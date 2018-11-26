function [ diffOp ] = waveOp_part_mu(mu, D, gridSize)
%WAVEOP_U Summary of this function goes here
%   Detailed explanation goes here

vec1 = mu(2:end-1) + (mu(3:end)-mu(1:end-2))/4;
vec2 = - 2*mu(2:end-1);
vec3 = mu(2:end-1) - (mu(3:end)-mu(1:end-2))/4;

diags = [[vec1;0;0],[-D;vec2;-D], [0;0;vec3]];
diffOp = spdiags(diags, [-1,0,1], gridSize, gridSize);

end
