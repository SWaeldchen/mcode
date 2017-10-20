function norm_estwrite_epidico2mni(DATA_DIR,TPMdir,tesla)
disp('#### norm_estwrite_epidico2mni ####');
cd(DATA_DIR);

if strcmp(tesla,'7T')
    voxresolution = [1 1 1];
end
if strcmp(tesla,'3T')
    voxresolution = [2 2 2];
end

normdata{1} = 'ABSG_dico_nc.nii';
normdata{2} = 'ABSG_dico.nii';
normdata{3} = 'ABSG_modico_nc.nii';
normdata{4} = 'ABSG_modico.nii';
normdata{5} = 'PHI_dico_nc.nii';
normdata{6} = 'PHI_dico.nii';
normdata{7} = 'PHI_modico_nc.nii';
normdata{8} = 'PHI_modico.nii';
normdata{9} = 'MAGm_dico.nii';
normdata{10} = 'MAGm_modico.nii';
normdata{11} = 'wx_Twarp_dico.nii';
normdata{12} = 'wy_Twarp_dico.nii';
normdata{13} = 'wz_Twarp_dico.nii';
normdata{14} = 'iy_MAGf_dico_segepi2mprage.nii';
normdata{15} = 'my_field.nii';

if ~exist(fullfile(DATA_DIR,'y_epi2orig2mni.nii'),'file');
    cd(DATA_DIR);
    disp('...est_normalise...');
    clear matlabbatch
    spm('defaults','fmri');
    spm_jobman('initcfg');
    matlabbatch{1}.spm.spatial.normalise.est.subj.vol = {'MAGf_dico.nii'};
    matlabbatch{1}.spm.spatial.normalise.est.eoptions.biasreg = 0.0001;
    matlabbatch{1}.spm.spatial.normalise.est.eoptions.biasfwhm = 60;
    matlabbatch{1}.spm.spatial.normalise.est.eoptions.tpm = {fullfile(TPMdir,'TPM.nii')};
    matlabbatch{1}.spm.spatial.normalise.est.eoptions.affreg = 'mni';
    matlabbatch{1}.spm.spatial.normalise.est.eoptions.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{1}.spm.spatial.normalise.est.eoptions.fwhm = 0;
    matlabbatch{1}.spm.spatial.normalise.est.eoptions.samp = 3;
    spm_jobman('run',matlabbatch);
    
    !mv y_MAGf_dico.nii y_epi2dico2mni.nii
    
end

for knormdata = 1:length(normdata)
    
    if ~exist(fullfile(DATA_DIR,['w' normdata{knormdata}]),'file');
        disp(['...write_normalise... ' normdata{knormdata} ]);
        
        clear matlabbatch
        spm('defaults','fmri');
        spm_jobman('initcfg');
        matlabbatch{1}.spm.spatial.normalise.write.subj.def = {fullfile(DATA_DIR,'y_epidico2mni.nii')};
        matlabbatch{1}.spm.spatial.normalise.write.subj.resample = {fullfile(DATA_DIR,normdata{knormdata})};
        matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
            78 76 85];
        matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = voxresolution;
        matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
        spm_jobman('run',matlabbatch);
    end    
    
end

end