function y = sg_sigmoid(x)
%SG_SIGMOID Logistic function with stable behaviour for large inputs.
y = 1 ./ (1 + exp(-x));
end
