function [sigma_tab,U_star,Stiffness_table]=SF_Order_Tables(savedata_dir_check,IECT,sigma_tab,U_star,Stiffness_table)


if(exist([savedata_dir_check{1} '.mat'])==2)
    %So, take the the already calculated:
    CHECK=load([savedata_dir_check{1} '.mat']); %load data
    sigma_index=1;
    
    %this resembles a lot to what I did in SF_HarmonicForcing.m ass:Diogo
    for i=IECT
        for j=1:size(CHECK.U_star,2)
            
            if(U_star(i)<CHECK.U_star(j))
                %Inserting Ustar in the right place
                CHECK.U_star= [CHECK.U_star(1,1:j-1)  U_star(i)  CHECK.U_star(1,j:end)];
                %Inserting Stiffness in the right place
                CHECK.Stiffness_table=  [CHECK.Stiffness_table(1,1:j-1)  Stiffness_table(i)  CHECK.Stiffness_table(1,j:end)];
                %Inserting sigma in the right place
                CHECK.sigma_tab=  [CHECK.sigma_tab(1,1:j-1)  sigma_tab(sigma_index)  CHECK.sigma_tab(1,j:end)];
                sigma_index=sigma_index+1; %I this this will work...
                break;%exit the j loop and entering in a new i-element
            end
            if(j==size(CHECK.U_star,2) ) %For add at the end of the list
                %Inserting Ustar in the right place
                CHECK.U_star= [ CHECK.U_star(1,1:j) U_star(i) ];
                %Inserting Stiffness in the right place
                CHECK.Stiffness_table= [ CHECK.Stiffness_table(1,1:j) Stiffness_table(i) ];
                %Inserting sigma in the right place
                CHECK.sigma_tab= [ CHECK.sigma_tab(1,1:j) sigma_tab(sigma_index) ];
                sigma_index=sigma_index+1; %I this this will work...
                break;%exit the j loop and entering in a new i-element
            end
        end
    end
    sigma_tab=CHECK.sigma_tab;
    U_star=CHECK.U_star;
    Stiffness_table=CHECK.Stiffness_table;
    %else: just return the inputs that were given
end


end