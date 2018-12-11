function res = BF_Add(field1,field2,varargin)

%% Very basic driver to add two fields ; to be improved

global ff ffdir ffdatadir sfdir verbosity

p = inputParser;
addParameter(p, 'Amp1', 1);
addParameter(p, 'Amp2',1e-3);
parse(p, varargin{:});

% reads first file
fid1 = fopen(field1.filename);
size1 = fscanf(fid1,'%d',1);
if(strcmp(field1.datastoragemode(1:2),'Re'))
    data1 = fscanf(fid1,'%f',size1);
else
    data1raw = fscanf(fid1,' (%f,%f)',2*size1);
    data1 = data1raw(1:2:end-1)+1i*data1raw(2:2:end);
end
end1 = fscanf(fid1,'%f');
fclose(fid1);

% reads second file
fid2 = fopen(field2.filename);
size2 = fscanf(fid2,'%d',1);
if(strcmp(field2.datastoragemode(1:2),'Re'))
    data2 = fscanf(fid2,'%f',size2);
else
    data2raw = fscanf(fid2,' (%f,%f)',2*size2);
    data2 = data2raw(1:2:end-1)+1i*data2raw(2:2:end);
end
end2 = fscanf(fid2,'%f');
fclose(fid2);




if(size1~=size2) 
    error('Error : the fields have different structures and cannot be added')
end

% Generation of the .txt file 
    data3 = real(p.Results.Amp1*data1+p.Results.Amp2*data2);
    mydisp(2,'Creating field by adding two fields');
    res.filename = [ ffdatadir 'Addition.txt'];
    res.datatype= 'Addition';
    res.DataDescription = ['Addition of two fields from files ' field1.filename ' and ' field2.filename];
    res.datastoragemode = field1.datastoragemode;
    fid3 = fopen(res.filename,'w');
    fprintf(fid3,'%d \n',size1);
    fprintf(fid3,' %f %f %f %f %f \n',data3);
    if(strcmp(field1.datatype,'BaseFlow')||strcmp(field1.datatype,'MeanFlow'))
    fprintf(fid3,' %f \n',end1);
    end
    fclose(fid3);
    
res.mesh = field1.mesh;    
    
% Construction of the fields of res
% res.ux = field1.ux+field2.ux, etc... for each field of relevant dimension
    
end



    
    
