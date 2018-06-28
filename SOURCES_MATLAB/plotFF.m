function handle = plotFF(FFdata,field1,varargin);
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
%      where [PARAM,VALUE] is any couple of parameters accepted by pdeplot.
%       (help pdeplot for a list of possibilities)
%
%  FFdata is the structure containing the data to plot
%  field is the field to plot (the data may comprise multiple fields)
%  (may be useful, for instance, to plot re/im parts of a complex field)
%

%   This version of plotFF is based on pdeplot2dff developed by chloros2
%   as an Octave-compatible alternative to pdeplot from toolbox pdetools 
%   (https://github.com/samplemaker/freefem_matlab_octave_plot)



global ff ffdir ffdatadir sfdir verbosity

handle = figure();
%handle = gcf;

% single-input mode (to plot mesh)
if(nargin==1)
    field1 = 'mesh';
    mesh = FFdata;

    varargin={ varargin{:}, 'mesh', 'on'}; 
    pdeplot2dff(mesh.points,mesh.seg,mesh.tri,varargin{:});
    %axis equal;
else
    mesh = FFdata.mesh;
    field1 = varargin{1};
    varargin = { varargin{2:end} };
    if(strcmp(field1,'mesh')) % plot mesh ins double-entry mde
        varargin={ varargin{:}, 'mesh', 'on'};
        pdeplot2dff(mesh.points,mesh.seg,mesh.tri,varargin{:});
        %axis equal;
    else
    % plot data 
    
    % check if data to plot is a the name of a field or a numerical dataset
    if(~isnumeric(field1))
        [dumb,field,suffix] = fileparts(field1); % to extract the suffix
        if(strcmp(suffix,'.im')==1)
            data = imag(getfield(FFdata,field));
        else
            data = real(getfield(FFdata,field));
        end
    else
       data = field1;
    end

    % same check for the data to plot using contours
%    if(any(cellfun(@(x) isequal(lower(x), 'contour'), varargin)))
%        iii = find(strcmp(varargin,'contour'));
%        field1 = varargin{iii+1};
%        if(~isnumeric(field1))
%            [dumb,field,suffix] = fileparts(field1); % to extract the suffix
%            if(strcmp(suffix,'.im')==1)
%                dataL = imag(getfield(FFdata,field));
%            else
%                dataL = real(getfield(FFdata,field));
%            end
%        varargin{iii+1} = dataL;
%        end  
%    end
    
%if( (any(cellfun(@(x) isequal(lower(x), 'colormap'), varargin))==0) )
%    varargin={varargin{:} ,'ColorMap','parula'}; % default colormap set to parula
%end

%if( any(cellfun(@(x) isequal(lower(x), 'mesh'), varargin))==0) 
%    varargin={varargin{:} ,'Mesh','off'};
%end

%if(length(colorrange)==2)
%    data = min(max(data,colorrange(1)),colorrange(2)); % ecretage des donnees
%end
pdeplot2dff(FFdata.mesh.points,FFdata.mesh.seg,FFdata.mesh.tri,'xydata',data,varargin{:});
%pdeplot(FFdata.mesh.points,FFdata.mesh.seg,FFdata.mesh.tri,'xydata',data,varargin{:});
% axis equal;
%if(any(strcmp('plottitle',fieldnames(FFdata)))) 
%    title(FFdata.plottitle) 
%end


% check if 'colorrange' is a parameter.
narg = length(varargin);colorrange = 0;
if(narg>0)
if(strcmp(lower(varargin{narg-1}),'colorrange')==1)
    colorrange = varargin{narg};
    varargin = {varargin{1:narg-2}};
end
end

% two-input mode (to plot a field, real or complex)
if(strcmp(field1,'mesh')==0)
   [dumb,field,suffix] = fileparts(field1); % to extract the suffix
   mesh=FFdata.mesh;
   if(strcmp(suffix,'.im')==1)
        data = imag(getfield(FFdata,field));
   else
        data = real(getfield(FFdata,field));
   end
end

if(strcmp(field1,'mesh')~=1)
 
axes1 = axes('Parent',handle);
box(axes1,'on');
hold(axes1,'all');
if(any(strcmp('plottitle',fieldnames(FFdata)))) 
    title(FFdata.plottitle) 
end
%pdemesh(mesh.points,mesh.seg,mesh.tri) ;


if( (any(cellfun(@(x) isequal(lower(x), 'contour'), varargin))) ...
     &&(length(FFdata.mesh.seg)==1) ) 
         mydisp(2,'PlotFF : Reconstructing seg array is neccessary for contour plots');
         meshS=importFFmesh([ ffdatadir , 'mesh.msh'],'seg');
         FFdata.mesh.seg=meshS.seg;
end

if( (any(cellfun(@(x) isequal(lower(x), 'colormap'), varargin))==0) )
    varargin={varargin{:} ,'ColorMap','parula'}; % default colormap set to parula
end

if( any(cellfun(@(x) isequal(lower(x), 'mesh'), varargin))==0) 
    varargin={varargin{:} ,'Mesh','off'};
end

if(length(colorrange)==2)
    data = min(max(data,colorrange(1)),colorrange(2)); % ecretage des donnees
end

pdeplot(FFdata.mesh.points,FFdata.mesh.seg,FFdata.mesh.tri,'xydata',data,varargin{:});
 axis equal;
if(any(strcmp('plottitle',fieldnames(FFdata)))) 
    title(FFdata.plottitle) 
end


else
% plot mesh
 axes1 = axes('Parent',handle);
 box(axes1,'off');
 hold(axes1,'all');
 xlabel('x');ylabel('r');
 if(any(strcmp('plottitle',fieldnames(FFdata)))) 
    title(FFdata.plottitle) 
 end

if(length(mesh.seg)==1) % to construct the 'seg' structure necessary for ploting mesh
    FFdata.mesh=importFFmesh('mesh.msh','seg');
end

 pdemesh(FFdata.mesh.points,FFdata.mesh.seg,FFdata.mesh.tri) ;
axis equal;
end


if(any(strcmp('xlim',fieldnames(FFdata)))) 
    xlim(axes1,FFdata.xlim); 
elseif ( any(strcmp('mesh',fieldnames(FFdata))) && any(strcmp('xlim',fieldnames(FFdata.mesh))) )
    xlim(axes1,FFdata.mesh.xlim); 
end

if(any(strcmp('ylim',fieldnames(FFdata))))
    ylim(axes1,FFdata.ylim); 
elseif ( any(strcmp('mesh',fieldnames(FFdata))) && any(strcmp('ylim',fieldnames(FFdata.mesh))) )
    ylim(axes1,FFdata.mesh.ylim); 
end

end
