function [peaks,prob] = peaks_prob(t,signal,t_min)

% Given a signal, the corresponding time vector and the minimum time between 
% peaks, the function returns the peaks and exceedance probability vectors 

if length(t)>1
    
    % Find the peaks and sort them in absolute value
    fsamp = 1/(t(2)-t(1));
    signal = abs(signal);
    peaks = findpeaks(double(signal),fsamp,'MinPeakDistance',t_min);
    peaks = sort(peaks);
    
    % Build the probability vector
    index = 1:1:length(peaks);
    prob = 1-(index./(length(index)+1));
    
else
    
    peaks = NaN;
    prob = NaN;

end

return