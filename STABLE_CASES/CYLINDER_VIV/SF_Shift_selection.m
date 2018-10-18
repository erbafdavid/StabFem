function [RealShift, ImagShift,PPrev,PPrevPrev]=SF_Shift_selection(shiftmode,modename,Re,m_star,U_star,PPrev,PPrevPrev,Shift)

%Manually put the right shift, acordding to the above spectrum(
%For the pair (Re;[m_star])(starting at U_star(1)=3 )
%For the STRUCTURE Mode:
%shift=0+2.1i:
%shift=0+2i:	([60-19];[1000-4.73])
%shift=-0.05+1.7i:                (20;[3])
%shift=-0.1+1.5i:        (20;[2])

%For the FLUID Mode :
%shift=0.05+0.75i:	(60;[20,10,5])
%shift=-0.03+0.75i:               (40,[300-5])
%shift=-0.07+0.62i:                                                                 %%%%(21;[10])
%close all

%Initialise:
switch shiftmode
    case ('ContUSTAR')
        RealShift=0; ImagShift=0;
        switch modename{1} %update this to take into account the USTAR!!
            case('02modeSTRUCTURE')
                if (Re>15&&Re<100)
                    disp('Entering hereee')
                    if(m_star>=0.05&&m_star<0.1)
                           RealShift=-0.07; ImagShift=0.85; %u=1

                    elseif(m_star>0.1&&m_star<0.2)
                        RealShift=-0.05; ImagShift=0.68; %u=2
                   
                    elseif(m_star==0.1)% && Re==20 && U_star==6
                        RealShift=-0.057; ImagShift=0.55; %onera 18.10.2018
                        disp('Entering hereee')
                        
                    elseif(m_star>=0.2&&m_star<0.3)
                        RealShift=-0.05; ImagShift=0.81; %u=2

                    elseif(m_star>=0.3&&m_star<0.4)%u=2
                        RealShift=-0.13; ImagShift=0.96;

                    elseif(m_star>=0.4&&m_star<0.6)%u=3
                        RealShift=-0.05; ImagShift=0.81;

                    elseif(m_star>=0.6&&m_star<0.8)%u=3
                        RealShift=-0.10; ImagShift=0.92;

                    elseif(m_star>=0.8&&m_star<1)%u=3
                        RealShift=-0.03; ImagShift=0.78;

                    elseif(m_star>=1&&m_star<2&&Re<35)%u=3
                        RealShift=-0.13; ImagShift=1.1;

                    elseif(m_star>=1&&m_star<2&&Re>35)%u=3
                        RealShift=-0.04; ImagShift=1.15;
                        
                    elseif(m_star==2&&Re==20&&U_star==6.5)%added in onera 18.10.2018
                        RealShift=0; ImagShift=0.68;
                        
                    elseif(m_star>2&&m_star<3)%u=3
                        RealShift=-0.1; ImagShift=1.45;

                    elseif(m_star>=3&&m_star<4.73)%u=3
                        RealShift=-0.05; ImagShift=1.7;

                    elseif(m_star>=4.73&&m_star<20)%u=3
                        RealShift=0; ImagShift=1.9;

                    elseif(m_star>=20&&m_star<300)%u=3
                        RealShift=0; ImagShift=2;

                    elseif(m_star>=300)
                        RealShift=0; ImagShift=2.1;%u=3
                    end
                else
                    disp('Shift not programed');
                    RealShift=300; ImagShift=300; %Just to give an error
                end
            case('03modeFLUID')
                if (Re>60&&Re<=100)
                    RealShift=0.09; ImagShift=0.75;

                elseif (Re>50&&Re<=60)
                    RealShift=0.05; ImagShift=0.75;

                elseif(Re>45&&Re<=50)
                    RealShift=0; ImagShift=0.75;

                elseif(Re>40&&Re<=45)
                    RealShift=-0.03; ImagShift=0.75;

                elseif(Re>35&&Re<=40)
                    RealShift=-0.05; ImagShift=0.72;

                elseif(Re>29.9&&Re<=35)
                    RealShift=-0.06; ImagShift=0.72;

                else
                    disp('Shift not programed');
                    RealShift=300; ImagShift=300;
                end

        end
    case('ContMSTAR')
        if(Re==20 && m_star==4.8 && U_star==6)
            %starting continuation
            RealShift=-0.03; ImagShift=0.85;
            PPrev=RealShift+1i*ImagShift;
            PPrevPrev=PPrev;
        elseif(Re==23 && m_star==4.95 && U_star==5)%re23
            %starting continuation
            RealShift=-0.045; ImagShift=1.02;
            PPrev=RealShift+1i*ImagShift;
            PPrevPrev=PPrev;
        elseif(Re==25 && m_star==4.95 && U_star==5)%re25
            %starting continuation
            RealShift=-0.049; ImagShift=1.01;
            PPrev=RealShift+1i*ImagShift;
            PPrevPrev=PPrev;
        elseif(Re==27 && m_star==4.95 && U_star==4)%re27
            %starting continuation
            RealShift=-0.06; ImagShift=1.3;
            PPrev=RealShift+1i*ImagShift;
            PPrevPrev=PPrev;
        elseif(Re==30 && m_star==0.9 && U_star==3)%re30
            %starting continuation
            RealShift=-0.095; ImagShift=1.11;
            PPrev=RealShift+1i*ImagShift;
            PPrevPrev=PPrev;
        elseif(Re==33 && m_star==4.95 && U_star==3)%re33
            %starting continuation
            RealShift=-0.08; ImagShift=1.75;
            PPrev=RealShift+1i*ImagShift;
            PPrevPrev=PPrev;
        elseif(Re==35 && m_star==4.95 && U_star==3)%re35
            %starting continuation
            RealShift=-0.08; ImagShift=1.8;
            PPrev=RealShift+1i*ImagShift;
            PPrevPrev=PPrev;
        elseif(Re==40 && m_star==0.9 && U_star==3)%re40
            %starting continuation
            RealShift=-0.07; ImagShift=1.2;
            PPrev=RealShift+1i*ImagShift;
            PPrevPrev=PPrev;
        elseif(Re==45 && m_star==4.95 && U_star==3)%re45
            %starting continuation
            RealShift=-0.07; ImagShift=1.75;
            PPrev=RealShift+1i*ImagShift;
            PPrevPrev=PPrev;
        else
            disp('CALCULATING THE PREDICTING SHIFT')
            PPrevPrev=PPrev;
            PPrev=Shift;
            Shift=2*PPrev-PPrevPrev;
            RealShift=real(Shift); ImagShift=imag(Shift);
        end
end     
%CHOOSE shift manually:
%RealShift=0; ImagShift=2; %Normally, for Structure
%RealShift=0.04; ImagShift=0.75; %Normally, for Fluid
end