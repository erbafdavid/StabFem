global ff ffdir ffdatadir sfdir verbosity
%ff = '/PRODCOM/FREEFEM/Ubuntu12.04/3.29/bin/FreeFem++-nw'; % on IMFT network
ff = '/usr/local/ff++/openmpi-2.1/3.55/bin/FreeFem++-nw'; % on DF's macbookpro 
ffdatadir = './WORK/';
sfdir = '/Users/dfabre/StabFem/SOURCES_MATLAB/'; % where to find the matlab drivers
ffdir = '/Users/dfabre/StabFem/SOURCES_FREEFEM/'; % where to find the freefem scripts
verbosity = 1;
addpath(sfdir);
if(exist(ffdatadir)~=7)
    mysystem(['mkdir ' ffdatadir]);
end
mysystem(['echo "// File automatically created by StabFem" > SF_Geom.edp']); % a file SF_Geom should be present, even if blank 