import json
import subprocess
import sys
from tempfile import NamedTemporaryFile

import more_itertools
import jsonstreams

def main():
    args = sys.argv[1:]
    if len(args) % 2:
        sys.exit("Expected an even number of arguments")

    with NamedTemporaryFile() as f:
        with jsonstreams.Stream(jsonstreams.Type.object, filename=f.name) as s:
            for k, v in more_itertools.sliced(args, 2):
                s.write(k, v)
        f.flush()
        subprocess.run(['cat', f.name])

if __name__ == '__main__':
    main()
