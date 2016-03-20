function [ output ] = testfunctionforgit()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
name = 'brian';
output = zeros(size(name));
for i = 1:5
    output(i) = name(i);
end
end
