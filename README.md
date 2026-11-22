# ST 558 Final Project

This individual project compares a regression tree and a random
forest for predicting tablet hardness using tidymodels. The selected
random forest is served through a plumber API that runs locally.
The API can also run inside a Docker container.

[View the modeling report](https://aliyahsheth01.github.io/ST558_FinalProject/)

## Prediction Task

The response is measured tablet hardness (`hardness_kp`), expressed
in kiloponds (kp).

The four predictors are:

- `strength`: Low, Mid, or High tablet strength.
- `target_hardness_kp`: Intended hardness setpoint.
- `sampling_point`: Pre-Start, Beginning, Middle, or End.
- `speed_setting`: Nominal setting or turret/feeder speed combination.

RMSE is the primary metric for tuning and comparing models.

## Data

The project uses the original deidentified tablet manufacturing
workbook from Project 2. It contains 4,850 records from 52 compression
lots across two engineering studies and one registration campaign.

The modeling analysis includes the 2,900 records with observed
hardness. Missing-value handling and preparation are documented
in the modeling report.

## Modeling Results

The training/test comparison produced the following results:

| Model | Test RMSE (kp) |
|---|---:|
| Random forest | 0.287529 |
| Regression tree | 0.287677 |

The models performed very similarly on this split. The random forest
was selected because it had the lower test RMSE.

The selected forest uses mtry = 4, 500 trees, and min_n = 5.
Its workflow was refitted using all 2,900 modeling records and saved
for the API.

Validation assigned individual tablet records. Evaluation of
entirely new lots or blends would require grouped validation.

## Repository Files

| File or folder | Purpose |
|---|---|
| `ST558_FinalProject.Rproj` | Opens the project in RStudio |
| `data/tablet_ipc_deidentified.xlsx` | Original dataset and supporting worksheets |
| `index.qmd` | Source for the modeling report and saved model generation |
| `_quarto.yml` | Website configuration |
| `docs/` | Rendered website and supporting files |
| `models/final_model.rds` | Selected forest workflow fitted using all modeling records |
| `models/api_inputs.rds` | Calculated default inputs and supported factor levels |
| `plumber.R` | API endpoint definitions and input validation |
| `run_api.R` | Starts the API locally on port 8000 |
| `Dockerfile` | Builds the API image using R 4.6.1 |
| `.dockerignore` | Excludes analysis files and image archives from the build context |

## Required Packages

The project uses readxl, dplyr, tidymodels, rpart, ranger, and plumber.

## Render the Report

Open `ST558_FinalProject.Rproj` in RStudio.

Run the following in the Terminal:

```bash
quarto render
```

The rendered report is saved as `docs/index.html`. Rendering also
regenerates the saved model and API input files.

## Run the API

With the project open in RStudio, run the following in the R Console:

```r
source("run_api.R")
```

Leave the API running while making requests.

Available endpoints:

- [/info](http://127.0.0.1:8000/info): Returns the author and report URL.
- [/pred](http://127.0.0.1:8000/pred): Returns predicted hardness and the inputs used.

Prediction inputs are supplied as URL query parameters.
Omitted inputs use the following defaults calculated from the
modeling records:

| Input | Default |
|---|---|
| `strength` | Mid |
| `target_hardness_kp` | Mean target hardness, approximately 6.077586 kp |
| `sampling_point` | Pre-Start |
| `speed_setting` | Nominal |

Supported speed settings are `Nominal`, `Turret high / Feeder high`,
`Turret high / Feeder low`, `Turret low / Feeder high`, and
`Turret low / Feeder low`.

Category labels are case-sensitive. Target hardness must be one
positive, finite number. Invalid inputs receive HTTP status 400
with an explanatory message.

Example prediction requests:

- [Use all defaults](http://127.0.0.1:8000/pred)
- [Low strength, target 4 kp](http://127.0.0.1:8000/pred?strength=Low&target_hardness_kp=4&sampling_point=Beginning&speed_setting=Nominal)
- [High strength, target 9 kp](http://127.0.0.1:8000/pred?strength=High&target_hardness_kp=9&sampling_point=End&speed_setting=Nominal)

These three examples are also included as comments below the
prediction endpoint in `plumber.R`.

To stop the API, press Esc or click the Stop button in RStudio.

## Build and Run with Docker

Start Docker Desktop. From the project's main folder, build the image:

```bash
docker build --platform linux/amd64 --progress=plain -t st558-finalproject:1.0 .
```

The image targets Linux AMD64. Docker Desktop can run it on
Apple Silicon through emulation.

Stop any API running in RStudio so port 8000 is available.
Create and start a new container:

```bash
docker run -d \
  --platform linux/amd64 \
  --name st558-api \
  -p 127.0.0.1:8000:8000 \
  st558-finalproject:1.0
```

Check the container and its startup logs:

```bash
docker ps --filter name=st558-api
docker logs --tail 30 st558-api
```

With the container running, use the same `/info` and `/pred`
links listed above.

Both endpoints and the three example predictions were tested
inside Docker. The prediction results matched the local API.
An unsupported strength returned HTTP status 400.

Stop the container:

```bash
docker stop st558-api
```

Restart that existing container:

```bash
docker start st558-api
```

## Project Status

The modeling report, API, and Docker image build are complete.
The API has been tested successfully inside the container.

Image archive delivery, final review, and the narrated
demonstration video remain.