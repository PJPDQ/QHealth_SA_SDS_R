# Tidying <- structuring datasets to facilitate analysis
# to facilitate initial exploration and analysis of the data, and
# to simplify the development of data analysis tools that work well together.

# a standardized way to link the structure of a dataset (its physical layout)
##
# with its semantics (its meaning).
## a collection of values (numbers quantitative or strings qualitative)
## values => a variable and observation
## variable contains values measure the same underlying attributes (height, temperature, duration) across units
## observation contains measured on the same unit (like person, day or race) across attributes

install.packages("readxl", "tidyr", "dplyr", "stringr")

library(readxl)
library(tidyr)
library(dplyr)
library(stringr)
library(plotly)
library(ggplot2)
library(htmlwidgets)
workdir <- "./Work/P/QHealth_SA_SDS_R/"
filename <- paste(workdir, "input/ABS_death_australia_remotenessareas.xlsx", sep="")
sheetname <- "Table 1"
save_name <- paste(workdir, "output/ABS_death_australia_remotenessareas_tidy.csv", sep="")
html_name <- paste(workdir, "output/assets/MortalityRate_Queensland_v_Australia.html", sep="")

# Read excel spreadsheet
df_raw <- read_excel(filename, sheet = sheetname, skip=5)

# Display data
# View(df_raw)

col_names <- df_raw %>%
  slice(1:3) %>%
  t() %>%
  as.data.frame() %>%
  fill(everything())

col_names <- col_names %>%
  unite("name", everything(), sep = "_") %>%
  pull(name)

df <- df_raw
colnames(df) <- col_names
df <- df[-c(0:3), ]

rem_col <- "NA_NA_Remoteness Area"
df_cleaned <- df %>%
  mutate(
    state = case_when(
      !is.na(.data[[rem_col]]) &
        rowSums(!is.na(select(., -all_of(rem_col)))) == 0 ~
        .data[[rem_col]],
      TRUE ~ NA_character_
    )
  ) %>%
  fill(state) %>%
  filter(!(state == .data[[rem_col]] &
             rowSums(!is.na(select(., -all_of(rem_col)))) == 0))

# To filter the null values
df_cleaned <- df_cleaned %>%
  filter(!if_all(-c(state, `NA_NA_Remoteness Area`), ~ is.na(.) | . == ""))


df_cleaned_tidy <- df_cleaned %>%
  pivot_longer(
  cols = -c(state, `NA_NA_Remoteness Area`),
  names_to = "colname",
  values_to = "value"
)

df_cleaned_tidy <- df_cleaned_tidy %>%
  mutate(
    year = str_extract(colname, "^\\d{4}")
  )

df_cleaned_tidy <- df_cleaned_tidy %>%
  mutate(
    measure = str_remove(colname, "^\\d{4}_")
  )

df_cleaned_tidy <- df_cleaned_tidy %>%
  rename("remoteness" = rem_col)

df_cleaned_tidy <- df_cleaned_tidy %>%
  select(-c("colname"))

write.csv(df_cleaned_tidy, save_name)

### Mortality Rate for Queensland to Australia
classes_remote <- c("Major Cities", "Inner Regional", "Outer Regional", "Remote", "Very Remote")
study_region <- c("Queensland", "Australia")
mort_df <- df_cleaned_tidy %>%
  filter(state %in% study_region & remoteness %in% classes_remote)

mort_df <- mort_df %>%
  mutate(
      variable = case_when(
        grepl("Deaths", measure, ignore.case = TRUE) ~ "deaths",
        grepl("Population", measure, ignore.case = TRUE) ~ "population",
        TRUE ~ NA_character_
      )
    ) %>%
  filter(!is.na(variable))

mort_rate <- mort_df %>%
  select(state, remoteness, year, variable, value) %>%
  pivot_wider(
    names_from = variable,
    values_from = value
  ) %>%
  mutate(
    mortality_rate = (as.numeric(deaths) / as.numeric(population)) * 100
  )

mort_rate <- mort_rate %>%
  mutate(
    mortality_rate = as.numeric(mortality_rate),
    year = as.numeric(year)
  )

## Temporal Pattern
p <- ggplot(mort_rate,
            aes(as.numeric(year), mortality_rate,
              colour = state,
              group = state,
              text = paste0(
                "Year: ", year,
                "<br>Mortality: ", round(mortality_rate,4),
                "<br>State: ", state
                ))) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 1.8) +
  facet_wrap(~ remoteness) +
  scale_x_continuous(
    breaks = unique(mort_rate$year)
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

pltly_gg <- ggplotly(p, tooltip = "text")
saveWidget(pltly_gg, file = html_name)
pltly_gg


## Cross sectional Pattern for 2024
cross_sec <- mort_rate %>%
  filter(year == 2024)

p2 <- ggplot(cross_sec,
       aes(remoteness, mortality_rate, fill = state)) +
  geom_col(position = "dodge") +
  labs(
    title = "Mortality rate by remoteness (2024)",
    x = "Remoteness area",
    y = "Mortality rate (%)"
  )
pltly_gg2 <- ggplotly(p2, tooltip = "text")
html_name2 <- paste(workdir, "output/assets/2024MortalityRate_Queensland_v_Australia.html", sep="")
saveWidget(pltly_gg2, file = html_name2)
pltly_gg2

## Cross Sectional Pattern for average years
cross_sec <- mort_rate %>%
  group_by(state, remoteness) %>%
  summarise(mortality_rate = mean(mortality_rate, na.rm = TRUE))

p3 <- ggplot(cross_sec,
       aes(remoteness, mortality_rate, fill = state)) +
        geom_col(position = "dodge") +
        labs(
          title = "Average mortality rate by remoteness (2011–2024)",
          x = "Remoteness area",
          y = "Mortality rate (%)"
    )
pltly_gg3 <- ggplotly(p3, tooltip = "text")
html_name3 <- paste(workdir, "output/assets/2011-2024Average_MortalityRate_Queensland_v_Australia.html", sep="")
saveWidget(pltly_gg3, file = html_name3)
pltly_gg3

