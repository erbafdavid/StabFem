%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%>   This is part of StabFem Project.
%>   (set of programs in Freefem to perform global stability calculations
%>   in hydrodynamic stability)
%>
%>	File: Main_VIV_Free_Movement.m
%>   Contributours: Diogo Sabino, David Fabre
%>   Last Modification: Diogo Sabino, 17 10 2018
%>
%>   Linear Stability Analysis (LSA) of a rigid circular cilinder mounted
%>	in a spring-damped system
%>
%>   To give a good use of this script, run each section at a time
%>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Mesh: creation and convergence using adapt mesh (last check:17/10/2018)
global  verbosity ffdatadir
clear all; close all
addpath('./../../SOURCES_MATLAB/');
addpath('./../../SOURCES_FREEFEM/');
SF_Start;
%run('../../SOURCES_MATLAB/SF_Start.m'); %not working on Diogo's windows

tic
%CHOOSE the domain parameters:
domain_parameters=[-50 50 50];
%domain_parameters=[-100 100 100];
ADAPTMODE='S'; % D, A or S
[baseflow]= SF_MeshGeneration(domain_parameters,ADAPTMODE);
toc %Time for generating adapted mesh(inerent to StabFEM)

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

%% Computation: Spectrum (last check:18/10/2018)
%Parameters' Definition
%CHOOSE the Re to test:
%Re_tab=[24:1:40]; 
Re_tab=[45];verbosity=10;
for Re=Re_tab
    baseflow = SF_BaseFlow(baseflow,'Re',Re);
    %CHOOSE the m_star to test:
    m_star_tab=[4.95 4.9 4.7:-0.4:2 1.8:-0.2:1 0.9:-0.1:0.1];
    %m_star_tab=[0.9:-0.1:0.1];
    %m_star_tab=5;
    %shift formulation for continuation in mass:
    PPrev=0; PPrevPrev=0; Shift=0; % for  ContMSTAR
    for m_star=m_star_tab
        mass=m_star*pi/4;
        %CHOOSE the DAMPING_tab to test:
        DAMPING_tab=[0];
        for DAMP=DAMPING_tab
            %CHOOSE U_star
            %U_star=[1:0.05:4]; %m=0.05
            %U_star=[2:0.1:7]; %0.3,...,0.1
            %U_star=[3:0.1:7]; %m=0.7,...0.4
            %U_star=[4:0.1:7]; %m=0.9,0.8
            %U_star=[3:0.1:7]; %m=1 RealShift=-0.13; ImagShift=1.1;
            %U_star=[3:0.2:6.5  6.5:0.1:11]; %The most used
            %U_star=[6:-0.3:4 4:-0.5:2.5 2.48:-0.03:2];%AQUI mstar descent
            %U_star=[3 3.1:0.1:3.5 3.75 4]; %preparaçao
            U_star=[3]; %preparaçao
            %U_star=[3 2 1.5 1.4 1.3:-0.02:1.26]%quando ja se está na massa
            %U_star=[1.5:0.005:1.51 3.5 4 4.2:0.02:4.4];
            %U_star=[5:-0.5:4 3.5:-0.01:3.4 3 2.5 2:-0.05:1.65 1.61];%
            %U_star=[500:500:5000];% for studiyng the damping
            %U_star=[1:-0.1:0.1];% limit Ustar tends to 0
            %U_star=8.;
            Stiffness_table=pi^3*m_star./((U_star).^2);
            

            % Spectrum search: See spectrum if wanted, for discover the shift
            if(1==0) %  now actualized: TO DO with the right damping factor...
                sigma_tab=[];
                %Re and mass are already defined above. Define numbers or tables for:
                m_s=1; % mass star
                m=m_s*pi/4; %real mass
                STIFFNESS_to_search=Stiffness_table(end); %Use whatever we want, e.g.: Stiffness_table(1)
                RealShift=[-0.05];
                ImagShift=[0.54 ];
                
                nev=10; %Normally here we don't use just one
                [baseflow,sigma_tab,IECT] = SF_FreeMovement_Spectrum('search',-1,baseflow,sigma_tab,RealShift,ImagShift,STIFFNESS_to_search,m,DAMP,nev); %savedata_dir is not used
                %filename={'01spectrum_search'};
                %SF_Save_Data('spectrum',General_data_dir,savedata_dir,Re,m_star,filename,Stiffness_table,U_star,sigma_tab);
            end
            
            % Mode Follow: Follow a mode along the Stiffness_table/U_star
            %CHOOSE the one for save data w/ a good name:
            modename={'02modeSTRUCTURE'};
            %modename={'03modeFLUID'};
            %filename={[modename{1} 'damp' num2str(DAMP) '_data']}; %For the saved data (it's a cell)
            filename={[modename{1}  '_data']}; %For the saved data (it's a cell)
            savedata_dir_check={[savedata_dir{1} 'Re' num2str(Re) '/mstar' num2str(m_star) '/DAMP' num2str(DAMP) '/' filename{1}]};
            
			%CHOOSE shift:
            shiftmode='ContMSTAR'; %options: 'ContMSTAR' , 'ContUSTAR'
            [RealShift,ImagShift,PPrev,PPrevPrev]=SF_Shift_selection(shiftmode,modename,Re,m_star,U_star,PPrev,PPrevPrev,Shift); %Do not use for particular values, it will not converge
            %use with just one usar that was not calculated yet: contmstar
            %RealShift=0.; ImagShift=0.65; %If you know exactly the value
            sigma_tab=[]; 
            nev=1; %Normally if's just one, but if shift is wrong, it helps to put more
            disp(['this is imagshift tab:' num2str(ImagShift)])
            [baseflow,sigma_tab,IECT] = SF_FreeMovement_Spectrum('modefollow',savedata_dir_check,baseflow,sigma_tab,RealShift,ImagShift,Stiffness_table,mass,DAMP,nev);
            disp(['this is sigma tab:' num2str(sigma_tab)])
            Shift=sigma_tab(1);% for continuation in ContMSTAR
            %For testing just one computation:
			%tic 
            %[ev,em] = SF_Stability(baseflow,'shift',RealShift+ImagShift*1i,'nev',nev,'type','D','STIFFNESS',Stiffness_table(1),'MASS',mass,'DAMPING',DAMP,'Frame','R','PlotSpectrum','no');
            %toc
            %change the stiffness and Ustar Tables to put realy all the values: the ones calculated now and the ones that have already beencalculated
            [sigma_tab,U_star,Stiffness_table]=SF_Order_Tables(savedata_dir_check,IECT,sigma_tab,U_star,Stiffness_table);
            SF_Save_Data('data',General_data_dir,savedata_dir,Re,m_star,filename,Stiffness_table,U_star,sigma_tab,DAMP);
            %close all
        end
    end
end

%% EigenValue: Data Treatement (last check:17/10/2018)

%CHOOSE Data to plot: (Be sure that data exists)
General_data_dir_folder='./Final_Results_v20/';   %General_data_dir; % e.g.: './FOLDER_TOTO/'
%General_data_dir_folder='./Final_Results_v24/';
domain_plot={'-50_50_50/'}; %domain_identity;        %e.g.:{'totodir1','totodir2'} %%FALTA POR O DOMAIN NO PROXIMO LOOP
mesh_plot={'Adapt_S_Hmax1_InterError_0.02/'};%,'Adapt_mode_Hmax1_InterError_0.02/','Adapt_sensibility_Hmax1_InterError_0.02/'
%mesh_plot={'Adapt_D_Hmax10_InterError_0.02/'};
%mesh_plot={'Adapt_D_Hmax10_InterError_0.02/','Adapt_S_Step_mod10_Hmax1_InterError_0.02/'};
folder_plot={};
for element=1:size(mesh_plot,2)
folder_plot{end+1}=[General_data_dir_folder  domain_plot{1} mesh_plot{element} ];
end

Re_plot=[40] ; % Re for previous calculation; for an array:Â [Re1 Re2]
m_star_plot=[1]; % m_star for previous calculation
%DAMPING_tab=[0 0.01 0.02 0.03 0.033 0.031 0.032];
DAMPING_tab=[0];


%The different data treatment options: %How to do:'Mode:-', 'Axis:-'
%Mode:Fluid, Structure or Both
%Axis:sigma_VS_Ustar, F_LSA_VS_Ustar, f_star_LSA_VS_Ustar, sigma_r_VS_Ustar_LSA,
%NavroseMittal2016LockInRe60M20, NavroseMittal2016LockInRe60M5,
%NavroseMittal2016LockInRe40M10, spectrum, sigma_rCOMP,sigma_rCOMPRe33m50
%For testing:
%SF_Data_Treatement('Mode:Both','Axis:NavroseMittal2016LockInRe60M20',folder_plot,Re_plot,m_star_plot);

%IF one data only is plotted
SF_Data_Treatement('Mode:Structure','Axis:spectrum',folder_plot,Re_plot,m_star_plot,DAMPING_tab);
%plot([0.01 0.01],[0.6 1.2], '--','HandleVisibility','off')

%SF_Save_Data('graphic',General_data_dir_folder,folder_plot,Re_plot,m_star_plot,filename,0,0,0,DAMPING_tab); %Last 3 not used in 'graphic'
%ELSE
%SF_Data_Treatement('Mode:Both','Axis:sigma_rCOMP',folder_plot,Re_plot,m_star_plot);
%filename={'Re60_m20_sacar_parte_real'};%CHOOSE name of the figure
%SF_Save_Data('graphic',General_data_dir_folder,folder_plot,Re_plot,m_star_plot,filename,0,0,0,DAMPING_tab); %Last 3 not used in 'graphic'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% EigenMode: Plot (last check:17/10/2018)
%CHOOSE the eigenmode to plot
General_data_dir_folder='./Final_Results_v20/';    %General_data_dir; % e.g.: './FOLDER_TOTO/'
domain_plot={'-50_50_50/'}; %domain_identity;        %e.g.:{'totodir1','totodir2'}
mesh_plot={'Adapt_S_Hmax1_InterError_0.02/'};
folder_plot={[General_data_dir_folder  domain_plot{1} mesh_plot{1} ]}; % isto funciona se forem 2 meshs ??

Re_plot=[60] ; % Re for previous calculation; for an array:Â [Re1 Re2]
m_star_plot=[20]; % m_star for previous calculation
DAMPING_tab=[0];
%Usage:
%%% availability, Compute
%%%Mode:Fluid, Structure or Both
%%%Problem:D, A S

%SEE U_star available
SF_Mode_Display('availability','Mode:Structure',0,0,folder_plot,Re_plot,m_star_plot,DAMPING_tab,0);

% COMPUTE of the demanding eigenmodes
U_star_plot=[4]; %put just one for now...
baseflow = SF_BaseFlow(baseflow,'Re',Re_plot);
[em]=SF_Mode_Display('Compute','Mode:Structure','Problem:A',baseflow,folder_plot,Re_plot,m_star_plot,DAMPING_tab,U_star_plot);

plotFF(em,'vort1Adj.re')
%plotFF(em,'sensitivity')
%plotFF(em,'uy1Adj')

%name=['./Latex_data/Report/S_Sec_GOOD/Re' num2str(Re_plot) 'm' num2str(m_star_plot) 'U' num2str(U_star_plot) '_STRUC.plt'];
%exportFF_tecplot(em,name)

%% Validation with the fixed cilinder (last check:17/10/2018)
%(use mode adapted to the sensitivity)

General_data_dir_folder='./Final_Results_v24/';domain_plot={'-50_50_50/'}; mesh_plot={'Adapt_S_Hmax1_InterError_0.02/'};folder_plot={};
for element=1:size(mesh_plot,2)
    folder_plot{end+1}=[General_data_dir_folder  domain_plot{1} mesh_plot{element} ];
end
Re_plot=[40:5:100];
m_star_plot=[1000];
DAMPING_tab=[0];
lambda_r=[];
lambda_i=[];

for Re=Re_plot
    extracting=[folder_plot{1} 'Re' num2str(Re) '/mstar' num2str(m_star_plot) '/DAMP' num2str(DAMPING_tab) '03modeFLUID_data.mat'];
    ploting=load( extracting,'Re','m_star','sigma_tab','U_star','Stiffness_table');
    lambda_r=[lambda_r real(ploting.sigma_tab(1)) ];
    lambda_i=[lambda_i imag(ploting.sigma_tab(1))];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load fixed cylinder data
FC=load('./Literature_Data/Validation_data_from_fixed_cylinder.mat');

figure; hold on;
plot(Re_plot,lambda_r)
plot(FC.Re_LIN,real(FC.lambda_LIN))
figure; hold on;
plot(Re_plot,lambda_i/(2*pi))
plot(FC.Re_LIN,imag(FC.lambda_LIN)/(2*pi))

%% Grafic U* Re (it is missing the damping in the directories. its just that)
%Put just one path!!
General_data_dir_folder='./Final_Results_v20/';    %General_data_dir; % e.g.: './FOLDER_TOTO/'
domain_plot={'-50_50_50/'}; %domain_identity;        %e.g.:{'totodir1','totodir2'}
mesh_plot={'Adapt_mode_Hmax10_InterError_0.02/'};
folder_plot={[General_data_dir_folder  domain_plot{1} mesh_plot{1} ]}; % isto funciona se forem 2 meshs ??
Re_plot=[20 23 25 27 30 33 35 40 42 43 45];
m_star_plot=50;
%m_star_plot=4.73;

%ADD THE DAMPING !!!!
Point_TAB_ReUstar_plane=SF_Data_Tretement_Post('Case:Ustar_Re_plane',folder_plot,Re_plot,m_star_plot);
%save( './Latex_data/Free/Koucomp/m473_ReUstar_plane.mat','Point_TAB_ReUstar_plane');
%save( './Latex_data/Free/Koucomp/m50_ReUstar_plane.mat','Point_TAB_ReUstar_plane');

%% Impedance Treatment
% See "Main2_Impedance_based_predictions.m" that uses "SF_Impedance_Treatement.m"

%% DAMPING analysis: Search for the critic Re curve
%See the proper damping file somewhere...

%% Non-linear: Validation for big mass ans small Ustar on fluid mode
%not sure it's working...
Re_start=47.;
baseflow = SF_BaseFlow(baseflow,'Re',Re_start);
m_star=1;
U_star=0.1;

mass=m_star*pi/4;
STIFFNESS=pi^3*m_star./((U_star).^2);

shift=0+0.74i;
[ev,em] = SF_Stability(baseflow,'shift',shift,'nev',1,'type','D','STIFFNESS',STIFFNESS,'MASS',mass,'DAMPING',0,'Frame','R');

YGuess=0.001;
Amplitude_HB=[];
[meanflow,mode] = SF_SelfConsistentDirect(baseflow,em,'Yguess',YGuess,'STIFFNESS', STIFFNESS,'MASS',mass,'DAMPING',0);

disp(['The eingenvalue was ' num2str(ev)]);

%% Go to Re=100
Y_HB=[mode.Y];
omega_HB = [imag(mode.lambda)];
Aenergy_HB  = [mode.AEnergy];


Re_tab=[47.5 48 50 52 54 60 65 70 75 80 85 90 95 100];

for Re=Re_tab
    [meanflow,mode]=SF_SelfConsistentDirect(meanflow,mode,'Re',Re,'STIFFNESS', STIFFNESS,'MASS',mass,'DAMPING',0);
    Y_HB=[Amplitude_HB mode.Y];
       omega_HB = [omega_HB imag(mode.lambda)];
       Aenergy_HB  = [Aenergy_HB mode.AEnergy];
end
omega_gallaire = importdata('./Literature_Data/NL/omega_gallaire.csv');
figure; hold on;
plot(omega_gallaire.data(:,1),omega_gallaire.data(:,2))
plot([47 Re_tab],real(omega_HB))
legend('Gallaire2014','Present mstar=1 Ustar=0.1')
A_gallaire = importdata('./Literature_Data/NL/A_gallaire.csv');
figure; hold on
plot([47 Re_tab],real(Aenergy_HB)./sqrt(2))
plot(A_gallaire.data(:,1),A_gallaire.data(:,2))
plot(A_gallaire.data(:,1),A_gallaire.data(:,3))
legend('Present mstar=1 Ustar=0.1','SC Gallaire','DNS Gallaire')

%system(['cp ' ffdatadir 'SelfConsistentMode.ff2m ' ffdatadir 'HB_O1/HB_ModeO1_mstar70_Re100_Ustar6p4.ff2m'])
%system(['cp ' ffdatadir 'MeanFlow.ff2m ' ffdatadir 'HB_O1/MeanFlow_mstar70_Re100_Ustar6p4.ff2m'])
%save('./WORK/HB_O1/amplitude_HBO1_untilRe100.mat','Amplitude_HB', 'Re_tab')

%% Non-linear: Harmonic Balance
%Guess
%not working...

Re_start=45;
baseflow = SF_BaseFlow(baseflow,'Re',Re_start);
m_star=70;
U_star=4.5;

mass=m_star*pi/4;
STIFFNESS=pi^3*m_star./((U_star).^2);

shift=0+1.4i;
[ev,em] = SF_Stability(baseflow,'shift',shift,'nev',1,'type','D','STIFFNESS',STIFFNESS,'MASS',mass,'DAMPING',0,'Frame','R');

YGuess=0.5;

[meanflow,mode] = SF_SelfConsistentDirect(baseflow,em,'Yguess',YGuess,'STIFFNESS', STIFFNESS,'MASS',mass,'DAMPING',0);

%% Go to Ustar 5.5
%Y_HB=[mode.Y];
%omega_HB = [imag(mode.lambda)];
%Aenergy_HB  = [mode.AEnergy];


%Re_tab=[47.5 48 50 52 54 60 65 70 75 80 85 90 95 100];
%Ustar_tab= [4.6 4.7 4.8 4.9 5 5.1 5.2 5.3 5.4 5.5]
Ustar_tab= [8.2]
for Ustar=Ustar_tab
    STIFFNESS=pi^3*m_star./((Ustar).^2);
    [meanflow,mode]=SF_SelfConsistentDirect(meanflow,mode,'Re',100,'STIFFNESS', STIFFNESS,'MASS',mass,'DAMPING',0);
    Y_HB=[Amplitude_HB mode.Y];
	 omega_HB = [omega_HB imag(mode.lambda)];
	Aenergy_HB  = [Aenergy_HB mode.AEnergy];
end

omega_gallaire = importdata('./Literature_Data/NL/omega_gallaire.csv');
figure; hold on;
plot(omega_gallaire.data(:,1),omega_gallaire.data(:,2))
plot([4.5 Ustar_tab],real(omega_HB))
legend('Gallaire2014','Present mstar=1 Ustar=0.1')
A_gallaire = importdata('./Literature_Data/NL/A_gallaire.csv');
figure; hold on
plot([47 Re_tab],real(Aenergy_HB)./sqrt(2))
plot(A_gallaire.data(:,1),A_gallaire.data(:,2))
plot(A_gallaire.data(:,1),A_gallaire.data(:,3))
legend('Present mstar=1 Ustar=0.1','SC Gallaire','DNS Gallaire')

%system(['cp ' ffdatadir 'SelfConsistentMode.ff2m ' ffdatadir 'HB_O1/HB_ModeO1_mstar70_Re100_Ustar6p4.ff2m'])
%system(['cp ' ffdatadir 'MeanFlow.ff2m ' ffdatadir 'HB_O1/MeanFlow_mstar70_Re100_Ustar6p4.ff2m'])
%save('./WORK/HB_O1/amplitude_HBO1_untilRe100.mat','Amplitude_HB', 'Re_tab')

%% Go to Re=100 ...
%to do...
%% follow at Re=100

system(['cp ' ffdatadir 'HB_O1/HB_ModeO1_mstar70_Re100_Ustar6p4.ff2m ' ffdatadir 'SelfConsistentMode.ff2m ' ])
system(['cp ' ffdatadir 'HB_O1/MeanFlow_mstar70_Re100_Ustar6p4.ff2m ' ffdatadir 'MeanFlow.ff2m '])

Re=100;
m_star=70;
U_star_plot=[6.1 6 5.8 5.6 5.4 5.2];
Amplitude_varying_Ustar=Amplitude_HB(end);

for U_star=U_star_plot
    STIFFNESS=pi^3*m_star./((U_star).^2);
    [meanflow,mode]=SF_SelfConsistentDirect(meanflow,em,'Re',Re,'STIFFNESS', STIFFNESS,'MASS',mass,'DAMPING',0);
    Amplitude_varying_Ustar=[Amplitude_varying_Ustar mode.Y];
end
figure
plot([6.2 U_star_plot],real(Amplitude_varying_Ustar))

%save('./WORK/HB_O1/amplitude_HBO1_varyingUstar.mat','Amplitude_varying_Ustar','U_star_plot' )

    