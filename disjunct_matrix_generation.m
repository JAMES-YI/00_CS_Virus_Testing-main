function [A,colWt,rowWt] = disjunct_matrix_generation(varargin)
% This function will generate a d-disjunct binary matrix of size
% nchoose(n,d) by nchoosek(n,k), and with nchoosek(k,d) in each column,
% and nchoosek(n-d,k-d) 1 in each row.
%
% input arguments
% - 1st, d,
% - 2nd, k
% - 3rd, n
%
% This function requires n >= k >= d, and the algorihm is from
% A. Macula. A simple construction of d-disjunct matrices with certain
% constant weights, Discrete Mathematics 162: 311-312, 1996.
%
% Created by JYI, 09/17/2020
%
%% 

if nargin==0
    d = 2;
    k = 4;
    n = 6;
else
    d = varargin{1};
    k = varargin{2};
    n = varargin{3};
end

%%

rowSets = nchoosek(1:n,d);
colSets = nchoosek(1:n,k);
colWt = nchoosek(k,d);
rowWt = nchoosek(n-d,k-d);

rowNum = size(rowSets,1);
colNum = size(colSets,1);
A = zeros(rowNum,colNum);

% Exhaustive search
for iRow=1:rowNum
    for iCol=1:colNum
        if all(ismember(rowSets(iRow,:),colSets(iCol,:))) == 1
            A(iRow,iCol) = 1;
        end
    end
end

% More efficient search




end