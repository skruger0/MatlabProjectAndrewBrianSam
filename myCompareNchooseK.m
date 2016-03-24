function [] = myCompareNchooseK(n)
% from this function, I concluded that this built-in function nchoosek does
% not take that long for as many band members as we throw at it up to I
% tested 180 which is the number of band members in
%fullscale_bridge_to_train_initial


my_time_values = [];
% GSI_time_values = [];
number_of_elements = 1:n;
for m = 1:n
    numberlist = randperm(n);
    mytimestart = tic;
    my_sorted = nchoosek(numberlist,2);
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
