function spm_ArtRepair
%   ArtRepairv5 interface using uimenu command.
%   Format is directly from spm_Deformations.m by John Ashburner.
%   Hopefully this works in all versions of Matlab.

SPMid = spm('FnBanner',mfilename,'3');
%Finter = spm('CreateIntWin','on');
%[Finter,Fgraph,CmdLine] = spm('FnUIsetup','ArtRepair');
%spm_help('!ContextHelp',mfilename);

fig = spm_figure('GetWin','Interactive');
h0  = uimenu(fig,...
	'Label',	'Artifact Repair Toolbox v4',...
	'Separator',	'on',...
	'Tag',		'ArtRepair',...
	'HandleVisibility','on');
h1  = uimenu(h0,...
	'Label',	'View Data     :       Movie of signal variations on every voxel',...
	'Separator',	'off',...
	'Tag',		'ArtRepair',...
	'CallBack',	'art_movie;',...
	'HandleVisibility','on');
h1  = uimenu(h0,...
	'Label',	'View Data     :       Find RMS of image series',...
	'Separator',	'off',...
	'Tag',		'ArtRepair',...
	'CallBack',	'art_rms;',...
	'HandleVisibility','on');
h1  = uimenu(h0,...
	'Label',	'View Data     :       Display timeseries on a single voxel',...
	'Separator',	'off',...
	'Tag',		'ArtRepair',...
	'CallBack',	'art_plottimeseries;',...
	'HandleVisibility','on');
h1  = uimenu(h0,...
	'Label',	'Bad slices:           Repairs bad slices from scanner noise',...
	'Separator',	'off',...
	'Tag',		'ArtRepair',...
    'CallBack',	'art_slice;',...
	'HandleVisibility','on');
h1  = uimenu(h0,...
	'Label',	'Artifact Repair:      Reduces realignment residuals from interpolation',...
	'Separator',	'off',...
	'Tag',		'ArtRepair',...
	'CallBack',	'art_motionregress;',...
	'HandleVisibility','on');
h1  = uimenu(h0,...
	'Label',	'Artifact Repair:      Detects and repairs outlier volumes',...
	'Separator',	'off',...
	'Tag',		'ArtRepair',...
	'CallBack',	'art_global;',...
	'HandleVisibility','on');
h1  = uimenu(h0,...
	'Label',	'Artifact Repair:      Despike and/or high pass filter image series',...
	'Separator',	'off',...
	'Tag',		'ArtRepair',...
	'CallBack',	'art_despike;',...
	'HandleVisibility','on');
h1  = uimenu(h0,...
	'Label',	'Deweight:             Applies deweighting to existing SPM',...
	'Separator',	'off',...
	'Tag',		'ArtRepair',...
	'CallBack',	'art_redo;',...
	'HandleVisibility','on');
h1  = uimenu(h0,...
	'Label',	'Percent Scaling:      Finds scale factors into percent signal change',...
	'Separator',	'off',...
	'Tag',		'ArtRepair',...
	'CallBack',	'art_percentscale;',...
    'HandleVisibility','on');
h1  = uimenu(h0,...
	'Label',	'Summarize estimates:     Distribution of subject contrast estimates',...
	'Separator',	'off',...
	'Tag',		'ArtRepair',...
	'CallBack',	'art_summary;',...
	'HandleVisibility','on');
h1  = uimenu(h0,...
	'Label',	'Summarize group estimate   Distribution of group contrast estimates',...
	'Separator',	'off',...
	'Tag',		'ArtRepair',...
	'CallBack',	'art_groupsummary;',...
	'HandleVisibility','on');
h1  = uimenu(h0,...
	'Label',	'Review group SPM:     View all data in group SPM.mat',...
	'Separator',	'off',...
	'Tag',		'ArtRepair',...
	'CallBack',	'art_groupcheck;',...
	'HandleVisibility','on');
h1  = uimenu(h0,...
	'Label',	'Group Outlier:        Finds outlier subjects from con images',...
	'Separator',	'off',...
	'Tag',		'ArtRepair',...
	'CallBack',	'art_groupoutlier;',...
	'HandleVisibility','on');

