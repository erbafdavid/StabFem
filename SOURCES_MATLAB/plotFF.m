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


global ff ffdir ffdatadir sfdir verbosity

%handle = figure();
%handle = gcf;


if (mod(nargin, 2) == 1) % plot mesh in single-entry mode
    mesh = FFdata;
    varargin = {varargin{:}, 'mesh', 'on'};
    mydisp(15, ['launching ffpeplot with the following options :']);
    if (verbosity >= 15)
        varargin
    end;
    ffpdeplot(mesh.points, mesh.seg, mesh.tri, varargin{:});
else
    mesh = FFdata.mesh;
    field1 = varargin{1};
    varargin = {varargin{2:end}};
    if (strcmp(field1, 'mesh')) % plot mesh ins double-entry mde
        varargin = {varargin{:}, 'mesh', 'on'};
        
        mydisp(15, ['launching ffpeplot with the following options :']);
        if (verbosity >= 15)
            varargin
        end;
        
        ffpdeplot(mesh.points, mesh.seg, mesh.tri, varargin{:});
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
        
        ffpdeplot(FFdata.mesh.points, FFdata.mesh.seg, FFdata.mesh.tri, 'xydata', data, varargin{:});
        
        mydisp(15, ['launching ffpeplot with the following options :']);
        if (verbosity >= 15)
            varargin
        end;
        %pdeplot(FFdata.mesh.points,FFdata.mesh.seg,FFdata.mesh.tri,'xydata',data,varargin{:});
        % axis equal;
        %if(any(strcmp('plottitle',fieldnames(FFdata))))
        %    title(FFdata.plottitle)
        %end
        
        
    end
    
    % plot mesh
    % axes1 = axes('Parent',handle);
    % box(axes1,'off');
    % hold(axes1,'all');
    %xlabel('x');ylabel('r');
    % if(any(strcmp('plottitle',fieldnames(FFdata))))
    %    title(FFdata.plottitle)
    % end
    
    
    %if(length(mesh.seg)==1) % to construct the 'seg' structure necessary for ploting mesh
    %    FFdata.mesh=importFFmesh('mesh.msh','seg');
    %end
    
    %pdemesh(FFdata.mesh.points,FFdata.mesh.seg,FFdata.mesh.tri) ;
    %axis equal;
    %end
    
    
    % This should be removed in some future, as this as this is now done differently
    % if(any(strcmp('plottitle',fieldnames(FFdata))))
    %     title(FFdata.plottitle)
    % end
    % if(any(strcmp('xlim',fieldnames(FFdata))))
    %     xlim(axes1,FFdata.xlim);
    % elseif ( any(strcmp('mesh',fieldnames(FFdata))) && any(strcmp('xlim',fieldnames(FFdata.mesh))) )
    %     xlim(axes1,FFdata.mesh.xlim);
    % end
    % if(any(strcmp('ylim',fieldnames(FFdata))))
    %     ylim(axes1,FFdata.ylim);
    % elseif ( any(strcmp('mesh',fieldnames(FFdata))) && any(strcmp('ylim',fieldnames(FFdata.mesh))) )
    %     ylim(axes1,FFdata.mesh.ylim);
    % end
    
    %axis equal;
    
end

%pdemesh(FFdata.mesh.points,FFdata.mesh.seg,FFdata.mesh.tri) ;
%axis equal;
%end
