import sys
import json
import requests

#{action:'EEG_ACTIVITY_AND_STIMULATION_GET',data:{session_id:7}} stimulation_duration, stimulation_amplitude, stimulation_frequency
obj = json.dumps({'action':'EEG_ACTIVITY_AND_STIMULATION_GET','data':{'session_id':7}})#, sort_keys=True, indent=4, separators=(',', ': '))

url = 'http://www.cs.tau.ac.il/~noamp1/cLoop/php/sql_server/handle_request_from_matlab.php'

headers = {'Content-type': 'application/json', 'Accept': 'text/plain'}

r = requests.post(url, data=obj, headers=headers)

print r.content
