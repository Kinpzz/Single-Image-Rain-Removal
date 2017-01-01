function [ output ] = rescale( input )
%RESCALE Summary of this function goes here
%   Detailed explanation goes here
    mx = max(input(:));
    mn = min(input(:));
    output = (input-mn)/(mx-mn);
end

