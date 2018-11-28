bf = SF_Init('Mesh_Cylinder_Large.edp');
bf = SF_BaseFlow(bf,'Re',1);
bf = SF_BaseFlow(bf,'Re',10);
bf = SF_BaseFlow(bf,'Re',60);
bf = SF_Adapt(bf,'Hmax',10,'InterpError',0.01);
[ev,em] = SF_Stability(bf,'shift',0.04+0.74i,'type','S')
bf = SF_Adapt(bf,em,'Hmax',10,'InterpError',0.01);
SF_Plot(bf,'p','contour','psi','clevels',[-.02 0 .2 1 2 5],'cstyle','patchdashedneg',...
      'xlim',[-1.5 4.5],'ylim',[0 3],'cbtitle','p','colormap','redblue','colorrange','centered',...
      'boundary','on','bdlabels',2,'bdcolors','k'); % figure 2

Re_Range = [2 : 2: 50]; Drag_tab = []; Lx_tab = [];
    for Re = Re_Range
        bf = SF_BaseFlow(bf,'Re',Re);
        Drag_tab = [Drag_tab,bf.Drag];
        Lx_tab = [Lx_tab,bf.Lx];
    end
plot(Re_Range,Drag_tab,'b+-'); %Figure 3a 
plot(Re_Range,Lx_tab,'b+-'); % Figure 3b

Re_Range = [40 : 2: 100];lambda_branch=[];
bf=SF_BaseFlow(bf,'Re',40);
[ev,em] = SF_Stability(bf,'shift',-.03+.72i,'nev',1,'type','D');
    for Re = Re_Range
        bf = SF_BaseFlow(bf,'Re',Re);
        [ev,em] = SF_Stability(bf,'nev',1,'shift','cont');
        lambda_branch = [lambda_branch ev];
    end
plot(Re_Range,real(lambda_branch),'b+-'); %Figure 4a
plot(Re_Range,imag(lambda_branch)/(2*pi),'b+-'); % Figure 4b