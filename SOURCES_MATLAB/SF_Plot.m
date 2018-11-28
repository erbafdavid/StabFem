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
%   ffpdeplot. 
%   The list of accepted parameters are the same as accepted by ffpdeplot,
%   plus two specific ones : 'symmmetry' and 'logsat'.
%   NB : parameter 'colomap' accepts  a few custom ones including 'redblue' and 'ice'. 
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
%                       NB : In addition to default ones ('cool', jet', etc...) 
%                            we provide a few custom ones ('redblue', 'ice', etc...)
%      'ColorBar'    Indicator in order to include a colorbar
%                       'on' (default) | 'off' | 'northoutside' ...
%      'CBTitle'     Colorbar Title
%                       (default=[])
%      'ColorRange'  Range of values to adjust the color thresholds
%                       'minmax' (default) | 'centered' | 'cropminmax' | 'cropcentered' | [min,max]
%      'Mesh'        Switches the mesh off / on
%                       'on' | 'off' (default)
%      'Boundary'    Shows the domain boundary / edges
%                       'on' | 'off' (default)
%      'BDLabels'    Draws boundary / edges with a specific label
%                       [] (default) | [label1,label2,...]
%      'BDColors'    Colorize boundary / edges with color (linked to 'BDLabels')
%                       'r' (default) | ['r','g', ... ]
%      'BDShowText'  Shows the labelnumber on the boundary / edges
%                       'on' | 'off' (default)
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
%      'YLim'        Range for the y-axis
%                       'minmax' (default) | [min,max]
%      'ZLim'        Range for the z-axis
%                       'minmax' (default) | [min,max]
%      'DAspect'     Data unit length of the xy- and z-axes
%                       'off' | 'xyequal' (default) | [ux,uy,uz]
%      'FlowData'    Data for quiver plot
%                       FreeFem++ point data | FreeFem++ triangle data
%      'FGridParam'  Number of grid points used for quiver plot
%                       'auto' (default) | [N,M]
%
%       'symmetry'  symmetry property of the flow to plot
%                       'no' (default) | 'YS' (symmetric w.r.t. Y axis) | 'YA' (antisymmetric w.r.t. Y axis) | 'XS' | 'XA' 
%                                      | 'XM' (mirror image w/r to X axis) | 'YM'  
%       'logsat'    use nonlinearly scaled colorange using filter function f_S
%                   colorange is linear when |value|<S and turns into logarithmic when |value|>S  
%                   (use this option to plot fields with strong spatial amplifications)
%                   NB : is S = 0 the colorrange is purely logarithmic
%                   -1 (default, disabled) | S
% 
%       'Streamlines' Set streamlines of a given vector field (Not
%                      optimised/ it takes more time than a normal plot)
%                     'no' (default) | 'yes'
%       'StreamlinesX0' array that stores the origin in x of streamlines
%
%       'StreamlinesY0' array that stores the origin in y of streamlines
%
%       'StreamlinesFieldX' string of the field to be taken as reference 
%                           for the x component. 'ux' (default) 
%
%       'StreamlinesFieldY' string of the field to be taken as reference 
%                           for the x component. 'uy' (default) 
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
            case('fire')
                varargin{i+1} = fire();
            case('seashore')
                varargin{i+1} = seashore();
            case('dawn')
                varargin{i+1} = dawn();
                %otherwise varargin{i+1} should be a standard colormap
        end    
    end   
end

% check if 'contour' is part of the parameters and recovers its value
contourval='off';
for i=1:nargin-2
      if(strcmp(varargin{i},'contour'))
           icontour = i;
           contourval = varargin{i+1};
      end    
end

% check if 'symmetry' is part of the parameters and recovers it
symmetry = 'no';
for i=1:length(varargin)
      if(strcmp(varargin{i},'symmetry'))
           isymmetry = i;
           symmetry = varargin{i+1};
      end    
end
if (strcmp(symmetry,'no')~=1)
       varargin = { varargin{1:isymmetry-1} ,varargin{isymmetry+2:end}} ;
end

% check if 'logsat' is part of the parameters and recovers it
logscaleS = -1;
for i=1:length(varargin)
      if(strcmp(varargin{i},'logsat'))
           ilogscale = i;
           logscaleS = varargin{i+1};
           mydisp(2,['using colorrange with logarithmic saturation ; S = ',num2str(logscaleS)]);
      end    
end
if (logscaleS~=-1)
       varargin = { varargin{1:ilogscale-1} ,varargin{ilogscale+2:end}} ;
end




%%% prepares to invoke ffpdeplot...
if (mod(nargin, 2) == 1) % plot mesh in single-entry mode : mesh
    mesh = FFdata;
    varargin = {varargin{:}, 'mesh', 'on'};
    if(isfield(mesh,'xlim'))
        varargin = { varargin{:}, 'xlim', mesh.xlim};
    end
    if(isfield(mesh,'ylim'))
        varargin = { varargin{:}, 'ylim', mesh.ylim};
    end
    mydisp(15, ['launching ffpeplot with the following options :']);
    if (verbosity >= 15)
        varargin;
    end;
    if(strcmpi(symmetry,'xm'))
        mesh.points(2,:) = -mesh.points(2,:);
        symmetry = 'no';
 elseif(strcmpi(symmetry,'ym'))
        mesh.points(1,:) = -mesh.points(1,:); 
        symmetry ='no';
  end
    handle = ffpdeplot(mesh.points, mesh.bounds, mesh.tri, varargin{:});
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
         if(strcmpi(symmetry,'xm'))
        mesh.points(2,:) = -mesh.points(2,:);
        symmetry = 'no';
 elseif(strcmpi(symmetry,'ym'))
        mesh.points(1,:) = -mesh.points(1,:); 
        symmetry ='no';
  end  
        handle = ffpdeplot(mesh.points, mesh.bounds, mesh.tri, varargin{:});
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
        if (logscaleS~=-1)
            varargin = {varargin{:}, 'ColorRangeTicks', logscaleS};
            data = logfilter(data,logscaleS);
        end
        
        if (strcmpi(contourval,'off')~=1&&strcmpi(contourval,'on')~=1)
        varargin{icontour} = 'on';
        [~, field, suffix] = fileparts(contourval); % to extract the suffix
            if (strcmp(suffix, '.im') == 1)
                xydata = imag(getfield(FFdata, field));
            else
                xydata = real(getfield(FFdata, field));
            end
        varargin = { varargin{:} , 'cxydata',xydata } ;
        end

        mydisp(20, ['launching ffpeplot with the following options :']);
        if (verbosity >= 20)
            varargin
        end;
          
 pointsS = FFdata.mesh.points;
 if(strcmpi(symmetry,'xm'))
        pointsS(2,:) = -pointsS(2,:);
        symmetry = 'no';
 elseif(strcmpi(symmetry,'ym'))
        pointsS(1,:) = -pointsS(1,:); 
        symmetry ='no';
 end
  

  handle = ffpdeplot(pointsS, FFdata.mesh.bounds, FFdata.mesh.tri, 'xydata', data, varargin{:});


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
    case({'XM','YM'})
          % do nothing as these case has already been treated
      otherwise
        error(' Error in plotFF with option symmetry ; value must be XS,XA,YS,YA,XM,YM or no')      
  end
  
    hold on;
    handle = ffpdeplot(pointsS, FFdata.mesh.bounds, FFdata.mesh.tri, 'xydata', dataS, varargin{:});
end

end

end

end

% custom colormaps
function cmap = redblue()
%colmapdef=[193,0,0; 235,164,164; 235,235,235; 196,196,255; 127,127,255]/255;
colmapdef=[127,127,255; 196,196,255; 235,235,235; 235,164,164; 193,0,0  ]/255;
[sz1,~]=size(colmapdef);
cmap=interp1(linspace(0,1,sz1),colmapdef,linspace(0,1,255));
end

function cmap = french()
colmapdef=[255,0,0; 255,255,255; 0,0,255]/255;
[sz1,~]=size(colmapdef);
cmap=interp1(linspace(0,1,sz1),colmapdef,linspace(0,1,255));
end

function cmap = ice()
%definition of the colormap "ice"
colmapdef=[255,255,255; 125,255,255; 0,123,255; 0,0,124; 0,0,0]/255;
[sz1,~]=size(colmapdef);
cmap=interp1(linspace(0,1,sz1),colmapdef,linspace(0,1,255));
end

function cmap = fire()
% definition of colormap "fire"
colmapdef=[255 255 255
255 255 253
255 255 251
255 255 249
255 255 247
255 255 245
255 255 243
255 255 241
255 255 239
255 255 237
255 255 235
255 255 233
255 255 231
255 255 229
255 255 226
255 255 224
255 255 222
255 255 220
255 255 218
255 255 216
255 255 214
255 255 212
255 255 210
255 255 208
255 255 206
255 255 204
255 255 202
255 255 200
255 255 198
255 255 196
255 255 194
255 255 192
255 255 190
255 255 188
255 255 186
255 255 184
255 255 182
255 255 180
255 255 178
255 255 176
255 255 174
255 255 172
255 255 169
255 255 167
255 255 165
255 255 163
255 255 161
255 255 159
255 255 157
255 255 155
255 255 153
255 255 151
255 255 149
255 255 147
255 255 145
255 255 143
255 255 141
255 255 139
255 255 137
255 255 135
255 255 133
255 255 131
255 255 129
255 255 127
255 255 125
255 253 124
255 252 123
255 251 122
255 250 121
255 248 120
255 247 119
255 246 118
255 245 117
255 243 116
255 242 115
255 241 114
255 240 113
255 238 112
255 237 112
255 236 111
255 235 110
255 233 109
255 232 108
255 231 107
255 229 106
255 228 105
255 227 104
255 226 103
255 224 102
255 223 101
255 222 100
255 221 99
255 219 98
255 218 97
255 217 96
255 216 95
255 214 94
255 213 93
255 212 92
255 211 91
255 209 90
255 208 90
255 207 89
255 206 88
255 204 87
255 203 86
255 202 85
255 200 84
255 199 83
255 198 82
255 197 81
255 195 80
255 194 79
255 193 78
255 192 77
255 190 76
255 189 75
255 188 74
255 187 73
255 185 72
255 184 71
255 183 70
255 182 69
255 180 68
255 179 67
255 178 67
255 177 66
255 175 65
255 174 64
255 173 63
255 172 62
255 171 62
255 170 61
255 169 60
255 168 59
255 167 58
255 166 58
255 165 57
255 164 56
255 163 55
255 162 55
255 161 54
255 160 53
255 159 52
255 158 52
255 157 51
255 156 50
255 155 49
255 154 49
255 152 48
255 151 47
255 150 46
255 149 46
255 148 45
255 147 44
255 146 43
255 145 43
255 144 42
255 143 41
255 142 40
255 141 40
255 140 39
255 139 38
255 138 37
255 137 37
255 136 36
255 135 35
255 134 34
255 133 34
255 132 33
255 131 32
255 130 31
255 129 31
255 128 30
255 127 29
255 126 28
255 125 28
255 124 27
255 123 26
255 122 25
255 121 25
255 120 24
255 118 23
255 117 22
255 116 22
255 115 21
255 114 20
255 113 19
255 112 19
255 111 18
255 110 17
255 109 16
255 108 16
255 108 16
255 107 16
255 106 15
255 105 15
255 104 15
255 103 15
255 103 14
255 102 14
255 101 14
255 100 13
255 99 13
255 99 13
255 98 13
255 97 12
255 96 12
255 95 12
255 95 12
255 94 11
255 93 11
255 92 11
255 91 11
255 90 10
255 90 10
255 89 10
255 88 10
255 87 9
255 86 9
255 86 9
255 85 9
255 84 8
255 83 8
255 82 8
255 82 8
255 81 7
254 80 7
254 79 7
254 78 7
254 77 6
254 77 6
254 76 6
254 75 6
254 74 5
254 73 5
254 73 5
254 72 5
254 71 4
254 70 4
254 69 4
254 69 4
254 68 3
254 67 3
254 66 3
254 65 3
254 64 2
254 64 2
254 63 2
254 62 2
254 61 1
254 60 1
254 60 1
254 59 1
253 58 0
253 57 0]/255;
[sz1,~]=size(colmapdef);
cmap=interp1(linspace(0,1,sz1),colmapdef,linspace(0,1,255));
end
function cmap = dawn()
% definition of colormap "dawn"
colmapdef=[
255 255 195
255 255 194
255 255 193
255 255 191
255 255 190
255 255 189
255 255 188
255 255 187
255 255 186
255 255 185
255 255 184
255 255 183
255 255 182
255 255 181
255 255 179
255 255 178
255 255 177
255 255 176
255 255 175
255 255 174
255 255 173
255 255 172
255 255 171
255 255 170
255 255 169
255 255 167
255 255 166
255 255 165
255 255 164
255 255 163
255 255 162
255 255 161
255 255 160
255 255 159
255 255 158
255 255 157
255 255 155
255 255 154
255 255 153
255 255 152
255 255 151
255 255 150
255 255 149
255 255 148
255 255 147
255 255 146
255 255 145
255 255 143
255 255 142
255 255 141
255 255 140
255 255 139
255 255 138
255 255 137
255 255 136
255 255 135
255 255 134
255 255 133
255 255 131
255 255 130
255 255 129
255 255 128
255 255 127
255 255 126
255 255 125
255 253 125
255 251 125
255 249 125
255 247 125
255 245 125
255 242 125
255 241 125
255 238 125
255 237 125
255 235 125
255 233 125
255 231 125
255 229 126
255 227 126
255 225 126
255 223 126
255 221 126
255 219 126
255 217 126
255 215 126
255 213 126
255 211 126
255 209 126
255 207 126
255 205 126
255 203 126
255 201 126
255 199 126
255 197 126
255 195 126
255 193 126
255 191 126
255 189 126
255 187 126
255 185 126
255 183 126
255 181 126
255 179 126
255 177 126
255 175 126
255 173 126
255 171 126
255 169 126
255 167 126
255 165 126
255 163 126
255 161 126
255 159 126
255 157 126
255 155 126
255 153 126
255 151 126
255 149 126
255 147 126
255 145 127
255 143 127
255 141 127
255 138 127
255 136 127
255 134 127
255 132 127
255 131 127
255 129 127
254 126 127
252 125 127
250 122 127
248 121 127
246 118 127
244 116 127
242 115 127
240 113 127
238 111 127
236 109 127
234 107 127
232 105 127
230 102 127
228 100 127
226 98 127
224 97 127
222 94 127
220 93 127
218 91 127
216 89 127
214 87 127
212 84 127
210 83 127
208 81 127
206 79 127
204 77 127
202 75 127
200 73 127
198 70 127
196 68 127
194 66 127
192 64 127
190 63 127
188 61 127
186 59 127
184 57 127
182 54 127
180 52 127
178 51 127
176 49 127
174 47 127
171 44 127
169 42 127
167 40 127
165 39 127
163 37 127
161 34 127
159 33 127
157 31 127
155 29 127
153 27 127
151 25 127
149 22 127
147 20 127
145 18 127
143 17 127
141 14 127
139 13 127
137 11 127
135 9 127
133 6 127
131 4 127
129 2 127
127 0 127
125 0 127
123 0 127
121 0 127
119 0 127
117 0 127
115 0 127
113 0 127
111 0 127
109 0 127
107 0 127
105 0 127
103 0 127
101 0 127
99 0 127
97 0 127
95 0 127
93 0 127
91 0 127
89 0 127
87 0 126
85 0 126
83 0 126
82 0 126
80 0 126
78 0 126
76 0 126
74 0 126
72 0 126
70 0 126
68 0 126
66 0 126
64 0 126
62 0 126
60 0 126
58 0 126
56 0 126
54 0 126
52 0 126
50 0 126
48 0 126
46 0 126
44 0 126
42 0 126
40 0 126
38 0 126
36 0 126
34 0 126
32 0 126
30 0 126
28 0 126
26 0 126
24 0 126
22 0 126
20 0 126
18 0 126
16 0 126
14 0 126
12 0 126
10 0 126
8 0 126
6 0 126
4 0 126
2 0 126
0 0 126]/255;
[sz1,~]=size(colmapdef);
cmap=interp1(linspace(0,1,sz1),colmapdef,linspace(0,1,255));
end

function cmap = seashore()
% definition of colormap "seashore"
colmapdef=[
255 255 195
255 255 194
255 255 193
255 255 191
255 255 190
255 255 189
255 255 188
255 255 187
255 255 186
255 255 185
255 255 184
255 255 183
255 255 182
255 255 181
255 255 179
255 255 178
255 255 177
255 255 176
255 255 175
255 255 174
255 255 173
255 255 172
255 255 171
255 255 170
255 255 169
255 255 167
255 255 166
255 255 165
255 255 164
255 255 163
255 255 162
255 255 161
255 255 160
255 255 159
255 255 158
255 255 157
255 255 155
255 255 154
255 255 153
255 255 152
255 255 151
255 255 150
255 255 149
255 255 148
255 255 147
255 255 146
255 255 145
255 255 143
255 255 142
255 255 141
255 255 140
255 255 139
255 255 138
255 255 137
255 255 136
255 255 135
255 255 134
255 255 133
255 255 131
255 255 130
255 255 129
255 255 128
255 255 127
255 255 126
255 255 125
253 255 125
251 255 125
249 255 125
247 255 125
245 255 125
242 255 125
241 255 125
238 255 125
237 255 125
235 255 125
233 255 125
231 255 125
229 255 126
227 255 126
225 255 126
223 255 126
221 255 126
219 255 126
217 255 126
215 255 126
213 255 126
211 255 126
209 255 126
207 255 126
205 255 126
203 255 126
201 255 126
199 255 126
197 255 126
195 255 126
193 255 126
191 255 126
189 255 126
187 255 126
185 255 126
183 255 126
181 255 126
179 255 126
177 255 126
175 255 126
173 255 126
171 255 126
169 255 126
167 255 126
165 255 126
163 255 126
161 255 126
159 255 126
157 255 126
155 255 126
153 255 126
151 255 126
149 255 126
147 255 126
145 255 127
143 255 127
141 255 127
138 255 127
136 255 127
134 255 127
132 255 127
131 255 127
129 255 127
126 254 127
125 252 127
122 250 127
121 248 127
118 246 127
116 244 127
115 242 127
113 240 127
111 238 127
109 236 127
107 234 127
105 232 127
102 230 127
100 228 127
98 226 127
97 224 127
94 222 127
93 220 127
91 218 127
89 216 127
87 214 127
84 212 127
83 210 127
81 208 127
79 206 127
77 204 127
75 202 127
73 200 127
70 198 127
68 196 127
66 194 127
64 192 127
63 190 127
61 188 127
59 186 127
57 184 127
54 182 127
52 180 127
51 178 127
49 176 127
47 174 127
44 171 127
42 169 127
40 167 127
39 165 127
37 163 127
34 161 127
33 159 127
31 157 127
29 155 127
27 153 127
25 151 127
22 149 127
20 147 127
18 145 127
17 143 127
14 141 127
13 139 127
11 137 127
9 135 127
6 133 127
4 131 127
2 129 127
0 127 127
0 125 127
0 123 127
0 121 127
0 119 127
0 117 127
0 115 127
0 113 127
0 111 127
0 109 127
0 107 127
0 105 127
0 103 127
0 101 127
0 99 127
0 97 127
0 95 127
0 93 127
0 91 127
0 89 127
0 87 126
0 85 126
0 83 126
0 82 126
0 80 126
0 78 126
0 76 126
0 74 126
0 72 126
0 70 126
0 68 126
0 66 126
0 64 126
0 62 126
0 60 126
0 58 126
0 56 126
0 54 126
0 52 126
0 50 126
0 48 126
0 46 126
0 44 126
0 42 126
0 40 126
0 38 126
0 36 126
0 34 126
0 32 126
0 30 126
0 28 126
0 26 126
0 24 126
0 22 126
0 20 126
0 18 126
0 16 126
0 14 126
0 12 126
0 10 126
0 8 126
0 6 126
0 4 126
0 2 126
0 0 126]/255;
[sz1,~]=size(colmapdef);
cmap=interp1(linspace(0,1,sz1),colmapdef,linspace(0,1,255));
end

function y = logfilter(x,S)
y = S*sign(x).*log(1+abs(x)/S);
end
