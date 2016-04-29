function [ Stm ] = getStimulation( EEG )
% This function will get EEG activity and return what stimulation
% we would like to do

% This is just a very simple example, NOT the real function

Stm.Function = 'MatNICOnlineAtdcsPeak';
Stm.amplitudeArray = 1000*(EEG.Activities(1,3) > 0.5);% Stimulate only if Alpha activity is present
Stm.channelArray = 1;
Stm.transitionToPeak = 1000;
Stm.transitionStay = 1000;
Stm.transitionFromPeak = 1000; 


end

