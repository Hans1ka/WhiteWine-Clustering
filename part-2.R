# Financial Forecasting

# Install packages
install.packages("neuralnet")
install.packages("readxl")

# Load required libraries
library(neuralnet)
library(readxl)

# Load the data
exchange_data <- read_excel("ExchangeUSD.xlsx")

# Extract the USD/EUR column
exchange_rate <- exchange_data$`USD/EUR`

# Define function to normalize data
normalize <- function(data) {
  normalized_data <- (data - min(data)) / (max(data) - min(data))
  return(normalized_data)
}

# Define function to calculate MAPE
mape <- function(actual, predicted) {
  denominator <- actual
  denominator[denominator == 0] <- 1  # Replace zeros with 1 to avoid division by zero
  mape_value <- mean(abs((actual - predicted) / denominator)) * 100
  return(mape_value)
}

# Define function to calculate sMAPE
smape <- function(actual, predicted) {
  smape_value <- 2 * mean(abs(actual - predicted) / (abs(actual) + abs(predicted))) * 100
  return(smape_value)
}

# Define function to create input/output matrix for AR approach
create_io_matrix <- function(data, time_delay) {
  input <- matrix(NA, nrow = length(data) - time_delay, ncol = time_delay)
  output <- data[(time_delay + 1):length(data)]
  for (i in 1:time_delay) {
    input[, i] <- data[i:(length(data) - time_delay + i - 1)]
  }
  input <- apply(input, 2, normalize)
  output <- normalize(output)
  return(list(input = input, output = output))
}

# Split data into training and testing sets
training_data <- exchange_rate[1:400]
testing_data <- exchange_rate[401:500]

# Experiment with various time delays
time_delays <- 1:4

# Define various MLP configurations
mlp_configs <- list(
  list(hidden_layers = c(5), linear_output = TRUE, activation_func = "logistic"),
  list(hidden_layers = c(10, 5), linear_output = FALSE, activation_func = "tanh"),
  list(hidden_layers = c(8, 4), linear_output = TRUE, activation_func = "logistic")
)

# Initialize list to store results
results <- list()

# Initialize counter for configuration index
config_index <- 1

# Iterate over different time delays
for (delay in time_delays) {
  # Create input/output matrix for training data
  train_io <- create_io_matrix(training_data, delay)
  
  # Create input/output matrix for testing data
  test_io <- create_io_matrix(testing_data, delay)
  
  for (config in mlp_configs) {
    # Train MLP model using neuralnet function
    mlp_model <- neuralnet(output ~ ., data = as.data.frame(train_io), hidden = config$hidden_layers, 
                           linear.output = config$linear_output, act.fct = config$activation_func)
    
    # Make predictions on testing data
    predictions <- predict(mlp_model, as.data.frame(test_io$input))
    
    # Calculate evaluation metrics
    rmse <- sqrt(mean((predictions - test_io$output)^2))
    mae <- mean(abs(predictions - test_io$output))
    mape_value <- mape(test_io$output, predictions)
    smape_value <- smape(test_io$output, predictions)
    
    # Store results
    result_key <- paste("Delay", delay, "_Config", config_index, sep = "_")
    results[[result_key]] <- list(model = mlp_model, 
                                  rmse = rmse, 
                                  mae = mae, 
                                  mape = mape_value, 
                                  smape = smape_value)
    
    # Increment configuration index
    config_index <- config_index + 1
  }
}

# Print results
for (key in names(results)) {
  cat("Model:", key, "\n")
  cat("RMSE:", results[[key]]$rmse, "\n")
  cat("MAE:", results[[key]]$mae, "\n")
  cat("MAPE:", results[[key]]$mape, "%\n")
  cat("sMAPE:", results[[key]]$smape, "%\n\n")
}


# Visualize individual neural network models
for (key in names(results)) {
  # Extract the neural network model
  model <- results[[key]]$model
  
  # Plot the neural network
  plot(model)
  
}


# Ensure mlp_configs matches the length of results
if (length(mlp_configs) < length(results)) {
  repeat {
    mlp_configs <- c(mlp_configs, mlp_configs)
    if (length(mlp_configs) >= length(results)) break
  }
}

# Initialize a table to store results
comparison_table <- matrix(NA, nrow = length(results), ncol = 6)
colnames(comparison_table) <- c("Model", "Description", "RMSE", "MAE", "MAPE", "sMAPE")

# Populate the comparison table
for (i in 1:length(results)) {
  key <- names(results)[i]
  model <- results[[key]]$model
  description <- paste("Hidden Layers:", paste(mlp_configs[[i]]$hidden_layers, collapse = "-"), 
                       "Linear Output:", mlp_configs[[i]]$linear_output,
                       "Activation Function:", mlp_configs[[i]]$activation_func)
  
  # Extract evaluation metrics
  rmse <- results[[key]]$rmse
  mae <- results[[key]]$mae
  mape <- results[[key]]$mape
  smape <- results[[key]]$smape
  
  # Populate the comparison table
  comparison_table[i, ] <- c(key, description, rmse, mae, mape, smape)
}

# Print the comparison table
print(comparison_table)


# Define function to calculate MAPE
mape <- function(actual, predicted) {
  denominator <- actual
  denominator[denominator == 0] <- 1  # Replace zeros with 1 to avoid division by zero
  mape_value <- mean(abs((actual - predicted) / denominator)) * 100
  return(mape_value)
}

# Define function to calculate sMAPE
smape <- function(actual, predicted) {
  smape_value <- 2 * mean(abs(actual - predicted) / (abs(actual) + abs(predicted))) * 100
  return(smape_value)
}

# Plot predictions vs. desired outputs (scatter plot) 
if (!is.null(predictions)) {
  plot(test_io$output, predictions, main = "Predictions vs. Desired Outputs", 
       xlab = "Desired Outputs", ylab = "Predictions", col = "blue")
  abline(0, 1, col = "red")  # Add a diagonal line for reference
  
  # Calculate statistical indices
  rmse <- sqrt(mean((predictions - test_io$output)^2))
  mae <- mean(abs(predictions - test_io$output))
  mape_value <- mape(test_io$output, predictions)
  smape_value <- smape(test_io$output, predictions)
  
  # Print statistical indices
  cat("RMSE:", rmse, "\n")
  cat("MAE:", mae, "\n")
  cat("MAPE:", mape_value, "%\n")
  cat("sMAPE:", smape_value, "%\n")
} else {
  cat("Error: The predictions are not available.\n")
}


