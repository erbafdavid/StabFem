function sigma_branch = FreeFem_Stability_LoopRe(baseflow, Re_Range, varargin) %m,shift,nev,filename)

% Matlab driver to compute stability curve : sigma as function of Re in a
% given range.
%
% usage : sigma_branch = FreeFem_Stability_LoopRe(baseflow,Re_range,[option1,value1])
% Parameters :
% Reynolds (range under the form of a vector),
% wavenumber m,
% shift (complex), for initial point
% nev number of eigenvalues
% namefile (optional) name of the file where the results are written
%
%  If nev > 1 the loop will use Arnoldi iteration with fixed shift
%  If nev = 1 the loop will use shift-invert iteration with continuation for shift and eigenmode structure
%    (much more efficient for tracking one branch)
%
% Version 2.0 by D. Fabre , 2 june 2017

global ff ffdir ffdatadir

%%% management of optionnal parameters
p = inputParser;
%paramaters for axisymmetric case
addParameter(p, 'm', 1, @isnumeric);
%parameters for 2D case (to be implemented...)
addParameter(p, 'k', 0, @isnumeric);
addParameter(p, 'sym', 'A', @ischar);
addParameter(p, 'filename', '', @ischar);
%parameters for the eigenvalue solver
addParameter(p, 'shift', 1+1i, @isnumeric);
addParameter(p, 'nev', 1, @isnumeric);
addParameter(p, 'type', 'D', @ischar);
parse(p, varargin{:});
shift = p.Results.shift;

sigma_branch = [];
system('rm Eigenmode_guess.txt');
system('rm Branches.txt');

for Re = Re_Range
    
    % if(exist([ ffdatadir '/CHBASE/chbase_Re' num2str(Re) '.txt'])==2);
    %     disp(['Re = ',num2str(Re), ' : base flow already computed']);
    %     system(['cp ' ffdatadir '/CHBASE/chbase_Re' num2str(Re) '.txt chbase.txt']);
    % else
    %     disp(['Re = ',num2str(Re), ' : computing base flow ']);
    baseflow = FreeFem_BaseFlow(baseflow, Re);
    % end
    
    EV = FreeFem_Stability(baseflow, varargin{:}, 'shift', shift);
    sigma_branch = [sigma_branch, EV];
    
    system('cat ./Eigenvalues.txt >> Branches.txt'); %% file to put everything in case of crash
    if (p.Results.nev == 1)
        if (length(sigma_branch) > 1)
            shift = 2 * sigma_branch(end) - sigma_branch(end-1); % guess is interpolated using two previous values
        else
            shift = sigma_branch(1); % guess is previous value
        end
        system('cp Eigenmode.txt Eigenmode_guess.txt'); % provides a guess for next iteration
    end
end

if (length(p.Results.filename > 0))
    system(['cp Branches.txt ', filename]);
end
