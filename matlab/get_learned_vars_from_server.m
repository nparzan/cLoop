function [stimLength, tACS_Freq, stimAmp] = get_learned_vars_from_server(EEG)
% This function will get EEG activity and return what stimulation
% we would like to perform.
% We assume that only channel 4 is relevant for our test.

% This is just a very simple example, NOT the real function!
% We DO NOT connect to our DB server here

Amp_to_stim = 1200;
Upper_TH = 1156;
Lower_TH = 30;
Theta = 2;
eegChannel = 4;

EEG.Activities(eegChannel,:)

stimLength = 30000;
tACS_Freq = 6;
stimAmp = 0;

% Stimulate only if Theta activity < Upper_TH and > Lower_TH

fprintf('\nChannel 4 theta activity is %d \n',EEG.Activities(eegChannel,Theta));

if(((EEG.Activities(eegChannel,Theta) > Lower_TH)&&(EEG.Activities(eegChannel,Theta) < Upper_TH)))
    stimAmp = Amp_to_stim;
    disp('Stimulating...')
else
    stimAmp = 0;
    disp('Not stimulating...')
end

end

