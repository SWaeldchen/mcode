function [mu_sfwi, mu_helm] = sfwi_inversion_reg_grad(U, freqvec, spacing, xyz_order, nohelm, kern_ord)

%mu_sfwi includes all first and second order gradients
%mu_helm neglects all first gradients
%U = mir(U);
% set constants
RHO = 1000;
sz = size(U);
if numel(sz) < 5
    nfreqs = 1;
else
    nfreqs = sz(5);
end
sz_adj = [sz(1)-1, sz(2)-1, sz(3)-1];
N = prod(sz_adj);
if nargin < 5
    nohelm = 1;
    if nargin < 4
        xyz_order = [1 2 3];
    end
end
y_diags = [0 1];
x_diags = [0 sz_adj(1)];
z_diags = [0 sz_adj(1)*sz_adj(2)];
onevec = ones(N,1);
zerovec = zeros(N,1);
%onevec(1) = 0;
%onevec(end) = 0;

% set variable scope
f = [];
K1_sfwi = [];

% create FD gradient functions
if nargin < 6
    kern = [0.5 0 -0.5];
else
    switch kern_ord
        case 1
             kern = [1 -1];
        case 2
            kern = [0.5 0 -0.5];
        case 3
            kern = [1/12 -2/3 0 2/3 -1/12];
    end
end
x_grad_kern = kern  / spacing(1);
y_grad_kern = kern'  / spacing(2);
z_grad_kern = zeros(1,1,numel(kern)); z_grad_kern(:) = kern  / spacing(3);

%xgrad = @(v) convn(v, x_grad_kern, 'same');
%ygrad = @(v) convn(v, y_grad_kern, 'same');
%zgrad = @(v) convn(v, z_grad_kern, 'same');

xgrad_ = @(v) convn(cell2mat(v), x_grad_kern, 'same');
ygrad_ = @(v) convn(cell2mat(v), y_grad_kern, 'same');
zgrad_ = @(v) convn(cell2mat(v), z_grad_kern, 'same');

% create some other functions
om = @(x) 2*pi*x;
spdiag = @(x) spdiags(x(:), 0, N, N);
spdiag_ = @(x) spdiags(vec(cell2mat(x)), 0, N, N);

% stack for n frequencies
for n = 1:nfreqs
    
    [x_derivs, U_x] = gradestim4d(double(U(:,:,:,xyz_order(1),n)), spacing);
    [y_derivs, U_y] = gradestim4d(double(U(:,:,:,xyz_order(2),n)), spacing);
    [z_derivs, U_z] = gradestim4d(double(U(:,:,:,xyz_order(3),n)), spacing);
    
    x_x = x_derivs(:,:,:,1); x_y = x_derivs(:,:,:,2); x_z = x_derivs(:,:,:,3);
    y_x = y_derivs(:,:,:,1); y_y = y_derivs(:,:,:,2); y_z = y_derivs(:,:,:,3);
    z_x = z_derivs(:,:,:,1); z_y = z_derivs(:,:,:,2); z_z = z_derivs(:,:,:,3);
    %x_x = x_derivs(:,:,:,2); x_y = x_derivs(:,:,:,1); x_z = x_derivs(:,:,:,3);
    %y_x = y_derivs(:,:,:,2); y_y = y_derivs(:,:,:,1); y_z = y_derivs(:,:,:,3);
    %z_x = z_derivs(:,:,:,2); z_y = z_derivs(:,:,:,1); z_z = z_derivs(:,:,:,3);

    % INFINITESIMAL STRAIN TENSOR
    %E = {   { 2*x_x         }  {(x_y + y_x)}  {(x_z + z_x)}    ;   ...
    %        {(y_x + x_y)}  { 2*y_y         }  {(y_z + z_y)}    ;   ...
    %        {(z_x + x_z)}  {(z_y + y_z)}  {2*z_z          }     };
    
    E = {   { x_x         }  {(x_y + y_x)/2}  {(x_z + z_x)/2}    ;   ...
            {(y_x + x_y)/2}  { y_y         }  {(y_z + z_y)/2}    ;   ...
            {(z_x + x_z)/2}  {(z_y + y_z)/2}  {z_z          }     };
                 
    % SFWI inversion: [ DIVGRAD_E E ]
    K1_sfwi_n = [ spdiag_(E{1,1})  spdiag_(E{1,2})  spdiag_(E{1,3}); ...
                  spdiag_(E{2,1})  spdiag_(E{2,2})  spdiag_(E{2,3}); ...
                  spdiag_(E{3,1})  spdiag_(E{3,2})  spdiag_(E{3,3})  ];
        
    K1_sfwi = cat(1, K1_sfwi, K1_sfwi_n);
    
    f = cat(1, f, -RHO*om(freqvec(n)).^2.*[U_x(:); U_y(:); U_z(:)]);
end

% SFWI matrix K2 = [I; NablaX; NablaY; NablaZ]

K2_sfwi = [  spdiags([-onevec onevec]/spacing(1), x_diags, N, N); ...
             spdiags([-onevec onevec]/spacing(2), y_diags, N, N); ...
             spdiags([-onevec onevec]/spacing(3), z_diags, N, N); ];

K_sfwi = K1_sfwi*K2_sfwi;

% Ku = f . LSQR method is faster and less memory intensive than
% backslash. User should get convergence before 1000.
%u_sfwi = K_sfwi \ f;
%u_sfwi = lsqr(K_sfwi, f, 1e-15, 100000);
u_sfwi = lsqr(K_sfwi, f, 1e-15, 20000);
%mu_sfwi = mircrop(reshape(u_sfwi, [sz(1) sz(2) sz(3)]));
mu_sfwi = reshape(u_sfwi, [sz_adj(1) sz_adj(2) sz_adj(3)]);
end
