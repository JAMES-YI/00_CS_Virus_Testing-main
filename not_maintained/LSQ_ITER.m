    function vload = LSQ_ITER(data,Params)
        % Perform least square for decoding virus load
        %
        % input arguments
        % - data
        % - Params
        %
        % Created by JYI, 08/12/2020
        % Updated by JYI, 06/24/2022
        % - this solver will no longer be maintained
        %
        %% 

        sampNumLoc = data.sampNum; 
        sampPosLoc = data.sampPos;
        poolVloadLoc = data.poolVload; 
        MixMatLoc = data.MixMat;

        vload = zeros(obj.sampNum,1);
        Asub = MixMatLoc;
        b = poolVloadLoc; 

        cvx_begin quiet

            variable vload_sub(length(sampPosLoc),1)
            minimize(norm(Asub*vload_sub-b,2))
            subject to 
                -vload_sub <= 0

        cvx_end

        vload(sampPosLoc) = vload_sub;

    end