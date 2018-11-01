

%%% This script will produce figures for :

%%% 1/ the base flow 
%%%    (something like figure 5 of the JFM paper but using cx mapping)
%%% 2/ an eigenmode 
%%%     (something like figure 14)
%%% 3/ the growth rates/oscillation rates 
%%%     (something like figure 13, including impedance-based predictions) 



run('../../SOURCES_MATLAB/SF_Start.m');
verbosity=10;
close all;
set(0, 'DefaultLineLineWidth', 2);

Re = 1500;
chi = 1;

%% Chapter 1 : mesh
if(exist('./WORK/MESHES/BaseFlow_adapt6_Re1500.ff2m')~=2);
    disp('Creating baseflow/mesh')
    bf = SmartMesh_Hole(chi);
else
    disp('Recovering baseflow/mesh')
    ffmesh = importFFmesh('./WORK/MESHES/mesh_adapt6_Re1500.msh'); 
    bf = importFFdata(ffmesh,'./WORK/MESHES/BaseFlow_adapt6_Re1500.ff2m');
    bf = SF_BaseFlow(bf);
end


figure; plotFF(bf,'ux','title','Base Flow','colormap','redblue','xlim',[-3 3],'ylim',[1e-4 1.5],'contour','on','clevels',[0 0],'boundary','on');
% something like figure 5....
pause(0.1);

%% Chapter 3 : stability

bf = SF_BaseFlow(bf,'Re',1500);
[ev,em] = SF_Stability(bf,'m',0,'shift',-.036-2.050i,'nev',20,'solver','StabAxi_COMPLEX_m0.edp','plotspectrum','yes')
figure;plotFF(em(1),'vort1','title','eigenmode','xlim',[-3 4],'ylim',[1e-4 1.5],'colormap','redblue','colorrange',[-200,200],'boundary','on');
% something like figure 14

%%

figure(200);
Re_tab = [2000 : -50 : 1200];  
ev_tab_H2 = SF_Stability_LoopRe(bf,Re_tab,0.3-2.23i,'m',0,'solver','StabAxi_COMPLEX_m0_nev1.edp','plot','r');
ev_tab_H3 = SF_Stability_LoopRe(bf,Re_tab,0.22-4.33i,'m',0,'solver','StabAxi_COMPLEX_m0_nev1.edp','plot','b');
ev_tab_H1 = SF_Stability_LoopRe(bf,Re_tab,-.04-.562i,'m',0,'solver','StabAxi_COMPLEX_m0_nev1.edp','plot','g');




figure(20);
plot(Re_tab,real(ev_tab_H2),'r',Re_tab,-imag(ev_tab_H3),'b');
saveas(gcf,'Eigenvalues_chi1_CM','png');
pause(0.1);


%% Chapter 4 : eigenvalue prediction based on Impedance


% This loop uses the function Imp2Stab

% branch H2

OmegaS = [2.18 :.05 : 2.28];%initial range ; will be updated
Re_tabI = [2000 :-50:1200];omega0_H2_tabI = [];sigma1_H2_tabI = [];omega0_H3_tabI = [];sigma1_H3_tabI = [];
for Re = Re_tabI
    bf = SF_BaseFlow(bf,'Re',Re);
    res = Imp2Stab(bf,OmegaS);
    omega0_H2_tabI = [ omega0_H2_tabI res.omega0 ];
    sigma1_H2_tabI = [ sigma1_H2_tabI res.sigma1 ]; 
    OmegaS = [res.omega0-.05 :.05 : res.omega0+.05];%update range
    figure(20);hold on;
    plot(Re,res.omega0,'+b',Re,res.sigma1,'r+');
    pause(0.1);
end

% branch H3

OmegaS = [4.28 :.05 : 4.38];%initial range ; will be updated
Re_tabI = [2000 :-50:1200];omega0_H3_tabI = [];sigma1_H3_tabI = [];
for Re = Re_tabI
    bf = SF_BaseFlow(bf,'Re',Re);
    res = Imp2Stab(bf,OmegaS);
    omega0_H3_tabI = [ omega0_H3_tabI res.omega0 ];
    sigma1_H3_tabI = [ sigma1_H3_tabI res.sigma1 ]; 
    OmegaS = [res.omega0-.05 :.05 : res.omega0+.05];%update range
    figure(20);hold on;
    plot(Re,res.omega0,'+b',Re,res.sigma1,'r+');
    pause(0.1);
end

save('results_stab');



%figure(20);hold on;
%plot(Re_tabI,omega0_tabI,'+b',Re_tabI,sigma1_tabI,'r+');
%pause(0.1);
%saveas(gcf,['Eigenvalues_chi1_CM'],'png');

%% results without complex mapping
load('EP1_Mesh4_L60/results_nomap')    
load('results_stab');

figure(120);hold off;
subplot(2,1,1);
plot(Re_tab,real(ev_tab_H2),'r-','linewidth',2);hold on;
plot(Re_tab,real(ev_tab_H3),'b-','linewidth',2);
plot(Re_tab,real(ev_tab_H1),'g-','linewidth',2);
%plot(Re_Range,real(EVH2),'r.','linewidth',2);hold on;
%plot(Re_Range,real(EVH3),'b.','linewidth',2);
%plot(Re_Range,real(EVH1),'g.','linewidth',2);
plot(Re_tabI,sigma1_H2_tabI,'ro:','linewidth',1);
plot(Re_tabI,sigma1_H3_tabI,'bo:','linewidth',1);
plot(Re_Range,0*real(EVH2),'k:','linewidth',1);
ylim([-.2 .4]);xlim([1200  2000]);
xlabel('Re');ylabel('\sigma')

subplot(2,1,2);hold off;
hold on;
plot(Re_tab(real(ev_tab_H2)>0),imag(ev_tab_H2(real(ev_tab_H2)>0)),'r-','linewidth',2);hold on;
plot(Re_tab(real(ev_tab_H3)>0),imag(ev_tab_H3(real(ev_tab_H3)>0)),'b-','linewidth',2);
plot(Re_tab,-imag(ev_tab_H2),'r:');
plot(Re_tab,-imag(ev_tab_H3),'b:');
plot(Re_tab,-imag(ev_tab_H1),'g:');
%plot(Re_Range,imag(EVH2),'r.',Re_Range,imag(EVH3),'b.',Re_Range,imag(EVH1),'g.');hold on;
%plot(Re_tabI,omega0_H2_tabI,'ro:','linewidth',1);
%plot(Re_tabI,omega0_H3_tabI,'bo:','linewidth',1);
ylim([0 5]);xlim([1200  2000]);
xlabel('Re');ylabel('\omega')
saveas(gcf,'Eigenvalues_onehole_beta1','png')
saveas(gcf,'Eigenvalues_onehole_beta1','fig')



