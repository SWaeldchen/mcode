function mredge_organize_acquisition(info, prefs)
% Creates nested folder structure for NIfTI files
%
% INPUTS:
%
%   info - an acquisition info structure created by make_acquisition_info
%
% OUTPUTS:
%
%   none
%
% SEE ALSO:
%
%   mredge, mredge_dicom_to_nifti
%
% Part of the MREdge software package
% Created 2016 at Charite Medical University Berlin
% So that we can vouch for results, 
% this code is source-available but not open source.
% Please contact Eric Barnhill at ericbarnhill@protonmail.ch 
% for permission to make modifications.
%
%% process each series
NIF_EXT = getenv('NIFTI_EXTENSION');

for d = 1:numel(prefs.ds.logical)
    if prefs.ds.logical(d) 
        dirpath = fullfile(prefs.ds.list{d});
        if ~exist(dirpath, 'dir')
            mkdir(dirpath);
        end
        series_nums = prefs.ds.series_nums{d};
        for series_num = series_nums
            movefile(fullfile(info.path, [num2str(series_num), NIF_EXT]), dirpath);
        end
    end
end
    
if info.all_freqs_one_series == 1
    mredge_break_into_frequencies(info.phase(1), prefs.ds.list(prefs.ds.enum.phase), info);
    mredge_break_into_frequencies(info.magnitude(1), prefs.ds.list(prefs.ds.enum.magnitude), info);
else
    mredge_rename_by_frequency(prefs.ds.list(prefs.ds.enum.phase), info.phase, info);
    mredge_rename_by_frequency(prefs.ds.list(prefs.ds.enum.magnitude), info.magnitude, info);
end

% convert all NIfTI files to double data type
mredge_phase2double(prefs);
mredge_mag2double(prefs);
delete(fullfile(info.path, '*.nii'));