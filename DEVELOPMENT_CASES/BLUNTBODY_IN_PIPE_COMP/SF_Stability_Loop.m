function EV = SF_Stability_Loop(bf,Re_Range,guess_ev);
%
% Construction of a "branch" lambda(Re) with a loop over Re.
%
% Usage : EV =  SF_Stability_Loop(bf,Re_range,guess_ev);
% Re_range is an array of values, typically [Restart:Restep:Reend]
% guess_ev is an approximate value of the eigenvalue at Re=Re_Range(1)
% (will be used as guess for first step, then continuation mode will be used)
%
% NB this program is designed to work for an axisymmetric blunt body, 
% possibly to be adapted to your case...

% first step using guess
guessI = guess_ev;
bf=SF_BaseFlow(bf,'Re',Re_Range(1));
EV = SF_Stability(bf,'m',1,'shift',guessI,'nev',1,'type','D');

% then loop...
for Re = Re_Range(2:end)
        bf = SF_BaseFlow(bf,'Re',Re);
        ev = SF_Stability(bf,'m',1,'nev',1,'shift','cont');
        disp(['Re = ',num2str(Re),' : lambda = ',num2str(ev)])
        EV = [EV ev];
end

end