function [baseflow]=SF_HarmonicForcing(baseflow,Re,Omega_values,formulation)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%	File: SF_HarmonicForcing.m
%%%
%%% INPUTS: baseflow, Omega_values(To select which ones to calculate),etc..
%%%
%%% OUTPUTS: new baseflow based on the Re given in the INPUTS
%%%
%%% FILES CHANGED/CREATED: The file that ends by TOTAL.ff2m
%%% Contributours: Diogo Sabino
%%% Last Modification: Diogo Sabino, 23 July 2018
%%%
%%% NB's:Go to line 96 if something changed in .edp file regarding the 
%%% writing of the ff2m file.
%%% ...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global ff ffdataharmonicdir

filename=[formulation 'Forced_Harmonic2D_Re' num2str(Re)];

%% Set omega values not calculated yet
Omega_to_compute=[];

all_data_stored_file=[ffdataharmonicdir{1} filename 'TOTAL.ff2m'];
if exist(all_data_stored_file)~=0
    %import all data already calculted, if exists any
    all_data_stored=importFFdata(all_data_stored_file);
    %discover the values of Omega that have not been calculated
    for i=1:size(Omega_values,2)
        if(ismembertol(Omega_values(i),all_data_stored.OMEGAtab,2*10^-5)==0) %TOLERANCE DUE TO FF2M WRITING IN FREEFEM++
            Omega_to_compute=[Omega_to_compute Omega_values(i)];
        end
    end
    
else
    Omega_to_compute=Omega_values;
end

% Number of omega values to be calculated
Nomega=size(Omega_to_compute,2);

%% .edp command execution
if isempty(Omega_to_compute)==1
    disp('All demanded omegas were already calculated');
    % And the .edp won't be called
else
    % The .edp will be called
    baseflow=SF_BaseFlow(baseflow,'Re',Re);
    % Create the command string:
    stringparam = [ffdataharmonicdir{1} filename ' ' formulation ' ' num2str(Nomega) ' '];
    for omega = Omega_to_compute
        stringparam = [stringparam num2str(omega) '  ' ];
    end
    disp(['The following Omega values will be calculated: ' stringparam]);
    
    command = ['echo  ' stringparam ' | ' ff ' FF_Forced_Harmonic_2D_Lateral_Oscillations.edp'];
    disp(command);
    error='Error in FF_Forced_Harmonic_2D_Lateral_Oscillations.edp when executing ... Be bold to solve it! ;)';
    
    mysystem(command,error); %Execute .edp file with FreeFEM++ for specific Re
    
    %Add new omegas calculated
    
    new_data_stored_file=[ffdataharmonicdir{1} filename '.ff2m'];
    new_data_stored=importFFdata(new_data_stored_file);
    disp(new_data_stored.OMEGAtab)
    if exist(all_data_stored_file)~=0
        for i=1:size(new_data_stored.OMEGAtab,1)
            for j=1:size(all_data_stored.OMEGAtab,1)%PUT THE CHANGES HERE, IF SOMETHING CHANGES IN THE EDP FILE
                
                if(new_data_stored.OMEGAtab(i)<all_data_stored.OMEGAtab(j))
                    %Inserting OMEGA in the right place
                    all_data_stored.OMEGAtab= [all_data_stored.OMEGAtab(1:j-1,1);...
                        new_data_stored.OMEGAtab(i,1); all_data_stored.OMEGAtab(j:end,1)];
                    %Inserting LIFT in the right place
                    all_data_stored.Lift= [all_data_stored.Lift(1:j-1,1);...
                        new_data_stored.Lift(i); all_data_stored.Lift(j:end,1)];
                    %Inserting Drag in the right place
                    all_data_stored.Drag= [all_data_stored.Drag(1:j-1,1);...
                        new_data_stored.Drag(i); all_data_stored.Drag(j:end,1)];
                    %Inserting MOMENTUM in the right place
                    all_data_stored.Momentum= [all_data_stored.Momentum(1:j-1,1);...
                        new_data_stored.Momentum(i); all_data_stored.Momentum(j:end,1)];
                    break;%exit the j loop and entering in a new i-element
                end
                if(j==size(all_data_stored.OMEGAtab,1) ) %For add at the end of the list %PUT THE CHANGES HERE, IF SOMETHING CHANGES IN THE EDP FILE
                    %Inserting OMEGA in the right place
                    all_data_stored.OMEGAtab= [all_data_stored.OMEGAtab(1:j,1);...
                        new_data_stored.OMEGAtab(i,1)];
                    %Inserting LIFT in the right place
                    all_data_stored.Lift= [all_data_stored.Lift(1:j,1);...
                        new_data_stored.Lift(i)];
                    %Inserting Drag in the right place
                    all_data_stored.Drag= [all_data_stored.Drag(1:j,1);...
                        new_data_stored.Drag(i)];
                    %Inserting MOMENTUM in the right place
                    all_data_stored.Momentum= [all_data_stored.Momentum(1:j,1);...
                        new_data_stored.Momentum(i)];
                    break;%exit the j loop and entering in a new i-element
                end
                
                
                
            end
        end
        
        %PUT THE CHANGES HERE, IF SOMETHING CHANGES IN THE EDP FILE
        %Write back in the file ff2m with all the values
        dlmwrite(all_data_stored_file,'###Data Generated by FF++ ;','delimiter', '')
        dlmwrite(all_data_stored_file,'FileTOTOdiogo123456789','delimiter', '', '-append')
        dlmwrite(all_data_stored_file,'Format : ','delimiter', '', '-append')
        Nomega=size(all_data_stored.OMEGAtab,1);
        formatff2m=['real.' num2str(Nomega) ' OMEGAtab complex.' num2str(Nomega) ' Lift complex.' num2str(Nomega) ' Drag complex.' num2str(Nomega) ' Momentum real Drag0P real Drag0V real Drag0T'];
        dlmwrite(all_data_stored_file,formatff2m,'delimiter', '', '-append');
        dlmwrite(all_data_stored_file,' ','delimiter', '', '-append'); %See if works
        for i=1:size(all_data_stored.OMEGAtab,1)
            dlmwrite(all_data_stored_file,num2str(all_data_stored.OMEGAtab(i)),'delimiter', '', '-append');
        end
        for i=1:size(all_data_stored.Lift,1)
            formatff2m=[num2str(real(all_data_stored.Lift(i))) ' ' num2str(imag(all_data_stored.Lift(i)))];
            dlmwrite(all_data_stored_file,formatff2m,'delimiter', '', '-append');
        end
        for i=1:size(all_data_stored.Drag,1)
            formatff2m=[num2str(real(all_data_stored.Drag(i))) ' ' num2str(imag(all_data_stored.Drag(i)))];
            dlmwrite(all_data_stored_file,formatff2m,'delimiter', '', '-append');
        end
        for i=1:size(all_data_stored.Momentum,1)
            formatff2m=[num2str(real(all_data_stored.Momentum(i))) ' ' num2str(imag(all_data_stored.Momentum(i)))];
            dlmwrite(all_data_stored_file,formatff2m,'delimiter', '', '-append');
        end
        formatff2m=[num2str(real(all_data_stored.Drag0P))];
        dlmwrite(all_data_stored_file,formatff2m,'delimiter', '', '-append');
        formatff2m=[num2str(real(all_data_stored.Drag0V))];
        dlmwrite(all_data_stored_file,formatff2m,'delimiter', '', '-append');
        formatff2m=[num2str(real(all_data_stored.Drag0T))];
        dlmwrite(all_data_stored_file,formatff2m,'delimiter', '', '-append');
        
    else
        % all_data_stored_file does not exist yet, so lest create it
        system(['cp ' new_data_stored_file ' ' all_data_stored_file ]);
        %Since it does not exist, the matlab structure needed for calculate
        %the dirivative does not exist neither;
        all_data_stored=importFFdata(all_data_stored_file);
    end
    
    %Calculating derivatives and saving it in a new file .mat
    disp('DIOGO TOTO');
    disp(all_data_stored.OMEGAtab);
    dOMEGA=diff(all_data_stored.OMEGAtab);
    dZr=diff(2*real(all_data_stored.Lift));
    dZi=diff(2*imag(all_data_stored.Lift)); 
    save([ffdataharmonicdir{1} filename '_diff_DATA.mat'],'dZr','dZi','dOMEGA');
end

end  %End file

