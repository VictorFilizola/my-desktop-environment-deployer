#!/usr/bin/env python3
"""Query OBS recording status via WebSocket v5. Outputs waybar JSON.

Requires: OBS Studio with obs-websocket enabled (Tools → obs-websocket Settings)
No external Python dependencies — stdlib only.
"""

import socket
import json
import struct
import hashlib
import base64
import os
import time
import sys

OBS_HOST = "localhost"
OBS_PORT = 4455
TIMEOUT = 2
START_FILE = "/tmp/obs-recording-start"
AUTH_FILE = os.path.expanduser(
    "~/.config/obs-studio/plugin_config/obs-websocket/config.json"
)


class WS:
    """Minimal WebSocket client — just enough for OBS WebSocket v5."""

    def __init__(self, sock):
        self.sock = sock
        self.buf = bytearray()

    def _recv_exact(self, n):
        while len(self.buf) < n:
            chunk = self.sock.recv(max(n - len(self.buf), 4096))
            if not chunk:
                raise ConnectionError("socket closed")
            self.buf.extend(chunk)
        data = bytes(self.buf[:n])
        self.buf = self.buf[n:]
        return data

    def recv_frame(self):
        """Read one WebSocket frame, return (opcode, payload)."""
        b0 = self._recv_exact(1)[0]
        opcode = b0 & 0x0F

        b1 = self._recv_exact(1)[0]
        masked = (b1 & 0x80) != 0
        length = b1 & 0x7F

        if length == 126:
            length = struct.unpack(">H", self._recv_exact(2))[0]
        elif length == 127:
            length = struct.unpack(">Q", self._recv_exact(8))[0]

        mask = self._recv_exact(4) if masked else b""
        payload = self._recv_exact(length)

        if masked:
            payload = bytes(b ^ mask[i % 4] for i, b in enumerate(payload))

        return opcode, payload

    def send_frame(self, payload: bytes):
        """Send a masked text frame."""
        frame = bytearray([0x81])  # FIN + text opcode

        plen = len(payload)
        if plen < 126:
            frame.append(0x80 | plen)
        elif plen < 65536:
            frame.append(0x80 | 126)
            frame.extend(struct.pack(">H", plen))
        else:
            frame.append(0x80 | 127)
            frame.extend(struct.pack(">Q", plen))

        mask = os.urandom(4)
        masked = bytes(b ^ mask[i % 4] for i, b in enumerate(payload))
        frame.extend(mask)
        frame.extend(masked)

        self.sock.sendall(bytes(frame))


def handshake(sock):
    """Perform WebSocket HTTP upgrade. Returns any leftover bytes after
    the HTTP response for the WS frame parser to consume."""
    key = base64.b64encode(os.urandom(16)).decode()
    req = (
        f"GET / HTTP/1.1\r\n"
        f"Host: {OBS_HOST}:{OBS_PORT}\r\n"
        f"Upgrade: websocket\r\n"
        f"Connection: Upgrade\r\n"
        f"Sec-WebSocket-Key: {key}\r\n"
        f"Sec-WebSocket-Version: 13\r\n"
        f"\r\n"
    )
    sock.sendall(req.encode())

    data = b""
    while b"\r\n\r\n" not in data:
        chunk = sock.recv(4096)
        if not chunk:
            raise ConnectionError("handshake: connection closed")
        data += chunk

    header_end = data.index(b"\r\n\r\n") + 4
    leftover = data[header_end:]  # bytes after HTTP headers (start of WS frame)

    if b"101" not in data:
        first_line = data.split(b"\r\n")[0].decode()
        raise ConnectionError(f"handshake rejected: {first_line}")

    return leftover


def get_obs_password():
    try:
        with open(AUTH_FILE) as f:
            cfg = json.load(f)
        return cfg.get("server_password", "") or ""
    except Exception:
        return ""


def auth_response(password: str, challenge: str, salt: str) -> str:
    secret = base64.b64encode(
        hashlib.sha256((password + salt).encode()).digest()
    ).decode()
    return base64.b64encode(
        hashlib.sha256((secret + challenge).encode()).digest()
    ).decode()


def format_time(seconds):
    m = seconds // 60
    s = seconds % 60
    return f"{m:02d}:{s:02d}"


def main():
    try:
        # 1. Connect
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(TIMEOUT)
        sock.connect((OBS_HOST, OBS_PORT))

        # 2. HTTP upgrade → WS
        leftover = handshake(sock)
        ws = WS(sock)
        ws.buf = bytearray(leftover)

        # 3. Read Hello (op 0)
        op, payload = ws.recv_frame()
        hello = json.loads(payload)

        # 4. Send Identify (op 1)
        identify = {"op": 1, "d": {"rpcVersion": 1}}

        auth_info = hello.get("d", {}).get("authentication", {})
        if auth_info:
            password = get_obs_password()
            if password:
                identify["d"]["authentication"] = auth_response(
                    password,
                    auth_info["challenge"],
                    auth_info["salt"],
                )

        ws.send_frame(json.dumps(identify).encode())

        # 5. Read Identified (op 2)
        op, payload = ws.recv_frame()
        identified = json.loads(payload)

        # op 2 = Identified success. Anything else = auth failed.
        if identified.get("op") != 2:
            sock.close()
            print(json.dumps({"text": "", "class": "hidden"}))
            return

        # 6. Send GetRecordStatus (op 6 = Request)
        request = {
            "op": 6,
            "d": {
                "requestType": "GetRecordStatus",
                "requestId": "waybar",
            },
        }
        ws.send_frame(json.dumps(request).encode())

        # 7. Read RequestResponse (op 7)
        op, payload = ws.recv_frame()
        response = json.loads(payload)
        sock.close()

        is_active = (
            response.get("d", {})
            .get("responseData", {})
            .get("outputActive", False)
        )

        now = int(time.time())

        if is_active:
            if os.path.exists(START_FILE):
                with open(START_FILE) as f:
                    start = int(f.read().strip())
            else:
                start = now
                with open(START_FILE, "w") as f:
                    f.write(str(start))

            elapsed = now - start
            time_str = format_time(elapsed)
            mins, secs = divmod(elapsed, 60)
            print(
                json.dumps(
                    {
                        "text": f"● REC {time_str}",
                        "class": "recording",
                        "tooltip": f"OBS recording — {mins}m {secs}s",
                    }
                )
            )
        else:
            if os.path.exists(START_FILE):
                os.remove(START_FILE)
            print(json.dumps({"text": "", "class": "hidden"}))

    except (ConnectionRefusedError, socket.timeout, ConnectionError, OSError):
        print(json.dumps({"text": "", "class": "hidden"}))
    except Exception:
        # Don't spam waybar with errors — hide module on any failure
        print(json.dumps({"text": "", "class": "hidden"}))


if __name__ == "__main__":
    main()
