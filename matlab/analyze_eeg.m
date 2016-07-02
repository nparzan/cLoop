function [ Delta,Theta,Alpha,Beta,Gamma ] = analyze_eeg( eeg_signal )
% This function get a raw eeg signal from a single channel 
% use FFT to break it into to frequencies and return the MAX AMPLITUDE
% for each of the wave types

fs = 500; % StarSim Sampling Frequency is 500Hz
                       
% Time properties
Datapoints = length(eeg_signal); % Number of recorded data;
y = eeg_signal;

% Fourier Transformation

NFFT = Datapoints; % Next power of 2 from length of y
Y = fft(y,NFFT)/Datapoints;
f = fs/2*linspace(0,1,NFFT/2+1);

% Store the Freqs and Amps

[B,IX] = sort(2*abs(Y(1:NFFT/2+1)));
BFloor=0.1; %BFloor is the minimum amplitude value (ignore small values) 
Amplitudes = B(B>=BFloor); %find all amplitudes above the BFloor 
Frequencies = f(IX(1+end-numel(Amplitudes):end)); %frequency of the peaks

% Plot single-sided amplitude spectrum.

%plot(f,2*abs(Y(1:NFFT/2+1)));
%axis([0 max(Frequencies) 0 max(Amplitudes)]);
%title('Single-Sided Amplitude Spectrum of y(t)');
%xlabel('Frequency (Hz)');
%ylabel('Amplitude - |Y(f)|');

% Seperate into EEG wave types
% Delta (0.5-4Hz)
% Theta (4-8Hz)
% Alpha (8-12Hz)
% Beta (12-40Hz)
% Gamma (38-42Hz)
% Everything else will be counted as noise

Delta = [0];Theta = [0];Alpha = [0];Beta = [0];Gamma = [0];

for i = 1:length(Amplitudes)
    fr = Frequencies(i);
    if ((fr < 0.5) || (fr >= 42))
        continue;
    elseif ((fr >= 0.5) && (fr < 4))
        Delta = [Delta Amplitudes(i)];
    elseif ((fr >= 4) && (fr < 8))
        Theta = [Theta Amplitudes(i)];
    elseif ((fr >= 8) && (fr < 12))
        Alpha = [Alpha Amplitudes(i)];
    elseif ((fr >= 12) && (fr < 38))
        Beta = [Beta Amplitudes(i)];
    elseif ((fr >= 38) && (fr < 42))
        Gamma = [Gamma Amplitudes(i)];
    end 
end

% Calculating the max Amplitude for each wave type

Delta = max(Delta);
Theta = max(Theta);
Alpha = max(Alpha);
Beta = max(Beta);
Gamma = max(Gamma);
end

