function h = plotFF_ETA(varargin)
%
% This functions adds to the current plot a representation of the
% free-surface displacement ETA.
%
% Usage (just after SF_Plot(em,'ux')
% SF_Plot(em,['E',E,'style',color,'LineWidth',lw,'projection','n'|'r'|'z?,symmmetry,'sym')

disp(' WARNING : function plotFF_ETA is now called SF_Plot_ETA. Please update your programs !') 
handle = SF_Plot_ETA(varargin{:});

end