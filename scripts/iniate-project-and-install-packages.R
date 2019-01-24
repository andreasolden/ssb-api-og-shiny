#initiate project
install.packages("checkpoint")
library("checkpoint")
checkpoint("2019-01-21") #or your preferred date
#Sys.info() #Useful command for checking versions and play around with checkpoint
#sessionInfo() #Useful command for checking versions and play around with checkpoint

#Add package here for relative file paths
install.packages("here")

#Add custom packages
install.packages("tidyverse")
install.packages("stargazer")
install.packages("httr") #Tools for Working with URLs and HTTP
install.packages("mosaic")#Project MOSAIC Statistics and Mathematics Teaching Utilities 
install.packages("rjstats") #Read and Write 'JSON-stat' Data Sets

#If installing directly in a Markdown document with checkpoint make sure to use: 
#install.packages("httr", repos = "https://mran.microsoft.com/")