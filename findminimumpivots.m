function [ matrixofminimumpivots ] = findminimumpivots( matrixofdistances )
%create a matrix of minimum pivots

matrixofminimums = matrixofdistances;
matrixofminimumpivots = zeros(size(matrixofdistances));
n = length(matrixofdistances);
%keep track of minimums




for i = 1:n
    %min of each column
    [mincols, rowindexofmin] = min(matrixofminimums);
    %min of those values
    [minmin, colindexofminmin] = min(mincols);

    %set all of row and all of col of mimimum val to NaN
    matrixofminimums(:,colindexofminmin(1)) = NaN;
    matrixofminimums(rowindexofmin(colindexofminmin),:) = NaN;
    %set minmin val to Inf from NaN
    matrixofminimumpivots(rowindexofmin(colindexofminmin),colindexofminmin(1)) = matrixofdistances(rowindexofmin(colindexofminmin),colindexofminmin(1));
end



end

