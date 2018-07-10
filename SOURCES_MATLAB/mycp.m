function mycp(file1,file2)
% This is a platform-independent tool to copy a file on a different name

if(strcmp(file1,file2)==0) % cp will only be called if filenames are different !

if(isunix||ismac)
    command = [ 'cp ' file1 ' ' file2 ];
    system(command);
end

if(ispc)
    command = [ 'copy ' file1 ' ' file2 ];
    command = strrep(command,'/','\');
    system(command);
end

end

end