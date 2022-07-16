ctVal1 = [10.84, 13.677, 16.996, 20.717, 24.165, 27.607, 30.911, 35.473];
ctVal2=[10.11, 13.87, 17.311, 21.307, 24.783, 28.337, 32.019,35.321];

ctVal=[ctVal1, ctVal2];

vload = [2200, 220, 22, 2.2, 0.22, 0.022, 0.0022, 0.00022]; 
 
vload=[vload, vload];
    
[a]=fit(ctVal.',log10(vload).','poly1');

mismatchratio_norm='L1';

A=[1,0,0,0,0,1,0,0,1,0,1,1,0,0,1,1,1,1,1,0,0,0,1,1,0,1,1,1,0,1,0;...
   0,1,0,0,0,0,1,0,0,1,0,1,1,0,0,1,1,1,1,1,0,0,0,1,1,0,1,1,1,0,1;...
   0,0,1,0,0,1,0,1,1,0,0,1,1,1,1,1,0,0,0,1,1,0,1,1,1,0,1,0,1,0,0;...
   0,0,0,1,0,0,1,0,1,1,0,0,1,1,1,1,1,0,0,0,1,1,0,1,1,1,0,1,0,1,0;...
   0,0,0,0,1,0,0,1,0,1,1,0,0,1,1,1,1,1,0,0,0,1,1,0,1,1,1,0,1,0,1;]; 

A=[A;zeros(1,31)];
A(6,[1,2,4,5,7,10,11,18,19,22,26,28,30,31])=1;

b=[1,
2,
4,
5,
7,
10,
11,
17,
18,
19,
22,
26,
28,
30,
31];

A=[A; zeros(size(b,1), 31)];
for i=7:size(A,1)
A(i,b(i-6))=1;
end




%N=31, run 3
 
 A=[A;A];
 

%y=[16.931, 16.234, 16.817, 40, 40, 16.909, 16.202, 16.783, 40, 40];   %measured Ct values       %
y=[35.068
35.107
40
35.021
34.031
34.021
40
40
40
40
40
40
40
40
31.523
40
40
32.053
40
40
40
34.234
34.526
40
34.697
34.123
34.321
40
40
40
40
40
40
40
40
30.886
40
40
32.568
40
40
40].';



measured_load=zeros(size(y,2),1);
pooload_LB=zeros(size(y,2),1);
pooload_UB=zeros(size(y,2),1);

Ct_tolerance=2; %tolerance in Ct value inaccuracy

for i=1:size(y,2)

    if (y(1,i) >= 37.5)
    
        measured_load(i)=0;
        pooload_LB(i)=0;
        pooload_UB(i)=0;
        
    else

        measured_load(i)=10^a(y(1,i));
        pooload_LB(i)=10^a(y(1,i)+Ct_tolerance);
        pooload_UB(i)=10^a(y(1,i)-Ct_tolerance);
        
    end

end


for i=1:size(A,1)

  if (sum(A(i,:))>1 )   
       A(i,:)=(1/4)*A(i,:);
  end
  
end


MixMat=A;


sampNum=size(A,2);


%% One-by-one minimization-maximization decoding
fprintf('Performing obo-mm decoding...\n'); 

tic; 
    
%     poolVloadTmp = poolVload{iTria};

    xLbTmp = zeros(sampNum,1);
    xUbTmp = zeros(sampNum,1); 
    MixMat =A;
   
    
    for iSamp=1:sampNum
        
        % minimization
        cvx_begin quiet
            variable x(sampNum,1)
            minimize(x(iSamp))
            subject to
                -MixMat*x <= - pooload_LB;
                MixMat*x <= pooload_UB;
                -x <= 0;
        cvx_end
        
        xLbTmp(iSamp) = x(iSamp); 
        minStatus = cvx_status;
        
        
        % maximization
        cvx_begin quiet
            variable x(sampNum,1)
            minimize(-x(iSamp))
            subject to
                -MixMat*x <= -pooload_LB;
                MixMat*x <= pooload_UB;
                -x <= 0; 
        cvx_end
        
        xUbTmp(iSamp) = x(iSamp);
        maxStatus = cvx_status;
        
    end
    
    xLb = xLbTmp;
    xUb = xUbTmp;
    
    fprintf('Trial: minimization status %s, maximization status %s.\n',...
           minStatus,maxStatus);
    



tEnd = toc;
fprintf('Elapsed time for obo-mm decoding %8.2e seconds.\n',tEnd);



 poolVload=measured_load;
 
 [~,nSamp] = size(MixMat);
 poolPos = find(poolVload > 0);
 poolNeg = find(poolVload == 0);
% 
 MaxIter = 3;
 tol = 1e-6;
% 
 
 x = (xLb+xUb)/2;
 z = poolVload;
 
 for Iter=1:MaxIter
     
     x_prev = x;
     
     switch mismatchratio_norm
         case 'L1'
             % L1 norm
             cvx_begin quiet
                 variable x_cvx(nSamp,1)
                 minimize(norm((poolVload(poolPos,1) - MixMat(poolPos,:)*x_cvx) ./ z(poolPos,1),1))
                 subject to
                     MixMat(poolNeg,:)*x_cvx == 0;
                     - x_cvx <= 0;
             cvx_end
             
             
%             
         case 'L2'
            % L2 norm
            cvx_begin quiet
                variable x_cvx(nSamp,1)
                minimize(norm((poolVload(poolPos,1) - MixMat(poolPos,:)*x_cvx) ./ z(poolPos,1),2))
                subject to
                    MixMat(poolNeg,:)*x_cvx == 0;
                    - x_cvx <= 0;
            cvx_end
            
            
    end
    
    x = x_cvx;
    
    % update y
    z=MixMat*x_cvx; % without updating z
%     
    if norm(x-x_prev,2) < tol || norm(poolVload-MixMat*x,2) < tol
        break;
    end
    
end














