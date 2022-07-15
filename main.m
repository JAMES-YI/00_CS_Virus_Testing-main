function main(Params)
% This is the main function of the compressed sensing based virus detection
% (CSVT) system, and it accepts parameters from a graphic user interface.
%
% Created by JYI, 08/03/2020
%

%% Generate testing samples
% Params.InfModVal = InfModVal;
% Params.N = N;
% Params.Prob = Prob;
% Params.k = k;
% Params.lb = lb;
% Params.ub = ub;
% Params.InfSet = InfSet;
% Params.Samp_VStatus = Samp_VStatus;


% Test samples generation
Samp_VQuant = zeros(Params.N,1); 
Samp_VQuant(Params.InfSet,1) = (Params.ub-Params.lb)*rand(Params.k,1) + Params.lb;

% Save data
Samp_Data.Samp_VQuant = Samp_VQuant;
Samp_Data.Samp_VStatus = Params.Samp_VStatus;
Samp_Data.lb = Params.lb;
Samp_Data.ub = Params.ub;

save(Params.Samp_DataName,'Samp_Data')
fprintf('Test sample data have been saved in %s.\n',Params.Samp_DataName);


% fprintf('Virus load in test samples:\n'); Samp_VQuant
% fprintf('Infection status in test samples: \n'); Samp_VStatus
% fprintf('Test samples with infection:\n'); InfSet


end