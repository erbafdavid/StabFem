
run('../../SOURCES_MATLAB/SF_Start.m');
verbosity=1;

%% Generation of the base flow

%if(exist('./WORK/BASEFLOW/BaseFlow_Re500.ff2m')==0)
    bf = SmartMesh_L2();
%else
%    ffmesh = importFFmesh('./WORK/mesh.msh');
%    bf = importFFdata(ffmesh,'./WORK/BASEFLOW/BaseFlow_Re500.ff2m');
%    bf = SF_BaseFlow(bf)
%end

% plot the base flow
figure;plotFF(bf,'ux','contour','on','clevels',[0,0]);  %
pause(0.1);


%% Spectrum explorator 
[ev,em] = SF_Stability(bf,'m',1,'shift',.2+0.3i,'nev',20,'type','D','plotspectrum','yes');   
pause(0.1);
 bf.mesh.xlim = [-2 6];
 bf.mesh.ylim = [-1 1];
 figure;
    subplot(2,1,1);plotFF(em(1),'ux1','symmetry','XA','colormap','parula');hold on;title('Blunt body : steady mode')
    subplot(2,1,2);plotFF(em(3),'ux1','symmetry','XA','colormap','parula');hold on;title('Blunt body : unsteady mode')
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*.75;set(gcf,'Position',pos);
saveas(gcf,'FIGURES/BluntBody_L2_D2_Modes','png');
pause(0.1);
 
%% COMPUTING THE UNSTEADY BRANCH (going backwards)
Re_RangeI = [500:-20:300];
guessI =  0.1654 + 0.8358i;
EVI = SF_Stability_Loop(bf,Re_RangeI,guessI);
       
%% COMPUTING THE STEADY BRANCH (going backwards)
Re_RangeS = [500:-50:300 280 :-20:140];
guessS = 0.3;
EVS = SF_Stability_Loop(bf,Re_RangeS,guessS);
      

%% FIGURES
figure(11);
subplot(2,1,1);hold on;
plot(Re_RangeS,real(EVS),'-b',Re_RangeI,real(EVI),'-r');hold on;
plot(Re_RangeS,0*real(EVS),':k');%axis
title('growth rate lambda_r vs. Reynolds ; unstready mode (red) and steady mode (blue)')
subplot(2,1,2);hold on;
plot(Re_RangeS,imag(EVS),'-b',Re_RangeI,imag(EVI),':r',Re_RangeI(real(EVI)>0),imag(EVI(real(EVI)>0)),'r-')
suptitle('Leading eigenvalues of a blunt body with L/d=2; D/d=2');hold on;
saveas(gca,'FIGURES/BluntBody_L2_D2_Eigenvalues','png');


%% Localizing the instability threshold

% [bf,ev] = SF_FindThreshold(bf,ev) % available soon...
 