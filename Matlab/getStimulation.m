function [ Stm ] = getStimulation( EEG )
% This function will get EEG activity and return what stimulation
% we would like to do

% This is just a very simple example, NOT the real function
eegChannel = 4;

EEG.Activities(eegChannel,:)
Stm.Function = 'MatNICOnlineAtacsPeak';
% Stimulate only if Theta activity is larger than 50 mV
Stm.amplitudeArray = 1200*((EEG.Activities(eegChannel,2) > 30)&&(EEG.Activities(eegChannel,2) < 1156));
fprintf('\nChannel 4 theta activity is %d \n',EEG.Activities(eegChannel,2));

if((EEG.Activities(eegChannel,2) > 30)&&(EEG.Activities(eegChannel,2) < 1156))
    disp('Stimulating...')
else
    disp('Not stimulating...')
end
Stm.channelArray = 1;
Stm.transitionToPeak = 5000;
Stm.transitionStay = 10000;
Stm.transitionFromPeak = 5000; 


end

