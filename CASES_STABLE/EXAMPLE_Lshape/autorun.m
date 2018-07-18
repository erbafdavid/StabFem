function value = autorun(isfigures);
% Autorun function for StabFem. 
% This function will produce sample results for the case EXAMPLE_Lshape
%
% USAGE : 
% autorun(0) -> automatic check
% autorun(1) -> produces the figures used for the manual


value=0;
run('../../SOURCES_MATLAB/SF_Start.m');ffdatadir = './';verbosity=0;

% Generation of the mesh
Ndensity =40;
ffmesh=SF_Mesh('Lshape_Mesh.edp','Params',Ndensity)

if(isfigures)
    mkdir FIGURES
    figure();plotFF(ffmesh,'title','Mesh for L-shape body'); 
    set(gca,'FontSize', 18); saveas(gca,'FIGURES/Lshape_Mesh','png');
    pause(1);
end;

% importation and plotting of a real P1 field : temperature
heatS=SF_Launch('Lshape_Steady.edp','Mesh',ffmesh)
if(isfigures) 
    figure();plotFF(heatS,'T','title', 'Solution of the steady heat equation on a L-shaped domain'); 
    set(gca,'FontSize', 18); saveas(gca,'FIGURES/Lshape_T0','png');
    pause(1);
end;

% importation and plotting of data not associated to a mesh : temperature along a line
heatCut = importFFdata('Heat_1Dcut.ff2m')
if(isfigures) figure();plot(heatCut.Xcut,heatCut.Tcut);
    title('Temperature along a line : T(x,y=0.25)') 
    set(gca,'FontSize', 18); saveas(gca,'FIGURES/Lshape_T0_Cut','png');
    pause(1);
end;

critere1 = heatCut.Tcut(50);
critere1REF = 0.034019400000000;

disp('##### autorun test 1 : Steady temperature at a given point');
error1 = abs(critere1-critere1REF)
if(error1>1e-3)
    value = value+1
end

% importation and plotting of a complex P1 field : temperature for unsteady problem
heatU=SF_Launch('Lshape_Unsteady.edp','Params',100,'Mesh',ffmesh,'DataFile','Heat_Unsteady.ff2m');
if(isfigures) 
    figure();plotFF(heatU,'Tc.re','title',['Ti: real(colors) part']) 
    set(gca,'FontSize', 18); saveas(gca,'FIGURES/Lshape_Tc','png');
end


critere2 = max(imag(heatU.Tc));
critere2REF = 0.506614000000000;

disp('##### autorun test 2 : Unsteady temperature at a given point');
error2 = abs(critere2-critere2REF)

if(error2>1e-3)
    value = value+1
end

end
