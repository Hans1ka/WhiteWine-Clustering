#Partitioning clustering

#Subtask-1

# Part-a

# Installing packages
install.packages("readxl")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("outliers")

#Loading libraries
library(readxl) #for reading excel files
library(dplyr)   # for data manipulation
library(ggplot2) # for visualization
library(outliers) # for outlier detection

#Load the dataset
data <- read_excel("Whitewine_v6.xlsx")
data <- data[, 1:11] #considering the first 11 attributes
head(data)
summary(data)

boxplot(data, main = "Before Removing Outliers", outline = TRUE) #dataset visualization with outliers


# 1. Outliers detection and removal
# Calculate the Interquartile Range (IQR) for each attribute
Q1 <- apply(data, 2, quantile, probs = 0.25)
Q3 <- apply(data, 2, quantile, probs = 0.75)
IQR <- Q3 - Q1

# Define the threshold for outlier detection
threshold <- 1.5

# Identify outliers
outliers <- sapply(1:11, function(i) {
  lower_bound <- Q1[i] - threshold * IQR[i]
  upper_bound <- Q3[i] + threshold * IQR[i]
  outliers <- data[, i] < lower_bound | data[, i] > upper_bound
})

outlier_counts <- colSums(outliers)

# Remove outliers
outliers_removed_data <- data[!apply(outliers, 1, any), ]

dim(data)

boxplot(outliers_removed_data, main="After Removing Outliers")


# 2. Scaling
scaled_data <- scale(outliers_removed_data)
boxplot(scaled_data, main="Scaled Data")


#Part-b

# Installing packages
install.packages("NbClust")
install.packages("cluster")
install.packages("factoextra")

# Load necessary libraries
library(NbClust)
library(cluster)
library(factoextra)

# NbClust
nb_results <- NbClust(scaled_data, distance = "euclidean", min.nc = 2, max.nc = 10, method = "kmeans")

# Elbow method
fviz_nbclust(scaled_data, kmeans, method = "wss") +
  labs(title = "Elbow Method")

# Gap statistics
gap_stat <- clusGap(scaled_data, FUN = kmeans, nstart = 25, K.max = 10, B = 50)
plot(gap_stat, main = "Gap Statistic")

# Silhouette method
fviz_nbclust(scaled_data, kmeans, method='silhouette')


# Part-c

# Assigning k value
k <- 2

#k-means
kmeans_model <- kmeans(scaled_data, centers = k, nstart = 25)

kmeans_model

fviz_cluster(kmeans_model, data = scaled_data)

centers <- kmeans_model$centers
print(centers)

clustered_results <- kmeans_model$cluster

bss <- kmeans_model$betweenss
tss <- kmeans_model$totss
wss <- tss - bss

bss_tss_ratio <- bss/tss
print(bss_tss_ratio)
print(wss)
print(bss)

# Get the cluster assignments for each data point
cluster_assignments <- kmeans_model$cluster

# Calculate BSS and WSS for each cluster
bss_per_cluster <- numeric(k)
wss_per_cluster <- numeric(k)

for (i in 1:k) {
  # Find indices of data points belonging to the current cluster
  cluster_indices <- which(cluster_assignments == i)
  
  # Extract data points for the current cluster
  cluster_data <- scaled_data[cluster_indices, ]
  cluster_center <- centers[i, ]
  
  # Calculate the sum of squares for the cluster
  cluster_ssq <- sum(rowSums((cluster_data - cluster_center)^2))
  
  # BSS for the cluster
  bss_per_cluster[i] <- length(cluster_indices) * cluster_ssq
  
  # WSS for the cluster
  wss_per_cluster[i] <- sum(rowSums((cluster_data - cluster_center)^2))
}

# Calculate BSS and TSS for the entire dataset
bss_total <- sum(bss_per_cluster)
tss_total <- sum(wss_per_cluster) + bss_total

# Calculate BSS/TSS ratio for each cluster
bss_tss_ratio_per_cluster <- bss_per_cluster / tss_total

# Print BSS, WSS, and BSS/TSS ratio for each cluster
for (i in 1:k) {
  cat("Cluster", i, "BSS:", bss_per_cluster[i], "\n")
  cat("Cluster", i, "WSS:", wss_per_cluster[i], "\n")
  cat("Cluster", i, "BSS/TSS ratio:", bss_tss_ratio_per_cluster[i], "\n\n")
}

# Print total BSS, TSS, and BSS/TSS ratio for the entire dataset
cat("Total BSS:", bss_total, "\n")
cat("Total TSS:", tss_total, "\n")
cat("Total BSS/TSS ratio:", bss_total / tss_total, "\n")


fviz_cluster(kmeans_model, data = scaled_data, geom = "point",
             stand = FALSE, ellipse.type = "convex")


# Part-d

# Calculate silhouette scores for each point
sil_scores <- silhouette(kmeans_model$cluster, dist(scaled_data))

# Plot silhouette plot
plot(sil_scores, col = 1:k, border = NA)

# Average silhouette width score
avg_silhouette_width <- mean(sil_scores[, "sil_width"])

# Print average silhouette width score
print(paste("Average Silhouette Width Score:", avg_silhouette_width))




# Subtask-2

# Part-e

#Install packages
install.packages("FactoMineR")

# Load necessary library
library(FactoMineR)

# Perform PCA
pca_result <- prcomp(scaled_data, center = TRUE, scale. = TRUE)
summary(pca_result)

# Print eigenvalues and eigenvectors
print(pca_result$rotation)  # Eigenvectors (Principal Component Loadings)
print(pca_result$sdev^2)     # Eigenvalues (Variances)

# Plot cumulative score per principal components
plot(cumsum(pca_result$sdev^2) / sum(pca_result$sdev^2), 
     xlab = "Number of Principal Components",
     ylab = "Cumulative Proportion of Variance Explained",
     type = "b")

# Identify principal components that provide at least cumulative score > 85%
cumulative_score <- cumsum(pca_result$sdev^2) / sum(pca_result$sdev^2)
pcs_to_include <- which(cumulative_score > 0.85)[1]

# Create a transformed dataset with selected principal components
transformed_data <- as.data.frame(predict(pca_result, newdata = scaled_data)[, 1:pcs_to_include])

# Print the first few rows of the transformed dataset
head(transformed_data)


# Part-f

# NbClust for PCA-based dataset
nb_results_pca <- NbClust(transformed_data, distance = "euclidean", min.nc = 2, max.nc = 10, method = "kmeans")

# Elbow method for PCA-based dataset
fviz_nbclust(transformed_data, kmeans, method = "wss") +
  labs(title = "Elbow Method for PCA-based Dataset")

# Gap statistics for PCA-based dataset
gap_stat_pca <- clusGap(transformed_data, FUN = kmeans, nstart = 25, K.max = 10, B = 50)
plot(gap_stat_pca, main = "Gap Statistic for PCA-based Dataset")

# Silhouette method for PCA-based dataset
fviz_nbclust(transformed_data, kmeans, method='silhouette')


# Part-g
# Perform k-means clustering using the determined k
kmeans_model_pca <- kmeans(transformed_data, centers = 2, nstart = 25)

# Display k-means output
print(kmeans_model_pca)

# Print cluster centers
print(kmeans_model_pca$centers)

# Calculate BSS and TSS
bss_pca <- kmeans_model_pca$betweenss
tss_pca <- kmeans_model_pca$totss

# Calculate WSS
wss_pca <- sum(kmeans_model_pca$withinss)

# Calculate BSS/TSS ratio
bss_tss_ratio_pca <- bss_pca / tss_pca

# Print BSS, TSS, and BSS/TSS ratio
cat("BSS:", bss_pca, "\n")
cat("TSS:", tss_pca, "\n")
cat("BSS/TSS ratio:", bss_tss_ratio_pca, "\n")
cat("WSS:", wss_pca, "\n")

# Visualize the clustered results
fviz_cluster(kmeans_model_pca, data = transformed_data, geom = "point",
             stand = FALSE, ellipse.type = "convex")



#part-h
# Calculate silhouette scores for each point
sil_scores_pca <- silhouette(kmeans_model_pca$cluster, dist(transformed_data))

# Plot silhouette plot
plot(sil_scores_pca, col = 1:k, border = NA)

# Calculate average silhouette width score
avg_silhouette_width_pca <- mean(sil_scores_pca[, "sil_width"])

# Print average silhouette width score
print(paste("Average Silhouette Width Score:", avg_silhouette_width_pca))



#part-i
library(fpc)
ch_index <- calinhara(transformed_data, kmeans_model_pca$cluster)
# Print Calinski-Harabasz Index
print(paste("Calinski-Harabasz Index:", ch_index))


fviz_ch <- function(data) {
  ch_index <- c()
  for (i in 2:10) {
    km <- kmeans(data, i) # perform clustering
    ch_index[i] <- calinhara(data, km$cluster, cn = max(km$cluster)) # calculate Calinski-Harabasz index
  }
  ch <- ch_index[2:10]
  k <- 2:10
  plot(k, ch,xlab =  "Cluster number k",
       ylab = "Calinski - Harabasz Score",
       main = "Calinski - Harabasz Plot", cex.main=1,
       col = "darkblue", cex = 0.9 ,
       lty=1 , type="o" , lwd=1, pch=4,
       bty = "l",
       las = 1, cex.axis = 0.8, tcl  = -0.2)
  abline(v=which(ch==max(ch)) + 1, lwd=1, col="red", lty="dashed")
}

fviz_ch(transformed_data)


