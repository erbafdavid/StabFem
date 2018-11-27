function mycp(file1, file2)
% This is a platform-independent tool to copy a file on a different name

if(exist(file1)~=2)
    error(['Error in mycp : file ',file1,' does not exist !\n%s\n%s'],...
        ' If this error occurs during SF_BaseFlow, the file associated to your previous baseflow may have disapeared on a previous adapt',...
        ' Try typing ''SF_Status'' and following the recovery procedure...')
  
end

if (strcmp(file1, file2) == 0) % cp will only be called if filenames are different !
    
    if (isunix || ismac)
        command = ['cp ', file1, ' ', file2];
        system(command);
    end
    
    if (ispc)
        command = ['copy ', file1, ' ', file2];
        command = strrep(command, '/', '\');
        system(command);
    end
    
end
end
