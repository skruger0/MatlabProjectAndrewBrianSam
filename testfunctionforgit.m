function [ output ] = testfunctionforgit()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
name = 'brian'
namecell = ['b','r','i','a','n'];
output = size(namecell);
for i = 1:5
    output(i) = namecell(i);
end
end
