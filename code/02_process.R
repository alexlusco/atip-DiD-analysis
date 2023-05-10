

source("code/01_config.R")
source("code/TC_functions.R")

ati_2015_16 <- tidy_ati_stats(ati_2015_16.file, request_type = 'ATI', fy_ending = 2016, header_rows = 5)
#privacy_2015_16 <- tidy_ati_stats(privacy_2015_16.file, request_type = 'Privacy', fy_ending = 2016, header_rows = 4)

ati_2016_17 <- tidy_ati_stats(ati_2016_17.file, request_type = 'ATI', fy_ending = 2017, header_rows = 5)
#privacy_2016_17 <- tidy_ati_stats(privacy_2016_17.file, request_type = 'Privacy', fy_ending = 2017, header_rows = 5)

ati_2017_18 <- tidy_ati_stats(ati_2017_18.file, request_type = 'ATI', fy_ending = 2018, header_rows = 5)
#privacy_2017_18 <- tidy_ati_stats(privacy_2017_18.file, request_type = 'Privacy', fy_ending = 2018, header_rows = 5)

ati_2018_19 <- tidy_ati_stats(ati_2018_19.file, request_type = 'ATI', fy_ending = 2019, header_rows = 5)
#privacy_2018_19 <- tidy_ati_stats(privacy_2018_19.file, request_type = 'Privacy', fy_ending = 2019, header_rows = 5)

ati_2019_20 <- tidy_ati_stats(ati_2019_20.file, request_type = 'ATI', fy_ending = 2020, header_rows = 3)
#privacy_2019_20 <- tidy_ati_stats(privacy_2019_20.file, request_type = 'Privacy', fy_ending = 2020, header_rows = 3)

ati_2020_21 <- tidy_ati_stats(ati_2020_21.file, request_type = 'ATI', fy_ending = 2021, header_rows = 3)
#privacy_2020_21 <- tidy_ati_stats(privacy_2020_21.file, request_type = 'Privacy', fy_ending = 2021, header_rows = 3)

ati_2021_22 <- tidy_ati_stats(ati_2021_22.file, request_type = 'ATI', fy_ending = 2022, header_rows = 3)
#privacy_2021_22 <- tidy_ati_stats(privacy_2021_22.file, request_type = 'Privacy', fy_ending = 2022, header_rows = 3)

atip <- bind_rows(
  ati_2015_16,
  privacy_2015_16,
  ati_2016_17,
  privacy_2016_17,
  ati_2017_18,
  privacy_2017_18,
  ati_2018_19,
  privacy_2018_19,
  ati_2019_20,
  privacy_2019_20,
  ati_2020_21,
  privacy_2020_21,
  ati_2021_22,
  privacy_2021_22
)

feather::write_feather(atip, "data/processed/atip-2015-2022.feather")

