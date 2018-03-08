global ff ffdir ffdatadir sfdir verbosity
%ff = '/PRODCOM/FREEFEM/Ubuntu12.04/3.29/bin/FreeFem++-nw'; % on IMFT network
%ff = '/usr/local/ff++/openmpi-2.1/3.55/bin/FreeFem++-nw'; % on DF's macbookpro 
ff =  '/usr/local/bin/FreeFem++' % on the server AZTECA (UPS)
ffdatadir = './';
%sfdir = '/Users/dfabre/StabFem/SOURCES_MATLAB/'; % where to find the matlab drivers
sfdir = './';
ffdir = './'; % where to find the freefem scripts
verbosity = 5;
%addpath(sfdir);
%if(exist(ffdatadir)~=7)
%    mysystem(['mkdir ' ffdatadir]);
%end
mysystem(['echo "// File automatically created by StabFem" > SF_Geom.edp']); % a file SF_Geom should be present, even if blank 