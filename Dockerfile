# I use the same R version used to create the saved model.
FROM rocker/r-ver:4.6.1

# I install build tools and Linux libraries used by the R packages.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        libcurl4-openssl-dev \
        libssl-dev \
        libxml2-dev \
        libsodium-dev \
        libicu-dev \
    && rm -rf /var/lib/apt/lists/*

# I install the required R packages and check that they load.
RUN Rscript -e "install.packages(c('tidymodels', 'ranger', 'plumber')); library(tidymodels); library(ranger); library(plumber)"

# I set the working directory inside the container.
WORKDIR /app

# I copy the API definition and startup script.
COPY plumber.R run_api.R ./

# I copy the fitted workflow and prediction input information.
COPY models/final_model.rds models/api_inputs.rds ./models/

# I document the port used by the API.
EXPOSE 8000

# I start the API when the container runs.
CMD ["Rscript", "run_api.R"]