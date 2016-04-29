function [ Stm ] = getStimulation( EEG )
% This function will get EEG activity and return what stimulation
% we would like to do

% This is just a very simple example, NOT the real function
% We DO NOT connect to our DB server here

Amp_to_stim = 1200;
Upper_TH = 1156;
Lower_TH = 30;
Theta = 2;
eegChannel = 4;

EEG.Activities(eegChannel,:)
Stm.Function = 'MatNICOnlineAtacsPeak';

% Stimulate only if Theta activity < Upper_TH and > Lower_TH

fprintf('\nChannel 4 theta activity is %d \n',EEG.Activities(eegChannel,Theta));

if(((EEG.Activities(eegChannel,Theta) > Lower_TH)&&(EEG.Activities(eegChannel,Theta) < Upper_TH)))
    Stm.amplitudeArray = Amp_to_stim;
    disp('Stimulating...')
else
    Stm.amplitudeArray = 0;
    disp('Not stimulating...')
end

Stm.channelArray = 1;
Stm.transitionToPeak = 5000;
Stm.transitionStay = 10000;
Stm.transitionFromPeak = 5000; 

end

