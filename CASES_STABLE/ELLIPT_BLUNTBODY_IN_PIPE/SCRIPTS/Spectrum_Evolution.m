       


        
Re = [300:50:700];   
         
    for Rej = Re
        bf=SF_BaseFlow(bf,'Re',Rej); 
        bf=SF_Adapt(bf,'Hmax',Hmax);
        
 [ev1,eigenmode1] = SF_Stability(bf,'m',1,'shift',0,'nev',10,'plotspectrum','yes');   
 [ev2,eigenmode2] = SF_Stability(bf,'m',1,'shift',0.4i,'nev',10,'plotspectrum','yes');   
 [ev3,eigenmode3] = SF_Stability(bf,'m',1,'shift',0.8i,'nev',10,'plotspectrum','yes');   
 [ev4,eigenmode4] = SF_Stability(bf,'m',1,'shift',1.2i,'nev',10,'plotspectrum','yes');   
 [ev5,eigenmode5] = SF_Stability(bf,'m',1,'shift',1.6i,'nev',10,'plotspectrum','yes');   
 [ev6,eigenmode6] = SF_Stability(bf,'m',1,'shift',2i,'nev',10,'plotspectrum','yes');   
 [ev7,eigenmode7] = SF_Stability(bf,'m',1,'shift',2.4i,'nev',10,'plotspectrum','yes');   

 pause(0.1);

evtot=[ev1 ev2 ev3 ev4 ev5 ev6 ev7]    
        
    end
   
 