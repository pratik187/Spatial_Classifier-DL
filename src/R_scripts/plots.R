################################
##### Plotting 
################################
rm(list = ls())
args = commandArgs(trailingOnly=TRUE)
file_path = "/Users/nagp/Desktop/nonstat_splitting/Spatial_Classifier-DL/" #args[1]
setwd(file_path)

library(ggplot2)
df1 = read.csv("Model_Example/stat_test-probs.csv", header = T)
df2 = read.csv("Model_Example/nonstat_test-probs.csv", header = T)
data = data.frame(
  Status = rep(c("stationary data", "nonstationary data"), each = 100),
  Value = c(df1[,2], df2[,2])
)

# Create histogram
ggplot(data, aes(x = Value, fill = Status)) +
  geom_histogram(aes(y = after_stat(count) / sum(after_stat(count))), 
                 position = "identity", alpha = 1, bins = 20, color = "white") +
  labs(title = "",
       x = "Probability of nonstationarity", y = "Relative frequency")+
  theme(panel.background = element_rect(fill = "grey90"),
        legend.position = c(0.5, 0.5),
        axis.title = element_text(size = 14, face = "bold"),
        legend.text = element_text(size = 14)) 

