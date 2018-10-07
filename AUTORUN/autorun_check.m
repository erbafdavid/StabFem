% AUTORUN_CHECK SCRIPT FOR STABFEM

run('../SOURCES_MATLAB/SF_Start.m');
test = 0;

AUTORUN_LIST_STABLE =... 
    {'STABLE_CASES/EXAMPLE_Lshape', 'STABLE_CASES/CYLINDER',...
    'STABLE_CASES/ROTATING_POLYGONS','STABLE_CASES/LiquidBridges',...
    'STABLE_CASES/Vessel','STABLE_CASES/BLUNTBODY_IN_PIPE'...
    };

AUTORUN_LIST_DEVEL = {'DEVELOPMENT_CASES/Vessel'};

AUTORUN_LIST_CUSTOM =... 
    {'STABLE_CASES/ROTATING_POLYGONS','STABLE_CASES/LiquidBridges',...
    'STABLE_CASES/Vessel','DEVELOPMENT_CASES/Vessel'...
    };

% il faudrait pr?voir de faire tourner de trois mani?res :
% 1/ cas stables uniquement (sens?s tourner sur toute machine)
% 2/ cas stables + cas devel. (sens?s tourner sur le r?seau IMFT, pas garantis ailleurs)
% 3/ custom (pour faire tourner sur un nombre limit? de cas

AUTORUN_LIST = AUTORUN_LIST_STABLE
%AUTORUN_LIST = { AUTORUN_LIST_STABLE{:} , AUTORUN_LIST_DEVEL{:} }
%AUTORUN_LIST = AUTORUN_LIST_CUSTOM

cd('..')

for i = 1:length(AUTORUN_LIST);

    disp(' ');
    disp([' AUTORUN test number ' num2str(i) ' : ']);
    disp(' ');
    disp(AUTORUN_LIST{i});
    disp(' ');

    cd(AUTORUN_LIST{i});
    a = autorun();
    test = test+a;
    if(a==0) 
        disp([' AUTORUN test number ' num2str(i) ' : RUN SUCCESSFUL !']); 
    else
        disp([' AUTORUN test number ' num2str(i) ' : FAILURE OF ' num2str(a) ' COMPUTATIONS !']);
    end
    cd('../..')
end


% Bilan
if(test~=0)
   disp(['FAILURE OF AUTORUN_check : ' num2str(test) ' test failed. '] );
else
   disp(['AUTORUN_check SUCCEEDED ! '] ); 
end

cd('AUTORUN')


%%
    
%     
% disp('Case Lshape')
% cd('../STABLE_CASES/EXAMPLE_Lshape');
% a = autorun();
% test = test+a;
% if(a==0) 
%     disp('RUN SUCCESSFUL'); 
% else
%     disp(['FAILURE OF ' a ' COMPUTATIONS !']);
% end
% 
% disp('Case CYLINDER');
% cd('../CYLINDER/')
% a = autorun();
% test = test+a;
% if(a==0) 
%     disp('RUN SUCCESSFUL'); 
% else
%     disp(['FAILURE OF ' a ' COMPUTATIONS !']);
% end
% 
% 
% disp('Case ROTATING POLYGONS');
% cd('../ROTATING_POLYGONS/')
% a = autorun();
% test = test+a;
% if(a==0) 
%     disp('RUN SUCCESSFUL');
% else
%     disp(['FAILURE OF ' a ' COMPUTATIONS !']);
% end
% 
% disp('Case LiquidBridges');
% cd('../LiquidBridges/')
% a = autorun();
% test = test+a;
% if(a==0) 
%     disp('RUN SUCCESSFUL'); 
% else
%     disp(['FAILURE OF ' a ' COMPUTATIONS !']);
% end
% 
% 
% 
% 
% disp('Case Vessel (stable)');
% cd('../Vessel/')
% a = autorun();
% test = test+a;
% if(a==0) 
%     disp('RUN SUCCESSFUL'); 
% else
%     disp(['FAILURE OF ' a ' COMPUTATIONS !']);
% end
% 
% 
% 
% disp('Case Vessel (devel)');
% cd('../../DEVELOPMENT_CASES/Vessel/')
% a = autorun();
% test = test+a;
% if(a==0) 
%     disp('RUN SUCCESSFUL'); 
% else
%     disp(['FAILURE OF ' a ' COMPUTATIONS !']);
% end









