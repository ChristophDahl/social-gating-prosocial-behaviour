function tasks = sg_taskPresets()
%SG_TASKPRESETS Task-preset definitions for the social-gating model.
%
% Each row describes independently specified task variables. These variables
% are inputs to the model, not inferred from whether helping occurs.
%
% Version 3 makes the actor-benefit distinction explicit:
%   expectedSelfBenefit  = actor's predicted direct benefit from the help action;
%   expectedOtherBenefit = actor's predicted benefit to the recipient;
%   jointBenefit         = predicted non-additive joint payoff;
%   actualOtherBenefit   = realised recipient benefit if the help action is chosen;
%   actualSelfBenefit    = realised direct actor benefit before subtracting cost.
%
% The realised net actor outcome is computed trial-wise in sg_simulateTrial as:
%   actualSelfDelta = actualSelfBenefit - sampledCost.
%
% This prevents low-cost recipient-benefiting actions from being treated as
% self-benefiting unless a direct actor benefit has been specified.

names = { ...
    'instrumental_reaching'; ...
    'visible_tool_transfer'; ...
    'hidden_tool_transfer'; ...
    'food_token_randomised'; ...
    'food_token_fixed_position'; ...
    'apparatus_bias_no_benefit'; ...
    'low_competition_provisioning'; ...
    'high_cost_help'; ...
    'dominance_risk_help'; ...
    'reliable_partner_collaboration'};

% Columns:
% visibility, solicitation, goalTransparency, affordanceClarity, familiarity,
% occlusion, cost, competition, relationship, reciprocity,
% expectedSelfBenefit, expectedOtherBenefit, jointBenefit, motorBiasHelp,
% actualOtherBenefit, actualSelfBenefit, isCollaborative.
%
% Note that non-collaborative helping tasks generally have no direct actor
% benefit. They may still be chosen by non-social controls when cost is very
% low or when motor/apparatus bias is strong, but recipient benefit no longer
% enters the actor's self-payoff term.
X = [ ...
    0.95 0.70 0.90 0.92 0.82 0.05 0.10 0.05 0.35 0.10 0.00 0.90 0.00 0.00 0.90 0.00 0; ... % instrumental reaching
    0.96 0.75 0.90 0.90 0.78 0.04 0.14 0.05 0.35 0.12 0.00 0.88 0.00 0.00 0.88 0.00 0; ... % visible tool transfer
    0.25 0.65 0.45 0.45 0.58 0.75 0.14 0.05 0.35 0.12 0.00 0.82 0.00 0.00 0.82 0.00 0; ... % hidden tool transfer
    0.45 0.18 0.42 0.55 0.55 0.25 0.05 0.55 0.15 0.05 0.00 0.65 0.00 0.00 0.65 0.00 0; ... % food token randomised
    0.45 0.18 0.42 0.50 0.55 0.25 0.05 0.55 0.15 0.05 0.00 0.65 0.00 -0.20 0.65 0.00 0; ... % food token fixed position
    0.35 0.00 0.25 0.35 0.55 0.35 0.02 0.00 0.00 0.00 0.00 0.00 0.00 2.25 0.00 0.00 0; ... % apparatus bias, no benefit
    0.66 0.20 0.62 0.65 0.70 0.12 0.08 0.10 0.45 0.15 0.00 0.75 0.00 0.00 0.75 0.00 0; ... % low-competition provisioning
    0.96 0.55 0.90 0.92 0.82 0.04 0.80 0.15 0.35 0.10 0.00 1.00 0.00 0.00 1.00 0.00 0; ... % high-cost help
    0.86 0.60 0.85 0.82 0.76 0.08 0.55 0.75 0.25 0.10 0.00 0.92 0.00 0.00 0.92 0.00 0; ... % dominance-risk help
    0.86 0.40 0.80 0.85 0.80 0.07 0.25 0.10 0.50 0.20 0.75 0.75 0.80 0.00 0.75 0.75 1];    % reliable collaboration

tasks = table(names, X(:,1), X(:,2), X(:,3), X(:,4), X(:,5), X(:,6), ...
    X(:,7), X(:,8), X(:,9), X(:,10), X(:,11), X(:,12), X(:,13), ...
    X(:,14), X(:,15), X(:,16), logical(X(:,17)), ...
    'VariableNames', {'Name','visibility','solicitation','goalTransparency', ...
    'affordanceClarity','familiarity','occlusion','cost','competition', ...
    'relationship','reciprocity','expectedSelfBenefit','expectedOtherBenefit', ...
    'jointBenefit','motorBiasHelp','actualOtherBenefit','actualSelfBenefit', ...
    'isCollaborative'});
end
