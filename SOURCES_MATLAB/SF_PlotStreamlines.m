
function streamlines = SF_PlotStreamlines(FFdata, varargin);
%  function SF_PlotStreamlines
%  computes and plots a data field imported from freefem
%  This function is part of the StabFem project by D. Fabre & coworkers.
%
%  Usage :
%  1/ streamlines=SF_PlotStreamlines(ffdata,'field'); to plot isocontours
%                 of a P1 field
%  To be added the capability to plot also the real or imaginary part
%       (See Below)
%   The list of accepted parameters are described below.
%
%       'StreamlinesInput' A given streamline already computed and ready 
%                           to be plot
%       'StreamlinesX0' array that stores the origin in x of streamlines
%
%       'StreamlinesY0' array that stores the origin in y of streamlines
%
%       'StreamlinesFieldX' string of the field to be taken as reference 
%                           for the x component. 'ux' (default) 
%
%       'StreamlinesFieldY' string of the field to be taken as reference 
%                           for the x component. 'uy' (default) 
%       'color'             the code of the color of streamlines (matlab
%                           convention, 'k'-> Black, 'r' -> Red...)
%       'compute'           'yes' if you want to compute streamlines 'no'
%                           if you do not
%       'plot'              'yes' if you want to plot streamlines 'no' if
%                           you do not

% Determine the type of input file. mesh
if(strcmpi(FFdata.datatype,'Mesh')==1)
       % first argument is a simple mesh
       disp('Your input file cannot be a mesh file. How can I compute',...
             'the streamlines?');
       return
else
       % first argument is a base flow
       ffmesh = FFdata.mesh;
end

% Read input parameters
p = inputParser;
addParameter(p, 'StreamlinesInput',0); % Streamlines input
addParameter(p, 'StreamlinesX0', [0.1]); % Array Position streamlines start X
addParameter(p, 'StreamlinesY0', [0.1]); % Array Position streamlines start Y
addParameter(p, 'StreamlinesFieldX', 'ux'); % Field to represent streamlines in X
addParameter(p, 'StreamlinesFieldY', 'uy'); % Field to represent streamlines in Y
addParameter(p, 'color', 'k'); % Color of the streamlines
addParameter(p, 'compute', "yes"); % Color of the streamlines
addParameter(p, 'plot', "yes"); % Color of the streamlines

parse(p, varargin{:});

% Asign new names to input parameters
x0 = p.Results.StreamlinesX0;
y0 = p.Results.StreamlinesY0;
FieldX = p.Results.StreamlinesFieldX;
FieldY = p.Results.StreamlinesFieldY;
color = p.Results.color;
compute = p.Results.compute;
plot = p.Results.plot;

% 
tri = ffmesh.tri(1:3,:);
X = ffmesh.points(1,:);
Y = ffmesh.points(2,:);
U = FFdata.(FieldX);
V = FFdata.(FieldY);


hold on;

if(compute == "yes")
    streamlines=TriStream(tri,X,Y,U,V,x0,y0);
    if (plot == "yes")
        PlotTriStream(streamlines,color);
    end
else
    if (plot == "yes")
        streamlines = p.Results.StreamlinesInput
        PlotTriStream(streamlines,color);
    end
end



end
