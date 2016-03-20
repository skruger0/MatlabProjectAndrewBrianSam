function [ instructions ] = findandassigndirection(instructions, n_bandmembers,allfoundrowinorder,allfoundcolumninorder)
%find and assign direction
%   
for currentindex = 1:n_bandmembers
    target_i = instructions(currentindex).i_target
    target_j = instructions(currentindex).j_target
    initial_i = allfoundrowinorder(currentindex)
    initial_j = allfoundcolumninorder(currentindex)
    %i
    if target_i > initial_i
        direction1 = 'E';
    elseif target_i < initial_i
        direction1 = 'W';
    elseif target_i == initial_i
        direction1 = '';
    else
        direction1 = '.';
        instructions(currentindex).i_target = initial_i;
        
    end
    %j
    if target_j > initial_j
        direction2 = 'N';
    elseif target_j < initial_j
        direction2 = 'S';
    elseif target_j == initial_j
        direction2 = '';
    else
        direction2 ='.'
        instructions(currentindex).j_target = initial_j;
    end
    overalldirection = strcat(direction1,direction2);
    
    if strcmpi(overalldirection,'..')
        overalldirection = '.';
    end
    instructions(currentindex).direction = overalldirection;
end



end

