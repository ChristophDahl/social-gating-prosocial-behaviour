function llTbl = sg_logLikelihoodVariants(data, parameterRegimes, baseParams)
%SG_LOGLIKELIHOODVARIANTS Model-ablation likelihood scores for simulated data.
%
% This function is retained under its original name for compatibility, but the
% analysis should be interpreted as a structural ablation / predictive recovery
% check, not as a fitted empirical nested-model comparison. The variants use
% the same parameter values with selected terms removed; they are not refitted
% by maximum likelihood.

modelVariants = {'bias_only', 'self_interest', 'competition', ...
                 'relationship', 'full_social_gating'};

rows = [];
r = 0;

for iRegime = 1:numel(parameterRegimes)
    parameterRegime = parameterRegimes{iRegime};
    idxRegime = data.socialSystem == string(parameterRegime);
    D = data(idxRegime,:);
    pFull = sg_parameterPresetParams(baseParams, parameterRegime);

    for m = 1:numel(modelVariants)
        variant = modelVariants{m};
        p = applyVariant(pFull, variant);
        k = modelK(variant);

        ll = 0;
        for t = 1:height(D)
            pChoice = predictChoiceProb(D(t,:), p);
            pChoice = min(max(pChoice, p.epsProb), 1 - p.epsProb);
            if D.choiceHelp(t)
                ll = ll + log(pChoice);
            else
                ll = ll + log(1 - pChoice);
            end
        end

        r = r + 1;
        rows(r).socialSystem = string(parameterRegime); %#ok<AGROW>
        rows(r).parameterRegime = string(parameterRegime); %#ok<AGROW>
        rows(r).modelVariant = string(variant); %#ok<AGROW>
        rows(r).n = height(D); %#ok<AGROW>
        rows(r).kApprox = k; %#ok<AGROW>
        rows(r).logLikelihood = ll; %#ok<AGROW>
        rows(r).ablationICApprox = 2 * k - 2 * ll; %#ok<AGROW>
        rows(r).AICApprox = 2 * k - 2 * ll; %#ok<AGROW> % legacy column name
    end
end

llTbl = struct2table(rows);
end

function p = applyVariant(pFull, variant)
p = pFull;

switch variant
    case 'bias_only'
        p.wSelf = 0; p.wOther = 0; p.wJoint = 0; p.wCost = 0; p.wComp = 0;
        p.wRel = 0; p.wRecip = 0; p.wSol = 0;
    case 'self_interest'
        p.wOther = 0; p.wJoint = 0; p.wComp = 0; p.wRel = 0; p.wRecip = 0; p.wSol = 0;
    case 'competition'
        p.wOther = 0; p.wJoint = 0; p.wRel = 0; p.wRecip = 0; p.wSol = 0;
    case 'relationship'
        p.wOther = 0; p.wJoint = 0;
    case 'full_social_gating'
        % no change
    otherwise
        error('Unknown model variant: %s', variant);
end
end

function k = modelK(variant)
switch variant
    case 'bias_only'
        k = 2;
    case 'self_interest'
        k = 4;
    case 'competition'
        k = 5;
    case 'relationship'
        k = 8;
    case 'full_social_gating'
        k = 10;
    otherwise
        k = NaN;
end
end

function pHelp = predictChoiceProb(row, p)
% Recompute utility using stored trial-level variables. Using sg_computeUtility
% keeps the action-threshold rule identical to the simulation.
Uhelp = sg_computeUtility(row, p, row.pNeed, row.pAfford, row.cost, ...
    row.competition, row.relationship, row.reciprocity, true, row.pNeed);
UnoHelp = sg_computeUtility(row, p, row.pNeed, row.pAfford, row.cost, ...
    row.competition, row.relationship, row.reciprocity, false, row.pNeed);

pHelp = 1 ./ (1 + exp(-p.beta * (Uhelp - UnoHelp)));
end
