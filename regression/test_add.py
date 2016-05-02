import sys
import json
import requests

#{action:'EEG_ACTIVITY_AND_STIMULATION_GET',data:{session_id:7}}
obj = json.dumps({'action':'STIMULATION_ADD','table':'cloop_stimulation','data':{'session_id':6,'stimulation_duration':56,'stimulation_amplitude':23,'stimulation_frequency':7.23}})

url = 'http://www.cs.tau.ac.il/~noamp1/cLoop/php/sql_server/handle_request_from_matlab.php'

headers = {'Content-type': 'application/json', 'Accept': 'text/plain'}

r = requests.post(url, data=obj, headers=headers)

print r.content
