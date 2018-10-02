function HBres = HB1_LoopRe(bfT,emT,Re_TAB)

Rec = bfT.Re;  Fxc = bfT.Fx; 
Lxc=bfT.Lx;    Omegac=imag(emT.lambda);

Res = Re_TAB(2);
%[ev,em] = SF_Stability(bfT,'shift',emT.lambda,'nev',1,'type','S'); % type S = direct+adjoint (adjoint is needed for WNL)
[wnl,meanflow,mode,mode2] = SF_WNL(bfT,emT,'Retest',Res);


disp('HB1 model (or SC model) on the range [Rec , 200]');
HBres.Re = Re_TAB;
HBres.Lx = [Lxc]; HBres.Fx0 = [Fxc]; HBres.omega = [Omegac]; HBres.Aenergy  = [0]; HBres.Fy = [0];

for Re = HBres.Re(2:end)
    [meanflow,mode] = SF_HB1(meanflow,mode,'Re',Re);
    if(meanflow.iter>0)
        HBres.Lx = [HBres.Lx meanflow.Lx];
        HBres.Fx0 = [HBres.Fx0 meanflow.Fx];
        HBres.omega = [HBres.omega imag(mode.lambda)];
        HBres.Aenergy  = [HBres.Aenergy mode.AEnergy];
        HBres.Fy = [HBres.Fy mode.Fy];
    else
        disp(['####### Loop HB2 : divergenge at Re = ',num2str(Re)]);
        break;
    end
end
HBres.Re = HBres.Re(1:length(HBres.Lx)); % truncate if the computation has failed at some point

end %Function HB1_LoopRe