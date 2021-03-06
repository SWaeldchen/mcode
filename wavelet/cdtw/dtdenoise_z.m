function [U_den] = dtdenoise_z(U, fac, J)
[h0, h1, g0, g1] = daubf(3);
if nargin < 3
    J = 1;
end
sz = size(U);
if nargin < 2
	fac = 1;
end
if (numel(sz) < 4)
    d4 = 1;
else
    d4 = sz(4);
end

pwr = 0;
while (2^pwr < sz(3)) 
    pwr = pwr+1;
end
xDim = 2^(pwr+1);
Uex = zeros(sz(1), sz(2), xDim, d4);
for m = 1:d4
    [temp, order_vector] = extendZ2(U(:,:,:,m), xDim);
    [Uex(:,:,:,m)] = temp(1:sz(1),1:sz(2),:);
end
U = Uex;
U_den = zeros(sz(1), sz(2), xDim, d4);
for m = 1:d4
    cube = U(:,:,:,m);
    %lambda = getLambda(U(:,:,:,m),0);
    lambda = median(abs(cube(:) - median(cube(:))));

    T = lambda*fac;
    for i=1:sz(1)
        for j =1:sz(2)
            z_line = squeeze(U(i,j,:,m));
            w = udwt(z_line, J, h0, h1);
			for n = 1:J
            	a = w{n};
<<<<<<< HEAD
				w{n} = max(abs(a) - T, 0);
			end
            z_line_den = iudwt(w, J, g0, g1);
            U_den(i,j,:,m) = z_line_den(1:numel(z_line));
=======
				c = max(abs(a) - T, 0);
		        w{n}{1} = real(c);
		        w{n}{2} = imag(c);
			end
            z_line_den = iudwt(w, J, g0, g1);
            U_den(i,j,:,m) = z_line_den;
>>>>>>> 14803ebee41767e1a5bf2a62664855d932748d33
        end
    end
end



