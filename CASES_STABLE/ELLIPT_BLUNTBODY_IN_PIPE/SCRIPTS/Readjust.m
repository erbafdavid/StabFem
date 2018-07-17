%Point de départ pour les méthodes itératives:
%Obtenir les valeurs propres des modes à des nombres de Reynolds choisis 
%Entrée :   guessS et guessI (coordonnées supposées des modes)
%           ReSi et ReIi (nombres de Reynolds légèrement supérieurs 
%                       aux nombres de Reynolds critiques recherchés.)




% 1er mode

bf=SF_BaseFlow(bf,'Re',ReSi); 
bf=SF_Adapt(bf,'Hmax',Hmax); 

[ev00,eigenmode00] = SF_Stability(bf,'m',1,'shift',guessReS,'nev',1,'plotspectrum','yes');   


ev00


% Calcul du bae flow inermédiaire

ReInt=(ReIi+ReSi)/2;

        bf=SF_BaseFlow(bf,'Re',ReInt); 
        bf=SF_Adapt(bf,'Hmax',Hmax);


%2eme mode

bf=SF_BaseFlow(bf,'Re',ReIi); 
bf=SF_Adapt(bf,'Hmax',Hmax); 

[ev01,eigenmode01] = SF_Stability(bf,'m',1,'shift',guessReI,'nev',1,'plotspectrum','yes');   


ev01
