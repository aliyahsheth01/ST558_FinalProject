# I load the packages needed to use the saved model.
library(tidymodels)
library(ranger)

# I load the fitted workflow once when the API starts.
hardness_model <- readRDS("models/final_model.rds")

#* Return the project author and modeling report URL.
#* @get /info
function() {
  list(
    name = "Aliyah Sheth",
    report_url = "https://aliyahsheth01.github.io/ST558_FinalProject/"
  )
}

# Example request:
# http://127.0.0.1:8000/info