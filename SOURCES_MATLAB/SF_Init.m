%> @file SOURCES_MATLAB/SF_Init.m
%> @brief Matlab/FreeFem driver for generating initial mesh and base flow
%>
%> @param[in] meshfile: FreeFem script file
%> @param[in] parameters: Parameters for the FreeFem++ script
%> @param[out] baseflow: Generated Base Flow
%>
%> Usage in single-input mode: <code>baseflow = SF_Init('Mesh.edp')</code>
%> Usage in two-inputs mode: <code>baseflow = SF_Init('Mesh.edp',params)</code>
%>
%> 'Mesh.edp' must be a FreeFem script which generates a file "mesh.msh", a
%>  parameter file "SF_Init.ff2m", and an initial base flow
%>  "BaseFlow_init.txt" / "BaseFlow_init.ff2m"
%>
%> @author David Fabre
%> @date june 2017
%> @version 2.0
function baseflow = SF_Init(meshfile, parameters)
global ff ffdir ffdatadir sfdir verbosity

% Creation et vidange du WORK/
if (exist(ffdatadir) ~= 7 && exist(ffdatadir) ~= 5)
    mymake(ffdatadir);
else
    myrm([ffdatadir, '*.txt ', ffdatadir, '*.ff2m ', ffdatadir, '*.msh ']);
end

% Creation et vidange de BASEFLOWS/
if (exist([ffdatadir, 'BASEFLOWS']) ~= 7)
    mymake([ffdatadir, 'BASEFLOWS/']);
else
    myrm([ffdatadir, 'BASEFLOWS/*']);
end

% Creation et vidange de BASEFLOWS/
if (exist([ffdatadir, 'MESHES']) ~= 7)
    mymake([ffdatadir, 'MESHES/']);
else
    myrm([ffdatadir, 'MESHES/*']);
end


% Execution du maillage
if (nargin == 1)
    command = [ff, ' ', meshfile];
else
    stringparam = [];
    for p = parameters;
        stringparam = [stringparam, num2str(p), '  '];
    end
    command = ['echo   ', stringparam, '  | ', ff, ' ', meshfile];
    
    %   Warning : does not work with windows (Adrien)
    %    command = ['echo  ', parameters, ' | ',ff,' ',meshfile]
    
end
error = 'ERROR : SF_Init not working ! \n Possible causes : \n 1/ your "ff" variable is not correctly installed (check SF_Start.m) ; \n 2/ Your Freefem++ script is bugged (try running it outside the Matlab driver) ';
mysystem(command, error);

% Traitement des infos
if (nargout == 1)
    mesh = importFFmesh([ffdatadir, 'mesh.msh']);
    %   mycp([ffdatadir 'mesh.msh'],[ffdatadir '/BASEFLOWS/mesh_init.msh']);
    mycp([ffdatadir, 'mesh.msh'], [ffdatadir, '/MESHES/mesh_init.msh']);
    mycp([ffdatadir, 'mesh.ff2m'], [ffdatadir, '/MESHES/mesh_init.ff2m']);
    mycp([ffdatadir, 'SF_Init.ff2m'], [ffdatadir, '/MESHES/SF_Init.ff2m']);
    mycp([ffdatadir, 'BaseFlow_guess.txt'], [ffdatadir, 'BASEFLOWS/BaseFlow_init.txt']);
    mycp([ffdatadir, 'BaseFlow_guess.txt'], [ffdatadir, 'MESHES/BaseFlow_init.txt']);
    mycp([ffdatadir, 'BaseFlow.ff2m'], [ffdatadir, 'BaseFlow_guess.ff2m']); % in future the mesh creator should create direcly BaseFlow_guess
    mycp([ffdatadir, 'BaseFlow_guess.ff2m'], [ffdatadir, 'BASEFLOWS/BaseFlow_init.ff2m']);
    mycp([ffdatadir, 'BaseFlow_guess.ff2m'], [ffdatadir, 'MESHES/BaseFlow_init.ff2m']);
    mesh.filename = [ffdatadir, 'MESHES/mesh_init.msh'];
    baseflow = importFFdata(mesh, 'BaseFlow_guess.ff2m');
    baseflow.filename = [ffdatadir, 'MESHES/BaseFlow_init.txt'];
    mydisp(1,['      ### INITIAL MESH CREATED WITH np = ', num2str(mesh.np), ' points']);
end

% myrm([ffdatadir 'Eigenmode_guess.txt']);

end