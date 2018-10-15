run('../../SOURCES_MATLAB/SF_Start.m');

bf=SF_Init('Mesh_Resonateur_Design_Ailettes.edp');
bf=SF_BaseFlow(bf,'Re',10);
bf=SF_BaseFlow(bf,'Re',30);
bf=SF_BaseFlow(bf,'Re',60);
bf=SF_BaseFlow(bf,'Re',120);
bf=SF_Adapt(bf);

% illustration of mesh and base flow for Re = 100
bf = SF_BaseFlow(bf,'Re',100)
figure;plotFF(bf,'mesh','title','Mesh');
saveas(gcf,'Mesh','png')
figure;plotFF(bf,'ux','title','Base flow for Re =100','symmetry','XS');
saveas(gcf,'BaseFlow','png')
pause(0.1);

% Illustration of an eigenmode for Re =100

[ev,em] = SF_Stability(bf,'shift',.1+.1i,'nev',10);
figure;plotFF(em(1),'ux1.re','symmetry','XA','title', 'Eigenmode for Re .= 100');
saveas(gcf,'Eigenmode','png')
pause(0.1);

% construction of stability branch

bf=SF_BaseFlow(bf,'Re',40);
[ev,em] = SF_Stability(bf,'shift',-.03+.12i,'nev',1,'type','D');

Re_LIN = [40 :5 :100];
lambda_LIN=[];
    for Re = Re_LIN
        bf = SF_BaseFlow(bf,'Re',Re);
        [ev,em] = SF_Stability(bf,'nev',1,'shift','cont');
        lambda_LIN = [lambda_LIN ev];
    end    

figure(20);subplot(2,1,1);hold on;
plot(Re_LIN,real(lambda_LIN),'b+-');
plot(Re_LIN,0*Re_LIN,'k:');
xlabel('Re');ylabel('\sigma');

figure(20);subplot(2,1,2);hold on;
plot(Re_LIN,imag(lambda_LIN),'b+-');
xlabel('Re');ylabel('\omega' );   
saveas(gcf,'Eigenvalues','png')

%% Have a look at symmetric modes...
bf = SF_BaseFlow(bf,'Re',100)

[ev,em] = SF_Stability(bf,'shift',.1+.3i,'nev',20,'sym','S','PlotSpectrum','yes');

%% impedances
bf = SF_BaseFlow(bf,'Re',200)
bf = SF_Split(bf);
bf = SF_BaseFlow(bf,'Re',250)
bf = SF_BaseFlow(bf,'Re',300)
bf = SF_BaseFlow(bf,'Re',400)


imp = SF_LinearForced(bf,[0 : .01 : 2])
figure;
plot(imp.omega,real(imp.Z),'r-',imp.omega,imag(imp.Z),'r--')

