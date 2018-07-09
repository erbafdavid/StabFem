

guess2 = -0.0229848+5.39569i



Re_Range = [400 408 409 410 420 430 440 450];
  
 %if(exist('DP0_Branch')==0)% to save time if already computed
     DP0_Branch = [];
     EVW = [];  
    [ev,em] = SF_Stability(bf,'m',0,'shift',guess2,'nev',1);
    for Re = Re_Range
        bf=SF_BaseFlow(bf,'Re',Re);
        DP0_Branch = [DP0_Branch,bf.Pup]
        if(Re==Re_Range(1)) shift = guess2; else shift = 'cont'; end;
        [ev,em] = SF_Stability(bf,'m',0,'shift',shift,'nev',1);
        if(em.iter~=-1) EVW = [EVW ev]; else break; end;
    end
 %end
 
 figure(3);
    plot(Re_Range,DP0_Branch);
    title('Pressure drop across the whistle as function of Re');
    

%    if(exist('EV2')==0)
%        EV2 = SF_Stability_LoopRe(bf,Re_Range,0,guess2,1,'Branch2.dat');
%    end

    
    figure(4);
    subplot(2,1,1);
    plot(Re_Range,real(EV2),'-*b');%,Re_Range,real(EV1),'-*g')
    title('growth rate Re(sigma) vs. Reynolds ; mode 1 (red) and mode 2 (blue)')
    subplot(2,1,2);
    plot(Re_Range,imag(EV2)/(2*pi),'-*b');%,Re_Range,imag(EV3)/(2*pi),'-*g')%,Re_Range,imag(EVI),'-*r')
    title('Strouhal vs. Reynolds');
    
    

pause(0.1);

%%% WEAKLY NONLINEAR ANALYSIS AT THE THRESHOLD


Rec = 408.56;
bf = SF_BaseFlow(bf,'Re',Rec)

%if(exist('emA')==0)
    bf = SF_BaseFlow(bf,'Re',Rec)
    [ev,em] = SF_Stability(bf,'Re',Rec,'m',0,'shift',5.39374i,'nev',1,'type','S');
    %bf.sensitivity = abs(em.ux1).*abs(emA.ux1)+abs(em.ur1).*abs(emA.ur1);
    plotFF(bf,'sensitivity');
%end
%if(exist('wnl')==0)
    wnl = SF_WNL(bf)
%end
        ReWa = [Rec-20 Rec+20]; % vector to draw the 'linear' interpolations
        ReWb = Rec+ [0 :0.005 :1].^2*1000;  % vector to draw the 'weakly nonlinear' interpolations 
        
        % estimates for the pressure drop (in figure 3)
        DeltaPa  = wnl.DeltaP0+wnl.DeltaPeps/Rec^2*(ReWa-Rec);
        DeltaPb  = wnl.DeltaP0+(wnl.DeltaPeps+real(wnl.DeltaPAAs*wnl.lambdaA/wnl.muA))/Rec^2*(ReWb-Rec);
        figure(3);hold on;
        plot(ReWa,DeltaPa,'--b',ReWb,DeltaPb,'--r');

        % estimates for the growth rate and strouhal
        EVSWa = wnl.eigenvalue+wnl.lambdaA/Rec^2*(ReWa-Rec); % linear development of eigenvalue
        EVSWbI = imag(wnl.eigenvalue)+(imag(wnl.lambdaA)-imag(wnl.muA)*real(wnl.lambdaA)/real(wnl.muA)).*(1/Rec-1./ReWb);
        figure(4);subplot(2,1,1);
        hold on;
        plot(ReWa,real(EVSWa),'--');
        figure(4);subplot(2,1,2);
        hold on;
        plot(ReWa,imag(EVSWa)/(2*pi),'--',ReWb,(EVSWbI)/(2*pi));
        
        figure(13);hold on;
        % we try epsilon and epsilonprime (cf. Gallaire et al, FDR 2017, and Tchoufag et al.)
        LiftA_epsilon = sqrt(abs(wnl.lambdaA/wnl.muA).*(1/Rec-1./ReWb)); 
        LiftA_epsilonprime = sqrt(abs(wnl.lambdaA/wnl.muA).*(ReWb-Rec)/Rec^2);
        plot(ReWb,LiftA_epsilon,'b-',ReWb,LiftA_epsilonprime,'b--');
       title('Oscillating flow rate as function of Re (WNL expansions ; epsilon and epsilon'' scalings)');   

       
DATA = [ReWb; EVSWbI; LiftA_epsilon; DeltaPb];

fid=fopen('WNL_Branch2.dat','w')
fprintf(fid,'%12.6f %12.6f %12.6f %12.6f \n',DATA)
fclose(fid);
       
%save('baseflow.mat','bf','EV1','EV2','Re_Range','CD_Branch');
%plotFF(bf,'u0');