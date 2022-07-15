function [ctVal,vload]= loadStdCurveData()
% This file loads the standard curve data for interpolation over ct value
% and virus load.
%
% Created by JYI, 10/05/2020
%
%%
fID = 'Data/MHV1 Pooled Testing Exp 1 Decoded Results with Actual_with_new_standard_curve.xlsx';
stID = 'Sheet1';
ctRg1 = 'AL19:AL26';
ctRg2 = 'AO19:AO32';
vlRg1 = 'AI19:AI26';
vlRg2 = 'AQ19:AQ32';

ctVal1 = xlsread(fID,stID,ctRg1);
ctVal2 = xlsread(fID,stID,ctRg2);
ctVal = [ctVal1; ctVal2];

vload1 = xlsread(fID,stID,vlRg1);
vload2 = xlsread(fID,stID,vlRg2);
vload = [vload1; vload2];
end