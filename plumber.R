# ST 558 Final Project: Tablet Hardness Prediction API

# I load the packages needed to use the saved workflow.
library(tidymodels)
library(ranger)

# I load the fitted model and input information once at startup.
hardness_model <- readRDS("models/final_model.rds")
api_inputs <- readRDS("models/api_inputs.rds")


#* Return the project author and modeling report URL.
#* @get /info
function() {
  list(
    name = "Aliyah Sheth",
    report_url = "https://aliyahsheth01.github.io/ST558_FinalProject/"
  )
}

# Example information request:
# http://127.0.0.1:8000/info


#* Predict measured tablet hardness in kp.
#* @param strength Tablet strength: Low, Mid, or High.
#* @param target_hardness_kp Intended hardness setpoint in kp.
#* @param sampling_point Pre-Start, Beginning, Middle, or End.
#* @param speed_setting Nominal or a supported turret/feeder speed category.
#* @get /pred
function(
    res,
    strength = api_inputs$defaults$strength,
    target_hardness_kp = api_inputs$defaults$target_hardness_kp,
    sampling_point = api_inputs$defaults$sampling_point,
    speed_setting = api_inputs$defaults$speed_setting
) {
  
  # I check that strength is one supported category.
  if (length(strength) != 1L ||
      !(strength %in% api_inputs$factor_levels$strength)) {
    res$status <- 400
    return(list(
      error = "strength must be Low, Mid, or High."
    ))
  }
  
  # I convert the numeric query input from text when needed.
  target_hardness_kp <- suppressWarnings(
    as.numeric(target_hardness_kp)
  )
  
  # I require one positive, finite target hardness value.
  if (length(target_hardness_kp) != 1L ||
      !is.finite(target_hardness_kp) ||
      target_hardness_kp <= 0) {
    res$status <- 400
    return(list(
      error = "target_hardness_kp must be one positive, finite number."
    ))
  }
  
  # I check that the sampling point is supported.
  if (length(sampling_point) != 1L ||
      !(sampling_point %in% api_inputs$factor_levels$sampling_point)) {
    res$status <- 400
    return(list(
      error = "sampling_point must be Pre-Start, Beginning, Middle, or End."
    ))
  }
  
  # I check that the speed setting is supported.
  if (length(speed_setting) != 1L ||
      !(speed_setting %in% api_inputs$factor_levels$speed_setting)) {
    res$status <- 400
    return(list(
      error = "Unsupported speed_setting.",
      allowed = api_inputs$factor_levels$speed_setting
    ))
  }
  
  # I prepare one record using the model's categorical levels.
  new_tablet <- data.frame(
    strength = factor(
      strength,
      levels = api_inputs$factor_levels$strength
    ),
    target_hardness_kp = target_hardness_kp,
    sampling_point = factor(
      sampling_point,
      levels = api_inputs$factor_levels$sampling_point
    ),
    speed_setting = factor(
      speed_setting,
      levels = api_inputs$factor_levels$speed_setting
    )
  )
  
  # I generate a prediction using the saved fitted workflow.
  prediction <- predict(
    hardness_model,
    new_data = new_tablet
  )
  
  # I return predicted hardness and the inputs used.
  list(
    predicted_hardness_kp = prediction$.pred,
    inputs = new_tablet
  )
}

# Example 1: Use all default inputs.
# http://127.0.0.1:8000/pred

# Example 2: Predict for a Low-strength tablet.
# http://127.0.0.1:8000/pred?strength=Low&target_hardness_kp=4&sampling_point=Beginning&speed_setting=Nominal

# Example 3: Predict for a High-strength tablet.
# http://127.0.0.1:8000/pred?strength=High&target_hardness_kp=9&sampling_point=End&speed_setting=Nominal