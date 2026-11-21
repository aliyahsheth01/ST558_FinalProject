# I load plumber to create and run the API.
library(plumber)

# I read the endpoint definitions from the API file.
api <- plumb("plumber.R")

# I start the API locally on port 8000.
api$run(port = 8000, debug = FALSE)