run('../../../SOURCES_MATLAB/SF_Start.m')

if(exist('./WORK/BASEFLOWS/BaseFlow_Re2000.txt')==0)
bf = SmartMesh_Hole_NoMap;
else
    ffmesh = importFFmesh('./WORK/mesh.msh');
    bf = importFFdata(ffmesh,'./WORK/BASEFLOWS/BaseFlow_Re2000.ff2m');
end

%% 
Re_Range = [2000 : -50 :1000];
%Re_RangeUP = [2000 :50: 3000];

EVH2 = SF_Stability_LoopRe(bf,Re_Range,0.3+2.23i,'type','A','m',0);
EVH3 = SF_Stability_LoopRe(bf,Re_Range,0.22+4.33i,'type','A','m',0);
EVH1 = SF_Stability_LoopRe(bf,Re_Range,-.04+.562i,'type','A','m',0); 

%EVH2UP = SF_Stability_LoopRe(bf,Re_RangeUP,0.3+2.23i,'type','A','m',0);
%EVH3UP  = SF_Stability_LoopRe(bf,Re_RangeUP,0.22+4.33i,'type','A','m',0);
% EVH2 and EVH3 are branches H2 and H3;


%%
%% Superposing with results obtained without complex mapping

figure(120);hold off;
subplot(2,1,1);
plot(Re_Range,real(EVH2),'r-','linewidth',2);hold on;
plot(Re_Range,real(EVH3),'b-','linewidth',2);
plot(Re_Range,real(EVH1),'g-','linewidth',2);
plot(Re_Range,0*real(EVH2),'k:');ylim([-.2 .4]);xlim([1200  2000]);
xlabel('Re');ylabel('\sigma')
subplot(2,1,2);hold off;
plot(Re_Range,imag(EVH2),'r:',Re_Range,imag(EVH3),'b:',Re_Range,imag(EVH1),'g:');hold on;
plot(Re_Range(real(EVH2)>0),imag(EVH2(real(EVH2)>0)),'r-','linewidth',2);hold on;
plot(Re_Range(real(EVH3)>0),imag(EVH3(real(EVH3)>0)),'b-','linewidth',2);ylim([0 5]);xlim([1200  2000]);
xlabel('Re');ylabel('\omega')
saveas(gcf,'Eigenvalues_onehole_beta1','png')
saveas(gcf,'Eigenvalues_onehole_beta1','fig')


%EV1_nomap = EVH1;
%EV2_nomap = EVH2;
%EV3_nomap = EVH3;
%Re_Range_nomap = Re_Range;
save('results_nomap','EVH1','EVH2','EVH3','Re_Range')


%%
%computing spectrum with various shifts
figure(40);hold on;
bf= SF_BaseFlow(bf,'Re',1700);
SpectrumA_0i = SF_Stability(bf,'shift',0.5+0.5i,'nev',20,'type','A','m',0);
plot(SpectrumA_0i,'x')
SpectrumA_1i = SF_Stability(bf,'shift',0.5+1i,'nev',20,'type','A','m',0);
plot(SpectrumA_1i,'x')
SpectrumA_2i = SF_Stability(bf,'shift',0.5+2i,'nev',20,'type','A','m',0);
plot(SpectrumA_2i,'x')
SpectrumA_3i = SF_Stability(bf,'shift',0.5+3i,'nev',20,'type','A','m',0);
plot(SpectrumA_3i,'x')
SpectrumA_4i = SF_Stability(bf,'shift',0.5+4i,'nev',20,'type','A','m',0);
plot(SpectrumA_4i,'x')
SpectrumD_0i = SF_Stability(bf,'shift',0.5+0.5i,'nev',20,'type','D','m',0);
plot(SpectrumD_0i,'+')
SpectrumD_1i = SF_Stability(bf,'shift',0.5+1i,'nev',20,'type','D','m',0);
plot(SpectrumD_1i,'+')
SpectrumD_2i = SF_Stability(bf,'shift',0.5+2i,'nev',20,'type','D','m',0);
plot(SpectrumD_2i,'+')
SpectrumD_3i = SF_Stability(bf,'shift',0.5+3i,'nev',20,'type','D','m',0);
plot(SpectrumD_3i,'+')
SpectrumD_4i = SF_Stability(bf,'shift',0.5+4i,'nev',20,'type','D','m',0);
plot(SpectrumD_4i,'+')

Spectrum_1700_NoMap = [SpectrumA_0i;SpectrumA_1i;SpectrumA_2i;SpectrumA_3i;conj(SpectrumA_0i);SpectrumA_4i;conj(SpectrumA_1i);conj(SpectrumA_2i);conj(SpectrumA_3i);conj(SpectrumA_4i)];
save('Spectrum_1700_NoMap','Spectrum_1700_NoMap');

%%
figure(40);
plot(Spectrum_1700_NoMap,'+')


%%
%computing spectrum with various shifts
figure(40);hold on;
bf= SF_BaseFlow(bf,'Re',2000);
SpectrumA_0i = SF_Stability(bf,'shift',0.5+0.5i,'nev',20,'type','A','m',0);
plot(SpectrumA_0i,'x')
SpectrumA_1i = SF_Stability(bf,'shift',0.5+1i,'nev',20,'type','A','m',0);
plot(SpectrumA_1i,'x')
SpectrumA_2i = SF_Stability(bf,'shift',0.5+2i,'nev',20,'type','A','m',0);
plot(SpectrumA_2i,'x')
SpectrumA_3i = SF_Stability(bf,'shift',0.5+3i,'nev',20,'type','A','m',0);
plot(SpectrumA_3i,'x')
SpectrumA_4i = SF_Stability(bf,'shift',0.5+4i,'nev',20,'type','A','m',0);
plot(SpectrumA_4i,'x')
SpectrumD_0i = SF_Stability(bf,'shift',0.5+0.5i,'nev',20,'type','D','m',0);
plot(SpectrumD_0i,'+')
SpectrumD_1i = SF_Stability(bf,'shift',0.5+1i,'nev',20,'type','D','m',0);
plot(SpectrumD_1i,'+')
SpectrumD_2i = SF_Stability(bf,'shift',0.5+2i,'nev',20,'type','D','m',0);
plot(SpectrumD_2i,'+')
SpectrumD_3i = SF_Stability(bf,'shift',0.5+3i,'nev',20,'type','D','m',0);
plot(SpectrumD_3i,'+')
SpectrumD_4i = SF_Stability(bf,'shift',0.5+4i,'nev',20,'type','D','m',0);
plot(SpectrumD_4i,'+')

Spectrum_1700_NoMap = [SpectrumA_0i;SpectrumA_1i;SpectrumA_2i;SpectrumA_3i;conj(SpectrumA_0i);SpectrumA_4i;conj(SpectrumA_1i);conj(SpectrumA_2i);conj(SpectrumA_3i);conj(SpectrumA_4i)];
save('Spectrum_2000_NoMap','Spectrum_2000_NoMap');

%%
figure(40);
plot(Spectrum_2000_NoMap,'+')

