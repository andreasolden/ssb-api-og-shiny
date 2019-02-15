library(readxl)
library(httr)

GET("https://www.eia.gov/dnav/pet/hist_xls/RBRTEm.xls", write_disk(tf <- tempfile(fileext = ".xls")))

df <- read_excel(tf,
                 col_names = c("date","price"),
                 skip=3,
                 sheet = "Data 1")
str(df)