function [ ] = myCompareperms( n )
% from this function, I concluded that this built-in function perms
%does not work above 20!


my_time_values = [];
% GSI_time_values = [];
number_of_elements = 1:n;
    for m = 1:n
        numberlist = number_of_elements;
        mytimestart = tic;
        my_sorted = perms(numberlist);
        mytime = toc(mytimestart);
        my_time_values = [my_time_values, mytime];


    %     GSItimestart = tic;
    %     GSI_sorted = GSISortElements(elementlist);
    %     GSItime = toc(GSItimestart);
    %     GSI_time_values = [GSI_time_values, GSItime];

    end
my_time_values;
plot(number_of_elements,my_time_values);
title('Comparison of times')
xlabel('number of elements')
ylabel('time')
end
