function D = expm1(A)
%EXPM1  Matrix exponential via Pade approximation.
%   changed by ingolf to allow sparse matrix application
%   E = EXPM1(A) is an M-file implementation of the built-in
%   algorithm used by MATLAB for the matrix exponential.
%   See Golub and Van Loan, Matrix Computations, Algorithm 11.3-1.
%
%   See also EXPM, EXPM2, EXPM3.

%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision: 5.3 $  $Date: 1997/11/21 23:38:25 $

% Scale A by power of 2 so that its norm is < 1/2 .
[f,e] = log2(norm(A,'inf'));
s = max(0,e+1);
A = A/2^s;

% Pade approximation for exp(A)
X = A; 
c = 1/2;
dim=size(A);
E = sparse(1:min(dim),1:min(dim),1,dim(1),dim(2)) + c*A;

D = sparse(1:min(dim),1:min(dim),1,dim(1),dim(2)) - c*A;

q = 6;
p = 1;

for k = 2:q
   c = c * (q-k+1) / (k*(2*q-k+1));
   X = A*X;
   cX = c*X;
   E = E + cX;
   if p
     D = D + cX;
   else
     D = D - cX;
   end
   p = ~p;
end
%a=find(abs(E) < 0.1);
%E(a)=0;
%E = D\E;

% Undo scaling by repeated squaring
%for k=1:s, E = E*E; end
