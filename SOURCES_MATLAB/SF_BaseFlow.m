%> @file SOURCES_MATLAB/SF_BaseFlow.m
%> @brief StabFem wrapper for Base flow calculation (Newton iteration)
%>
%> @param[in] baseflow: baseflow guess to initialise NEwton iterations
%> @param[in] varargin: list of parameters and associated values
%> @param[out] baseflow: baseflow solved by Newton iterations
%>
%> usage: <code>baseflow = SF_BaseFlow(baseflow1,['Param1',Value1,...])</code>
%>
%> This wrapper will launch the Newton FreeFem++ program of the corresponding
%>  case. Nota Bene: if baseflow was already created, it is simply copied from
%>  the "BASEFLOW" directory (unless specified otherwise by parameter 'Type').
%>
%> List of valid parameters:
%>   - <code>Re</code>          Reynolds number
%>   - <code>Ma</code>          Mach number (for compressible cases)
%>   - <code>Omegax</code>      Rotation rate (for swirling axisymetric or 2D body)
%>   - <code>Darcy</code>       Darcy number (for cases with porous body)
%>   - <code>Porosity</code> \t\t    Porosity (for cases with porous body)
%>   - <code>Type</code>
%>      - <code>'Normal'</code> (default) ;
%>      - <code>'NEW'</code> to force new computation ;
%>      - <code>'POSTADAPT'</code> for recomputing baseflow after mesh adaptation ;
%>      - <code>'PREV'</code> if connection was lost (obsolete ?)
%>   - <code>ncores</code>      Number of cores (for parallel computations)
%>
%> SF IMPLEMENTATION:
%> Depending on set parameters, this wrapper will select and launch one of the
%>  following FreeFem++ solvers:
%>       'Newton_Axi.edp'
%>       'Newton_AxiSWIRL.edp'
%>       'Newton_2D.edp'
%>       'Newton_2D_Comp.edp'
%>
%> Nota Bene: if for some reason the mesh/baseflow compatibility was lost, use
%>  <CODE>SF_BaseFlow(baseflow,'Re',Re,'type','PREV')</CODE> to reconstruct the structure and
%>  relocate files correctly. Similarly, to force recomputation even if files exist,
%>  (for instance, just after adaptmesh), use <code>SF_BaseFlow(baseflow,'Re',Re,'type','NEW')</code>.
%>
%> This syntax allows to do <CODE>baseflow=SF_BaseFlow(baseflow)</CODE> which is useful
%>  for instance to recomputed the baseflow after mesh adaptation.
%>
%> @author David Fabre
%> @date 2017-2018
%> @copyright GNU Public License
function baseflow = SF_BaseFlow(baseflow, varargin)
global ff ffMPI ffdir ffdatadir sfdir verbosity

mydisp(2, '### ENTERING FUNCTION SF_BaseFlow ');

% MANAGEMENT OF PARAMETERS (Re, Mach, Omegax, Porosity...)
% Explanation
% (Mode 1) if parameters are transmitted to the function we use these ones.
%      (for instance baseflow = SF_BaseFlow(baseflow1,'Re',10)
% (Mode 2) if no parameters are passed and if the field exists in the previous
% baseflow, we take these values
%      (for instance SF_BaseFlow(bf) is equivalent to SF_Baseflow(bf,'Re',bf.Re) )
% (Mode 3) if no previous value we will define default values set in the next lines.

p = inputParser;
if (isfield(baseflow, 'Re')) ReDefault = baseflow.Re;
else ReDefault = 2;
end;
addParameter(p, 'Re', ReDefault, @isnumeric); % Reynolds

if (isfield(baseflow, 'Ma')) MaDefault = baseflow.Ma;
else MaDefault = 0.01;
end;
addParameter(p, 'Mach', MaDefault, @isnumeric); % Mach

if (isfield(baseflow, 'Omegax')) OmegaxDefault = baseflow.Omegax;
else OmegaxDefault = 0;
end
addParameter(p, 'Omegax', OmegaxDefault, @isnumeric); % rotation rate (for swirling body)

if (isfield(baseflow, 'Darcy')) DarcyDefault = baseflow.Darcy;
else DarcyDefault = 0;
end
addParameter(p, 'Darcy', DarcyDefault, @isnumeric); % For porous body

if (isfield(baseflow, 'Porosity')) PorosityDefault = baseflow.PorosityDefault;
else PorosityDefault = 0.95;
end
addParameter(p, 'Porosity', PorosityDefault, @isnumeric); % For porous body too

addParameter(p, 'type', 'Normal', @ischar); % mode type
addParameter(p, 'ncores', 1, @isnumeric); % number of cores to launch in parallel

addParameter(p, 'MappingDef', 'Type1'); % Array of parameters for the cases involving mapping
addParameter(p, 'MappingParams', 'default'); % Array of parameters for the cases involving mapping

parse(p, varargin{:});

% Now the right parameters are in p.Results
Re = p.Results.Re;
Ma = p.Results.Mach;
Omegax = p.Results.Omegax;
Darcy = p.Results.Darcy;
Porosity = p.Results.Porosity;
ncores = p.Results.ncores; % By now only for the 2D compressible


%%% SELECTION OF THE SOLVER TO BE USED DEPENDING ON THE CASE

switch (baseflow.mesh.problemtype)
    
    case ('AxiXR') % Newton calculation for axisymmetric base flow
        mydisp(1, '## Entering SF_BaseFlow (axisymmetric case)');
        solvercommand = ['echo ', num2str(Re), ' | ', ff, ' ', ffdir, 'Newton_Axi.edp'];
        BFfilename = [ffdatadir, 'BASEFLOWS/BaseFlow_Re', num2str(Re)];
        
    case ('AxiXRCOMPLEX') % Newton calculation for axisymmetric base flow WITH COMPLEX MAPPING
        mydisp(1, '## Entering SF_BaseFlow (axisymmetric case COMPLEX)');
        %%% Writing parameter file for Adapmesh
        createMappingParamFile(p.Results.MappingDef,p.Results.MappingParams); %% See auxiliary function of this file
        solvercommand = ['echo ', num2str(Re),' | ', ff, ' ', ffdir, 'Newton_Axi_COMPLEX.edp'];
        BFfilename = [ffdatadir, 'BASEFLOWS/BaseFlow_Re', num2str(Re)];
   case ('AxiCompCOMPLEX')
        mydisp(1, '## Entering SF_BaseFlow (axisymmetric Compressible case COMPLEX)');
        % generating file "Param_Mapping.edp" used by Newton and stab. solver
        %%% Writing parameter file for Adapmesh
        if(length(p.Results.MappingParams)==9) % if no parameters are specified then the file must already exist
            fid = fopen('Param_Mapping.edp', 'w');
                fprintf(fid, '// Parameters for complex mapping (file generated by matlab driver)\n');
                fprintf(fid, ['real ParamMapx0 = ', num2str(p.Results.MappingParams(1)), ' ;']);
                fprintf(fid, ['real ParamMapx1 = ', num2str(p.Results.MappingParams(2)), ' ;']);
                fprintf(fid, ['real ParamMapLA = ',  num2str(p.Results.MappingParams(3)), ' ;']);
                fprintf(fid, ['real ParamMapLC = ', num2str(p.Results.MappingParams(4)), ' ;']);
                fprintf(fid, ['real ParamMapGC = ',  num2str(p.Results.MappingParams(5)), ' ;']);
                fprintf(fid, ['real ParamMapyo = ', num2str(p.Results.MappingParams(6)), ' ;']);
                fprintf(fid, ['real ParamMapLAy = ',  num2str(p.Results.MappingParams(7)), ' ;']);
                fprintf(fid, ['real ParamMapLCy = ', num2str(p.Results.MappingParams(8)), ' ;']);
                fprintf(fid, ['real ParamMapGCy = ',  num2str(p.Results.MappingParams(9)), ' ;']);
            fclose(fid);
        end
        mydisp(1, '## Entering SF_BaseFlow (Axi-COMPLEX COMPRESSIBLE) ');
        solvercommand = ['echo ', num2str(Re), ' ', num2str(p.Results.Mach), ' | ', ffMPI, ' ', ffdir, 'Newton_Axi_Comp_COMPLEX.edp'];
        BFfilename = [ffdatadir, 'BASEFLOWS/BaseFlow_Re', num2str(Re), 'Ma', num2str(Ma)];
    case ('AxiCompCOMPLEX_m') % with azimuthal mode
        mydisp(1, '## Entering SF_BaseFlow (axisymmetric Compressible case COMPLEX)');
        % generating file "Param_Mapping.edp" used by Newton and stab. solver
        %%% Writing parameter file for Adapmesh
        if(length(p.Results.MappingParams)==9) % if no parameters are specified then the file must already exist
            fid = fopen('Param_Mapping.edp', 'w');
                fprintf(fid, '// Parameters for complex mapping (file generated by matlab driver)\n');
                fprintf(fid, ['real ParamMapx0 = ', num2str(p.Results.MappingParams(1)), ' ;']);
                fprintf(fid, ['real ParamMapx1 = ', num2str(p.Results.MappingParams(2)), ' ;']);
                fprintf(fid, ['real ParamMapLA = ',  num2str(p.Results.MappingParams(3)), ' ;']);
                fprintf(fid, ['real ParamMapLC = ', num2str(p.Results.MappingParams(4)), ' ;']);
                fprintf(fid, ['real ParamMapGC = ',  num2str(p.Results.MappingParams(5)), ' ;']);
                fprintf(fid, ['real ParamMapyo = ', num2str(p.Results.MappingParams(6)), ' ;']);
                fprintf(fid, ['real ParamMapLAy = ',  num2str(p.Results.MappingParams(7)), ' ;']);
                fprintf(fid, ['real ParamMapLCy = ', num2str(p.Results.MappingParams(8)), ' ;']);
                fprintf(fid, ['real ParamMapGCy = ',  num2str(p.Results.MappingParams(9)), ' ;']);
            fclose(fid);
        end
        mydisp(1, '## Entering SF_BaseFlow (Axi-COMPLEX COMPRESSIBLE) ');
        solvercommand = ['echo ', num2str(Re), ' ', num2str(p.Results.Mach), ' | ', ffMPI, ' ', ffdir, 'Newton_Axi_Comp_COMPLEX_m.edp'];
        BFfilename = [ffdatadir, 'BASEFLOWS/BaseFlow_Re', num2str(Re), 'Ma', num2str(Ma)];
        
    case ('AxiXRPOROUS') % axisymmetric WITH SWIRL
        mydisp(1, '## Entering SF_BaseFlow (axisymmetric case WITH SWIRL)');
        solvercommand = ['echo ', num2str(Re), ' ', num2str(p.Results.Omegax), ' ', num2str(p.Results.Darcy), ' ', num2str(p.Results.Porosity), ' | ', ff, ' ', ffdir, 'Newton_AxiSWIRL.edp']
        BFfilename = [ffdatadir, 'BASEFLOWS/BaseFlow_Re', num2str(Re), '_Omega', num2str(p.Results.Omegax), '_Da', num2str(p.Results.Darcy), '_Por', num2str(p.Results.Porosity)];
        
    case ({'2D','2DMobile'})
        mydisp(1, '## Entering SF_BaseFlow (2D INCOMPRESSIBLE)');
        solvercommand = ['echo ', num2str(Re), ' | ', ff, ' ', ffdir, 'Newton_2D.edp'];
        BFfilename = [ffdatadir, 'BASEFLOWS/BaseFlow_Re', num2str(Re)];
        
    case ('2DComp')
        createMappingParamFile(p.Results.MappingDef,p.Results.MappingParams); %% See auxiliary function of this file
        mydisp(1, '## Entering SF_BaseFlow (2D COMPRESSIBLE) ');
        solvercommand = ['echo ', num2str(Re), ' ', num2str(p.Results.Mach), ' | ', ffMPI, ' -np ', num2str(ncores), ' ', ffdir, 'Newton_2D_Comp.edp'];
        BFfilename = [ffdatadir, 'BASEFLOWS/BaseFlow_Re', num2str(Re), 'Ma', num2str(Ma)];
        
        % case (other cases...)
    otherwise
        error(['ERROR : problem type ' baseflow.mesh.problemtype ' not recognized ']); 
end %switch

errormessage = 'ERROR : SF_ base flow computation aborted';

if (exist([BFfilename, '.txt']) == 2 && strcmpi(p.Results.type, 'NEW') ~= 1 && strcmpi(p.Results.type, 'POSTADAPT') ~= 1)
    mydisp(3, ['Base flow already computed for Re = ', num2str(Re)]);
    mycp([BFfilename, '.txt'], [ffdatadir, 'BaseFlow.txt']); %% in future this should not be necessary
    mycp([BFfilename, '.ff2m'], [ffdatadir, 'BaseFlow.ff2m']); %% in future this should not be necessary
    baseflow.iter = 0;
    
else
    
    
    %  POSITION THE "GUESS" FILE
%    if (strcmp(p.Results.type, 'POSTADAPT') ~= 1)
        mydisp(3, ['Computing base flow for Re = ', num2str(Re)]);
        mycp(baseflow.filename, [ffdatadir, 'BaseFlow_guess.txt']);
        mycp(baseflow.mesh.filename, [ffdatadir, 'mesh.msh']);
%    else
%        mydisp(3, ['Recomputing base flow after adaptmesh for Re = ', num2str(Re)]);
%        mycp([ffdatadir, 'BaseFlow_adaptguess.txt'], [ffdatadir, 'BaseFlow_guess.txt']);
%        mycp(baseflow.filename, [ffdatadir, 'BaseFlow_guess.txt']);
%        mycp([ffdatadir, 'mesh_adapt.msh'], [ffdatadir, 'mesh.msh']);
%        baseflow.mesh = importFFmesh([ffdatadir, 'mesh.msh']);
%    end
    
    %%% TO BE MODIFIED
    
    % CALL NEWTON SOLVER
    mysystem(solvercommand, errormessage);
    if (exist([ffdatadir, 'BaseFlow.txt']) == 0);
        error('ERROR : SF_ base flow computation did not converge');
    end
    
    % Copy under the expected name
    
    if(strcmpi(p.Results.type, 'POSTADAPT')==1)
         myrm([ffdatadir '/BASEFLOWS/*']); % after adapt we clean the "BASEFLOWS" directory as the previous baseflows are no longer compatible 
    end
    mycp([ffdatadir, 'BaseFlow.txt'], [BFfilename, '.txt']);
    mycp([ffdatadir, 'BaseFlow.ff2m'], [BFfilename, '.ff2m']);
    
end

% import data
baseflow = importFFdata(baseflow.mesh, [BFfilename, '.ff2m']);
baseflow.filename = [BFfilename, '.txt']; %maybe redundant ?

if(strcmpi(baseflow.mesh.meshtype,'2DMapped'))
    % for cases involving mapping ; update Mapping definition in mesh as
    % this one may hve changed
    fileToRead4 = [ffdatadir,'Mapping.ff2m'];
    m2 = importFFdata(baseflow.mesh,fileToRead4);
    baseflow.mesh.xphys = m2.xphys;
    baseflow.mesh.yphys = m2.yphys;
    baseflow.mesh.Hx = m2.Hx;
    baseflow.mesh.Hy = m2.Hy;
end

if (baseflow.iter >= 1)
    message = ['=> Base flow converged in ', num2str(baseflow.iter), ' iterations '];
    if (isfield(baseflow, 'Fx') == 1) %% adding drag information for blunt-body wake
        message = [message, '; Fx = ', num2str(baseflow.Fx)];
    end
    if (isfield(baseflow, 'Lx') == 1) %% adding drag information for blunt-body wake
        message = [message, '; Lx = ', num2str(baseflow.Lx)];
    end
    if (isfield(baseflow, 'deltaP0') == 1) %% adding pressure drop information for jet flow
        message = [message, '; deltaP0 = ', num2str(baseflow.deltaP0)];
    end
    mydisp(2, message);
else
    mydisp(1, ['      ### Base flow recovered from previous computation for Re = ', num2str(Re)]);
end

mydisp(2, '### END FUNCTION SF_BASEFLOW ');
end


function [] = createMappingParamFile(MappingDef,MappingParams)
% This auxiliary function creates the file with complex parameters
% There are currently 2 different cases (to be generalized someday...)
    if(isnumeric(MappingParams))  
    switch(MappingDef)   
            case('Type1')  
        % Mapping with 6 parameters for axisym. flow across a hole 
            fid = fopen('Param_Mapping.edp', 'w');
            fprintf(fid, '// Parameters for complex mapping (file generated by matlab driver)\n');
            fprintf(fid, ['real ParamMapLm = ', num2str(MappingParams(1)), ' ;']);
            fprintf(fid, ['real ParamMapLA = ',  num2str(MappingParams(2)), ' ;']);
            fprintf(fid, ['real ParamMapLC = ', num2str(MappingParams(3)), ' ;']);
            fprintf(fid, ['real ParamMapGC = ',  num2str(MappingParams(4)), ' ;']);
            fprintf(fid, ['real ParamMapyA = ', num2str(MappingParams(5)), ' ;']);
            fprintf(fid, ['real ParamMapyB = ',  num2str(MappingParams(6)), ' ;']);
            fclose(fid);
          case('Type2')      
        % Mapping with 9 parameters for 2D flow around an object
                fid = fopen('Param_Mapping.edp', 'w');
                fprintf(fid, '// Parameters for complex mapping (file generated by matlab driver)\n');
                fprintf(fid, ['real ParamMapx0 = ', num2str(MappingParams(1)), ' ;']);
                fprintf(fid, ['real ParamMapx1 = ', num2str(MappingParams(2)), ' ;']);
                fprintf(fid, ['real ParamMapLA = ',  num2str(MappingParams(3)), ' ;']);
                fprintf(fid, ['real ParamMapLC = ', num2str(MappingParams(4)), ' ;']);
                fprintf(fid, ['real ParamMapGC = ',  num2str(MappingParams(5)), ' ;']);
                fprintf(fid, ['real ParamMapyo = ', num2str(MappingParams(6)), ' ;']);
                fprintf(fid, ['real ParamMapLAy = ',  num2str(MappingParams(7)), ' ;']);
                fprintf(fid, ['real ParamMapLCy = ', num2str(MappingParams(8)), ' ;']);
                fprintf(fid, ['real ParamMapGCy = ',  num2str(MappingParams(9)), ' ;']);
                fclose(fid);
 
    end
    end
end