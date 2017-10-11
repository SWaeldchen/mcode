%% function mredge_ri2pm(info, frequency, component)
%
% Part of the MREdge software package
% Created 2016 at Charite Medical University Berlin
% Private usage only. Distribution only by permission of Elastography working
% group.
%
% USAGE:
%
% Converts phase and magnitude .nii files to real and imaginary .nii
% and sends them to path_out/
%
%
% INPUTS:
%
% dir - location of the time series
%
% OUTPUTS:
%
% none

function mredge_ri2pm(info)
    for subdir = info.ds.subdirs_comps_files
        % load re and im
        re = load_untouch_nii_eb(cell2str(fullfile(info.ds.list(info.ds.enum.real), subdir)));
        im = load_untouch_nii_eb(cell2str(fullfile(info.ds.list(info.ds.enum.imaginary), subdir)));
        % create placeholder p and m
        p = re;
        m = im;
        % calculate
        cplx = re.img + 1i*im.img;
        p.img = angle(cplx);
        m.img = abs(cplx);  
        % write p and m
        save_untouch_nii_eb(p, cell2str(fullfile(info.ds.list(info.ds.enum.phase), subdir)));
        save_untouch_nii_eb(m, cell2str(fullfile(info.ds.list(info.ds.enum.magnitude), subdir)));
    end
end
