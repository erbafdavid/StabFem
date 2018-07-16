
global ff ffMPI ffdir ffdatadir sfdir verbosity

% TODO : David We need to define a global variable in windows and unix
% for ff-mpirun (or equivanlent)
% THE ROLE OF THIS FUNCTION IS TO POSITION THE following global variables :
% ff -> adress with full path of the FreeFem++ executable
% ffdir -> path of the FreeFem sources of the project
% sfdir -> path of the Matlab sources of the project
% ffdatadir -> path where to store the results (recommended is ./WORK)

if (isunix)
    %ff = '/usr/local/bin/FreeFem++ -v 0'; % on most systems
    ff = '/PRODCOM/Ubuntu16.04/freefem/3.55/gcc-5.4-mpich_3.2/bin/FreeFem++ -v 0'; % on IMFT network
    ffMPI = '/PRODCOM/Ubuntu16.04/freefem/3.55/gcc-5.4-mpich_3.2/bin/ff-mpirun -v 0';
end
if (ismac)
    ff = '/usr/local/bin/FreeFem++ -v 0';
    ffMPI = '/usr/local/bin/ff-mpirun';
    
    % NB normally this is where the FreeFem++ executable should be on a mac.
    % If not the case, either do a symbolic link (recommended) or replace with
    % the right one. option "-nw" is better to discard the ff++ graphical output.
    % below are possible choices for various contributors :
    %ff = '/usr/local/ff++/openmpi-2.1/3.60/bin/FreeFem++'; % old syntax for David
    %ff = '/usr/local/ff++/bin/FreeFem++'; for Flavio
end
if (ispc)
    ff = 'FreeFem++ -nw -v 0 -nw'; % for windows systems
    ffMPI = 'ffm-mpirun -v 0 -nw';
end

sfdir = '~/StabFem/SOURCES_MATLAB/';
ffdir = '~/StabFem/SOURCES_FREEFEM/';


% This is the recommended implementation on most systems.
% In case StabFem is not in your root directory you may adapt. Bellow a few
% examples from various contributors.

%sfdir = '/Users/flavio/StabFem/SOURCES_MATLAB/'; % where to find the matlab drivers
%ffdir = '/Users/flavio/StabFem/SOURCES_FREEFEM/'; % where to find the freefem scripts

%sfdir = '/Users/fabred/StabFem/SOURCES_MATLAB/'; % where to find the matlab drivers
%ffdir = '/Users/fabred/StabFem/SOURCES_FREEFEM/'; % where to find the freefem scripts

%sfdir = '/home/jsagg/Sources/StabFem/SOURCES_MATLAB/';
%ffdir = '/home/jsagg/Sources/StabFem/SOURCES_FREEFEM/';

addpath(sfdir);


ffdatadir = './WORK/';

verbosity = 1;

% if(exist(ffdatadir)~=7)
%     mysystem(['mkdir ' ffdatadir]);
% end
% mysystem(['echo "// File automatically created by StabFem" > SF_Geom.edp']); % a file SF_Geom should be present, even if blank
