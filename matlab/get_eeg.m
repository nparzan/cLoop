function [ EEG ] = get_eeg( seconds, nchannels, host )
% Records eeg and returns channel activity, represented as bands
% (alpha,beta, etc...)
% 
% Input Parameters:
%   seconds = number of seconds to record EEG from the device
%   nchannels = the number of channels to record
%   host = the host device 
%
% Output Parameters:
%   EEG = a struct which represent the current EEG activity
%           EEG.channels - The number of channels 
%           EEG.Activities - Matrix that hold the band activity for
%                            each of the recorded channels 
%

disp('INFO: Recording started');
raweeg = MatNICEEGRecord(seconds, nchannels, host);
pause(seconds);
disp('INFO: Recording finished');

EEG = struct('channels',nchannels,'Activities',[]);
eegWaves = zeros(nchannels,5); %5 is the number of bands 

for i = 1:nchannels
    [ Delta,Theta,Alpha,Beta,Gamma ] = analyze_eeg( raweeg(:,i) );
    eegWaves(i,:) = [ Delta,Theta,Alpha,Beta,Gamma ];
end

EEG.Activities = (eegWaves)/1000; % change to mV

end

