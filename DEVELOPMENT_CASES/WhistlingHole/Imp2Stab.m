function res = Imp2Stab(bf,OmegaS);
% this function finds predictions for the eigenvalue problem based on
% impedance predictions.
% Input : 
%   bf valid baseflow, 
%   OmegaS small array of values in the vicinity of omegazero.
% 
% Output :
%   res.omega0
%   res.Z0
%   res.dZ0
%   res.sigma1

if(length(OmegaS)<2)
    error('Error : you should provide an array of at least 3 values for omega !');
end

%IP = SF_Launch('LoopImpedance.edp','Params',Omegarange,'DataFile',['Impedance_Chi' num2str(chi) '_Re' num2str(Re) '.ff2m']);
IP = SF_LinearForced(bf,OmegaS)

IP.Za2 = abs(IP.Z).^2;
polyZa2 = polyfit(IP.omega,IP.Za2,2);
polyZ = polyfit(IP.omega,IP.Z,2);
Omegazero = -polyZa2(2)/(2*polyZa2(1));

OmegaSS = linspace(OmegaS(1),OmegaS(end),100);
Za2SS = polyval(polyZa2,OmegaSS);
ZSS = polyval(polyZ,OmegaSS);
Zzero = polyval(polyZ,Omegazero);
dZzero = 2*Omegazero*polyZ(1)+polyZ(2);



figure(10);hold off;
subplot(1,2,1);hold off;
plot(IP.omega,real(IP.Z),'r+',IP.omega,imag(IP.Z),'b+',IP.omega,abs(IP.Z).^2,'g+');hold on;
plot(OmegaSS,real(ZSS),'r:',OmegaSS,imag(ZSS),'b:',OmegaSS,Za2SS,'g:');hold on;
plot(Omegazero,real(Zzero),'ro',Omegazero,imag(Zzero),'bo',Omegazero,polyval(polyZa2,Omegazero),'go');
plot(OmegaSS,real(Zzero+dZzero*(OmegaSS-Omegazero)),'r--',OmegaSS,imag(Zzero+dZzero*(OmegaSS-Omegazero)),'b--');hold on;
box on; axis on;
%plot(IP.omega,0*real(IP.Z),'k:','LineWidth',1)
xlabel('\omega');ylabel('Z_r, Z_i');
title(['Impedance for chi =1, Re = ',num2str(bf.Re),' and quad. interpol.'] );
subplot(1,2,2);hold off;
plot(real(IP.Z),imag(IP.Z),'b+');hold on;
plot(real(ZSS),imag(ZSS),'b:');hold on;
plot(real(Zzero),imag(Zzero),'bo');
plot(real(Zzero+dZzero*(OmegaSS-Omegazero)),imag(Zzero+dZzero*(OmegaSS-Omegazero)),'b--');hold on;
axis equal;
pause(0.1);

res.Re = bf.Re;
res.omega0 = Omegazero;
res.Z0 = Zzero;
res.dZ0 = dZzero;
res.sigma1 = -Zzero/dZzero/1i


end


