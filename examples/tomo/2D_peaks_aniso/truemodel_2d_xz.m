function [Vh, E, h, sensors, events] = truemodel_2d_xy(Nev)
%[Vh, E, h, sensors, events] = TRUEMODEL_2D_XY(Nev)
%
%This function constructs a 2D model of 28x28 nodes with an isotropic,
%heterogeneous wave velocity (given by matlab's peaks function), and
%generates coordinates for 8 sensors positioned regularly in the grid on
%the perimeter of a disk of radius 2.5. OUtisde this disk, the velocity is
%set to 0. The function then generates a set of Nev random source positions
%inside the disk.
%
%input:
%    Nev:    number of events
%
%output:
%    Vh:      the velocity structure, given by a scaled "peaks" function,
%             and set to 0 outside a disk of radius 2.5.
%    E:       the anisotropy structure, given by a scaled "peaks" function.
%    h:       the grid spacing (=0.2);
%    sensors: array of sensor positions
%    events:  array of event positions


%% generate grid with Vh and E fields

%spacing
h=.2;

%number of points in each direction
Nx=28;
Ny=1;
Nz=28;

%Coordinates
x = h*(0:Nx-1);
z = h*(0:Nz-1);

%initialise V and epsilon
Vh = reshape(3 + peaks(Nx)/30, [Nx Ny Nz]);

XX = meshgrid(x,z);
ZZ = meshgrid(z,x)';
x_center = x(end)/2;
z_center = z(end)/2;
RR = sqrt((XX-x_center).^2 + (ZZ-z_center).^2);
ind_out = find(RR>2.8);
[Iout,Jout] = ind2sub([Nx Nz],ind_out);

for k=1:length(Iout)
    Vh(Iout(k),:,Jout(k)) = 0.0;
end

E = reshape(peaks(Nx)/80, [Nx Ny Nz]);


%% generate sensors and events

%radius positions of sensors:
r_sens = 2.5;
%azimuths of sensors:
q_sens = pi/4 * (0:7);
%build sensor locations matrix:
sensors = repmat([x_center  0  z_center  0],8,1) + ...
    r_sens.*[cos(q_sens')  0*q_sens'  sin(q_sens')  0*q_sens'];

%pick random radii for events between 0 and 2.5
r_evt = rand(Nev, 1)*2.5;
%pick random azimuths for events between 0 and 2pi
q_evt = rand(Nev, 1)*2*pi;
%build event locations matrix
events = [r_evt.*cos(q_evt)+2.5+h  zeros(Nev,1)  r_evt.*sin(q_evt)+2.5+h  rand(Nev,1)*4];
