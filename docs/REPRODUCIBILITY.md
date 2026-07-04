# Reproducibility notes

## Random seed

The default manuscript run uses:

```matlab
seeds = 11;
```

inside `main_social_gating_simulation.m`.

For a simulation-stability check, replace this with a vector, for example:

```matlab
seeds = 11:60;
```

The manuscript figures should be regenerated after changing the seed vector.

## Path handling

The main script infers the project root from its own location. The intended layout is:

```text
<repo>/matlab/main_social_gating_simulation.m
<repo>/results/
<repo>/figures/
```

Do not hard-code local paths such as `I:\...` in the public repository.

## Interpretation of model-ablation scores

`sg_logLikelihoodVariants.m` is retained under its original name for compatibility. The output should be interpreted as a structural ablation / predictive-recovery check using simulated data, not as a fitted empirical likelihood comparison.

## Terminology

The manuscript uses **prosocial behaviour** as the broad domain. Some code variables retain older names such as `helpingRate`, `choiceHelpRate`, and `costlyOtherBenefitRate`. These names should not be changed unless all dependent figure scripts, tables, and manuscript references are changed at the same time.
