## Recodes the values of one of the column variables and 
## which can be used across other datasets that contain that variable.
## e.g., recodes remoteness area category names to standard abbreviations
## for labelling figures or maps
## Input: dataframe  Output: dataframe with renamed column

library(stringr)
column_recoder <- function(tidy_df, col_name="remoteness") {
  tidy_df_rename <- tidy_df %>%
    mutate(
      !!"abbr" := str_extract_all(.data[[col_name]], "\\b\\w") %>%
      sapply(paste, collapse = " ")
    )
  return (tidy_df_rename)
}
