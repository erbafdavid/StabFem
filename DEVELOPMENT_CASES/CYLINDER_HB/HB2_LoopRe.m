
function HB2res = HB2_LoopRe(bfT,emT,Re_TAB)

Rec = bfT.Re;  Fxc = bfT.Fx; 
Lxc=bfT.Lx;    Omegac=imag(emT.lambda);

Res = Re_TAB(2);
[wnl,meanflow,mode,mode2] = SF_WNL(bfT,emT,'Retest',Res); % Here to generate a starting point 

HB2res.Re = Re_TAB;
HB2res.Lx = [Lxc]; HB2res.Fx0 = [Fxc]; HB2res.omega = [Omegac]; HB2res.Aenergy  = [0]; HB2res.Fy = [0];HB2res.Fx2 = [0];

for Re = HB2res.Re(2:end)
    if(meanflow.iter>=0)
        [meanflow,mode,mode2] = SF_HB2(meanflow,mode,mode2,'Re',Re);
        HB2res.Lx = [HB2res.Lx meanflow.Lx];
        HB2res.Fx0 = [HB2res.Fx0 meanflow.Fx];
        HB2res.omega = [HB2res.omega imag(mode.lambda)];
        HB2res.Aenergy  = [HB2res.Aenergy sqrt(mode.AEnergy^2+ mode2.AEnergy^2)];
        HB2res.Fy = [HB2res.Fy mode.Fy];
        HB2res.Fx2 = [HB2res.Fx2 mode2.Fx];
    else
        disp(['####### Loop HB2 : divergenge at Re = ',num2str(Re)]);
        break;
    end
end

HB2res.Re = HB2res.Re(1:length(HB2res.Lx)); % truncate if the computation has failed at some point

end% Function HB2LoopRe
