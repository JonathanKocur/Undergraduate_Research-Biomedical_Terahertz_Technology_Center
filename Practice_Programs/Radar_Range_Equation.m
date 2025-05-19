% This program is a simple calculation of the Radar Range equation. The
% below variables are arbitrary and can have anything set

clc;
clear all;
close all;

PowerT = 1;
PowerR = 1;
Gain = 1;
WavelengthT = 1;
SphereR = 1;

Range = ((PowerT*Gain^2*WavelengthT^2*pi*SphereR^2)/(PowerR*(4*pi)^3))^(1/4);