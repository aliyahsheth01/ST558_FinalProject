# I load plumber to create and run the API.
library(plumber)

# I read the endpoint definitions from the API file.
api <- plumb("plumber.R")

# I listen on all interfaces so the API can receive container traffic.
api$run(
  host = "0.0.0.0",
  port = 8000,
  debug = FALSE
)