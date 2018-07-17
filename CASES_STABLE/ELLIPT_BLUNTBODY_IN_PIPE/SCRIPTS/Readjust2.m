%Pour la deuxième paire de modes qui apparaissent en confinement
%Pour avoir les valeurs propres à un nouveau Reynolds et les visualiser
%Entrée : guessS et guessI


% 1er mode


bf=SF_BaseFlow(bf,'Re',ReIi); 
bf=SF_Adapt(bf,'Hmax',Hmax); 

[ev01,eigenmode01] = SF_Stability(bf,'m',1,'shift',guessReI,'nev',1,'plotspectrum','yes');   

ev01


% Calcul du base flow intermédiaire

ReInt=(ReIi+ReSi)/2;

        bf=SF_BaseFlow(bf,'Re',ReInt); 
        bf=SF_Adapt(bf,'Hmax',Hmax);

        
% 2eme mode

bf=SF_BaseFlow(bf,'Re',ReSi); 
bf=SF_Adapt(bf,'Hmax',Hmax); 

[ev00,eigenmode00] = SF_Stability(bf,'m',1,'shift',guessReS,'nev',1,'plotspectrum','yes');   

ev00
