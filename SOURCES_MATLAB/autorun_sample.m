function value = autorun(isfigures);
% Autorun function for StabFem. 
% This function will produce sample results for the case BLUNTBODY_IN_PIPE
%
% USAGE : 
% autorun(0) -> automatic check
% autorun(1) -> produces the figures used for the manual
% autorun(2) -> may produces "bonus" results...
%%
close all;
run('../../SOURCES_MATLAB/SF_Start.m');verbosity=10;
system('mkdir FIGURES');
figureformat = 'png';

if(nargin==0) 
    isfigures=0; verbosity=0;
end;
value =0;

%% Test 1 : base flow
bf = SmartMesh;

CxREF = 3.2618;
error = abs(bf.Cx/CxREF-1)

if(error>1e-3) 
    value = value+1 
end

if(isfigures>0)
    figure;plotFF(bf,'ux','contour','on','clevels',[0,0]);  %
    pause(0.1);
    saveas(gcf,'FIGURES/Example_BaseFlow','png');
    pos = get(gcf,'Position'); pos(4)=pos(3)*.5;set(gcf,'Position',pos); % to resize aspect ratio : pos(3) is height, pos(4) is width
end


end
