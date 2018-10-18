function [baseflow,sigma_tab,index_effect_calculated_tab] = SF_FreeMovement_Spectrum(stability_analysis,savedata_dir_check,baseflow,sigma_tab,RealShift,ImagShift,STIFFNESS_to_search,mass,DAMP,nev)
%%
switch stability_analysis
    case 'search' %For search "randomly" in the spectrum (normally nev>1)
        %RealShift=0.03;
        %ImagShift=0.76;
        %STIFFNESS_to_search=Stiffness_table;
        %sigma_tab=[];
        for STIFFNESS=STIFFNESS_to_search
            for ii=RealShift
                for jj=ImagShift
                    [ev,em] = SF_Stability(baseflow,'shift',ii+jj*1i,'nev',nev,'type','D','STIFFNESS',STIFFNESS,'MASS',mass,'DAMPING',DAMP,'Frame','R','PlotSpectrum','yes');
                    sigma_tab = [sigma_tab ev];
                    %mode_tab=[mode_tab em];It's too heavy in terms of memory
                    set(gcf, 'Position', get(0, 'Screensize'));
                end
            end
        end
        
    case 'modefollow' %For following a mode in the spectrum (normally nev=1)
        index_effect_calculated_tab=[];
        %RealShift=0.03;
        %ImagShift=0.76;
        %STIFFNESS_to_search=Stiffness_table;
        %sigma_tab=[];
        shift=RealShift+ImagShift*1i;%compose the shift
        if(exist([savedata_dir_check{1} '.mat'])==2)
            disp('File already exists, so lets see what has been already calculated....');
            sigmaPrev=shift;%initialise
            sigmaPrevPrev=shift;%initialise
            CHECK=load([savedata_dir_check{1} '.mat']); %load data to then see if it is already calculated
            for S=STIFFNESS_to_search
                [Logical_res,index_needed]=ismembertol(S,CHECK.Stiffness_table); %logical value + index
                if(Logical_res==1) %it means that it exists, so we wont calculate it again
                    %if(index_needed>1)%To be more precise... because
                    %    sigmaPrevPrev=CHECK.sigma_tab(index_needed-1);
                    %else
                    %sigmaPrevPrev=sigmaPrev;
                    sigmaPrevPrev=CHECK.sigma_tab(index_needed);
                    %end
                    sigmaPrev=CHECK.sigma_tab(index_needed);
                    disp(['Value of U_star=' num2str(CHECK.U_star(index_needed)) ' already calculated! Passing to the next one :)'])
                else
                    shift=2*sigmaPrev-sigmaPrevPrev;
                    [ev,em] = SF_Stability(baseflow,'shift',shift,'nev',nev,'type','D','STIFFNESS',S,'MASS',mass,'DAMPING',DAMP,'Frame','R','PlotSpectrum','yes');
                    set(gcf, 'Position', get(0, 'Screensize'));%img in fullscream during compute
                    sigmaPrevPrev=sigmaPrev;
                    sigmaPrev=ev;
                    %insert by order
                    %just to know the index
                    [tototo99,index_effect_calculated]=ismembertol(S,STIFFNESS_to_search); %take only the indexes that have been calculated, to threat outside...
                    sigma_tab = [sigma_tab ev];
                    index_effect_calculated_tab=[index_effect_calculated_tab index_effect_calculated];
                end
            end
        else %do the normal continuation if nothing was done yet...
            if(size(STIFFNESS_to_search,2)~=1)%if its a lot of values
            [ev,em] = SF_Stability(baseflow,'shift',shift,'nev',nev,'type','D','STIFFNESS',STIFFNESS_to_search(1),'MASS',mass,'DAMPING',DAMP,'Frame','R','PlotSpectrum','yes');
            set(gcf, 'Position', get(0, 'Screensize'));%img in fullscream during compute
            
            for index_S=1:size(STIFFNESS_to_search,2)
                [ev,em] = SF_Stability(baseflow,'shift','cont','nev',nev,'type','D','STIFFNESS',STIFFNESS_to_search(index_S),'MASS',mass,'DAMPING',DAMP,'Frame','R','PlotSpectrum','yes');
                sigma_tab = [sigma_tab ev];
            end
            else%if continuation procedure is done outside
                [ev,em] = SF_Stability(baseflow,'shift',shift,'nev',nev,'type','D','STIFFNESS',STIFFNESS_to_search(1),'MASS',mass,'DAMPING',DAMP,'Frame','R','PlotSpectrum','yes');
                set(gcf, 'Position', get(0, 'Screensize'));%img in fullscream during compute 
                sigma_tab = [sigma_tab ev];
            end
        end
        %This is what I did before improving(I mean, the normal continuation stuff of David):
        %shift=RealShift+ImagShift*1i;
        %Adapt to the first value
        %%%%%%%%%%%plotFF(baseflow,'mesh');
        %%%%%%%%%%%[evadapt,emadapt] = SF_Stability(baseflow,'shift',shift,'nev',nev,'type','S','STIFFNESS',STIFFNESS_to_search(1),'MASS',mass,'DAMPING',0,'Frame','R');
        %%%%%%%%%%%[baseflow,em]=SF_Adapt(baseflow,emadapt,'Hmax',1,'InterpError',0.02);
        %%%%%%%%%%%plotFF(baseflow,'mesh');
        %[ev,em] = SF_Stability(baseflow,'shift',shift,'nev',nev,'type','D','STIFFNESS',STIFFNESS_to_search(1),'MASS',mass,'DAMPING',0,'Frame','R','PlotSpectrum','yes');
        %set(gcf, 'Position', get(0, 'Screensize'));%img in fullscream during compute
        %for STIFFNESS=STIFFNESS_to_search
        %for index_S=1:size(STIFFNESS_to_search,2)
        %    [ev,em] = SF_Stability(baseflow,'shift','cont','nev',nev,'type','D','STIFFNESS',STIFFNESS_to_search(index_S),'MASS',mass,'DAMPING',0,'Frame','R','PlotSpectrum','yes');
            %%%%%%%%%%%if(mod(index_S,10)==0)
            %%%%%%%%%%%    [evadapt,emadapt] = SF_Stability(baseflow,'shift',ev,'nev',nev,'type','S','STIFFNESS',STIFFNESS_to_search(index_S),'MASS',mass,'DAMPING',0,'Frame','R');
            %%%%%%%%%%%    [baseflow,emADAPTED]=SF_Adapt(baseflow,emadapt,'Hmax',1,'InterpError',0.02);
            %%%%%%%%%%%    plotFF(baseflow,'mesh');
            %%%%%%%%%%%end
        %    sigma_tab = [sigma_tab ev];
            %mode_tab=[mode_tab em];It's too heavy in terms of memory
        %end
end
disp('Exiting function SF_FreeMovement_Spectrum.m')
end
