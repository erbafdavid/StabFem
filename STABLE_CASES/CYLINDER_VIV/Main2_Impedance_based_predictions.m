%> @file ./StabFem/STABLE_CASES/CYLINDER_VIV/Main2_Impedance_based_predictions.m
%> @brief Matlab Impedance-Based Predictions Treatement
%> 
%> Usage : Run each section at time and read the comments 
%> @param[in] not
%> OPTIONS :
%> 
%> @param[out] not
%> @param[out] not
%>
%> IMPORTANT NOTE : I have to write something, but I dont have time...
%>
%> @author Diogo Sabino
%> @version 0.0
%> @date 17/10/2018 Release of version 0.0
global ffdatadir ffdataharmonicdir verbosity
addpath('./../../SOURCES_MATLAB/');
addpath('./../../SOURCES_FREEFEM/');
SF_Start;
%run('../../SOURCES_MATLAB/SF_Start.m'); %not working on Diogo's windows
ffdatadir = './WORK/';
verbosity=100;
%% CHOOSE folder for saving data:
%General_data_dir='v1/General_data/';
General_data_dir='v1/General_data_refined/';
%General_data_dir='v1/Rec1/';
%General_data_dir='v1/Rec2/';
%General_data_dir='v1/Rec3/';
%General_data_dir='v1/Limit_St0/';
%General_data_dir='v1/Limit_St_Infty/';

domain_parameters=[-50 50 50];
%domain_parameters=[-100 100 100]; %for the case when St->0
domain_identity={[ num2str(domain_parameters(1)) '_' num2str(domain_parameters(2)) '_' num2str(domain_parameters(3)) '/']};

%mesh_identity={'Adapt_mode_Hmax2_InterError_0.02/'};
%mesh_identity={'Adapt_sensibility_Hmax2_InterError_0.02/'};
%mesh_identity={'Adapt_sensibility_Hmax1_InterError_0.02/'};
mesh_identity={'Adapt_S_Hmax1_InterError_0.02/'};

savedata_dir={[ General_data_dir domain_identity{1} mesh_identity{1}]};
% path of the saved data for the harmonic case cylinder (repeated in macros.edp)
ffdataharmonicdir={[ffdatadir 'DATA_Forced_Cylinder/' savedata_dir{1} ]};
disp('run')
% Create path if it does not exist
if(exist(ffdataharmonicdir{1})~=7&&exist(ffdataharmonicdir{1})~=5)
    mysystem(['mkdir -p ' ffdataharmonicdir{1}]); %I read in internet that the '-p'(stands for parent) not always work in every shell...
end %It's compulsory: Creation of the directory

formulation='R'; %Put the formulation used
%Normally, this is the general name of the file, so dont change it
filename=[formulation 'Forced_Harmonic2D_Re']; %name WITHOUT the Re

%% Order epsilon 0 Predictions at Re=19.95 

load([ffdataharmonicdir{1}  formulation 'DATA.mat'],'Re_c1_FINAL_REc1','Zimin_FINAL_REc1','Omegamin_FINAL_REc1');

%Variation of mstar:
mstar=[0:0.05:19.9 20:0.1:50 60:10:1000];
Ustar_impedance=sqrt((4*(pi^2))./(Omegamin_FINAL_REc1.*(Omegamin_FINAL_REc1+2./(pi.*mstar).*2*Zimin_FINAL_REc1)));
%Plot predictions:
figure
plot(mstar,Ustar_impedance);
figure
loglog(mstar,Ustar_impedance);
figure
semilogx(mstar,Ustar_impedance);
%%%%filename_latex=['./Latex_data/Free/Re20/bIMPEDANCEmesh50_50_50_Re19p95.txt'];%DONE in relatorio
%%%%for index=1:size(mstar,2)
%%%%    str_latex=['(' num2str(mstar(index)) ',' num2str(Ustar_impedance(index)) ')'];
%%%%    dlmwrite(filename_latex,str_latex,'delimiter', '','-append' )
%%%%end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Pour enquanto uso o 19.95
%Data location from free case:
General_data_dir_folder='./Final_Results_v20/';
domain_plot={'-50_50_50/'};
mesh_plot={'Adapt_S_Hmax1_InterError_0.02/'};
folder_plot={[General_data_dir_folder  domain_plot{1} mesh_plot{1} ]};

mstar_free=[0.1:0.1:1 2:1:10 20:10:50 100:100:500 1000];
TAB_FREE=[];
%%%%filename_latex=['./Latex_data/Free/Re20/bFREEmesh50_50_50_Re19p95.txt'];%DONE in relatorio

for mf=mstar_free
    FreeCase=load([folder_plot{1} 'Re' num2str(19.95) '/mstar' num2str(mf) '/02modeSTRUCTURE_data.mat']);
    [lambda_r_Free,index_max]=max(real(FreeCase.sigma_tab));
    U_max=FreeCase.U_star(index_max);
    TAB_FREE=[TAB_FREE, [mf  U_max]'];
    %%%%str_latex=['(' num2str(mf) ',' num2str(U_max) ')'];
    %%%%dlmwrite(filename_latex,str_latex,'delimiter', '','-append' )
end


%Figure
figure;
plot(mstar,Ustar_impedance); hold on;
scatter(TAB_FREE(1,:),TAB_FREE(2,:),'r');

title('Predictions of Impedance Based Method');
xlabel('m^*'); ylabel('U^*');
legend('Impedance Based Predictions','Data from free Case')

%Figure with x-axis in log scale
figure;
semilogx(mstar,Ustar_impedance); hold on;
scatter(TAB_FREE(1,:),TAB_FREE(2,:),'r');

title('Predictions of Impedance Based Method (in log scale)');
xlabel('m^*'); ylabel('U^*');
legend('Impedance Based Predictions','Data from free Case')

%% Order epsilon 0 as function of Re for fixed mass

Tab_FORCED_VALUES=[];
%Variation of Re:
Re_tab=[20:1:46]; %start with a value above the threshold
for Re=Re_tab
   %Load Data Forced-Case:
    all_data_stored_file={[ffdataharmonicdir{1} filename  num2str(Re) 'TOTAL.ff2m']};
    dataRe_total=importFFdata(all_data_stored_file{1});
    for ele=2:size(dataRe_total.Lift,1)
        if(real(dataRe_total.Lift(ele-1))*real(dataRe_total.Lift(ele))<0)
            Tab_FORCED_VALUES=[Tab_FORCED_VALUES;[Re (imag(dataRe_total.Lift(ele))+imag(dataRe_total.Lift(ele-1)) )*0.5   (dataRe_total.OMEGAtab(ele)+dataRe_total.OMEGAtab(ele-1))*0.5 ] ];
        end
    end
end
m_star=4.73;

Ustar_impedance=sqrt((4*(pi^2))./(Tab_FORCED_VALUES(:,3).*(Tab_FORCED_VALUES(:,3)+2./(pi.*m_star).*2*Tab_FORCED_VALUES(:,2))));

%% Plot predictions:
figure;hold on
plot(Ustar_impedance,Tab_FORCED_VALUES(:,1));

Ustar_impedanceORDERED=[];
Re_ORDRED=[];
%%Ordering terms
for toto=size(Ustar_impedance,1):-2:1
    Ustar_impedanceORDERED=[Ustar_impedanceORDERED Ustar_impedance(toto)];
    Re_ORDRED=[Re_ORDRED Tab_FORCED_VALUES(toto,1)];
end
for toto=1:2:size(Ustar_impedance,1)
    Ustar_impedanceORDERED=[Ustar_impedanceORDERED Ustar_impedance(toto)];
    Re_ORDRED=[Re_ORDRED Tab_FORCED_VALUES(toto,1)]
end

figure;hold on
plot(Ustar_impedanceORDERED,Re_ORDRED);
title('Predictions of Impedance Based Method');
xlabel('Re'); ylabel('U^*');
%Save data:

dlmwrite('Latex_data/Impedance/Impedance_pred_RE_m4p73.dat',[Ustar_impedanceORDERED' Re_ORDRED']);

%% Order epsilon 1 Predictions

%Data location from free case:
General_data_dir_folder='./Final_Results_v20/';    %General_data_dir; % e.g.: './FOLDER_TOTO/'
domain_plot={'-50_50_50/'}; %domain_identity;        %e.g.:{'totodir1'}
mesh_plot={'Adapt_S_Hmax1_InterError_0.02/'};
folder_plot={[General_data_dir_folder  domain_plot{1} mesh_plot{1} ]};

Re=40;
mstar=5;

[Ustar_impedance,lambda_r_impedance,U_free,lambda_r_Free,U_freeFLUID,lambda_r_FreeFLUID,Omega_f]=SF_Impedance_Treatement(Re,mstar,folder_plot,filename);

%Figures:
figure, hold on
plot(Ustar_impedance,lambda_r_impedance); %1

plot(U_freeFLUID,lambda_r_FreeFLUID); %2
plot(U_free,lambda_r_Free); %3
plot(Ustar_impedance,Ustar_impedance*0,'k--','HandleVisibility','off');
title(['Comparision Impedance-Based-Method and Free Results for Re=' num2str(Re) ',m^*=' num2str(mstar)]);
xlabel('U^*'); ylabel('\lambda_r');
legend('Impedance Based Predictions','Data from free Case');

%Save data
%dlmwrite(['Latex_data/Impedance/eps2/Impedance_eps2_Re' num2str(Re) '_mstar' num2str(mstar) '.dat'],[Ustar_impedance lambda_r_impedance]);
%dlmwrite(['Latex_data/Impedance/eps2/LSA_FLUID_Re' num2str(Re) '_mstar' num2str(mstar) '.dat'],[U_freeFLUID' lambda_r_FreeFLUID']);
%dlmwrite(['Latex_data/Impedance/eps2/LSA_STRUC_Re' num2str(Re) '_mstar' num2str(mstar) '.dat'],[U_free' lambda_r_Free']);

%%PLOT DAVID
figure
plot(Ustar_impedance,Omega_f);
title(['Comparision Impedance-Based-Method and Free Results for Re=' num2str(Re) ',m^*=' num2str(mstar)]);
xlabel('U^* impedance'); ylabel('\omega_r');
legend('Impedance Based Predictions');
%END FILE