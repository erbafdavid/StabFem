
function bf = SmartMesh_Hole()

sigmaguess = 0.9 + 5.76i;

disp('generating base flow and mesh for a birdcall')
disp(['Adaptation to mode for Re = 1000, and lambda = ',num2str(sigmaguess)])
bf = SF_Init('Mesh_BirdCall.edp'); %% this is the mesh from Benjamin/Raffaele
%figure();plotFF(bf,'mesh','xlim',[-1 5],'ylim',[0 4]);
ReTab = [10 100 200 300 400 600 700 800 900 1000]
for Re = ReTab
    bf = SF_BaseFlow(bf,'Re',Re);
    if(Re>100) 
        bf = SF_Adapt(bf,'Hmax',.5);
    end
end

 
[ev,em] = SF_Stability(bf,'m',0,'shift',sigmaguess,'nev',1,'type','D');
bf=SF_Adapt(bf,em,'Hmax',.5); 
[ev,em] = SF_Stability(bf,'m',0,'shift',sigmaguess,'nev',1,'type','D');
bf=SF_Adapt(bf,em,'Hmax',.5); 

end