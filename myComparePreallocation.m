function [ ] = myComparePreallocation( n )
% test preallocate vs concatenate


preallocate_time_values = [];
concatenate_time_values = [];
number_of_elements = 1:n;
for m = 1:n

    mytimestart = tic;
%    PREALLOCATE
    mycreatedarray = zeros([n 1]);
    for i = 1:n
        currentvalue = i+1;
        mycreatedarray(i) = currentvalue;
    end
    mytime = toc(mytimestart);
    preallocate_time_values = [preallocate_time_values, mytime];
    
    
    GSItimestart = tic;
    GSIcreatedarray = [];
    for j = 1:n
        currentvalue = j+1;
        GSIcreatedarray = [GSIcreatedarray, currentvalue];
    end
%    GSI_sorted = GSISortElements(elementlist);
    GSItime = toc(GSItimestart);
    concatenate_time_values = [concatenate_time_values, GSItime];

end
preallocate_time_values;
plot(number_of_elements,preallocate_time_values,'g',number_of_elements,concatenate_time_values,'r');
title('Comparison of times')
xlabel('number of elements')
ylabel('time')
end