#!/usr/bin/env python
if __name__ == '__main__':
    import sys
    with open(sys.argv[1]) as infile:
        content = infile.read()
    content = content.strip()
    if not content:
        sys.exit(1)
