
global ff ffMPI ffdir ffdatadir sfdir verbosity

%> THE ROLE OF THIS SCRIPT IS TO POSITION THE following global variables :
%> ff -> adress with full path of the FreeFem++ executable
%> ffdir -> path of the FreeFem sources of the project 
%>           (recommened is ~/StabFem/SOURCES_FREEFEM)
%> sfdir -> path of the OCTAVE/Matlab sources of the project
%>           (recommened is ~/StabFem/SOURCES_MATLAB)
%> ffdatadir -> path where to store the results 
%>           ( recommended is ./WORK)
%> verbosity -> global variable controlling the volume of messages produced by the programs
%>           ( recommended : 1 in stable mode ; 100 in debug mode...)

verbosity = 1;


%% Adress of the executable :
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

%% Directories where to find the programs :
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

%% Directory where to put working files
ffdatadir = './WORK/';

%In case not already present, we create the ffdatadir folder and a few useful subfolders:

if(exist(ffdatadir)~=7)
    mymake(ffdatadir);
end
if(exist([ffdatadir 'MESHES'])~=7)
    mymake([ffdatadir 'MESHES']);
end
if(exist([ffdatadir 'BASEFLOWS'])~=7)
    mymake([ffdatadir 'BASEFLOWS']);
end
if(exist([ffdatadir 'MEANFLOWS'])~=7)
    mymake([ffdatadir 'MEANFLOWS'])
end
exist([ffdatadir 'DNSFIELDS'])
if(exist([ffdatadir 'DNSFIELDS'])~=7)
    mymake([ffdatadir 'DNSFIELDS'])
end


%%
mysystem(['echo "// File automatically created by StabFem" > SF_Geom.edp']);
% a file SF_Geom should be present, even if blank 
% (this line is here for retrocompatibility,  not sure it is still userul...)
