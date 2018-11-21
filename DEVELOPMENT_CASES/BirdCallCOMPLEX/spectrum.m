%% Computation of the spectrum

run('../../SOURCES_MATLAB/SF_Start.m');
figureformat='png'; AspectRatio = 0.56; % for figures
tinit = tic;
verbosity=20;
Ma = 0.05;

meshRef = 1.0;
LA = 200;
Params =[20 20 LA 35 0.2 15 LA 35 0.2]

ffmesh = importFFmesh('./WORK/MESHES/mesh_adapt12_Re1600_Ma0.05.msh')
bf = importFFdata(ffmesh,'./WORK/BASEFLOWS/BaseFlow_adapt12_Re1600_Ma0.05.ff2m')

spectrum = [];
spectrumStruct = [];
Imag_Range = [2:0.5:10];
Real_Range = [1.0:-0.1:-0.5];
for realTerm = Real_Range
    for imagTerm = Imag_Range
        evSearch = realTerm - imagTerm*1i;
        [ev,em] = SF_Stability(bf,'shift',evSearch,'m',0,'nev',10,'type','D')
        spectrum = [spectrum, ev ];
        spectrumStruct = [spectrumStruct, em];
    end
end

Params =[10000 1000000 LA 35 0.0 10000 LA 100000 0.0];
bf=SF_BaseFlow(bf,'Re',1600,'Mach',Ma,'ncores',1,'type','NEW','MappingParams',Params);
spectrumNoCM = [];
spectrumStructNoCM = [];
Imag_Range = [2:0.5:10];
Real_Range = [1.0:-0.1:-0.5];
for realTerm = Real_Range
    for imagTerm = Imag_Range
        evSearch = realTerm - imagTerm*1i;
        [ev,em] = SF_Stability(bf,'shift',evSearch,'m',0,'nev',10,'type','D')
        spectrumNoCM = [spectrumNoCM, ev ];
        spectrumStructNoCM = [spectrumStructNoCM, em];
    end
end