import sys, json


def f():
    print ("XXXs")

# Load the data that PHP sent us
try:
    data = int(sys.argv[1])
    #print("OK")
except:
    print "ERROR"
    sys.exit(1)

# Generate some data to send to PHP
#result = {'status': 'Yes!'}

# Send it to stdout (to PHP)
print data * 2 #json.dumps(result)

