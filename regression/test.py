import numpy as np
from sklearn import linear_model

import sys
import json
import requests

#delta, theta, alpha, beta, gamma
def get_deltas(act_a, act_b):
    bands = ["delta_activity", "theta_activity", "alpha_activity", "beta_activity", "gamma_activity"]
    deltas = list()
    for band in bands:
        #print "subtracting", float(act_a[band]), "and", float(act_b[band])
        deltas.append(float(act_a[band]) - float(act_b[band]))
    return deltas

#{action:'EEG_ACTIVITY_AND_STIMULATION_GET',data:{session_id:7}} stimulation_duration, stimulation_amplitude, stimulation_frequency
request_from_server = dict()
request_from_server['action'] = 'EEG_ACTIVITY_AND_STIMULATION_GET'
request_from_server['data'] = dict()
#FIXME - change to input session id
request_from_server['data']['session_id'] = 8

#obj = json.dumps({'action':'EEG_ACTIVITY_AND_STIMULATION_GET','data':{'session_id':6}})#, sort_keys=True, indent=4, separators=(',', ': '))
obj = json.dumps(request_from_server)
url = 'http://www.cs.tau.ac.il/~noamp1/cLoop/php/sql_server/handle_request_from_matlab.php'

headers = {'Content-type': 'application/json', 'Accept': 'text/plain'}

r = requests.post(url, data=obj, headers=headers)

#Create dictionaries of stimulations by stimulation and activity id
stimulations_by_stimulation_id = dict()
stimulations_by_eeg_activity_id = dict()
for stimulation in r.json()["data"]["STIMULATION"]:
    if not stimulation["stimulation_id"] is None:
        stimulations_by_stimulation_id[int(stimulation["stimulation_id"])] = stimulation
    if not stimulation["eeg_activity_id"] is None:
        stimulations_by_eeg_activity_id[int(stimulation["eeg_activity_id"])] = stimulation

#Create dictionaries of eeg activities by activity and stimulation id
eeg_activities_by_eeg_activity_id = dict()
eeg_activities_by_stimulation_id = dict()
for eeg_activity in r.json()["data"]["EEG_ACTIVITY"]:
    if not eeg_activity["eeg_activity_id"] is None:
        eeg_activities_by_eeg_activity_id[int(eeg_activity["eeg_activity_id"])] = eeg_activity
    if not eeg_activity["stimulation_id"] is None:
        eeg_activities_by_stimulation_id[int(eeg_activity["stimulation_id"])] = eeg_activity

deltas = list()
stims = list()

for stimulation in stimulations_by_stimulation_id:
    if (not stimulations_by_stimulation_id[stimulation]["eeg_activity_id"] is None) and \
        (int(stimulations_by_stimulation_id[stimulation]["eeg_activity_id"]) in eeg_activities_by_eeg_activity_id) and \
        (not stimulations_by_stimulation_id[stimulation]["stimulation_id"] is None) and \
        (int(stimulations_by_stimulation_id[stimulation]["stimulation_id"]) in eeg_activities_by_stimulation_id):
            act_b = eeg_activities_by_eeg_activity_id[int(stimulations_by_stimulation_id[stimulation]["eeg_activity_id"])]
            act_a = eeg_activities_by_stimulation_id[int(stimulations_by_stimulation_id[stimulation]["stimulation_id"])]
            deltas.append(get_deltas(act_a, act_b))
            stim = stimulations_by_stimulation_id[stimulation]
            stims.append([float(stim["stimulation_duration"]), float(stim["stimulation_amplitude"]), float(stim["stimulation_frequency"])])

    #(not eeg_activities[int(stimulation["eeg_activity_id"])]["stimulation_id"] is None)

print (stims)
print (deltas)


X = np.ndarray(shape = (len(deltas),len(deltas[0])), buffer = np.array(deltas), dtype = float)
y_0 = np.ndarray(shape = (len(stims)), buffer = np.array([item[0] for item in stims]), dtype = float)
y_1 = np.ndarray(shape = (len(stims)), buffer = np.array([item[0] for item in stims]), dtype = float)
y_2 = np.ndarray(shape = (len(stims)), buffer = np.array([item[0] for item in stims]), dtype = float)
temp = [1,2,3,4,5]
X_test = np.array(temp).reshape(1,-1)

#X_test = np.ndarray(shape = (5), buffer = np.array([1,2,3,4,5]), dtype = float)
#X_test.reshape(1,-1)
regr = linear_model.LinearRegression()

regr.fit(X, y_0)

print("Done with regression fit")
print("Predicting for", X_test)
print("Reg predict", regr.predict(X_test))
print('Coefficients: \n', regr.coef_)
print("Intercept: \n", regr.intercept_)
print("done")

