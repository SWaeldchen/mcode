classdef class_modicoismrm
    methods (Static)
        
        
       function mredata_topup2RAWN(PROJ_DIR,SCRIPT_DIR,Asubject,subjectlist)
            disp('mredata_topup2RAWN...');
            
            for ksub = subjectlist
                disp(['Subnum: ' int2str(ksub)]);
                
                DATA_SUB = fullfile(PROJ_DIR,Asubject(ksub).name);
                RAWN_SUB = fullfile(DATA_SUB,'RAWN');
                
                cd(SCRIPT_DIR);
                disp(SCRIPT_DIR);
                copyfile('topup_param.txt',fullfile(RAWN_SUB,'topup_param.txt'));
                
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function moveima2SCAN_SUB(PROJ_DIR,Asubject,subjectlist)
            disp('moveima2SCAN_SUB...');
            
            for ksub = subjectlist
                disp(['Subnum: ' int2str(ksub)]);
                
                DATA_SUB = fullfile(PROJ_DIR,Asubject(ksub).name);
                SCAN_SUB = fullfile(DATA_SUB,'SCAN');
                if ~exist(SCAN_SUB,'dir'), mkdir(SCAN_SUB), end
                
                if length(dir(SCAN_SUB)) < 3
                    disp('move');
                    cd(DATA_SUB);
                    [s,mess,messid] = movefile('*.ima',SCAN_SUB);
                else
                    disp('already imported');
                   
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        function mredata_plotpic(PROJ_DIR,Asubject,subjectlist)
            disp('importing MRE data...');
            % modicomod, distortion correction y/n
            
            PIC_DIR2 = fullfile(PROJ_DIR,'PICS2');
            mkdir(PIC_DIR2)
            
            for ksub = subjectlist
                disp(['Subnum: ' int2str(ksub) ' ' Asubject(ksub).name]);
                
                DATA_SUB = fullfile(PROJ_DIR,Asubject(ksub).name);
                ANA_SUB = fullfile(DATA_SUB,'ANA');
                RAWN_SUB = fullfile(DATA_SUB,'RAWN');
                
                cd(RAWN_SUB);
                if exist('RL_dico_ma.nii','file')
                    plot2dwaves(spm_read_vols(spm_vol('RL_dico_ma.nii')));
                    saveas(gcf,fullfile(PIC_DIR2,['sub_' int2str(ksub) '_RL_dico_ma.png']));
                    close
                end
                
                if exist('uRL_dico_ma.nii','file')
                    plot2dwaves(spm_read_vols(spm_vol('uRL_dico_ma.nii')));
                    saveas(gcf,fullfile(PIC_DIR2,['sub_' int2str(ksub) '_uRL_dico_ma.png']));
                    close
                end
                
                cd(ANA_SUB);
                
                if exist('MAGf_dico.nii','file')
                    plot2dwaves(spm_read_vols(spm_vol('MAGf_dico.nii')));
                    saveas(gcf,fullfile(PIC_DIR2,['sub_' int2str(ksub) '_MAGf_dico.png']));
                    close
                end
                if exist('MAGf_orig.nii','file')
                    plot2dwaves(spm_read_vols(spm_vol('MAGf_orig.nii')));
                    saveas(gcf,fullfile(PIC_DIR2,['sub_' int2str(ksub) '_MAGf_orig.png']));
                    close
                end
                
                if exist('wMAGf_dico.nii','file')
                    plot2dwaves(spm_read_vols(spm_vol('wMAGf_dico.nii')));
                    saveas(gcf,fullfile(PIC_DIR2,['sub_' int2str(ksub) '_wMAGf_dico.png']));
                    close
                end
                
                if exist('wMAGf_orig.nii','file')
                    plot2dwaves(spm_read_vols(spm_vol('wMAGf_orig.nii')));
                    saveas(gcf,fullfile(PIC_DIR2,['sub_' int2str(ksub) '_wMAGf_orig.png']));
                    close
                end
                
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        


        
        function mpragedata_import(PROJ_DIR,Asubject,subjectlist)
            disp('importing mprage data...');
            
            for ksub = subjectlist
                disp(['Subnum: ' int2str(ksub) ' ' Asubject(ksub).name]);
                DATA_SUB = fullfile(PROJ_DIR,Asubject(ksub).name);
                ANA_SUB = fullfile(DATA_SUB,'ANA');
                SCAN_SUB = fullfile(DATA_SUB,'SCAN');
                
                if ~strcmp(Asubject(ksub).name,'MREPERF-FD_20150513-133126');
                    
                    if ~exist(fullfile(ANA_SUB,'MPRAGE.nii'),'file');
                        ap_spm_import_mprage(SCAN_SUB,ANA_SUB,Asubject(ksub));
                    else
                        %disp('...mprage.nii existed already.');
                    end
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function mredata_import(PROJ_DIR,Asubject,subjectlist,modicomod)
            disp('importing MRE data...');
            % modicomod, distortion correction y/n
            
            for ksub = subjectlist
                disp(['Subnum: ' int2str(ksub) ' ' Asubject(ksub).name]);
                
                DATA_SUB = fullfile(PROJ_DIR,Asubject(ksub).name);
                SCAN_SUB = fullfile(DATA_SUB,'SCAN');
                NII_SUB = fullfile(DATA_SUB,'NII');
                RAWN_SUB = fullfile(DATA_SUB,'RAWN');
                if ~exist(RAWN_SUB,'dir'), mkdir(RAWN_SUB); end
                if ~exist(NII_SUB,'dir'), mkdir(NII_SUB); end
                
                if ~exist(fullfile(RAWN_SUB,'RL_dico_ma.nii'),'file') % ???
                    modico_import_ref(Asubject(ksub),modicomod,SCAN_SUB,RAWN_SUB);
                end
                
                if ~exist(fullfile(NII_SUB,'tmpfirstRL_dyn_ma.nii'),'file') % ???
                    modico_import(Asubject(ksub),modicomod,SCAN_SUB,NII_SUB);
                else
                    % disp('...4D MRE data existed already.')
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function mredata_calc(PROJ_DIR,Asubject,subjectlist,modicomod)
            disp('calc MRE data...');
            % modicomod, distortion correction y/n
            
            for ksub = subjectlist
                disp(['Subnum: ' int2str(ksub) ' ' Asubject(ksub).name]);
                
                SUB_NAME = Asubject(ksub).name;
                
                DATA_SUB = fullfile(PROJ_DIR,SUB_NAME);
                RAWN_SUB = fullfile(DATA_SUB,'RAWN');
                MODICO_SUB = fullfile(DATA_SUB,'MODICO');
                if ~exist(RAWN_SUB,'dir'), mkdir(RAWN_SUB); end
                if ~exist(MODICO_SUB,'dir'), mkdir(MODICO_SUB); end
                
                cd(DATA_SUB);
                
                if ~exist(fullfile(RAWN_SUB,'uRLLR.nii'),'file')
                    !cp NII/* RAWN/
                    cd(RAWN_SUB);
                    !cp ../../topup_param.txt .
                    modico_topup(PROJ_DIR,RAWN_SUB);
                end
                
                if ~exist(fullfile(RAWN_SUB,'rRL_dyn_r_4D.nii'),'file')
                    modico_calc_origmoco(PROJ_DIR,RAWN_SUB,MODICO_SUB,modicomod,SUB_NAME,'research');
                end
                
                if ~exist(fullfile(RAWN_SUB,'urRL_dyn_r_4D.nii'),'file')
                    modico_calc_dicomodico(RAWN_SUB);
                end
                
                if ~exist(fullfile(RAWN_SUB,'uRL_dico_ma.nii'),'file')
                    cd(RAWN_SUB);
                    system('fsl5.0-applytopup --imain=RL_dico_ma --inindex=1 --datain=topup_param.txt --topup=my_topup_results --method=jac --interp=spline --out=uRL_dico_ma');
                    !gunzip -f *gz
                end
                
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function mredata_ri2pm_origmoco(PROJ_DIR,Asubject,subjectlist)
            
            for ksub = subjectlist
                disp(['Subnum: ' int2str(ksub) ' ' Asubject(ksub).name]);
                
                DATA_SUB = fullfile(PROJ_DIR,Asubject(ksub).name);
                RAWN_SUB = fullfile(DATA_SUB,'RAWN');
                ANA_SUB = fullfile(DATA_SUB,'ANA');
                MODICO_SUB = fullfile(DATA_SUB,'MODICO');
                if ~exist(RAWN_SUB,'dir'), mkdir(RAWN_SUB); end
                if ~exist(MODICO_SUB,'dir'), mkdir(MODICO_SUB); end
                if ~exist(ANA_SUB,'dir'), mkdir(ANA_SUB); end
                
                % Convert Re + Im to Ph + Ma and copy to MODICO
                disp('Converting Re + Im images to Ph + Ma...');
                if ~exist(fullfile(MODICO_SUB,'RL_dyn_m_4D.nii'),'file')
                    convert_ri2pm(RAWN_SUB,MODICO_SUB,'RL');
                end
                if ~exist(fullfile(MODICO_SUB,'rRL_dyn_m_4D.nii'),'file')
                    convert_ri2pm(RAWN_SUB,MODICO_SUB,'rRL');
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function mredata_ri2pm_dicomodico(PROJ_DIR,Asubject,subjectlist)
            
            parfor ksub = subjectlist
                disp(['Subnum: ' int2str(ksub) ' ' Asubject(ksub).name]);
                
                DATA_SUB = fullfile(PROJ_DIR,Asubject(ksub).name);
                RAWN_SUB = fullfile(DATA_SUB,'RAWN');
                ANA_SUB = fullfile(DATA_SUB,'ANA');
                MODICO_SUB = fullfile(DATA_SUB,'MODICO');
                if ~exist(RAWN_SUB,'dir'), mkdir(RAWN_SUB); end
                if ~exist(MODICO_SUB,'dir'), mkdir(MODICO_SUB); end
                if ~exist(ANA_SUB,'dir'), mkdir(ANA_SUB); end
                
                % Convert Re + Im to Ph + Ma and copy to MODICO
                disp('Converting Re + Im images to Ph + Ma...');
                if ~exist(fullfile(MODICO_SUB,'uRL_dyn_m_4D.nii'),'file')
                    convert_ri2pm(RAWN_SUB,MODICO_SUB,'uRL');
                end
                if ~exist(fullfile(MODICO_SUB,'urRL_dyn_m_4D.nii'),'file')
                    convert_ri2pm(RAWN_SUB,MODICO_SUB,'urRL');
                end
            end
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function mredata_copyRAWN2ANA(PROJ_DIR,Asubject,subjectlist)
            disp('copyRAWN2ANA...');
            
            parfor ksub = subjectlist
                disp(['Subnum: ' int2str(ksub) ' ' Asubject(ksub).name]);
                
                DATA_SUB = fullfile(PROJ_DIR,Asubject(ksub).name);
                RAWN_SUB = fullfile(DATA_SUB,'RAWN');
                ANA_SUB = fullfile(DATA_SUB,'ANA');
                if ~exist(RAWN_SUB,'dir'), mkdir(RAWN_SUB); end
                if ~exist(ANA_SUB,'dir'), mkdir(ANA_SUB); end
                
                
                cd(DATA_SUB);
                !cp RAWN/my_field.nii ANA/
                !cp RAWN/dmy_field.nii ANA/
                !cp RAWN/RL_dico_ma.nii ANA/MAGf_orig.nii
                !cp RAWN/RL_dico_ma.nii ANA/
                !cp RAWN/uRL_dico_ma.nii ANA/MAGf_dico.nii
                
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function mredata_mdev(PROJ_DIR,Asubject,subjectlist,freqs,pixel_spacing)
            disp('mdev MRE data...');
            
            parfor ksub = subjectlist
                disp(['Subnum: ' int2str(ksub) ' ' Asubject(ksub).name]);
                
                DATA_SUB = fullfile(PROJ_DIR,Asubject(ksub).name);
                RAWN_SUB = fullfile(DATA_SUB,'RAWN');
                ANA_SUB = fullfile(DATA_SUB,'ANA');
                MODICO_SUB = fullfile(DATA_SUB,'MODICO');
                if ~exist(RAWN_SUB,'dir'), mkdir(RAWN_SUB); end
                if ~exist(MODICO_SUB,'dir'), mkdir(MODICO_SUB); end
                if ~exist(ANA_SUB,'dir'), mkdir(ANA_SUB); end
                
                cd(DATA_SUB);
                %                 !cp RAWN/my_field.nii ANA/
                %                 !cp RAWN/dmy_field.nii ANA/
                %                 !cp RAWN/RL_dico_ma.nii ANA/MAGf_orig.nii
                %                 !cp RAWN/RL_dico_ma.nii ANA/
                %                 !cp RAWN/uRL_dico_ma.nii ANA/MAGf_dico.nii
                %system(fullfile(RAWN_SUB,'my_field.nii'),fullfile(ANA_SUB,'my_field.nii'));
                
                if ~exist(fullfile(ANA_SUB,'MAGm_orig.nii'),'file');
                    dataset = 'RL';
                    modico_mdev(MODICO_SUB,ANA_SUB,freqs,pixel_spacing,dataset);
                end
                if ~exist(fullfile(ANA_SUB,'MAGm_moco.nii'),'file');
                    dataset = 'rRL';
                    modico_mdev(MODICO_SUB,ANA_SUB,freqs,pixel_spacing,dataset);
                end
                if ~exist(fullfile(ANA_SUB,'MAGm_modico.nii'),'file');
                    dataset = 'urRL';
                    modico_mdev(MODICO_SUB,ANA_SUB,freqs,pixel_spacing,dataset);
                end
                if ~exist(fullfile(ANA_SUB,'MAGm_dico.nii'),'file');
                    dataset = 'uRL';
                    modico_mdev(MODICO_SUB,ANA_SUB,freqs,pixel_spacing,dataset);
                end
                
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function sub_deform_epi2mni(PROJ_DIR,Asubject,subjectlist,voxsize)
            disp('sub_deform_epi2mni');
                        
            parfor ksub = subjectlist
                disp(['Subnum: ' int2str(ksub) ' ' Asubject(ksub).name]);
                DATA_SUB = fullfile(PROJ_DIR,Asubject(ksub).name);
                ANA_SUB = fullfile(DATA_SUB,'ANA');
                cd(ANA_SUB);
                
                deform_epi2mni(ANA_SUB,'MAGf_dico',voxsize); % Masken, Deformationsfelder
                deform_epi2mni(ANA_SUB,'MAGf_orig',voxsize);
                deform_epi2mni(ANA_SUB,'MAGm_moco',voxsize);
                deform_epi2mni(ANA_SUB,'MAGm_orig',voxsize);
                deform_epi2mni(ANA_SUB,'MAGm_dico',voxsize);
                deform_epi2mni(ANA_SUB,'MAGm_modico',voxsize);                
                
                deform_epidico2mni_ABSGPHIMAG(ANA_SUB,voxsize); % ABSG,PHI,MAG
                deform_epiorig2mni_ABSGPHIMAG(ANA_SUB,voxsize); % ABSG,PHI,MAG
            end
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function sub_segment_epi2mni(PROJ_DIR,Asubject,subjectlist)
            disp('segment_epi2mni');
            
            TPMdir = fullfile(spm('Dir'),'tpm');
            parfor ksub = subjectlist
                disp(['Subnum: ' int2str(ksub) ' ' Asubject(ksub).name]);
                DATA_SUB = fullfile(PROJ_DIR,Asubject(ksub).name);
                ANA_SUB = fullfile(DATA_SUB,'ANA');
                if ~exist(ANA_SUB,'dir'), mkdir(ANA_SUB); end
                cd(ANA_SUB);
                if ~exist(fullfile(ANA_SUB,'MAGf_orig_epi2mni_seg8.mat'),'file')
                    segment_epi2mni(ANA_SUB,'MAGf_orig',TPMdir);
                end
                if ~exist(fullfile(ANA_SUB,'MAGf_dico_epi2mni_seg8.mat'),'file')
                    segment_epi2mni(ANA_SUB,'MAGf_dico',TPMdir);
                end                
                if ~exist(fullfile(ANA_SUB,'MAGm_orig_epi2mni_seg8.mat'),'file')
                    segment_epi2mni(ANA_SUB,'MAGm_orig',TPMdir);
                end
                if ~exist(fullfile(ANA_SUB,'MAGm_moco_epi2mni_seg8.mat'),'file')
                    segment_epi2mni(ANA_SUB,'MAGm_moco',TPMdir);
                end
                if ~exist(fullfile(ANA_SUB,'MAGm_dico_epi2mni_seg8.mat'),'file')
                    segment_epi2mni(ANA_SUB,'MAGm_dico',TPMdir);
                end
                if ~exist(fullfile(ANA_SUB,'MAGm_modico_epi2mni_seg8.mat'),'file')
                    segment_epi2mni(ANA_SUB,'MAGm_modico',TPMdir);
                end
                
                af_interpolwrapfield_mod(ANA_SUB,'MAGf_orig','epi2mni'); % erzeugt wx,wy,wz-nifti-Dateien
                af_interpolwrapfield_mod(ANA_SUB,'MAGf_dico','epi2mni'); % erzeugt wx,wy,wz-nifti-Dateien                
                af_interpolwrapfield_mod(ANA_SUB,'MAGm_orig','epi2mni'); % erzeugt wx,wy,wz-nifti-Dateien
                af_interpolwrapfield_mod(ANA_SUB,'MAGm_moco','epi2mni'); % erzeugt wx,wy,wz-nifti-Dateien
                af_interpolwrapfield_mod(ANA_SUB,'MAGm_dico','epi2mni'); % erzeugt wx,wy,wz-nifti-Dateien
                af_interpolwrapfield_mod(ANA_SUB,'MAGm_modico','epi2mni'); % erzeugt wx,wy,wz-nifti-Dateien
                
                
            end
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function sub_segment_ana2mni(PROJ_DIR,Asubject,subjectlist)
            disp('segment_ana2mni');
            
            TPMdir = fullfile(spm('Dir'),'tpm');
            parfor ksub = subjectlist
                disp(['Subnum: ' int2str(ksub) ' ' Asubject(ksub).name]);
                DATA_SUB = fullfile(PROJ_DIR,Asubject(ksub).name);
                ANA_SUB = fullfile(DATA_SUB,'ANA');
                if ~exist(ANA_SUB,'dir'), mkdir(ANA_SUB); end
                cd(ANA_SUB);
                if exist(fullfile(ANA_SUB,'MPRAGE.nii'),'file')
                    tic
                    segment_ana2mni(ANA_SUB,TPMdir);  % segment untouched high-res mprage
                    t = toc
                    disp(t);
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %         function normwrite_mprage2mni(PROJ_DIR,Asubject,subjectlist)
        %
        %             for ksub = subjectlist
        %                 disp(['Subnum: ' int2str(ksub) ' ' Asubject(ksub).name]);
        %                 DATA_SUB = fullfile(PROJ_DIR,Asubject(ksub).name);
        %                 ANA_SUB = fullfile(DATA_SUB,'ANA');
        %                 mkdir(ANA_SUB);
        %                 cd(ANA_SUB);
        %                 if exist(fullfile(ANA_SUB,'c1MPRAGE_mprage_mni.nii'),'file')
        %                     tic
        %                     af_normwrite_mprage2mni(ANA_SUB);
        %                     t = toc
        %                     disp(t);
        %                 end
        %             end
        %         end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function sub_segment_epi2ana(PROJ_DIR,Asubject,subjectlist)
            disp('segment_epi2ana');
            
            parfor ksub = subjectlist
                disp(['Subnum: ' int2str(ksub) ' ' Asubject(ksub).name]);
                DATA_SUB = fullfile(PROJ_DIR,Asubject(ksub).name);
                ANA_SUB = fullfile(DATA_SUB,'ANA');                
                if ~exist(ANA_SUB,'dir'), mkdir(ANA_SUB); end
                
                cd(DATA_SUB);                
                
                if ~exist('EPI_c1_epi2ana_orig.nii','file')
                    segment_epi2ana(ANA_SUB,'MAGf_orig');
                end
                
                if ~exist('EPI_c1_epi2ana_dico.nii','file')
                    segment_epi2ana(ANA_SUB,'MAGf_dico');
                end
                
                if ~exist('EPI_c1_epi2ana_1.nii','file')
                    segment_epi2ana(ANA_SUB,'MAGm_orig');
                end
                
                if ~exist('EPI_c1_epi2ana_2.nii','file')
                    segment_epi2ana(ANA_SUB,'MAGm_moco');
                end
                
                if ~exist('EPI_c1_epi2ana_3.nii','file')
                    segment_epi2ana(ANA_SUB,'MAGm_dico');
                end
                
                if ~exist('EPI_c1_epi2ana_4.nii','file')
                    segment_epi2ana(ANA_SUB,'MAGm_modico');
                end
                
                af_interpolwrapfield_mod(ANA_SUB,'MAGf_orig','epi2ana'); % erzeugt wx,wy,wz-nifti-Dateien
                af_interpolwrapfield_mod(ANA_SUB,'MAGf_dico','epi2ana'); % erzeugt wx,wy,wz-nifti-Dateien
                af_interpolwrapfield_mod(ANA_SUB,'MAGm_orig','epi2ana'); % erzeugt wx,wy,wz-nifti-Dateien
                af_interpolwrapfield_mod(ANA_SUB,'MAGm_moco','epi2ana'); % erzeugt wx,wy,wz-nifti-Dateien
                af_interpolwrapfield_mod(ANA_SUB,'MAGm_dico','epi2ana'); % erzeugt wx,wy,wz-nifti-Dateien
                af_interpolwrapfield_mod(ANA_SUB,'MAGm_modico','epi2ana'); % erzeugt wx,wy,wz-nifti-Dateien
                
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        function sub_deform_ana2epi(PROJ_DIR,Asubject,subjectlist)
            disp('deform_ana2epi');
            
            parfor ksub = subjectlist
                disp(['Subnum: ' int2str(ksub) ' ' Asubject(ksub).name]);
                DATA_SUB = fullfile(PROJ_DIR,Asubject(ksub).name);
                ANA_SUB = fullfile(DATA_SUB,'ANA');
                if ~exist(ANA_SUB,'dir'), mkdir(ANA_SUB); end
                
                cd(ANA_SUB);
                
                 deform_ana2epi(ANA_SUB,'MAGf_dico');
                 deform_ana2epi(ANA_SUB,'MAGf_orig');
                 deform_ana2epi(ANA_SUB,'MAGm_orig');
                 deform_ana2epi(ANA_SUB,'MAGm_moco');
                 deform_ana2epi(ANA_SUB,'MAGm_dico');
                 deform_ana2epi(ANA_SUB,'MAGm_modico');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function sub_deform_ana2mni(PROJ_DIR,Asubject,subjectlist)
            disp('deform_ana2mni');
            
            parfor ksub = subjectlist
                disp(['Subnum: ' int2str(ksub) ' ' Asubject(ksub).name]);
                DATA_SUB = fullfile(PROJ_DIR,Asubject(ksub).name);
                ANA_SUB = fullfile(DATA_SUB,'ANA');                
                if ~exist(ANA_SUB,'dir'), mkdir(ANA_SUB); end
               
                cd(ANA_SUB);
                deform_ana2mni(ANA_SUB);
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function sub_create_dmyfield(PROJ_DIR,Asubject,subjectlist)
            disp('sub_create_dmyfield');
            
            for ksub = subjectlist
                disp(['Subnum: ' int2str(ksub) ' ' Asubject(ksub).name]);
                DATA_SUB = fullfile(PROJ_DIR,Asubject(ksub).name);
                RAWN_SUB = fullfile(DATA_SUB,'RAWN');
                cd(RAWN_SUB);
                
                disp('Header myfield...');
                head_distmy = spm_vol('RL_dico_ma.nii');
                head_distmy.fname = 'myfield.nii';
                DATA = spm_read_vols(spm_vol('my_field.nii'));
                spm_write_vol(head_distmy,DATA);
                !cp myfield.nii ../ANA/
                
                disp('Distort myfield...');
                !cp my_topup_results_fieldcoef.nii my_topup_results_fieldcoef_tmp.nii
                head_distmy = spm_vol('my_topup_results_fieldcoef.nii');
                head_distmy.fname = 'my_topup_results_fieldcoef_inverted.nii';
                DATA = -spm_read_vols(spm_vol('my_topup_results_fieldcoef.nii'));
                spm_write_vol(head_distmy,DATA);
                pause(1)
                system('fsl5.0-applytopup --imain=myfield --inindex=1 --datain=topup_param.txt --topup=my_topup_results --method=jac --interp=spline --out=dmy_field');
                !gunzip -f *.gz
                
                disp('Header myfield...');
                head_distmy = spm_vol('RL_dico_ma.nii');
                head_distmy.fname = 'dmyfield.nii';
                DATA = spm_read_vols(spm_vol('dmy_field.nii'));
                spm_write_vol(head_distmy,DATA);
                !gunzip -f *.gz
                
                !cp dmyfield.nii ../ANA/
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end

