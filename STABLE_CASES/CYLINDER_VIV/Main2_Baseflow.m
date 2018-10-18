%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%>   This is part of StabFem Project.
%>   (set of programs in Freefem to perform global stability calculations  
%>   in hydrodynamic stability)
%>
%>	File: Main2_Baseflow.m
%>   Contributours: Diogo Sabino ...
%>   Last Modification: Diogo Sabino, 16 August 2018
%>   
%>	This script performs simple calculations on te baseflow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialisation
%clear all
global ffdataharmonicdir verbosity ffdatadir
run('../SOURCES_MATLAB/SF_Start.m');

%CHOOSE the domain parameters:
domain_parameters=[-50 50 50];
%domain_parameters=[-100 100 100]; %for the case when St->0
ADAPTMODE='D'; % D, A or S 
[baseflow]= SF_MeshGeneration(domain_parameters,ADAPTMODE);

%% Just 2 points
tic
baseflow=SF_BaseFlow(baseflow,'Re',20);
toc
%%
baseflow=SF_BaseFlow(baseflow,'Re',40);
%% Computation
tic
Cx_tab=[]; Lx_tab=[];
Re_tab=4:2:120;
for Re=Re_tab
    baseflow=SF_BaseFlow(baseflow,'Re',Re);
    %%Data Treatement
    Cx_tab=[Cx_tab baseflow.Cx];
    Lx_tab=[Lx_tab baseflow.Lx];
end
Lx_tab=Lx_tab-0.5;
toc
%% Plot

figure
plot(Re_tab,Cx_tab);
figure
plot(Re_tab,Lx_tab);
%%Save data

dlmwrite('Latex_data/Baseflow/Lx.dat',[Re_tab' Lx_tab']);
dlmwrite('Latex_data/Baseflow/Cx.dat',[Re_tab' Cx_tab']);


%%END FILE