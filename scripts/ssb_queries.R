#Run SSB api queries and save data

#Load packages we will use ####
library("checkpoint") #Checkpoint assures us that we use the same package versions
checkpoint("2019-01-21") #As they were at the date set in this function. i.e "2019-01-21"
library(here) # allows us to use relative file paths, see readme or simulations doc
library(httr) #Tools for Working with URLs and HTTP
library(rjstat) #Read and Write 'JSON-stat' Data Sets
library(mosaic) #Project MOSAIC Statistics and Mathematics Teaching Utilities
library(tidyverse) #For almost everything else :)
#options(encoding="UTF-8")

# How to step by step ####

#Go to SSB API site https://www.ssb.no/omssb/tjenester-og-verktoy/api/px-api
#Use the API console to find tables (data) and query code
#For english https://data.ssb.no/api/v0/en/console
#Example: Go to API console, find "priser for drivstoff" 09654

#1. Make object 'url' with desired URL as in URL field in console
#2. Make object 'data' with json code. Can paste from console, but
        #a) Sometimes code wont run until changed to json-stat from json-stat2
        #b) Paste from query, not results
        #c) Default is to only loads head and bottom observations
        #d) Fill in manual or add all values by [“*”] , see time for example
#3. Make object with POST function. posts send 'data' to server and gets data
        #a) url=object from 1
        #b) body=object from 2
        #c) encode="json" for format of data you get back
        #d) verbose is verbose
#4. create dataframe by using fromJSONstat 
#5. Play
#6. Save dataset

#1 Set URL ####
url <- "https://data.ssb.no/api/v0/no/table/09654"

#2 Make object 'data' with the jsonsstat code pasted in. QUERY NOT RESULTS ####

data <- '
{
  "query": [
        {
        "code": "PetroleumProd",
        "selection": {
        "filter": "item",
        "values": [
        "031",
        "035"
        ]
        }
        },
        {
        "code": "ContentsCode",
        "selection": {
        "filter": "item",
        "values": [
        "Priser"
        ]
        }
        },
        {
        "code": "Tid",
        "selection": {
        "filter": "item",
        "values": [
        "*"
        ]
        }
        }
        ],
        "response": {
        "format": "json-stat2"
        }
        }
        '


#3 Make object with POST function####
temp <- POST(url , body = data, encode = "json", verbose())
str(temp)

#4 create dataframe by using fromJSONstat ####
df_petroleum_price_liter <- fromJSONstat(content(temp, as ="text"), use_factors = TRUE)

#5 Play ####

#6 Save ####
saveRDS(df_petroleum_price_liter, file = here("results", "df_petroleum_price_liter.rds"))
