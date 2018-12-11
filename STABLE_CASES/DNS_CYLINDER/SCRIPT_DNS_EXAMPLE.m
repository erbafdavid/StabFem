  
% THIS SCRIPT DEMONSTRATES HOW TO DO DNS with StabFem

%%

run('../../SOURCES_MATLAB/SF_Start.m');verbosity = 0;
figureformat='png'; AspectRatio = 0.56; % for figures


%% Chapter 1 : generation of a mesh and base flow for Re=60
if (~exist('bf','var'))
type = 'D';
ffmesh = SF_Mesh('Mesh_Cylinder_FullDomain.edp');
bf=SF_BaseFlow(ffmesh,'Re',1);
bf=SF_BaseFlow(bf,'Re',10);
bf=SF_BaseFlow(bf,'Re',60);
bf=SF_Adapt(bf,'Hmax',5);
[ev,em] = SF_Stability(bf,'shift',0.04+0.76i,'nev',1,'type',type);
bf=SF_Adapt(bf,em,'Hmax',5);
end

%% Chapter 1bis : generation of a starting point for DNS using stability results
%
[ev,em] = SF_Stability(bf,'shift',0.04+0.76i,'sym','N'); % compute the eigenmode
startfield = SF_Add(bf,em,'Amp2',0.01); % creates startfield = bf+0.01*em


%% Chapter 2 : Launch a DNS

%  We do 30 000 time steps and produce output each 100 timestep 

Nit = 30000; iout = 100;dt = 0.01;
%[DNSstats,DNSfields] =SF_DNS(startfield,'Re',60,'Nit',Nit,'dt',dt,'iout',iout)

Nit = 8900;
[DNSstats,DNSfields] =SF_DNS(startfield,'Re',60,'Nit',Nit,'dt',dt,'iout',iout,'mode','postprocessonly')
% this one is for postprocessing only, without launching everything again

% plot 

h = figure;
filename = 'html/DNS_Cylinder_Re60.gif';
SF_Plot(DNSfields(i),'vort','xlim',[-2 10],'ylim',[-3 3 ],'title',['t = ',num2str(i-1)*dt],'boundary','on')
set(gca,'nextplot','replacechildren');

%% Generate a movie

for i=1:Nit/iout
    SF_Plot(DNSfields(i),'p','xlim',[-2 10],'ylim',[-3 3 ],'title',['t = ',num2str(i)],'boundary','on');
    pause(0.1);
    frame = getframe(h); 
    im = frame2im(frame); 
    [imind,cm] = rgb2ind(im,256); 
    if i == 1 
        imwrite(imind,cm,filename,'gif', 'Loopcount',inf,'DelayTime',0.05); 
    else 
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.05); 
    end 
end

%%
% Here is the movie
%
% <<DNS_Cylinder_Re60.gif>>
%

%% Plot the lift force as function of time

figure(15);
subplot(2,1,1);
plot(DNSstats.tps,DNSstats.Lift);
xlabel('t');ylabel('Fy');
subplot(2,1,2);
plot(DNSstats.tps,DNSstats.Drag);
xlabel('t');ylabel('Fx');


%% Chapter 3 : how to do a DNS starting from a previous snapshot
%  We do another 1000 time steps starting from previous point 

%DNSfield = DNSfields(end);
%[DNSstats2,DNSfields] = SF_DNS(DNSfield,'Re',60,'Nit',20,'dt',0.005,'iout',100)

