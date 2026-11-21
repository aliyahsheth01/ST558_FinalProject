# ST 558 Final Project

This individual project will compare a regression tree and a random
forest for predicting tablet hardness using tidymodels. The selected
model will be made available through a plumber API running in a
Docker container.

[View the modeling report](https://aliyahsheth01.github.io/ST558_FinalProject/)

## Prediction Task

The response is measured tablet hardness (`hardness_kp`), expressed
in kiloponds (kp).

The initial predictors are:

- `strength`: Low, Mid, or High tablet strength.
- `target_hardness_kp`: Intended hardness setpoint.
- `sampling_point`: Sampling stage during compression.
- `speed_setting`: Nominal setting or turret/feeder speed combination.

RMSE will be the primary metric for tuning and comparing models.

## Data

The project uses the original deidentified tablet manufacturing
workbook from Project 2. It contains 4,850 records from 52 compression
lots across two engineering studies and one registration campaign.

Measurement availability varies across records. Missing-value handling
and the resulting modeling sample will be documented in the report.

## Repository Files

| File or folder | Purpose |
|---|---|
| `ST558_FinalProject.Rproj` | Opens the project in RStudio |
| `data/tablet_ipc_deidentified.xlsx` | Original dataset and supporting worksheets |
| `index.qmd` | Source for the modeling report |
| `_quarto.yml` | Website configuration |
| `docs/` | Rendered website and supporting files |
| `models/final_model.rds` | Selected random forest workflow fitted using all modeling records |

## Render the Report

Open `ST558_FinalProject.Rproj` in RStudio. The current report requires
the readxl, dplyr, and tidymodels packages.

Run the following in the Terminal:

```bash
quarto render
```

The rendered report is saved as `docs/index.html`.

## Project Status

Data preparation, five-fold cross-validation, regression tree and
random forest tuning, and test-set comparison are complete.

The random forest was selected with a test RMSE of 0.287529 kp.
The final workflow was refitted using all 2,900 modeling records
and saved as `models/final_model.rds`.

API development, Docker packaging, and the demonstration video
are the remaining project tasks.