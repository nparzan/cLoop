import sys


def main():
    input_string = sys.argv[1]
    print 'Hello World!', input_string
    if input_string == 'blerg':
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()
