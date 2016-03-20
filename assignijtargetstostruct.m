function [instructions] = assignijtargetstostruct(instructions,personnumber,spotnumber,i,j)
%put i_target and j_target into struct
n = length(personnumber);
for currentindex = 1:n
    instructions(personnumber(currentindex)).i_target = i(spotnumber(currentindex));
    instructions(personnumber(currentindex)).j_target = j(spotnumber(currentindex));
end

end

