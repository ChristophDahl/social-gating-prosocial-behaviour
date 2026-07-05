function summaryTbl = sg_summariseResults(data)
%SG_SUMMARISERESULTS Summarise simulated behaviour by task and parameter preset.

tasks = unique(data.task, 'stable');
systems = unique(data.socialSystem, 'stable');

rows = [];
r = 0;

for i = 1:numel(tasks)
    for j = 1:numel(systems)
        idx = data.task == tasks(i) & data.socialSystem == systems(j);
        if ~any(idx)
            continue;
        end
        T = data(idx,:);
        r = r + 1;
        rows(r).task = tasks(i); %#ok<AGROW>
        rows(r).socialSystem = systems(j); %#ok<AGROW>
        rows(r).n = height(T); %#ok<AGROW>
        rows(r).choiceHelpRate = mean(T.choiceHelp); %#ok<AGROW>
        rows(r).helpingRate = mean(T.helping); %#ok<AGROW>
        rows(r).prosocialRate = mean(T.prosocial); %#ok<AGROW>
        rows(r).costlyOtherBenefitRate = mean(T.costlyOtherBenefit); %#ok<AGROW>
        rows(r).strictAltruismLikeRate = mean(T.strictAltruismLike); %#ok<AGROW>
        rows(r).collaborationLikeRate = mean(T.collaborationLike); %#ok<AGROW>
        rows(r).falsePositiveRate = mean(T.falsePositive); %#ok<AGROW>
        rows(r).meanExpectedSelfBenefit = mean(T.expectedSelfBenefit); %#ok<AGROW>
        rows(r).meanExpectedOtherBenefit = mean(T.expectedOtherBenefit); %#ok<AGROW>
        rows(r).meanActualSelfBenefit = mean(T.actualSelfBenefit); %#ok<AGROW>
        rows(r).meanActualSelfDelta = mean(T.actualSelfDelta); %#ok<AGROW>
        rows(r).meanPNeed = mean(T.pNeed); %#ok<AGROW>
        rows(r).meanPAfford = mean(T.pAfford); %#ok<AGROW>
        rows(r).meanGate = mean(T.gate); %#ok<AGROW>
        rows(r).meanPHelp = mean(T.pHelp); %#ok<AGROW>
        rows(r).needFailureRate = mean(T.needFailure); %#ok<AGROW>
        rows(r).affordanceFailureRate = mean(T.affordanceFailure); %#ok<AGROW>
        rows(r).costCompetitionOverrideRate = mean(T.costCompetitionOverride); %#ok<AGROW>
        rows(r).valuationNoHelpRate = mean(T.valuationNoHelp); %#ok<AGROW>
        rows(r).falsePositiveBiasRate = mean(T.falsePositiveBias); %#ok<AGROW>
        rows(r).successRate = mean(T.success); %#ok<AGROW>
    end
end

summaryTbl = struct2table(rows);

% Human-readable descriptions for manuscript-facing outputs. The MATLAB
% variable name remains camelCase, but the intended label is
% "costly other-benefit rate".
if any(strcmp(summaryTbl.Properties.VariableNames, 'costlyOtherBenefitRate'))
    if isempty(summaryTbl.Properties.VariableDescriptions)
        summaryTbl.Properties.VariableDescriptions = repmat({''}, 1, width(summaryTbl));
    end
    idxDesc = find(strcmp(summaryTbl.Properties.VariableNames, 'costlyOtherBenefitRate'), 1, 'first');
    summaryTbl.Properties.VariableDescriptions{idxDesc} = ...
        'costly other-benefit rate: recipient benefits while actor pays action cost';
end

end
