function [DNSstats,DNSfields] = SF_DNS(varargin)
%>
%> This is part of StabFem Project, D. Fabre, July 2017 -- present
%> Matlab driver for DNS
%>
%> USAGE :
%>    [DNSstats,DNSfields] = SF_DNS(DNS_Start,'Re',Re,'dt',dt,'itmax',itmax,[...])
%>    
%>  INPUT PARAMETERS : 
%>      DNS_Start is either a baseflow/meanflow or a previous DNS result
%>
%> RESULTS :
%>    DNSstats : arrays containing time statistics 
%>               (history of lift,drag, or other customisable statistics)
%>
%>    DnsFields : array(N) of fields produced each iout time steps
%>
%> NB improved mode to compute meanflow by timeaveraging in three-output mode
%> [DNSstats,DNSfields,meanflow] = SF_DNS(....)
%> To immplement ? Diogo ??

global ff ffdir ffdatadir sfdir verbosity

mkdir('./WORK/DNSFIELDS/');

startfield = varargin{1};
ffmesh = startfield.mesh;
vararginopt = {varargin{2:end}};

p = inputParser;
addParameter(p, 'Re', 100);
addParameter(p, 'rep',0);
addParameter(p, 'itmax', 0); % max step number
addParameter(p, 'Nit',1000 ); %  number of step
% NB you should provide either itmax or Nit but not both !
addParameter(p, 'dt', 5e-3);
addParameter(p, 'iout', 100);
addParameter(p, 'iplot', 50);
parse(p, vararginopt{:});

startfield.datatype;

switch(startfield.datatype)
    case {'BaseFlow','Meanflow'} 
        rep = 0
        mydisp(1, ['FUNCTION SF_DNS : starting from BF / MF (reset it = 0)']);
         mycp(startfield.filename, [ffdatadir, 'dnsfield_start.txt']);
         myrm([ffdatadir,'dns_Stats_Re',num2str(p.Results.Re),'.ff2m'])
    case 'DNSField'
        rep = startfield.it
        mydisp(1, ['FUNCTION SF_DNS : starting from previous DNS result with it = ', num2str(rep)]);
end

if(p.Results.itmax==0)  
    itmax = rep+p.Results.Nit
else
    itmax = p.Results.itmax
end
mydisp(1, ['         : Time-stepping up to it = ',num2str(itmax) ' ( number of steps = ' num2str(itmax-rep) ' ) ']);
iout = p.Results.iout


mydisp(1, ['FUNCTION SF_DNS : starting from step ',num2str(p.Results.rep)]);
mycp(startfield.mesh.filename, [ffdatadir, 'mesh.msh']);
optionstring = [' ', num2str(p.Results.Re), ' ', num2str(rep), ' ',num2str(itmax), ' ',num2str(p.Results.dt), ' ',num2str(p.Results.iout), ' ', num2str(p.Results.iplot)];

% launch ff++ code

switch (startfield.mesh.problemtype)
    
    case('2D')
command = ['echo ', optionstring, ' | ', ff, ' ',ffdir,'TimeStepper_2D.edp'];
errormessage = 'ERROR : TimeStepper aborted';

  % case("your case...")
        % add your case here !
        
    case default
        error(['Error in SF_HB2 : your case ', meanflow.mesh.problemtype 'is not yet implemented....'])
        
end

status = mysystem(command, errormessage);

%%% GENERATE RESULTS : an array of "DNSflow structures each iout steps
    for i=1:(itmax-rep)/iout
        DNSfields(i) = importFFdata(ffmesh,[ffdatadir ,'DNSFIELDS/dnsfield_',num2str(rep+i*iout),'.ff2m']);
    end

    DNSstats = importFFdata([ffdatadir,'dns_Stats_Re',num2str(p.Results.Re),'.ff2m']);
    
end