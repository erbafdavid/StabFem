function myrm(file)
% This is a platform-independent tool to copy a file on a different name

if(isunix||ismac)
    command = [ 'rm ' file ];
    system(command);
end

if(ispc)
    c1 = [ 'del /q ' ];
    c2 = [ file ];
    c2 = strrep(c2,'/','\');
    command = [c1 c2];
    system(command);
end

end