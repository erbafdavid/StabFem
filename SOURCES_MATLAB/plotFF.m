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


% first check if 'colormap' is a custom one 
%   (a few customs are defined at the bottom of this function)
for i=1:nargin-2
    if(strcmp(lower(varargin{i}),'colormap'))
        switch(lower(varargin{i+1}))
            case('redblue')
                varargin{i+1} = redblue(); % defined at the bottom
            case('french')
                varargin{i+1} = french();
            case('ice')
                varargin{i+1} = ice();
                %otherwise varargin{i+1} should be a standard colormap
        end    
    end   
end

% check if 'symmetry' is part of the parameters and recovers it
symmetry = 'no';
for i=1:nargin-2
      if(strcmp(varargin{i},'symmetry'))
           isymmetry = i;
           symmetry = varargin{i+1};
      end    
end
if (strcmp(symmetry,'no')~=1)
       varargin = { varargin{1:isymmetry-1} ,varargin{isymmetry+2:end}} ;
end


%%% prepares to invoke ffpdeplot...

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
        
        % check if data to plot is the name of a field or a numerical dataset
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
      otherwise
        error(' Error in plotFF with option symmetry ; value must be XS,XA,YS,YA or no')      
  end
  
    hold on;
    ffpdeplot(pointsS, FFdata.mesh.bounds, FFdata.mesh.tri, 'xydata', dataS, varargin{:});
    hold off;
end

end

end

end

% custom colormaps
function cmap = redblue()
cmap = [255,129,129;
255,130,130;
255,132,132;
255,133,133;
255,134,134;
255,136,136;
255,137,137;
255,138,138;
255,140,140;
255,141,141;
255,142,142;
255,143,144;
255,145,145;
255,146,146;
255,147,148;
255,149,149;
255,150,150;
255,151,152;
255,153,153;
255,154,154;
255,155,155;
255,157,157;
255,158,158;
255,159,159;
255,160,161;
255,162,162;
255,163,163;
255,164,165;
255,166,166;
255,167,167;
255,168,169;
255,170,170;
255,171,171;
255,172,173;
255,174,174;
255,175,175;
255,176,177;
255,177,178;
255,179,179;
255,180,181;
255,181,182;
255,183,183;
255,184,185;
255,185,186;
255,187,187;
255,188,189;
255,189,190;
255,191,191;
255,192,192;
255,193,194;
255,195,195;
255,196,196;
255,197,198;
255,198,199;
255,200,200;
255,201,202;
255,202,203;
255,204,204;
255,205,206;
255,206,207;
255,208,208;
255,209,210;
255,210,211;
255,212,212;
255,213,213;
255,213,214;
255,214,215;
255,215,215;
255,215,216;
255,216,217;
255,217,217;
255,217,218;
255,218,219;
255,219,219;
255,219,220;
255,220,221;
255,221,221;
255,221,222;
255,222,223;
255,223,223;
255,224,224;
255,224,225;
255,225,225;
255,226,226;
255,226,227;
255,227,227;
255,228,228;
255,228,228;
255,229,229;
255,230,230;
255,230,230;
255,231,231;
255,232,232;
255,232,232;
255,233,233;
255,234,234;
255,234,234;
255,235,235;
255,236,236;
255,236,236;
255,237,237;
255,238,238;
255,238,238;
255,239,239;
255,240,240;
255,241,240;
255,241,241;
255,242,242;
255,243,242;
255,243,243;
255,244,244;
255,245,244;
255,245,245;
255,246,246;
255,247,246;
255,247,247;
255,248,247;
255,249,248;
255,249,249;
255,250,249;
255,251,250;
255,251,251;
255,252,251;
255,253,252;
255,253,253;
255,254,253;
255,255,254;
255,255,255;
255,255,255;
254,254,254;
252,252,253;
250,250,253;
249,249,252;
247,247,252;
246,246,251;
244,244,250;
243,243,250;
241,241,249;
240,240,249;
238,238,248;
237,237,247;
235,235,247;
234,234,246;
232,232,245;
231,231,245;
229,229,244;
228,228,244;
226,226,243;
225,225,242;
223,223,242;
222,222,241;
220,220,240;
219,219,240;
217,217,239;
216,216,239;
214,214,238;
213,213,237;
211,211,237;
210,210,236;
208,208,236;
207,207,235;
205,205,234;
204,204,234;
202,202,233;
200,200,232;
199,199,232;
197,197,231;
196,196,231;
194,194,230;
193,193,229;
191,191,229;
190,190,228;
188,188,227;
187,187,227;
185,185,226;
184,184,226;
182,182,225;
181,181,224;
179,179,224;
178,178,223;
176,176,223;
175,175,222;
173,173,221;
172,172,221;
170,170,220;
169,169,219;
167,167,219;
166,166,218;
164,164,218;
163,163,217;
161,161,216;
160,160,216;
157,157,215;
155,155,213;
152,152,212;
150,150,211;
147,147,209;
145,145,208;
142,142,207;
140,140,205;
137,137,204;
135,135,202;
132,132,201;
130,130,200;
127,127,198;
125,125,197;
122,122,196;
120,120,194;
117,117,193;
115,115,192;
112,112,190;
110,110,189;
107,107,188;
105,105,186;
102,102,185;
100,100,184;
97,97,182;
95,95,181;
92,92,180;
90,90,178;
87,87,177;
85,85,176;
82,82,174;
80,80,173;
77,77,172;
75,75,170;
72,72,169;
70,70,167;
67,67,166;
65,65,165;
62,62,163;
60,60,162;
57,57,161;
55,55,159;
52,52,158;
50,50,157;
47,47,155;
45,45,154;
42,42,153;
40,40,151;
37,37,150;
35,35,149;
32,32,147;
30,30,146;
27,27,145;
25,25,143;
22,22,142;
20,20,141;
17,17,139;
15,15,138;
12,12,137;
10,10,135;
7,7,134;
5,5,133;
2,2,131;
0,0,130];
cmap = cmap/255;
end

function cmap = french()
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

function cmap = ice()
cmap = [255,255,255;
253,255,255;
251,255,255;
249,255,255;
247,255,255;
245,255,255;
243,255,255;
241,255,255;
239,255,255;
236,255,255;
234,255,255;
232,255,255;
230,255,255;
228,255,255;
226,255,255;
224,255,255;
222,255,255;
220,255,255;
218,255,255;
216,255,255;
214,255,255;
212,255,255;
210,255,255;
208,255,255;
206,255,255;
203,255,255;
201,255,255;
199,255,255;
197,255,255;
195,255,255;
193,255,255;
191,255,255;
189,255,255;
187,255,255;
185,255,255;
183,255,255;
181,255,255;
179,255,255;
177,255,255;
175,255,255;
173,255,255;
171,255,255;
168,255,255;
166,255,255;
164,255,255;
162,255,255;
160,255,255;
158,255,255;
156,255,255;
154,255,255;
152,255,255;
150,255,255;
148,255,255;
146,255,255;
144,255,255;
142,255,255;
140,255,255;
138,255,255;
135,255,255;
133,255,255;
131,255,255;
129,255,255;
127,255,255;
125,255,255;
123,254,255;
121,252,255;
119,250,255;
117,248,255;
115,246,255;
113,244,255;
112,242,255;
110,240,255;
108,238,255;
106,236,255;
104,234,255;
102,232,255;
100,230,255;
98,228,255;
96,226,255;
94,224,255;
92,222,255;
90,219,255;
88,217,255;
86,215,255;
84,213,255;
82,211,255;
80,209,255;
79,207,255;
77,205,255;
75,203,255;
73,201,255;
71,199,255;
69,197,255;
67,195,255;
65,193,255;
63,191,255;
61,189,255;
59,186,255;
57,184,255;
55,182,255;
53,180,255;
51,178,255;
49,176,255;
48,174,255;
46,172,255;
44,170,255;
42,168,255;
40,166,255;
38,164,255;
36,162,255;
34,160,255;
32,158,255;
30,156,255;
28,154,255;
26,151,255;
24,149,255;
22,147,255;
20,145,255;
18,143,255;
16,141,255;
15,139,255;
13,137,255;
11,135,255;
9,133,255;
7,131,255;
5,129,255;
3,127,255;
1,125,255;
0,123,254;
0,121,252;
0,119,250;
0,117,248;
0,115,246;
0,113,244;
0,111,242;
0,109,240;
0,107,237;
0,105,235;
0,103,233;
0,101,231;
0,99,229;
0,97,227;
0,96,225;
0,94,223;
0,92,221;
0,90,219;
0,88,217;
0,86,215;
0,84,213;
0,82,211;
0,80,209;
0,78,207;
0,76,205;
0,74,202;
0,72,200;
0,70,198;
0,68,196;
0,66,194;
0,64,192;
0,63,190;
0,61,188;
0,59,186;
0,57,184;
0,55,182;
0,53,180;
0,51,178;
0,49,176;
0,47,174;
0,45,172;
0,43,169;
0,41,167;
0,39,165;
0,37,163;
0,35,161;
0,33,159;
0,32,157;
0,30,155;
0,28,153;
0,26,151;
0,24,149;
0,22,147;
0,20,145;
0,18,143;
0,16,141;
0,14,139;
0,12,137;
0,10,134;
0,8,132;
0,6,130;
0,4,128;
0,2,126;
0,0,124;
0,0,122;
0,0,120;
0,0,118;
0,0,116;
0,0,114;
0,0,112;
0,0,111;
0,0,109;
0,0,107;
0,0,105;
0,0,103;
0,0,101;
0,0,99;
0,0,97;
0,0,95;
0,0,93;
0,0,91;
0,0,89;
0,0,87;
0,0,85;
0,0,83;
0,0,81;
0,0,80;
0,0,78;
0,0,76;
0,0,74;
0,0,72;
0,0,70;
0,0,68;
0,0,66;
0,0,64;
0,0,62;
0,0,60;
0,0,58;
0,0,56;
0,0,54;
0,0,52;
0,0,50;
0,0,48;
0,0,47;
0,0,45;
0,0,43;
0,0,41;
0,0,39;
0,0,37;
0,0,35;
0,0,33;
0,0,31;
0,0,29;
0,0,27;
0,0,25;
0,0,23;
0,0,21;
0,0,19;
0,0,17;
0,0,16;
0,0,14;
0,0,12;
0,0,10;
0,0,8;
0,0,6;
0,0,4;
0,0,2;
0,0,0];
cmap = cmap/255;
end