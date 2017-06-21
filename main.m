% import package
import YMicroscope.*
m = Microscope();

%%
clc
ui = UIViewController(m);

%%
% temporary for taking live record
ui = UIViewControllerRecord(m);
