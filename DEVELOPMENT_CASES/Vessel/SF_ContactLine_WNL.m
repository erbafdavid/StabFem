function WNL = SF_ContactLine_WNL(mode)
%>
%> Function WNL_ContactLine_WNL
%>
%> Computes the coefficients of the WNL approach of Viola, Gallaire & Brun
%>
%> USAGE:
%> WNL = SF_ContactLine_WNL(mode)
%>

global ff ffMPI ffdir ffdatadir sfdir verbosity

 mycp(mode.filename,[ffdatadir 'EIGENMODE_FOR_WNL.txt']);
 WNL = SF_Launch('WNL_ContactLine_Potential.edp','DataFile','WNL.ff2m')

end