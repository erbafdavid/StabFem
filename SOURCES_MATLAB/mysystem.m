
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
%global parameter verbosity will control the verbosity : 
% verbosity<10 : quiet mode (output from Freefem++ is not displayed unless error)
% verbosity=>10 : verbose mode (output from Freefem++ is displayed)
%
% This function is part of the StabFem project distributed under gnu
% licence, copyright D. Fabre (2017-2018).


if(nargin==1)
    errormessage=['mysystem Error while calling ',command];
end
    

if(verbosity<10) % quiet mode
[status,result]=system(command);
    if(status~=0)&&(status~=141)&&(status~=13)&&(strcmp(errormessage,'skip')==0)   
    % NB if successful matlab retunrs 0, Octave returns 141, sometimes 13
        result
        error(errormessage);
    end
else % verbose mode
 disp('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$');
 disp('$$ ENTERING FREEFEM++ :')
 disp('$$ ');
 disp(['$$ > ' command ]);
 disp('$$ ');
 [status]=system(command);
 disp('$$ ');
 disp('$$ LEAVING FREEFEM++ :')
 disp('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$');
    if(status~=0)&&(status~=141)&&(status~=13)&&(strcmp(errormessage,'skip')==0)
        error(errormessage);
    end   
end
