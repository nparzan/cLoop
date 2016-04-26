function [ EEG ] = getEEG( seconds, channels, host )
% Records eeg and returns the wave types (Alpha,Beta,etc...) activity
% levels
% 
disp('INFO: Recording started');
raweeg = MatNICEEGRecord(seconds, channels, host);
%raweeg = raweeg(:,4);
%plot(raweeg);
disp('INFO: Recording finished');
pause(seconds);
EEG = struct('channels',channels,'Activities',[]);
eegWaves = zeros(channels,5);
for i = 1:channels
    [ Delta,Theta,Alpha,Beta,Gamma ] = analyzeEEG( raweeg(:,i) );
    eegWaves(i,:) = [ Delta,Theta,Alpha,Beta,Gamma ];
end
EEG.Activities = (eegWaves)/1000; % change to mV
end

