global ff ffMPI ffdir ffdatadir sfdir verbosity 

% TODO : David We need to define a global variable in windows and unix
% for ff-mpirun (or equivanlent)
% THE ROLE OF THIS FUNCTION IS TO POSITION THE following global variables :
% ff -> adress with full path of the FreeFem++ executable
% ffdir -> path of the FreeFem sources of the project
% sfdir -> path of the Matlab sources of the project 
% ffdatadir -> path where to store the results (recommended is ./WORK) 

if(isunix)
% ff = '/PRODCOM/FREEFEM/Ubuntu12.04/3.29/bin/FreeFem++-nw'; % on IMFT network
ff = 'FreeFem++-nw';
ffMPI = 'ff-mpirun';
end
if(ismac)
ff = '/usr/local/bin/FreeFem++ -nw';
ffMPI = 'ff-mpirun';
% NB normally this is where the FreeFem++ executable should be on a mac.
% If not the case, either do a symbolic link (recommended) or replace with
% the right one. option "-nw" is better to discard the ff++ graphical output. 
% below are possible choices for various contributors :
%ff = '/usr/local/ff++/openmpi-2.1/3.60/bin/FreeFem++'; % old syntax for David
%ff = '/usr/local/ff++/bin/FreeFem++ -nw'; for Flavio
end
if(ispc)
    ff = 'launchff++'; % for windows systems
    ffMPI = '';
end


sfdir = '/home/jsagg/Sources/StabFem/SOURCES_MATLAB/'; 
ffdir = '/home/jsagg/Sources/StabFem/SOURCES_FREEFEM/';

% This is the recommended implementation on most systems. 
% In case StabFem is not in your root directory you may adapt. Bellow a few
% examples from various contributors.

%sfdir = '/Users/flavio/StabFem/SOURCES_MATLAB/'; % where to find the matlab drivers
%ffdir = '/Users/flavio/StabFem/SOURCES_FREEFEM/'; % where to find the freefem scripts

%sfdir = '/Users/fabred/StabFem/SOURCES_MATLAB/'; % where to find the matlab drivers
%ffdir = '/Users/fabred/StabFem/SOURCES_FREEFEM/'; % where to find the freefem scripts

ffdatadir = './WORK/';

verbosity = 1;
addpath(sfdir);
if(exist(ffdatadir)~=7)
    mysystem(['mkdir ' ffdatadir]);
end
mysystem(['echo "// File automatically created by StabFem" > SF_Geom.edp']); % a file SF_Geom should be present, even if blank 
