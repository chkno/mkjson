import sys

import more_itertools
import jsonstreams

def main():
    args = sys.argv[1:]
    if len(args) % 2:
        sys.exit("Expected an even number of arguments")

    with jsonstreams.Stream(jsonstreams.Type.object, filename="/dev/stdout") as s:
        for k, v in more_itertools.sliced(args, 2):
            if k.endswith("@"):
                # Waiting on https://github.com/dcbaker/jsonstreams/issues/30
                # for a way to do this in bounded memory.
                if v == '-':
                    s.write(k[0:-1], sys.stdin.read())
                else:
                    with open(v, "r") as f:
                        s.write(k[0:-1], f.read())
            else:
                s.write(k, v)

if __name__ == '__main__':
    main()
