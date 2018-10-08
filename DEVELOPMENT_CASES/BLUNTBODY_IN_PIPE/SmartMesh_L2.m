
function bf = SmartMesh_L2;
%
% This function will create an adapted mesh for a blunt body of diameter 1, 
% overall length L = 6 comprizing an oblate speroidal noze of length 1 and
% afterbody of lenght 5.
%

Rbody = 0.5; Lel = 1; Lcyl = 1; Rpipe = 1; xmin = -10; xmax = 60;Lbody=Lcyl+Lel;
bctype = 1;

    bf = SF_Init('meshInit_BluntBodyInTube.edp',[Rbody Lel Lcyl Rpipe xmin xmax bctype]); 
    Re_start = [10 , 30, 60, 100 , 250, 500]; % values of Re for progressive increasing up to end
    for Rei = Re_start
        bf=SF_BaseFlow(bf,'Re',Rei); 
        bf=SF_Adapt(bf,'Hmax',1);
    end
 
  % adapting mesh on eigenmode structure as well      
 shift =  0.1654 + 0.8358i;
 ev = SF_Stability(bf,'m',1,'shift',shift,'nev',10);
 shift=ev(1);
 [ev,eigenmode] = SF_Stability(bf,'m',1,'shift',shift,'nev',1,'type','A');
 [bf,eigenmode] = SF_Adapt(bf,eigenmode); 
 [ev,eigenmode] = SF_Stability(bf,'m',1,'shift',shift,'nev',1,'type','A');
 [bf,eigenmode] = SF_Adapt(bf,eigenmode); 
 
 % adjust range for plots
 bf.mesh.xlim = [-2 10];
 bf.mesh.ylim = [0 1];
 
end