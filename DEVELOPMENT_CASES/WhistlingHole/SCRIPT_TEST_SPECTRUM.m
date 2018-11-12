% This script creates the figure in the appendix.

run('../../SOURCES_MATLAB/SF_Start.m');
verbosity=10;
close all;
set(0, 'DefaultLineLineWidth', 1);

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

%% Illustration of the complex mapping function
Xline = linspace(min(bf.mesh.points(1,:)),max(bf.mesh.points(1,:)),500);
Xphysline = SF_ExtractData(bf.mesh,'xphys',Xline,0);
figure;plot(Xline,real(Xphysline),'r-',Xline,imag(Xphysline),'b-');
Hxline = SF_ExtractData(bf.mesh,'Hx',Xline,0);
hold on;plot(Xline,real(Hxline),'r--',Xline,imag(Hxline),'b--');

%% Chapter 2 : exploration of the spectrum and figure (mesh 1)
figure(40);hold on;
bf= SF_BaseFlow(bf,'Re',1700);
SpectrumA_0i = SF_Stability(bf,'shift',0.5+0.5i,'nev',20,'type','D','m',0,'solver','StabAxi_COMPLEX_m0.edp');
plot(SpectrumA_0i,'x')
SpectrumA_1i = SF_Stability(bf,'shift',0.5+1i,'nev',20,'type','D','m',0,'solver','StabAxi_COMPLEX_m0.edp');
plot(SpectrumA_1i,'x')
SpectrumA_2i = SF_Stability(bf,'shift',0.5+2i,'nev',20,'type','D','m',0,'solver','StabAxi_COMPLEX_m0.edp');
plot(SpectrumA_2i,'x')
SpectrumA_3i = SF_Stability(bf,'shift',0.5+3i,'nev',20,'type','D','m',0,'solver','StabAxi_COMPLEX_m0.edp');
plot(SpectrumA_3i,'x')
SpectrumA_4i = SF_Stability(bf,'shift',0.5+4i,'nev',20,'type','D','m',0,'solver','StabAxi_COMPLEX_m0.edp');
plot(SpectrumA_4i,'x')
SpectrumA_m1i = SF_Stability(bf,'shift',0.5-1i,'nev',20,'type','D','m',0,'solver','StabAxi_COMPLEX_m0.edp');
plot(SpectrumA_1i,'x')
SpectrumA_m2i = SF_Stability(bf,'shift',0.5-2i,'nev',20,'type','D','m',0,'solver','StabAxi_COMPLEX_m0.edp');
plot(SpectrumA_2i,'x')
SpectrumA_m3i = SF_Stability(bf,'shift',0.5-3i,'nev',20,'type','D','m',0,'solver','StabAxi_COMPLEX_m0.edp');
plot(SpectrumA_3i,'x')
SpectrumA_m4i = SF_Stability(bf,'shift',0.5-4i,'nev',20,'type','D','m',0,'solver','StabAxi_COMPLEX_m0.edp');
plot(SpectrumA_4i,'x')

Spectrum_1700_Map = [SpectrumA_0i;SpectrumA_1i;SpectrumA_2i;SpectrumA_3i;SpectrumA_4i;SpectrumA_m1i;SpectrumA_m2i;SpectrumA_m3i;SpectrumA_m4i];
save('Spectrum_1700_Map','Spectrum_1700_Map');


%
figure(41);hold on;
bf= SF_BaseFlow(bf,'Re',2000);
SpectrumA_0i = SF_Stability(bf,'shift',0.5+0.5i,'nev',20,'type','D','m',0,'solver','StabAxi_COMPLEX_m0.edp');
plot(SpectrumA_0i,'x')
SpectrumA_1i = SF_Stability(bf,'shift',0.5+1i,'nev',20,'type','D','m',0,'solver','StabAxi_COMPLEX_m0.edp');
plot(SpectrumA_1i,'x')
SpectrumA_2i = SF_Stability(bf,'shift',0.5+2i,'nev',20,'type','D','m',0,'solver','StabAxi_COMPLEX_m0.edp');
plot(SpectrumA_2i,'x')
SpectrumA_3i = SF_Stability(bf,'shift',0.5+3i,'nev',20,'type','D','m',0,'solver','StabAxi_COMPLEX_m0.edp');
plot(SpectrumA_3i,'x')
SpectrumA_4i = SF_Stability(bf,'shift',0.5+4i,'nev',20,'type','D','m',0,'solver','StabAxi_COMPLEX_m0.edp');
plot(SpectrumA_4i,'x')
SpectrumA_m1i = SF_Stability(bf,'shift',0.5-1i,'nev',20,'type','D','m',0,'solver','StabAxi_COMPLEX_m0.edp');
plot(SpectrumA_1i,'x')
SpectrumA_m2i = SF_Stability(bf,'shift',0.5-2i,'nev',20,'type','D','m',0,'solver','StabAxi_COMPLEX_m0.edp');
plot(SpectrumA_2i,'x')
SpectrumA_m3i = SF_Stability(bf,'shift',0.5-3i,'nev',20,'type','D','m',0,'solver','StabAxi_COMPLEX_m0.edp');
plot(SpectrumA_3i,'x')
SpectrumA_m4i = SF_Stability(bf,'shift',0.5-4i,'nev',20,'type','D','m',0,'solver','StabAxi_COMPLEX_m0.edp');
plot(SpectrumA_4i,'x')

Spectrum_2000_Map = [SpectrumA_0i;SpectrumA_1i;SpectrumA_2i;SpectrumA_3i;SpectrumA_4i;SpectrumA_m1i;SpectrumA_m2i;SpectrumA_m3i;SpectrumA_m4i];
save('Spectrum_2000_Map','Spectrum_2000_Map');


%% Chapter 3 : generation of figure comparing 4 meshes (run only this section to save time !)


figure(345);hold off;
set(0, 'DefaultLineLineWidth', 1);
load('Spectrum_1700_Map');
plot(Spectrum_1700_Map,'xr');hold on;
load('EP1_Mesh4_L60/Spectrum_1700_NoMap');
plot(Spectrum_1700_NoMap,'+b');hold on;
load('EP1_Mesh3_L30/Spectrum_1700_NoMap_L30');
plot(Spectrum_1700_NoMap_L30,'*g');hold on;
ylabel('\omega');xlabel('\sigma');box on;
plot([0 0],[-10 10],'k:');plot([-10 10],[0 0],'k:');
xlim([-1 1]);ylim([-5 5]);
saveas(gcf,'Spectrum_Re1700_Map_NoMap','png')
saveas(gcf,'Spectrum_Re1700_Map_NoMap','fig')

%
figure(346);hold off;
set(0, 'DefaultLineLineWidth', 1);
load('Spectrum_2000_Map');
plot(Spectrum_2000_Map,'xr');hold on;
load('EP1_Mesh4_L60/Spectrum_2000_NoMap');
plot(Spectrum_2000_NoMap,'+b');hold on;
load('EP1_Mesh3_L30/Spectrum_2000_NoMap_L30');
plot(Spectrum_2000_NoMap_L30,'*g');hold on;
ylabel('\omega');xlabel('\sigma');box on;
plot([0 0],[-10 10],'k:');plot([-10 10],[0 0],'k:');
xlim([-1 1]);ylim([-5 5]);
saveas(gcf,'Spectrum_Re2000_Map_NoMap','png')

