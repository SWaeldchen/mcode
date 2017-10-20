% calculate the maps of shear wave speed, the penetration rate and the amplitude of
% the shear wave field from the complex MRE-data. This is done by smoothing 
% unwrapping, filtering and gradient inverion.
% 
% [c, a, amplitude] = kMDEV( MRsignal, inplaneResolution, frequency)
% 
% input:
% MRsignal              - 6D complex MRE signal
%                       - 1st and 2nd dimensions correspond to the in-plane matrix
%                         size(number of rows and columns)
%                       - 3rd dimension corresponds to the number of slices
%                         (at leeat 1 slice)
%                       - 4th dimension corresponds to the the number of timesteps
%                         (at least 3 timesteps)
%                       - 5th dimension contains the components of the displacement
%                         the order of the components SS, RO, and PE is arbitrary
%                       - 6th direction corresponds to the number of frequencies
%                   
% inplaneResolution     pixel spaceing in meters, correspond to the 1st and
%                       2nd dimensions in MRsignal, respectively.
%   
% frequency             array of frequencies in Hz
%                       note: length(frequency) must be identical to size(MRsignal,6)
%                       note: order of frequency must match the data order in the 6th dimension of MRsignal
% 
% output:
% c                     map of shear wave speed
%                       - c.standart: standart calculation of c
%                       - c.alternative: more stable calculation of c only if the shear
%                         wave amplitudes have a strong frequency dependence
%                       - c.frequencyResolved: calculation of frequency resolved c
%                       - c.standardStd: calutation of standard devitation of shear wave speed
% Lambda                 map of penetration depth
%                       - Lambda.standart: standart calculation of Lambda
%                       - Lambda.alternative: more stable calculation of a only if the shear
%                         wave amplitudes have a strong frequency dependence
%                       - Lambda.frequencyResolved: frequency resolved Lambda
% amplitude              map of amplitude
%                       - amplitude.standart: standart calculation of amplitude
%                       - amplitude.alternative: more stable calculation of amplitude only if the shear
%                         wave amplitudes have a strong frequency dependence
%                       - amplitude.frequencyResolved: gives the frequency resolved amplitude

% edit by Heiko Tzsch�tzsch, Charit�- Universit�tsmedizin Berlin, Berlin, Germany
% Date: 2015/10/16
function [c, Lambda, amplitude, shearWaveField, waveField] = kMDEV( MRsignal, inplaneResolution, frequency,sigma,n)

%smooth the complex MREsignal
%sigma = 2.75 * 10^-3 *3;%[m] filter strength for gaussien smoothing
MRsignalSmoothed = smoothMRsignal( MRsignal, inplaneResolution, sigma);

% rho = 10^3;%[kg/m^3]
% eta = 1;%[Pa s]
% sigma = sqrt(2 * eta ./ (rho * 2*pi*frequency) );%[m] filter strength for gaussien smoothing
% MRsignalSmoothed = smoothMRsignal2( MRsignal, inplaneResolution, sigma);


% calculate the temporally resolved wave field (phase of the complex MRsignal)
temporalWaveField = imag(log( MRsignalSmoothed ));


%unwrap the phase and decompose the frequency componets
waveField = gunwrapFFT( temporalWaveField );


% waveField = gradUnwrapFFT(MRsignal, frequency);

% directional and radial filtering of the complex wave field
% FilterRho.method = 'off';% flag for the radial filter
FilterRho.method = 'diff';% flag for the radial filter
% FilterRho.method = 'fermi';% flag for the radial filter
% FilterRho.value = mean(frequency)*sigma/4;%[m/s] HP-value for the radial filter
% FilterRho.method = 'diffgauss';% flag for the radial filter
% FilterRho.value = 2.25 * 10^-3;%[m] HP-value for the radial filter
% FilterRho.method = 'gaussC';% flag for the radial filter
% FilterRho.valueHP = 3;%[m/s] HP-value for the radial filter
% FilterRho.valueHP = sigma*(2*pi*45)*1;%[m/s] HP-value for the radial filter
FilterTheta.flag = 'on';% flag for the directional filter
FilterTheta.sigma = (2*pi)/n;% filter stength for the directional filter
shearWaveField = directionalRadialFilter( waveField, inplaneResolution, frequency, FilterRho, FilterTheta);


% main inversion
weigthingFactor = 4;% weigthing factor for the weigthed mean of shear wave speed and penetration rate (should be >= 1 or 0)
[c, Lambda, amplitude] = gradientInversion( shearWaveField, inplaneResolution, frequency, weigthingFactor);

end