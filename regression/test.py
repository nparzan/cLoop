import numpy as np
from sklearn import linear_model
import sys
import json
import requests

#Get relevant input variables
session_id = sys.argv[1]
parameter_for_fitting = int(sys.argv[2])

#Deduce the eeg difference between a pair of activities linked by a stimulation
def get_deltas(act_a, act_b):    
    bands = ["delta_activity", "theta_activity", "alpha_activity", "beta_activity", "gamma_activity"]
    deltas = list()
    for band in bands:
        deltas.append(float(act_a[band]) - float(act_b[band]))
    return deltas

#Once model has been fit, get coefficents and intercept value
def get_regression_model_coeffs(model):
    bands = ["delta", "theta", "alpha", "beta", "gamma"]
    coeffs = dict()
    for i in range(len(model.coef_)):
        coeffs[bands[i]] = model.coef_[i]
    coeffs["intercept"] = model.intercept_
    return coeffs

#{action:'EEG_ACTIVITY_AND_STIMULATION_GET',data:{session_id:7}} stimulation_duration, stimulation_amplitude, stimulation_frequency
request_from_server = dict()
request_from_server['action'] = 'EEG_ACTIVITY_AND_STIMULATION_GET'
request_from_server['data'] = dict()
#FIXME - change to input session id
request_from_server['data']['session_id'] = session_id

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

#FIXME: Document
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

#If we don't have enough points, we abort
if len(deltas) < 2:
    print 'NONE'
    exit(0);

X = np.ndarray(shape = (len(deltas),len(deltas[0])), buffer = np.array(deltas), dtype = float)
y_0 = np.ndarray(shape = (len(stims)), buffer = np.array([item[parameter_for_fitting] for item in stims]), dtype = float)
#y_1 = np.ndarray(shape = (len(stims)), buffer = np.array([item[0] for item in stims]), dtype = float)
#y_2 = np.ndarray(shape = (len(stims)), buffer = np.array([item[0] for item in stims]), dtype = float)
#temp = [1,2,3,4,5]
#X_test = np.array(temp).reshape(1,-1)

regr = linear_model.LinearRegression()
regr.fit(X, y_0)

#print (stims)
#print (deltas)
#print("Done with regression fit")
#print("Predicting for", X_test)
#print("Reg predict", regr.predict(X_test))
#print('Coefficients: \n', regr.coef_)
#print("Intercept: \n", regr.intercept_)
#print("done")

print json.dumps(get_regression_model_coeffs(regr), sort_keys=True)

