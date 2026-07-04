# MATLAB file manifest

This repository uses the MATLAB files that already exist in the project ZIP. The public repository should keep the original function names, because the manuscript and figure scripts depend on the current output field names.

## Top-level execution

| File | Role |
|---|---|
| `main_social_gating_simulation.m` | Runs the full simulation, summary generation, counterfactual analysis, model-ablation scoring, and default diagnostic plotting. |
| `render_main_figures_only.m` | Renders the two main manuscript figures from existing CSV outputs. |
| `make_Fig1_helping_need_sensitivity.m` | Renders Fig. 1: realised recipient-benefiting action / helping profile and counterfactual need sensitivity. |
| `make_Fig2_failure_decomposition.m` | Renders Fig. 2: failure decomposition averaged across parameter regimes. |
| `make_FigS1_failure_decomposition_by_system.m` | Renders Online Resource 1, Fig. S1 / `SupFig1`: failure decomposition by task and parameter regime. |

## Core model and simulation functions

| File | Role |
|---|---|
| `sg_defaultParams.m` | Baseline parameter values. |
| `sg_taskPresets.m` | Task-regime definitions. |
| `sg_runSimulation.m` | Runs all trials across task regimes and parameter regimes. |
| `sg_simulateTrial.m` | Simulates one trial and assigns realised outcome labels. |
| `sg_computeUtility.m` | Computes help/no-help utility for the social-gating architecture. |
| `sg_summariseResults.m` | Summarises trial-level data by task and parameter regime. |
| `sg_counterfactualNeedEffect.m` | Computes counterfactual need-sensitivity summaries. |
| `sg_logLikelihoodVariants.m` | Computes model-ablation / predictive-recovery scores. |

## Configuration and helper functions

| File | Role |
|---|---|
| `sg_plotConfig.m` | Manuscript-facing task order, labels, and figure configuration. |
| `sg_plotResults_v2.m` | Default diagnostic plotting called by the main simulation script. |
| `sg_parameterRegimeParams.m` | Compatibility wrapper for parameter-regime settings. |
| `sg_getParameterRegimeParams.m` | Compatibility wrapper for parameter-regime settings. |
| `sg_speciesParams.m` | Legacy name retained for compatibility; these are parameter regimes, not species simulations. |
| `sg_sigmoid.m` | Logistic helper. |
| `sg_softmax2.m` | Two-action softmax helper. |
| `sg_pickBinary.m` | Bernoulli helper. |
| `sg_addParameterRegimes.m` | Compatibility helper for adding parameter-regime information. |
| `sg_renameTaskRegimes.m` | Compatibility helper for older task labels. |
| `sg_orderedSubset.m` | Ordering helper for labels. |
| `sg_applyPubStyle.m` | Figure-style helper retained for compatibility. |
| `sg_pubFigureConfig.m` | Figure-style configuration retained for compatibility. |
| `sg_exportFigure.m` | Figure-export helper retained for compatibility. |

## Omitted from the clean repository

The following development files are not needed for reproduction of the submitted manuscript and should not be placed in the public repository unless explicitly archived separately:

| File | Reason |
|---|---|
| `render_supplement_figures.m` | Old broader supplementary-figure pipeline; the supplement now contains only `SupFig1`. |
| `sg_plotResults.m` | Older simple plotting function superseded by `sg_plotResults_v2.m` and dedicated figure scripts. |
| `README*.txt` | Superseded by `README.md` and documentation in `docs/`. |
