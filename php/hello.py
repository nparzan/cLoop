import sys
import json
import requests

#{action:'EEG_ACTIVITY_AND_STIMULATION_GET',data:{session_id:7}}
j = json.dumps({'action':'EEG_ACTIVITY_AND_STIMULATION_GET','data':{'session_id':7}}, sort_keys=True, indent=4, separators=(',', ': '))

def main():
    print 'About to try'
    try:
        print 'Try successful'
        #input_j = json.loads(sys.argv[1])
    except:
        print 'Try failed'
        sys.exit(1)    

    result = {'status': 'Yes!'}

    print json.dumps(result)
    sys.exit(0)

if __name__ == "__main__":
    main()
