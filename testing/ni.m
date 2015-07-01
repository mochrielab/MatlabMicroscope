clear all; clc;
%%
nidaq=daq.createSession('ni');
nidaq2=daq.createSession('ni');
% nidaq.addDigitalChannel('Dev1','port0/line2','OutputOnly');
% 
% %%
% nidaq.outputSingleScan(1)
% %%
% nidaq.outputSingleScan(0)
% 
% %%
% nidaq.addDigitalChannel('Dev1','port0/line1','OutputOnly');

%%
ch = nidaq2.addDigitalChannel('Dev1', 'Port0/Line1:2', 'OutputOnly');

%%
nidaq.outputSingleScan([0 1 0]); %white LED off/red LED on

%%
nidaq.outputSingleScan([1 0 0]); %white LED on/red LED off

%%
nidaq.outputSingleScan([0 0 0]); %white LED off/red LED off

%%
nidaq.outputSingleScan(flip(decimalToBinaryVector(2),2));