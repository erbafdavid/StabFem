
run('../../SOURCES_MATLAB/SF_Start.m');
verbosity=1;

%% Generation of the base flow

%if(exist('./WORK/BASEFLOW/BaseFlow_Re500.ff2m')==0)
    bf = SmartMesh_L6();
%else
    ffmesh = importFFmesh('./MESHES/mesh_adapt8_Re500.msh');
    bf = importFFdata(ffmesh,'./WORK/MESHES/BaseFlow_adapt8_Re500.ff2m');
    bf = SF_BaseFlow(bf)
    bf.mesh.xlim = [-2 10];bf.mesh.ylim = [0 1];
%end

% plot the base flow
figure;plotFF(bf,'ux','contour','on','clevels',[0,0]);  %
pause(0.1);


%% Spectrum explorator 
[ev,eigenmode] = SF_Stability(bf,'m',1,'shift',1+0.2i,'nev',20,'type','D','plotspectrum','yes');   
pause(0.1);

 
%% COMPUTING THE UNSTEADY BRANCH (going backwards)
Re_RangeI = [500:-20:420 405 400:-20:300];
guessI = 0.04+0.657i;
EVI = SF_Stability_Loop(bf,Re_RangeI,guessI);
       

        
%% COMPUTING THE STEADY BRANCH (going backwards)
Re_RangeS = [500:-50:300 280 :-20:160];
guessS = 0.246;
EVS = SF_Stability_Loop(bf,Re_RangeS,guessS);
      

%% FIGURES
figure(11);hold on;
subplot(2,1,1);hold on;
plot(Re_RangeS,real(EVS),'-b',Re_RangeI,real(EVI),'-r');hold on;
plot(Re_RangeS,0*real(EVS),':k');%axis
title('growth rate lambda_r vs. Reynolds ; unstready mode (red) and steady mode (blue)')
subplot(2,1,2);hold on;
plot(Re_RangeS,imag(EVS),'-b',Re_RangeI,imag(EVI),':r',Re_RangeI(real(EVI)>0),imag(EVI(real(EVI)>0)),'r-')
title('oscillation rate lambda_i vs. Reynolds')
suptitle('Leading eigenvalues of a blunt body with L/d=6; D/d=2');
