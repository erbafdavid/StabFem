function [baseflow,eigenmode] = SF_FindThreshold(baseflow,eigenmode,varargin)

% Direct computation of instability threshold

global ff ffMPI ffdir ffdatadir sfdir verbosity

system(['cp ' ffdatadir 'Eigenmode.txt ' ffdatadir 'Eigenmode_guess.txt']);

if(isfield(baseflow,'np')==1)
       % first argument is a simple mesh
       ffmesh = baseflow; 
   else
       % first argument is a base flow
       ffmesh = baseflow.mesh;
end

p = inputParser;

 if(isfield(baseflow,'Re')) ReDefault = baseflow.Re ; else ReDefault = 0; end;
 if(isfield(baseflow,'Ma')) MaDefault = baseflow.Ma ; else MaDefault = 0.03; end;
 addParameter(p,'Ma',MaDefault,@isnumeric); % Reynolds
 addParameter(p,'Re',ReDefault,@isnumeric);
 addParameter(p,'ncores',1,@isnumeric);
 parse(p,varargin{:});
 
switch ffmesh.problemtype

    case('2DComp')
     
     mydisp(1,['      ### FUNCTION SF_FindThreshold']);
     mydisp(1,['      ### USING Compressible Solver']);
     argumentstring = [' " ' num2str(p.Results.Ma) ' '   num2str(p.Results.Re) ' ' num2str(-1) ...
                          '  L ' num2str(0.5) ' " '];
        solvercommand = ['echo ' argumentstring ' | ',ffMPI,' -np ',num2str(p.Results.ncores),' ', 'FindThreshold.edp'];
        status = mysystem(solvercommand);
 case default
       solvercommand = [ff ' ' ffdir 'FindThreshold2D.edp'];
       status = mysystem(solvercommand);
end
 
        
disp(['#### Direct computation of instability threshold ']);

baseflowT=importFFdata(baseflow.mesh,'BaseFlow_threshold.ff2m');
eigenmodeT=importFFdata(baseflow.mesh,'Eigenmode_threshold.ff2m');


disp(['#### Re_c =  ' num2str(baseflowT.Re) ]);
disp(['#### lambda_c =  ' num2str(eigenmodeT.lambda) ]);

if(nargout>0)
baseflow=baseflowT;
system(['cp ',ffdatadir,'BaseFlow_threshold.txt ',ffdatadir,'BaseFlow.txt']);
system(['cp ',ffdatadir,'BaseFlow_threshold.txt ',ffdatadir,'BaseFlow_guess.txt']);
end


if(nargout>1)
eigenmode=eigenmodeT;
system(['cp ',ffdatadir,'Eigenmode_threshold.txt ',ffdatadir,'Eigenmode_guess.txt']);
end


