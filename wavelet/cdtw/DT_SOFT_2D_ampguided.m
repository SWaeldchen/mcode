function [y, w] = DT_SOFT_2D_ampguided(x, amp, T, J)

[Faf, Fsf] = FSfarras;
[af, sf] = dualfilt1;
if (nargin < 4)
	J = 2;
end
w = cplxdual2D(x,J,Faf,af);
I = sqrt(-1);
% loop thru scales:
for j = 1:J
    % loop thru subbands
    for s1 = 1:2
        for s2 = 1:3
            C = w{j}{1}{s1}{s2} + I*w{j}{2}{s1}{s2};
			amp = imresize(double(amp), size(C));
            %C = ( C - T^2 ./ C ) .* (abs(C) > T); 
			% soft thresh
		    C = max(abs(C) - T ./ 2*amp, 0);
		    %C = c./(c+T) .* C;
            %C = ogs2(C, 3, 3, 0.08, 'atan', 1, 5);
            w{j}{1}{s1}{s2} = real(C);
            w{j}{2}{s1}{s2} = imag(C);
        end
    end
end
%+ TEST EB
assignin('base', 'w', w);
%-TEST EB
y = icplxdual2D(w,J,Fsf,sf);
