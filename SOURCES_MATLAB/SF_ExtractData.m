
function values = SF_ExtractData(ffdata,field,X,Y);
%
% This function interpolated data from a P1-ordered field of a ffdata,
% on prescribed X and Y vectors.
%
% Usage : value = SF_ExtractData(ffdata,fieldname,X,Y)
% X and Y are expected as 1D-vectors of same length 
% (but if either X or Y are a single constant, the function will work as well)
%
% Examples of usage : UXaxis = SF_ExtractData(bf,'ux',[0:.01:10],0); -> values on the x-axis 
%                     Vortline = SF_ExtractData(em,'vort1',[0:.01:10],[[0:.01:10]); -> values of the vorticity on a diagonal line  
% 
% Adapted from ffplottri2gridint from Chloros, 2018. 
% Incorporated into the StabFem project by D. F on nov. 1, 2018.

% Position input files
if(strcmpi(ffdata.datatype,'Mesh')==1)
       % first argument is a simple mesh
       ffmesh = ffdata; 
else
       % first argument is a base flow
       ffmesh = ffdata.mesh;
       
end



    xpts=ffmesh.points(1,:);
    ypts=ffmesh.points(2,:);
    tx=[xpts(ffmesh.tri(1,:)); xpts(ffmesh.tri(2,:)); xpts(ffmesh.tri(3,:))];
    ty=[ypts(ffmesh.tri(1,:)); ypts(ffmesh.tri(2,:)); ypts(ffmesh.tri(3,:))];    
    ax=tx(1,:);
    ay=ty(1,:);
    bx=tx(2,:);
    by=ty(2,:);
    cx=tx(3,:);
    cy=ty(3,:);
    invA0=(1.0)./((by-cy).*(ax-cx)+(cx-bx).*(ay-cy));

    uu = getfield(ffdata, field);
    tu = preparedata(ffmesh.points,ffmesh.tri,uu);
    
    if(numel(X)==1)
        X = X*ones(size(Y)); 
    end
    
    if(numel(Y)==1)
        Y = Y*ones(size(X));
    end
    
        u=NaN(numel(X));
        for mx=1:numel(X)
                px=X(mx);
                py=Y(mx);
                Aa=((by-cy).*(px-cx)+(cx-bx).*(py-cy)).*invA0;
                Ab=((cy-ay).*(px-cx)+(ax-cx).*(py-cy)).*invA0;
                Ac=1.0-Aa-Ab;
                pos=find(((Aa>=-1e-10) & (Ab>=-1e-10) & (Ac>=-1e-10)),1,'first');
                if ~isempty(pos)
                    values(mx)=Aa(pos).*tu(1,pos)+ ...
                             Ab(pos).*tu(2,pos)+ ...
                             Ac(pos).*tu(3,pos);
                end
        end
        
end


function [varargout] = preparedata(points,triangles,data)
    M=rowvec(data);
    [ndim,ndof]=size(M);
    [~,nv]=size(points);
    varargout=cell(1,ndim);
    if (ndof==nv)
        %Data in points/vertex format (P1-Simulation): Works for P1 FE-space only
        for i=1:ndim
            cols=M(i,:);
            varargout{i}=[cols(triangles(1,:)); cols(triangles(2,:)); cols(triangles(3,:))];
        end
    else
        %Data in triangle format (work around): Works for P1 as well as for other Elements
        [~,nt]=size(triangles);
        if ~((nt*3)==ndof)
            error('unable to recognize input data format');
        end
        for i=1:ndim
            varargout{i}=reshape(M(i,:),3,nt);
        end
    end
end

function [S] = rowvec(S)
    [sz1,sz2]=size(S);
    if sz1>sz2
        S=S.'; % use .' instead of ' for complex fields !!!
    end
end
