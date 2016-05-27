function [ filtered_eeg ] = sma_filtering( raw_eeg , freq)
% This function implements the Superposition of Moving Averages (SMA) 
% algorithm, in order to clean tACS stimulation artifacts from raw EEG data.
%
% This is an implementation of the algorithm described in
% the article : 'Removal of transcranial a.c. current stimulation 
% artifact from simultaneous EEG recordings by superposition of 
% moving averages' by Siddharth Kohli and Alexander J. Casson, Member,IEEE
%
% Basicly, the raw data will be splited into N slices. A moving average will
% be calculated for each slice (using M of his neighbouring slices)
% and then reduced from the raw data.
%
% input Vars :
%   -- raw_eeg = a vector of single eeg channel
%   -- ferq = the stimulation frequency (that we want to clean) in Hz
% output Vars:
%   -- filtered_eeg = a vector of the filtered eeg
%

num_of_samples_in_seg = 2*ceil(500 / freq);
num_of_segments = ceil(length(raw_eeg)/num_of_samples_in_seg);

M = ceil(num_of_segments*0.05); % numebr of neighbors to consider
m = ceil(M/2); % number of neighbors to consider from each side
split_indexs = 1:num_of_samples_in_seg:length(raw_eeg);

Y = cell(num_of_segments,1);
average_vec = cell(num_of_segments,1);
filtered_vec = cell(num_of_segments,1);
filtered_eeg = [];

for ind = 1:num_of_segments - 1
   i = split_indexs(ind);
   Y{ind} = raw_eeg(i:i + num_of_samples_in_seg - 1);
end
Y{num_of_segments} = raw_eeg(split_indexs(num_of_segments):length(raw_eeg));
tail = length(Y{num_of_segments});

% Calculate the moving average for each segment and reduce it
for ind = 1:num_of_segments - 1
    temp_vec = Y{ind};
    dlm = 1;
    for n = 1:m
        if(ind - n > 0)
            dlm = dlm + 1;
            temp_vec = temp_vec + Y{ind - n};
        end
        if (ind + n < num_of_segments)
            dlm = dlm + 1;
            temp_vec = temp_vec + Y{ind + n};
        end
    end
    fix(temp_vec/dlm);
    average_vec{ind} = fix(temp_vec/dlm);
    filtered_vec{ind} = Y{ind} - average_vec{ind};
end
% Now we will deal with the tail segment
average{num_of_segments} = Y{num_of_segments};
dlm = 1;
for n = 1:m
    i = num_of_segments - n;
    if(i > 0)
        dlm = dlm + 1;
        average_vec{num_of_segments} = average{num_of_segments} + Y{i}(1:tail);
    end
end
average_vec{num_of_segments} = fix(average_vec{num_of_segments}/dlm);
filtered_vec{num_of_segments} = Y{num_of_segments} - average_vec{num_of_segments};

% Concatenate the splited filtered vector into single filtered eeg

for ind = 1:num_of_segments
    filtered_eeg = [filtered_eeg ;filtered_vec{ind}];
end

end

