%>   This is part of StabFem Project.
%>   (set of programs in Freefem to perform global stability calculations  
%>   in hydrodynamic stability)
%>
%>	File: SCRIPT_VIV_HARMONICFORCED.m
%>   Contributours: David Fabre, Diogo Sabino ...
%>   Last Modification: Diogo Sabino, 18 April 2018
%> 
%>	This script models a flow aroung a rigid circular cilinder mounted
%>	in a spring-damped system to simulate VIV
%>
%>   To give a good use of this script, run each section at a time
%>
%> Some of the resutls v1 does not have the field Drag calculated. the program will do an error if so. The best to do is whenever you change the the fields exported to the ff2m file, you  change the .m file how generalre the file TOTAL and you save all the results in a different version.
%> To be modified: Go search the results at DATA_Forced_Cylinder_v0 and not
%> at WORK
%% Mesh: creation and convergence using adapt mesh
%clear all
global ffdataharmonicdir verbosity ffdatadir
run('../SOURCES_MATLAB/SF_Start.m');

%CHOOSE the domain parameters:
domain_parameters=[-50 50 50];
%domain_parameters=[-100 100 100]; %for the case when St->0
ADAPTMODE='S'; % D, A or S 
[baseflow]= SF_MeshGeneration(domain_parameters,ADAPTMODE);

%% CHOOSE folder for saving data:
%General_data_dir='v1/General_data/';
General_data_dir='v1/General_data_refined/';
%General_data_dir='v1/Rec1/';
%General_data_dir='v1/Rec2/'; %TO REDO 
%General_data_dir='v1/Rec3/';%TO REDO
%General_data_dir='v1/Limit_St0/';
%General_data_dir='v1/Limit_St_Infty/';
domain_identity={[ num2str(domain_parameters(1)) '_' num2str(domain_parameters(2)) '_' num2str(domain_parameters(3)) '/']};
%mesh_identity={'Adapt_sensibility_Hmax2_InterError_0.02/'};
%mesh_identity={'Adapt_mode_Hmax2_InterError_0.02/'};
%mesh_identity={'Adapt_sensibility_stepOMEGA1000_Hmax1_InterError_0.02/'}; %For inf limit adapt each 1000 omegas
mesh_identity={'Adapt_S_Hmax1_InterError_0.02/'};
savedata_dir={[ General_data_dir domain_identity{1} mesh_identity{1}]};

% path of the saved data for the harmonic case cylinder (repeated in macros.edp)
ffdataharmonicdir={[ffdatadir 'DATA_Forced_Cylinder/' savedata_dir{1} ]};

% Create path if it does not exist
if(exist(ffdataharmonicdir{1})~=7&&exist(ffdataharmonicdir{1})~=5)
    mysystem(['mkdir -p ' ffdataharmonicdir{1}]); %I read in internet that the '-p'(stands for parent) not always work in every shell...
end %It's compulsory: Creation of the directory

%% Computation of Harmonic Forcing Cylinder
% NB: If simulation seems to stuck do Ctrl+C and start again; Previous data 
%will not be lost and script will continue at the omega it was interrupted
% NB2: Comment/Uncomment the parts that interest you.

%Options: A or R for Absolute or Relative velocity resp., in relative frame
formulation='R'; 
%Re_tab=[15 25 35]; %For a small test demonstration
%Omega_values=[0.1:0.005:1.1 1.2]; %For a small test demonstration

%%%%%%%%%%First Run %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Re_tab=[15:1:19 19.9 20:1:30 30.3 31:1:60];
%Omega_values=[0.1:0.02:1.3];
%%%%%%%%%%Second Run refining where needed (first figures) %%%%%%%%%%%%%%%%
%Re_tab=[25 35];
%Omega_values=[0.46:0.005:0.74];                            % A refazer !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%Re_tab=[55];
%Omega_values=[0.6:0.005:0.86]; %Additional values for Re=55
%%%%%%%%%%Third run (refining everywhere) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Re_tab=[15:1:19 19.9 20:1:30 30.3 31:1:60];
%Omega_values=[0.1:0.005:1.3];
%just for the figures:
Re_tab=[25 30 35 40 42];
Omega_values=[0.1:0.001:1.3];
%%%%%%%%%%Limits St --> 0 or St--> infty %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Re_tab=[15:1:60]; Omega_values=[0:0.001:0.01 0.02:0.01:0.05];
%Re_tab=[15 25 35 55]; Omega_values=[1:0.1:5 5:5:20 30 40 100:100:1000 1000:1000:10000]; %for the case without adaptation

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
verbosity=10; %To see all
tic
for Re=Re_tab
    [baseflow]=SF_HarmonicForcing(baseflow,Re,Omega_values,formulation);
    disp('___________________________________________________')%To separete iters
end
toc

%% Computation of Limit Case St INF: Adaptation to the Stokes Boundary Layer
%Not working, I think...
Re_tab=[15 25 35 55];
Omega_values=[3:5:20 30 40 50:50:1000];
formulation='R';
filename=[formulation 'Forced_Harmonic2D_Re']; %name WITHOUT the Re

for Re=Re_tab
    SF_HarmonicForcing(baseflow,Re,Omega_values,formulation);
    disp('___________________________________________________')%To separete iters
end
Omega_values=[1000:100:2000];
for Re=Re_tab
    ForcedField_file={[ffdataharmonicdir{1} filename num2str(Re) 'Omega' num2str(Omega_values(1)) '.ff2m' ]};
    ForcedField=importFFdata(ForcedField_file{1});
    baseflow=SF_BaseFlow(baseflow,'Re',Re);
    baseflow=SF_Adapt(ForcedField);%...
    SF_HarmonicForcing(baseflow,Re,Omega_values,formulation);
    disp('___________________________________________________')%To separete iters
end
%... to continue

%% Data treatement: General
%select the desired omegas and re

figure
Re_tab=[15 25 35 55];
%Re_tab=Rec1_convergence_tab; % For the Rec1
% For the Rec2...
% For the Rec3...
formulation='R'; 
for Re=Re_tab
    %extract data from importFFdata...
    all_data_stored_file={[ffdataharmonicdir{1}  formulation 'Forced_Harmonic2D_Re' num2str(Re) 'TOTAL.ff2m']};
    dataRe=importFFdata(all_data_stored_file{1} );
    SF_HarmonicForcing_Display(dataRe.OMEGAtab,dataRe.Lift,Re_tab); 
end

%% Iterative method to find Rec1

%erase previous values for Re=20 for assured convergence
formulation='R';
Re=20; %Re initial
Omega_values=linspace(0.64,0.67,10);%omegas init
baseflow=SF_BaseFlow(baseflow,'Re',Re);

SF_HarmonicForcing(baseflow,Re,Omega_values,formulation);
all_data_stored_file={[ffdataharmonicdir{1}  formulation 'Forced_Harmonic2D_Re' num2str(Re) 'TOTAL.ff2m']};
dataRe=importFFdata(all_data_stored_file{1});
[Zr_min,indexmin]=min(real(dataRe.Lift));
Omegamin=dataRe.OMEGAtab(indexmin);
Zimin=imag(dataRe.Lift(indexmin));

incrementRe=0.1;
incrementOMEGA=0.02;
Re_last=25;% just to enter the loop
Zr_min_last=Zr_min;
Rec1_convergence_tab=[Re];
incrementOMEGA_TAB=[0.02];
Omegamin_tab=[Omegamin];
Zimin_tab=[Zimin];
Zrmin_tab=[Zr_min];
indexmin_tab=[indexmin];

while(abs(Re_last-Re)>0.0005 || incrementOMEGA>0.0005)
    disp('___________________________________________________')%To separete iters
    Zr_min_last=Zr_min;
    Re_last=Re;
    
    if(Zr_min_last>0)
        Re=Re_last+incrementRe;
    elseif(Zr_min_last<0)
        Re=Re_last-incrementRe;
    elseif(Zr_min_last==0)
        break;
    end
    
    baseflow=SF_BaseFlow(baseflow,'Re',Re);
    Omega_values=linspace(Omegamin-incrementOMEGA,Omegamin+incrementOMEGA,10);
    SF_HarmonicForcing(baseflow,Re,Omega_values,formulation);
    
    all_data_stored_file={[ffdataharmonicdir{1}  formulation 'Forced_Harmonic2D_Re' num2str(Re) 'TOTAL.ff2m']};
    dataRe=importFFdata(all_data_stored_file{1});
    [Zr_min,indexmin]=min(real(dataRe.Lift));
    Omegamin=dataRe.OMEGAtab(indexmin);
    
    if((Zr_min_last*Zr_min)<0&& abs(Re_last-Re)>0.0005)
        incrementRe=0.5*incrementRe;
    end
    if((Zr_min_last*Zr_min)<0 && incrementOMEGA>0.0005)
        incrementOMEGA=0.5*incrementOMEGA;
    end
    
    Rec1_convergence_tab=[Rec1_convergence_tab Re];
    incrementOMEGA_TAB=[incrementOMEGA_TAB incrementOMEGA];
    Omegamin_tab=[Omegamin_tab Omegamin];
    Zimin_tab=[Zimin_tab Zimin];
    Zrmin_tab=[Zrmin_tab Zr_min];
    indexmin_tab=[indexmin_tab indexmin];
    disp(['RE TAB:' num2str(Rec1_convergence_tab)]);
end

 [Zr_min_FINAL_REc1,indexmin]=min(abs(Zrmin_tab));
 Re_c1_FINAL_REc1=Rec1_convergence_tab(indexmin);
 Zimin_FINAL_REc1=Zimin_tab(indexmin);
 Omegamin_FINAL_REc1=Omegamin_tab(indexmin);
 
disp('Loop Terminated');
disp(['Rec1=' num2str(Re_c1_FINAL_REc1)]);
%save_data_final_Rec1={[ffdataharmonicdir{1}  formulation 'DATA.mat']};
%save(save_data_final_Rec1{1},'Rec1_convergence_tab','Omegamin_tab','Zimin_tab','Zrmin_tab','Re_c1_FINAL_REc1','Zimin_FINAL_REc1','Omegamin_FINAL_REc1')


%% Iterative method to find Rec2 To redo

%erase previous values for Re=30.3 for assured convergence
Re=30.3; %Re initial
Omega_values=linspace(0.56,0.62,10);%omegas init
baseflow=SF_BaseFlow(baseflow,'Re',Re);
formulation='R';

SF_HarmonicForcing(baseflow,Omega_values,formulation);
all_data_stored_file=[ffdataharmonicdir, formulation 'Forced_Harmonic2D_Re' num2str(Re) 'TOTAL.ff2m'];
dataRe=importFFdata(all_data_stored_file);
[Zi_min,indexmin]=min(imag(dataRe.Lift));
Omegamin=dataRe.OMEGAtab(indexmin);
Zrmin=imag(dataRe.Lift(indexmin));

incrementRe=0.1;
incrementOMEGA=0.02;
Re_last=32;% just to enter the loop
Zi_min_last=Zi_min;
Rec2_convergence_tab=[Re];
incrementOMEGA_TAB=[0.02];
Omegamin_tab=[Omegamin];
Zrmin_tab=[Zrmin];
indexmin_tab=[indexmin];

while(abs(Re_last-Re)>0.0005 || incrementOMEGA>0.0005)
    disp('___________________________________________________')%To separete iters
    Zi_min_last=Zi_min;
    Re_last=Re;
    
    if(Zi_min_last>0)
        Re=Re_last+incrementRe;
    elseif(Zi_min_last<0)
        Re=Re_last-incrementRe;
    elseif(Zi_min_last==0)
        break;
    end
    
    baseflow=SF_BaseFlow(baseflow,'Re',Re);
    Omega_values=linspace(Omegamin-incrementOMEGA,Omegamin+incrementOMEGA,10);
    SF_HarmonicForcing(baseflow,Omega_values,formulation);
    
    all_data_stored_file=[ffdataharmonicdir, formulation 'Forced_Harmonic2D_Re' num2str(Re) 'TOTAL.ff2m'];
    dataRe=importFFdata(all_data_stored_file);
    [Zi_min,indexmin]=min(imag(dataRe.Lift));
    Omegamin=dataRe.OMEGAtab(indexmin);
    
    if((Zi_min_last*Zi_min)<0&& abs(Re_last-Re)>0.0005)
        incrementRe=0.5*incrementRe;
    end
    if((Zi_min_last*Zi_min)<0 && incrementOMEGA>0.0005)
        incrementOMEGA=0.5*incrementOMEGA;
    end
    
    Rec2_convergence_tab=[Rec2_convergence_tab Re];
    incrementOMEGA_TAB=[incrementOMEGA_TAB incrementOMEGA];
    Omegamin_tab=[Omegamin_tab Omegamin];
    Zrmin_tab=[Zrmin_tab Zrmin];
    indexmin_tab=[indexmin_tab indexmin];
end

disp(['RE TAB:' num2str(Rec2_convergence_tab)]);
disp('Loop Terminated');
disp(['Rec2=' num2str(Re)]);
%Re=30.349
%omega=0.5972
%St=0.0950
%Zr=0

%St_tab=Omega_values/2/pi;
%Omega_values=St_tab*2*pi;

%% Iterative method to find Rec3 To redo
%St_tab=Omega_values/2/pi;
%Omega_values=St_tab*2*pi;

%erase previous values for Re=46.6 for assured convergence
Re=46.6; %Re init
Omega_values=linspace(0.72,0.75,10);%omegas init
formulation='R';

baseflow=SF_BaseFlow(baseflow,'Re',Re);
SF_HarmonicForcing(baseflow,Omega_values,formulation);
all_data_stored_file=[ffdataharmonicdir, formulation 'Forced_Harmonic2D_Re' num2str(Re) 'TOTAL.ff2m'];
dataRe=importFFdata(all_data_stored_file);

[Yr_close,index_close]=min(abs(real(1./dataRe.Lift)));
Yi_close=imag(1/dataRe.Lift(index_close));
Omegamin=dataRe.OMEGAtab(index_close);

norm=sqrt( real(1/dataRe.Lift(index_close)).^2+ imag(1/dataRe.Lift(index_close))^2 ) ;
norm_tab=[norm];
incrementRe=0.1;
incrementOMEGA=0.02;
Re_last=46;% just to enter the loop
Rec3_convergence_tab=[Re];
incrementOMEGA_TAB=[0.02];
Omegamin_tab=[Omegamin];
ALL_OMEGA_VALUES=[Omega_values];


while(abs(Re_last-Re)>0.0005 || incrementOMEGA>0.0005)
    disp('___________________________________________________')%To separete iters
    Yi_close_last=Yi_close;
    Re_last=Re;
    
    if(Yi_close>0)
        Re=Re_last+incrementRe;
    elseif(Yi_close<0)
        Re=Re_last-incrementRe;
    elseif(Yi_close==0)
        break;
    end
    
    baseflow=SF_BaseFlow(baseflow,'Re',Re);
    Omega_values=linspace(Omegamin-incrementOMEGA,Omegamin+incrementOMEGA,10);
    ALL_OMEGA_VALUES=[ALL_OMEGA_VALUES;Omega_values];
    SF_HarmonicForcing(baseflow,Omega_values,formulation);
    
    all_data_stored_file=[ffdataharmonicdir, formulation 'Forced_Harmonic2D_Re' num2str(Re) 'TOTAL.ff2m'];
    dataRe=importFFdata(all_data_stored_file);
    
    [Yr_close,index_close]=min(abs(real(1./dataRe.Lift)));
    Yi_close=imag(1/dataRe.Lift(index_close));
     Omegamin=dataRe.OMEGAtab(index_close);
    
    norm=sqrt( real(1/dataRe.Lift(index_close)).^2+ imag(1/dataRe.Lift(index_close))^2 ) ;
    
    if((Yi_close_last*Yi_close)<0&& abs(Re_last-Re)>0.0005)
        incrementRe=0.5*incrementRe;
    end
    if((Zi_min_last*Zi_min)<0 && incrementOMEGA>0.0005)
        incrementOMEGA=0.5*incrementOMEGA;
    end
    
    
    Rec3_convergence_tab=[Rec3_convergence_tab Re];
    norm_tab=[norm_tab norm];
    incrementOMEGA_TAB=[incrementOMEGA_TAB incrementOMEGA];
    Omegamin_tab=[Omegamin_tab Omegamin];
    
end

disp(['RE TAB:' num2str(Rec3_convergence_tab)]);
disp('Loop Terminated');
disp(['Rec3=' num2str(Re)]);
%Re=46.766 (see manually after covergence, due to lack of precision on omega)
%omega=0.7323
%St=0.1165
%Zr=0

%% Limit Case St tends to ZERO and INF 
% See Main2_Forced_Case_Limits...
%% Impedance Treatment
% See "Main2_Impedance_based_predictions.m" that uses "SF_Impedance_Treatement.m"
%% TRASH: Spectial treatement for a beautiful plot of Rec3: do it manually
if(1==0)
    %First erase the purple line manually in graph 5 for Re=46.7
    %The execute this
    txt_data = importdata([ ffdataharmonicdir,'HARMONIC_2D_LateralOscillations_Re46.7.txt']);
	Omegatab= txt_data(:,1);
	Ltab = txt_data(:,3)+1i*txt_data(:,4);
    U=1; D=1; %Cylinder non-dimentionnal definitions
    Strouhal_number=Omegatab/(2*pi)*U/D;
    subplot(2,3,5)
    plot(real(Ltab(1:35)),imag(Ltab(1:35)),'m-o','MarkerSize',2);
    plot(real(Ltab(36:end)),imag(Ltab(36:end)),'m-o','MarkerSize',2);
    %Finally change manually the color of the line to correspond to the
    %legend. Right-click mouse-> edit...etc ;)
end
