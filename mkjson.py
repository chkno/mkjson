import sys

import more_itertools
import jsonstreams

def main():
    args = sys.argv[1:]
    if len(args) % 2:
        sys.exit("Expected an even number of arguments")

    with jsonstreams.Stream(jsonstreams.Type.object, filename="/dev/stdout") as s:
        for k, v in more_itertools.sliced(args, 2):
            s.write(k, v)

if __name__ == '__main__':
    main()
