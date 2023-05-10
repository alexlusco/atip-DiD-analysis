
pacman::p_load(tidyverse, janitor, feather)

files <- list.files("data/raw", pattern = ".csv|.xlsx")


ati_2015_16.file <- "data/raw/2015-16-ati.csv" 
ati_2016_17.file <- "data/raw/2016-17-ati.csv"
ati_2017_18.file <- "data/raw/2017-18-ati.csv"
ati_2018_19.file <- "data/raw/2018-19-ati.csv"
ati_2019_20.file <- "data/raw/2019-20-ati.csv"
ati_2020_21.file <- "data/raw/2020-21-ati.xlsx"
ati_2021_22.file <- "data/raw/2021-22-ATI-Dataset.xlsx"