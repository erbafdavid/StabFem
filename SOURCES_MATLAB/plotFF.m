function handle = plotFF(FFdata, varargin);
%  function plotFF
%  plots a data field imported from freefem.
%  This function is part of the StabFem project by D. Fabre & coworkers.
%
%  Usage :
%  1/ handle=plotFF(mesh); (if mesh is a mesh object)
%  2/ handle=plotFF(ffdata,'field'); to plot isocontours of a P1 field
%  3/ handle=plotFF(ffdata,'field.re'); to plot isocontours of a P1 complex
%  field (specify '.re' or '.im')
%  4/ handle=plotFF(ffdata,'field',[PARAM,VALUE,..])
%      where [PARAM,VALUE] is any couple of parameters accepted by ffpdeplot.
%       (See Below)
%
%  FFdata is the structure containing the data to plot
%  'field' is the field to plot (the data may comprise multiple fields)
%
%   This version of plotFF is based on ffpdeplot developed by chloros2
%   as an Octave-compatible alternative to pdeplot from toolbox pdetools
%   (https://github.com/samplemaker/freefem_matlab_octave_plot)
%
%   [PARAM,VALUE] are any couple of name/value parameter accepted by
%   ffpdeplot. The list of possibilities currently comprises the following :
%
%   specifies parameter name/value pairs to control the input file format
%
%       Parameter       Value
%      'XYData'      Data in order to colorize the plot
%                       FreeFem++ point data | FreeFem++ triangle data
%      'XYStyle'     Coloring choice
%                       'interp' (default) | 'off'
%      'ZStyle'      Draws 3D surface plot instead of flat 2D Map plot
%                       'continuous' | 'off' (default)
%      'ColorMap'    ColorMap value or matrix of such values
%                       'cool' (default) | colormap name | three-column matrix of RGB triplets
%      'ColorBar'    Indicator in order to include a colorbar
%                       'on' (default) | 'off'
%      'CBTitle'     Colorbar Title
%                       (default=[])
%      'ColorRange'  Range of values to adjust the color thresholds
%                       'minmax' (default) | [min,max]
%      'Mesh'        Switches the mesh off / on
%                       'on' | 'off' (default)
%      'Boundary'    Shows the domain boundary / edges
%                       'on' | 'off' (default)
%      'BDLabels'    Draws boundary / edges with a specific label
%                       [] (default) | [label1,label2,...]
%      'Contour'     Isovalue plot
%                       'off' (default) | 'on'
%      'CXYData'     Use extra (overlay) data to draw the contour plot
%                       FreeFem++ points | FreeFem++ triangle data
%      'CStyle'      Contour plot style
%                       'patch' (default) | 'patchdashed' | 'patchdashedneg' | 'monochrome' | 'colormap'
%      'CColor'      Isovalue color
%                       [0,0,0] (default) | RGB triplet | 'r' | 'g' | 'b' |
%      'CLevels'     Number of isovalues used in the contour plot
%                       (default=10)
%      'CGridParam'  Number of grid points used for the contour plot
%                       'auto' (default) | [N,M]
%      'Title'       Title
%                       (default=[])
%      'XLim'        Range for the x-axis 
%                       'minmax' (default) | [min,max] 
%               NOTE: if not specified but the mesh contains a 'xlim' field, this one is used.
%      'YLim'        Range for the y-axis
%                       'minmax' (default) | [min,max]
%               NOTE: if not specified but the mesh contains a 'ylim' field, this one is used.
%      'ZLim'        Range for the z-axis
%                       'minmax' (default) | [min,max]
%
%      'DAspect'     Data unit length of the xy- and z-axes
%                       'off' | 'xyequal' (default) | [ux,uy,uz]
%      'FlowData'    Data for quiver plot
%                       FreeFem++ point data | FreeFem++ triangle data
%      'FGridParam'  Number of grid points used for quiver plot
%                       'auto' (default) | [N,M]
%       'symmetry'  symmetry property of the flow to plot
%                       'no' (default) | 'YS' (symmetric w.r.t. Y axis) | 'YA' (antisymmetric w.r.t. Y axis) | 'XS' | 'XA'              
%
%     Notes :




global ff ffdir ffdatadir sfdir verbosity

%handle = figure();
%handle = gcf;


% first check if 'colormap' is 'redblue'...
for i=1:nargin-2
    if(strcmp(lower(varargin{i}),'colormap')&&strcmp(lower(varargin{i+1}),'redblue'))
       varargin{i+1} = redblue(); % defined at the bottom
    end    
end


if (mod(nargin, 2) == 1) % plot mesh in single-entry mode : mesh
    mesh = FFdata;
    varargin = {varargin{:}, 'mesh', 'on'};
    if(isfield(mesh,'xlim'))
        varargin = {varargin{:}, 'xlim', mesh.xlim};
    end
    if(isfield(mesh,'ylim'))
        varargin = {varargin{:}, 'ylim', mesh.ylim};
    end
    mydisp(15, ['launching ffpeplot with the following options :']);
    if (verbosity >= 15)
        varargin;
    end;
    ffpdeplot(mesh.points, mesh.bounds, mesh.tri, varargin{:});
else % plot mesh in single-entry mode : data
    mesh = FFdata.mesh;
    field1 = varargin{1};
    varargin = {varargin{2:end}};
     if(isfield(mesh,'xlim'))
        varargin = {varargin{:}, 'xlim', mesh.xlim};
    end
    if(isfield(mesh,'ylim'))
        varargin = {varargin{:}, 'ylim', mesh.ylim};
    end
    if (strcmp(field1, 'mesh')) % plot mesh ins double-entry mde
        varargin = {varargin{:}, 'mesh', 'on'};
        
        mydisp(15, ['launching ffpeplot with the following options :']);
        if (verbosity >= 15)
            varargin
        end;
        
        ffpdeplot(mesh.points, mesh.bounds, mesh.tri, varargin{:});
        %axis equal;
    else
        % plot data
        
        % check if data to plot is a the name of a field or a numerical dataset
        if (~isnumeric(field1))
            [dumb, field, suffix] = fileparts(field1); % to extract the suffix
            if (strcmp(suffix, '.im') == 1)
                data = imag(getfield(FFdata, field));
            else
                data = real(getfield(FFdata, field));
            end
        else
            data = field1;
        end

         mydisp(20, ['launching ffpeplot with the following options :']);
        if (verbosity >= 20)
            varargin
        end;
        
        ffpdeplot(FFdata.mesh.points, FFdata.mesh.bounds, FFdata.mesh.tri, 'xydata', data, varargin{:});

    
%%% SYMMETRIZATION OF THE PLOT

% first chech if 'symmetry' is part of the parameters and recovers it
symmetry = 'no';
for i=1:nargin-2
    if(strcmp(varargin{i},'symmetry'))
        symmetry = varargin{i+1};
    end    
end

if(strcmp(symmetry,'no'))
        mydisp(20,'No symmetry');
else   
     mydisp(20,['Symmetrizing the plot with option ',symmetry]);
  pointsS = FFdata.mesh.points;
  switch(symmetry)
    case('XS')
        pointsS(2,:) = -pointsS(2,:);dataS = data;
    case('XA')
       pointsS(2,:) = -pointsS(2,:);dataS = -data;
    case('YS')
        pointsS(1,:) = -pointsS(1,:);dataS = data;
    case('YA')
        pointsS(1,:) = -pointsS(1,:);dataS = -data;   
    end
  
  hold on;
    ffpdeplot(pointsS, FFdata.mesh.bounds, FFdata.mesh.tri, 'xydata', dataS, varargin{:});
    hold off;
end

end

end

end

% custom colormap
function cmap = redblue()
cmap = [193,0,0;
194,2,2;
195,4,4;
196,6,6;
197,8,8;
198,10,10;
199,12,12;
200,14,14;
201,16,16;
202,18,18;
203,20,20;
204,22,22;
205,24,24;
206,26,26;
207,28,28;
208,30,30;
209,32,32;
210,34,34;
211,36,36;
212,38,38;
213,40,40;
214,42,42;
215,44,44;
216,46,46;
217,48,48;
218,50,50;
219,52,52;
220,54,54;
221,56,56;
222,58,58;
223,60,60;
224,62,62;
225,64,64;
226,66,66;
227,68,68;
228,70,70;
229,72,72;
230,74,74;
230,76,76;
231,78,78;
232,80,80;
233,82,82;
234,85,84;
235,87,86;
236,89,88;
237,91,90;
238,93,92;
239,95,94;
240,97,96;
241,99,98;
242,101,100;
243,103,102;
244,105,104;
245,107,106;
246,109,108;
247,111,110;
248,113,112;
249,115,114;
250,117,116;
251,119,118;
252,121,120;
253,123,122;
254,125,124;
255,127,126;
255,129,128;
255,131,130;
255,133,132;
255,135,134;
255,137,136;
255,139,138;
255,141,140;
255,143,142;
255,145,144;
255,147,146;
255,149,148;
255,151,150;
255,153,152;
255,155,154;
255,157,156;
255,159,158;
255,161,160;
255,163,162;
255,165,164;
255,167,166;
255,169,168;
255,171,170;
255,173,172;
255,175,174;
255,177,176;
255,179,178;
255,181,180;
255,183,182;
255,185,184;
255,187,186;
255,189,188;
255,191,190;
255,193,192;
255,195,194;
255,197,196;
255,199,198;
255,201,200;
255,203,202;
255,205,204;
255,207,206;
255,209,208;
255,211,210;
255,213,212;
255,215,214;
255,217,216;
255,219,218;
255,221,220;
255,223,222;
255,225,224;
255,227,226;
255,229,228;
255,231,230;
255,233,232;
255,235,234;
255,237,236;
255,239,238;
255,241,240;
255,243,242;
255,245,244;
255,247,246;
255,249,248;
255,251,250;
255,253,252;
255,255,254;
255,255,255;
253,253,255;
251,251,255;
249,249,255;
247,247,255;
245,245,255;
243,243,255;
241,241,255;
239,239,255;
237,237,255;
235,235,255;
233,233,255;
231,231,255;
229,229,255;
227,227,255;
225,225,255;
223,223,255;
221,221,255;
219,219,255;
217,217,255;
215,215,255;
213,213,255;
211,211,255;
208,208,255;
206,206,255;
204,204,255;
202,202,255;
200,200,255;
198,198,255;
196,196,255;
194,194,255;
192,192,255;
190,190,255;
188,188,255;
186,186,255;
184,184,255;
182,182,255;
180,180,255;
178,178,255;
176,176,255;
174,174,255;
172,172,255;
170,170,255;
168,168,255;
166,166,255;
164,164,255;
162,162,255;
160,160,255;
158,158,255;
156,156,255;
154,154,255;
152,152,255;
150,150,255;
148,148,255;
146,146,255;
144,144,255;
142,142,255;
140,140,255;
138,138,255;
136,136,255;
134,134,255;
132,132,255;
130,130,255;
128,128,255;
126,126,255;
124,124,254;
122,122,253;
120,120,252;
118,118,251;
116,116,251;
114,114,250;
112,112,249;
110,110,248;
108,108,247;
106,106,246;
104,104,245;
102,102,244;
100,100,243;
98,98,242;
96,96,241;
94,94,241;
92,92,240;
90,90,239;
88,88,238;
86,86,237;
84,84,236;
82,82,235;
80,80,234;
78,78,233;
76,76,232;
74,74,231;
72,72,231;
70,70,230;
68,68,229;
66,66,228;
64,64,227;
62,62,226;
60,60,225;
58,58,224;
56,56,223;
54,54,222;
52,52,221;
50,50,221;
48,48,220;
46,46,219;
44,44,218;
42,42,217;
40,40,216;
38,38,215;
36,36,214;
34,34,213;
32,32,212;
30,30,211;
28,28,211;
26,26,210;
24,24,209;
22,22,208;
20,20,207;
18,18,206;
16,16,205;
14,14,204;
12,12,203;
10,10,202;
8,8,201;
6,6,201;
4,4,200;
2,2,199;
0,0,198];
cmap = cmap/255;
end
