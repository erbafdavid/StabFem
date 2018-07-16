function [] = MeshStatus();

% This function allows to check the number of Meshes/Baseflows present in
% the current arborescence. This can be useful to reconstrucy structures
% from available data sets.
%
% NB this functions uses nestedSortStruct and SortStruct taken from
% mathworks (to sort the files by dates)

global ff ffdir ffdatadir sfdir verbosity


disp(' ');
disp(' ');
disp(['.... CONTENT OF DIRECTORY ', ffdatadir, 'MESHES :']);
disp('     (list of meshes previously created/adapted ; couples of .msh/.ff2m files )');
disp(' ');
disp('Name                      | Date                 | Nv (nb of vertices)'); %| (Number of vertices) ');
meshdir = dir([ffdatadir, 'MESHES/*.msh']);
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
disp(' ');
disp('     (list of base flows associated to newly computed meshes ; couples of .txt/.ff2m files )');
disp(' ');
disp('Name                      | Date                 | Size (bytes) '); %| (Number of vertices) ');
meshdir = dir([ffdatadir, 'MESHES/*.txt']);
meshdir = nestedSortStruct(meshdir, 'datenum');
for i = 1:length(meshdir)
    name = meshdir(i).name;
    date = meshdir(i).date;
    disp([name, blanks(25-length(name)), ' | ', date, blanks(20-length(date)), ' | ', num2str(meshdir(i).bytes)]);
end


disp(' ');
disp(' ');
disp(' ');
disp(['.... CONTENT OF DIRECTORY ', ffdatadir, 'BASEFLOWS']);
disp('     (list of base flows compatible with current mesh ; couples of .txt/.ff2m files )');
disp(' ');
disp('Name                      | Date                 | Size ');
meshdir = dir([ffdatadir, 'BASEFLOWS/*.txt']);
meshdir = nestedSortStruct(meshdir, 'datenum');
for i = 1:length(meshdir)
    name = meshdir(i).name;
    date = meshdir(i).date;
    disp([name, blanks(25-length(name)), ' | ', date, blanks(20-length(date)), ' | ', num2str(meshdir(i).bytes)]);
end

disp(' ');
disp(' ');
disp(' REMINDER : PROCEDURE TO RECOVER A PREVIOUSLY COMPUTED MESH/BASEFLOW')
disp('    type succesfully the two following commands :');
disp(' ');
disp('    ffmesh = importFFmesh(''./WORK/MESHES/mesh_adaptRe100.msh'')');
disp('    bf = importFFdata(ffmesh,''./WORK/MESHES/BaseFlow_adaptRe100.ff2m'')');
disp(' ');
disp(' ');


end
