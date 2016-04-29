function [ EEG ] = getEEG( seconds, channels, host )
% Records eeg and returns the wave types (Alpha,Beta,etc...) activity
% levels
% 
disp('INFO: Recording started')     
raweeg = MatNICEEGRecord(seconds, channels, host);
disp('INFO: Recording finished')
pause(seconds)
EEG = struct('channels',channels,'Activities',[]);
for i = 1:length(channels)
    [ Delta,Theta,Alpha,Beta,Gamma ] = analyzeEEG( raweeg(i) );
    eegWaves(i) = [ Delta,Theta,Alpha,Beta,Gamma ];
end
EEG.Activities = eegWaves;
end

