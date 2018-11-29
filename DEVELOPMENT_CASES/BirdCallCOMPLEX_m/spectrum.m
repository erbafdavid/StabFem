run('../../SOURCES_MATLAB/SF_Start.m');
figureformat='png'; AspectRatio = 0.56; % for figures
tinit = tic;
verbosity=20;
Ma = 0.05;

if(exist('../BirdCallComplex','dir') ~= 0)
    ffmesh = importFFmesh('../BirdCallComplex/MESH30x30DIRECT/MESHES/mesh_adapt9_Re1280_Ma0.05.msh');
    bf = importFFdata(ffmesh,'../BirdCallComplex/MESH30x30DIRECT/MESHES/BaseFlow_adapt9_Re1280_Ma0.05.ff2m');
else
    bf = smartmesh('Ma',0.05,'MeshRefine',1,'RefineType','S');
end

Re = 320;
LA = 100000;
LAy = 100000;
Params =[10000 10000 LA 10.0 0 10000 LAy 10000 0]
bf = SF_SetMapping(bf,'mappingtype','box','mappingparams',Params);
bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');

%% COMPUTATION OF THE SPECTRA WITHOUT COMPLEX MAPPING

spectrumNOCM = [];
spectrumStructNOCM = [];
Imag_Range = [-9.75:0.5:10];
Real_Range = [0.0];
for realTerm = Real_Range
    for imagTerm = Imag_Range
        evSearch = realTerm - imagTerm*1i;
        [ev,em] = SF_Stability(bf, 'shift', evSearch, 'm', 0, 'nev', 5, 'type', 'D')
        spectrumNOCM = [spectrumNOCM, ev];
        spectrumStructNOCM = [spectrumStructNOCM, em];
    end
end

%% COMPUTATION OF THE SPECTRA WITH COMPLEX MAPPING
LA = 200;
LAy = 200;
Params =[10 10 LA 10.0 0.1 10.0 LAy 10.0 0.1]
bf = SF_SetMapping(bf,'mappingtype','box','mappingparams',Params);
bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');
Params =[10 10 LA 10.0 0.15 10.0 LAy 10.0 0.15]
bf = SF_SetMapping(bf,'mappingtype','box','mappingparams',Params);
bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');

LA = 60;
LAy = 60;
Params =[10 10 LA 10.0 0.1 10.0 LAy 10.0 0.1]
bf = SF_SetMapping(bf,'mappingtype','box','mappingparams',Params);
bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');
[ev,em] = SF_Stability(bf, 'shift', 0.4-4.9i, 'm', 0, 'nev', 5, 'type', 'D')

spectrumCM0 = [ev,spectrumCM0];
spectrumStruct = [];
for realTerm = Real_Range
    for imagTerm = Imag_Range
        evSearch = realTerm - imagTerm*1i;
        [ev,em] = SF_Stability(bf, 'shift', evSearch, 'm', 0, 'nev', 5, 'type', 'D')
        spectrumCM0 = [spectrumCM0, ev];
    end
end

LA = 60;
LAy = 60;
Params =[10 10 LA 10.0 0.15 10.0 LAy 10.0 0.15]
bf = SF_SetMapping(bf,'mappingtype','box','mappingparams',Params);
bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');


spectrumCM = [];
spectrumStruct = [];
for realTerm = Real_Range
    for imagTerm = Imag_Range
        evSearch = realTerm - imagTerm*1i;
        [ev,em] = SF_Stability(bf, 'shift', evSearch, 'm', 0, 'nev', 5, 'type', 'D')
        spectrumCM = [spectrumCM, ev];
        spectrumStruct = [spectrumStruct, em];
    end
end



LA = 50;
LAy = 50;
Params =[10 10 LA 10.0 0.1 10.0 LAy 10.0 0.1]
bf = SF_SetMapping(bf,'mappingtype','box','mappingparams',Params);
bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');

spectrumCM2 = [];
for realTerm = Real_Range
    for imagTerm = Imag_Range
        evSearch = realTerm - imagTerm*1i;
        [ev,em] = SF_Stability(bf, 'shift', evSearch, 'm', 0, 'nev', 5, 'type', 'D')
        spectrumCM2 = [spectrumCM2, ev];
    end
end


LA = 100000;
LAy = 100000;
Params =[10 10 LA 10.0 0.15 10.0 LAy 10.0 0.15]
bf = SF_SetMapping(bf,'mappingtype','box','mappingparams',Params);
bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');

spectrumCMNOST = [];
for realTerm = Real_Range
    for imagTerm = Imag_Range
        evSearch = realTerm - imagTerm*1i;
        [ev,em] = SF_Stability(bf, 'shift', evSearch, 'm', 0, 'nev', 5, 'type', 'D')
        spectrumCMNOST = [spectrumCMNOST, ev];
    end
end

LA = 100000;
LAy = 100000;
Params =[10 10 LA 10.0 0.1 10.0 LAy 10.0 0.1]
bf = SF_SetMapping(bf,'mappingtype','box','mappingparams',Params);
bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');

spectrumCMNOST0 = [];
for realTerm = Real_Range
    for imagTerm = Imag_Range
        evSearch = realTerm - imagTerm*1i;
        [ev,em] = SF_Stability(bf, 'shift', evSearch, 'm', 0, 'nev', 5, 'type', 'D')
        spectrumCMNOST0 = [spectrumCMNOST0, ev];
    end
end


figure();
plot(-imag(spectrumNOCM),real(spectrumNOCM),'kx');
hold on;
plot(-imag(spectrumCM0),real(spectrumCM0),'r+');
plot(-imag(spectrumCM),real(spectrumCM),'b+');
%plot(-imag(spectrumCM2),real(spectrumCM2),'g+');
plot(-imag(spectrumCMNOST),real(spectrumCMNOST),'c+');
plot(-imag(spectrumCMNOST0),real(spectrumCMNOST0),'m+');

pause();

%% COMPUTATION FOR 640
Re = 640;
LA = 100000;
LAy = 100000;
Params =[10000 10000 LA 10.0 0 10000 LAy 10000 0]
bf = SF_SetMapping(bf,'mappingtype','box','mappingparams',Params);
bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');

%% COMPUTATION OF THE SPECTRA WITHOUT COMPLEX MAPPING

spectrumNOCM = [];
spectrumStructNOCM = [];
Imag_Range = [-9.75:0.5:10];
Real_Range = [0.0];
for realTerm = Real_Range
    for imagTerm = Imag_Range
        evSearch = realTerm - imagTerm*1i;
        [ev,em] = SF_Stability(bf, 'shift', evSearch, 'm', 0, 'nev', 5, 'type', 'D')
        spectrumNOCM = [spectrumNOCM, ev];
        spectrumStructNOCM = [spectrumStructNOCM, em];
    end
end

%% COMPUTATION OF THE SPECTRA WITH COMPLEX MAPPING
LA = 200;
LAy = 200;
Params =[10 10 LA 10.0 0.1 10.0 LAy 10.0 0.1]
bf = SF_SetMapping(bf,'mappingtype','box','mappingparams',Params);
bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');
Params =[10 10 LA 10.0 0.15 10.0 LAy 10.0 0.15]
bf = SF_SetMapping(bf,'mappingtype','box','mappingparams',Params);
bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');

LA = 60;
LAy = 60;
Params =[10 10 LA 10.0 0.1 10.0 LAy 10.0 0.1]
bf = SF_SetMapping(bf,'mappingtype','box','mappingparams',Params);
bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');

spectrumCM0 = [];
spectrumStruct = [];
for realTerm = Real_Range
    for imagTerm = Imag_Range
        evSearch = realTerm - imagTerm*1i;
        [ev,em] = SF_Stability(bf, 'shift', evSearch, 'm', 0, 'nev', 5, 'type', 'D')
        spectrumCM0 = [spectrumCM0, ev];
    end
end

LA = 60;
LAy = 60;
Params =[10 10 LA 10.0 0.15 10.0 LAy 10.0 0.15]
bf = SF_SetMapping(bf,'mappingtype','box','mappingparams',Params);
bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');


spectrumCM = [];
spectrumStruct = [];
for realTerm = Real_Range
    for imagTerm = Imag_Range
        evSearch = realTerm - imagTerm*1i;
        [ev,em] = SF_Stability(bf, 'shift', evSearch, 'm', 0, 'nev', 5, 'type', 'D')
        spectrumCM = [spectrumCM, ev];
        spectrumStruct = [spectrumStruct, em];
    end
end



LA = 50;
LAy = 50;
Params =[10 10 LA 10.0 0.1 10.0 LAy 10.0 0.1]
bf = SF_SetMapping(bf,'mappingtype','box','mappingparams',Params);
bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');

spectrumCM2 = [];
for realTerm = Real_Range
    for imagTerm = Imag_Range
        evSearch = realTerm - imagTerm*1i;
        [ev,em] = SF_Stability(bf, 'shift', evSearch, 'm', 0, 'nev', 5, 'type', 'D')
        spectrumCM2 = [spectrumCM2, ev];
    end
end


ffmesh = importFFmesh('../BirdCallComplex/MESH30x30DIRECT/MESHES/mesh_adapt9_Re1280_Ma0.05.msh');
bf = importFFdata(ffmesh,'../BirdCallComplex/MESH30x30DIRECT/MESHES/BaseFlow_adapt9_Re1280_Ma0.05.ff2m');

Re = 640
LA = 100000;
LAy = 100000;
Params =[10 10 LA 10.0 0.1 10.0 LAy 10.0 0.1]
bf = SF_SetMapping(bf,'mappingtype','box','mappingparams',Params);
bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');
[ev,em] = SF_Stability(bf, 'shift', 0.4-4.9i, 'm', 0, 'nev', 5, 'type', 'D')

spectrumCMNOST0 = [spectrumCMNOST0,ev];
for realTerm = Real_Range
    for imagTerm = Imag_Range
        evSearch = realTerm - imagTerm*1i;
        [ev,em] = SF_Stability(bf, 'shift', evSearch, 'm', 0, 'nev', 5, 'type', 'D')
        spectrumCMNOST0 = [spectrumCMNOST0, ev];
    end
end

LA = 100000;
LAy = 100000;
Params =[10 10 LA 10.0 0.15 10.0 LAy 10.0 0.15]
bf = SF_SetMapping(bf,'mappingtype','box','mappingparams',Params);
bf=SF_BaseFlow(bf,'Re',Re,'Mach',Ma,'ncores',1,'type','NEW');

spectrumCMNOST = [];
for realTerm = Real_Range
    for imagTerm = Imag_Range
        evSearch = realTerm - imagTerm*1i;
        [ev,em] = SF_Stability(bf, 'shift', evSearch, 'm', 0, 'nev', 5, 'type', 'D')
        spectrumCMNOST = [spectrumCMNOST, ev];
    end
end


figure();
plot(-imag(spectrumNOCM),real(spectrumNOCM),'kx');
hold on;
plot(-imag(spectrumCM0),real(spectrumCM0),'b^');
plot(-imag(spectrumCM),real(spectrumCM),'r^');
%plot(-imag(spectrumCM2),real(spectrumCM2),'g+');
plot(-imag(spectrumCMNOST),real(spectrumCMNOST),'rs');
plot(-imag(spectrumCMNOST0),real(spectrumCMNOST0),'bs');
save('eigs640.mat')

