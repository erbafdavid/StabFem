%pdeplot2dff.m Wrapper function reading and plotting FreeFem++
%              2D mesh and FreeFem++ data
%
% Author: Chloros2 <chloros2@gmx.de>
% Created: 2018-05-13
%
%   [handles] = pdeplot2dff (points,triangles,boundary,varargin)
%   is a customized FreeFem++ wrapper function to implement some
%   of the classic pdeplot() features. The input arguments
%   include the vertex coordinates, the triangles and the boundary
%   definition as provided by the FreeFem++ savemesh(Th,"mesh.msh")
%   command.
%
%   [handles] = pdeplot2dff (...,'PARAM1',val1,'PARAM2',val2,...)
%   specifies parameter name/value pairs to control the input file format
%
%       Parameter       Value
%      'XYData'     Scalar value in order to colorize the plot
%                      (default='off')
%      'ZStyle'     3D surface instead of 2D Map plot
%                      (default='off')
%      'ColorMap'   Specifies the colormap
%                      (default='jet')
%      'ColorBar'   ndicator in order to include a colorbar
%                      (default='on')
%      'Mesh'       Switches the mesh off/on
%                      (default='off')
%      'Edge'       Shows the PDE boundary
%                      (default='off')
%      'Contour'    Isovalue plot
%                      (default='off' ; accepted values : 'on' or a data set)
%      'Levels'     Number of isovalues for contour plot
%                      (default=10)
%      'colorrange' Range of values to ajust the colormap
%                        (default='minmax', or specify [min,max]) 
%       'title'     Title
%                        (default='')
%       'xlim'      Range for the x-axis
%                        (default='minmax')
%       'ylim'      Range for the y-axis
%                        (default='minmax')

% Copyright (C) 2018 Chloros2 <chloros2@gmx.de>
%
% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see
% <https://www.gnu.org/licenses/>.
%
function [hh] = pdeplot2dff(points,boundary,triangles,varargin) %%DD : switch boundary/triangle
    switch mod(nargin,2) %%DD
        case {1}
        otherwise
            printhelp();
            error('wrong number arguments');
    end
    numvarargs = length(varargin);
    optsnames = {'xydata','colormap','mesh','edge','zstyle','contour','levels','colorbar','colorrange','title','xlim','ylim'};
    vararginval = {[],'jet','off','off','off','off',10,'on','minmax','','minmax','minmax'};
    if(numvarargs~=0)
        switch(mod(numvarargs,2)) %%DD
        case {0}
            optargs(1:numvarargs) = varargin;
            for j = 1:length(optsnames)
                for i = 1:length(varargin)
                    if strcmp(lower(optsnames(j)),optargs(i)) %%DD : lower
                        vararginval(j) = optargs(i+1);
                    end
                end
            end
        otherwise
            printhelp();
            error('wrong number arguments');
        end
    end
    [xydata,setcolormap,showmesh,showedge,zstyle,contourplt,isolevels,showcolbar,colorrange,plottitle,plotxlim,plotylim] = vararginval{:};%DD
    points=rowvec(points);
    triangles=rowvec(triangles);
    xpts=points(1,:);
    ypts=points(2,:);
    dataX=[xpts(triangles(1,:)); xpts(triangles(2,:)); xpts(triangles(3,:))];
    dataY=[ypts(triangles(1,:)); ypts(triangles(2,:)); ypts(triangles(3,:))];
    if (~isempty(xydata))
        cpts=rowvec(xydata);
        dataC=[cpts(triangles(1,:)); cpts(triangles(2,:)); cpts(triangles(3,:))];
        if strcmp(contourplt,'off')
            if strcmp(showmesh,'off')
                if strcmp(zstyle,'off')
                    hh=patch(dataX,dataY,dataC,'EdgeColor','none');
                    view(2);
                else
                    hh=patch(dataX,dataY,dataC,dataC,'EdgeColor','none');
                    daspect([1 1 2.5*(max(max(dataC))-min(min(dataC)))]);
                    view(3);
                end
            else
                if strcmp(zstyle,'off')
                    hh=patch(dataX,dataY,dataC,'EdgeColor',[0 0 0],'LineWidth',1);
                    view(2);
                else
                    hh=patch(dataX,dataY,dataC,dataC,'EdgeColor',[0 0 0],'LineWidth',1);
                    daspect([1 1 2.5*(max(max(dataC))-min(min(dataC)))]);
                    view(3);
                end
            end
        else
            hh=patch(dataX,dataY,dataC,'EdgeColor','none');
            view(2);
            hold on;
            [~,sz2]=size(dataX);
            N=sqrt(sz2);
            if (N > 150)
                N=150;
            end
            %%DD
            if strcmp(contourplt,'on') 
                dataL = dataC;
            else
                cpts=rowvec(contourplt);
                dataL=[cpts(triangles(1,:)); cpts(triangles(2,:)); cpts(triangles(3,:))];
            end %%DD/end
            ymin=min(min(dataY));
            ymax=max(max(dataY));
            xmin=min(min(dataX));
            xmax=max(max(dataX));
            x=linspace(xmin,xmax,N);
            y=linspace(ymin,ymax,N);
            [X,Y]=meshgrid(x,y);
            C=tri2grid(dataX,dataY,dataL,x,y);%%DD:dataL
           
           dashednegative = 'yes';
           if(strcmp(dashednegative,'yes'))
             if(length(isolevels)==1)
               step = (max(max(C))-min(min(C)))/(isolevels+1);
               isolevels = [min(min(C))+step:step:max(max(C))-step];
             end
             isopos = isolevels(isolevels>=0); 
             if(length(isopos)==1) isopos = [isopos isopos]; end;
             isoneg = isolevels(isolevels<0); 
             if(length(isoneg)==1) isoneg = [isoneg isoneg]; end;
             [~,hhc]=contour(X,Y,C,isoneg,'--','LineColor',[0 0 0]);  hh=[hh; hhc];
             [~,hhc]=contour(X,Y,C,isopos,'LineColor',[0 0 0]);  hh=[hh; hhc];
           else
             [~,hhc]=contour(X,Y,C,isolevels,'LineColor',[0 0 0]); hh=[hh; hhc];
           end
           
        end
        colormap(setcolormap);
        %%DD
        if(~isnumeric(colorrange)) 
            caxis([min(min(dataC)) max(max(dataC))]);
        else
            caxis(colorrange); 
        end
        %%DD/end
        if strcmp(showcolbar,'on')
            hcb=colorbar;
            hh=[hh; hcb];
        end
    else
        if ~strcmp(showmesh,'off')
            hh=patch(dataX,dataY,[1 1 1],'EdgeColor',[0 0 1],'LineWidth',1);
            view(2);
        end
    end
    if ~strcmp(showedge,'off')
        boundary=rowvec(boundary);
        line([xpts(boundary(1,:));xpts(boundary(2,:))], ...
             [ypts(boundary(1,:));ypts(boundary(2,:))],'Color','red','LineWidth',2);
    end
    
    %%DD
    if(~strcmp(plottitle,'')) 
        title(plottitle);
    end
    if(~strcmp(plotxlim,'minmax')) 
        axis equal;
        xlim(plotxlim);
    end
    if(~strcmp(plotylim,'minmax')) 
        ylim(plotylim);
    end 
    hold off;
    %%DD/end
    
end

function [S] = rowvec(S)
    [sz1,sz2]=size(S);
    if sz1>sz2
        S=S';
    end
end

function [u] = tri2grid(tx, ty, tc, X, Y)
    u=NaN(numel(Y),numel(X));
    ax=tx(1,:);
    ay=ty(1,:);
    bx=tx(2,:);
    by=ty(2,:);
    cx=tx(3,:);
    cy=ty(3,:);
    invA0=(1.0)./((by-cy).*(ax-cx)+(cx-bx).*(ay-cy));
    for mx=1:numel(X)
        for my=1:numel(Y)
            px=X(mx);
            py=Y(my);
            Aa=((by-cy).*(px-cx)+(cx-bx).*(py-cy)).*invA0;
            Ab=((cy-ay).*(px-cx)+(ax-cx).*(py-cy)).*invA0;
            Ac=1.0-Aa-Ab;
            pos=find(((Aa>=0) & (Ab>=0) & (Ac>=0)),1,'first');
            if ~isempty(pos)
                u(my,mx)=Aa(pos).*tc(1,pos)+ ...
                         Ab(pos).*tc(2,pos)+ ...
                         Ac(pos).*tc(3,pos);
            end
        end
    end
end

function printhelp()
    fprintf('%s\n\n','Invalid call to pdeplot2dff.  Correct usage is:');
    fprintf('%s\n',' -- [handles] = pdeplot2dff (points,triangles,boundary,varargin)');
    fprintf('%s\n',' -- [handles] = pdeplot2dff (points,triangles,boundary,''XYData'',u,''ColorMap'',''jet'',''Mesh'',''on'')');
    fprintf('%s\n',' -- [handles] = pdeplot2dff (points,triangles,boundary,''XYData'',u,''ZStyle'',''on'')');
    fprintf('%s\n',' -- [handles] = pdeplot2dff (points,triangles,boundary,''XYData'',u,''Edge'',''on'',''Contour'',''on'',''Levels'',10)');
    fprintf('\n');
end