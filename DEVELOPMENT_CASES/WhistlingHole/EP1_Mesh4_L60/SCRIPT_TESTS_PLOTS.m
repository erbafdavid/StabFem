
run('../../../SOURCES_MATLAB/SF_Start.m')


%% Generates or recovers Mesh/BF
if(exist('./WORK/MESHES/BaseFlow_adapt9_Re1500.txt')==0)
bf = SmartMesh_Hole_NoMap;
bf = SF_BaseFlow(bf,'Re',1500)
[ev,em] = SF_Stability(bf,'m',0,'nev',1,'type','D','shift',2.05i);
bf = SF_Adapt(bf,em,'Hmax',.5);
else
    ffmesh = importFFmesh('./WORK/MESHES/mesh_adapt9_Re1500.msh');
    bf = importFFdata(ffmesh,'./WORK/MESHES/BaseFlow_adapt9_Re1500.ff2m');
end


%% Plot BF
bf = SF_BaseFlow(bf,'Re',1600)
plotFF(bf,'ux','title','Base Flow','colormap','redblue','xlim',[-3 3],'ylim',[-1.5 1.5],'contour','on','clevels',[0 0],'boundary','on','symmetry','XS');
pause(0.1);

%% computes linear response for a given omega
omega = 0.8;Re = 1500; chi=1;
fo = SF_LinearForced(bf,omega);

figure;plotFF(fo,'ux1','boundary','on','colormap','redblue','colorrange',[-20 20],'xlim',[-3 3],'ylim',[-1.5 1.5],...
                'boundary','on','colorbar','northoutside','cbtitle','u''_x');
hold on;plotFF(fo,'p1','boundary','on','colormap','redblue','colorrange',[-2 2],'xlim',[-3 3],'ylim',[-1.5 1.5],...
               'symmetry','XM','boundary','on','colorbar','southoutside','cbtitle','p'''); % symmetry = XM means mirror about X-axis
saveas(gcf,['ForcedMode_UXandP_chi', num2str(chi), '_Re',num2str(Re),'_omega',num2str(omega),'.png'],'png');
saveas(gcf,['ForcedMode_UXandP_chi', num2str(chi), '_Re',num2str(Re),'_omega',num2str(omega) '.fig'],'fig')

%% extracts and plots the values of ux on the axis
Xaxis = [-3 :.1 :10];
Uxaxis = SF_ExtractData(fo,'ux1',Xaxis,0);
figure;plot(Xaxis,Uxaxis);ylabel('u_x''(x,y=0)'); xlabel('x');
saveas(gcf,['AxialVelocityOnAxis.png'],'png');


