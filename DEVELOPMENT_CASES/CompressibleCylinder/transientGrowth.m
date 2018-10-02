% Temporal file for transient Growth 
clear all; clc;
run('../SOURCES_MATLAB/SF_Start.m');
verbosity = 20;
close all;

Re = 60;
Ma = 0.5
tEnd = 80.0;
dt = 0.4;
ncores = 1

argumentstring = [' " ' num2str(Re) ' '  num2str(Ma) ' ' num2str(tEnd)... 
                             ' ' num2str(dt) ' " '];
solvercommand = ['echo ' argumentstring ' | ',ffMPI,' -np ',num2str(ncores),' ', 'DNSComp.edp'];
status = mysystem(solvercommand);

