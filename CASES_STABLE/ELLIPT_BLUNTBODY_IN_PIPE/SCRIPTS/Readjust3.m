%Pour la deuxième paire de modes INSTATIONNAIRES qui apparaissent en
%confinement pour des Re>900
%Pour avoir les valeurs propres à un nouveau Reynolds et les visualiser
%Entrée : guessS et guessI


% 1er mode


bf=SF_BaseFlow(bf,'Re',ReI1i); 
bf=SF_Adapt(bf,'Hmax',Hmax); 

[ev01,eigenmode01] = SF_Stability(bf,'m',1,'shift',guessReI1,'nev',1,'plotspectrum','yes');   

ev01

bf=SF_BaseFlow(bf,'Re',1000); 
bf=SF_Adapt(bf,'Hmax',Hmax); 

bf=SF_BaseFlow(bf,'Re',1100); 
bf=SF_Adapt(bf,'Hmax',Hmax); 

% 2eme mode


bf=SF_BaseFlow(bf,'Re',ReI2i); 
bf=SF_Adapt(bf,'Hmax',Hmax); 

[ev00,eigenmode00] = SF_Stability(bf,'m',1,'shift',guessReI2,'nev',1,'plotspectrum','yes');   

ev00
