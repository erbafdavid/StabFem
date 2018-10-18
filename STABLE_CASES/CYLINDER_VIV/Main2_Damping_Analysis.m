%Damping Analysis

%% Mesh: creation and convergence using adapt mesh
global  verbosity ffdatadir
run('../SOURCES_MATLAB/SF_Start.m');

tic
%CHOOSE the domain parameters:
domain_parameters=[-50 50 50];
%domain_parameters=[-100 100 100];
ADAPTMODE='S'; % D, A or S
[baseflow]= SF_MeshGeneration(domain_parameters,ADAPTMODE);
toc

% Save Data
%CHOOSE folder for saving data:
General_data_dir='./Final_Results_v20/';
%General_data_dir='./Final_Results_v24/'; %studying the limits of Ustar to 0
domain_identity={[ num2str(domain_parameters(1)) '_' num2str(domain_parameters(2)) '_' num2str(domain_parameters(3)) '/']};
%mesh_identity={'Adapt_S_Step_mod10_Hmax1_InterError_0.02/'};
%mesh_identity={'Adapt_D_Hmax10_InterError_0.02/'};
mesh_identity={'Adapt_S_Hmax1_InterError_0.02/'};
savedata_dir={[ General_data_dir domain_identity{1} mesh_identity{1}]};
%savedata_dir=[General_data_folder domain_identity mesh_identity];

%% Mstar=100

DAMP=0;%init
m_star=100;
mass=m_star*pi/4;
U_star_lamR=8.5;%init (guess)
RealShift=0; %init (guess)
ImagShift=0.8; %init (guess)
DAMP_DATA=[];
BOOL=true;
%DAMP=0.034115;%FOR CONTINUATION
for Re=[21:1:46 46.4 46.55]
    DAMP_DATA_Converging=[];
    if(Re==46.4)
        figure(47);hold on
    elseif(Re==46.55)
        figure(48);hold on
    else
        figure(Re);hold on %to see what's going on...
    end
    
    set(gcf, 'Position', get(0, 'Screensize'));%img in fullscream during compute
    title(['Damping convergence for Re=' num2str(Re) ' (Damping value at the beggining of the curve)'])
    nPUstar=15; % init
    if(Re<43) %M100
    incDAMP=DAMP*0.1+0.001; %Empirical formula again...(for dealing with the coupled modes at the end)
    elseif(Re>=43 &&Re<46)
    incDAMP=DAMP*0.05+0.001; %Empirical formula again...(for dealing with the coupled modes at the end)
        elseif(Re>=46)
    incDAMP=DAMP*0.5+0.001; %Empirical formula again...(for dealing with the coupled modes at the end)
    end
    baseflow = SF_BaseFlow(baseflow,'Re',Re);
    lambdaRant=1; %init with positive value
    DAMPant=0;%init
    lambdaR=5; %init
    while(abs(lambdaR)>0.00005 || nPUstar<15 )
        if(Re<43) %M100
            DeltaUstar=4*DAMP+1; %Empiric formula from Diogo %FOR inf a RE43
        elseif(Re>=43)
            DeltaUstar=1*DAMP+0.1; %Empiric formula from Diogo %FOR RE43
        end
        U_star=linspace(U_star_lamR-DeltaUstar,U_star_lamR+DeltaUstar,nPUstar); %The values of Ustar to test
        Stiffness_table=pi^3*m_star./((U_star).^2); %Converting to stiffness
        %disp(['VALUE of DELTAUSTAR=' num2str(DeltaUstar)  'ans VALUE OF min Ustar='  num2str(U_star(1))  ]);%Debugging
        
        %Details of the Diogo's functions:
        modename={'02modeSTRUCTURE'}; filename={[modename{1}  '_data']}; savedata_dir_check={[savedata_dir{1} 'Re' num2str(Re) '/mstar' num2str(m_star) '/DAMP' num2str(DAMP) '/' filename{1}]}; sigma_tab=[];
        %Executing the LSA problem:
        [baseflow,sigma_tab,IECT] = SF_FreeMovement_Spectrum('modefollow',savedata_dir_check,baseflow,sigma_tab,RealShift,ImagShift,Stiffness_table,mass,DAMP,1);%last value is "nev"
        %Order the results calculated with the ones already calculated before; it also saves them:
        [sigma_tab,U_star,Stiffness_table]=SF_Order_Tables(savedata_dir_check,IECT,sigma_tab,U_star,Stiffness_table);
        SF_Save_Data('data',General_data_dir,savedata_dir,Re,m_star,filename,Stiffness_table,U_star,sigma_tab,DAMP);
        %Close figure of SF_Stability at each iteration if 'PlotSpectrum'='yes'
        %if ishandle(100)
        %   close(100)
        %end
        [lambdaR,index]=max(real(sigma_tab));
        U_star_lamR=U_star(index);%Refresh the Ustar where lamR is max
        
        format long
        DAMP_DATA_Converging=[DAMP_DATA_Converging [Re U_star(index) lambdaR imag(sigma_tab(index)) DAMP]' ];
        format short
        
        if(Re==46.4)
            figure(47);hold on
        elseif(Re==46.55)
            figure(48);hold on
        else
            figure(Re);hold on %to see what's going on...
        end
        plot(real(sigma_tab),imag(sigma_tab),'.-');
        text(real(sigma_tab(1)),imag(sigma_tab(1)),num2str(DAMP)); drawnow; %ylim([0.5 1.2])
        
        if(DAMP>3)
            if(BOOL==true)
                BOOL=false;
                incDAMP=3;
                disp(['AQUI!!!!!!!!!!' num2str(incDAMP)])
            end
        end
        %( index~=1 || index~=size(sigma_tab,2) ) means that the range of Ustar was well chosen. If not, it wont enter in the following IF's
        % and it will redo the calculations with a better Ustar range
        if( ( index~=1 || index~=size(sigma_tab,2) ) && (lambdaR*lambdaRant)<0 ) %supostamente, ele nunca entra aqui na primeira iter
            %if(incDAMP>0.0001) %Refinig in DAMPING
                incDAMP=0.25*incDAMP;
            %end
            if(nPUstar<15) %Put more points if needed
                nPUstar=1.5*nPUstar; %dont put to much, since it is costly...
            end
        DAMP=(-lambdaR*(DAMPant-DAMP))/(lambdaRant-lambdaR)+DAMP;    
        end
        if( ( index~=1 || index~=size(sigma_tab,2) ) && lambdaR>0 && (lambdaR*lambdaRant)>=0 )
            DAMPant=DAMP; DAMP=DAMP+incDAMP; lambdaRant=lambdaR;
        end
        if( ( index~=1 || index~=size(sigma_tab,2) ) && lambdaR<0 && (lambdaR*lambdaRant)>=0 )
            DAMPant=DAMP; DAMP=DAMP-incDAMP; lambdaRant=lambdaR;
        end
        
        DeltaUstar=4*DAMP+1.5; % Empiric formula from Diogo
        %disp(['comparing this to values:' num2str(U_star) ' and ' num2str(U_star_lamR-DeltaUstar)])%Debugging
        [toto_notneeded,indexUstar]=min(abs(U_star_lamR-DeltaUstar-U_star)); % UstarlamR is here the refreshed
        %disp(' ')
        %disp(['the index is:' num2str(indexUstar)])%Debugging
        if(indexUstar==0)%I think this is not need anymore... but lets keep it
            indexUstar=1;
        end
        RealShift=real(sigma_tab(indexUstar));
        ImagShift=imag(sigma_tab(indexUstar));
        
        disp('Passing to next value of DAMPING (if the last went well...)');

       
    end
    %Pick the best for the next iteration:(yes, is needed)
    disp(DAMP_DATA_Converging)
    [toto_notneeded2,indexLAST]=min(abs(DAMP_DATA_Converging(3,:)));%the LamR min
    U_star_lamR=DAMP_DATA_Converging(2,indexLAST);%Refresh the Ustar where lamR is max for next RE (its a guess)
    DAMP=DAMP_DATA_Converging(5,indexLAST);
    save([savedata_dir{1} 'Re' num2str(Re) '/mstar' num2str(m_star) '/data_converging_Gammma.mat'],'DAMP_DATA_Converging');
    
    disp(['---------------------------------- Passing to next value of RE=' num2str(Re+1) ' ----------------------------------']);
    DAMP_DATA=[DAMP_DATA [Re U_star_lamR DAMP_DATA_Converging(3,indexLAST) DAMP_DATA_Converging(4,indexLAST) DAMP]' ];
    %if(DAMP>20)
    %    break; %it means that we arive to the limit Re for the mass chosen at the beginning
    %end
end
save([savedata_dir{1} 'data_converging_Gammma_m' num2str(m_star) '.mat'],'DAMP_DATA');
disp('Finish');

%% Mstar=10


DAMP=0;%init
m_star=10;
mass=m_star*pi/4;
U_star_lamR=8.5;%init (guess)
RealShift=0; %init (guess)
ImagShift=0.8; %init (guess)
DAMP_DATA=[];
BOOL=true;
%DAMP=0.034115;%FOR CONTINUATION
for Re=[21:1:44 44.5 44.7 44.75 44.77] %44.8 does not work!!!
    DAMP_DATA_Converging=[];
        if(Re==44.5)
            figure(45);hold on
        elseif(Re==44.7)
            figure(46);hold on
                    elseif(Re==44.75)
            figure(47);hold on 
                                elseif(Re==44.77)
            figure(48);hold on 
        else
            figure(Re);hold on %to see what's going on...
        end
    set(gcf, 'Position', get(0, 'Screensize'));%img in fullscream during compute
    title(['Damping convergence for Re=' num2str(Re) ' (Damping value at the beggining of the curve)'])
    nPUstar=15; % init
    if(Re<=44.5) %M10
    incDAMP=DAMP*0.1+0.001; %Empirical formula again...(for dealing with the coupled modes at the end)
    elseif(Re>44.5)
    incDAMP=DAMP*1+0.001; %Empirical formula again...(for dealing with the coupled modes at the end)
    end
    baseflow = SF_BaseFlow(baseflow,'Re',Re);
    lambdaRant=1; %init with positive value
    DAMPant=0;%init 
    lambdaR=1;
    while(abs(lambdaR)>0.00005  || nPUstar<15 )
        %DeltaUstar=1*DAMP+0.1; %Empiric formula from Diogo %FOR RE43
        if(Re<45) %M100
            DeltaUstar=4*DAMP+1; %Empiric formula from Diogo %FOR inf a RE43
        elseif(Re>=45)
        DeltaUstar=2*DAMP+0.1; %Empiric formula from Diogo %FOR RE43
        end
        U_star=linspace(U_star_lamR-DeltaUstar,U_star_lamR+DeltaUstar,nPUstar); %The values of Ustar to test
        Stiffness_table=pi^3*m_star./((U_star).^2); %Converting to stiffness
        %disp(['VALUE of DELTAUSTAR=' num2str(DeltaUstar)  'ans VALUE OF min Ustar='  num2str(U_star(1))  ]);%Debugging
        
        %Details of the Diogo's functions:
        modename={'02modeSTRUCTURE'}; filename={[modename{1}  '_data']}; savedata_dir_check={[savedata_dir{1} 'Re' num2str(Re) '/mstar' num2str(m_star) '/DAMP' num2str(DAMP) '/' filename{1}]}; sigma_tab=[];
        %Executing the LSA problem:
        [baseflow,sigma_tab,IECT] = SF_FreeMovement_Spectrum('modefollow',savedata_dir_check,baseflow,sigma_tab,RealShift,ImagShift,Stiffness_table,mass,DAMP,1);%last value is "nev"
        %Order the results calculated with the ones already calculated before; it also saves them:
        [sigma_tab,U_star,Stiffness_table]=SF_Order_Tables(savedata_dir_check,IECT,sigma_tab,U_star,Stiffness_table);
        SF_Save_Data('data',General_data_dir,savedata_dir,Re,m_star,filename,Stiffness_table,U_star,sigma_tab,DAMP);
        %Close figure of SF_Stability at each iteration if 'PlotSpectrum'='yes'
        %if ishandle(100)
        %   close(100)
        %end
        [lambdaR,index]=max(real(sigma_tab));
        U_star_lamR=U_star(index);%Refresh the Ustar where lamR is max

        format long
        DAMP_DATA_Converging=[DAMP_DATA_Converging [Re U_star(index) lambdaR imag(sigma_tab(index)) DAMP]' ];
        format short
        
        if(Re==44.5)
            figure(45);hold on
        elseif(Re==44.7)
            figure(46);hold on   
                    elseif(Re==44.75)
            figure(47);hold on 
             elseif(Re==44.77)
            figure(48);hold on 
        else
            figure(Re);hold on %to see what's going on...
        end
        
        plot(real(sigma_tab),imag(sigma_tab),'.-');
        text(real(sigma_tab(1)),imag(sigma_tab(1)),num2str(DAMP)); drawnow; %ylim([0.5 1.2])
        
        if(DAMP>5.54)
            if(BOOL==true)
                BOOL=false;
                incDAMP=5;
                disp(['AQUI!!!!!!!!!!' num2str(incDAMP)])
            end
        end
        %( index~=1 || index~=size(sigma_tab,2) ) means that the range of Ustar was well chosen. If not, it wont enter in the following IF's
        % and it will redo the calculations with a better Ustar range
        if( ( index~=1 || index~=size(sigma_tab,2) ) && (lambdaR*lambdaRant)<0 ) %supostamente, ele nunca entra aqui na primeira iter
            %if(incDAMP>0.0001) %Refinig in DAMPING
            disp('AQUI!!!!!!!!!!')
            %%if(DAMP<5.54)%NAO DEVIA DE ESTAR QAUI
                incDAMP=0.25*incDAMP;
            %%elseif(DAMP>2.9)
            %    if(BOOL==true)
            %        BOOL=false;
            %        incDAMP=5;
            %        disp(['AQUI!!!!!!!!!!' num2str(incDAMP)])
            %    end
            %    incDAMP=0.5*incDAMP;
            %    disp(['AQUI!!!!!!!!!!' num2str(incDAMP)])
            %end
            
            %end
            if(nPUstar<15) %Put more points if needed
                nPUstar=1.5*nPUstar; %dont put to much, since it is costly...
            end
            DAMP=(-lambdaR*(DAMPant-DAMP))/(lambdaRant-lambdaR)+DAMP;
        end
        if( ( index~=1 || index~=size(sigma_tab,2) ) && lambdaR>0 && (lambdaR*lambdaRant)>=0 )
            
            %incDAMP=0.5*incDAMP;
            %if(DAMP<6.7)
                DAMPant=DAMP; DAMP=DAMP+incDAMP; lambdaRant=lambdaR;
            %elseif(DAMP>6.7)
            %      if(BOOL==true)
            %         BOOL=false;
            %        incDAMP=1;
            %       disp(['AQUI!!!!!!!!!!' num2str(incDAMP)])
            %    end
            %    incDAMP=(DAMP)*incDAMP;
            %    disp(['AQUI!!!!!!!!!!' num2str(incDAMP)])
            %                    DAMPant=DAMP; DAMP=DAMP+incDAMP; lambdaRant=lambdaR;
            %end
            
            
            
            
        end
        if( ( index~=1 || index~=size(sigma_tab,2) ) && lambdaR<0 && (lambdaR*lambdaRant)>=0 )
            DAMPant=DAMP; DAMP=DAMP-incDAMP; lambdaRant=lambdaR;
        end
        
        DeltaUstar=4*DAMP+1.5; % Empiric formula from Diogo
        %disp(['comparing this to values:' num2str(U_star) ' and ' num2str(U_star_lamR-DeltaUstar)])%Debugging
        [toto_notneeded,indexUstar]=min(abs(U_star_lamR-DeltaUstar-U_star)); % UstarlamR is here the refreshed
        %disp(' ')
        %disp(['the index is:' num2str(indexUstar)])%Debugging
        if(indexUstar==0)%I think this is not need anymore... but lets keep it
            indexUstar=1;
        end
        RealShift=real(sigma_tab(indexUstar));
        ImagShift=imag(sigma_tab(indexUstar));
        
        disp('Passing to next value of DAMPING (if the last went well...)');

       
    end
    %Pick the best for the next iteration:(yes, is needed)
    disp(DAMP_DATA_Converging)
    [toto_notneeded2,indexLAST]=min(abs(DAMP_DATA_Converging(3,:)));%the LamR min
    U_star_lamR=DAMP_DATA_Converging(2,indexLAST);%Refresh the Ustar where lamR is max for next RE (its a guess)
    DAMP=DAMP_DATA_Converging(5,indexLAST);
    save([savedata_dir{1} 'Re' num2str(Re) '/mstar' num2str(m_star) '/data_converging_Gammma.mat'],'DAMP_DATA_Converging');
    
    disp(['---------------------------------- Passing to next value of RE=' num2str(Re+1) ' ----------------------------------']);
    DAMP_DATA=[DAMP_DATA [Re U_star_lamR DAMP_DATA_Converging(3,indexLAST) DAMP_DATA_Converging(4,indexLAST) DAMP]' ];
    %if(DAMP>20)
    %    break; %it means that we arive to the limit Re for the mass chosen at the beginning
    %end
end
save([savedata_dir{1} 'data_converging_Gammma_m' num2str(m_star) '.mat'],'DAMP_DATA');
disp('Finish');

%% Mstar=0.1
DAMP=0;%init
m_star=0.1;
mass=m_star*pi/4;
U_star_lamR=2.2;%init (guess)
RealShift=0; %init (guess)
ImagShift=0.66; %init (guess)
DAMP_DATA=[];
BOOL=true;
BOOL2=true;
%DAMP=0.034115;%FOR CONTINUATION
for Re=[21:1:31 31.3 31.4 31.5 31.6 31.7 ] 
    DAMP_DATA_Converging=[];
    if(Re==19.95)
        figure(19);hold on
    elseif(Re==31.3)
        figure(32);hold on
    elseif(Re==31.4)
        figure(33);hold on
    elseif(Re==31.5)
        figure(34);hold on
    elseif(Re==31.6)
        figure(35);hold on
    elseif(Re==31.7)
        figure(36);hold on
    else
        figure(Re);hold on %to see what's going on...
    end
    set(gcf, 'Position', get(0, 'Screensize'));%img in fullscream during compute
    title(['Damping convergence for Re=' num2str(Re) ' (Damping value at the beggining of the curve)'])
    nPUstar=15; % init
    if(Re<=24) %M0.1
    incDAMP=DAMP*0.1+0.1; %Empirical formula again...(for dealing with the coupled modes at the end)
    elseif(Re>=25)
    incDAMP=DAMP*0.1+0.01; %dont use it for m0.1%Empirical formula again...(for dealing with the coupled modes at the end)
    end
    baseflow = SF_BaseFlow(baseflow,'Re',Re);
    lambdaRant=1; %init with positive value
    DAMPant=0;%init 
    lambdaR=1; %just to enter the loop
    while(abs(lambdaR)>0.00005  || nPUstar<15 )
        %DeltaUstar=1*DAMP+0.1; %Empiric formula from Diogo %FOR RE43
        if(Re<25) %M0.1 
            DeltaUstar=1*DAMP+0.2; %Empiric formula from Diogo %FOR inf a RE25
        elseif(Re>=25)
            DeltaUstar=0.75*DAMP+0.01; %Empiric formula from Diogo %FOR RE??
        end
        U_star=linspace(U_star_lamR-DeltaUstar,U_star_lamR+DeltaUstar,nPUstar); %The values of Ustar to test
        Stiffness_table=pi^3*m_star./((U_star).^2); %Converting to stiffness
        %disp(['VALUE of DELTAUSTAR=' num2str(DeltaUstar)  'ans VALUE OF min Ustar='  num2str(U_star(1))  ]);%Debugging
        
        %Details of the Diogo's functions:
        modename={'02modeSTRUCTURE'}; filename={[modename{1}  '_data']}; savedata_dir_check={[savedata_dir{1} 'Re' num2str(Re) '/mstar' num2str(m_star) '/DAMP' num2str(DAMP) '/' filename{1}]}; sigma_tab=[];
        %Executing the LSA problem:
        [baseflow,sigma_tab,IECT] = SF_FreeMovement_Spectrum('modefollow',savedata_dir_check,baseflow,sigma_tab,RealShift,ImagShift,Stiffness_table,mass,DAMP,1);%last value is "nev"
        %Order the results calculated with the ones already calculated before; it also saves them:
        [sigma_tab,U_star,Stiffness_table]=SF_Order_Tables(savedata_dir_check,IECT,sigma_tab,U_star,Stiffness_table);
        SF_Save_Data('data',General_data_dir,savedata_dir,Re,m_star,filename,Stiffness_table,U_star,sigma_tab,DAMP);
        %Close figure of SF_Stability at each iteration if 'PlotSpectrum'='yes'
        %if ishandle(100)
        %   close(100)
        %end
        [lambdaR,index]=max(real(sigma_tab));
        U_star_lamR=U_star(index);%Refresh the Ustar where lamR is max

        format long
        DAMP_DATA_Converging=[DAMP_DATA_Converging [Re U_star(index) lambdaR imag(sigma_tab(index)) DAMP]' ];
        format short
        
    if(Re==19.95)
        figure(19);hold on
    elseif(Re==31.3)
        figure(32);hold on
    elseif(Re==31.4)
        figure(33);hold on
    elseif(Re==31.5)
        figure(34);hold on
    elseif(Re==31.6)
        figure(35);hold on
    elseif(Re==31.7)
        figure(36);hold on
    else
        figure(Re);hold on %to see what's going on...
    end
        
        plot(real(sigma_tab),imag(sigma_tab),'.-');
        text(real(sigma_tab(1)),imag(sigma_tab(1)),num2str(DAMP)); drawnow; %ylim([0.5 1.2])
        
        if(DAMP>0.84)
            if(BOOL==true)
                BOOL=false;
                incDAMP=0.25*incDAMP;
                disp(['AQUI!!!!!!!!!!' num2str(incDAMP)])
            end
        end
        if(DAMP>4.42)
            if(BOOL2==true)
                BOOL2=false;
                incDAMP=5;
                disp(['AQUI!!!!!!!!!!' num2str(incDAMP)])
            end
        end
        %( index~=1 || index~=size(sigma_tab,2) ) means that the range of Ustar was well chosen. If not, it wont enter in the following IF's
        % and it will redo the calculations with a better Ustar range
        if( ( index~=1 || index~=size(sigma_tab,2) ) && (lambdaR*lambdaRant)<0 ) %supostamente, ele nunca entra aqui na primeira iter
            %if(incDAMP>0.0001) %Refinig in DAMPING
            disp('AQUI!!!!!!!!!!')
            %%if(DAMP<5.54)%NAO DEVIA DE ESTAR QAUI
           
                incDAMP=0.25*incDAMP;
            %%elseif(DAMP>2.9)
            %    if(BOOL==true)
            %        BOOL=false;
            %        incDAMP=5;
            %        disp(['AQUI!!!!!!!!!!' num2str(incDAMP)])
            %    end
            %    incDAMP=0.5*incDAMP;
            %    disp(['AQUI!!!!!!!!!!' num2str(incDAMP)])
            %end
            
            %end
            if(nPUstar<15) %Put more points if needed
                nPUstar=1.5*nPUstar; %dont put to much, since it is costly...
            end
            DAMP=(-lambdaR*(DAMPant-DAMP))/(lambdaRant-lambdaR)+DAMP;
        end
        if( ( index~=1 || index~=size(sigma_tab,2) ) && lambdaR>0 && (lambdaR*lambdaRant)>=0 )
            
            %incDAMP=0.5*incDAMP;
            %if(DAMP<6.7)
                DAMPant=DAMP; DAMP=DAMP+incDAMP; lambdaRant=lambdaR;
            %elseif(DAMP>6.7)
            %      if(BOOL==true)
            %         BOOL=false;
            %        incDAMP=1;
            %       disp(['AQUI!!!!!!!!!!' num2str(incDAMP)])
            %    end
            %    incDAMP=(DAMP)*incDAMP;
            %    disp(['AQUI!!!!!!!!!!' num2str(incDAMP)])
            %                    DAMPant=DAMP; DAMP=DAMP+incDAMP; lambdaRant=lambdaR;
            %end
            
            
            
            
        end
        if( ( index~=1 || index~=size(sigma_tab,2) ) && lambdaR<0 && (lambdaR*lambdaRant)>=0 )
            DAMPant=DAMP; DAMP=DAMP-incDAMP; lambdaRant=lambdaR;
        end
        
        DeltaUstar=4*DAMP+1.5; % Empiric formula from Diogo
        %disp(['comparing this to values:' num2str(U_star) ' and ' num2str(U_star_lamR-DeltaUstar)])%Debugging
        [toto_notneeded,indexUstar]=min(abs(U_star_lamR-DeltaUstar-U_star)); % UstarlamR is here the refreshed
        %disp(' ')
        %disp(['the index is:' num2str(indexUstar)])%Debugging
        if(indexUstar==0)%I think this is not need anymore... but lets keep it
            indexUstar=1;
        end
        RealShift=real(sigma_tab(indexUstar));
        ImagShift=imag(sigma_tab(indexUstar));
        
        disp('Passing to next value of DAMPING (if the last went well...)');

       
    end
    %Pick the best for the next iteration:(yes, is needed)
    disp(DAMP_DATA_Converging)
    [toto_notneeded2,indexLAST]=min(abs(DAMP_DATA_Converging(3,:)));%the LamR min
    U_star_lamR=DAMP_DATA_Converging(2,indexLAST);%Refresh the Ustar where lamR is max for next RE (its a guess)
    DAMP=DAMP_DATA_Converging(5,indexLAST);
    save([savedata_dir{1} 'Re' num2str(Re) '/mstar' num2str(m_star) '/data_converging_Gammma.mat'],'DAMP_DATA_Converging');
    
    disp(['---------------------------------- Passing to next value of RE=' num2str(Re+1) ' ----------------------------------']);
    DAMP_DATA=[DAMP_DATA [Re U_star_lamR DAMP_DATA_Converging(3,indexLAST) DAMP_DATA_Converging(4,indexLAST) DAMP]' ];
    %if(DAMP>20)
    %    break; %it means that we arive to the limit Re for the mass chosen at the beginning
    %end
end
save([savedata_dir{1} 'data_converging_Gammma_m' num2str(m_star) '.mat'],'DAMP_DATA');
disp('Finish');
%% Mstar=1


DAMP=0;%init
m_star=1;
mass=m_star*pi/4;
U_star_lamR=5.7;%init (guess)
RealShift=0; %init (guess)
ImagShift=0.75; %init (guess)
DAMP_DATA=[];
BOOL=true;
BOOL2=true;
%DAMP=0.034115;%FOR CONTINUATION
for Re=[21:1:37 37.2 37.3 ] %mudar as coisas para RE 38 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    DAMP_DATA_Converging=[];
    if(Re==19.95)
        figure(19);hold on
    elseif(Re==37.2)
        figure(38);hold on
    elseif(Re==37.3)
        figure(39);hold on
    %elseif(Re==31.5)
    %    figure(34);hold on
    %elseif(Re==31.6)
    %    figure(35);hold on
    %elseif(Re==31.7)
    %    figure(36);hold on
    else
        figure(Re);hold on %to see what's going on...
    end
    set(gcf, 'Position', get(0, 'Screensize'));%img in fullscream during compute
    title(['Damping convergence for Re=' num2str(Re) ' (Damping value at the beggining of the curve)'])
    nPUstar=15; % init
    if(Re<=24) %M0.1 mudar o increment para a gneralidade dos RE
    incDAMP=DAMP*0.1+0.06; %Empirical formula again...(for dealing with the coupled modes at the end)
    elseif(Re>=25&&Re<=37)
    incDAMP=DAMP*0.1+0.01; %dont use it for m0.1%Empirical formula again...(for dealing with the coupled modes at the end)
    elseif(Re>37)
    incDAMP=DAMP*0.5+0.1; %dont use it for m0.1%Empirical formula again...(for dealing with the coupled modes at the end)
   
    end
    baseflow = SF_BaseFlow(baseflow,'Re',Re);
    lambdaRant=1; %init with positive value
    DAMPant=0;%init 
    lambdaR=1; %just to enter the loop
    while(abs(lambdaR)>0.00005  || nPUstar<15 )
        %DeltaUstar=1*DAMP+0.1; %Empiric formula from Diogo %FOR RE43
        if(Re<25) %M0.1 
            DeltaUstar=1*DAMP+0.1; %Empiric formula from Diogo %FOR inf a RE25
        elseif(Re>=25)
            DeltaUstar=0.75*DAMP+0.01; %Empiric formula from Diogo %FOR RE??
        end
        U_star=linspace(U_star_lamR-DeltaUstar,U_star_lamR+DeltaUstar,nPUstar); %The values of Ustar to test
        Stiffness_table=pi^3*m_star./((U_star).^2); %Converting to stiffness
        %disp(['VALUE of DELTAUSTAR=' num2str(DeltaUstar)  'ans VALUE OF min Ustar='  num2str(U_star(1))  ]);%Debugging
        
        %Details of the Diogo's functions:
        modename={'02modeSTRUCTURE'}; filename={[modename{1}  '_data']}; savedata_dir_check={[savedata_dir{1} 'Re' num2str(Re) '/mstar' num2str(m_star) '/DAMP' num2str(DAMP) '/' filename{1}]}; sigma_tab=[];
        %Executing the LSA problem:
        [baseflow,sigma_tab,IECT] = SF_FreeMovement_Spectrum('modefollow',savedata_dir_check,baseflow,sigma_tab,RealShift,ImagShift,Stiffness_table,mass,DAMP,1);%last value is "nev"
        %Order the results calculated with the ones already calculated before; it also saves them:
        [sigma_tab,U_star,Stiffness_table]=SF_Order_Tables(savedata_dir_check,IECT,sigma_tab,U_star,Stiffness_table);
        SF_Save_Data('data',General_data_dir,savedata_dir,Re,m_star,filename,Stiffness_table,U_star,sigma_tab,DAMP);
        %Close figure of SF_Stability at each iteration if 'PlotSpectrum'='yes'
        %if ishandle(100)
        %   close(100)
        %end
        [lambdaR,index]=max(real(sigma_tab));
        U_star_lamR=U_star(index);%Refresh the Ustar where lamR is max

        format long
        DAMP_DATA_Converging=[DAMP_DATA_Converging [Re U_star(index) lambdaR imag(sigma_tab(index)) DAMP]' ];
        format short
        
    if(Re==19.95)
        figure(19);hold on
    elseif(Re==37.2)
        figure(38);hold on
    elseif(Re==37.3)
        figure(39);hold on
    %elseif(Re==31.5)
    %    figure(34);hold on
    %elseif(Re==31.6)
    %    figure(35);hold on
    %elseif(Re==31.7)
    %    figure(36);hold on
    else
        figure(Re);hold on %to see what's going on...
    end
        
        plot(real(sigma_tab),imag(sigma_tab),'.-');
        text(real(sigma_tab(1)),imag(sigma_tab(1)),num2str(DAMP)); drawnow; %ylim([0.5 1.2])
        
        if(DAMP>2.03)%mudar o incremento no mesmo reynolds
            if(BOOL==true)
                BOOL=false;
                incDAMP=0.07;
                disp(['AQUI!!!!!!!!!!' num2str(incDAMP)])
            end
        end
        if(DAMP>5.84)
            if(BOOL2==true)
                BOOL2=false;
                incDAMP=10;
                disp(['AQUI!!!!!!!!!!' num2str(incDAMP)])
            end
        end
        %( index~=1 || index~=size(sigma_tab,2) ) means that the range of Ustar was well chosen. If not, it wont enter in the following IF's
        % and it will redo the calculations with a better Ustar range
        if( ( index~=1 || index~=size(sigma_tab,2) ) && (lambdaR*lambdaRant)<0 ) %supostamente, ele nunca entra aqui na primeira iter
            %if(incDAMP>0.0001) %Refinig in DAMPING
            disp('AQUI!!!!!!!!!!')
            %%if(DAMP<5.54)%NAO DEVIA DE ESTAR QAUI
           
                incDAMP=0.25*incDAMP;
            %%elseif(DAMP>2.9)
            %    if(BOOL==true)
            %        BOOL=false;
            %        incDAMP=5;
            %        disp(['AQUI!!!!!!!!!!' num2str(incDAMP)])
            %    end
            %    incDAMP=0.5*incDAMP;
            %    disp(['AQUI!!!!!!!!!!' num2str(incDAMP)])
            %end
            
            %end
            if(nPUstar<15) %Put more points if needed
                nPUstar=1.5*nPUstar; %dont put to much, since it is costly...
            end
            DAMP=(-lambdaR*(DAMPant-DAMP))/(lambdaRant-lambdaR)+DAMP;
        end
        if( ( index~=1 || index~=size(sigma_tab,2) ) && lambdaR>0 && (lambdaR*lambdaRant)>=0 )
            
            %incDAMP=0.5*incDAMP;
            %if(DAMP<6.7)
                DAMPant=DAMP; DAMP=DAMP+incDAMP; lambdaRant=lambdaR;
            %elseif(DAMP>6.7)
            %      if(BOOL==true)
            %         BOOL=false;
            %        incDAMP=1;
            %       disp(['AQUI!!!!!!!!!!' num2str(incDAMP)])
            %    end
            %    incDAMP=(DAMP)*incDAMP;
            %    disp(['AQUI!!!!!!!!!!' num2str(incDAMP)])
            %                    DAMPant=DAMP; DAMP=DAMP+incDAMP; lambdaRant=lambdaR;
            %end
            
            
            
            
        end
        if( ( index~=1 || index~=size(sigma_tab,2) ) && lambdaR<0 && (lambdaR*lambdaRant)>=0 )
            DAMPant=DAMP; DAMP=DAMP-incDAMP; lambdaRant=lambdaR;
        end
        
        DeltaUstar=4*DAMP+1.5; % Empiric formula from Diogo
        %disp(['comparing this to values:' num2str(U_star) ' and ' num2str(U_star_lamR-DeltaUstar)])%Debugging
        [toto_notneeded,indexUstar]=min(abs(U_star_lamR-DeltaUstar-U_star)); % UstarlamR is here the refreshed
        %disp(' ')
        %disp(['the index is:' num2str(indexUstar)])%Debugging
        if(indexUstar==0)%I think this is not need anymore... but lets keep it
            indexUstar=1;
        end
        RealShift=real(sigma_tab(indexUstar));
        ImagShift=imag(sigma_tab(indexUstar));
        
        disp('Passing to next value of DAMPING (if the last went well...)');

       
    end
    %Pick the best for the next iteration:(yes, is needed)
    disp(DAMP_DATA_Converging)
    [toto_notneeded2,indexLAST]=min(abs(DAMP_DATA_Converging(3,:)));%the LamR min
    U_star_lamR=DAMP_DATA_Converging(2,indexLAST);%Refresh the Ustar where lamR is max for next RE (its a guess)
    DAMP=DAMP_DATA_Converging(5,indexLAST);
    save([savedata_dir{1} 'Re' num2str(Re) '/mstar' num2str(m_star) '/data_converging_Gammma.mat'],'DAMP_DATA_Converging');
    
    disp(['---------------------------------- Passing to next value of RE=' num2str(Re+1) ' ----------------------------------']);
    DAMP_DATA=[DAMP_DATA [Re U_star_lamR DAMP_DATA_Converging(3,indexLAST) DAMP_DATA_Converging(4,indexLAST) DAMP]' ];
    %if(DAMP>20)
    %    break; %it means that we arive to the limit Re for the mass chosen at the beginning
    %end
end
save([savedata_dir{1} 'data_converging_Gammma_m' num2str(m_star) '.mat'],'DAMP_DATA');
disp('Finish');
%% Sketch gamma*mstar vs Rec
close all
figure(1);hold on
figure(2);hold on
figure(3);hold on
for m=[0.1]
load([savedata_dir{1}  'data_converging_Gammma_m' num2str(m) '.mat'])
%figure(1);hold on
%plot(((DAMP_DATA(5,:)).*m),DAMP_DATA(1,:))
%figure(2);hold on
%plot(log10((DAMP_DATA(5,:)).*m),DAMP_DATA(1,:))
figure(3);hold on
plot(DAMP_DATA(2,:),DAMP_DATA(5,:))
%plot(log((DAMP_DATA(2,:)).*DAMP_DATA(5,:)),(DAMP_DATA(5,:))*m) %relacao interessante de Ustar
xlabel('Ustar'); ylabel('gamma')
%dlmwrite(['Latex_data/Free/DAMP/DAMP_CURVE_m' num2str(m) '.dat'],[DAMP_DATA(5,:)'.*m DAMP_DATA(1,:)']);


end
figure(2);hold on
legend('m=10','m=100')
figure(3);hold on
legend('m=10','m=100')

%% gamma vs Re
close all
figure(80);hold on

for m=[0.1]
%load([savedata_dir{1}  'data_converging_Gammma_m' num2str(m) '.mat'])
figure(80);hold on
semilogx((DAMP_DATA(5,:)*m),(DAMP_DATA(1,:)))
end

figure(80);hold on
legend('m=10')


%%
%For a fixed gamma, find Rec
%% TRASH
% DAMPING SKETC

m_star=100;
DAMPING_plot=[];
Re_tab=21:1:42;
for Re=Re_tab
    load([savedata_dir{1} 'Re' num2str(Re) '/mstar' num2str(m_star) '/data_converging_Gammma.mat'])
    [toto_notneeded2,indexLAST]=min(abs(DAMP_DATA_Converging(3,:)));%the LamR min
     DAMPING_plot=[DAMPING_plot DAMP_DATA_Converging(5,indexLAST) ];
end

figure;hold on
plot(DAMPING_plot,Re_tab,'.-')
xlabel('\gamma'); ylabel('Re');title('mstar=100 ')
diogo_by_handRE=[20 25 30 35 40];
diogo_by_handDAMP=[0.00001 0.0032 0.068 0.120 0.234];
%plot(diogo_by_handDAMP,diogo_by_handRE,'*')
%END FILE