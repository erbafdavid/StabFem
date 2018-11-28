

ffmesh = importFFmesh('../BirdCallComplex/MESH30x30DIRECT/MESHES/mesh_adapt11_Re1600_Ma0.05.msh');
bf = importFFdata(ffmesh,'../BirdCallComplex/MESH30x30DIRECT/MESHES/BaseFlow_adapt9_Re1280_Ma0.05.ff2m');

%% Plot figure 4 Longorbardi et. al.

% Definition of Reynolds range
Re_Range = [Re_RangeHigh(end:-1:1), 1600]
ev1B = zeros(3,17)
ev2B = zeros(3,17)
ev3B = zeros(3,13)
ev4B = zeros(3,6)

% Load mesh based on eigenmode simulation with domain 30x30
load('../BirdCallComplex/MESH30x30DIRECT/figure4.mat')

ev1B(1,:) = ev1BranchListH(end:-1:1)
ev2B(1,:) = ev2BranchListH(end:-1:1)
ev3B(1,:) = ev3BranchListH(end:-1:1)
ev4B(1,:) = ev4BranchListH(end:-1:1)

% Load mesh based on sensitivity simulation with domain 30x30
load('../BirdCallComplex/MESH30x30SEN/Figure4.mat')

ev1B(2,:) = ev1BranchListH(end:-1:1)
ev2B(2,:) = ev2BranchListH(end:-1:1)
ev3B(2,:) = ev3BranchListH(end-1:-1:1)
ev4B(2,:) = ev4BranchListH(end:-1:1)

% Load mesh based on eigenmode simulation with domain 80x80
load('../BirdCallComplex/MESH80x80DIRECT/Figure4.mat')

ev1B(3,:) = ev1BranchListH(end:-1:1)
ev2B(3,:) = ev2BranchListH(end:-1:1)
ev3B(3,:) = ev3BranchListH(end:-1:1)
ev4B(3,:) = ev4BranchListH(end:-1:1)


% Plot Real part 4 a)
% title('$\hat{\psi}$','Interpreter','latex')
color = ["g-","g--","g-.","g:";
         "r-","r--","r-.","r:";
         "b-","b--","b-.","b:"]
figure(1);
for i=[1:3]
    plot(Re_Range, real(ev1B(i,:)),char(color(i,1)));
    hold on;
    plot(Re_Range, real(ev2B(i,:)),char(color(i,2)));
    plot(Re_Range(5:end), real(ev3B(i,:)),char(color(i,3)));
    plot(Re_Range(12:end), real(ev4B(i,:)),char(color(i,4)));
end
set(gca,'fontsize',30);
set(gca,'TickLabelInterpreter','latex')
set(findall(gca, 'Type', 'Line'),'LineWidth',2);
axis([300 1700 -0.2 1])

leg1 = legend('$CM$', '$Sponge$');



figure(2);
for i=[1:3]
    plot(Re_Range, -imag(ev1B(i,:)),char(color(i,1)));
    hold on;
    plot(Re_Range, -imag(ev2B(i,:)),char(color(i,2)));
    plot(Re_Range(5:end), -imag(ev3B(i,:)),char(color(i,3)));
    plot(Re_Range(12:end), -imag(ev4B(i,:)),char(color(i,4)));
end
axis([300 1700 2.8 10])
set(gca,'fontsize',30);
set(gca,'TickLabelInterpreter','latex')
set(findall(gca, 'Type', 'Line'),'LineWidth',6);
