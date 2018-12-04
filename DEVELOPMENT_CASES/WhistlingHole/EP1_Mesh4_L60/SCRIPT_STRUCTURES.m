
%%% THIS SCRIPT GENERATES PLOTS FOR THE FORCED STRUCTURES
run('../../../SOURCES_MATLAB/SF_Start.m')

%% This is to replace subplot by subtighplot
make_it_tight = true;
subplot = @(m,n,p) subtightplot (m, n, p, [0.05 0.05], [0.05 0.01], [0.05 0.01]);
if ~make_it_tight,  clear subplot;  end


%% Building Adapted Mesh
if(exist('./WORK/MESHES/BaseFlow_adapt8_Re2000.txt')==0)
    bf = SmartMesh_Hole_NoMap;
else
    ffmesh = importFFmesh('./WORK/MESHES/mesh_adapt8_Re2000.msh');
    bf = importFFdata(ffmesh,'./WORK/MESHES/BaseFlow_adapt8_Re2000.ff2m');
end

%% Plot BF
bf = SF_BaseFlow(bf,'Re',1600)
plotFF(bf,'ux','title','Base Flow','colormap','redblue','xlim',[-3 3],'ylim',[-1.5 1.5],'contour','on','clevels',[0 0],...
    'boundary','on','bdlabels',2,'bdcolors','k','symmetry','XS');
pause(0.1);

%% Impedances for this case
%figure(30);
%fo = SF_LinearForced(bf,[0:.05:6],'plot','yes');

%% Forced structures

% Computes forced structures for 5 values of omega
bf = SF_BaseFlow(bf,'Re',1600)

%
omega = 0.8;
Re = 1600; chi=1;
foA = SF_LinearForced(bf,omega);

%
omega = 1.7;
Re = 1600; chi=1;
foB = SF_LinearForced(bf,omega);

%
omega = 2.5;
Re = 1600; chi=1;
foC = SF_LinearForced(bf,omega);

%
omega = 3.6;
Re = 1600; chi=1;
foD = SF_LinearForced(bf,omega);

%
omega = 4.5;
Re = 1600; chi=1;
foE = SF_LinearForced(bf,omega);



%% Here is how to plot the velocity and pressure in two subfigures with different ranges
close all;
figure(11);
% This is to replace subplot by subtighplot
subplot = @(m,n,p) subtightplot (m, n, p, [0.05 0.05], [0.05 0.03], [0.05 0.01]);
Re = 1600;

% a and b 
foA.p1f = logfilter(foA.p1,1);foA.ux1f = logfilter(foA.ux1,1);foA.vort1f = logfilter(foA.vort1,1);
subplot(5,2,1);
plotFF(foA,'p1f','boundary','on','colormap','redblue','colorrange','cropcentered','xlim',[-3 5],'ylim',[0 3],...
               'boundary','on','bdlabels',2,'bdcolors','k','cbtitle','f_1(p'')');
           text(-2.8,3.2,'(a)');
subplot(5,2,2);
plotFF(foA,'ux1f','boundary','on','colormap','redblue','colorrange','cropcentered','xlim',[-3 5],'ylim',[0 3],...
                'boundary','on','bdlabels',2,'bdcolors','k','cbtitle','f_1(u''_x)');
             text(-2.8,3.2,'(b)');

% c and d
foB.p1f = logfilter(foB.p1,.3);foB.ux1f = logfilter(foB.ux1,.3);foB.vort1f = logfilter(foB.vort1,.3);
subplot(5,2,3);
plotFF(foB,'p1f','boundary','on','colormap','redblue','colorrange','cropcentered','xlim',[-3 5],'ylim',[0 3],...
               'boundary','on','bdlabels',2,'bdcolors','k','cbtitle','f_{0.3}(p'')');
           text(-2.8,3.2,'(c)');
subplot(5,2,4);
plotFF(foB,'ux1f','boundary','on','colormap','redblue','colorrange','cropcentered','xlim',[-3 5],'ylim',[0 3],...
                'boundary','on','bdlabels',2,'bdcolors','k','cbtitle','f_{0.3}(u''_x)');
             text(-2.8,3.2,'(d)');
             
% e and f 
foC.p1f = logfilter(foC.p1,.3);foC.ux1f = logfilter(foC.ux1,.3);foC.vort1f = logfilter(foC.vort1,.3);
subplot(5,2,5);
plotFF(foC,'p1f','boundary','on','colormap','redblue','colorrange','cropcentered','xlim',[-3 5],'ylim',[0 3],...
               'boundary','on','bdlabels',2,'bdcolors','k','cbtitle','f_{0.3}(p'')');
           text(-2.8,3.2,'(e)');
subplot(5,2,6);
plotFF(foC,'ux1f','boundary','on','colormap','redblue','colorrange','cropcentered','xlim',[-3 5],'ylim',[0 3],...
                'boundary','on','bdlabels',2,'bdcolors','k','cbtitle','f_{0.3}(u''_x)');
             text(-2.8,3.2,'(f)');
% g and h
             
foD.p1f = logfilter(foD.p1,.3);foD.ux1f = logfilter(foD.ux1,.3);foD.vort1f = logfilter(foD.vort1,.3);
subplot(5,2,7);
plotFF(foD,'p1f','boundary','on','colormap','redblue','colorrange','cropcentered','xlim',[-3 5],'ylim',[0 3],...
               'boundary','on','bdlabels',2,'bdcolors','k','cbtitle','f_{0.3}(p'')');
           text(-2.8,3.2,'(g)');
subplot(5,2,8);
plotFF(foD,'ux1f','boundary','on','colormap','redblue','colorrange','cropcentered','xlim',[-3 5],'ylim',[0 3],...
                'boundary','on','bdlabels',2,'bdcolors','k','cbtitle','f_{0.3}(u''_x)');
             text(-2.8,3.2,'(h)');

% i and j
foE.p1f = logfilter(foE.p1,.3);foE.ux1f = logfilter(foE.ux1,.3);foE.vort1f = logfilter(foE.vort1,.3);
subplot(5,2,9);
plotFF(foE,'p1f','boundary','on','colormap','redblue','colorrange','cropcentered','xlim',[-3 5],'ylim',[0 3],...
               'boundary','on','bdlabels',2,'bdcolors','k','cbtitle','f_{0.3}(p'')');
           text(-2.8,3.2,'(i)');
subplot(5,2,10);
plotFF(foE,'ux1f','boundary','on','colormap','redblue','colorrange','cropcentered','xlim',[-3 5],'ylim',[0 3],...
                'boundary','on','bdlabels',2,'bdcolors','k','cbtitle','f_{0.3}(u''_x)');
             text(-2.8,3.2,'(j)');             
             
pos = get(gcf,'Position'); pos(3) = 800; pos(4)=pos(3)*1.18;set(gcf,'Position',pos);            
saveas(gcf,['ForcedModes_chi', num2str(chi), '_Re',num2str(Re),'.png'],'png');
saveas(gcf,['ForcedModes_chi', num2str(chi), '_Re',num2str(Re), '.fig'],'fig')



%% Eigenmodes
Re =1490;
bf = SF_BaseFlow(bf,'Re',Re);
[ev,em2S,em2D,em2A] = SF_Stability(bf,'shift',2.1i,'m',0,'nev',1,'type','S');
%bf = SF_Adapt(bf,em2S,em2D,em2A);
%[ev,em2S,em2D,em2A] = SF_Stability(bf,'shift',2.1i,'m',0,'nev',1,'type','S');

Re =1701;
bf = SF_BaseFlow(bf,'Re',Re);
[ev,em3S,em3D,em3A] = SF_Stability(bf,'shift',4.14i,'m',0,'nev',1,'type','S');
%bf = SF_Adapt(bf,em2S,em2D,em2A);
%[ev,em3S,em3D,em3A] = SF_Stability(bf,'shift',4.14i,'m',0,'nev',1,'type','S');


exportFF_tecplot(em2D,['Eigenmode_chi', num2str(chi), '_Re',num2str(Re),'_ModeH2','.plt']);
exportFF_tecplot(em3D,['Eigenmode_chi', num2str(chi), '_Re',num2str(Re),'_ModeH3','.plt']);
em2D.p1f = logfilter(em2D.p1,1);em2D.ux1f = logfilter(em2D.ux1,1);em2D.vort1f = logfilter(em2D.vort1,1);
em3D.p1f = logfilter(em3D.p1,1);em3D.ux1f = logfilter(em3D.ux1,1);em3D.vort1f = logfilter(em3D.vort1,1);


%% FIGURES FOR EIGENMODES
make_it_tight = true;
subplot = @(m,n,p) subtightplot (m, n, p, [0.05 0.05], [0.05 0.01], [0.05 0.01]);
if ~make_it_tight,  clear subplot;  end


figure(33);
subplot(2,2,1);
plotFF(em2D,'p1f','colormap','redblue','colorrange','cropcentered','xlim',[-3 5],'ylim',[0 3],...
                'boundary','on','bdlabels',2,'bdcolors','k','cbtitle','f_1(p'')');
text(-2.8,3.2,'(a)');


subplot(2,2,2);hold on;
plotFF(em2D,'ux1f','colormap','redblue','colorrange','cropcentered','xlim',[-3 5],'ylim',[0 3],...
                'boundary','on','bdlabels',2,'bdcolors','k','cbtitle','f_1(u''_x)');
text(-2.8,3.2,'(b)');


subplot(2,2,3);
plotFF(em3D,'p1f','colormap','redblue','colorrange','cropcentered','xlim',[-3 5],'ylim',[0 3],...
                'boundary','on','bdlabels',2,'bdcolors','k','cbtitle','f_1(p'')');
box on; text(-2.8,3.2,'(c)');

subplot(2,2,4);
plotFF(em3D,'ux1f','colormap','redblue','colorrange','cropcentered','xlim',[-3 5],'ylim',[0 3],...
                'boundary','on','bdlabels',2,'bdcolors','k','cbtitle',{'f_1(u''_x)'});
box on; text(-2.8,3.2,'(d)');


pos = get(gcf,'Position'); pos(3) = 800;pos(4)=pos(3)*.4;set(gcf,'Position',pos);            
saveas(gcf,['EigenModes_chi', num2str(chi),'.png'],'png');
saveas(gcf,['EigenModes_chi', num2str(chi),'.fig'],'fig')


%% Adjoint Eigenmodes
Re =1490;
bf = SF_BaseFlow(bf,'Re',Re);
[ev,em2A] = SF_Stability(bf,'shift',2.1i,'m',0,'nev',1,'type','A');
bf = SF_Adapt(bf,em2A,'Hmax',0.25);
[ev,em2S,em2D,em2A] = SF_Stability(bf,'shift',2.1i,'m',0,'nev',1,'type','S');

Re =1701;
bf = SF_BaseFlow(bf,'Re',Re);
[ev,em3S,em3D,em3A] = SF_Stability(bf,'shift',4.14i,'m',0,'nev',1,'type','S');
bf = SF_Adapt(bf,em3A,em3S,'Hmax',0.25);
[ev,em3S,em3D,em3A] = SF_Stability(bf,'shift',4.14i,'m',0,'nev',1,'type','S');


%% FIGURES FOR ADJOINT
figure(34);

subplot(2,2,1);
plotFF(em2A,'ux1Adj','colormap','redblue','colorrange',[-15 15],'xlim',[-3.5 .5],'ylim',[0.5 2],...
                'boundary','on','bdlabels',2,'bdcolors','k','cbtitle','u''_{x,adj}');
text(-3.45,2.1,'(a)');

subplot(2,2,2);
plotFF(em2S,'sensitivity','colormap','ice','colorrange',[0 0.4],'xlim',[-2.25 1.75],'ylim',[0 1.5],...
                'boundary','on','bdlabels',2,'bdcolors','k','cbtitle','S_w','colorbar','eastoutside');
text(-2.2,1.6,'(b)');


subplot(2,2,3);
plotFF(em3A,'ux1Adj','colormap','redblue','colorrange',[-30 30],'xlim',[-3.5 .5],'ylim',[0.5 2],...
                'boundary','on','bdlabels',2,'bdcolors','k','cbtitle','u''_{x,adj}');
box on; text(-3.45,2.1,'(c)');

subplot(2,2,4);
plotFF(em3S,'sensitivity','colormap','ice','colorrange',[0 0.4],'xlim',[-2.25 1.75],'ylim',[0 1.5],...
                'boundary','on','bdlabels',2,'bdcolors','k','cbtitle','S_w');
box on; text(-2.2,1.6,'(d)');

pos = get(gcf,'Position'); pos(3) = 800;pos(4)=pos(3)*.4;set(gcf,'Position',pos);            
saveas(gcf,['EigenModes_Adj_chi', num2str(chi),'.png'],'png');
saveas(gcf,['EigenModes_Adj_chi', num2str(chi),'.fig'],'fig')

%%
%Forced flow structure for omega = 2.1
ForcedFlow_21_Mesh4 = SF_LinearForced(bf,2.1);
save('ForcedFlow_21_Mesh4','ForcedFlow_21_Mesh4')
