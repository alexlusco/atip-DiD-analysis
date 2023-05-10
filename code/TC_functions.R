# =======================================================================
# Project-specific functions.
# =======================================================================

read_atip_file <- function(
    filename,
    request_type = NA,
    skip = 5,
    names = c('org', 'received', 'outstanding', 'total'),
    types = 'ciii',
    fy_ending = NA
  ) {
    if (str_detect(filename, '\\.csv$')) {
      df <- suppressWarnings(read_csv(
        filename,
        skip = skip,
        col_names = names,
        col_types = types
      ))

    } else {
      if (types == 'ciii') types <- c('text', 'numeric', 'numeric', 'numeric')
      df <- suppressWarnings(read_excel(
          filename,
          range = cell_cols(1:length(names)),
          col_names = names,
          col_types = types
        )) %>%
        filter(row_number() %not_in% 1:skip)
    }
    df %>%
      mutate(
        request_type = request_type,
        fy_ending = fy_ending
      )
  }

# extract_atip_stats_xml_2014_2015 <- function(node, type, org, year) {
# }

extract_atip_stats_xml_2014_2015 <- function(node, type, org, year) {
  if (year == 2015) {
    if (type == 'ATI') {
      query <- glue('.//{type}/Part1/Section1.1')
    } else {
      query <- glue('.//{type}/Part1')
    }
  } else if (year == 2014) {
    query <- glue('.//{type}/Section1.1')
  }

  stats_section <- node %>%
    xml_find_first(query)

  received <- stats_section %>%
    xml_find_first('..//ReceivedDuringPeriod') %>%
    xml_text() %>%
    as.integer

  outstanding <- stats_section %>%
    xml_find_first('..//OutstandingFromPrevious') %>%
    xml_text() %>%
    as.integer

  total <- received + outstanding

  tibble(
    org = org,
    received = received,
    outstanding = outstanding,
    total = received + outstanding,
    request_type = ifelse(type == 'ATI', 'ati', 'privacy')
  )
}

parse_atip_xml_report_2007_2010 <- function(report, year = NA) {

}

parse_atip_xml_report_2011_2013 <- function(data, year = NA) {
  # # will have to handle idrefs
  # xml_find_all('//reports/report') %>%
  # map_dfr(parse_atip_xml, year = 2011)
}

parse_atip_xml_report_2014_2015 <- function(report, year = NA) {
  org <- report %>%
    xml_find_first('.//institution/nameEng') %>%
    xml_text()

  ati_data <- extract_atip_stats_xml_2014_2015(report, 'ATI', org, year)
  privacy_data <- extract_atip_stats_xml_2014_2015(report, 'Privacy', org, year)

  combined <- bind_rows(
      ati_data,
      privacy_data
    ) %>%
    mutate(fy_ending = year)

  return(combined)
}

parse_atip_xml <- function(file, year = NA) {

  # read_xml(atip_2011_12.file) %>%
  #   xml_find_first('//reports/report') %>%
  #   flatten_xml_recursively() %>%
  #   select(starts_with('level'), 'names', 'values')

  if (year %in% 2007:2010) {
    # these files all have the same format
    df <- read_xml(file) %>%
      xml_find_all('//institution') %>%
      map_dfr(parse_atip_xml_report_2007_2010, year = year)
  }

  if (year %in% 2011:2013) {
    df <- read_xml(file) %>%
      parse_atip_xml_report_2011_2013(year = year)
  }

  if (year %in% 2014:2015) {
    df <- read_xml(file) %>%
      xml_find_all('//report') %>%
      map_dfr(parse_atip_xml_report_2014_2015, year = year)
  }

  return(df)

}

flatten_xml_recursively <- function(node, depth = 0, data = tibble()) {
  node_has_children <- node %>%
    xml_length() %>%
    as.logical() %>%
    all()

  if (node_has_children) {
    # recurse further…

    new_data <- node %>%
      xml_name() %>%
      tibble('level_{depth}' := .) %>%
      select(-`.`)

    if (length(data) != 0) {
      new_data <- data %>%
        crossing(new_data, .name_repair = 'minimal')
    }

    children <- node %>%
      xml_children()

    final_table <- tibble()

    for (child in children) {
      final_table <- bind_rows(
        final_table,
        flatten_xml_recursively(child, depth = depth + 1, data = new_data)
      )
    }

    return(final_table)

  } else {

    names <- node %>%
      xml_name()

    values <- node %>%
      xml_text() %>%
      as.integer()

    df <- tibble(names, values)

    final_table <- data %>%
      bind_cols(df, .name_repair = 'unique')

    return(final_table)

  }

}

parse_completed_atips <- function(file) {
  completed_request_cols <- cols(
    year = col_double(),
    month = col_double(),
    request_number = col_character(),
    summary_en = col_character(),
    summary_fr = col_character(),
    disposition = col_character(),
    pages = col_double(),
    comments_en = col_character(),
    comments_fr = col_character(),
    umd_number = col_double(),
    owner_org = col_character(),
    owner_org_title = col_character()
  )

  read_csv(
      file,
      col_types = completed_request_cols
    ) %>%
    select(-summary_fr, -comments_en, -comments_fr) %>%
    mutate(
      disposition = case_when(
        disposition == 'DA' ~ 'All disclosed',
        disposition == 'DP' ~ 'Disclosed in part',
        disposition == 'EC' ~ 'All excluded',
        disposition == 'EX' ~ 'All exempted',
        disposition == 'NE' ~ 'No records exist'
      )
    )
}

read_tabular_atip_file <- function(filename, ...) {

  extension <- filename %>%
    str_extract('\\.[0-9a-z]+$') %>%
    str_replace('.', '')

  filetype <- NA

  if (extension %in% c('xls', 'xlsx')) {
    filetype <- 'excel'
  } else if (extension == 'csv') {
    filetype <- 'csv'
  }

  if (is.na(filetype)) return()

  use_col_type <- FALSE
  use_skip <- FALSE
  use_col_names <- FALSE
  use_n_max <- FALSE

  args <- list(...)

  if ('col_type' %in% names(args)) use_col_type <- TRUE
  if ('skip' %in% names(args)) use_skip <- TRUE
  if ('col_names' %in% names(args)) use_col_names <- TRUE
  if ('n_max' %in% names(args)) use_n_max <- TRUE

  col_type_parameter <- NA

  if (use_col_type) {
    if (filetype == 'excel') col_type_parameter <- 'text'
    if (filetype == 'csv') col_type_parameter <- cols(.default = 'c')
  }

  filter_arg_vector <- c(
    TRUE,
    use_skip,
    use_col_names,
    use_n_max,
    use_col_type
  )

  partial_arg_list <- list(
    filename,
    skip = args$skip,
    col_names = args$col_names,
    n_max = args$n_max
  )

  if (filetype == 'excel') {
    final_arg_list <- append(partial_arg_list, list(col_type = col_type_parameter))
  }

  if (filetype == 'csv') {
    final_arg_list <- append(partial_arg_list, list(col_types = col_type_parameter))
  }

  reading_fn <- ifelse(filetype == 'excel', read_excel, read_csv)

  do.call(reading_fn, final_arg_list[filter_arg_vector])

}

tidy_ati_stats <- function(curr_file, request_type, fy_ending, header_rows) {

  header_data_messy <- read_tabular_atip_file(curr_file, col_names = FALSE, n_max = header_rows, col_type = 'text')

  first_header_empty <- header_data_messy %>%
    select(1) %>%
    na.omit() %>%
    nrow() %>%
    as.logical() %>%
    isFALSE()

  if (first_header_empty) {
    header_data_messy <- header_data_messy %>%
      select(-1)
  }

  header_data <- header_data_messy %>%
    filter_all(any_vars(!is.na(.))) %>%
    mutate(row_id = row_number()) %>%
    select(row_id, everything())

  header_data_cols <- header_data %>%
    select(2, ncol(.)) %>%
    names()

  header_clean <- header_data %>%
    pivot_longer(header_data_cols[1]:header_data_cols[2]) %>%
    group_by(row_id) %>%
    fill(value, .direction = "down") %>%
    pivot_wider(row_id) %>%
    ungroup() %>%
    select(-row_id) %>%
    t(.) %>%
    as_tibble(.) %>%
    rename(
      category = 1,
      subcategory = 2,
      metric = 3
    ) %>%
    mutate(col_id = row_number())

  rest_of_data <- read_tabular_atip_file(curr_file, col_names = FALSE, skip = header_rows, col_type = 'text')

  rest_of_data_cols <- rest_of_data %>%
    select(2, ncol(.)) %>%
    names()

  rest_of_data %>%
    pivot_longer(rest_of_data_cols[1]:rest_of_data_cols[2]) %>%
    rename(
      institution = 1,
      col_id = 2,
      value = 3
    ) %>%
    mutate(
      col_id = col_id %>%
        str_replace(fixed('...'), '') %>%
        str_replace(fixed('X'), '') %>%
        as.numeric() %>%
        -(1)
    ) %>%
    left_join(header_clean, by = 'col_id') %>%
    select(-col_id) %>%
    mutate(
      request_type = request_type,
      fy_ending = fy_ending,
      value = as.numeric(value)
    ) %>%
    select(fy_ending, request_type, institution, category, subcategory, metric, value)

}
