
run('../../SOURCES_MATLAB/SF_Start.m');
verbosity=1;


%% Generation of the base flow
dsurD = 0.1;
bf = SmartMesh_L2(dsurD);
bf.mesh.xlim = [-2 6];bf.mesh.ylim = [-5 5];%default ranges for figures associated to this mesh
bfREF = bf; % backup the base flow for Re =500, dsurD = 0.1
    
% plot the base flow
figure;plotFF(bf,'ux','contour','on','clevels',[0,0],'symmetry','XS','boundary','on','bdlabels',[1 21 22 23],'bdcolors','brrr');  %
pause(0.1);

%% Loop over dsurD for Re = 500
dsurD_tab = [0.1:0.1:0.6 , 0.65 0.7 0.75 0.8 0.83 0.86 0.88 0.9];
Cx_tab = []; Lx_tab = []; Umax_tab = []; Umin_tab = [];
dsurDans = dsurD_tab(1);
bf = bfREF;
for dsurD = dsurD_tab
    dsurD
    Yratio = ((1/dsurD-1)/(1/dsurDans-1))
    bf = SF_MeshStretch(bf,'Yratio',Yratio,'Ymin',0.5);
    bf = SF_Adapt(bf);
    Cx_tab = [Cx_tab, bf.Cx]; 
    Umax_tab = [Umax_tab, max(bf.ux)];
    Umin_tab = [Umin_tab, min(bf.ux)];
    dsurDans = dsurD;
end
figure(12);
plot(dsurD_tab,Cx_tab,'r',dsurD_tab,Umax_tab,'b',dsurD_tab,Umin_tab,'g');
xlabel('d/D');legend('Cx','Umax','Umin');
    


%% Spectrum explorator 
bf = bfREF
[ev,em] = SF_Stability(bf,'m',1,'shift',.5+0.4i,'nev',20,'type','D','plotspectrum','yes');   
pause(0.1);
 figure;
    subplot(2,1,1);plotFF(em(2),'ux1','symmetry','XA','colormap','redblue','boundary','on','bdlabels',[1 21 22 23],'bdcolors','brrr','ylim',[-2 2],'colorrange','cropcentered','cbtitle','u_x''');hold on;title('Blunt body : steady mode')
    subplot(2,1,2);plotFF(em(1),'ux1','symmetry','XA','colormap','redblue','boundary','on','bdlabels',[1 21 22 23],'bdcolors','brrr','ylim',[-2 2],'colorrange','cropcentered','cbtitle','u_x''');hold on;title('Blunt body : unsteady mode')
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*.75;set(gcf,'Position',pos);
saveas(gcf,'FIGURES/BluntBody_L2_D2_Modes','png');
pause(0.1);
 

%% COMPUTING THE UNSTEADY BRANCH (going backwards)
bf = bfREF
Re_RangeI = [500:-20:300];
guessI =  0.013 + 0.6463i;
figure(10);
[EVI,ResI,omegasI] = SF_Stability_LoopRe(bf,Re_RangeI,guessI,'plot','r');
ResI_01=ResI; omegasI_01 = omegasI;
       
%% COMPUTING THE STEADY BRANCH (going backwards)
Re_RangeS = [500:-50:300];
guessS = 0.128;
[EVS,ResS,omegasS] = SF_Stability_LoopRe(bf,Re_RangeS,guessS,'plot','b');
ResS_01=ResS

%% 
%Refining estimation of thresholds on a smaller interval
%[EVI,ResI,omegasI] = SF_Stability_LoopRe(bf,[5*round(ResI/5)-15:5:5*round(ResI/5)+15],omegasI*1i,'plot','r');
%[EVS,ResS,omegasS] = SF_Stability_LoopRe(bf,[5*round(ResS/5)-15:5:5*round(ResS/5)+15],0,'plot','b');

%% Loop
bf = bfREF
dsurD_tab = [0.1:0.1:0.6 , 0.65 0.7 0.75 0.8];ResStab1 = ResS;
ResI_tab = []; ResI_tab = ResI_01;
omegaI_tab = []; omegaI_tab = omegasI_01;
ResS_tab = []; ResS_tab = ResS_01;
dsurDans = dsurD_tab(1);
for i=1:length(dsurD_tab)
    dsurD = dsurD_tab(i)
    % guess values for thresholds and frequency
   if(i<=2) 
        ResIguess = ResI_tab(1); ResSguess = ResS_tab(1); omegaIguess = omegaI_tab(1);
    else
        ResIguess = 2*ResI_tab(i-1)-ResI_tab(i-2); ResSguess = 2*ResS_tab(i-1)-ResS_tab(i-2); omegaIguess = 2*omegaI_tab(i-1)-omega_tab(i-2);
    end
    % stretching mesh
    Yratio = ((1/dsurD-1)/(1/dsurDans-1))
    bf = SF_MeshStretch(bf,'Yratio',Yratio,'Ymin',0.5);
    % adapting to bf/mode at guess threshold of unsteady mode
    bf = SF_BaseFlow(bf,'Re',ResIguess);
    [ev,em] = SF_Stability(bf,'m',1,'shift',omegaIguess*1i,'nev',10,'type','D');   
    bf = SF_Adapt(bf,em(1));
    [EVI,ResI,omegasI] = SF_Stability_LoopRe(bf,[5*round(ResIguess/5)-20:10:5*round(ResIguess/5)+20],omegasI*1i,'plot','r');
    [EVS,ResS,omegasS] = SF_Stability_LoopRe(bf,[5*round(ResSguess/5)-20:10:5*round(ResSguess/5)+20],0,'plot','b');
    ResI_tab(i) = ResI;
    omegaI_tab(i) = omegasI;
    ResS_tab(i) = ResS;
    dsurDans = dsurD;
end
    
figure(25);
plot(dsurD_tab,ResS_tab,'b',dsurD_tab,ReI_tab,'r');
xlabel('d/D');ylabel('Re'); legend('Re_{c,s}','Re_{c,i}');
saveas(gcf,['NeutralCurves_Re_dD_BluntBondy_L2','.png'],'png')

figure(26);
plot(dsurD_tab,omegaI_tab,'r');
xlabel('d/D');ylabel('omega'); 
saveas(gcf,['OmegaI_dD_BluntBondy_L2','.png'],'png')
