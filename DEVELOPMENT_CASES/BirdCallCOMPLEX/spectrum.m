run('../../SOURCES_MATLAB/SF_Start.m');
figureformat='png'; AspectRatio = 0.56; % for figures
tinit = tic;
verbosity=20;
Ma = 0.05;

if(exist('bf','var'))
    ffmesh = importFFmesh('../BirdCallComplex/MESH30x30DIRECT/MESHES/mesh_adapt10_Re1600_Ma0.05.msh');
    bf = importFFdata(ffmesh,'../BirdCallComplex/MESH30x30DIRECT/MESHES/BaseFlow_adapt10_Re1600_Ma0.05.ff2m');
else
    bf = smartmesh('Ma',0.05,'MeshRefine',1,'RefineType','S');
end

Re = 320;
bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');

%% COMPUTATION OF THE SPECTRA WITHOUT COMPLEX MAPPING

spectrumNOCM = [];
spectrumStructNOCM = [];
Imag_Range = [0.5:0.5:10];
Real_Range = [1.0:-0.1:-0.5];
for realTerm = Real_Range
    for imagTerm = Imag_Range
        evSearch = realTerm - imagTerm*1i;
        [ev,em] = SF_Stability(bf, 'shift', evSearch, 'm', 0, 'nev', 10, 'type', 'D')
        spectrumNOCM = [spectrumNOCM, ev];
        spectrumStructNOCM = [spectrumStructNOCM, em];
    end
end

%% COMPUTATION OF THE SPECTRA WITH COMPLEX MAPPING
LA = 50;
LAy = 50;
Params =[10 10 LA 10.0 0.1 10.0 LAy 10.0 0.1]
bf = SF_SetMapping(bf,'mappingtype','box','mappingparams',Params);
bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');
Params =[10 10 LA 10.0 0.15 10.0 LAy 10.0 0.15]
bf = SF_SetMapping(bf,'mappingtype','box','mappingparams',Params);
bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');


spectrumCM = [];
spectrumStruct = [];
Imag_Range = [0.5:0.5:10];
Real_Range = [1.0:-0.1:-0.5];
for realTerm = Real_Range
    for imagTerm = Imag_Range
        evSearch = realTerm - imagTerm*1i;
        [ev,em] = SF_Stability(bf, 'shift', evSearch, 'm', 0, 'nev', 10, 'type', 'D')
        spectrumCM = [spectrumCM, ev];
        spectrumStruct = [spectrumStruct, em];
    end
end


