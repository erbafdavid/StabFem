%%####################################################################
%  STAGE IMFT                                        Adrien Rouviere
%                    -- STABILITY CURVES --
%           -- ÉCOULEMENT AUTOUR D'UN DISQUE POREUX --
%                                                   
%#####################################################################

%% 4 - Sability curves

Re_LIN = [80 : -2 : 50];

baseflow=SF_BaseFlow(baseflow,'Re',100);
[ev,em] = SF_Stability(baseflow,'m',1,'shift',ev,'nev',1);
lambda1_LIN=[];
    for Re = Re_LIN
        baseflow = SF_BaseFlow(baseflow,'Re',Re);
        [ev,em] = SF_Stability(baseflow,'nev',1,'shift','cont');
        lambda1_LIN = [lambda1_LIN ev];
    end    

% baseflow=SF_BaseFlow(baseflow,'Re',100);
% [ev,em]=SF_Stability(baseflow,'m',1,'shift',ev2(1),'nev',1);
% lambda2_LIN=[];
%     for Re = Re_LIN
%         baseflow = SF_BaseFlow(baseflow,'Re',Re);
%         [ev,em] = SF_Stability(baseflow,'nev',1,'shift','cont');
%         lambda2_LIN = [lambda2_LIN ev];
%     end   
%     
% baseflow=SF_BaseFlow(baseflow,'Re',100);
% [ev,em]=SF_Stability(baseflow,'m',1,'shift',ev3(1),'nev',1);
% lambda3_LIN=[];
%     for Re = Re_LIN
%         baseflow = SF_BaseFlow(baseflow,'Re',Re);
%         [ev,em] = SF_Stability(baseflow,'nev',1,'shift','cont');
%         lambda3_LIN = [lambda3_LIN ev];
%     end   

figure();
plot(Re_LIN,real(lambda1_LIN),'b+-');
xlabel('Re');ylabel('$\sigma$','Interpreter','latex');
% box on; pos = get(gcf,'Position'); pos(4)=pos(3);set(gcf,'Position',pos); % resize aspect ratio
% set(gca,'FontSize', 18);
saveas(gca,'PorousDisk_sigma_Re',figureformat);

figure();hold off;
plot(Re_LIN,imag(lambda1_LIN));
xlabel('Re');ylabel('$\omega$','Interpreter','latex');
% box on; pos = get(gcf,'Position'); pos(4)=pos(3);set(gcf,'Position',pos); % resize aspect ratio
% set(gca,'FontSize', 18);
saveas(gca,'PorousDisk_omega_Re',figureformat);    
