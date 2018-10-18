function [em]=SF_Mode_Display(Mode_option,MODE,EIGENPROBLEM,baseflow,folder_plot,Re_plot,m_star_plot,DAMP_tab,U_star_plot);

all_paths={};
em=-1;

for element= 1: size(folder_plot,2)
    for R=Re_plot
        for m=m_star_plot
            for DAMP=DAMP_tab
            all_paths{end+1}=strcat(folder_plot{element},'Re',num2str(R),'/mstar',num2str(m),'/DAMP',num2str(DAMP),'/');
            end
        end
    end
end

for element= 1: size(all_paths,2)
    disp(['Case:' num2str(element)]);
    switch MODE
        case('Mode:Fluid')
            extracting=[all_paths{element} '03modeFLUID_data.mat'];
            if(exist(extracting)~=2)
                disp(['Data not calculated for mode: ' extracting]);
            else
                DATA=load(extracting,'sigma_tab','U_star','Stiffness_table');
                %filename={'03modeFLUID'};%For the saving, in the end of this function
            end
        case('Mode:Structure')
            extracting=[all_paths{element} '02modeSTRUCTURE_data.mat'];
            if(exist(extracting)~=2) 
                disp(['Data not calculated for mode: ' extracting]);
            else
                DATA=load(extracting,'sigma_tab','U_star','Stiffness_table');
                %filename={'03modeFLUID'};%For the saving, in the end of this function
            end
        case('Mode:Both')
            extracting=[all_paths{element} '03modeFLUID_data.mat'];
            if(exist(extracting)~=2)
                disp(['Data not calculated for mode: ' extracting]);
            else
                DATA=load(extracting,'sigma_tab','U_star','Stiffness_table');
            end
            extracting2=[all_paths{element} '02modeSTRUCTURE_data.mat'];
            if(exist(extracting2)~=2)
                disp(['Data not calculated for mode: ' extracting]);
            else
                DATA2=load(extracting2,'sigma_tab','U_star','Stiffness_table');
                %filename={'04modeBOTH'};%For the saving, in the end of this function
            end
    end
    switch Mode_option
        case('availability')
            switch MODE
                
                case{'Mode:Fluid','Mode:Structure'}
                    if(exist('DATA')==1)
                        disp(MODE);
                        disp(['U_star:' num2str(DATA.U_star)]);
                        disp(['Stiffness_table:' num2str(DATA.Stiffness_table)]);
                    end
                case('Mode:Both')
                    if(exist('DATA')==1&&exist('DATA2')==1)
                        disp('Mode:Fluid');
                        disp(['U_star:' num2str(DATA.U_star)]);
                        disp(['Stiffness_table:' num2str(DATA.Stiffness_table)]);
                        disp('Mode:Structure');
                        disp(['U_star:' num2str(DATA2.U_star)]);
                        disp(['Stiffness_table:' num2str(DATA2.Stiffness_table)]);
                    end
            end
        case('Compute')
            disp(['Attention, if Mode:Both is active it will just do the structure one'])
            disp(['Computing mode for U_star=' num2str(U_star_plot)]);
            m_star = extractAfter(all_paths{element},'mstar');
            m_star = extractBefore(m_star,'/');
            STIFFNESS=pi^3*str2num(char(m_star))./((U_star_plot).^2);
            %sprintf( '%0.20f', DATA.U_star(15))
            %sprintf( '%0.20f', U_star_plot)
            tol=10^(-6);
            index_shift = find(abs(DATA.U_star-U_star_plot)<tol);%to overcome tolerance problems
            shift=DATA.sigma_tab(index_shift);
            disp(['Using shift of: ' num2str(shift)])
            
            if(strcmp(EIGENPROBLEM,'Problem:D')==1) %we can do better, the next 7 lines... but this works, so... :p
                [ev,em] = SF_Stability(baseflow,'shift',shift,'nev',1,'type','D','STIFFNESS',STIFFNESS,'MASS',str2num(char(m_star))*pi/4,'DAMPING',0,'Frame','R');
            elseif(strcmp(EIGENPROBLEM,'Problem:A')==1)
                [ev,em] = SF_Stability(baseflow,'shift',shift,'nev',1,'type','A','STIFFNESS',STIFFNESS,'MASS',str2num(char(m_star))*pi/4,'DAMPING',0,'Frame','R');
            elseif(strcmp(EIGENPROBLEM,'Problem:S')==1)
                [ev,em] = SF_Stability(baseflow,'shift',shift,'nev',1,'type','S','STIFFNESS',STIFFNESS,'MASS',str2num(char(m_star))*pi/4,'DAMPING',0,'Frame','R');
            end
            
            %Ploting the mode (this function returns the mode, so you can also threat it outside)
            %plotFF(em,'ux1');
    end
end

end
