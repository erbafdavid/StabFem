%%####################################################################
%  STAGE IMFT                                        Adrien Rouviere
%                         -- BASEFLOW --
%           -- ÉCOULEMENT AUTOUR D'UN DISQUE POREUX --
%                                                   
%#####################################################################

%% 2 - Génération du BASEFLOW pour un certain Re

% Paramètres de calcul
Re_start = [10 50 100 150 200 250];
Omega = [0.];
Darcy = [1e-9];
Porosite = [0.95];

baseflow = SF_BaseFlow(baseflow,'Re',10,'Omegax',Omega,'Darcy',Darcy,'Porosity',Porosite);
% baseflow = SF_BaseFlow(baseflow,'Re',50);
% baseflow = SF_BaseFlow(baseflow,'Re',80);
% baseflow = SF_Adapt(baseflow,'Hmin',1e-7,'Hmax',5);
% baseflow = SF_BaseFlow(baseflow,'Re',100);
% baseflow = SF_BaseFlow(baseflow,'Re',130);
% baseflow = SF_BaseFlow(baseflow,'Re',150);
% baseflow = SF_Adapt(baseflow,'Hmin',1e-7,'Hmax',5);
% baseflow = SF_BaseFlow(baseflow,'Re',170);
% baseflow = SF_BaseFlow(baseflow,'Re',200);
baseflow = SF_Adapt(baseflow,'Hmin',1e-7,'Hmax',5);
baseflow = SF_Adapt(baseflow,'Hmin',1e-7,'Hmax',0.5);
baseflow = SF_Adapt(baseflow,'Hmin',1e-7,'Hmax',0.5);
% baseflow = SF_BaseFlow(baseflow,'Re',105);
% baseflow = SF_BaseFlow(baseflow,'Re',130);
% baseflow = SF_BaseFlow(baseflow,'Re',160);
% baseflow = SF_Adapt(baseflow,'Hmin',1e-7,'Hmax',5);
% baseflow = SF_BaseFlow(baseflow,'Re',165);
% baseflow = SF_BaseFlow(baseflow,'Re',180);
% baseflow = SF_BaseFlow(baseflow,'Re',200);
% baseflow = SF_Adapt(baseflow,'Hmin',1e-7,'Hmax',5);
% baseflow = SF_BaseFlow(baseflow,'Re',210);
% baseflow = SF_BaseFlow(baseflow,'Re',240);
% baseflow = SF_Adapt(baseflow,'Hmin',1e-7,'Hmax',5);
% baseflow = SF_Adapt(baseflow,'Hmin',1e-7,'Hmax',5);

%------------------

% Plot mesh final
figure;
baseflow.xlabel=('x');baseflow.ylabel=('r');
plotFF(baseflow,'mesh','title',['Maillage final du domaine de calcul']);
hold on;fill(boxx,boxy,'y','FaceAlpha', 0.3);hold off;

% Plot ux
figure;
baseflow.xlabel=('x');baseflow.ylabel=('r');
plotFF(baseflow,'ux','Contour','on','CLevels',[0,1e-50],'Title',['Champ de vitesse u_x pour Re = ' num2str(baseflow.Re) ' - \Omega = ' num2str(baseflow.Omegax) ' - Da = ' num2str(baseflow.Darcy) ' - \epsilon = ' num2str(baseflow.Porosity)]);
hold on;plot(boxx, boxy, 'w-');hold off;

% Plot ur
figure;
plotFF(baseflow,'ur','Title',['Champ de vitesse u_r pour Re = ' num2str(baseflow.Re) ' - \Omega = ' num2str(baseflow.Omegax) ' - Da = ' num2str(baseflow.Darcy) ' - \epsilon = ' num2str(baseflow.Porosity)]);
hold on;plot(boxx, boxy, 'w-');hold off;

% Plot uphi
figure;
plotFF(baseflow,'uphi','title',['Champ de vitesse u_\phi pour Re = ' num2str(baseflow.Re) ' - \Omega = ' num2str(baseflow.Omegax) ' - Da = ' num2str(baseflow.Darcy) ' - \epsilon = ' num2str(baseflow.Porosity)]);
hold on;plot(boxx, boxy, 'w-');hold off;

% Plot P
figure;
plotFF(baseflow,'p','title',['Champ de pression P pour Re = ' num2str(baseflow.Re) ' - \Omega = ' num2str(baseflow.Omegax) ' - Da = ' num2str(baseflow.Darcy) ' - \epsilon = ' num2str(baseflow.Porosity)]);
hold on;plot(boxx, boxy, 'w-');hold off;

% Plot Vorticité
figure;
plotFF(baseflow,'vort','title',['Champ de vorticité \omega pour Re = ' num2str(baseflow.Re) ' - \Omega = ' num2str(baseflow.Omegax) ' - Da = ' num2str(baseflow.Darcy) ' - \epsilon = ' num2str(baseflow.Porosity)]);
hold on;plot(boxx, boxy, 'w-');hold off;

% % Plot Lignes de courant
% figure;
% plotFF(baseflow,'psi','Contour','on','Levels',50,'title',['Lignes de courant pour Re = ' num2str(baseflow.Re) ' - \Omega = ' num2str(baseflow.Omegax) ' - Da = ' num2str(baseflow.Darcy) ' - \epsilon = ' num2str(baseflow.Porosity)]);
% hold on;plot(boxx, boxy, 'w-');hold off;