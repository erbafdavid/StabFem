function SF_HarmonicForcing_Display(Omegatab,Ltab,Re_tab)
%	File: SF_HarmonicForcing_Display.m
%   Contributours: David Fabre, Diogo Sabino
%   Last Modification: Diogo Sabino, 18 April 2018

%% Display
%omega_fixed_cylinder=0.744937;
%omega_fixed_cylinder=1;
U=1; D=1; %Cylinder non-dimentionnal definitions
Strouhal_number=Omegatab/(2*pi)*U/D;


subplot(2,3,1);hold on
plot(Strouhal_number,real(Ltab),'-o','MarkerSize',2);
title('Re (Z) as function of omega');
%xlabel('\omega/\omega_0','FontSize',15);ylabel('\Re (Z)','FontSize',15);
xlabel('St','FontSize',15);ylabel('\Re (Z)','FontSize',15);
%axis([0.06 0.18 -1 1.5]) %Case general
%axis([0.097 0.113 -0.01 0.09]) %Case Rec1
%axis([0.075 0.165 -1 1]) %Case Rec3

subplot(2,3,2);hold on
plot(Strouhal_number,imag(Ltab),'-o','MarkerSize',2);
title('Im (Z) as function of omega');
xlabel('St','FontSize',15);ylabel('\Im (Z)','FontSize',15);
%axis([0.06 0.18 -1 2.5])
%axis([0.093 0.099 -0.01 0.025]) %Case Rec2

subplot(2,3,3);hold on
%plot(Strouhal_number,imag(Ltab)./Strouhal_number,'-o','MarkerSize',1);
plot(Strouhal_number,real(1./Ltab),'-o','MarkerSize',2);
title('Re (Y) as function of omega');
xlabel('St','FontSize',15);ylabel('\Re (Y)','FontSize',15);
%axis([0.07 0.13 -6 6])

subplot(2,3,4);hold on
plot(Strouhal_number,imag(1./Ltab),'-o','MarkerSize',2);
title('Im (Y) as function of omega');
xlabel('St','FontSize',15);ylabel('\Im (Y)','FontSize',15);
%axis([0.07 0.13 -4 4])

subplot(2,3,5);hold on
plot(real(Ltab),imag(Ltab),'-o','MarkerSize',2);
title('Nyquist : Z(omega) in the complex plane');
xlabel('\Re (Z)','FontSize',15);ylabel('\Im (Z)','FontSize',15);
%axis([-1 1.5 -1 2.5])
%axis([-0.01 0.09 0.55 1.25]) %Case Rec1
%axis([-0.15 0.15 -0.01 0.02]) %Case Rec2
%axis([-1.5 1.5 -3 4]) %Case Rec3

subplot(2,3,6);hold on
plot(real(1./Ltab),imag(1./Ltab),'-o','MarkerSize',2);
title('AntiNyquist : G(omega) in the complex plane');
xlabel('\Re (Y)','FontSize',15);ylabel('\Im (Y)','FontSize',15);
%axis([-0.5 5 -2 3.5])
%axis([-10 10 -1.4 0.4]) %Case Rec2
%axis([-0.07 0.07 -0.15 0.15]) %Case Rec3

%% Finish Grafics (Save is optional, uncomment for saveas)
%Detect if all Re were plotted
if numel(get(gca,'Children'))==numel(Re_tab)
    Legend=cell(numel(Re_tab),1);  % Size: numel(Re_tab) positions
    for Legend_number = 1:numel(Re_tab)
        Legend{Legend_number}=strcat('Re=',num2str(Re_tab(Legend_number)));
    end
    for i=1:6 %subplot numbers
        subplot(2,3,i)
        legend(Legend,'Location','southwest','AutoUpdate','off');
        %legend('Re=20', 'Re=30', 'Re=40', 'Re=50', 'Re=60','Location','southwest')
        grid on;
        %plot([0 2],[0 0],'k','LineWidth',0.1)
        %saveas(gca,strcat('./DATA_SF_CYLINDER/',int2str(figure_number),'.png'));
    end
end


end

%Trash
%THE OLD 6 IMAGE INDIVIDUAL SCRIPT

%Initilise figures: Axis and label
%figure_number_tab=[3:1:8]; %question

% for figure_number=figure_number_tab
% switch figure_number
%     case 3
%         if(ishandle(figure_number)==0)
%             figure(3);hold on;title('Re (Z) as function of omega');
%             xlabel('\omega/\omega_0','FontSize',15);ylabel('\Re (Z)','FontSize',15);
%         end
%         figure(3);hold on;
%         plot(Omegatab_adim,real(Ltab),'-o','MarkerSize',4);
%     case 4
%         if(ishandle(figure_number)==0)
%             figure(4);hold on;title('Im (Z) as function of omega');
%             xlabel('\omega/\omega_0','FontSize',15);ylabel('\Im (Z)','FontSize',15);
%         end
%         figure(4);hold on;
%         plot(Omegatab_adim,imag(Ltab),'-o','MarkerSize',4);
%     case 5
%         if(ishandle(figure_number)==0)
%             figure(5);hold on;title('Re (Y) as function of omega');
%             xlabel('\omega/\omega_0','FontSize',15);ylabel('\Re (Y)','FontSize',15);
%         end
%         figure(5);hold on;
%         plot(Omegatab_adim,real(1./Ltab),'-o','MarkerSize',4);    
%     case 6
%         if(ishandle(figure_number)==0)
%             figure(6);hold on;title('Im (Y) as function of omega');
%             xlabel('\omega/\omega_0','FontSize',15);ylabel('\Im (Y)','FontSize',15);
%         end
%         figure(6);hold on;
%         plot(Omegatab_adim,imag(1./Ltab),'-o','MarkerSize',4);      
%     case 7  
%         if(ishandle(figure_number)==0)
%             figure(7);hold on; title('Nyquist : Z(omega) in the complex plane');
%             xlabel('\Re (Z)','FontSize',15);ylabel('\Im (Z)','FontSize',15);
%         end
%         figure(7);hold on;
%         plot(real(Ltab),imag(Ltab),'-o','MarkerSize',4);   
%     case 8
%         if(ishandle(figure_number)==0)
%             figure(8);hold on; title('AntiNyquist : Y(omega) in the complex plane');
%             xlabel('\Re (Y)','FontSize',15);ylabel('\Im (Y)','FontSize',15);
%         end
%         figure(8);hold on;
%         plot(real(1./Ltab),imag(1./Ltab),'-o','MarkerSize',4);
% end


