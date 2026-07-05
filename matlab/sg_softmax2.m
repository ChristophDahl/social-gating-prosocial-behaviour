function pFirst = sg_softmax2(uFirst, uSecond, beta)
%SG_SOFTMAX2 Probability of choosing first of two options.
% Uses a numerically stable two-action softmax.
if nargin < 3
    beta = 1;
end
x1 = beta * uFirst;
x2 = beta * uSecond;
m = max(x1, x2);
e1 = exp(x1 - m);
e2 = exp(x2 - m);
pFirst = e1 ./ (e1 + e2);
end
