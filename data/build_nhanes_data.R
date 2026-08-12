#!/usr/bin/env Rscript
#
# Builds every course dataset under data/nhanes/ from public source files.
#
#   Rscript data/build_nhanes_data.R        # run from the repo root
#
# Sources:
#   NHANES 2017-2018 component files   https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2017/DataFiles/
#   NHANES DEMO files, 1999-2018       (same host, one directory per cycle start year)
#   BRFSS prevalence, 2023             https://data.cdc.gov/resource/dttw-5yxu
#
# Downloaded .xpt files are cached in data/nhanes/source/ (git-ignored). Delete that
# directory to force a re-download.
#
# The script is deterministic: every random step is seeded, so a second run reproduces
# the CSVs byte for byte. See data/nhanes/README.md for which columns are measured and
# which are synthesized.

suppressPackageStartupMessages({
  library(tidyverse)
  library(haven)
})

out_dir    <- "data/nhanes"
source_dir <- file.path(out_dir, "source")
dir.create(source_dir, recursive = TRUE, showWarnings = FALSE)

# ---------------------------------------------------------------------------
# download helper
# ---------------------------------------------------------------------------

# The CDC host throttles rapid bursts and returns an empty body, so retry with a pause.
fetch <- function(url, dest, tries = 5) {
  if (file.exists(dest) && file.size(dest) > 1000) return(invisible(dest))
  for (i in seq_len(tries)) {
    ok <- tryCatch({
      download.file(url, dest, mode = "wb", quiet = TRUE)
      file.exists(dest) && file.size(dest) > 1000
    }, error = function(e) FALSE)
    if (ok) return(invisible(dest))
    unlink(dest)
    message("  retry ", i, " for ", basename(dest))
    Sys.sleep(3 * i)
  }
  stop("could not download ", url)
}

read_nhanes <- function(file, cycle_year = 2017) {
  dest <- file.path(source_dir, paste0(file, ".xpt"))
  fetch(sprintf("https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/%s/DataFiles/%s.xpt",
                cycle_year, file), dest)
  read_xpt(dest)
}

message("downloading NHANES 2017-2018 component files")
demo <- read_nhanes("DEMO_J")     # demographics
bmx  <- read_nhanes("BMX_J")      # body measures
bpx  <- read_nhanes("BPX_J")      # blood pressure
tchol<- read_nhanes("TCHOL_J")    # total cholesterol
hdl  <- read_nhanes("HDL_J")      # HDL cholesterol
ghb  <- read_nhanes("GHB_J")      # glycohemoglobin (HbA1c)
glu  <- read_nhanes("GLU_J")      # fasting plasma glucose
diq  <- read_nhanes("DIQ_J")      # diabetes questionnaire
smq  <- read_nhanes("SMQ_J")      # smoking
paq  <- read_nhanes("PAQ_J")      # physical activity
slq  <- read_nhanes("SLQ_J")      # sleep
hsq  <- read_nhanes("HSQ_J")      # current health status
rxq  <- read_nhanes("RXQ_RX_J")   # prescription medications

# ---------------------------------------------------------------------------
# nhanes.csv -- the main participant-level table (lectures 2-5)
# ---------------------------------------------------------------------------

# Codebook labels, spelled out so the CSV is readable without the NHANES documentation.
race_labels <- c(
  "1" = "Mexican American", "2" = "Other Hispanic", "3" = "White",
  "4" = "Black", "6" = "Asian", "7" = "Other"
)
education_labels <- c(
  "1" = "Less than 9th grade", "2" = "9-11th grade", "3" = "High school",
  "4" = "Some college", "5" = "College grad"
)
health_labels <- c(
  "1" = "Excellent", "2" = "Very good", "3" = "Good", "4" = "Fair", "5" = "Poor"
)

message("building nhanes.csv")

nhanes <- demo |>
  transmute(
    SEQN,
    RIDSTATR,
    RIDEXMON,
    DMDBORN4,
    id  = sprintf("NHANES-%d", SEQN),
    age = RIDAGEYR,
    age_group = cut(RIDAGEYR, c(-1, 19, 39, 59, 79, Inf),
                    labels = c("0-19", "20-39", "40-59", "60-79", "80+")) |> as.character(),
    sex = if_else(RIAGENDR == 1, "male", "female"),
    race      = unname(race_labels[as.character(RIDRETH3)]),
    education = unname(education_labels[as.character(DMDEDUC2)])
  ) |>
  left_join(bmx   |> select(SEQN, weight_kg = BMXWT, height_cm = BMXHT,
                            bmi = BMXBMI, waist_cm = BMXWAIST), by = "SEQN") |>
  left_join(bpx   |> select(SEQN, pulse = BPXPLS,
                            bp_sys_1 = BPXSY1, bp_sys_2 = BPXSY2,
                            bp_sys_3 = BPXSY3, bp_sys_4 = BPXSY4,
                            bp_dia_1 = BPXDI1, bp_dia_2 = BPXDI2,
                            bp_dia_3 = BPXDI3, bp_dia_4 = BPXDI4), by = "SEQN") |>
  left_join(tchol |> select(SEQN, cholesterol = LBXTC), by = "SEQN") |>
  left_join(hdl   |> select(SEQN, hdl = LBDHDD), by = "SEQN") |>
  left_join(ghb   |> select(SEQN, hba1c = LBXGH), by = "SEQN") |>
  left_join(glu   |> select(SEQN, glucose = LBXGLU), by = "SEQN") |>
  left_join(diq   |> transmute(SEQN, diabetes = case_match(DIQ010,
                                 1 ~ "Yes", 2 ~ "No", 3 ~ "Borderline",
                                 .default = NA_character_)), by = "SEQN") |>
  left_join(smq   |> transmute(SEQN, smoke_now = case_match(SMQ040,
                                 c(1, 2) ~ "Yes", 3 ~ "No",
                                 .default = NA_character_)), by = "SEQN") |>
  left_join(paq   |> transmute(SEQN, phys_active = case_match(PAQ665,
                                 1 ~ "Yes", 2 ~ "No",
                                 .default = NA_character_)), by = "SEQN") |>
  left_join(slq   |> transmute(SEQN, sleep_hours = if_else(SLD012 > 24, NA_real_, SLD012)),
            by = "SEQN") |>
  left_join(hsq   |> transmute(SEQN, health_gen = unname(health_labels[as.character(HSD010)])),
            by = "SEQN") |>
  # Diastolic readings of 0 mean "could not be measured", not a blood pressure of zero.
  mutate(across(starts_with("bp_dia_"), \(x) if_else(x == 0, NA_real_, x)))

nhanes_out <- nhanes |>
  select(id, age, age_group, sex, race, education,
         weight_kg, height_cm, bmi, waist_cm, pulse,
         bp_sys_1, bp_sys_2, bp_sys_3, bp_sys_4,
         bp_dia_1, bp_dia_2, bp_dia_3, bp_dia_4,
         cholesterol, hdl, hba1c, glucose,
         diabetes, smoke_now, phys_active, sleep_hours, health_gen) |>
  arrange(id)

write_csv(nhanes_out, file.path(out_dir, "nhanes.csv"), na = "NA")

# ---------------------------------------------------------------------------
# nhanes_subset.csv -- 59 adults, complete on six measures (lectures 1-2)
#
# Layout mirrors the file it replaces: five description columns, then six numeric
# measurement columns in positions 6:11, so names(nhanes)[6:11] still works.
# ---------------------------------------------------------------------------

message("building nhanes_subset.csv")

# Dropping the handful of participants above 300 mg/dL keeps one extreme outlier from
# squashing every scatterplot in lecture 1 into the left-hand third of the panel. It costs
# 1% of the eligible pool and still spans normal to poorly-controlled diabetic glucose.
# glucose and hba1c lead the measurement block because they are the pair lecture 1 plots, and
# the eleventh column of a tibble does not print at 80 characters. Positions 6:11 must stay the
# six measurements either way: the last slide of lecture 1 pivots names(nhanes)[6:11].
subset_pool <- nhanes_out |>
  filter(age >= 20, diabetes %in% c("Yes", "No"), glucose < 300) |>
  select(id, age, sex, race, diabetes,
         glucose, hba1c, bmi, waist_cm, bp_sys_1, cholesterol) |>
  drop_na()

set.seed(20260812)
nhanes_subset <- bind_rows(
  subset_pool |> filter(diabetes == "Yes") |> slice_sample(n = 30),
  subset_pool |> filter(diabetes == "No")  |> slice_sample(n = 29)
) |>
  arrange(id)

write_csv(nhanes_subset, file.path(out_dir, "nhanes_subset.csv"))

# ---------------------------------------------------------------------------
# Exam logistics: sessions, exams, participants (lecture 4 joins, practice 2-3)
#
# NHANES publishes the six-month window each exam fell in (RIDEXMON) but not exam
# dates, session times, or examination-center assignments. Those are simulated here,
# inside the true window, so the date-handling exercises have something to work on.
# ---------------------------------------------------------------------------

message("building exam session tables")

components <- c("body measures", "blood pressure", "phlebotomy", "oral health")

# Weekdays across the two field years. RIDEXMON 1 covers Nov-Apr, 2 covers May-Oct.
all_days <- tibble(date = seq(as.Date("2017-01-01"), as.Date("2018-12-31"), by = "day")) |>
  mutate(
    weekday = !(format(date, "%u") %in% c("6", "7")),
    window  = if_else(as.integer(format(date, "%m")) %in% 5:10, 2L, 1L)
  ) |>
  filter(weekday) |>
  select(date, window)

sessions <- all_days |>
  cross_join(tibble(session_type = c("morning", "afternoon", "evening"))) |>
  arrange(date, match(session_type, c("morning", "afternoon", "evening"))) |>
  mutate(
    session_id = sprintf("MEC-%s-%s", format(date, "%Y%m%d"), toupper(substr(session_type, 1, 1))),
    # One of three mobile examination teams works a stretch of consecutive weeks.
    center_id  = paste0("MEC", (as.integer(strftime(date, "%V")) %% 3) + 1)
  )

examined <- nhanes |>
  filter(RIDSTATR == 2, !is.na(RIDEXMON)) |>
  select(SEQN, id, RIDEXMON) |>
  arrange(id)

# Spread participants evenly over the sessions whose window matches their exam period.
set.seed(20260812)
assign_sessions <- function(window_value) {
  people <- examined |> filter(RIDEXMON == window_value)
  slots  <- sessions |> filter(window == window_value) |> pull(session_id)
  people |> mutate(session_id = slots[1 + (sample(nrow(people)) %% length(slots))])
}
participant_sessions <- bind_rows(assign_sessions(1L), assign_sessions(2L)) |> arrange(id)

# Each component's primary measurement tells us whether that component was completed.
component_done <- nhanes |>
  transmute(
    SEQN,
    `body measures`  = !is.na(bmi),
    `blood pressure` = !is.na(bp_sys_1),
    phlebotomy       = !is.na(cholesterol),
    `oral health`    = !is.na(waist_cm)
  ) |>
  pivot_longer(-SEQN, names_to = "component", values_to = "completed")

# Components run in a fixed order within a session, each in its own room.
component_clock <- tibble(
  component   = components,
  start_after = c(0L, 25L, 50L, 80L),   # minutes into the session
  minutes     = c(20L, 20L, 25L, 30L)
)
session_clock <- tibble(
  session_type = c("morning", "afternoon", "evening"),
  session_hour = c(8L, 13L, 17L)
)

exams <- participant_sessions |>
  cross_join(tibble(component = components)) |>
  left_join(component_done, by = c("SEQN", "component")) |>
  left_join(sessions |> select(session_id, session_type, center_id, date), by = "session_id") |>
  left_join(component_clock, by = "component") |>
  left_join(session_clock, by = "session_type") |>
  mutate(
    exam_id    = sprintf("EX-%d-%d", SEQN, match(component, components)),
    status_code = if_else(completed, 1L, 2L),
    start_time = as.POSIXct(paste(date, sprintf("%02d:00:00", session_hour)), tz = "UTC") +
                   start_after * 60,
    exam_start = format(start_time, "%Y-%m-%dT%H:%M:%SZ"),
    exam_end   = format(start_time + minutes * 60, "%Y-%m-%dT%H:%M:%SZ")
  ) |>
  arrange(id, match(component, components))

# Deliberately narrow. A tibble prints only what fits in 80 characters, so every column here
# costs one that a join could otherwise show. The timestamps and status code live in the
# practice copy below, which is read from a file rather than printed on a slide.
write_csv(
  exams |> select(participant_id = id, exam_id, session_id, center_id, component),
  file.path(out_dir, "nhanes_exams.csv")
)

write_csv(
  sessions |>
    filter(session_id %in% participant_sessions$session_id) |>
    transmute(session_id, session_type, session_date = format(date, "%m/%d/%Y")) |>
    arrange(session_id),
  file.path(out_dir, "nhanes_sessions.csv")
)

# birth_date is back-calculated from the reported age at exam, so it is consistent with
# the published age but is not the participant's real date of birth.
set.seed(20260812)
participants <- nhanes |>
  select(SEQN, id, sex, age, age_group, race, education, DMDBORN4) |>
  left_join(exams |> filter(component == "body measures") |> select(SEQN, date), by = "SEQN") |>
  mutate(
    reference   = coalesce(date, as.Date("2018-06-30")),
    birth_date  = reference - (age * 365.25 + sample(0:364, n(), replace = TRUE)),
    birth_country = case_match(DMDBORN4, 1 ~ "United States", 2 ~ "Other",
                               .default = NA_character_)
  ) |>
  arrange(id)

# birth_country comes second on purpose: it is the variable the join exercise asks about, and
# a joined-in column has to survive into the printed output for the exercise to be checkable.
write_csv(
  participants |> select(participant_id = id, birth_country, sex, age_group, race,
                         education, birth_date),
  file.path(out_dir, "nhanes_participants.csv")
)

# ---------------------------------------------------------------------------
# Aggregates used by the pivot and multi-column join sections
# ---------------------------------------------------------------------------

message("building aggregate tables")

exam_dates <- exams |>
  transmute(participant_id = id, component, session_type, center_id,
            session_date = format(date, "%Y-%m-%d"))
write_csv(exam_dates, file.path(out_dir, "nhanes_exam_dates.csv"))

monthly_components <- exams |>
  count(component,
        month = as.integer(format(date, "%m")),
        year  = as.integer(format(date, "%Y")),
        name  = "n_exams") |>
  arrange(component, year, month)
write_csv(monthly_components, file.path(out_dir, "nhanes_monthly_components.csv"))

# Total exams per month, across all four components, so it can be joined against the
# per-component counts above on both month and year.
monthly_exams <- exams |>
  count(month = as.integer(format(date, "%m")),
        year  = as.integer(format(date, "%Y")),
        name  = "n_exams_total") |>
  arrange(year, month)
write_csv(monthly_exams, file.path(out_dir, "nhanes_monthly_exams.csv"))

# ---------------------------------------------------------------------------
# nhanes_cycle_counts.csv -- participants examined per age group, per survey cycle
#
# Wide on purpose: the column names are bare years, which is what makes this a good
# example of data that needs tidying.
# ---------------------------------------------------------------------------

message("building nhanes_cycle_counts.csv (10 survey cycles)")

cycles <- tribble(
  ~start_year, ~file,
  1999L, "DEMO",   2001L, "DEMO_B", 2003L, "DEMO_C", 2005L, "DEMO_D", 2007L, "DEMO_E",
  2009L, "DEMO_F", 2011L, "DEMO_G", 2013L, "DEMO_H", 2015L, "DEMO_I", 2017L, "DEMO_J"
)

cycle_counts <- cycles |>
  pmap(\(start_year, file) {
    read_nhanes(file, cycle_year = start_year) |>
      filter(RIDSTATR == 2) |>
      transmute(
        start_year,
        age_group = cut(RIDAGEYR, c(-1, 19, 39, 59, 79, Inf),
                        labels = c("0-19", "20-39", "40-59", "60-79", "80+")) |> as.character()
      )
  }) |>
  bind_rows() |>
  count(age_group, start_year) |>
  pivot_wider(names_from = start_year, values_from = n, values_fill = 0) |>
  arrange(age_group)

write_csv(cycle_counts, file.path(out_dir, "nhanes_cycle_counts.csv"))

# ---------------------------------------------------------------------------
# nhanes_medications.csv -- prescription medications (practice 4)
# ---------------------------------------------------------------------------

message("building nhanes_medications.csv")

meds_all <- rxq |>
  filter(RXDUSE == 1, !is.na(RXDDRGID), RXDDRGID != "") |>
  transmute(
    participant_id = sprintf("NHANES-%d", SEQN),
    drug_name = RXDDRUG,
    drug_id   = RXDDRGID,
    days_taken = if_else(RXDDAYS %in% c(77777, 99999), NA_real_, RXDDAYS),
    reason_code = na_if(RXDRSC1, "")
  )

# Cap at the 150 most widely used drugs so that pivoting to one column per drug stays fast.
top_drugs <- meds_all |>
  distinct(participant_id, drug_id) |>
  count(drug_id, sort = TRUE) |>
  slice_head(n = 150) |>
  pull(drug_id)

medications <- meds_all |>
  filter(drug_id %in% top_drugs) |>
  arrange(participant_id, drug_id)

write_csv(medications, file.path(out_dir, "nhanes_medications.csv"))

# ---------------------------------------------------------------------------
# state_health.csv -- BRFSS adult obesity prevalence by state (practice 1 map)
#
# NHANES releases no geographic identifiers, so the choropleth uses BRFSS instead.
# ---------------------------------------------------------------------------

message("building state_health.csv")

# 2022 is the most recent year that reports all 50 states; 2023 is missing two.
brfss_dest <- file.path(source_dir, "brfss_bmi_2022.csv")
fetch(paste0(
  "https://data.cdc.gov/resource/dttw-5yxu.csv",
  "?$select=locationabbr,locationdesc,response,data_value",
  "&$where=topic%3D%27BMI%20Categories%27%20AND%20break_out%3D%27Overall%27",
  "%20AND%20year%3D%272022%27&$limit=500"
), brfss_dest)

# The survey also covers national totals, territories, and DC; the map exercise wants states.
non_states <- c("US", "GU", "PR", "VI", "UW", "DC")

state_health <- read_csv(brfss_dest, show_col_types = FALSE) |>
  filter(!locationabbr %in% non_states, !is.na(data_value)) |>
  mutate(response = case_when(
    str_starts(response, "Obese")      ~ "obese_pct",
    str_starts(response, "Overweight") ~ "overweight_pct",
    TRUE ~ NA_character_
  )) |>
  filter(!is.na(response)) |>
  pivot_wider(id_cols = c(locationabbr, locationdesc),
              names_from = response, values_from = data_value) |>
  transmute(state = locationdesc, state_abbr = locationabbr, obese_pct, overweight_pct) |>
  drop_na() |>
  arrange(state)

write_csv(state_health, file.path(out_dir, "state_health.csv"))

# ---------------------------------------------------------------------------
# practice/data/ -- the practice notebooks read from relative paths, so they get their
# own copies. `participants.csv` is nhanes.csv plus the birth date, which the notebooks
# need for the age calculation.
# ---------------------------------------------------------------------------

message("building practice/data")

practice_dir <- "practice/data"
dir.create(practice_dir, recursive = TRUE, showWarnings = FALSE)

write_csv(
  nhanes_out |>
    left_join(participants |> select(id, birth_date), by = "id") |>
    relocate(birth_date, .after = id),
  file.path(practice_dir, "participants.csv")
)

write_csv(
  exams |> select(participant_id = id, exam_id, component, exam_start, exam_end,
                  center_id, session_type, status_code),
  file.path(practice_dir, "exams.csv")
)

write_csv(medications, file.path(practice_dir, "medications.csv"))
write_csv(state_health, file.path(practice_dir, "state_health.csv"))

# ---------------------------------------------------------------------------
# Checks on the specific facts the slides and exercises rely on
# ---------------------------------------------------------------------------

message("\nchecking slide assumptions")

check <- function(label, condition) {
  if (!isTRUE(condition)) stop("FAILED: ", label, call. = FALSE)
  message("  ok   ", label)
}

nh <- read_csv(file.path(out_dir, "nhanes.csv"), show_col_types = FALSE)
ns <- read_csv(file.path(out_dir, "nhanes_subset.csv"), show_col_types = FALSE)

check("nhanes.csv has 28 columns",              ncol(nh) == 28)
check("nhanes.csv has over 9000 rows",          nrow(nh) > 9000)
check("nhanes ids are unique",                  !any(duplicated(nh$id)))
check("subset is 59 x 11",                      all(dim(ns) == c(59, 11)))
check("subset numeric block is columns 6:11",   all(map_lgl(ns[6:11], is.numeric)))
check("subset has both sexes",                  n_distinct(ns$sex) == 2)
check("subset has both diabetes groups",        setequal(ns$diabetes, c("Yes", "No")))
check("subset has 3+ race groups",              n_distinct(ns$race) >= 3)
check("subset glucose/hba1c correlate",         cor(ns$glucose, ns$hba1c) > 0.6)

check("bp_sys_1 >= 180 is non-empty",           sum(nh$bp_sys_1 >= 180, na.rm = TRUE) > 0)
check("bp_sys_2 <= 80 is non-empty",            sum(nh$bp_sys_2 <= 80, na.rm = TRUE) > 0)
check("pulse pressure > 60 is non-empty",       sum(nh$bp_sys_1 - nh$bp_dia_1 > 60, na.rm = TRUE) > 0)
check("bmi >= 30 & bp_sys_1 >= 140 non-empty",  sum(nh$bmi >= 30 & nh$bp_sys_1 >= 140, na.rm = TRUE) > 0)
check("waist/height in [0.5, 0.6] non-empty",
      sum(between(nh$waist_cm / nh$height_cm, 0.5, 0.6), na.rm = TRUE) > 0)
check("non-diabetic under-30s over 6.5 hba1c",
      nh |> filter(!(diabetes == "Yes"), age < 30, hba1c > 6.5) |> nrow() > 0)
check("abs(bp_sys_1 - 120) > 40 non-empty",     sum(abs(nh$bp_sys_1 - 120) > 40, na.rm = TRUE) > 0)
check("bp_sys_4 is mostly missing",             mean(is.na(nh$bp_sys_4)) > 0.8)
check("bp_sys_1..3 are mostly present",         mean(is.na(nh$bp_sys_1)) < 0.4)
check("education has 5 levels",                 n_distinct(na.omit(nh$education)) == 5)
check("race has 6 levels",                      n_distinct(na.omit(nh$race)) == 6)
check("starts_with('bp_dia') picks 4 columns",  length(str_subset(names(nh), "^bp_dia")) == 4)
check("contains('age') picks 2 columns",        length(str_subset(names(nh), "age")) == 2)

# Six participants for the faceted pivot exercise. A fourth reading is only taken when an
# earlier one fails, so nobody has all four, and in practice a fourth reading always means the
# first one is missing. Mixing two kinds of participant means all four readings appear
# somewhere in the plot, with the same visible gaps the GTEx version had.
facet_ids <- bind_rows(
  nh |> filter(!is.na(bp_sys_1), !is.na(bp_sys_2), !is.na(bp_sys_3), is.na(bp_sys_4)) |>
    group_by(sex) |> slice_head(n = 1) |> ungroup(),
  nh |> filter(is.na(bp_sys_1), !is.na(bp_sys_2), !is.na(bp_sys_3), !is.na(bp_sys_4)) |>
    group_by(sex) |> slice_head(n = 2) |> ungroup()
) |> arrange(sex, id)
check("6 participants for the facet exercise", nrow(facet_ids) == 6)
check("all four readings appear among them",
      facet_ids |> summarize(across(bp_sys_1:bp_sys_4, \(x) any(!is.na(x)))) |> unlist() |> all())
message("     facet exercise ids: ", paste(facet_ids$id, collapse = ", "))

ex  <- read_csv(file.path(out_dir, "nhanes_exams.csv"), show_col_types = FALSE)
pt  <- read_csv(file.path(out_dir, "nhanes_participants.csv"), show_col_types = FALSE)
se  <- read_csv(file.path(out_dir, "nhanes_sessions.csv"), show_col_types = FALSE)
cc  <- read_csv(file.path(out_dir, "nhanes_cycle_counts.csv"), show_col_types = FALSE)
md  <- read_csv(file.path(out_dir, "nhanes_medications.csv"), show_col_types = FALSE)
sh  <- read_csv(file.path(out_dir, "state_health.csv"), show_col_types = FALSE)

check("exams has 4 components",                 n_distinct(ex$component) == 4)

# The slides print these tables, and a tibble shows only what fits in 80 characters. These
# checks pin the column sets and orders that keep every printed operation checkable.
printed_cols <- function(d) {
  op <- options(width = 80); on.exit(options(op))
  strsplit(trimws(capture.output(print(d, n = 1))[2]), "\\s+")[[1]]
}
check("exams is 5 columns wide",                 ncol(ex) == 5)
check("exams carries no timestamps",             !any(c("exam_start","exam_end") %in% names(ex)))
check("birth_country is participants column 2",  names(pt)[2] == "birth_country")
check("subset measurements start with glucose",  identical(names(ns)[6:7], c("glucose","hba1c")))
# Eleven columns cannot all fit in 80 characters whatever the order, so cholesterol is last on
# purpose: it is the only measurement lecture 1 never plots or filters on.
check("every variable lecture 1 plots prints",
      all(c("glucose","hba1c","bmi","waist_cm","diabetes","race","sex","age") %in%
            printed_cols(ns)))
check("join shows the joined-in columns",
      all(c("component","center_id","sex","birth_country") %in%
            printed_cols(inner_join(ex, pt, by = join_by(participant_id)))))
check("every exam session exists",              all(ex$session_id %in% se$session_id))
check("every exam participant exists",          all(ex$participant_id %in% pt$participant_id))
check("participants has no center_id",          !"center_id" %in% names(pt))
check("exams joins nhanes on id",
      nrow(inner_join(nh, ex, by = join_by(id == participant_id))) == nrow(ex))
check("birth_country has 2 levels",             n_distinct(na.omit(pt$birth_country)) == 2)
check("birth_country is only in participants",  !"birth_country" %in% names(nh))
check("sessions span 2017 and 2018",
      setequal(str_sub(se$session_date, -4), c("2017", "2018")))
check("2018 sessions with bp_sys_1 > 160 in males",
      se |> mutate(year = as.integer(str_sub(session_date, -4))) |> filter(year == 2018) |>
        inner_join(ex, by = "session_id") |>
        inner_join(nh, by = join_by(participant_id == id)) |>
        filter(bp_sys_1 > 160, sex == "male") |> nrow() > 0)
check("cycle_counts has 10 year columns",       ncol(cc) == 11)
check("cycle_counts columns are bare years",    all(str_detect(names(cc)[-1], "^\\d{4}$")))
check("monthly tables join on month and year",
      nrow(inner_join(monthly_components, monthly_exams, join_by(month, year))) ==
        nrow(monthly_components))
check("medications has <= 150 drugs",           n_distinct(md$drug_id) <= 150)
check("medications participants are in nhanes", all(md$participant_id %in% nh$id))
check("state_health covers 50 states",          nrow(sh) == 50)

pp <- read_csv(file.path(practice_dir, "participants.csv"), show_col_types = FALSE)
pe <- read_csv(file.path(practice_dir, "exams.csv"), show_col_types = FALSE)
pm <- read_csv(file.path(practice_dir, "medications.csv"), show_col_types = FALSE)

check("practice participants has birth_date",   "birth_date" %in% names(pp))
check("practice participants count is 9254",    nrow(pp) == 9254)
check("hba1c is right-skewed for a histogram",
      with(pp, mean(hba1c, na.rm = TRUE) < quantile(hba1c, 0.75, na.rm = TRUE) + 1) &&
        max(pp$hba1c, na.rm = TRUE) > 3 * median(pp$hba1c, na.rm = TRUE) / 2)
check("practice exam_start parses as a timestamp",
      !any(is.na(as.POSIXct(pe$exam_start, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"))))
check("practice exams span all 12 months",
      n_distinct(format(as.POSIXct(pe$exam_start, format = "%Y-%m-%dT%H:%M:%SZ",
                                   tz = "UTC"), "%B")) == 12)
# The p4 exercise looks for young participants on many medications; check the threshold works.
young_many <- pm |>
  distinct(participant_id, drug_id) |>
  count(participant_id) |>
  inner_join(pp |> select(id, age), by = join_by(participant_id == id)) |>
  filter(age < 40, n >= 5)
check("young participants on 5+ medications exist", nrow(young_many) > 0)
message("     participants under 40 on 5+ medications: ", nrow(young_many))

message("\ndone. files in ", out_dir, ":")
for (f in sort(list.files(out_dir, pattern = "\\.csv$"))) {
  message(sprintf("  %-34s %8.0f KB", f, file.size(file.path(out_dir, f)) / 1024))
}
