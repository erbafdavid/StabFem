%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                         Forced case limits                          %%%
%%%                                                                     %%%
%%% This program treats to cases for the forced oscillating cylinder:   %%%
%%%   1) When frequency tends to zero --> quasi-static approach         %%%
%%%   2) When frequency tends to infinity --> analytical solution       %%%
%%%                                                                     %%%
%%% Results are provided by Main_FORCED_CYLINDER.m                      %%%
%%% See D.Sabino Master Thesis for further explanations                 %%%
%%% Last modif: 07/07/2018 Diogo                                        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global ffdatadir ffdataharmonicdir verbosity
run('../SOURCES_MATLAB/SF_Start.m');
ffdatadir = './WORK/';
verbosity=100;
%% CHOOSE folder for saving data:
%General_data_dir='v1/General_data/';
%General_data_dir='v1/Rec1/';
%General_data_dir='v1/Rec2/';
%General_data_dir='v1/Rec3/';
%General_data_dir='v1/Limit_St0/';
General_data_dir='v1/Limit_St_Infty/';

domain_parameters=[-50 50 50];
%domain_parameters=[-100 100 100]; %for the case when St->0
domain_identity={[ num2str(domain_parameters(1)) '_' num2str(domain_parameters(2)) '_' num2str(domain_parameters(3)) '/']};

%mesh_identity={'Adapt_D_Hmax2_InterError_0.02/'};
%mesh_identity={'Adapt_S_Hmax2_InterError_0.02/'};
mesh_identity={'Adapt_S_Hmax1_InterError_0.02/'};

savedata_dir={[ General_data_dir domain_identity{1} mesh_identity{1}]};
% path of the saved data for the harmonic case cylinder (repeated in macros.edp)
ffdataharmonicdir={[ffdatadir 'DATA_Forced_Cylinder/' savedata_dir{1} ]};

% Create path if it does not exist
if(exist(ffdataharmonicdir{1})~=7&&exist(ffdataharmonicdir{1})~=5)
    mysystem(['mkdir -p ' ffdataharmonicdir{1}]); %I read in internet that the '-p'(stands for parent) not always work in every shell...
end %It's compulsory: Creation of the directory

formulation='R'; %Put the formulation used
%Normally, this is the general name of the file, so dont change it
filename=[formulation 'Forced_Harmonic2D_Re']; %name WITHOUT the Re

%% Limit St zero
Re_tab=[15:1:60]; %Put the Re_tab that has been calculated
%%%%filename_latex=['./Latex_data/Forced/LimitSt0/mesh50_50_50_CD0.txt'];
%%%%filename_latex=['./Latex_data/Forced/LimitSt0/mesh50_50_50_Lift.txt']; % DONE in relatorio mas està entre \iffalse
%%%%filename_latex=['./Latex_data/Forced/LimitSt0/mesh100_100_100_CD0.txt'];
%%%%filename_latex=['./Latex_data/Forced/LimitSt0/mesh100_100_100_Lift.txt'];%DONE in relatorio
figure; hold on;
for Re=Re_tab
    all_data_stored_file={[ffdataharmonicdir{1}  filename num2str(Re) 'TOTAL.ff2m']};
    dataRe=importFFdata(all_data_stored_file{1} );
    scatter(Re,2*real(dataRe.Lift(6))); % Value to tune: 4 for the -100; 6 for the -50
    scatter(Re,2*real(dataRe.Drag0T));
	%%%%str_latex=['(' num2str(Re) ',' num2str(2*real(dataRe.Drag0T)) ')'];
    %%%%str_latex=['(' num2str(Re) ',' num2str(2*real(dataRe.Lift(6))) ')'];
    %%%%dlmwrite(filename_latex,str_latex,'delimiter', '','-append' )    
end

%% Limit Case St INF Theoretical

Re_tab=[15 25 35 55];
dataANALYTIC={};
om_tab_ANALITIC=1:25:10000;
for Re=Re_tab
    %%%%filename_latex=['./Latex_data/Forced/LimitStINF/Theory_Re' num2str(Re) '.txt'];
    %Calculating Theoretical prediction:
    %radii=1; %cilinder radius
    %rho0=1; %fluid density
    j_plus=(1+1i)/sqrt(2); %constant
    j_minus=(1-1i)/sqrt(2); %constant
    ForceCoeff_ANALITIC=[]; %
    St_ANALITIC=[];
    for om_ANALITIC=om_tab_ANALITIC
        St_ANALITIC=[St_ANALITIC om_ANALITIC/(2*pi)];
        
        nu0=1/Re; %cinematic viscosity
        beta=sqrt(om_ANALITIC/nu0); %constant
        %constant in this case:
        fa=(2*j_plus*besselk(1,j_minus*beta))/(besselk(0,j_minus*beta));
        
        %Theoretical prediction for the Force/Force Coefficient:
        %F=-1i*2*pi*rho0*om_ANALITIC*radii*(radii+fa/beta); this is the brute force
        Force_Coeff=-2*pi*1i*om_ANALITIC*(1+fa/beta);  %This is the coefficient
        
        ForceCoeff_ANALITIC=[ForceCoeff_ANALITIC Force_Coeff];
        %%%%str_latex=['(' num2str(St_ANALITIC(end)) ',' num2str(Force_Coeff) ')'];
        %%%%dlmwrite(filename_latex,str_latex,'delimiter', '','-append' ) 
    end
    dataANALYTIC{end+1}=ForceCoeff_ANALITIC;
end

disp('TOTO')
figure; hold on
plot(log(om_tab_ANALITIC),log(real(dataANALYTIC{1})))
plot(log(om_tab_ANALITIC),log(real(dataANALYTIC{2})))
plot(log(om_tab_ANALITIC),log(real(dataANALYTIC{3})))
plot(log(om_tab_ANALITIC),log(real(dataANALYTIC{4})))

%% Limit Case St INF WITHOUT adaptation

%Re_tab=[15 25 35 55]; %Put the Re_tab that has been calculated
Re_tab=[15 25 35 55]; 

figure; hold on;
for Re=Re_tab
    %%%%filename_latex=['./Latex_data/Forced/LimitStINF/WoutADAPT_Re' num2str(Re) '.txt'];
    all_data_stored_file={[ffdataharmonicdir{1}  filename num2str(Re) 'TOTAL.ff2m']};
    dataRe=importFFdata(all_data_stored_file{1} );
    fv=2;%first value
    lv=size(dataRe.OMEGAtab,1);%last value
    scatter(log10(dataRe.OMEGAtab(fv:lv,1)./(2*pi)),log10( (2*real(dataRe.Lift(fv:lv,1))))  ) %Coefficients to tune in fuction of the points that one has...
    %scatter(dataRe.OMEGAtab(fv:lv,1)./(2*pi), (2*real(dataRe.Lift(fv:lv,1))))  
    %p=polyfit(log(dataRe.OMEGAtab(startfrom:lv,1)./(2*pi)),log(2*real(dataRe.Lift(startfrom:lv,1))),1); %p(1) slop , p2 is the origin
    %y1=polyval(p,log(dataRe.OMEGAtab(startfrom:lv,1)./(2*pi)));
    %plot(log(dataRe.OMEGAtab(startfrom:end,1)./(2*pi)),y1); % so the slop is 0.4785
    %Save data:
    %dlmwrite(['Latex_data/Forced/LimitStinf/LINEAR_Re' num2str(Re) '.dat'],[dataRe.OMEGAtab/(2*pi) 2*real(dataRe.Lift)]);
end

plot(log10(om_tab_ANALITIC./(2*pi)),log10(real(dataANALYTIC{1})),'b')
plot(log10(om_tab_ANALITIC./(2*pi)),log10(real(dataANALYTIC{2})))
plot(log10(om_tab_ANALITIC./(2*pi)),log10(real(dataANALYTIC{3})))
plot(log10(om_tab_ANALITIC./(2*pi)),log10(real(dataANALYTIC{4})),'g')

xlabel('log(St_F)'); ylabel('log(Zr)');

%Save data:
%dlmwrite(['Latex_data/Forced/LimitStinf/ANALYTIC_Re15.dat'],[om_tab_ANALITIC'/(2*pi) real(dataANALYTIC{1})']);
%dlmwrite(['Latex_data/Forced/LimitStinf/ANALYTIC_Re25.dat'],[om_tab_ANALITIC'/(2*pi) real(dataANALYTIC{2})']);
%dlmwrite(['Latex_data/Forced/LimitStinf/ANALYTIC_Re35.dat'],[om_tab_ANALITIC'/(2*pi) real(dataANALYTIC{3})']);
%dlmwrite(['Latex_data/Forced/LimitStinf/ANALYTIC_Re55.dat'],[om_tab_ANALITIC'/(2*pi) real(dataANALYTIC{4})']);

%% Limit Case St INF WITH adaptation

%...

%% TRASH: Limit St tends to infinity

%Select data
formulation='R';
Re_tab=[15 25 35 55];
dataFORCED={};
dataANALYTIC={};
om_tab_ANALITIC=0:25:1000;
for Re=Re_tab
    %Loading FORCED data:
    %(put manually the good data in the folder ffdataharmonicdir)
    %%%all_data_stored_file=[ffdataharmonicdir, formulation 'Forced_Harmonic2D_Re' num2str(Re) 'TOTAL.ff2m'];
    %%%dataFORCED{end+1}=importFFdata(all_data_stored_file);
    %figure; hold on
    %scatter(dataRe.OMEGAtab./(2*pi),(2*real(dataRe.Lift)))
    %p=polyfit(log(dataRe.OMEGAtab./(2*pi)),log(2*real(dataRe.Lift)),1); %p(1) slop , p2 is the origin
    %y1=polyval(p,log(dataRe.OMEGAtab./(2*pi)));
    %plot(log(dataRe.OMEGAtab./(2*pi)),y1);
    % so the slop is 0.4785
    
    %Calculating Theoretical prediction:
    radii=1; %cilinder radius
    rho0=1; %fluid density
    j_plus=(1+1i)/sqrt(2); %constant
    j_minus=(1-1i)/sqrt(2); %constant
    ForceCoeff_ANALITIC=[];
    St_ANALITIC=[];
    for om_ANALITIC=om_tab_ANALITIC
        St_ANALITIC=[St_ANALITIC om_ANALITIC/(2*pi)];
       
        %Re=50;
        nu0=1/Re;
        
        beta=sqrt(om_ANALITIC/nu0); %constant
        %constant in this case:
        fa=(2*j_plus*besselk(1,j_minus*beta*radii))/(besselk(0,j_minus*beta*radii));
        
        %theoretical prediction for the force:
        Force_Coeff=-1i*2*pi*rho0*om_ANALITIC*radii*(radii+fa/beta);
        
        ForceCoeff_ANALITIC=[ForceCoeff_ANALITIC Force_Coeff];
    end
    dataANALYTIC{end+1}=ForceCoeff_ANALITIC;
end

figure; hold on
plot(log(om_tab_ANALITIC),log(real(dataANALYTIC{1})))
plot(log(om_tab_ANALITIC),log(real(dataANALYTIC{3})))
plot(log(om_tab_ANALITIC),log(real(dataANALYTIC{4})))
scatter(log([400 450 500]/(2*pi)),log([10.3751 10.7978 11.1802]))
scatter(log([400 450 500]/(2*pi)),log([13.8513 14.4724 15.0391]))
scatter(log([500 550 600 650 700 800 850 900 950 1000]/(2*pi)),log([26.2503 27.1948 28.083 28.9215 29.7159 30.4706  31.1894  31.8757 32.5322 33.1615]))

