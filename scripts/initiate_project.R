#Initiate project

# This is only needed the first time you run the code. 
# The point is to set up the ckeckpoint to ensure reproducibility  by always 
# Running the same package versions
# https://cran.r-project.org/web/packages/checkpoint/index.html

#Install checkpoint- Will create a folder for snapshots of versions
install.packages("checkpoint")

library("checkpoint") #Load checkpoint. Always start a script with this command
checkpoint("2019-01-21") # Set date for snapshots-Note american date
#All packages will be loaded as they were on that date on CRAN

#If you want to see how it works use Sys.info() or sessionInfo() and change date around
