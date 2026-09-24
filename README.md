# Prosocial Behaviour in a Socially Gated Action-Selection Framework

MATLAB code accompanying the manuscript:

**Prosocial Behaviour in a Socially Gated Action-Selection Framework: A Computational Reframing**

The repository implements a generative computational framework in which task information, recipient need, affordance recognition, relationship context, costs, competition, payoffs, and response biases jointly contribute to action selection. Behavioural labels are assigned to the resulting action–outcome profiles; they are not treated as directly observed psychological mechanisms.

The revised code additionally includes:

- prospective architecture-derived predictions;
- a need × affordance diagnostic;
- a relationship × social-gate diagnostic;
- a need-dependent cost-threshold diagnostic;
- Bayesian expected-information-gain optimisation of candidate experiments;
- a constrained matched-contrast design that directly targets the need × affordance and relationship × gate interactions.

## Repository structure

```text
social-gating-prosocial-behaviour/
├── README.md
├── LICENSE
├── CITATION.cff
├── .gitignore
├── .gitattributes
├── matlab/
│   ├── main_social_gating_simulation.m
│   ├── render_main_figures_only.m
│   ├── make_Fig1_helping_need_sensitivity.m
│   ├── make_Fig2_failure_decomposition.m
│   ├── make_Fig3_prospective_predictions.m
│   ├── make_FigS1_failure_decomposition_by_system.m
│   ├── sg_prospectivePredictions.m
│   ├── sg_computeUtility.m
│   ├── sg_counterfactualNeedEffect.m
│   ├── sg_*.m
│   └── design_optimization/
│       ├── main_optimize_prosocial_design_stageB.m
│       ├── sg_designConfig_stageB.m
│       ├── sg_designCandidateModels_stageB.m
│       ├── sg_designCandidateConditions_stageB.m
│       ├── sg_designSampleParameters_stageB.m
│       ├── sg_designPredictSamples_stageB.m
│       ├── sg_designRobustSingleEIG_stageB.m
│       ├── sg_designBuildPool_stageB.m
│       ├── sg_designGreedyRobustEIG_stageB.m
│       ├── sg_designSummariseStageB.m
│       ├── sg_designSelectionStability_stageB.m
│       ├── sg_designPlotStageB.m
│       ├── sg_designConstrainedTarget_stageB.m
│       ├── sg_designSummariseConstrained_stageB.m
│       ├── sg_designPlotConstrainedStageB.m
│       └── make_stageB_final_figure.m
├── scripts/
│   └── run_all.m
├── docs/
│   ├── MATLAB_FILE_MANIFEST.md
│   ├── OUTPUTS.md
│   └── REPRODUCIBILITY.md
├── results/
│   └── design_optimization_stageB/
└── figures/
    ├── supplement/
    └── design_optimization_stageB/
```

## MATLAB requirements

The code uses standard MATLAB numerical, table, graphics, random-number, and file-I/O functionality. No external toolbox is required by the core generative simulation.

The Stage-B design optimisation uses Monte Carlo evaluation and can therefore be substantially slower than the core simulation.

## Core manuscript simulation

From the repository root:

```matlab
addpath(genpath('matlab'))
main_social_gating_simulation
```

This generates the principal simulation outputs, model-ablation summaries, counterfactual need-sensitivity outputs, and the prospective prediction tables.

The principal prospective outputs are:

```text
results/prospective_need_affordance.csv
results/prospective_relationship_gate.csv
results/prospective_cost_threshold.csv
results/prospective_prediction_summary.csv
```

The main figure renderer can then be run with:

```matlab
addpath(genpath('matlab'))
render_main_figures_only(pwd)
```

Expected main figures include:

```text
figures/Fig1.png
figures/Fig1.pdf
figures/Fig2.png
figures/Fig2.pdf
figures/Fig3_prospective_predictions.png
figures/Fig3_prospective_predictions.pdf
```

The supplementary failure-decomposition figure can be generated with:

```matlab
addpath(genpath('matlab'))
make_FigS1_failure_decomposition_by_system(pwd)
```

## Prospective model-derived diagnostics

`sg_prospectivePredictions.m` evaluates three consequences of the formal architecture in synthetic conditions that were not used to construct the literature-derived task presets:

1. **Need × affordance interaction.**  
   Because the social gate is multiplicative, the effect of inferred recipient need should be stronger when an effective affordance is strongly represented.

2. **Relationship × gate interaction.**  
   Because relationship value enters the gated recipient-benefit term, partner-specific effects should be stronger when the need–affordance gate is open.

3. **Need-dependent cost threshold.**  
   Stronger inferred need should increase the action cost tolerated before recipient-benefiting action becomes less probable than the alternative.

The pure self-interest parameter preset provides a negative control. These calculations are prospective predictions of the specified architecture, not independent empirical validation.

## Stage-B experimental-design optimisation

The Stage-B analysis asks which compact set of experimental conditions is most informative for distinguishing alternative model architectures when model parameters are uncertain.

The four targeted alternatives are:

- ungated recipient value;
- additive need and affordance effects;
- ungated relationship effects;
- full multiplicative social gating.

The candidate design space contains 200 conditions defined by five payoff structures crossed with two need levels, two affordance levels, two relationship levels, and five actor-cost levels.

### Running Stage B

From the repository root:

```matlab
addpath(genpath('matlab'))
main_optimize_prosocial_design_stageB
```

The final manuscript analysis uses the **final** Stage-B configuration:

```matlab
cfg.runMode = 'final';
```

in `sg_designConfig_stageB.m`, corresponding to:

```text
parameter-prior half-widths: 0.25, 0.50, 0.75
optimisation seeds:          1701, 2701, 3701
parameter samples/model:     128
Monte Carlo datasets/run:    6000
observations/condition:       20
```

The 20 observations per condition are a computational comparison budget, not a prescribed empirical animal sample size.

### Constrained matched-contrast design

The constrained optimisation forces a six-condition recipient-only core at one common actor cost.

At baseline relationship value, the four conditions form the complete:

```text
Need low  × Affordance low
Need low  × Affordance high
Need high × Affordance low
Need high × Affordance high
```

factorial block.

The weak-gate and strong-gate conditions are then repeated at a second relationship level. This provides matched tests of:

```text
Need × Affordance
Relationship × Gate
```

The optimiser may add up to two further conditions to improve model discrimination.

The need-dependent cost-threshold prediction is separate from this constrained factorial design and requires a graded-cost analysis.

## Stage-B outputs

Stage-B results are written to:

```text
results/design_optimization_stageB/
```

Important files include:

```text
stageB_candidate_conditions.csv
stageB_optimization_summary.csv
stageB_selected_conditions_all_runs.csv
stageB_selection_stability.csv

stageB_global_single_EIG_w*_seed*.csv
stageB_targeted_single_EIG_w*_seed*.csv
stageB_global_greedy_w*_seed*.csv
stageB_targeted_greedy_w*_seed*.csv
stageB_parameter_marginal_mean_predictions_w*_seed*.csv

stageB_targeted_constrained_best_w*_seed*.csv
stageB_targeted_constrained_curve_w*_seed*.csv
stageB_targeted_constrained_cost_comparison_w*_seed*.csv
```

The final robustness analysis reported in the manuscript compares constrained and unconstrained designs across three parameter-prior widths and three optimisation seeds.

## Stage-B summary figure

After the final Stage-B CSV files have been generated:

```matlab
addpath(genpath('matlab'))
make_stageB_final_figure
```

This creates:

```text
figures/design_optimization_stageB/Fig_stageB_final.png
figures/design_optimization_stageB/Fig_stageB_final.pdf
```

and compact plotting summaries in `results/design_optimization_stageB/`.

The repository should contain the corrected file as:

```text
make_stageB_final_figure.m
```

Do not keep the temporary development filename `make_stageB_final_figure_fixed.m`; the primary function is named `make_stageB_final_figure`.

## Interpretation of the optimisation

The optimisation does not establish that animals use the full multiplicative social-gating architecture. It identifies experimental conditions under which competing structural explanations make different behavioural predictions.

The constrained design is near-optimal **within the specified model family, parameter priors, trial budget, and candidate design space**. It is not claimed to be a universally optimal animal experiment.

The six-, seven-, and eight-condition analyses use a fixed observation count per condition. Consequently, gains from adding conditions should not be interpreted as equal-total-observation-budget comparisons.

## Important implementation note

The Stage-B files should be placed in:

```text
matlab/design_optimization/
```

This preserves the two-level project-root resolution used by the Stage-B scripts while keeping the repository organised.

Before running any component, use:

```matlab
addpath(genpath('matlab'))
```

so that the Stage-B code can access shared functions such as:

```text
sg_defaultParams.m
sg_parameterRegimeParams.m
```

## Files replaced by the revision

The following existing repository files should be overwritten with their revised versions:

```text
matlab/main_social_gating_simulation.m
matlab/sg_computeUtility.m
matlab/sg_counterfactualNeedEffect.m
matlab/render_main_figures_only.m
```

The following files are new relative to the earlier repository:

```text
matlab/sg_prospectivePredictions.m
matlab/make_Fig3_prospective_predictions.m
matlab/design_optimization/main_optimize_prosocial_design_stageB.m
matlab/design_optimization/sg_designConfig_stageB.m
matlab/design_optimization/sg_designCandidateModels_stageB.m
matlab/design_optimization/sg_designCandidateConditions_stageB.m
matlab/design_optimization/sg_designSampleParameters_stageB.m
matlab/design_optimization/sg_designPredictSamples_stageB.m
matlab/design_optimization/sg_designRobustSingleEIG_stageB.m
matlab/design_optimization/sg_designBuildPool_stageB.m
matlab/design_optimization/sg_designGreedyRobustEIG_stageB.m
matlab/design_optimization/sg_designSummariseStageB.m
matlab/design_optimization/sg_designSelectionStability_stageB.m
matlab/design_optimization/sg_designPlotStageB.m
matlab/design_optimization/sg_designConstrainedTarget_stageB.m
matlab/design_optimization/sg_designSummariseConstrained_stageB.m
matlab/design_optimization/sg_designPlotConstrainedStageB.m
matlab/design_optimization/make_stageB_final_figure.m
```

For `main_optimize_prosocial_design_stageB.m` and `sg_designConfig_stageB.m`, use the **constrained-patch versions**, which supersede the earlier Stage-B versions.

## One-command reproduction

If the manuscript retains the statement that

```matlab
run('scripts/run_all.m')
```

regenerates all reported simulation outputs, summaries, and figures, `scripts/run_all.m` should also be updated to call the prospective prediction pipeline and the final Stage-B optimisation.

Because Stage B is computationally heavier than the core simulation, an alternative is to keep it as a separate reproducibility step and revise the manuscript's code-availability statement accordingly.

## Legacy outputs and terminology

`nested_model_likelihoods.csv` is retained only as a legacy output name for compatibility. The corresponding analysis should be interpreted as a structural model-ablation / predictive-recovery check, not as fitted empirical nested-model comparison.

Some MATLAB variable names retain development-era labels such as `helpingRate` or `costlyOtherBenefitRate` for compatibility with existing output tables.

## Citation

Please cite the accompanying manuscript when using this code.
