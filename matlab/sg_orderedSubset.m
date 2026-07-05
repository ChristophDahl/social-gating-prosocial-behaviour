function [keep, labels] = sg_orderedSubset(order, allLabels, observed)
%SG_ORDEREDSUBSET Return ordered entries and matching labels present in data.

order = string(order);
observed = string(observed);
mask = ismember(order, observed);
keep = order(mask);
labels = allLabels(mask);
end
