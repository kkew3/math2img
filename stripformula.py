#!/usr/bin/env python
if __name__ == '__main__':
    import sys
    with open(sys.argv[1]) as infile:
        content = infile.read().strip()
    content += '\n'
    with open(sys.argv[1], 'w') as outfile:
        outfile.write(content)
