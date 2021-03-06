from contextlib import contextmanager
import fcntl
import json
import sys

import more_itertools
import jsonstreams

# Consider using https://github.com/benediktschmitt/py-filelock
# or https://github.com/AntoineCezar/flockcontext instead
@contextmanager
def flocked(fd, operation=fcntl.LOCK_SH):
    try:
        fcntl.flock(fd, operation)
        yield
    finally:
        fcntl.flock(fd, fcntl.LOCK_UN)

def main():
    args = sys.argv[1:]
    if len(args) % 2:
        sys.exit("Expected an even number of arguments")

    with jsonstreams.Stream(jsonstreams.Type.object, filename="/dev/stdout") as s:
        for k, v in more_itertools.sliced(args, 2):
            if k.endswith("@!") or k.endswith("!@"):
                # This currently isn't memory-efficient at all.  :(
                if v == '-':
                    s.write(k[0:-2], json.load(sys.stdin))
                else:
                    with open(v, "r") as f:
                        with flocked(f):
                            s.write(k[0:-2], json.load(f))
            elif k.endswith("@"):
                # Waiting on https://github.com/dcbaker/jsonstreams/issues/30
                # for a way to do this in bounded memory.
                if v == '-':
                    s.write(k[0:-1], sys.stdin.read())
                else:
                    with open(v, "r") as f:
                        with flocked(f):
                            s.write(k[0:-1], f.read())
            elif k.endswith("!"):
                s.write(k[0:-1], json.loads(v))
            else:
                s.write(k, v)

if __name__ == '__main__':
    main()
