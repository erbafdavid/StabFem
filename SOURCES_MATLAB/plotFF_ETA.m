function h = plotFF_ETA(eigenmode,varargin)

p = inputParser;
addParameter(p,'Amp',.15,@isnumeric);
addParameter(p,'style','r',@ischar); % style for plots (e.g. color)
addParameter(p,'LineWidth',2,@isnum); % Linewidth
addParameter(p,'symmetry','no',@ischar); % symmetry condition. 
                                         % available values are 'no', 
                                         % 'YS' (symmetric with respect to Y axis)
                                         % 'YA' (antisymmetric with respect to Y axis) 
parse(p,varargin{:});
E = p.Results.Amp;

ffmesh = eigenmode.mesh;
h = plot(ffmesh.xsurf+real(E*eigenmode.eta).*ffmesh.N0r,ffmesh.ysurf+real(E*eigenmode.eta).*ffmesh.N0z,p.Results.style,'LineWidth',p.Results.LineWidth);

switch p.Results.symmetry
    case('no')
        mydisp(15,'No symmetry');
    case('YS')
        hold on; 
        h1 = plot(-ffmesh.xsurf-real(E*eigenmode.eta).*ffmesh.N0r,ffmesh.ysurf+real(E*eigenmode.eta).*ffmesh.N0z,p.Results.style,'LineWidth',p.Results.LineWidth);
        h = [h; h1];
    case('YA')
        hold on; 
        h1 = plot(-ffmesh.xsurf+real(E*eigenmode.eta).*ffmesh.N0r,ffmesh.ysurf-real(E*eigenmode.eta).*ffmesh.N0z,p.Results.style,'LineWidth',p.Results.LineWidth);
        h = [h; h1];
end


end