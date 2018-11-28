function handle = SF_Plot(FFdata, varargin);
%%% Streamlines
p = inputParser;
addParameter(p, 'Streamlines', 'no'); % yes/no
addParameter(p, 'StreamlinesX0', [0]); % Array Position streamlines start X
addParameter(p, 'StreamlinesY0', [0]); % Array Position streamlines start Y
addParameter(p, 'StreamlinesFieldX', 'ux'); % Field to represent streamlines in X
addParameter(p, 'StreamlinesFieldY', 'uy'); % Field to represent streamlines in Y

parse(p, varargin{:});

x0 = p.Results.StreamlinesX0;
y0 = p.Results.StreamlinesY0;
FieldX = p.Results.StreamlinesFieldX;
FieldY = p.Results.StreamlinesFieldY;

tri = mesh.tri(1:3,:);
X = mesh.points(1,:);
Y = mesh.points(2,:);
U = FFdata.(FieldX);
V = FFdata.(FieldY);
if(p.Results.Streamlines == 'yes')
    FlowU=TriStream(tri,X,Y,U,V,x0,y0);
    hold on;
    PlotTriStream(FlowU,'k');
end
hold off;

% End streamlines
