function [ EEG ] = get_eeg( seconds, nchannels, host , filter_func, stim_freq)
% Records eeg and returns channel activity, represented as bands
% (alpha,beta, etc...)
% 
% Input Parameters:
%   seconds = number of seconds to record EEG from the device
%   nchannels = the number of channels to record
%   host = the host device
%   filter_func = eeg filter function
%   stim_freq = relevant tACS stimuation frequency
%
% Output Parameters:
%   EEG = a struct which represent the current EEG activity
%           EEG.channels - The number of channels 
%           EEG.Activities - Matrix that hold the band activity for
%                            each of the recorded channels 
%

if nargin == 3
    filter_func = '';
    stim_freq = 0;
end

disp('INFO: Recording started');
raweeg = MatNICEEGRecord(seconds, 8, host);
pause(seconds);
disp('INFO: Recording finished');

if strcmp(filter_func,'sma')
    for i = 1:nchannels
        raweeg(:,i) = sma_filtering( raweeg(:,i) , stim_freq);
    end
end

EEG = struct('Channels',nchannels,'Activities',[]);
eegWaves = zeros(nchannels,5); %5 is the number of bands 

for i = 1:nchannels
    [ Delta,Theta,Alpha,Beta,Gamma ] = analyze_eeg( raweeg(:,i) );
    eegWaves(i,:) = [ Delta,Theta,Alpha,Beta,Gamma ]/1000; % change to mV
end

EEG.Activities = eegWaves;

end

