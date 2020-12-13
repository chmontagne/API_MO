function [ fBm ] = mp_fm2d( maxLevel, sigma, H, Addition)
%MIDPOINTFM2D generates a 2D Fractal Brownian noise using the Random
%   Midpoint Displacement algorithm, with possibly the aid of the
%   Successive Random Addition algorithm.
%
%   maxLevel is the number of iteration that would be used.
%   sigma is the root of the variance of the Gaussian random numbers that
%       will be used.
%   H is the Hurst parameter.
%   Addition defines whether the aid of the Successive Random Addition
%       algorithm will be required.
%
%   Ver 1.0 04/04/10, by Pavel Yatvetsky
%       Based on the algorithm from "The Science of Fractal Images", page 100.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N = 2 ^ maxLevel;
delta = sigma;
fBm([1, N + 1], [1, N + 1]) = sigma * randn(2);
d = N / 2;

for stage = 1 : maxLevel
    
    %%% Type II
    
    delta = delta / (2 ^ (H / 2));
    
    x = d + 1 : 2 * d :N - d + 1;
    y = d + 1 : 2 * d : N - d + 1;
    fBm(x, y) = (fBm(x + d, y + d) + fBm(x + d, y - d)...
        + fBm(x - d, y + d) + fBm(x - d, y - d))...
        / 4 + delta * randn([length(x) length(y)]);
        
    if Addition
        x = 1 : 2 * d : N + 1;
        fBm(x, x) = fBm(x, x) + delta * randn(length(x));
    end
    
    %%% Type I
    
    delta = delta / (2 ^ (H / 2));
    
    x = d + 1 : 2 * d : N - d + 1;
    y = size(x);
    fBm(x, 1) = (fBm(x + d, 1) + fBm(x - d, 1) + fBm(x, d)) / 3 + delta * randn(y)';
    fBm(x, N + 1) = (fBm(x + d, N + 1) + fBm(x - d, N) + fBm(x, N + 1 - d)) / 3 + delta * randn(y)';
    fBm(1, x) = (fBm(1, x + d) + fBm(1, x - d) + fBm(d, x)) / 3 + delta * randn(y);
    fBm(N + 1, x) = (fBm(N + 1, x + d) + fBm(N + 1, x - d) + fBm(N + 1 - d, x)) / 3 + delta * randn(y);
    
    x = d + 1 : 2 * d : N - d + 1;
    y = 2 * d + 1 : 2 * d : N - d + 1;
    fBm(x, y) = (fBm(x + d, y) + fBm(x - d, y)...
        + fBm(x, y + d) + fBm(x, y + d))...
        / 4 + delta * randn([length(x) length(y)]);
    fBm(y, x) = (fBm(y + d, x) + fBm(y - d, x)...
        + fBm(y, x + d) + fBm(y, x + d))...
        / 4 + delta * randn([length(x) length(y)])';
        
    if Addition
        x = d + 1 : 2 * d : N - d + 1;
        fBm(x, x) = fBm(x, x) + delta * randn(length(x));
        x = 2 * d + 1 : 2 * d : N - d + 1;
        fBm(x, x) = fBm(x, x) + delta * randn(length(x));
    end
    
    d = d / 2;
end