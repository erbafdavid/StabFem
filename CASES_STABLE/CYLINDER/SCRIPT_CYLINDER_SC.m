%  Instability of the wake of a cylinder with STABFEM  
%
%  this script reproduces the results of the Self-Consistent model
%  of Mantic-Lugo et al. 


%% ##### CHAPTER 1 : COMPUTING THE MESH WITH ADAPTMESH PROCEDURE
run('../../SOURCES_MATLAB/SF_Start.m');verbosity = 10;
figureformat='png'; AspectRatio = 0.56; % for figures

type = 'S';
bf = CYLINDER_MESHGENERATION(type); 
    % here use 'S' for mesh M2 (converged results for all quantities except for A_E , but much faster
    % or 'D' for mesh M4 (converged results for all quantities, but much
    % slower)


%%  CHAPTER 2 : determining instability threshold

disp('COMPUTING INSTABILITY THRESHOLD');
bf=SF_BaseFlow(bf,'Re',50);
[ev,em] = SF_Stability(bf,'shift',+.75i,'nev',1,'type','D');
[bf,em]=SF_FindThreshold(bf,em);
Rec = bf.Re;  Fxc = bf.Fx; 
Lxc=bf.Lx;    Omegac=imag(em.lambda);

disp(' ');disp(['   ===> THRESHOLD FOUND FOR Re = ',num2str(Rec)]);disp(' ');


%% CHAPTER 6 : SELFCONSISTENT APPROACH WITH RE = 100

%%% (Reproducing the figure of Mantic-Lugo)
%%%
%%% HERE the initial guess is for sigma = 0.12 (slightly less than the
%%% linear growth rate, the initialisation is done with the linear eigmode
%%% with a "small" amplitude (measured by lift force), namely Fy=0.00734 .


% determination of meanflow/selfconsistentmode for Re = 100
Fyguess = 0.00734;
bf=SF_BaseFlow(bf,'Re',100);
[ev,em] = SF_Stability(bf,'shift',0.12+0.72i,'nev',1,'type','D');

sigma_SC = [real(em.lambda),0.12 0.115 0.11 0.1:-.02:0];
Fy_SC = [0]; AEnergy_SC = [0];

    [meanflow,mode] = SF_HB1(bf,em,'sigma',0.12,'Fyguess',Fyguess) 
    Fy_SC = [Fy_SC mode.Fy];
    AEnergy_SC = [AEnergy_SC mode.AEnergy];
for sigma = sigma_SC(3:end)
    [meanflow,mode] = SF_HB1(meanflow,mode,'sigma',sigma)
    Fy_SC = [Fy_SC mode.Fy];
    AEnergy_SC = [AEnergy_SC mode.AEnergy];
end

%% Generating figures

figure(31);hold on;
plot(sigma_SC,real(Fy_SC),'b-+','LineWidth',2);
xlabel('sigma');ylabel('Fy');
title('SC model results for Re=100');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_SC100_FySigma',figureformat);


figure(32);hold on;
plot(AEnergy_SC,sigma_SC,'b-+','LineWidth',2);
ylabel('$\sigma$','Interpreter','latex');xlabel('A_E');
title('SC model results for Re=100');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,['Cylinder_SC100_EnergySigma_type',type],figureformat);
