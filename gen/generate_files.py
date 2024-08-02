import os
import os.path
import sys
import gzip
import string
import random

def get_arg(name):
    return "".join(list(filter(lambda arg: arg.startswith(f"--{name}="), sys.argv))[0].split("=")[1:])

def rand_string(strlen):
    return ''.join(random.choice(string.ascii_lowercase) for x in range(strlen))

def rand_file(fpath, size):
    rand = open("/dev/urandom", "rb")
    with open(fpath, "wb") as file:
        file.write(rand.read(size))
    rand.close()

def fill_boot(path):
    # fill modules dir
    os.mkdir(os.path.join(path, "modules"))
    for _ in range(24):
        rand_file(os.path.join(path, "modules", rand_string(14)), random.randint(1024*3, 1024*1024))
    # generate some configs
    for _ in range(10):
        rand_file(os.path.join(path, rand_string(8)), random.randint(16, 1024))
    # write stage2 and kernel
    rand_file(os.path.join(path, "stage2"), 8192)
    rand_file(os.path.join(path, "kernel"), 1024*1024*16)

def fill_root(path, dirs):
    with gzip.open(dirs, "rt") as dirs:
        for dir_path in dirs:
            dir = dir_path[1:].strip()
            if not dir: continue
            os.mkdir(os.path.join(path, dir.strip()))


if __name__ == "__main__":
    path = get_arg("path")
    dirs = get_arg("dirs")
    mode = get_arg("mode")

    if not os.path.exists(path):
        sys.stderr.write("the mnt dir doesn't exists. preventing disaster")
        sys.exit(1)

    if mode == "boot": fill_boot(path)
    elif mode == "root": fill_root(path, dirs)
    else:
        sys.stderr.write("unkown mode\n")
        sys.exit(1)