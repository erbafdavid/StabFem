function filename=SF_Data_Treatement(MODE,AXIS,folder_plot,Re_plot,m_star_plot,DAMP_tab)
%%
%For the text in the spectrum: go tho line 133 and uncomment
all_paths={};
Legend={};
curve_zone_unstable1=[];%For Fluid
curve_zone_unstable2=[];%For Structure
curve_zone_unstable3=[];%For the conclusion of both
value_discovered=0;

for element= 1: size(folder_plot,2)
    for R=Re_plot
        for m=m_star_plot
            for DAMP=DAMP_tab
                all_paths{end+1}=strcat(folder_plot{element},'Re',num2str(R),'/mstar',num2str(m),'/DAMP',num2str(DAMP),'/');
            end
        end
    end
end

disp(all_paths)

f_subplot1=figure; % Used by all options and it has a silly name

for element= 1: size(all_paths,2)
    if(exist(all_paths{element})~=7&&exist(all_paths{element})~=5)
        disp('ERROR: The Folder of the data demanded was not calculated yet !!!!');
    else
        switch MODE
            case('Mode:Fluid')
                extracting=[all_paths{element} '03modeFLUID_data.mat'];
                Legend{end+1}=extracting;
                ploting=load( extracting,'Re','m_star','sigma_tab','U_star','Stiffness_table');
                filename={'03modeFLUID'};%For the saving, outside
            case('Mode:Structure')
                extracting=[all_paths{element} '02modeSTRUCTURE_data.mat'];
                Legend{end+1}=extracting;
                ploting=load( extracting,'Re','m_star','sigma_tab','U_star','Stiffness_table');
                filename={'03modeSTRUCTURE'};%For the saving, outside
            case('Mode:Both')
                extracting=[all_paths{element} '03modeFLUID_data.mat'];
                Legend{end+1}=extracting;
                extracting2=[all_paths{element} '02modeSTRUCTURE_data.mat'];
                Legend{end+1}=extracting2;
                ploting=load( extracting,'Re','m_star','sigma_tab','U_star','Stiffness_table');
                ploting2=load( extracting2,'Re','m_star','sigma_tab','U_star','Stiffness_table');
                filename={'04modeBOTH'};%For the saving, outside
        end
        switch AXIS
            case{'Axis:sigma_rCOMP','Axis:sigma_rCOMPRe33m50'}
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %case('Axis:sigma_r')
                filename={[filename{1} '_sigma_r']};%For the saving, outside
                figure(f_subplot1);hold on
                
                plot(ploting.U_star,real(ploting.sigma_tab),'o-','MarkerSize',2);
                plot(ploting.U_star,ploting.U_star*0,'--k','LineWidth',0.1,'HandleVisibility','off')
                if(strcmp(MODE,'Mode:Both')==1)
                    plot(ploting2.U_star,real(ploting2.sigma_tab),'o-','MarkerSize',2);
                end
                title('Amplification Rate');
                xlabel('U^*'); ylabel('\lambda_r');
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case('Axis:sigma_VS_Ustar') 
                filename={[filename{1} '_sigma_VS_Ustar']};
                figure(f_subplot1);
                subplot(2,1,1);hold on
                plot(ploting.U_star,real(ploting.sigma_tab),'o-','MarkerSize',2);
                plot(ploting.U_star,ploting.U_star*0,'--k','LineWidth',0.1,'HandleVisibility','off')
                if(strcmp(MODE,'Mode:Both')==1)
                    plot(ploting2.U_star,real(ploting2.sigma_tab),'o-','MarkerSize',2);
                end
                title('Amplification Rate');
                xlabel('U^*'); ylabel('\lambda_r');
                subplot(2,1,2);hold on;
                plot(ploting.U_star,imag(ploting.sigma_tab),'o-','MarkerSize',2);
                if(strcmp(MODE,'Mode:Both')==1)
                    plot(ploting2.U_star,imag(ploting2.sigma_tab),'o-','MarkerSize',2);
                end
                title('Oscillation Rate');
                xlabel('U^*'); ylabel('\lambda_i');
            case{'Axis:F_LSA_VS_Ustar','Axis:NavroseMittal2016LockInRe60M20','Axis:NavroseMittal2016LockInRe60M5'} %Done %('Axis:F_LSA_VS_Ustar')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %case('Axis:F_LSA_VS_Ustar')
                filename={[filename{1} '_F_LSA_VS_Ustar']};
                figure(f_subplot1);
                subplot(2,1,1);hold on
                plot(ploting.U_star,real(ploting.sigma_tab),'o-','MarkerSize',2);
                plot(ploting.U_star,ploting.U_star*0,'--k','LineWidth',0.1,'HandleVisibility','off')
                if(strcmp(MODE,'Mode:Both')==1)
                    plot(ploting2.U_star,real(ploting2.sigma_tab),'o-','MarkerSize',2);
                end
                title('Amplification Rate');
                xlabel('U^*'); ylabel('\lambda_r');
                subplot(2,1,2);hold on;
                plot(ploting.U_star,imag(ploting.sigma_tab)/(2*pi),'o-','MarkerSize',2);
                if(strcmp(MODE,'Mode:Both')==1)
                    plot(ploting2.U_star,imag(ploting2.sigma_tab)/(2*pi),'o-','MarkerSize',2);
                end
                title('Non-Dimensional Frequency F_{LSA}=\lambda_i/(2\pi)');
                xlabel('U^*'); ylabel('F_{LSA}');
            case{'Axis:fstar_LSA_VS_Ustar','Axis:NavroseMittal2016LockInRe40M10'} %Done
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %case('Axis:fstar_LSA_VS_Ustar')
                filename={[filename{1} '_fstar_LSA_VS_Ustar']};%For the saving, in the end of this function
                figure(f_subplot1);
                subplot(2,1,1);hold on
                plot(ploting.U_star,real(ploting.sigma_tab),'o-','MarkerSize',2);
                plot(ploting.U_star,ploting.U_star*0,'--k','LineWidth',0.1,'HandleVisibility','off')
                if(strcmp(MODE,'Mode:Both')==1)
                    plot(ploting2.U_star,real(ploting2.sigma_tab),'o-','MarkerSize',2);
                end
                title('Amplification Rate');
                xlabel('U^*'); ylabel('\lambda_r');
                subplot(2,1,2);hold on;
                plot(ploting.U_star,imag(ploting.sigma_tab).*ploting.U_star/(2*pi),'o-','MarkerSize',2);
                if(strcmp(MODE,'Mode:Both')==1)
                    plot(ploting2.U_star,imag(ploting2.sigma_tab).*ploting.U_star/(2*pi),'o-','MarkerSize',2);
                end
                title('Frequency Ratio f^*_{LSA}=\lambda_iU^*/(2\pi)');
                xlabel('U^*'); ylabel('f^*_{LSA}');
            case('Axis:sigma_r_VS_Ustar_LSA') %THE SNAKE
                if(strcmp(MODE,'Mode:Both')==1)
                    filename={[filename{1} '_sigma_r_VS_Ustar_LSA']};
                    figure(f_subplot1); hold on;
                    plot((2*pi)./imag(ploting.sigma_tab),real(ploting.sigma_tab),'o-','MarkerSize',2);
                    plot((2*pi)./imag(ploting2.sigma_tab),real(ploting2.sigma_tab),'o-','MarkerSize',2);
                    plot(ploting.U_star,ploting.U_star*0,'--k','LineWidth',0.1,'HandleVisibility','off')
                    title('Variation of \lambda_r with U^*_{LSA}=2\pi/\lambda_i');
                    xlabel('U^*_{LSA}'); ylabel('\lambda_r');
                else
                    disp('This system of axis must be done with the option: Mode:Both ');
                end
            case('Axis:spectrum')
                filename={[filename{1} '_post_spectrum']};%For the saving, in the end of this function
                figure(f_subplot1); hold on;
                plot(real(ploting.sigma_tab),imag(ploting.sigma_tab),'*-','MarkerSize',2);
                %TEXT TO PUT:
                [a1,a2]=max(real(ploting.sigma_tab));
                text_to_put=[ '\leftarrow' num2str(ploting.U_star(a2), '%.2f') ];
                text(real(ploting.sigma_tab(a2)),imag(ploting.sigma_tab(a2)),text_to_put);
                [a1,a22]=min(abs(real(ploting.sigma_tab(1:a2))-0.01));
                text_to_put=[ '\leftarrow' num2str(ploting.U_star(a22), '%.2f') ];
                text(real(ploting.sigma_tab(a22)),imag(ploting.sigma_tab(a22)),text_to_put);
                [a1,a3]=min(abs(real(ploting.sigma_tab(a22:end))-0.01));
                text_to_put=[ '\leftarrow' num2str(ploting.U_star(a3+a22-1), '%.2f') ];
                text(real(ploting.sigma_tab(a3+a22-1)),imag(ploting.sigma_tab(a3+a22-1)),text_to_put);
                for i=1:size(ploting.U_star,2)%Comment this loop if no text is desired
                    if (mod(size(ploting.U_star,2),i)==1000)
                        text_to_put=[ '\leftarrow' num2str(ploting.U_star(i), '%.2f') ];
                        text(real(ploting.sigma_tab(i)),imag(ploting.sigma_tab(i)),text_to_put);
                    end
                end
                text_to_put=[ '\leftarrow' num2str(ploting.U_star(end), '%.2f') ];
                text(real(ploting.sigma_tab(end)),imag(ploting.sigma_tab(end)),text_to_put); %AT THE END
                %END
               
                plot([0 0],[0.4 2.2],'--k','LineWidth',0.1,'HandleVisibility','off')
                title('Spectrum (with U* at each point)'); xlabel('\lambda_r'); ylabel('\lambda_i');
                if(strcmp(MODE,'Mode:Both')==1)
                    plot(real(ploting2.sigma_tab),imag(ploting2.sigma_tab),'*-','MarkerSize',2);
                    %TEXT TO PUT:
                    for i=1:size(ploting.U_star,2)%Comment this loop if no text is desired
                        if (mod(size(ploting.U_star,2),i)==5)
                            text_to_put=[ '\leftarrow' num2str(ploting2.U_star(i), '%.2f') ];
                            text(real(ploting2.sigma_tab(i)),imag(ploting2.sigma_tab(i)),text_to_put);
                        end
                    end
                    text_to_put=[ '\leftarrow' num2str(ploting2.U_star(end), '%.2f') ];
                    text(real(ploting2.sigma_tab(end)),imag(ploting2.sigma_tab(end)),text_to_put);
                    %END
                end
            case('Axis:Zone_m_star_vs_Ustar') %THE post-treatement grafic
                if(strcmp(MODE,'Mode:Both')==1)
                    m_star = extractAfter(all_paths{element},'mstar');
                    m_star = extractBefore(m_star,'/');
                    for i=1:(size(real(ploting2.sigma_tab),2)-1) %Structure=0
                        if (real(ploting2.sigma_tab(i))*real(ploting2.sigma_tab(i+1))<0)
                            if (real(ploting2.sigma_tab(i))<0)%=0
                                curve_zone_unstable2=[curve_zone_unstable2 [0 0 m_star imag(ploting2.sigma_tab(i))]']; value_discovered=1;
                            else
                                curve_zone_unstable2=[curve_zone_unstable2 [0 1 m_star imag(ploting2.sigma_tab(i))]']; value_discovered=1;
                            end
                        end
                    end
                    if (value_discovered==0)
                        disp(['No added value for the Structure mode at m_star=' m_star]);
                        disp('Go to the spectrum to see if it is always positive or negative!!');
                    end
                    value_discovered=0;
                    for i=1:(size(real(ploting.sigma_tab),2)-1) %Fluid=1
                        if (real(ploting.sigma_tab(i))*real(ploting.sigma_tab(i+1))<0)
                            if (real(ploting.sigma_tab(i))<0)%=0
                                curve_zone_unstable1=[curve_zone_unstable1 [1 0 m_star imag(ploting2.sigma_tab(i))]']; value_discovered=1;
                            else
                                curve_zone_unstable1=[curve_zone_unstable1 [1 1 m_star imag(ploting2.sigma_tab(i))]']; value_discovered=1;
                            end
                        end
                    end
                    if (value_discovered==0)
                        disp(['No added value for the Fluid mode at m_star=' m_star]);
                        disp('Go to the spectrum to see if it is always positive or negative!!');
                    end
                    value_discovered=0;
                    
                    
                    
                    
                    
                else
                    disp('This system of axis must be done with the option: Mode:Both ');
                end

                %...case
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%For comparing data; Data available (Re,mstar):
%	Navrose Mittal 2016:(60,20), (60,5), (40,10) 
%	Zhang et al. 2015:(60,20), ...
%	Kou et al 2017: a faire ...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Options: Navrose, Zhang, NavroseZhang
% Navrose_Re_available=[ [60,20]' [60,5]' [40,10]'];
% 
% %part 1: extracting data
% %switch COMPARE
% %    case('Compare:Navrose')
% if(strcmp(COMPARE,'Compare:Navrose')==1|| strcmp(COMPARE,'Compare:Zhang')==1||strcmp(COMPARE,'Compare:NavroseZhang')==1)
% %part 1: extracting data
% %switch COMPARE
%  %   case('Compare:Navrose')
%         for R=Re_plot
%             for m=m_star_plot
%                 if(R==60&&m==20)
%                     N_Re60_m20_r = importdata('./Literature_Data/csv/navroseRE60_M20_real.csv'); %sigma_r vs_ Ustar
%                     N_Re60_m20_i = importdata('./Literature_Data/csv/navroseRE60_M20_imag.csv');
%                     Z_Re60_m20_r = importdata('./Literature_Data/csv/ZhangRE60_M20_real_cut.csv');
%                 elseif(R==60&&m==5)
%                     N_Re60_m5_r = importdata('./Literature_Data/csv/navroseRE60_M5_real.csv'); %sigma_r vs_ Ustar
%                     N_Re60_m5_i = importdata('./Literature_Data/csv/navroseRE60_M5_imag.csv');
%                 elseif(R==40&&m==10)%Il n'existe pas encore
%                     N_Re40_m10_r = importdata('./Literature_Data/csv/navroseRE60_M5_real.csv'); %sigma_r vs_ Ustar
%                     N_Re40_m10_i = importdata('./Literature_Data/csv/navroseRE60_M5_imag.csv');
%                 end
%                 
%                 
%             end
%         end
%         
%         
% end


% 
% for R=Re_plot
%     for m=m_star_plot
%         if((strcmp(COMPARE,'Compare:Navrose')==1&&R==60&&m==20)
%             N_Re60_m20_r = importdata('./Literature_Data/csv/navroseRE60_M20_real.csv'); %sigma_r vs_ Ustar
%             N_Re60_m20_i = importdata('./Literature_Data/csv/navroseRE60_M20_imag.csv');
%             
%         end
%     end
% end

%Navrose comparasion, if demanded:

if(strcmp(AXIS,'Axis:NavroseMittal2016LockInRe60M20')==1||strcmp(AXIS,'Axis:NavroseMittal2016LockInRe60M5')==1||strcmp(AXIS,'Axis:NavroseMittal2016LockInRe40M10')==1)
    switch AXIS
        case('Axis:NavroseMittal2016LockInRe60M20')
            disp('TOTO')
            filename={[filename{1} '_Comparing_to_NavroseRe60M20']};
            Navrose_real = importdata('./Literature_Data/csv/navrose2016_RE60_M20_real.csv');
            Zhang_real = importdata('./Literature_Data/csv/Zhang_RE60_M20_real_cut.csv');
            Navrose_imag = importdata('./Literature_Data/csv/navrose2016_RE60_M20_imag.csv');
        case('Axis:NavroseMittal2016LockInRe60M5')
            filename={[filename{1} '_Comparing_to_NavroseRe60M5']};
            Navrose_real = importdata('./Literature_Data/csv/navrose2016_RE60_M5_real.csv');
            Navrose_imag = importdata('./Literature_Data/csv/navrose2016_RE60_M5_imag.csv');
        case('Axis:NavroseMittal2016LockInRe40M10')
            filename={[filename{1} '_Comparing_to_NavroseRe40M10']};
            Navrose_real = importdata('./Literature_Data/csv/navrose2016_RE40_M10_real.csv');
            Navrose_imag = importdata('./Literature_Data/csv/navrose2016_RE40_M10_imag.csv'); %J AI PAS ENCORE LE FICHIER
    end
    %Column 1: Ustar; %Column 2:Structure MODE; %Column 3: Fluid MODE
    switch MODE
        case('Mode:Structure')
            Legend{end+1}='Error_0.02/NavroseMittal Structure';
            Legend{end+1}='Error_0.02/Zhang Structure';
            subplot(2,1,1);hold on
            plot(Navrose_real.data(:,1),Navrose_real.data(:,3),'--*');
            plot(1./Zhang_real.data(:,1),Zhang_real.data(:,3),'--*'); %Because it is in FN x-axe
            subplot(2,1,2);hold on;
            plot(Navrose_imag.data(:,1),Navrose_imag.data(:,3),'--*');
            plot(8,0.25); %plot toto for avoid error in legend
        case('Mode:Fluid')
            Legend{end+1}='Error_0.02/NavroseMittal Fluid';
            subplot(2,1,1);hold on
            plot(Navrose_real.data(:,1),Navrose_real.data(:,2),'--*');
            subplot(2,1,2);hold on;
            plot(Navrose_imag.data(:,1),Navrose_imag.data(:,2),'--*');
        case('Mode:Both')
            subplot(2,1,1);hold on
            Legend{end+1}='Error_0.02/NavroseMittal Structure';
            Legend{end+1}='Error_0.02/NavroseMittal Fluid';
            plot(Navrose_real.data(:,1),Navrose_real.data(:,3),'--*');
            plot(Navrose_real.data(:,1),Navrose_real.data(:,2),'--*');
            subplot(2,1,2);hold on;
            plot(Navrose_imag.data(:,1),Navrose_imag.data(:,3),'--*');
            plot(Navrose_imag.data(:,1),Navrose_imag.data(:,2),'--*');   
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%For comparing all data but just one grafic
if(strcmp(AXIS,'Axis:sigma_rCOMP')==1)
    filename={[filename{1} '_Comparing']};
    Navrose_real = importdata('./Literature_Data/csv/navrose2016_RE60_M20_real.csv');
    Zhang_real = importdata('./Literature_Data/csv/Zhang_RE60_M20_real_cut.csv');
    %Navrose_imag = importdata('./Navrose_Data/RE60_M20_imag.csv');
    %Column 1: Ustar; %Column 2:Structure MODE; %Column 3: Fluid MODE
    switch MODE
        case('Mode:Structure')
            Legend{end+1}='Error_0.02/NavroseMittal Structure';
            Legend{end+1}='Error_0.02/Zhang Structure';
            plot(Navrose_real.data(:,1),Navrose_real.data(:,3),'--*');
            plot(1./Zhang_real.data(:,1),Zhang_real.data(:,3),'--*'); %Because it is in FN x-axe
        case('Mode:Fluid')
            Legend{end+1}='Error_0.02/NavroseMittal Fluid';
            Legend{end+1}='Error_0.02/Zhang Fluid';
            plot(Navrose_real.data(:,1),Navrose_real.data(:,2),'--*');
            plot(1./Zhang_real.data(:,1),Zhang_real.data(:,2),'--*'); %Because it is in FN x-axe
        case('Mode:Both')
            Legend{end+1}='Error_0.02/NavroseMittal Structure';
            Legend{end+1}='Error_0.02/NavroseMittal Fluid';
            Legend{end+1}='Error_0.02/Zhang Structure';
            Legend{end+1}='Error_0.02/Zhang Fluid';
            plot(Navrose_real.data(:,1),Navrose_real.data(:,3),'--*');
            plot(Navrose_real.data(:,1),Navrose_real.data(:,2),'--*');
            plot(1./Zhang_real.data(:,1),Zhang_real.data(:,3),'--*'); %Because it is in FN x-axe
            plot(1./Zhang_real.data(:,1),Zhang_real.data(:,2),'--*'); %Because it is in FN x-axe
            
    end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%For comparing with Zhang page 87
if(strcmp(AXIS,'Axis:sigma_rCOMPRe33m50')==1)
    filename={[filename{1} '_ComparingZHANGRe33']};
    Zhang_real = importdata('./Literature_Data/csv/Zhang_RE33_M50_real.csv');
    %Column 1: Ustar; %Column 2:Structure MODE; %Column 3: Fluid MODE
    switch MODE
        case('Mode:Structure')
            Legend{end+1}='Error_0.02/Zhang Structure';
            plot(1./Zhang_real.data(:,1),Zhang_real.data(:,2),'--*'); %Because it is in FN x-axe
        case('Mode:Fluid')
            disp('Attention, pas de resultats de Zhang por fluid à Re=33')
        case('Mode:Both')
            disp('Attention, pas de resultats de Zhang por fluid à Re=33')
    end
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ploting 'Axis:Zone_m_star_vs_Ustar'
if (strcmp(AXIS,'Axis:Zone_m_star_vs_Ustar')==1)
    if(isempty(curve_zone_unstable1)==0)%put in the if before
        scatter(curve_zone_unstable1(4,:),curve_zone_unstable1(3,:),'*');
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Adding the legend and saving:
%Figure 1
%figure(f_subplot1); hold on
if(strcmp(AXIS,'Axis:Zone_m_star_vs_Ustar')==0)
    %subplot(2,1,1);hold on 
    Legend = extractAfter(Legend,'Error_0.02/');
    legend(Legend,'Location','southwest','AutoUpdate','off');
end
disp('Attention: Do not forget to save the picture if you want it');
%I decide to put the save part outside
% if(size(all_paths,2)==1)
%     if((strcmp(MODE,'Mode:Fluid')==1||strcmp(MODE,'Mode:Structure')==1)&&strcmp(AXIS,'Axis:sigma_r_VS_Ustar_LSA')==1)
%         disp('Image not saved because this system of axis must be done with the option: Mode:Both')
%     else
%         SF_Save_Data('graphic',General_data_dir,folder_plot,Re_plot,m_star_plot,filename,0,0,0); %Last 3 not used in 'graphic'
%         disp('Figure saved !');
%     end
% else
%     disp('Attention: CHOOSE a filename and save the figure, please!!! (run next lines)');
%     
% end




%curve_zone_unstable1
%curve_zone_unstable2
end