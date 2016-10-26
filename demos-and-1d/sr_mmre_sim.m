function sr_mmre_sim(spike_int, sr, interp_meth, base_k, T)
% Analytic simulation of MR Elastography
% super-resolution interface detection
%
% (c) Eric Barnhill 2016, BSD License.
%
% DESCRIPTION: 
%
% This simulation program is intended to enable the exploration of 
% MDEV-based super-resolution MR Elastography under realistic conditions.
%
% The simulation first generates a 1D collection of complex wave fields 
% across a narrow band of wavenumbers. The code assumes unit-length
% stiffness and unit wave amplitude on a unit-length grid. 
%
% To simulate within-tissue heterogeneities, the underlying 'stiffness' is 
% slowly varied across the image by adding white-noise shifts to the
% instaneous phase gradient at each sample.
%
% To simulate interfaces, delta spikes in phase are added to the slowly
% varying stiffness with either a spacing specified by the user, or
% randomly. The user can specify a specific number of spikes, 0 for random
% spikes, or -1 for no spikes.
%
% Uses can also vary the base wavelength, method of interpolation
% (linear or wavelet) and Super Res level.
%
% Please note that this is _not_ intended as a best-case demo software
% but rather allows interested researchers to explore the range, potential
% and limitations of MDEV based Super Res-MMRE. Spikes far apart will be properly
% resolved by all methods and spikes close together, or very high levels
% Super Res, will be aliased by all methods. In between these extremes the 
% super-resolution will be apparent.
%
% USAGE:
%
% sr_mmre_sim(spike_int, sr, interp_meth, base_k)
%
% INPUTS:
%
% spike_int: Distance between spikes. 
% Set the spacing between delta spikes, 0 for random spikes, or -1 for 
% no spikes. The smaller the spacing, the more the aliasing.
%
% sr: Level of super-resolution. At present this must be an 
% integer to facilitate interpolation.
%
% interp_meth: Choice of interpolation method. User can choose from 
% 1 (linear) or 2 (dual-tree wavelet).
%
% base_k: Wavenumber of lowest base frequency across the 128 tap sample.
% When set too high, downsampled waves will be lost. When set too low,
% the Laplacian falls very close to zero and the simulation becomes
% numerically unstable.
% Default: 4
%
%% Set defaults if necessary
if (nargin < 5)
	T = 0.1;
	if (nargin < 4)
		base_k = 2;
		if (nargin < 3) 
		    interp_meth = 1;
		    if (nargin < 2)
		        sr = 4;
		        if (nargin < 1)
		            spike_int = 0;
		        end
		    end
		end
	end
end
%% Validate arguments
if sr ~= round(sr)
    display('Error. Super factor must be integer.');
    return
end
%{
if base_k > 8
    display('Error. Base k must be under 8. Higher values will alias the shear wave in the downsampling.');
    return
end
%}
if base_k < 1
    display('Error. Base k must be at least 1 for numerical stability.');
    return
end
if spike_int > 127
    display('Error. Spike interval must be within 128 tap simulation size.');
    return
end

%% Some constants. These can be edited but may not produce a stable result

gauss_sigma = .01;
spike_phase_shift = base_k*pi/2;
%spike_phase_shift = pi;
spike_randn_cutoff = 2;
bandwidth_coeffs = {1,1.1,1.2,1.3};
laplacian = [1; -2; 1];
figuretally = 0;
disrupted_r = 1;

%% Generate elasticity fields

% Generate base waves
x = repmat({zeros(128,1)}, [numel(bandwidth_coeffs) 1]);
increment = cell(numel(bandwidth_coeffs), 1);
base_wavelength = 128/(base_k);
for n = 1:numel(bandwidth_coeffs)
    increment{n} = 2*pi / (base_wavelength) * bandwidth_coeffs{n};
end
% Add slow variation and spikes
first_spike = 0;
for n = 2:128;
    h = 1; % to set h scope
    r = 1;
    if spike_int >= 0 % negative numbers produce no spikes
        if spike_int == 0  % case random spikes
            if abs(randn(1)) > spike_randn_cutoff % if random spike
                h = spike_phase_shift;
                r = disrupted_r;
                if first_spike == 0 && n > 20
                    first_spike = n;
                end
            else % if no random spike
                 h = (1 - gauss_sigma) + gauss_sigma*randn; 
            end
        elseif mod(n, spike_int) == 0 % case specified spike intervals
           h = spike_phase_shift;
           r = disrupted_r;
        else % if no spike at this point, stochastically vary
       h = (1 - gauss_sigma) + gauss_sigma*randn; 
        end
    else % if no spikes at all, stochastically vary
       h = (1 - gauss_sigma) + gauss_sigma*randn; 
    end
    for p = 1:numel(x) % now shift the phase 
        prev = x{p}(n-1);
        [t, ~] = cart2pol(real(prev), imag(prev));
        [a, b] = pol2cart(t+increment{p}*h, r);
        x{p}(n) = a + 1i*b;
    end
end

assignin('base', 'x1', x{1})
%% Set some display parameters

% Downsampling plus deriatives will create substantial
% boundary conditions when upsampled. Eliminate for better comparison.
ind1 = 6*sr; 
ind2 = 128-ind1;
% Params for focus on spike.
ind1_d = round(ind1/sr) ;
ind2_d = round(ind2/sr) +1;
if spike_int > 0
    ind1_f = round(ind2/2);
    ind2_f = ind1_f + 2*spike_int;
    ind1_d_f = round(ind2/(2*sr));
    ind2_d_f = ind1_d_f + 2*spike_int/sr;
elseif first_spike > 0;
    ind1_f = first_spike - 16;
    ind2_f = first_spike + 16;
    ind1_d_f = round(ind1_f/sr);
    ind2_d_f = round(ind2_f/sr);
else
    ind1_f = round(ind2/2);
    ind2_f = ind1_f + 16;
    ind1_d_f = round(ind2/(2*sr));
    ind2_d_f = ind1_d_f + 32/sr;
end
x_ds = cell(numel(x),1);

%% Downsample
% Throw out voxels, creating aliased data
for n = 1:numel(x)
    x_ds{n} = x{n}(1:sr:end);
end

assignin('base', 'xds1', x_ds{1})


%% OVERALL AND SPIKE FOCUSED WAVE FIELD
figuretally = figuretally + 1;
figure(figuretally);
set(gcf, 'Color', 'w');
set(gcf, 'Position', [1300 1300 1600 800]);
set(gca, 'Position', [.05 .05 0.9 0.9]);
for n = 1 % top row has titles
    subplot(numel(x), 4, (n-1)*4+1); complexPlot(x{n},'Complex Wavefield, Ground Truth',0,1); xlim([ind1 ind2]);
    subplot(numel(x), 4, (n-1)*4+2); complexPlot(x_ds{n},'Complex Wavefield, Scan Res',0,1); xlim([ind1_d ind2_d]);
    subplot(numel(x), 4, (n-1)*4+3); complexPlot(x{n},'Spike Focus, Ground Truth',0,1); xlim([ind1_f ind2_f]);
    subplot(numel(x), 4, (n-1)*4+4); complexPlot(x_ds{n},'Spike Focus, Scan Res',0,1); xlim([ind1_d_f ind2_d_f]);
end
for n = 2:numel(x)
    subplot(numel(x), 4, (n-1)*4+1); complexPlot(x{n},'',0,1); xlim([ind1 ind2]);
    subplot(numel(x), 4, (n-1)*4+2); complexPlot(x_ds{n},'',0,1); xlim([ind1_d ind2_d]);
    subplot(numel(x), 4, (n-1)*4+3); complexPlot(x{n},'',0,1); xlim([ind1_f ind2_f]);
    subplot(numel(x), 4, (n-1)*4+4); complexPlot(x_ds{n},'',0,1); xlim([ind1_d_f ind2_d_f]);
end

%% get SR

x_sr = cell(numel(x), 1);
guides = cell(numel(x), 1);

display('SR')

figuretally = figuretally + 1;
figure(figuretally);
set(gcf, 'Position', [1200 1200 1600 800]);
set(gca, 'Position', [.05 .05 0.95 0.95]);

  	gi = com.ericbarnhill.esp.GuidedInterpolator();

for n = 1:numel(x)
	display(['------ NUMBER ---- ', num2str(n)]);
    [x_sr{n}, guidance_image, guides{n}] = wavelet_guided_interp_java(x_ds{n}, sr, T);
		
	subplot(numel(x),1, n); plot(guidance_image);
    m = median(guidance_image);
	guide_points = find(guides{n}>0);
    hold on; scatter(guide_points, repmat(m, [1 numel(guide_points)]), 'r'); hold off;
    xlim([ind1_d ind2_d]);
	
end

assignin('base', 'guides', guides);

%% Take derivatives
x_lap = cell(numel(x), 1);
x_ds_lap = cell(numel(x), 1);
x_sr_pre_lap = cell(numel(x), 1);
x_sr_post_lap = cell(numel(x), 1);
%figure(2); complexPlot(x_ds{1});
%figure(3); complexPlot(wavelet_guided_interp_1d(x_ds{1}, sr, T));
for n = 1:numel(x)
	%figure(2); complexPlot(x_ds{n});
	%figure(3); complexPlot(spline_interp(x_ds{n}, sr));
	pause(1)
    x_lap{n} = conv(x{n}, laplacian, 'same');
    x_ds_lap{n} = conv(x_ds{n}, laplacian / (sr.^2) , 'same');
	%x_sr_pre_lap{n} = lap_adapt_1d(x_sr{n}, guides{n}*2);
    x_sr_pre_lap{n} = conv(x_sr{n}, laplacian, 'same'); 
    %x_sr_pre_lap{n} = conv(spline_interp(x_ds{n}, sr), laplacian, 'same'); 
	%x_sr_post_lap{n} = wavelet_guided_interp_java(conv(x_ds{n}, laplacian / (sr.^2), 'same'), sr, T); 
	x_sr_post_lap{n} = spline_interp(conv(x_ds{n}, laplacian / (sr.^2), 'same'), sr); 
    %x_sr_post_lap{n} = polar_interp(conv(x_ds{n}, laplacian / (sr.^2), 'same'), sr, interp_meth, 0.02, 2); 
end


%% OVERALL AND SPIKE FOCUSED SR WAVE FIELD
figuretally = figuretally + 1;
figure(figuretally);
set(gcf, 'Color', 'w');
set(gcf, 'Position', [1300 1300 1600 800]);
set(gca, 'Position', [.05 .05 0.9 0.9]);
for n = 1 % top row has titles
    subplot(numel(x), 2, (n-1)*2+1); complexPlot(x_sr{n},'SR Wavefield',0,1); xlim([ind1 ind2]);
    subplot(numel(x), 2, (n-1)*2+2); complexPlot(lap(x_sr{n}),'SR Laplacians',0,1); xlim([ind1 ind2]);
end
for n = 2:numel(x)
    subplot(numel(x), 2, (n-1)*2+1); complexPlot(x_sr{n},'',0,1); xlim([ind1 ind2]); 
    subplot(numel(x), 2, (n-1)*2+2); complexPlot(x_sr_pre_lap{n},'pre lap',0,1); xlim([ind1 ind2]);
end

%{
% OVERALL LAPLACIAN FIELD
figuretally = figuretally + 1;
figure(figuretally);
set(gcf, 'Color', 'w');
for n = 1 % top row has titles
    subplot(numel(x), 3, (n-1)*3+1); complexPlot(x_lap{n}); xlim([ind1 ind2]); title('Complex Laplacian Field, Ground Truth');
    subplot(numel(x), 3, (n-1)*3+2); complexPlot(x_down_lap{n}); xlim([ind1_d ind2_d]); title('Complex Laplacian Field, Scan Res');
    subplot(numel(x), 3, (n-1)*3+3); complexPlot(x_rs_lap{n}); xlim([ind1 ind2]); title('Complex Laplacian Field, Interpolated');
end
for n = 2:numel(x)
    subplot(numel(x), 3, (n-1)*3+1); complexPlot(x_lap{n}); xlim([ind1 ind2]);
    subplot(numel(x), 3, (n-1)*3+2); complexPlot(x_down_lap{n}); xlim([ind1_d ind2_d]);
    subplot(numel(x), 3, (n-1)*3+3); complexPlot(x_rs_lap{n}); xlim([ind1 ind2]);
end
%}

%{
% LAPLACIAN SPIKE FOCUS
figuretally = figuretally + 1;
figure(figuretally);
set(gcf, 'Color', 'w');
for n = 1 % top row has titles
    subplot(numel(x), 3, (n-1)*3+1); complexPlot(x_lap{n}); xlim([ind1_f ind2_f]); title('Spike Focus, Ground Truth');
    subplot(numel(x), 3, (n-1)*3+2); complexPlot(x_ds_lap{n}); xlim([ind1_d_f ind2_d_f]); title('Spike Focus, Scan Res');
    subplot(numel(x), 3, (n-1)*3+3); complexPlot(x_sr_pre_lap{n}); xlim([ind1_f ind2_f]); title('Spike Focus, Interpolated');
end
for n = 2:numel(x)
    subplot(numel(x), 3, (n-1)*3+1); complexPlot(x_lap{n}); xlim([ind1_f ind2_f]);
    subplot(numel(x), 3, (n-1)*3+2); complexPlot(x_ds_lap{n}); xlim([ind1_d_f ind2_d_f]);xlim([ind1_d_f ind2_d_f]);
    subplot(numel(x), 3, (n-1)*3+3); complexPlot(x_sr_pre_lap{n}); xlim([ind1_f ind2_f]);
end
%}

%% Interpolate Downsampled Displacements

%% Inversion Numerator and Denominator
x_orig_num = [];
x_orig_denom = [];
x_ds_num = [];
x_ds_denom = [];
x_sr_pre_num = [];
x_sr_pre_denom = [];
x_sr_post_num = [];
x_sr_post_denom = [];
x_gt_comps = [];


for n = 1:numel(x)
    x_gt_comps = cat(2, x_gt_comps, bandwidth_coeffs{n} .* (2*pi) ./ gradient(unwrap(angle(x{n}))) );
    x_orig_num = cat(2, x_orig_num, bandwidth_coeffs{n}.^2 * abs(x{n}));
    x_orig_denom = cat(2, x_orig_denom, abs(x_lap{n}));
    x_ds_num = cat(2, x_ds_num, bandwidth_coeffs{n}.^2 *abs(x_ds{n}));
    x_ds_denom = cat(2, x_ds_denom, abs(x_ds_lap{n}));
    x_sr_pre_num = cat(2, x_sr_pre_num, bandwidth_coeffs{n}.^2 * abs(x_sr{n}));
    x_sr_pre_denom = cat(2, x_sr_pre_denom, abs(x_sr_pre_lap{n}));
    x_sr_post_num = cat(2, x_sr_post_num, bandwidth_coeffs{n}.^2 * abs(spline_interp(x_ds{n},4)));
    x_sr_post_denom = cat(2, x_sr_post_denom, lap(abs(spline_interp(x_ds{n},4))));
end

%% Inversion Divide
inv_comps_orig = x_orig_num ./ x_orig_denom;
inv_orig = sum(x_orig_num, 2) ./ sum(x_orig_denom, 2);
inv_comps_down = x_ds_num ./ x_ds_denom;
inv_down = sum(x_ds_num, 2) ./ sum(x_ds_denom, 2);
%inv_comps_naive = polar_interp(inv_comps_down, sr, interp_meth);
%inv_naive = polar_interp(inv_down, sr, interp_meth);
inv_comps_naive = spline_interp(inv_comps_down, sr);
inv_naive = spline_interp(inv_down, sr);
inv_comps_sr_pre = x_sr_pre_num ./ x_sr_pre_denom;
inv_sr_pre = sum(x_sr_pre_num, 2) ./ sum(x_sr_pre_denom, 2);
size(x_sr_pre_num)
size(x_sr_post_num)
size(x_sr_post_denom)
inv_comps_sr_post = x_sr_post_num./ x_sr_post_denom;
inv_sr_post = sum(x_sr_post_num, 2) ./ sum(x_sr_post_denom, 2);
x_gt = sum(x_gt_comps, 2) / numel(x);

%{
% ADDITIONAL FILTERING
% to apply butterworth
[b, a] = butter(4, 1/sr);
%inv_comps_sr = filter(b, a, inv_comps_sr);
%inv_sr = filter(b, a, inv_sr);


%cap spikes
med = median(inv_comps_sr(~isnan(inv_comps_sr)));
cap_high = med*1.5;
cap_low = med*0.5;
% can be used if phase discontinuities are increased. method is still
% equally accurate, but spikes get very high
inv_super(inv_super>cap_high) = cap_high;
inv_super(inv_super<cap_low) = cap_low;
%}

comps = {x_gt_comps, inv_comps_orig, inv_comps_down, inv_comps_naive, inv_comps_sr_pre, inv_comps_sr_post};
inversions = {x_gt, inv_orig, inv_down, inv_naive, inv_sr_pre, inv_sr_post};

assignin('base', 'x_ds', x_ds);
assignin('base', 'x_orig', x);
%% Display elastograms

figuretally = figuretally + 1;
figure(figuretally);
ylims = ([0 200]);
set(gcf, 'Color', 'w');
set(gcf, 'Position', [1300 1300 1600 800]);
set(gca, 'Position', [.05 .05 0.9 0.9]);

for n = 1:numel(inversions)
    subplot(numel(inversions), 2, (n-1)*2+1); plot(comps{n}); 
    if (n ~= 3) 
        xlim([ind1 ind2]);
    else 
        xlim([ind1_d ind2_d]);
    end
    switch n
        case 1
            title('$\mathbf{\mu}_{gt}(\omega)$', 'Interpreter', 'LaTeX', 'FontSize', 18);
        case 2
            title('$\mathbf{\mu}_{or}(\omega)$', 'Interpreter', 'LaTeX', 'FontSize', 18);
        case 3
            title('$\mathbf{\mu}_{ds}(\omega)$', 'Interpreter', 'LaTeX', 'FontSize', 18);
        case 4
            title('$\mathbf{\mu}_{naive}(\omega)$', 'Interpreter', 'LaTeX', 'FontSize', 18);
        case 5
            title('$\mathbf{\mu}_{pre}(\omega)$', 'Interpreter', 'LaTeX', 'FontSize', 18);
        case 6
            title('$\mathbf{\mu}_{post}(\omega)$', 'Interpreter', 'LaTeX', 'FontSize', 18)    
    end
    subplot(numel(inversions), 2, (n-1)*2+2); plot(inversions{n}); ylim(ylims);
    if (n ~= 3) 
        xlim([ind1 ind2]);
    else 
        xlim([ind1_d ind2_d]);
    end
    switch n
        case 1
            title('$\mathbf{\mu}_{gt}$', 'Interpreter', 'LaTeX', 'FontSize', 18);
        case 2
            title('$\mathbf{\mu}_{or}$', 'Interpreter', 'LaTeX', 'FontSize', 18);
        case 3
            title('$\mathbf{\mu}_{ds}$', 'Interpreter', 'LaTeX', 'FontSize', 18);
        case 4
            title('$\mathbf{\mu}_{naive}$', 'Interpreter', 'LaTeX', 'FontSize', 18);
        case 5
            title('$\mathbf{\mu}_{pre}$', 'Interpreter', 'LaTeX', 'FontSize', 18);
        case 6
            title('$\mathbf{\mu}_{post}$', 'Interpreter', 'LaTeX', 'FontSize', 18);
    end
end

figuretally = figuretally + 1;
xsr = x_sr{1};
xsrlap = x_sr_pre_lap{1};
res = abs(xsr) ./ abs(xsrlap);

sniprange = 31:43;
plotRange = [(sniprange(1)/2)-0.5:(1/sr):(sniprange(end)/2)-0.5];
snip = xsr(sniprange); lsnip = xsrlap(sniprange); rsnip = res(sniprange);
figure(figuretally); 
set(gcf, 'Position', [300 300 2400 800]);
subplot(1,3,1); 
complexPlot(snip,'',0,1,plotRange); 
subplot(1, 3, 2); complexPlot(lsnip, '',0,1,plotRange); 
subplot(1, 3, 3); complexPlot(rsnip, '', 0,1,plotRange);

assignin('base', 'xsr', xsr);
assignin('base', 'xsrlap', xsrlap); 
assignin('base', 'xds', x_ds{1});
assignin('base', 'res', res);
%sr_fig2;
%sr_fig3;
%sr_fig4;
debug = 0; % for working within the sim
