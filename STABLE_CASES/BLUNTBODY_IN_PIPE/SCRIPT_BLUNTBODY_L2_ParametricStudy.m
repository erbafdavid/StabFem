
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
dsurD_tab = [0.1:0.05:0.6, 0.625:0.025:0.8 ];
Cx_tab = NaN*ones(size(dsurD_tab)); Lx_tab = NaN*ones(size(dsurD_tab)); 
Umax_tab = NaN*ones(size(dsurD_tab)); Umin_tab = NaN*ones(size(dsurD_tab));
bf = bfREF;
for i=1:length(dsurD_tab)
    dsurD = dsurD_tab(i)
    dsurDans = 0.5/max(bf.mesh.points(2,:));
    Yratio = ((1/dsurD-1)/(1/dsurDans-1));
    bf = SF_MeshStretch(bf,'Yratio',Yratio,'Ymin',0.5);
    bf = SF_Adapt(bf);
    Cx_tab = [Cx_tab, bf.Cx]; 
    Umax_tab = [Umax_tab, max(bf.ux)];
    Umin_tab = [Umin_tab, min(bf.ux)];
end
figure(12);
plot(dsurD_tab,Cx_tab,'r',dsurD_tab,Umax_tab,'b',dsurD_tab,Umin_tab,'g');
xlabel('d/D');legend('Cx','Umax','Umin');
    


%% Spectrum explorator for d/D = 0.1 ; Re = 500
bf = bfREF
[ev,em] = SF_Stability(bf,'m',1,'shift',.5+0.4i,'nev',20,'type','D','plotspectrum','yes');   
pause(0.1);
 figure;
    subplot(2,1,1);plotFF(em(2),'ux1','symmetry','XA','colormap','redblue','boundary','on','bdlabels',[1 21 22 23],'bdcolors','brrr','ylim',[-2 2],'colorrange','cropcentered','cbtitle','u_x''');hold on;title('Blunt body : steady mode')
    subplot(2,1,2);plotFF(em(1),'ux1','symmetry','XA','colormap','redblue','boundary','on','bdlabels',[1 21 22 23],'bdcolors','brrr','ylim',[-2 2],'colorrange','cropcentered','cbtitle','u_x''');hold on;title('Blunt body : unsteady mode')
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*.75;set(gcf,'Position',pos);
saveas(gcf,'FIGURES/BluntBody_L2_D2_Modes','png');
pause(0.1);
 

%% COMPUTING THE UNSTEADY BRANCH (going backwards) for d/D = 0.1;
bf = bfREF;
myrm('./WORK/BASEFLOWS/BaseFlow*');
Re_RangeI = [500:-20:360];
guessI =  0.013 + 0.6463i;
figure(10);
[EVI,ResI,omegasI] = SF_Stability_LoopRe(bf,Re_RangeI,guessI,'plot','r');
ResI_01=ResI; omegasI_01 = omegasI;
       
%% COMPUTING THE STEADY BRANCH (going backwards) for d/D = 0.1;
Re_RangeS = [500:-50:300];
guessS = 0.128;
bf = bfREF;
[EVS,ResS,omegasS] = SF_Stability_LoopRe(bf,Re_RangeS,guessS,'plot','b');
ResS_01=ResS;



%% Parametric study of neutral curbes in the Re/dsurD plane

bf = bfREF;
dsurD_tab = [0.1:0.05:0.6,0.625:.025:.8];ResStab1 = ResS;
ResI_tab = nan*ones(size(dsurD_tab)); ResI_tab(1) = ResI_01;
omegaI_tab = nan*ones(size(dsurD_tab)); omegaI_tab(1) = omegasI_01;
ResS_tab = nan*ones(size(dsurD_tab)); ResS_tab(1) = ResS_01;
dsurDans = dsurD_tab(1);
for i=1:length(dsurD_tab)
    dsurD = dsurD_tab(i)
    % stretching mesh
    dsurDans = 0.5/max(bf.mesh.points(2,:));
    Yratio = ((1/dsurD-1)/(1/dsurDans-1));
    bf = SF_MeshStretch(bf,'Yratio',Yratio,'Ymin',0.5);
    % guess values for thresholds and frequency 
   if(i<=2) % guess = start value
        ResIguess = ResI_tab(1); ResSguess = ResS_tab(1); omegasIguess = omegaI_tab(1);
   else % guess = extrapolation using two previous points
        ResIguess = ResI_tab(i-1) + (ResI_tab(i-1)-ResI_tab(i-2)) * (dsurD_tab(i)-dsurD_tab(i-1))/(dsurD_tab(i-1)-dsurD_tab(i-2))
        ResSguess = ResS_tab(i-1) + (ResS_tab(i-1)-ResS_tab(i-2)) * (dsurD_tab(i)-dsurD_tab(i-1))/(dsurD_tab(i-1)-dsurD_tab(i-2)) 
        omegasIguess = omegaI_tab(i-1) + (omegaI_tab(i-1)-omegaI_tab(i-2)) * (dsurD_tab(i)-dsurD_tab(i-1))/(dsurD_tab(i-1)-dsurD_tab(i-2))     
   end
    figure(30); % this is where the pieces of branches will be plotted by SF_Stability_LoopRe
    % adapting to bf/mode at guess threshold of unsteady mode
    bf = SF_BaseFlow(bf,'Re',ResIguess);
    [ev,em] = SF_Stability(bf,'m',1,'shift',omegasIguess*1i,'nev',10,'type','D');  
    bf = SF_Adapt(bf,em(1));
    % locates the threshold of unsteady mode
    [EVI,ResI,omegasI] = SF_Stability_LoopRe(bf,[ResIguess*1.1:-ResIguess*.05:ResIguess*0.9],ev(1),'plot','r');
    ResI_tab(i) = ResI;
    omegaI_tab(i) = omegasI;
    % locates the threshold of the steady mode
    [EVS,ResS,omegasS] = SF_Stability_LoopRe(bf,[ResSguess*1.1:-ResSguess*.05:ResSguess*0.9],0,'plot','b');
    ResS_tab(i) = ResS;
    % plots in 'dot' mode on figure 25
    figure(25);hold on;
    plot(dsurD_tab(i),ResS_tab(i),'b.',dsurD_tab(i),ResI_tab(i),'r.');
    pause(0.1);
end
 
save('Thresholds.mat','ResS_tab','ResI_tab','dsurD_tab','omegaI_tab');

%% FIGURES ;
load('Thresholds.mat');

figure(25);hold on;
plot(dsurD_tab,ResS_tab,'b-o',dsurD_tab,ResI_tab,'r-o');
xlabel('d/D');ylabel('Re'); legend('Re_{c,s}','Re_{c,i}');
saveas(gcf,['NeutralCurves_Re_dD_BluntBondy_L2','.png'],'png')

figure(26);hold on;
plot(dsurD_tab,omegaI_tab,'r');
xlabel('d/D');ylabel('omega'); 
saveas(gcf,['OmegaI_dD_BluntBondy_L2','.png'],'png')
