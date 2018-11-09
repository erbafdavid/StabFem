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
bf = SmartMesh_L6();

%disp(['Test 1 : Drag : ', bf.Cx]);
CxREF = 3.2618;

error1 = abs(bf.Cx/CxREF-1)

if(error1>1e-3) 
    value = value+1 
end

if(isfigures>0)
    figure;plotFF(bf,'ux','contour','on','clevels',[0,0]);  %
    pause(0.1);
    saveas(gcf,'FIGURES/BluntBody_L6_D2_BaseFlow','png');
    pos = get(gcf,'Position'); pos(4)=pos(3)*.25;set(gcf,'Position',pos); % resize aspect ratio
end


%% Test 2 : eigenvalues 
[ev,em] = SF_Stability(bf,'m',1,'shift',.2+0.3i,'nev',20,'type','D','plotspectrum','yes');   

evREF = [     0.0501 + 0.6574i 0.2425 + 0.0000i ]

error2 = abs(ev(1)/evREF(1)-1)+abs(ev(2)/evREF(2)-1);

if(error2>1e-3) 
    value = value+1 
end

if(isfigures>0)
    figure;
    subplot(2,1,1);plotFF(em(2),'ux1','colormap','redblue');title('Blunt body : steady mode')
    subplot(2,1,2);plotFF(em(1),'ux1','colormap','redblue');title('Blunt body : unsteady mode')
    saveas(gcf,'FIGURES/BluntBody_L6_D2_Modes','png');
    pos = get(gcf,'Position'); pos(4)=pos(3)*.5;set(gcf,'Position',pos); % resize aspect ratio
    
    figure(100);
    saveas(gcf,'FIGURES/BluntBody_L6_D2_SpectrumExplorator','png');
    
    pause(0.1);
end

 
if(isfigures>1)
%% COMPUTING THE UNSTEADY BRANCH (going backwards)
Re_RangeI = [500:-20:300];
guessI = 0.04+0.657i;
figure(10);hold on;
[EVI,Res,omegas] = SF_Stability_LoopRe(bf,Re_RangeI,guessI,'plot','r');
disp([' Unsteady branch : threshold detected at Re = ',num2str(Res),' ; omega = ',num2str(omegas) ]);

               
%% COMPUTING THE STEADY BRANCH (going backwards)
Re_RangeS = [500:-50:300 280 :-20:160];
guessS = 0.246;
figure(10);hold on;
[EVS,Res,omegas] = SF_Stability_LoopRe(bf,Re_RangeS,guessS,'plot','b');
disp([' Steady branch : threshold detected at Re = ',num2str(Res),' ; omega = ',num2str(omegas) ]);

  
      
%% FIGURES
figure(10);hold on;
subplot(2,1,1);hold on;
%plot(Re_RangeS,real(EVS),'-b',Re_RangeI,real(EVI),'-r');hold on;
%plot(Re_RangeS,0*real(EVS),':k');%axis
title('growth rate lambda_r vs. Reynolds ; unstready mode (red) and steady mode (blue)')
subplot(2,1,2);hold on;
%plot(Re_RangeS,imag(EVS),'-b',Re_RangeI,imag(EVI),':r',Re_RangeI(real(EVI)>0),imag(EVI(real(EVI)>0)),'r-')
title('oscillation rate lambda_i vs. Reynolds')
suptitle('Leading eigenvalues of a blunt body with L/d=6; D/d=2');
saveas(gcf,'FIGURES/BluntBody_L6_D2_Eigenvalues','png');

pause(0.1);
end

end
