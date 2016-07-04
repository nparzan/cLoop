function [ average_eeg ] = get_optimal_activity( EEG )

% This function calculate the optimal EEG activity that the system will try
% to achive during the session. 
% for now, it is just the average of the channel activity after the initial
% stimulation.

average_eeg = zeros(1,EEG.Channels);

for band = 1:5
   average_eeg = average(EEG.Activities(:,band)); 
end

end

