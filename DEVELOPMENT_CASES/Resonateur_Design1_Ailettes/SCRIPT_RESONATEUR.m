run('../../SOURCES_MATLAB/SF_Start.m');

baseflow=SF_Init('Mesh_Resonateur_Design_Ailettes.edp');
baseflow=SF_BaseFlow(baseflow,'Re',10);
baseflow=SF_BaseFlow(baseflow,'Re',30);
baseflow=SF_BaseFlow(baseflow,'Re',60);
baseflow=SF_BaseFlow(baseflow,'Re',120);
baseflow=SF_Adapt(baseflow);

% illustration of mesh and base flow for Re = 100

plotFF(baseflow,'mesh');
plotFF(baseflow,'ux');

% Illustration of an eigenmode for Re =100

[ev,em] = SF_Stability(baseflow,'shift',.1+.1i,'nev',10);
plotFF(em(1),'ux1.re');


% construction of stability branch

baseflow=SF_BaseFlow(baseflow,'Re',40);
[ev,em] = SF_Stability(baseflow,'shift',-.03+.12i,'nev',1,'type','D');

Re_LIN = [40 :5 :100];
lambda_LIN=[];
    for Re = Re_LIN
        baseflow = SF_BaseFlow(baseflow,'Re',Re);
        [ev,em] = SF_Stability(baseflow,'nev',1,'shift','cont');
        lambda_LIN = [lambda_LIN ev];
    end    

figure(20);subplot(2,1,1);hold on;
plot(Re_LIN,real(lambda_LIN),'b+-');
plot(Re_LIN,0*Re_LIN,'k:');
xlabel('Re');ylabel('\sigma');

figure(20);subplot(2,1,2);hold on;
plot(Re_LIN,imag(lambda_LIN),'b+-');
xlabel('Re');ylabel('\omega' );   



