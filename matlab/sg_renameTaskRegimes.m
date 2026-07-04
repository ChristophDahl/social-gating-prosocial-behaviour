function tasks = sg_renameTaskRegimes(tasks)
%SG_RENAMETASKREGIMES Compatibility function for legacy task labels.
%
% Current task presets already use structural task labels. This function is
% retained so that older scripts still run. It replaces legacy labels if they
% are encountered and otherwise returns the input unchanged.

if istable(tasks)
    names = string(tasks.Name);
    names(names == "marmoset_like_provisioning")     = "low_competition_provisioning";
    names(names == "false_positive_motor_bias")      = "apparatus_bias_no_benefit";
    names(names == "collaboration_partner_reliable") = "reliable_partner_collaboration";
    tasks.Name = cellstr(names);
    return;
end

for k = 1:numel(tasks)
    if isfield(tasks, 'name')
        fieldName = 'name';
    elseif isfield(tasks, 'Name')
        fieldName = 'Name';
    else
        error('Task structure has neither name nor Name field.');
    end

    switch string(tasks(k).(fieldName))
        case "marmoset_like_provisioning"
            tasks(k).(fieldName) = 'low_competition_provisioning';
        case "false_positive_motor_bias"
            tasks(k).(fieldName) = 'apparatus_bias_no_benefit';
        case "collaboration_partner_reliable"
            tasks(k).(fieldName) = 'reliable_partner_collaboration';
    end
end
end
