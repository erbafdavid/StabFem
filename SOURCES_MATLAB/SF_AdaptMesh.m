function [Field1New,Field2New,Field3New] = SF_AdaptMesh(varargin)
% 
% This is part of StabFem Project, version 2.1, D. Fabre, July 2017
% Generalized in July 2018, J. Sierra.
% Matlab driver for Adapting Mesh 
%
% usage : [Field1New,Field2New,Field3New] = SF_Adapt(nFields,Field1,{Field2},
%          {Field3},{TypeField1},{TypeField2},{TypeField3},{Hmax},{Hmin}
%          {rr},{Ratio},{InterpError},{Splitin2})
%
% Parameters between {} are optional
% 
%
% In the current version the user may select between 1 to 3 generic Fields
% Theu user may selected between the following types of FEM spaces
%
%   type = "ReP2P2P1" -> Real P2xP2xP1 data (for instance 2D base flow)
%   type = "CxP2P2P1" -> Complex P2xP2xP1 data (for instance 2D mode or 2D base flow with complex mapping)
%   type = "ReP2P2P2P1" -> Real P2xP2xP2xP1 data (for instance 3D base flow)
%   type = "CxP2P2P2P1" -> Complex P2xP2xP2xP1 data (for instance 3D mode or 3D base flow with complex mapping)
%   type = "ReP2P2P1P1" -> Real P2xP2xP1xP1 data (for instance 2D base flow with extra scalar)
%   type = "CxP2P2P1P1" -> Complex P2xP2xP1xP1 data (for instance 2D mode or 2D base flow with complex mapping with an extra scalar)
%   type = "ReP2P2P1P1P1" -> Real P2xP2xP1xP1xP1 data (for instance 2D compressible base flow)
%   type = "CxP2P2P1P1P1" -> Complex P2xP2xP1xP1xP1 data (for instance 2D compressible mode or 2D compressible base flow with complex mapping)
%
%
% Note: The baseflow should be included in Field1
% If baseflow is included in Field1, then the base flow will be recomputed 
% on the adapted mesh
%
%
% Version 2.2 by J. Sierra, 16 july 2018


%> @file SOURCES_MATLAB/SF_AdaptMesh.m
%> @brief StabFem wrapper for mesh adaption based on some FreeFem fields
%>
%> @param[in] Field_i: Field used to generate a mesh adaptation
%> @param[in] varargin: list of parameters and associated values
%> @param[out] Field_iNew: Interpolated fields in the new mesh
%>
%> usage: <code>[Field1New,Field2New,Field3New] = SF_Adapt(Field1,{Field2},
%          {Field3},{TypeField1},{TypeField2},{TypeField3},'Hmax',5,...) </code>
%>
%> Note: Parameters between {} are optional
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


global ff ffdir ffdatadir sfdir verbosity

% managament of optional parameters
p = inputParser;
for i = [1:3]
    if(isstruct(varargin{i}))
        nFields=i;
    end
end

if(nFields<1)
    disp('Error, you should enter at least a field')
end

if(nFields==1)
    % input mode for adaptation to Field1
    Field1=varargin{1};
    vararginopt={varargin{2:end}};
elseif(nFields == 2)
    % input mode for adaptation to Field1,Field2
    Field1=varargin{1};
    Field2=varargin{2};
    vararginopt={varargin{3:end}};
elseif(nFields == 3)
    % input mode for adaptation to Field1,Field2
    Field1=varargin{1};
    Field2=varargin{2};
    Field3=varargin{3};
    vararginopt={varargin{4:end}};
end

addParameter(p,'Hmax',10);
addParameter(p,'Hmin',1e-4);
addParameter(p,'Ratio',10.);               	
addParameter(p,'InterpError',1e-2);			
addParameter(p,'rr',0.95);
addParameter(p,'Splitin2',0); 
parse(p,vararginopt{:});
    

%%% Writing parameter file for Adapmesh
fid = fopen('Param_Adaptmesh.edp','w');
fprintf(fid,'// Parameters for adaptmesh (file generated by matlab driver)\n');
fprintf(fid,['real Hmax = ',num2str(p.Results.Hmax),' ;']);
fprintf(fid,['real Hmin = ',num2str(p.Results.Hmin),' ;']);
fprintf(fid,['real Ratio = ',num2str(p.Results.Ratio),' ;']);
fprintf(fid,['real error = ',num2str(p.Results.InterpError),' ;']);
 fprintf(fid,['real rr = ',num2str(p.Results.rr),' ;']);
if(p.Results.Splitin2==0)
    fprintf(fid,['bool Splitin2 = false ;']);
else
    fprintf(fid,['bool Splitin2 = true ;']);
end
fclose(fid);

disp(' '); 

% Copy Field files to Fieldi_toadapt
mycp([Field1.filename],[ffdatadir 'FlowFieldToAdapt0.txt']);
if(nFields == 3)
    mycp([Field2.filename],[ffdatadir 'FlowFieldToAdapt1.txt']);
    mycp([Field3.filename],[ffdatadir 'FlowFieldToAdapt2.txt']);
elseif(nFields == 2)
    mycp([Field2.filename],[ffdatadir 'FlowFieldToAdapt1.txt']);
    % We add it only to avoid issues with FF code
    mycp([Field1.filename],[ffdatadir 'FlowFieldToAdapt2.txt']);
else
    mycp([Field1.filename],[ffdatadir 'FlowFieldToAdapt1.txt']);
    mycp([Field1.filename],[ffdatadir 'FlowFieldToAdapt2.txt']);
    disp('Only a field is chosen for mesh adaptation');
end
mycp([ffdatadir 'mesh.msh'],[ffdatadir 'meshToAdapt.msh']);

% Command to call FreeFem to adapt the Fields
if (nFields==3)
    command = ['echo ',Field1.datastoragemode,' ',Field2.datastoragemode,' ',...
               Field3.datastoragemode,' ','| ',ff,' ',ffdir,'AdaptMesh.edp']; 
elseif(nFields==2)
    command = ['echo ',Field1.datastoragemode,' ',Field2.datastoragemode,' ',...
               'None',' ','| ',ff,' ',ffdir,'AdaptMesh.edp']; 
elseif(nFields==1)
    command = ['echo ',Field1.datastoragemode,' ','None',' ',...
               'None',' ','| ',ff,' ',ffdir,'AdaptMesh.edp']; 
end
error = 'ERROR : FreeFem adaptmesh aborted';
% Launch FreeFem
mysystem(command,error);

% Copy interpolated files to the original paths
mycp([ffdatadir 'meshAdapted.msh'],[ffdatadir 'mesh.msh']);
mycp([ffdatadir 'meshAdapted.ff2m'],[ffdatadir 'mesh.ff2m']);
mycp([ffdatadir 'FlowFieldAdapted0.txt'],[Field1.filename]);
if(nFields == 3)
    mycp([ffdatadir 'FlowFieldAdapted1.txt'],[Field2.filename]);
    mycp([ffdatadir 'FlowFieldAdapted2.txt'],[Field3.filename]);
elseif(nFields == 2)
    mycp([ffdatadir 'FlowFieldAdapted1.txt'],[Field2.filename]);
end

meshnp = importFFmesh('mesh.msh','nponly');
disp(['      ### ADAPT mesh to input fields ' ...% for Re = ' num2str(baseflow.Re)... 
      ' ; InterpError = ' num2str(p.Results.InterpError) '  ; Hmax = ' num2str(p.Results.Hmax) ])  

% Field1 in  the new mesh
Field1New = Field1;
Field1New.mesh=importFFmesh([ffdatadir 'mesh.msh']);

%Copy Fieldi to guess and set Fieldi new mesh
if(nFields == 3)
    mycp([ffdatadir 'FlowFieldAdapted1.txt'],[ffdatadir Field2.datatype '_guess.txt']);
    Field2New = Field2;
    Field2New.mesh=importFFmesh([ffdatadir 'mesh.msh']);
    mycp([ffdatadir 'FlowFieldAdapted2.txt'],[ffdatadir Field3.datatype '_guess.txt']);
    Field3New = Field3;
    Field3New.mesh=importFFmesh([ffdatadir 'mesh.msh']);
elseif(nFields == 2)
    mycp([ffdatadir 'FlowFieldAdapted1.txt'],[ffdatadir Field2.datatype '_guess.txt']);
    Field2New = Field2;
    Field2New.mesh=importFFmesh([ffdatadir 'mesh.msh']);
end

if(verbosity>=1)
  meshinfo = importFFdata(Field1New.mesh,'mesh.ff2m');
  disp(['      #   Number of points np = ',num2str(meshinfo.np), ...
        ' ; Ndof = ', num2str(meshinfo.Ndof)]);
  disp(['      #  h_min, h_max : ',num2str(meshinfo.deltamin), ' , ',...
        num2str(meshinfo.deltamax)]);    
end
   
    % recomputing base flow after adapt
    if(Field1.datatype == 'BaseFlow')
        mycp([ffdatadir 'FlowFieldAdapted0.txt'],[ffdatadir 'BaseFlow_guess.txt']);
        Field1New = SF_BaseFlow(Field1New,'Re',Field1.Re,'type','NEW');
        if(Field1New.iter>0)
            disp('Newton iteration has been completed');
        else % Newton has probably diverged : revert to previous mesh/baseflow
            mymv([ffdatadir 'mesh_ans.msh'],[ffdatadir 'mesh.msh']);
            mymv([ffdatadir 'BaseFlow_ans.txt'],[ffdatadir 'BaseFlow_guess.txt']);
            error(' ERROR in SF_Adapt : recomputing base flow failed, going back to baseflow/mesh') 
        end
    else
        if(Field1.datatype == 'EigenmodeD' || Field1.datatype == 'EigenmodeA')
            disp('Eigenmode fields are not set to guess');
        else
            mycp([ffdatadir 'FlowFieldAdapted0.txt'],[ffdatadir Field0.datatype '_guess.txt']);
        end
    end
    
    % Delete temporal files
    myrm([ffdatadir '*_ans.* ']);
    myrm([ffdatadir '*ToAdapt.* ']);
    myrm([ffdatadir '*Adapted.* ']);
end

