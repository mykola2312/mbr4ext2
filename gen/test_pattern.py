import sys
from struct import pack

for i in range (0, 2048):
    sys.stdout.buffer.write(pack("<I", i) + b'\0'*504 + b'\x45\x4e\x44\x21')