function [ matrixofdistances ] = findmatrixofdistances(...
    firstrowindices,firstcolindices,secondrowindices,secondcolindices)
%creates matrix of distances
n = length(firstrowindices);

%empty matrices
%overallmatrix = zeros([n n]);
cumulativecurrentspotarray = zeros([n n]);

%lets go!
firstspot = 1;
finalspot = n;
firstperson = 1;
finalperson = n;

for currentspot = firstspot:finalspot
    %cumpersonarray resets to empty every new spot
    cumulativecurrentpersonarray = zeros([n 1]);
    
    currentspotrowindex = firstrowindices(currentspot);
    currentspotcolindex = firstcolindices(currentspot);
    for currentperson = firstperson:finalperson
        currentpersonrowindex = secondrowindices(currentperson);
        currentpersoncolindex = secondcolindices(currentperson);
        %calculate distance from current person to current spot
        % dist = sqrt( (x1-x1)^2 + (y1-y2)^2 )
        currentdistance = sqrt( (currentspotrowindex-currentpersonrowindex)^2 + (currentspotcolindex-currentpersoncolindex)^2 );
        %append currentdistance to the cumulativecurrentperson array
        %cumulativecurrentperson array will be a mx1 array
        cumulativecurrentpersonarray(currentperson) = currentdistance;
    end
    %does cumulativepersonarray work? --- it does!
    cumulativecurrentpersonarray;
    
    %append cumulativecurrentspot to the overallmatrix array
    %overallmatrix array will be a m*n array
    cumulativecurrentspotarray(:,currentspot) = cumulativecurrentpersonarray;
end

%does cumulativepersonarray work? --- it does
cumulativecurrentspotarray;
matrixofdistances = cumulativecurrentspotarray;

end

