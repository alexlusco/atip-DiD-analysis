# =======================================================================
# Read raw data, clean it and save it out to `dir_data_processed()` here
# before moving to analysis. If run from `run.R`, all variables generated
# in this file will be wiped after completion to keep the environment
# clean. If your process step is complex, you can break it into several
# files like so: `source(dir_src('process_files', 'process_step_1.R'))`
# =======================================================================

# Still need to work on these…
# atip_2006_07 <- parse_atip_xml(atip_2006_07.file, year = 2007)
#
# atip_2007_08 <- parse_atip_xml(atip_2007_08.file, year = 2008)
#
# atip_2008_09 <- parse_atip_xml(atip_2008_09.file, year = 2009)
#
# atip_2009_10 <- parse_atip_xml(atip_2009_10.file, year = 2010)
#
# atip_2010_11 <- parse_atip_xml(atip_2010_11.file, year = 2011)
#
# atip_2011_12 <- parse_atip_xml(atip_2011_12.file, year = 2012)
#
# atip_2012_13 <- parse_atip_xml(atip_2012_13.file, year = 2013)
#
# atip_2013_14 <- parse_atip_xml(atip_2013_14.file, year = 2014)
#
# atip_2014_15 <- parse_atip_xml(atip_2014_15.file, year = 2015)
#
# read_xml(atip_2011_12.file) %>%
#   xml_find_first('//reports/report') %>%
#   flatten_xml_recursively() %>%
#   select(starts_with('level'), 'names', 'values')
#
#ati_2014_15 <- read_xml(atip_2014_15.file) %>%
#   xml_find_first('//report') %>%
#   flatten_xml_recursively() %>%
#   select(starts_with('level'), 'names', 'values')

ati_2015_16 <- tidy_ati_stats(ati_2015_16.file, request_type = 'ATI', fy_ending = 2016, header_rows = 5)
privacy_2015_16 <- tidy_ati_stats(privacy_2015_16.file, request_type = 'Privacy', fy_ending = 2016, header_rows = 4)

ati_2016_17 <- tidy_ati_stats(ati_2016_17.file, request_type = 'ATI', fy_ending = 2017, header_rows = 5)
privacy_2016_17 <- tidy_ati_stats(privacy_2016_17.file, request_type = 'Privacy', fy_ending = 2017, header_rows = 5)

ati_2017_18 <- tidy_ati_stats(ati_2017_18.file, request_type = 'ATI', fy_ending = 2018, header_rows = 5)
privacy_2017_18 <- tidy_ati_stats(privacy_2017_18.file, request_type = 'Privacy', fy_ending = 2018, header_rows = 5)

ati_2018_19 <- tidy_ati_stats(ati_2018_19.file, request_type = 'ATI', fy_ending = 2019, header_rows = 5)
privacy_2018_19 <- tidy_ati_stats(privacy_2018_19.file, request_type = 'Privacy', fy_ending = 2019, header_rows = 5)

ati_2019_20 <- tidy_ati_stats(ati_2019_20.file, request_type = 'ATI', fy_ending = 2020, header_rows = 3)
privacy_2019_20 <- tidy_ati_stats(privacy_2019_20.file, request_type = 'Privacy', fy_ending = 2020, header_rows = 3)

ati_2020_21 <- tidy_ati_stats(ati_2020_21.file, request_type = 'ATI', fy_ending = 2021, header_rows = 3)
privacy_2020_21 <- tidy_ati_stats(privacy_2020_21.file, request_type = 'Privacy', fy_ending = 2021, header_rows = 3)

ati_2021_22 <- tidy_ati_stats(ati_2021_22.file, request_type = 'ATI', fy_ending = 2022, header_rows = 3)
privacy_2021_22 <- tidy_ati_stats(privacy_2021_22.file, request_type = 'Privacy', fy_ending = 2022, header_rows = 3)

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

# TODO: str_squish on categories, subcategories and metrics

completed_ati <- parse_completed_atips(completed_ati.file)

completed_ati_historical <- parse_completed_atips(completed_ati_historical.file)

# bind_rows(
#   completed_ati,
#   completed_ati_historical
# ) %>%
# distinct()

write_feather(atip, dir_data_processed('atip.feather'))
