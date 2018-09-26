% This script computes the impedances of a jet through a non-zero thickness
% hole of aspect ratio chi. It draws the impedance curves and the Nyquist
% diagrams.



run('../../SOURCES_MATLAB/SF_Start.m');
verbosity=10;


%% chi = 1

chi = 1;Re = 1000;
if(exist('bf'))
    bf = SF_BaseFlow(bf,'Re',Re);
else
    bf = SmartMesh_Hole(chi);
end


REtab = [800 1200 1500];OmegaRange = [0 .1 8];ColorRange='gmr';
for k = 1:length(REtab)
    Re = REtab(k);
    bf = SF_BaseFlow(bf,'Re',Re);
    II(k) = SF_Launch('LoopImpedance.edp','Params',OmegaRange,'DataFile',['Impedance_Chi' num2str(chi) '_Re' num2str(Re) '.ff2m']);
    figure(1);hold on;plot(II(k).Omega,real(II(k).Z),[ColorRange(k) '-']);plot(II(k).Omega,imag(II(k).Z),[ColorRange(k) '--']);
    figure(2);hold on;plot(II(k).Z,[ColorRange(k) '-']);
end

figure(1);xlabel('\Omega'),ylabel('Z_r,Z_i');legend('Z_r, Re=800', 'Z_i, Re=800', 'Z_r, Re=1200', 'Z_i, Re=1200','Z_r, Re=1500', 'Z_i, Re=1500' );
figure(2);xlabel('Z_r'),ylabel('Z_i');legend('Re=800', 'Re=1200', 'Re=1500' );
