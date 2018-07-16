function Data = SF_Launch(file, varargin)
% generic Matlab/FreeFem driver
%
% usage : mesh = SF_Launch('File.edp', {Param1, Value1, Param2, Value2, etc...})
%
% Couples of optional parameters/values comprise :
%   'Params' -> a list of input parameters for the FreeFem++ script
%           for instance SF_Launch('File.edp','Params',[10 100]) will be
%           equivalent to typing 'FreeFem++ File.edp' and entering successively
%           10 and 100 through the keyboard)
%   'Mesh' -> a mesh associated to the data
%           (either a mesh struct or the name of a file)
%   'DataFile' -> the name of the resulting file
%
% 'Mesh.edp' must be a FreeFem script which generates a file "mesh.msh",
% a description file "mesh.ff2m", a geometrical parameter file "SF_Init.ff2m"
%
% Version 2.0 by D. Fabre ,  june 2017

p = inputParser;
addParameter(p, 'Params', NaN);
addParameter(p, 'Mesh', 0);
addParameter(p, 'DataFile', 'Data.ff2m');
parse(p, varargin{:})

global ff ffdir ffdatadir sfdir verbosity

mydisp(2, ['### Starting SF_Launch ', file]);

%if(isstring(p.Results.Mesh)) % in case I find a way to pass as a file...
%    mydisp(5,'Mesh read from file');
%    system(['cp ' p.Results.Mesh ' mesh.msh'])
%    ffmesh = imporFFmesh('mesh.msh'
%end

if (isstruct(p.Results.Mesh))
    mydisp(5, 'Mesh passed as structure');
    ffmesh = p.Results.Mesh;
    %system(['cp ' p.Results.Mesh.namefile ' mesh.msh'])
    p.Results.Mesh.filename
    mycp(p.Results.Mesh.filename, 'mesh.msh')
end

if ((p.Results.Params) == NaN)
    command = [ff, ' ', file];
else
    stringparam = [];
    for pp = p.Results.Params;
        stringparam = [stringparam, num2str(pp), '  '];
    end
    command = ['echo   ', stringparam, '  | ', ff, ' ', file];
end

error = 'ERROR : SF_Launch not working ! \n Possible causes : \n 1/ your "ff" variable is not correctly installed (check SF_Start.m) ; \n 2/ Your Freefem++ script is bugged (try running it outside the Matlab driver) ';
mysystem(command, error);


if (isnumeric(p.Results.Mesh) == 1)
    Data = importFFdata(p.Results.DataFile);
else
    Data = importFFdata(p.Results.Mesh, p.Results.DataFile);
end

end
