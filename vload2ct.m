classdef vload2ct
% This file defines a vload2ct class for converting virus load to ct values.
% 
% Created by JYI, 08/25/2020
% Updated by JYI, 10/05/2020
% Updated by JYI, 11/03/2020
% Updated by JYI, 11/20/2020
% Updated by JYI, 06/27/2022
% 
%% Properties

properties(SetAccess=public)

    ctVal;
    vload;
    virusID; 
    func_fit = 0;
    Params;

end

%% Methods

methods
    
    function obj = vload2ct(virusID,Params)
        % Constructor
        % virusID: 'MHV1', or 'COVID-19', or 'MHV1_2'
        
        obj.virusID = virusID;
        obj.Params = Params;
        ut = utils();
        obj = ut.load_stdCurveData(obj);

    end
    
    function convertor = datafit(convertor)
        % Fit over data
        % - fit() only accepts column vector x, and column vector y
        
        convertor.func_fit = fit(log10(convertor.vload)',convertor.ctVal','poly1');
        
    end
    
    function ctVal = ctVal_prd(convertor,vload)
        % Predict the virus load for given ct values
        % - truncate ctVal into range [10,50]
        
        ctVal = convertor.func_fit(log10(vload));
        ctVal = max(10,min(ctVal,40));
        ind40 = find(ctVal==40);
        ctVal(ind40) = 50;
    end
    
end

end