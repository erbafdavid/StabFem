function [Omegatab,Ltab,Mtab] = FreeFem_HarmonicForcing(baseflow);

%% 
%NB THIS IS VERY UGLY PROGRAMMING, TO BE REWRITTEN SOMEDAY
%
%%


global ff ffdir ffdatadir sfdir verbosity


file = ['HARMONIC_2D_LateralOscillations_Re', num2str(baseflow.Re),'.txt']
if(exist(file)==2)
    disp('already computed')
else
    disp('computing')
    system([ ff ' Harmonic_2D_LateralOscillations.edp'])
end


rawData1 = importdata(file)
Omegatab= rawData1(:,1);
Ltab = rawData1(:,3)+1i*rawData1(:,4);
Mtab = rawData1(:,5)+1i*rawData1(:,6);
end


