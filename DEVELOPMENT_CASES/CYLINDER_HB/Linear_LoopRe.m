function LINres = Linear_LoopRe(bf,shiftinit,Re_LIN)

bf=SF_BaseFlow(bf,'Re',Re_LIN(1));
[ev,em] = SF_Stability(bf,'shift',shiftinit,'nev',1,'type','D');
LINres.Re = Re_LIN;
LINres.Fx = []; LINres.Lx = [];LINres.lambda=[];
    for Re = LINres.Re
        bf = SF_BaseFlow(bf,'Re',Re);
        [ev,em] = SF_Stability(bf,'nev',1,'shift','cont','nev',1,'type','D');
        if(em.iter<0) 
            disp(['warning : divergence in eigenvalue computation for Re = ',num2sdtr(Re)]);
            break;
        end
        LINres.Fx= [LINres.Fx,bf.Fx];
        LINres.Lx = [LINres.Lx,bf.Lx];
        LINres.lambda = [LINres.lambda ev];
    end
    LINres.Re = LINres.Re(1:length(LINres.lambda)); % truncate if the computation has failed at some point
end