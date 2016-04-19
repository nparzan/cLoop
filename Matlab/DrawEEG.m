function [ ] = DrawEEG(EEGMatrix )
% A very simple function to draw EEG data of ONE channel
[Rows,Columns]=size(EEGMatrix);
n=(1:1:Rows);
plot(n,EEGMatrix(:,1)/1e3)

end

