# Outputs

Running `scripts/run_all.m` writes all generated files into `results/` and `figures/`.

## CSV outputs

| File | Description |
|---|---|
| `trial_data.csv` | Trial-level simulation output. |
| `summary_by_task_and_system.csv` | Full task-by-parameter-regime summary used by manuscript and figure scripts. |
| `summary_for_manuscript.csv` | Compact manuscript-facing summary table. |
| `counterfactual_need_effect.csv` | Counterfactual need-sensitivity analysis. |
| `model_ablation_scores.csv` | Structural model-ablation / predictive-recovery scores. |
| `nested_model_likelihoods.csv` | Legacy filename retained for compatibility; same conceptual output as model-ablation scoring. |

## Figure outputs

| File | Description |
|---|---|
| `figures/Fig1.png` / `figures/Fig1.pdf` | Main manuscript Fig. 1. |
| `figures/Fig2.png` / `figures/Fig2.pdf` | Main manuscript Fig. 2. |
| `figures/supplement/SupFig1.png` / `figures/supplement/SupFig1.pdf` | Online Resource 1, Fig. S1. |

The main simulation script may also write additional diagnostic figures through `sg_plotResults_v2.m`. The dedicated manuscript figures are the files listed above.
