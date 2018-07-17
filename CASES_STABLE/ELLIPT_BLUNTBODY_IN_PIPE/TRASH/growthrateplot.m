
figure(11);
    subplot(2,1,1);hold on;
    plot(Re_RangeS,real(EVS),'-*b',Re_RangeS,imag(EVS),'-sb')
    title('Steady mode')
    legend('Growth rate Re (\sigma)','Oscillation rate Im (\sigma)')
    subplot(2,1,2);hold on;
    plot(Re_RangeI,real(EVI),'-*r',Re_RangeI,imag(EVI),'-sr')
    title('Unsteady mode')
    legend('Growth rate Re (\sigma)','Oscillation rate Im (\sigma)')
