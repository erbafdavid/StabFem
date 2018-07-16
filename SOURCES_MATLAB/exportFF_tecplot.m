%> @file exportFF_tecplot.m
%> @brief Exports a finite-element file for tecplot
%>
%> @param[in] femstruct: TO COMPLETE, short description of femstruct
%> @param[in] namefile: name of the tecplot file
%>
%> @author David Fabre
%> @date 07/07/2017 Initial upload on github
function exportFF_tecplot(femstruct, namefile)

%% program to export a finite-element file for tecplot
disp('PROGRAM exportFF_tecplot : exporting data in tecplot format');

fid = fopen(namefile,'w');

np = femstruct.mesh.np;
nt = length(femstruct.mesh.tri);
Fields = fieldnames(femstruct);
tec_DATA = [];
tec_description = 'VARIABLES = "x", "y", ';
descriptor = '%12.8f %12.8f ';
for i = 1 : length(Fields);
    DD = getfield(femstruct,char(Fields(i)));
    if (length(DD)==np)
        if(max(imag(DD))==0)
            disp(['P1 field : ' char(Fields(i))]);
            tec_description = [tec_description '"' char(Fields(i)) '" ,'];
            descriptor= [descriptor '%12.8f '];
            tec_DATA = [tec_DATA, DD];
        else
            disp(['P1 COMPLEX field : ' char(Fields(i))]);
            tec_description = [tec_description '"' char(Fields(i)) '_r" , "' char(Fields(i)) '_i" ,'];
            descriptor= [descriptor '%12.8f %12.8f '];
            tec_DATA = [tec_DATA, real(DD) imag(DD)];
        end
        
    end
end

descriptor = [descriptor '\n'];
tec_description = [tec_description(1:end-1), '\n'];
tec_description2 = ['ZONE F=FEPOINT,ET=TRIANGLE,N=', num2str(np), ',E= ',num2str(nt) '\n'];

fprintf(fid,tec_description);
fprintf(fid,tec_description2);


for i = 1:np
fprintf(fid,descriptor,[ femstruct.mesh.points(:,i)',tec_DATA(i,:)]);
%fprintf(fid,tec_DATA(i,:));
end

for i = 1:nt
fprintf(fid,'%i %i %i \n',femstruct.mesh.tri(1:3,i)');
%sprintf('%i %i %i \n',femstruct.mesh.tri(1:3,i)')
end

%fwrite(fid,femstruct.mesh.tri(:,1:3)');

fclose(fid);
disp('END PROGRAM exportFF_tecplot');
end

% //// EXPORTATION DU CHAMP DE BASE AUX FORMATS TECPLOT ET MATLAB
% //	{
% //	ofstream champ2D("chbase_RE"+Re+".dat");
% //	{
% //		champ2D << "VARIABLES= \"x\" , \"y\" , \"u\" , \"v\" , \"p\" , \"om\" "<< endl;
% //		champ2D << "ZONE F=FEPOINT,ET=TRIANGLE,N=" << th.nv << ",E=" << th.nt << endl;
% //	
% //		for (int j=0; j<th.nv; j++)
% //		{
% //			champ2D << xx[][j] << " " << yy[][j]  << " " << ut[][j] <<  " " << vt[][j] << " " << pt[][j] << " " << vort[][j] << endl;
% //		}; 
% //
% //		for (int i=0; i<th.nt; i++)
% //		{ 
% //			champ2D << th[i][0]+1 << " " << th[i][1]+1 << " " << th[i][2]+1 << endl;
% //		};
% //	};
% //	}



