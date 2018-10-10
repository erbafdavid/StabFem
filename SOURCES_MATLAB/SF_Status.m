function [] = SF_Status(type);
%>
%> This function allows to generate a useful summary of data present in the
%> working directories.
%> This can be useful to reconstruct structures from available data files,
%> for instance if you did a 'clear all' but data files are still present... 
%>
%> USAGE :
%> 1. SF_Status('MESHES')
%>  -> check the content of folder ffdatadir/MESHES
%>      (meshes available and corresponding baseflows)
%>
%> 2. SF_Status('BASEFLOWS')
%>  -> check the content of folder ffdatadir/BASEFLOWS
%>      (baseflows compatible with the current mesh)
%>
%> 3. SF_Status('MEANFLOWS')
%>  -> check the content of folder ffdatadir/MEANFLOWS
%>      (baseflows compatible with the current mesh)
%>
%> 4. SF_Status('DNSFLOWS')
%>  -> check the content of folder ffdatadir/BASEFLOWS
%>      (baseflows compatible with the current mesh)
%>
%> 5. SF_Status()  [ or SF_Status('ALL') ]
%>  -> check all subfolders of ffdatadir
%>
%>
%>
%> NB this functions uses nestedSortStruct and SortStruct taken from
%> mathworks (to sort the files by dates)
%>


global ff ffdir ffdatadir sfdir verbosity

if(nargin==0)
    type = 'all';
end


if (strcmp(lower(type),'meshes') + strcmp(lower(type),'all') )
    disp('#################################################################################');
    disp(' ');
    disp(' ');
    disp(['.... CONTENT OF DIRECTORY ', ffdatadir, 'MESHES :']);
    disp('     (list of meshes previously created/adapted ; couples of .msh/.ff2m files )');
    disp(' ');
    disp('Name                      | Date                 | Nv (nb of vertices)'); %| (Number of vertices) ');
    meshdir = dir([ffdatadir, 'MESHES/*.msh']);
    if(length(meshdir)>0)
        meshdir = nestedSortStruct(meshdir, 'datenum');
        for i = 1:length(meshdir)
            name = meshdir(i).name;
            date = meshdir(i).date;
            fid = fopen([ffdatadir, 'MESHES/', name], 'r');
            headerline = textscan(fid, '%f %f %f', 1, 'Delimiter', '\n');
            nv = headerline{1};
            nt = headerline{2};
            ns = headerline{3};
            disp([name, blanks(25-length(name)), ' | ', date, blanks(20-length(date)), ' | ', num2str(nv)]);
        end
    end
    
    disp(' ');
    disp(' ');
    disp('     (list of base flows associated to newly computed meshes ; couples of .txt/.ff2m files )');
    disp(' ');
    disp('Name                      | Date                 | Size (bytes) '); %| (Number of vertices) ');
    meshdir = dir([ffdatadir, 'MESHES/*.txt']);
    if(length(meshdir)>0)
        meshdir = nestedSortStruct(meshdir, 'datenum');
        for i = 1:length(meshdir)
            name = meshdir(i).name;
            date = meshdir(i).date;
            disp([name, blanks(25-length(name)), ' | ', date, blanks(20-length(date)), ' | ', num2str(meshdir(i).bytes)]);
        end
          
        disp(' ');
        disp(' ');
        disp(' REMINDER : PROCEDURE TO RECOVER A PREVIOUSLY COMPUTED MESH/BASEFLOW')
        disp('    type succesfully the two following commands (to be adapted for your case...) :');
        disp(' ');
        disp('    ffmesh = importFFmesh(''./WORK/MESHES/mesh_adapt_Re100.msh'')');
        disp('    bf = importFFdata(ffmesh,''./WORK/MESHES/BaseFlow_adapt_Re100.ff2m'')');
        disp(' ');
        disp(' ');
    end
end

if(strcmp(lower(type),'baseflows')+strcmp(lower(type),'all'))
    disp('#################################################################################');
    disp(' ');
    disp(' ');
    disp(' ');
    disp(['.... CONTENT OF DIRECTORY ', ffdatadir, 'BASEFLOWS']);
    disp('     (list of base flows compatible with current mesh ; couples of .txt/.ff2m files )');
    disp(' ');
    disp('Name                      | Date                 | Size ');
    meshdir = dir([ffdatadir, 'BASEFLOWS/*.txt']);
    
    if(length(meshdir)>0)
        meshdir = nestedSortStruct(meshdir, 'datenum');    
        for i = 1:length(meshdir)
            name = meshdir(i).name;
            date = meshdir(i).date;
            disp([name, blanks(25-length(name)), ' | ', date, blanks(20-length(date)), ' | ', num2str(meshdir(i).bytes)]);
        end
        
        disp(' ');
        disp(' ');
        disp(' REMINDER : PROCEDURE TO RECOVER A PREVIOUSLY COMPUTED BASEFLOW')
        disp('    type succesfully the three following commands (to be adapted for your case...) :');
        disp(' ');
        disp('    ffmesh = importFFmesh(''./WORK/mesh.msh''); bf = importFFdata(ffmesh,''./WORK/BASEFLOWS/BaseFlow_Re100.ff2m'')');
        disp('    bf = SF_BaseFlow(bf)');
        disp(' ');
        disp(' ');
    end
end


if(strcmp(lower(type),'meanflows')+strcmp(lower(type),'all'))
    disp('#################################################################################');
    disp(' ');
    disp(' ');
    disp(' ');
    disp(['.... CONTENT OF DIRECTORY ', ffdatadir, 'MEANFLOWS']);
    disp('     (list of meanflow/nonlinear HB components compatible with current mesh ; couples of .txt/.ff2m files )');
    disp(' ');
    disp('Name                      | Date                 | Size ');
    
    meshdir = dir([ffdatadir, 'MEANFLOWS/*.ff2m']);
    if(length(meshdir)>0)
        meshdir = nestedSortStruct(meshdir, 'datenum');
        
        
        for i = 1:length(meshdir)
            name = meshdir(i).name;
            date = meshdir(i).date;
            disp([name, blanks(25-length(name)), ' | ', date, blanks(20-length(date)), ' | ', num2str(meshdir(i).bytes)]);
        end
        
        disp(' ');
        disp(' ');
        disp(' REMINDER : PROCEDURE TO RECOVER A PREVIOUSLY COMPUTED MEANFLOW / HB1 ')
        disp('    type succesfully the three following commands (to be adapted for your case and use a similar format for HB2...) :');
        disp(' ');
        disp('    ffmesh = importFFmesh(''./WORK/mesh.msh'')');
        disp('    bf = importFFdata(ffmesh,''./WORK/MEANFLOW/MeanFlow_Re100.ff2m'')');
        disp('    mode = importFFdata(ffmesh,''./WORK/MEANFLOW/SelfConsistentMode_Re100.ff2m'')');
        disp('    [bf,mode] = SF_HB1(bf,mode)');
        disp(' ');
        disp(' ');
    end
end

if(strcmp(lower(type),'dnsfield')+strcmp(lower(type),'all'))
    disp('#################################################################################');
    disp(' ');
    disp(' ');
    disp(' ');
    disp(['.... CONTENT OF DIRECTORY ', ffdatadir, 'DNSFIELDS']);
    disp('     (list of DNS Snapshots compatible with current mesh ; couples of .txt/.ff2m files )');
    disp(' ');
    disp('Name                      | Date                 | Size ');
    
    meshdir = dir([ffdatadir, 'DNSFIELDS/*.ff2m']);
    if(length(meshdir)>0)
        meshdir = nestedSortStruct(meshdir, 'datenum');
        
        
        for i = 1:length(meshdir)
            name = meshdir(i).name;
            date = meshdir(i).date;
            disp([name, blanks(25-length(name)), ' | ', date, blanks(20-length(date)), ' | ', num2str(meshdir(i).bytes)]);
        end
        
        disp(' ');
        disp(' ');
        disp(' REMINDER : PROCEDURE TO RECOVER A PREVIOUSLY COMPUTED MEANFLOW / HB1 ')
        disp('    type succesfully the three following commands (to be adapted for your case and use a similar format for HB2...) :');
        disp(' ');
        disp('    ffmesh = importFFmesh(''./WORK/mesh.msh'')');
        disp('    bf = importFFdata(ffmesh,''./WORK/MEANFLOW/MeanFlow_Re100.ff2m'')');
        disp('    mode = importFFdata(ffmesh,''./WORK/MEANFLOW/Harmonic1_Re100.ff2m'')');
        disp('    [bf,mode] = SF_HB1(bf,mode)');
        disp(' ');
        disp(' ');
    end
end

disp(' ');
disp('#################################################################################');
disp(' ');

end %function
