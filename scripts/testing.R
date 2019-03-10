#Testing
options(scipen=10000)
library("checkpoint") #Checkpoint assures us that we use the same package versions
checkpoint("2019-01-21") #As they were at the date set in this function. i.e "2019-01-21"
library(stargazer)
library(scales)
library(skimr)
library(tidyverse)
library(stringr)
library(readr)
library(tidyverse)
library(here)


df_joined_wide <- readRDS(here("data/processed", "df_joined_wide.rds"))
df_joined_long <- readRDS(here("data/processed", "df_joined_long.rds"))


unique(df_joined_long$contents)
levels(df_joined_long$age)

#Notes: 

#Faceting: contents: ave_home_price, home_transfers, inhabitants, oil_price, reg_unemployed, trans_val_in_1000
vec <- c("ave_home_price", "home_transfers", "inhabitants", "oil_price", "reg_unemployed", "trans_val_in_1000")

df_long_sub <- df_joined_long %>% 
        filter(contents %in% vec) 

#Subsetting

#Sex: Females, Males, Population
# Population is in both inhabitants and reg_unemployed. 
vec_unemp <- c("Population")

df_long_sub <- df_joined_long %>% 
        filter(sex %in% vec_unemp | is.na(sex)) 
        
#Filter on date
vec_date <- c( "2005-01-01", "2017-01-01" )
df_long_sub <- df_joined_long %>%
        filter(date>=vec_date[1] & date<=vec_date[2])

#Filter on age 0-105 and sum them up. Drops age and gives bach inhabitants w/o
vec_age <- c(0,67)
df_long_sub <- df_joined_long %>%
        mutate( age = parse_number(as.character(age))) %>%
        filter(between(age, vec_age[1], vec_age[2]) | is.na(age)) %>%
        group_by(region, sex, contents, date) %>%
        summarise(value = sum(value)) %>%
        ungroup()

# Plot

vec <- c("ave_home_price", "home_transfers")

df_long_sub <- df_joined_long %>% 
        filter(contents %in% vec) 


p <- ggplot(data = df_long_sub,
       aes(x = date, y = log(value), colour = region)) +
        geom_point() + 
        facet_grid(contents~., scales = "free_y") +
        geom_smooth(method ="lm") +
        geom_line() +
        ggtitle("Hello world") 
p

#Testing logic
x1 <- c("a", "b", "c", "d")
x2 <- c("a", "b", "e", "f")

x1 %in% x2
any(x1 %in% x2)

#Testing paste
x3 <- c(1,2,3)
paste(x3[1],"-",x3[3])



