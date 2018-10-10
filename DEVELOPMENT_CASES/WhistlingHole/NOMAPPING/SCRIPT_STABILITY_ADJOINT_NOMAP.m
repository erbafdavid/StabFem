run('../../../SOURCES_MATLAB/SF_Start.m')

bf = SmartMesh_Hole_NoMap;

Re_Range = [2000 : -50 :1000];
Re_RangeUP = [2000 50 3000];

EVH2 = SF_Stability_LoopRe(bf,Re_Range,0.3+2.23i,'type','A','m',0);
EVH3 = SF_Stability_LoopRe(bf,Re_Range,0.22+4.33i,'type','A','m',0);
EVH2UP = SF_Stability_LoopRe(bf,Re_RangeUP,0.3+2.23i,'type','A','m',0);
EVH3UP  = SF_Stability_LoopRe(bf,Re_RangeUP,0.22+4.33i,'type','A','m',0);
% EVH2 and EVH3 are branches H2 and H3;
% I have one point on branch H1 : Re = 2000, lambda = -.04 + .562i
EVH1UP = SF_Stability_LoopRe(bf,Re_RangeUP,-.04+.562i,'type','A','m',0);

EVH2 = EV1
EVH3 = EV2

%%
figure(120);hold off;
subplot(2,1,1);
plot(Re_Range,real(EVH2),'r-','linewidth',2);hold on;
plot(Re_Range,real(EVH3),'b-','linewidth',2);
plot(Re_Range,0*real(EVH2),'k:');ylim([-.2 .4]);xlim([1200  2000]);
xlabel('Re');ylabel('\sigma')
subplot(2,1,2);hold off;
plot(Re_Range,imag(EVH2),'r:',Re_Range,imag(EVH3),'b:');hold on;
plot(Re_Range(real(EVH2)>0),imag(EVH2(real(EVH2)>0)),'r-','linewidth',2);hold on;
plot(Re_Range(real(EVH3)>0),imag(EVH3(real(EVH3)>0)),'b-','linewidth',2);ylim([0 5]);xlim([1200  2000]);
xlabel('Re');ylabel('\omega')
saveas(gcf,'Eigenvalues_onehole_beta1','png')

EV2_nomap = EVH2;
EV3_nomap = EVH3;
Re_Range_nomap = Re_Range;
save(EV1_nomap,EV2_nomap,EV3_nomap,Re_range_nomap,'results_nomap.mat')

