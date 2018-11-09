function h = plotFF_ETA(eigenmode,varargin)
%
% This functions adds to the current plot a representation of the
% free-surface displacement ETA.
%
% Usage (just after SF_Plot(em,'ux')
% SF_Plot(em,['E',E,'style',color,'LineWidth',lw,'projection','n'|'r'|'z?,symmmetry,'sym')


p = inputParser;
addParameter(p,'Amp',.15,@isnumeric);
addParameter(p,'style','r',@ischar); % style for plots (e.g. color)
addParameter(p,'LineWidth',2,@isnum); % Linewidth
addParameter(p,'projection','n',@ischar); % projection : 'n' | 'r' | 'z'
addParameter(p,'symmetry','no',@ischar); % symmetry condition. 
                                         % available values are 'no', 
                                         % 'YS' (symmetric with respect to Y axis)
                                         % 'YA' (antisymmetric with respect to Y axis) 
parse(p,varargin{:});
E = p.Results.Amp;

ffmesh = eigenmode.mesh;

switch(p.Results.projection)
    case('n')
    h = plot(ffmesh.xsurf+real(E*eigenmode.eta).*ffmesh.N0r,ffmesh.ysurf+real(E*eigenmode.eta).*ffmesh.N0z,p.Results.style,'LineWidth',p.Results.LineWidth);
    case('r')
    h = plot(ffmesh.xsurf+real(E*eigenmode.eta)./ffmesh.N0r,p.Results.style,'LineWidth',p.Results.LineWidth);
    case('z')
    h = plot(ffmesh.xsurf,ffmesh.ysurf+real(E*eigenmode.eta)./ffmesh.N0z,p.Results.style,'LineWidth',p.Results.LineWidth);
end
        


switch p.Results.symmetry
    case('no')
        mydisp(15,'No symmetry');
    case('YS')
        eigenmodeSYM = eigenmode;
        eigenmodeSYM.mesh.xsurf = - eigenmodeSYM.mesh.xsurf;
        hold on; 
        plotFF_ETA(eigenmodeSYM,varargin{:},'symmetry','no');
        %
        %hold on; 
        %h1 = plot(-ffmesh.xsurf-real(E*eigenmode.eta).*ffmesh.N0r,ffmesh.ysurf+real(E*eigenmode.eta).*ffmesh.N0z,p.Results.style,'LineWidth',p.Results.LineWidth);
        %h = [h; h1];
    case('YA')
        %hold on; 
        %h1 = plot(-ffmesh.xsurf+real(E*eigenmode.eta).*ffmesh.N0r,ffmesh.ysurf-real(E*eigenmode.eta).*ffmesh.N0z,p.Results.style,'LineWidth',p.Results.LineWidth);
        %h = [h; h1];
        eigenmodeSYM = eigenmode;
        eigenmodeSYM.mesh.xsurf = - eigenmodeSYM.mesh.xsurf;
        eigenmodeSYM.eta = - eigenmodeSYM.eta;
        hold on; 
        plotFF_ETA(eigenmodeSYM,varargin{:},'symmetry','no');
end


end