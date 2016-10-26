% Fit frequencies to single voxel spring & dashot model
%
% Z= log(abs(G*)), c = log(mu^(1-alpha)* eta^alpha), m = number of frequencies
%
%clear all, close all

%% example 1 - fit to this data (result won't mean anything)
% wvec = [1:10].';
% Gvec = 10*rand(length(wvec),1) + 3;

%% example 2 - fit to known data 
wvec = 2*pi*[25,37.5,50,62.5].';
mu = 3.9; alf = 0.6; eta = 2.7;
Gvec = mu^(1-alf)*eta^alf*(1i*wvec).^alf;
%% standard code from here downwards

m = length(wvec);
if (length(Gvec) ~= m), end

v = log(wvec);
Z = log(abs(Gvec));
S = sum(v);

A(1,1) = sum(v.^2);
A(2,1) = S;
A(1,2) = S;
A(2,2) = m;

b(1,1) = sum(Z.*v);
b(2,1) = sum(Z);

x = A\b;

alpha = x(1);
%mu_ = ( Gvec ./ (wvec).^alf ) .^(1 / (1 - alpha));

int1 = (1i*wvec).^alpha;
int2 = eta.^alpha;
int3 = Gvec ./ (int1.*int2);
mu_ = int3.^(1/(1-alpha));










