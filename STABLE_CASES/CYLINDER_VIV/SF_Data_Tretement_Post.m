function Point_TAB=SF_Data_Tretement_Post(OPTION,folder_plot,Re_plot,m_star_plot)

all_paths={};
curve_zone_unstable=[];
points_impedance=[];
Point_TAB=[];
for R=Re_plot
    for m=m_star_plot
    all_paths{end+1}=strcat(folder_plot{1},'Re',num2str(R),'/mstar',num2str(m),'/');
    end
end

switch OPTION
    case('Case:Ustar_Re_plane')
        for element= 1: size(all_paths,2)
            %Extract data calculated:
            extracting=[all_paths{element} '02modeSTRUCTURE_data.mat'];
            %Legend{end+1}=extracting;
            ploting=load(extracting,'Re','m_star','sigma_tab','U_star','Stiffness_table');
            %filename={'03modeSTRUCTURE'};%For the saving, outside
            %Re = extractAfter(all_paths{element},'Re');
            % Re = extractBefore(m_star,'/');
            %Discover values for graph
            for i=1:(size(real(ploting.sigma_tab),2)-1)
                if (real(ploting.sigma_tab(i))*real(ploting.sigma_tab(i+1))<0)
                    if (real(ploting.sigma_tab(i))<0)%=0
                        curve_zone_unstable=[curve_zone_unstable [0 ploting.Re ploting.U_star(i)]'];
                    else
                        curve_zone_unstable=[curve_zone_unstable [1 ploting.Re  ploting.U_star(i)]'];
                    end
                end
            end  
        end
        
        figure; hold on;
        %Extract correct data
        switch m_star_plot
            case(50)
                Kou= importdata('./Literature_Data/csv/kou_M50.csv');
                title('Instability Boundaries for m^*=50')
            case(4.73)
                Kou= importdata('./Literature_Data/csv/kou_M4p73.csv');
                title('Instability Boundaries for m^*=4.73')
        end

        %Ploting the points
        %curve_zone_unstable
        xlabel('Re'); ylabel('U^*');
        scatter(Kou.data(:,1),Kou.data(:,2));
        scatter(curve_zone_unstable(2,:),curve_zone_unstable(3,:));
        legend('Kou','Diogo')
        Point_TAB=curve_zone_unstable;
    case('Case:Impedance_Points')%To be deleted: not used
        for element= 1: size(all_paths,2)
            %Extract data calculated:
            extracting=[all_paths{element} '02modeSTRUCTURE_data.mat'];
            %Legend{end+1}=extracting;
            ploting=load(extracting,'Re','m_star','sigma_tab','U_star','Stiffness_table');
            %filename={'03modeSTRUCTURE'};%For the saving, outside
            %Discover values for graph
            [value_max,index_max]=max(real(ploting.sigma_tab));
            Ustar_unstable=ploting.U_star(index_max);
            points_impedance=[points_impedance [ploting.Re ploting.m_star Ustar_unstable]'];
            
        end
        Point_TAB=points_impedance;
end

disp(points_impedance)
end