#install packages

#We highly reccomend keeping all install.packages in its own seperate file. 
#Pros: running scripts easier, debugging easier, and keeps track of installed packages
#and guarantees installed with checkpoint date

library(checkpoint) #Load checkpoint for reproducibility
checkpoint("2019-01-21") #Set snapshot of CRAN date. 

#Add package here for relative file paths
install.packages("here") #makes sharing files much easier (in combination with Rprojects)

#Add custom packages
install.packages("tidyverse") #All things 
install.packages("stargazer")
install.packages("httr") #Tools for Working with URLs and HTTP
install.packages("rjstats") #Read and Write 'JSON-stat' Data Sets
install.packages("shiny") #For nice interactive figures
install.packages("readxl") #For reading Excel files
install.packages("skimr") #For nice summary statistics

#If installing directly in a Markdown document with checkpoint make sure to use: 
#install.packages("httr", repos = "https://mran.microsoft.com/")

#If you face any issues at all, above code will fix it. 

#Shiny and its dependencies
install.packages("shiny")
install.packages("plotly")
install.packages("shinythemes")
install.packages("DT")
install.packages("shinyWidgets")
