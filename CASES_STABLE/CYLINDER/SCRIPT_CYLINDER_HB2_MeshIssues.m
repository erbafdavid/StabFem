
%  Instability of the wake of a cylinder with STABFEM
%
%  this script demonstrates the way to perform HARMONIC BALANCE
%  for the wake of a cylinder in the range Re = [46.7 - 200].
 
clear all;
run('../../SOURCES_MATLAB/SF_Start.m');verbosity=1;

if(exist('RESULTS/HB2res_meshes.mat')==0)
    
   
    figureformat='png'; AspectRatio = 0.56; % for figures
    mkdir('RESULTS');
    
    Rec = 46.7;
    Re_TAB = [Rec 47 47.5 48 49 50 52.5 55 60 65 70 75 80 85 90 95 100 110:10:200];
    
    %% ##### CHAPTER 1 : MESH 'S', 80, 'S'
    
    disp(' ');
    disp(' #### MESH 1 #### ');
    disp(' ');
    
    bf = SmartMesh_Cylinder('S',[-40 80 40]);
    
    disp('COMPUTING INSTABILITY THRESHOLD');
    bf=SF_BaseFlow(bf,'Re',50);
    [ev,em] = SF_Stability(bf,'shift',+.75i,'nev',1,'type','S');
    [bfT,emT]=SF_FindThreshold(bf,em);
    Rec = bfT.Re;
    
    HBres_mesh1 = HB2_LoopRe(bfT,emT,Re_TAB) ;    
    
    %% ##### CHAPTER 2 : MESH 'S', 120, 'S'
    
    disp(' ');
    disp(' #### MESH 2 #### ');
    disp(' ');
    
    bf = SmartMesh_Cylinder('S',[-40 120 40]);
    
    disp('COMPUTING INSTABILITY THRESHOLD');
    bf=SF_BaseFlow(bf,'Re',50);
    [ev,em] = SF_Stability(bf,'shift',+.75i,'nev',1,'type','S');
    [bfT,emT]=SF_FindThreshold(bf,em);
    Rec = bfT.Re;
    
    
    HBres_mesh2 = HB2_LoopRe(bfT,emT,Re_TAB) ;
    
    
    
    
    %% ##### CHAPTER 3 : MESH 'D', 80, 'S'
    
    disp(' ');
    disp(' #### MESH 3 #### ');
    disp(' ');
    
    bf = SmartMesh_Cylinder('D',[-40 80 40]);
    
    disp('COMPUTING INSTABILITY THRESHOLD');
    bf=SF_BaseFlow(bf,'Re',50);
    [ev,em] = SF_Stability(bf,'shift',+.75i,'nev',1,'type','S');
    [bfT,emT]=SF_FindThreshold(bf,em);
    Rec = bfT.Re;
    
    
    HBres_mesh3 = HB2_LoopRe(bfT,emT,Re_TAB) ;
    
    
    
    %% ##### CHAPTER 4 : MESH 'S', 40, 'S'
    
    disp(' ');
    disp(' #### MESH 4 #### ');
    disp(' ');
    
    bf = SmartMesh_Cylinder('D',[-40 120 40]);
    
    disp('COMPUTING INSTABILITY THRESHOLD');
    bf=SF_BaseFlow(bf,'Re',50);
    [ev,em] = SF_Stability(bf,'shift',+.75i,'nev',1,'type','S');
    [bfT,emT]=SF_FindThreshold(bf,em);
    Rec = bfT.Re;
    
    
    HBres_mesh4 = HB2_LoopRe(bfT,emT,Re_TAB) ;
    
    
    
    save('RESULTS/HB2res_meshes.mat','HBres_mesh1','HBres_mesh2','HBres_mesh4','HBres_mesh4');
    
    
    
else
    
    load('RESULTS/HB2res_meshes.mat')
    
end


%% Chapter 6 : figures;


figure(24);hold off;
hold on;
plot(HBres_mesh1.Re,real(HBres_mesh1.Fy),'r+-','LineWidth',2);
plot(HBres_mesh2.Re,real(HBres_mesh2.Fy),'bo-','LineWidth',2);
plot(HBres_mesh3.Re,real(HBres_mesh3.Fy),'gx-','LineWidth',2);
plot(HBres_mesh4.Re,real(HBres_mesh4.Fy),'c+-','LineWidth',2);
%title('Harmonic Balance results');
xlabel('Re');ylabel('Fy')
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('Mesh 1','Mesh 2','Mesh 3','Mesh 4','Location','south');
saveas(gca,'FIGURES/Cylinder_Fy_HBres.Re2',figureformat);

figure(25);hold off;
hold on;
plot(HBres_mesh1.Re,real(HBres_mesh1.Aenergy),'r+-','LineWidth',2);
plot(HBres_mesh2.Re,real(HBres_mesh2.Aenergy),'bo-','LineWidth',2);
plot(HBres_mesh3.Re,real(HBres_mesh3.Aenergy),'gx-','LineWidth',2);
plot(HBres_mesh4.Re,real(HBres_mesh4.Aenergy),'c+-','LineWidth',2);
%title('Harmonic Balance results');
xlabel('Re');ylabel('A_E')
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
legend('HB-1','HB-2','Location','south');
saveas(gca,['FIGURES/Cylinder_Energy_HBres.Re2_',type],figureformat);

pause(0.1);


