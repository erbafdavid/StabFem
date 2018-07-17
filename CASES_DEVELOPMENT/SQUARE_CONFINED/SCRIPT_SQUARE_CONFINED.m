
run('../SOURCES_MATLAB/SF_Start.m');
figureformat='png'; AspectRatio = 0.56; % for figures

BETA = 0.8;
Lmax = 20;
bf=SF_Init('Mesh_SquareConfined.edp',[BETA -5 Lmax]);
bf.mesh.xlim = [-2 , 4];% this range will be used for all plots 
bf.mesh.ylim = [0  , 1];% idem
for Re = [10 50 70 100 150]
    bf=SF_BaseFlow(bf,'Re',Re);
end

bf=SF_BaseFlow(bf,'Re',150);
%[ev,em] = SF_Stability(bf,'nev',1,'shift',0.15+6.18i,'type','S'); bf = SF_Adapt(bf,em);
[ev,em] = SF_Stability(bf,'nev',1,'shift',0.,'type','S'); 
bf = SF_Adapt(bf,em);

bf=SF_BaseFlow(bf,'Re',250);
%[ev,em] = SF_Stability(bf,'nev',1,'shift',0.15+6.18i,'type','S'); bf = SF_Adapt(bf,em);
[ev,em] = SF_Stability(bf,'nev',1,'shift',0.3,'type','S'); 
bf = SF_Adapt(bf,em);



plotFF(bf,'mesh');
pause(0.1);


% Loop over Re for stability computations
Re_TAB = [85:5:250];
evS_TAB = [];
shift = 0.5;
for Re = Re_TAB
    bf=SF_BaseFlow(bf,'Re',Re);
    if(Re==Re_TAB(1)) sort ='LR' ; else sort = 'cont'; end   % for first computation sort by increasing real part ; for next ones sort by continuation
    evS = SF_Stability(bf,'nev',10,'shift',shift,'sort',sort,'sym','A')
    evS_TAB = [evS_TAB,evS];
end  

evI_TAB = [];
shift = 0.5+6i;
for Re = Re_TAB
    bf=SF_BaseFlow(bf,'Re',Re);
    if(Re==Re_TAB(1)) sort ='LR' ; else sort = 'cont'; end
    evI = SF_Stability(bf,'nev',10,'shift',shift,'sort',sort,'sym','A')
    evI_TAB = [evI_TAB,evI];
end  

figure(10);
for j = 1:4
    plot(Re_TAB,real(evS_TAB(j,:)),'-');hold on;
    plot(Re_TAB,real(evI_TAB(j,:)),'--'); hold on;
end
plot(Re_TAB,0*Re_TAB,'k:')
xlabel('Re' ); ylabel('\lambda_r')
ylim([-.1,.35]);

figure(11);
plot(Re_TAB,imag(10*abs(evS_TAB(1,:))),'-');hold on;    
plot(Re_TAB,imag(evI_TAB(1,:)),'--'); hold on;

xlabel('Re' ); ylabel('\lambda_i ; 10 \lambda_i')
pause(0.1);



