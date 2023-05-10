# =======================================================================
# This file handles the primary analysis using the tidied  data as input.
# Should never read from `dir_data_raw()`, only `dir_data_processed()`.
# =======================================================================

atip <- read_feather(dir_data_processed('atip.feather'))

ati_overall <- atip %>%
  filter(request_type == 'ATI') %>%
  filter(str_detect(category, fixed('1.1'))) %>%
  filter(subcategory == 'Number of Requests') %>%
  group_by(fy_ending, institution, metric) %>%
  summarise(n = sum(value)) %>%
  ungroup() %>%
  mutate(is_ircc = case_when(
    institution == 'Citizenship and Immigration Canada' ~ TRUE,
    institution == 'Immigration Refugees and Citizenship Canada' ~ TRUE,
    TRUE ~ FALSE
  ))

# 80% of ATI files received by government are to IRCC
ati_overall %>%
  filter(metric == 'Received during reporting period') %>%
  group_by(fy_ending, is_ircc) %>%
  summarise(n = sum(n)) %>%
  mutate(pct = n / sum(n)) %>%
  ggplot(aes(x = fy_ending, y = pct, color = is_ircc)) +
  geom_line()

# But even excluding IRCC, requests have still grown
ati_overall %>%
  filter(metric == 'Received during reporting period') %>%
  group_by(fy_ending, is_ircc) %>%
  summarise(n = sum(n)) %>%
  ggplot(aes(x = fy_ending, y = n, color = is_ircc)) +
  geom_line()

# Carry-over percentages
ati_overall %>%
  filter(metric %in% c('Total', 'Carried over to next reporting period')) %>%
  spread(metric, n) %>%
  group_by(fy_ending, institution) %>%
  mutate(
    carried_over_pct = `Carried over to next reporting period` / Total
  ) %>%
  filter(Total >= 500) %>%
  filter(fy_ending == 2022) %>%
  arrange(carried_over_pct) %>%
  View()

# Overall pct
ati_overall %>%
  filter(metric %in% c('Total', 'Carried over to next reporting period')) %>%
  group_by(fy_ending, is_ircc, metric) %>%
  summarise(n = sum(n)) %>%
  spread(metric, n) %>%
  mutate(pct = `Carried over to next reporting period` / Total) %>%
  ungroup() %>%
  arrange(is_ircc, fy_ending)

  spread(metric, n) %>%
  group_by(fy_ending, institution) %>%
  mutate(
    carried_over_pct = `Carried over to next reporting period` / Total
  ) %>%
  filter(Total >= 500) %>%
  # filter(fy_ending == 2022) %>%
  arrange(carried_over_pct)

# Sources: those declaring themselves as "media" are at an all-time low. However, some members of the media do not identify themselves as such, and "decline to identify" has ticked upwards
atip %>%
  filter(request_type == 'ATI') %>%
  filter(category == '1.2 Sources of requests') %>%
  select(fy_ending, institution, metric, value) %>%
  mutate(is_ircc = case_when(
    institution == 'Citizenship and Immigration Canada' ~ TRUE,
    institution == 'Immigration Refugees and Citizenship Canada' ~ TRUE,
    TRUE ~ FALSE
  )) %>%
  group_by(fy_ending, is_ircc, metric) %>%
  summarise(n = sum(value)) %>%
  spread(metric, n) %>%
  filter(!is_ircc) %>%
  select(-Total, -is_ircc) %>%
  pivot_longer(Academia:Public) %>%
  group_by(fy_ending) %>%
  mutate(
    pct = value / sum(value)
  ) %>%
  ggplot(aes(x = fy_ending, y = pct, color = name)) +
  geom_line()

# Sources, indexed… easier to read
atip %>%
  filter(request_type == 'ATI') %>%
  filter(category == '1.2 Sources of requests') %>%
  select(fy_ending, institution, metric, value) %>%
  mutate(is_ircc = case_when(
    institution == 'Citizenship and Immigration Canada' ~ TRUE,
    institution == 'Immigration Refugees and Citizenship Canada' ~ TRUE,
    TRUE ~ FALSE
  )) %>%
  group_by(fy_ending, is_ircc, metric) %>%
  summarise(n = sum(value)) %>%
  spread(metric, n) %>%
  filter(!is_ircc) %>%
  select(-Total, -is_ircc) %>%
  pivot_longer(Academia:Public) %>%
  group_by(name) %>%
  mutate(
    index = calc_index(value)
  ) %>%
  ggplot(aes(x = fy_ending, y = index, color = name)) +
  geom_line()

# Pages - 12% increase, roughly, for both IRCC and non-IRCC requests
atip %>%
  filter(request_type == 'ATI') %>%
  filter(metric == 'Number of Pages Disclosed') %>%
  select(fy_ending, institution, value) %>%
  mutate(is_ircc = case_when(
    institution == 'Citizenship and Immigration Canada' ~ TRUE,
    institution == 'Immigration Refugees and Citizenship Canada' ~ TRUE,
    TRUE ~ FALSE
  )) %>%
  group_by(fy_ending, is_ircc) %>%
  summarise(n = sum(value)) %>%
  group_by(is_ircc) %>%
  mutate(
    chg = calc_index(n)
  )

# Formats: rapid move away from paper products. went from a third paper in 2020 to 7 per cent in 2022
bind_rows(
    atip %>%
      filter(request_type == 'ATI') %>%
      filter(category == '2.4 Format of information released' | category == '3.4 Format of information released') %>%
      filter(metric == 'Total') %>%
      mutate(is_ircc = case_when(
        institution == 'Citizenship and Immigration Canada' ~ TRUE,
        institution == 'Immigration Refugees and Citizenship Canada' ~ TRUE,
        TRUE ~ FALSE
      )) %>%
      group_by(fy_ending, is_ircc, subcategory) %>%
      summarise(n = sum(value)),

    atip %>%
      filter(request_type == 'ATI') %>%
      filter(category == '3.4  Format of information released') %>%
      mutate(is_ircc = case_when(
        institution == 'Citizenship and Immigration Canada' ~ TRUE,
        institution == 'Immigration Refugees and Citizenship Canada' ~ TRUE,
        TRUE ~ FALSE
      )) %>%
      group_by(fy_ending, is_ircc, metric) %>%
      summarise(n = sum(value)) %>%
      rename(subcategory = 'metric'),

    atip %>%
      filter(request_type == 'ATI') %>%
      filter(category == '4.4 Format of information released') %>%
      mutate(is_ircc = case_when(
        institution == 'Citizenship and Immigration Canada' ~ TRUE,
        institution == 'Immigration Refugees and Citizenship Canada' ~ TRUE,
        TRUE ~ FALSE
      )) %>%
      group_by(fy_ending, is_ircc, subcategory) %>%
      summarise(n = sum(value))
  ) %>%
  ungroup() %>%
  mutate(subcategory = case_when(
    subcategory == 'Other' ~ 'Other Formats',
    TRUE ~ subcategory
  )) %>%
  pivot_wider(names_from = subcategory, values_from = n) %>%
  mutate(
    total = Electronic + `Other Formats` + Paper,
    paper_pct = Paper / total
  ) %>%
  arrange(is_ircc, fy_ending)

# Informal requests

# Closed after leg deadline - also pull out specific institutions
bind_rows(
    atip %>%
      filter(request_type == 'ATI') %>%
      filter(str_detect(category, fixed('3.6'))) %>%
      filter(metric == 'Percentage of requests closed within legislated timelines (%)'),
    atip %>%
      filter(request_type == 'ATI') %>%
      filter(str_detect(category, fixed('4.6.1'))) %>%
      filter(metric == 'Percentage of requests closed within legislated timelines (%)')
  )




  filter(subcategory == 'Number of Requests') %>%
  mutate(is_ircc = case_when(
    institution == 'Citizenship and Immigration Canada' ~ TRUE,
    institution == 'Immigration Refugees and Citizenship Canada' ~ TRUE,
    TRUE ~ FALSE
  ))
