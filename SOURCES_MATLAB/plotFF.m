function handle = plotFF(FFdata,field1,normalisation);
%  function plotFF
%  plots a data field imported from freefem using pdeplot command from
%  toolbox pdetools
%  Usage : 
%  1/ handle=plotFF(mesh); (if mesh is a mesh object)
%  2/ handle=plotFF(ffdata,'field'); to plot isocontours of a P1 field
%  3/ handle=plotFF(ffdata,'field',normalisation) 
%
%  FFdata is the structure containing the data to plot
%  field is the field to plot (the data may comprise multiple fields)
%  normalisation (optional) is used to plot real(field/normalisation)
%  (may be useful, for instance, to plot re/im parts of a complex field)

handle = figure();


    % plot field 
if(nargin==1)
    field = 'mesh';
    mesh=FFdata;
end
if(nargin==2)    
   field = field1;
   %if(strcmp(field,'mesh')==1)
   mesh=FFdata.mesh;
   %else
   data = getfield(FFdata,field);
   %end
end

 if(nargin==3)
    field = field1;
    data = real(getfield(FFdata,field)/normalisation);
    mesh=FFdata.mesh;
 end
 
if(strcmp(field,'mesh')~=1)
 
axes1 = axes('Parent',handle);
box(axes1,'on');
hold(axes1,'all');
if(any(strcmp('plottitle',fieldnames(FFdata)))) 
    title(FFdata.plottitle) 
end
%pdemesh(mesh.points,mesh.seg,mesh.tri) ;
 
 pdeplot(FFdata.mesh.points,FFdata.mesh.seg,FFdata.mesh.tri,'xydata',data,'mesh','off','colormap','jet');
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
 if(any(strcmp('plottitle',fieldnames(FFdata.mesh)))) 
    title(FFdata.mesh.plottitle) 
end

 pdemesh(mesh.points,mesh.seg,mesh.tri) ;
 axis equal ;

end


if(any(strcmp('xlim',fieldnames(FFdata)))) 
    xlim(axes1,FFdata.xlim); 
elseif(any(strcmp('xlim',fieldnames(FFdata.mesh))))
    xlim(axes1,FFdata.mesh.xlim); 
end

if(any(strcmp('ylim',fieldnames(FFdata))))
    ylim(axes1,FFdata.ylim); 
elseif(any(strcmp('ylim',fieldnames(FFdata.mesh))))
    ylim(axes1,FFdata.mesh.ylim); 
end

end

