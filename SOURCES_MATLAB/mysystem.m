
function status=mysystem(command,errormessage);
global ff ffdir ffdatadir sfdir verbosity

%%% system command managements of StabFem.
%
% usage : 
% status=mysystem(command,errormessage);
%   -> execute the command ; displays the errormessage if fails
%   special cases : 
%    mysystem(command) -> will generate errormessage automatically 
%    mysystem(command,'skip') -> will ignore the error and continue
%                       (useful for cp/mv/rm file manipulations)
%
%global parameter verbosity will manage the verbosity


if(nargin==1)
    errormessage=['mysystem Error while calling ',command];
end
    

if(verbosity<=10) % quiet mode
[status,result]=system(command);
    if(status~=0)&&(strcmp(errormessage,'skip')==0)  
        result
        error(errormessage);
    end
else % verbose mode
 [status]=system(command);
    if(status~=0)&&(strcmp(errormessage,'skip')==0)
        error(errormessage);
    end   
end
