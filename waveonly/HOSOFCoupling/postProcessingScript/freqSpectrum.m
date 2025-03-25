
function [f,a,S]=freqSpectrum(t,x,flagmean)

% Takes a time vector and a signal and returns the one-sided Fourier 
% coefficients obtained with FFT, as well as the PSD function

% flagmean=0: f(1)=df, a(1)=mean(x) is removed
% flagmean=1: f(1)=0,  a(1)=mean(x) is kept

if length(t)==1
    
    f = NaN;
    a = NaN;
    S = NaN;
    
else

    % Definition of frequency vector
    Tmax = t(end)-t(1);
    df = 1/Tmax;
    if flagmean
        f = 0:df:(length(t)-1)*df;
    else
        f = df:df:length(t)*df;
    end

    % Amplitudes - first element of a is the mean of x(t)
    a = (fft(x))/length(t);

    % Make the amplitudes one-sided
    dt = t(2) - t(1);
    f_nyq = 1/2/dt;
    a(f>f_nyq) = 0;
    if flagmean
        a(2:end) = 2*a(2:end);
    else
       a = a(2:length(f));
       a(end+1) = 0;
       a = 2*a;
    end

    % PSD function
    S = (abs(a).^2)/2/df;

end
    
return