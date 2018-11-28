function mymv(file1, file2)
% This is a platform-independent tool to copy a file on a different name
if(exist(file1))
if (isunix || ismac)
    command = ['mv ', file1, ' ', file2];
    system(command);
end

if (ispc)
    c1 = ['move /y ']
    c2 = [file1, ' ', file2]
    c2 = strrep(c2, '/', '\')
    command = [c1, c2]
    system(command)
end
else
    mydisp(10,['Warning in mymv : file ',file1,'does not exist'])  
end

end
