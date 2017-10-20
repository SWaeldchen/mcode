%% function mredge_curl(info, prefs);
%
% Part of the MREdge software package
% Created 2016 by Eric Barnhill for Charite Medical University Berlin
% Private usage only. Distribution only by permission of Elastography working
% group.
%
%
% USAGE:
%
%   Helmholt-Hodge decomposition of the vector fields, retaining curl
%   component
%
% INPUTS:
%
%   info - MREdge acquisition info structure generated with mredge_acquisition_info
%   prefs - MREdge preferences structure generated with mredge_prefs
%
% OUTPUTS:
%
%   none

function mredge_curl(info, prefs)

	[FT_DIRS, RESID_DIRS] =set_dirs(info, prefs);
	NIF_EXT = '.nii.gz';
    for n = 1:numel(RESID_DIRS)
        if ~exist(RESID_DIRS{n}, 'dir')
            mkdir(RESID_DIRS{n});
        end
    end
    for d = 1:numel(FT_DIRS);
        for f = info.driving_frequencies
            display([num2str(f), ' Hz']);
            % make use of component order in prefs
            order_vec = get_order_vec(prefs);
            wavefield_vol = cell(3,1);
            components = cell(3,1);
            for c = 1:3
                wavefield_path = fullfile(FT_DIRS{d}, num2str(f), num2str(order_vec(c)), mredge_filename(f, order_vec(c), NIF_EXT));
                wavefield_vol{c} = load_untouch_nii(wavefield_path);
                components{order_vec(c)} = wavefield_vol{c}.img;
            end
            resid_vol = wavefield_vol;
            if strcmp(prefs.curl_strategy, 'lsqr') == 1
                components = mredge_hhd_lsqr(components, prefs);
            elseif strcmp(prefs.curl_strategy, 'fd') == 1
                [components{1}, components{2}, components{3}] = curl(components{1}, components{2}, components{3});
            elseif strcmp(prefs.curl_strategy, 'hipass') == 1
                for n = 1:3
                    components{n} = hipass_butter_3d(prefs.highpass_settings.order, prefs.highpass_settings.cutoff, components{n});
                end
            end
            for c = 1:3
                wavefield_path = fullfile(FT_DIRS{d}, num2str(f), num2str(order_vec(c)), mredge_filename(f, order_vec(c), NIF_EXT));
                wavefield_vol{c}.img = components{order_vec(c)};
				save_untouch_nii(wavefield_vol{c}, wavefield_path);
                resid_dir = fullfile(RESID_DIRS{d}, num2str(f), num2str(c));
                if ~exist(resid_dir, 'dir')
                    mkdir(resid_dir);
                end
                resid_path = fullfile(resid_dir, mredge_filename(f, c, NIF_EXT)); %#ok<PFBNS>
                resid_vol{c}.img = resid_vol{c}.img - wavefield_vol{c}.img;
                save_untouch_nii(resid_vol{c}, resid_path);
            end
        end
    end
    

end

function [FT_DIRS, RESID_DIRS] = set_dirs(info, prefs)
	if strcmp(prefs.phase_unwrap, 'gradient') == 1;
		FT_X = mredge_analysis_path(info,prefs,'FT_X');
		FT_Y = mredge_analysis_path(info,prefs,'FT_Y');
		FT_DIRS = cell(2,1);
		FT_DIRS{1} = FT_X;
		FT_DIRS{2} = FT_Y;
		RESID_X = mredge_analysis_path(info,prefs,'CURL_RESID_X');
		RESID_Y = mredge_analysis_path(info,prefs,'CURL_RESID_Y');
		RESID_DIRS = cell(2,1);
		RESID_DIRS{1} = RESID_X;
		RESID_DIRS{2} = RESID_Y;
	else
		FT_SUB = mredge_analysis_path(info,prefs,'FT');
		FT_DIRS = cell(1,1);
		FT_DIRS{1} = FT_SUB;
		RESID_SUB = mredge_analysis_path(info,prefs,'CURL_RESID');
		RESID_DIRS = cell(1,1);
		RESID_DIRS{1} = RESID_SUB;
	end
end

function order_vec = get_order_vec(prefs)
    order_vec = zeros(3,1);
    if strcmp(prefs.component_order(1), 'x') == 1
        order_vec(1) = 1;
    elseif strcmp(prefs(1), 'y') == 1
        order_vec(1) = 2;
    else
        order_vec(1) = 3;
    end
    if strcmp(prefs.component_order(2), 'x') == 1
        order_vec(2) = 1;
    elseif strcmp(prefs.component_order(2), 'y') == 1
        order_vec(2) = 2;
    else
        order_vec(2) = 3;
    end
    if strcmp(prefs.component_order(3), 'x') == 1
        order_vec(3) = 1;
    elseif strcmp(prefs.component_order(3), 'y') == 1
        order_vec(3) = 2;
    else
        order_vec(3) = 3;
    end
end

