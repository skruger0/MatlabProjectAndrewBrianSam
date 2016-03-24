function [allfoundrowinorder,allfoundcolumninorder] = ...
    findcurrentlocationofbandmembers(initial_formation, n_bandmembers)
% find specific location of every band member up to the total number of
% band members
% put their i and j values in two column arrays
allfoundrowinorder = zeros([n_bandmembers,1]);
allfoundcolumninorder = zeros([n_bandmembers,1]);
for currentfindnumber = 1:n_bandmembers
    [currentfoundrow currentfoundcolumn] = find(initial_formation == currentfindnumber);
    allfoundrowinorder(currentfindnumber) = currentfoundrow;
    allfoundcolumninorder(currentfindnumber) = currentfoundcolumn;
end


end

