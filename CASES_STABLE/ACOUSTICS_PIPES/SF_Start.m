global ff ffdir ffdatadir sfdir verbosity



if(isunix)
    ff =  '/usr/local/bin/FreeFem++';   % on most systems, including the server AZTECA (UPS)
    %ff = '/PRODCOM/FREEFEM/Ubuntu12.04/3.29/bin/FreeFem++-nw'; % on IMFT network
end

if(ismac)
    ff =  '/usr/local/bin/FreeFem++'; % on most mac instalations
    %ff = '/usr/local/ff++/openmpi-2.1/3.55/bin/FreeFem++-nw'; % on DF's macbookpro 
end
   

if(ispc)
    ff = 'launchff++'; % for windows systems
end


ffdatadir = './';
%sfdir = '/Users/dfabre/StabFem/SOURCES_MATLAB/'; % where to find the matlab drivers
sfdir = './';
ffdir = './'; % where to find the freefem scripts
verbosity = 5;
%addpath(sfdir);
%if(exist(ffdatadir)~=7)
%    mysystem(['mkdir ' ffdatadir]);
%end
mysystem(['echo "// File automatically created by StabFem" > SF_Geom.edp']); 
% a file SF_Geom should be present, even if blank 