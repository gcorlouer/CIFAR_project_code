% FIR Filtering testing
forder = 120;
fcut1 = 60;
fcut2 = 80;
stopbandAttenuation1 = 1;
stopbandAttenuation2 = 1;
fs = 500;
bandpassRipple = 0.1; 
kaiserParam = 3.4;

%% Rectangular window 
bpFilt = designfilt('bandpassfir', 'FilterOrder', forder, ...
        'CutoffFrequency1',fcut1,'CutoffFrequency2',fcut2, ...
        'SampleRate',fs);
    
fvtool(bpFilt)

%% CLS
bpFilt = designfilt('bandpassfir', 'FilterOrder', forder, ...
                    'CutoffFrequency1', fcut1, 'CutoffFrequency2', fcut2, ...
                    'StopbandAttenuation1', stopbandAttenuation1, ... 
                    'PassbandRipple', bandpassRipple, ...
                    'StopbandAttenuation2', stopbandAttenuation1, 'SampleRate', fs, ...
                    'DesignMethod', 'cls');
fvtool(bpFilt)

%% Kaiser window
bpFilt = designfilt('bandpassfir', 'FilterOrder', forder, ...
                    'CutoffFrequency1', fcut1, 'CutoffFrequency2', fcut2, ...
                    'SampleRate', fs, ...
                    'DesignMethod', 'window', 'Window', {@kaiser,kaiserParam});
fvtool(bpFilt)
%% Hamming window

bpFilt = designfilt('bandpassfir', 'FilterOrder', forder, ...
                    'CutoffFrequency1', fcut1, 'CutoffFrequency2', fcut2, ...
                    'SampleRate', fs, ...
                    'DesignMethod', 'window', 'Window', 'hamming');
                
fvtool(bpFilt)
% Order of 120 seems quite good

%% Minphase filter
Fs  = 500;
Fn  = Fs/2;
f = [0 55 60 80 85 Fn]/Fn;
a = [0 0 1 1 0 0];

w   = [10 1 10];
b   = firgr(forder, f, a, w, 'minphase');
hfvt = fvtool(b,'Fs', Fs,...
              'MagnitudeDisplay', 'Magnitude (dB)',...
              'legend','on');
legend(hfvt,'Min Phase');

fvtool(b, 'Fs', Fs, ...
              'Analysis', 'Impulse', ...
              'legend', 'on', ...
              'Arithmetic', 'fixed');

%% Analysis folter 

b_fixed = fi(b,1,15); % use best precision fraction length
T_coeff = numerictype(b_fixed);
minPhaseFilter = dsp.FIRFilter('Structure','Direct form transposed');
minPhaseFilter.Numerator = double(b_fixed);
minPhaseFilter.FullPrecisionOverride = false;
minPhaseFilter.CoefficientsDataType = 'Custom';
minPhaseFilter.CustomCoefficientsDataType = T_coeff;
minPhaseFilter.ProductDataType = 'Full precision';
minPhaseFilter.AccumulatorDataType = 'Full precision';
minPhaseFilter.OutputDataType = 'Same as accumulator';
%% 
hfvt = fvtool(minPhaseFilter, 'Fs', Fs, ...
              'Analysis', 'freq', ...
              'legend', 'on', ...
              'Arithmetic', 'fixed');
legend(hfvt, 'Min Phase');
%% 
hfvt = fvtool(minPhaseFilter, 'Fs', Fs, ...
              'Analysis', 'Impulse', ...
              'legend', 'on', ...
              'Arithmetic', 'fixed');
legend(hfvt, 'Min Phase');
%% Observations
% Kaiser window more precise but more ripples
% CLS more equiripple in attenuation but some ripples in bandpass or less
% ripple in bandpass but ripples have higher power outside bandpass
% Is minimum phase filter FIR? Not much ripples but also not very low
% amplitude 
