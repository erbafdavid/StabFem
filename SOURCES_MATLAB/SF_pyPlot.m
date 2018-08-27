function SF_pyPlot(varargin)

global ff ffMPI ffdir ffdatadir sfdir pydir verbosity
mydisp(2, '### ENTERING FUNCTION SF_pyPlot ');

% varargin (optional input parameters)
p = inputParser;
addParameter(p, 'file', 'None', @ischar); % variable
addParameter(p, 'path', 'None', @ischar); % field type
addParameter(p, 'typeFormat', 'ff2m', @ischar); % variable
addParameter(p, 'twoFields', '1', @ischar); % variable
addParameter(p, 'typeField', 'em', @ischar); % variable
addParameter(p, 'typeField2', 'em', @ischar); % variable
addParameter(p, 'plotVar', 0, @isstruct); % variable
addParameter(p, 'plotVar2', 0, @isstruct); % variable
addParameter(p, 'field', 'ux1', @ischar); % field type
addParameter(p, 'field2', 'ux1', @ischar); % field type
addParameter(p, 'typePlot', 'contour', @ischar); % variable
addParameter(p, 'xlim', [0.,80.], @isnumeric); % variable
addParameter(p, 'ylim', [-10,10], @isnumeric); % variable
addParameter(p, 'title', 'None', @ischar); % variable
addParameter(p, 'mirror', '0', @ischar); % variable
addParameter(p, 'cmap', 'viridis', @ischar); % variable
addParameter(p, 'saveOption', '0', @ischar); % variable
addParameter(p, 'name', 'test', @ischar); % variable

parse(p, varargin{:});

plotVar = p.Results.plotVar;
plotVar2 = p.Results.plotVar2;
typeFormat = p.Results.typeFormat;
twoFields = p.Results.twoFields;
field = p.Results.field;
typeField2 = p.Results.typeField2;
field2 = p.Results.field2;
typePlot = p.Results.typePlot;
xlim = p.Results.xlim;
ylim = p.Results.ylim;
title = p.Results.title;
cmap = p.Results.cmap;
mirror = p.Results.mirror;
name = p.Results.name;
saveOption = p.Results.saveOption;

if(p.Results.path == 'None')
    typeField = mygetVarName(plotVar);
    typeField2 = mygetVarName(plotVar2);
    save([ffdatadir,'temporalVariable.mat']);
    file = 'temporalVariable.mat';
    path = ffdatadir;
end

[' python ', pydir,'plotFF2M.py ',path,' ',file,' @@opt_field ',field, ...
    ' @@opt_typeField ', typeField,' @@type_plot ', typePlot...
    ' @@twoFields ', twoFields ...
    ' @@opt_field2 ',field2, ' @@opt_typeField2 ', typeField2 ...
    ' @@xlim ', num2str(xlim(1)), ',' num2str(xlim(2)), ...
    ' @@ylim ', num2str(ylim(1)), ',' num2str(ylim(2)), ...
    ' @@title ', title, ' @@cmap ', cmap, ' @@mirror ', mirror...
    ' @@name ', name, ' @@saveOption ', saveOption...
    ]

mysystem([' python ', pydir,'plotFF2M.py ',path,' ',file,' @@opt_field ',field, ...
    ' @@opt_typeField ', typeField,' @@type_plot ', typePlot...
    ' @@twoFields ', twoFields ...
    ' @@opt_field2 ',field2, ' @@opt_typeField2 ', typeField2 ...
    ' @@xlim ', num2str(xlim(1)), ',' num2str(xlim(2)), ...
    ' @@ylim ', num2str(ylim(1)), ',' num2str(ylim(2)), ...
    ' @@title ', title, ' @@cmap ', cmap, ' @@mirror ', mirror...
    ' @@name ', name, ' @@saveOption ', saveOption...
    ]);

if(p.Results.path == 'None')
    myrm([ffdatadir,'temporalVariable.mat']);
end
