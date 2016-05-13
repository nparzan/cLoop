import sys
import json
import requests

#{action:'EEG_ACTIVITY_AND_STIMULATION_GET',data:{session_id:7}} stimulation_duration, stimulation_amplitude, stimulation_frequency
request_from_server = dict()
request_from_server['action'] = 'EEG_ACTIVITY_AND_STIMULATION_GET'
request_from_server['data'] = dict()
request_from_server['data']['session_id'] = 6

#obj = json.dumps({'action':'EEG_ACTIVITY_AND_STIMULATION_GET','data':{'session_id':6}})#, sort_keys=True, indent=4, separators=(',', ': '))
obj = json.dumps(request_from_server)
url = 'http://www.cs.tau.ac.il/~noamp1/cLoop/php/sql_server/handle_request_from_matlab.php'

headers = {'Content-type': 'application/json', 'Accept': 'text/plain'}

r = requests.post(url, data=obj, headers=headers)


j = json.dumps(r.content, sort_keys=True, indent=4, separators=(',', ': '))
print j

# PARSE WITH r.json()

print type(j)
