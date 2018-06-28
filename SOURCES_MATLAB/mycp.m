function mycp(file1,file2)
% This is a platform-independent tool to copy a file on a different name

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