classdef ct2vload
% 
% This file defines a class named ct2vload which convers ct values to virus load (ng/ul)
% via interpolation.
%
% Created by JYI, 08/25/2020
% Updated by JYI, 10/04/2020
% Updated by JYI, 10/26/2020
% Updated by JYI, 11/20/2020
% Updated by JYI, 12/29/2020
% Updated by JYI, 06/27/2022
% 
% 
%% Properties
properties(SetAccess=public)

    ctVal; vload; % for data fitting
    virusID;
    func_fit = 0;
    Params; % return from cinfig()

end


%% Methods

methods
    
    function obj = ct2vload(virusID,Params)
        % Constructor
        % - virusID: 'MHV1', or 'COVID-19'
        % - Params, return from config()
        
        obj.virusID = virusID;
        obj.Params = Params;
        ut = utils();
        obj = ut.load_stdCurveData(obj);
        
    end
    
    function obj = datafit(obj)
        % Fit over data
        % - fit() only accepts column vector x, and column vector y
        
        obj.func_fit = fit(obj.ctVal',log10(obj.vload)','poly1');
        
    end
    
    function vload = vload_prd(obj,ctVal)
        % Predict the virus load for given ct values
        % - ctVal, 1D array; ct values
        % - truncation is removed by JYI on 09/01/2020
        % - if ct Value greater than 50, set the virus load to be 0;
        %   
        
        samInd = find(ctVal<50);
        ctSam = ctVal(samInd);
        vload = zeros(size(ctVal)); 
        
        vloadSam = 10.^(obj.func_fit(ctSam));
        vload(samInd) = vloadSam;
    
    end
    
end

end


