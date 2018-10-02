
R = 1;
H = 2;
g = 1;
gamma = 0.002;

% zeros of bessel functions
jp(1,1) = 3.8317; jp(1,2) = 7.0156; jp(1,3) = 10.1735; % zeros of j0'
jp(2,1) = 1.8412; jp(2,2) = 5.3314; jp(2,3) = 8.5363; % zeros of j1'
jp(3,1) = 3.0542; jp(3,2) = 6.7061; jp(3,3) = 9.9695; % zeros of j2'

% m=0 modes

disp( 'frequencies of m = 0 modes : ');
k = jp(1,:)/R;
omega0 = sqrt( (g*k+gamma*k.^3).*tanh(k*H))

% m=1 modes

disp( 'frequencies of m = 1 modes : ');
k = jp(2,:)/R;
omega1 = sqrt( (g*k+gamma*k.^3).*tanh(k*H))



