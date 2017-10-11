function mredge_motion_correction_fsl(info)
%
% Part of the MREdge software package
% Created 2016 by Eric Barnhill for Charite Medical University Berlin
% Private usage only. Distribution only by permission of Elastography working
% group.
%
%
% USAGE:
%
% This function will perform motion correction on an acquisition.
% Requires a typical Debian or Linux installation of FSL 5.0+
%
% INPUTS:
%
% info - an acquisition info structure created with make_acquisition_info
% prefs - a preference file structure created with mredge_prefs
%
% OUTPUTS:
%
% none
%	
    tic
    disp('MREdge Motion Correction with FSL');
    mredge_pm2ri(info);
    for subdir = info.ds.subdirs_comps_files
        % make a copy, motion correct with copy in, original out
        subdir_temp = [mredge_remove_nifti_extension(subdir), '_temp', NIF_EXT];
        copyfile([info.ds.list(info.ds.enum.magnitude), subdir], [info.ds.list(info.ds.enum.magnitude), subdir_temp]);
        mcflirt_command = ['fsl5.0-mcflirt -in ', subdir_temp, ' -out ', subdir,' -smooth 0.5 -mats -stats' ];
        system(mcflirt_command);
        delete(subdir_temp);
        subdir_mat = [mredge_remove_nifti_extension(subdir), '.mat'];
        apply_moco(info.ds.list(info.ds.enum.real), subdir, subdir_mat, info);
        apply_moco(info.ds.list(info.ds.enum.imaginary), subdir, subdir_mat, info);
    end
    mredge_ri2pm(info);
    toc
end

function apply_moco(path, path_mag_mat, info)
    path_split_list = mredge_split_4d(path);
    for t = 1:info.time_steps
      	split_image_temp = [fullfile(subdir, path_component), '/vol000', num2str(t-1), '.nii.gz'];
      	split_image_temp_trans = [fullfile(subdir, path_component), '/vol000', num2str(t-1), '_trans.nii.gz'];
      	trans_matrix_temp = [fullfile(path_mag_mat), '/MAT_000', num2str(t-1)];
	  	flirt_command = ['fsl5.0-flirt -in ',split_image_temp,' -ref ',split_image_temp, ' -out ',split_image_temp_trans,' -init ', trans_matrix_temp,' -applyxfm'];
      	system(flirt_command);
      	splitfiles = [splitfiles, ' ', split_image_temp_trans]; %#ok<*AGROW>
    end
	merge_command = ['fsl5.0-fslmerge -t ', path_re, ' ', splitfiles];
    system(merge_command);
end
