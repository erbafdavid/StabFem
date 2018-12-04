function Data = SF_Launch(file, varargin)
% generic Matlab/FreeFem driver
%
% usage : mesh = SF_Launch('File.edp', {Param1, Value1, Param2, Value2, etc...})
%
% First argument must be a valid FreeFem++ script
%
% Couples of optional parameters/values comprise :
%   'Params' -> a list of input parameters for the FreeFem++ script
%           for instance SF_Launch('File.edp','Params',[10 100]) will be
%           equivalent to typing 'FreeFem++ File.edp' and entering successively
%           10 and 100 through the keyboard)
%   'Mesh' -> a mesh associated to the data
%           (either a mesh struct or the name of a file)
%   'DataFile' -> the name of the resulting file
%   'Type' -> a string specifying the type of computation for the FreeFe++ script 
%
% 'Mesh.edp' must be a FreeFem script which generates a file "mesh.msh",
% a description file "mesh.ff2m", a geometrical parameter file "SF_Init.ff2m"
%
% Explanation : 
%   1/if Type and Params are both present, this driver will launch 
%       'echo "Type Params" | ff++ file
%   2/if Param is absent but Params is present, this driver will launch 
%       'echo "Params" | ff++ file
%   3/if both are absent we simply launch
%        'ff++ file
%
%
% by D. Fabre ,  june 2017, redesigned dec. 2018
%


p = inputParser;
addParameter(p, 'Params', NaN);
addParameter(p, 'Mesh', 0);
addParameter(p, 'DataFile', 'Data.ff2m');
addParameter(p, 'Type', 'none');
parse(p, varargin{:})

global ff ffdir ffdatadir sfdir verbosity

mydisp(2, ['### Starting SF_Launch ', file]);

if (isstruct(p.Results.Mesh))
    mydisp(5, 'Mesh passed as structure');
    ffmesh = p.Results.Mesh;
    mycp(p.Results.Mesh.filename, 'mesh.msh')
end

stringparam = [];
if (~strcmpi(p.Results.Type,'none'))
        stringparam = [p.Results.Type '  '];
end

if ~(exist(file,'file'))
    if(exist([ffdir file],'file'))
        file = [ffdir file];
    else
        error([' Error in SF_Launch : FreeFem++ program ' ,file, ' not found']);
    end
end

if ((p.Results.Params)~=NaN)
    for pp = p.Results.Params;
        stringparam = [stringparam, num2str(pp), '  '];
    end
end

if (length(stringparam)==0)
    command = [ff, ' ', file];
else
    command = ['echo   ', stringparam, '  | ', ff, ' ', file];
end

errormsg = 'ERROR : SF_Launch not working ! \n Possible causes : \n 1/ your "ff" variable is not correctly installed (check SF_Start.m) ; \n 2/ Your Freefem++ script is bugged (try running it outside the Matlab driver) ';
mysystem(command, errormsg);


if (isnumeric(p.Results.Mesh) == 1)
    Data = importFFdata(p.Results.DataFile);
else
    Data = importFFdata(p.Results.Mesh, p.Results.DataFile);
end

end
