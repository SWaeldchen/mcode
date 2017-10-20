function pipeline_modico_afsh_7T(subjectlist)

if ~exist('subjectlist','var')    
    subjectlist = 14; 
end

%% Set Paths, Directories, Functions, Subjects and Fixed Parameters
% paths for spm, modico, infun and rician
if isunix
    addpath(genpath('/home/stefanh/spm12/'));
    addpath(genpath('/home/stefanh/HETZER/mrdata/Andi/pipeline'));
    %addpath(genpath('/home/stefanh/HETZER/mrdata/MODICO/script_modico_20151028/'));
    
    PROJ_DIR = '/home/stefanh/HETZER/mrdata/Andi/';
else
    %addpath(genpath('H:\HETZER\mrdata\MODICO\script_modico_20151028/\'));
    addpath(genpath('e:\Andi\pipeline'));
    addpath(genpath('C:/spm12/'));
    %PROJ_DIR = 'H:/HETZER/mrdata/MODICO/DATA';
    PROJ_DIR = 'e:\Andi';
end

if (strcmp(version('-release'),'2015b'))
    addpath(genpath('/home/andi/work/mretools/project_modico/'));
    addpath(genpath('/opt/MATLAB/R2009a/toolbox/spm12/'));
    addpath('/home/andi/in_fun/');
    load('/home/andi/work/mretools/project_modico/script_modico/cmp_uh.mat');
    PROJ_DIR = fullfile('/media','afdata','project_modico');
end

PIC_DIR = fullfile(PROJ_DIR,'PICS');
if ~exist(PIC_DIR,'dir'), mkdir(PIC_DIR); end

disp(path);

TPMdir = fullfile(spm('Dir'),'tpm');
modico = 2;
list_process = {'orig','moco','dico','modico'};


% Subject List
% PROBID,MPRAGE,RLmag,LRmag,dynseriesmag,freqseries,slices,Tesla,ASL,ASL-RL,ASL-LR
Asubject_cell = {
    {'MREPERF-FD_20150513-133126',7,16,18,14,[30 40 50],40,30,3,4,5,'F. Dittmann',26}
    {'SHi_MREPERF_20150622',26,9,11,3,[30 40 50],40,30,15,16,17,'S. Hirsch',31}
    {'MREPERF-LM_20150624-131215',14,5,7,3,[30 40 50],40,30,11,12,13,'L. Marz',20}
    {'MREPERF-SH_20150625-145714',14,5,7,3,[30 40 50],40,30,11,12,13,'S. Hetzer',38}
    {'MREPERF-AFAndi_20150625-140247',14,5,7,3,[30 40 50],40,30,11,12,13,'A. Fehlner',29}
    {'MREPERF-TS_20150626-090422',14,5,7,3,[30 40 50],40,30,11,12,13,'T. Scheuermann',28}
    {'MREPERF-JB_20150630-110303',14,5,7,3,[30 40 50],40,30,11,12,13,'J. Braun',54}
    {'MREPERF-IS_20150630-132315',6,19,21,17,[30 40 50],40,30,3,4,5,'I. Sack',45}
    {'MREPERF-HT_20150630-114822',6,19,21,17,[30 40 50],40,30,3,4,5,'H. Tzschaetzsch',30}
    {'MREPERF-AR_20150706-095001',15,5,7,3,[30 40 50],40,30,12,13,14,'A. Ratthey',48}
    {'MREPERF-DS_20150707-164535',15,5,7,3,[30 40 50],40,30,24,13,14,'D. Schubert',56}
    {'MREPERF-TC_20150707-155729',15,5,7,3,[30 40 50],40,30,12,13,14,'T. Christofel',32}
    {'MREPERF-VG_20150707-173412',15,5,7,3,[30 40 50],40,30,12,13,14,'V. Gruendel',28}
    {'MREPERF-DG_20150708-112321',15,5,7,3,[30 40 50],40,30,12,13,14,'D. Glass',53}
    };

rowHeadings3T={'name','mprage','refRL','refLR','dynma','dynfreqs','nslices','tesla','dynmagasl','aslRL','aslLR','fullname','age'};

for ksub = 1:size(Asubject_cell,1)
    TMP_c2s = cell2struct(Asubject_cell{ksub}',rowHeadings3T,1);
    Asubject(ksub) = TMP_c2s;
end

freqs = [30 40 50];
pixel_spacing = [2 2]/1000;

class_modicoismrm.mredata_import(PROJ_DIR,Asubject,subjectlist,2);
class_modicoismrm.mredata_calc(PROJ_DIR,Asubject,subjectlist,2);
class_modicoismrm.mredata_mdev(PROJ_DIR,Asubject,subjectlist,freqs,pixel_spacing);

class_modicoismrm.segment_mprage2mni(PROJ_DIR,Asubject,subjectlist);
class_modicoismrm.sub_segment_epi2ana(PROJ_DIR,Asubject,subjectlist);
class_modicoismrm.sub_deform_ana2epi(PROJ_DIR,Asubject,subjectlist);
class_modicoismrm.sub_norm_epi2mni(PROJ_DIR,Asubject,subjectlist);
class_modicoismrm.sub_deform_ana2mni(PROJ_DIR,Asubject,subjectlist);

%class_modico.norm_estwrite_mre(PROJ_DIR,Asubject_struct,subjectlist);
%class_modico.prepare_spm_segmentnorm_mprage2tpm(PROJ_DIR,Asubject_struct,subjectlist);
%class_modico.prepare_spm_segment_MRE2mprage(PROJ_DIR,Asubject_struct,subjectlist);
%class_modico.prepare_data(PROJ_DIR,Asubject_struct,subjectlist);

%class_modico.norm_estwrite_mre(PROJ_DIR,Asubject_struct,subjectlist);
%class_modico.prepare_data(PROJ_DIR,Asubject_struct,subjectlist);
%class_modico.importmpragedata(PROJ_DIR,Asubject_struct,subjectlist);
%class_modico.prepare_spm_segmentnorm_MRE2MNI(PROJ_DIR,Asubject_struct,subjectlist);
%class_modico.combine_3D_PARA_segMRE(PROJ_DIR,Asubject_struct,subjectlist)
%class_modico.combine_3D_maskseg(PROJ_DIR,Asubject_struct,subjectlist);
%class_modico.plot_myfield_fieldMAGRL(PROJ_DIR,Asubject_struct,subjectlist);



end
