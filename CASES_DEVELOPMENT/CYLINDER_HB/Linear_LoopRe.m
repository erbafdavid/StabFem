function LINres = Linear_LoopRe(bf,shiftinit,Re_LIN)

bf=SF_BaseFlow(bf,'Re',Re_LIN(1));
[ev,em] = SF_Stability(bf,'shift',shiftinit,'nev',1,'type','D');
LINres.Re = Re_LIN;
LINres.Fx = []; LINres.Lx = [];LINres.lambda=[];
    for Re = LINres.Re
        bf = SF_BaseFlow(bf,'Re',Re);
        LINres.Fx= [LINres.Fx,bf.Fx];
        LINres.Lx = [LINres.Lx,bf.Lx];
        ev = SF_Stability(bf,'nev',1,'shift','cont','nev',1,'type','D');
        LINres.lambda = [LINres.lambda ev];
    end
    
end