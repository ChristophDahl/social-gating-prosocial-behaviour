function b = sg_pickBinary(p)
%SG_PICKBINARY Draw a Bernoulli random variable.
p = max(0, min(1, p));
b = rand() < p;
end
