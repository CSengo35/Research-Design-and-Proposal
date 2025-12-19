# Clear the environment ---------------------------------------------------
rm(list = ls())


# loading packages --------------------------------------------------------

#install.packages(c("readxl","dplyr","tidyr","stringr","ggplot2","scales","officer","rvg","flextable"))

#install.packages("dplyr")

library(readxl) 
library(dplyr) 
library(tidyr) 
library(stringr)
library(ggplot2) 
library(scales)
library(officer) 
library(rvg)
library(flextable)

library(tidyverse)
library(lubridate)
library(janitor)
library(scales)
#library(arules)
library(tibble)


setwd("../Fall of Budalangi Clinical Research Firm/")

input_xlsx <- "1.0 Budalangi_Clinical_Research_Firm_Fall_Synthetic_Data.xlsx"
output_ppt <- "Budalangi_Clinical_Research_Fall"

df <- readxl::read_xlsx(input_xlsx) %>%
  mutate(
    year = as.integer(year),
    staff_role = as.factor(staff_role)
  )

likert_vars <- c(
  "theft_of_funds",
  "unsustainable_consultants",
  "unsustainable_salaries",
  "expensive_team_building",
  "poor_leadership_management",
  "poor_financial_judgement",
  "unsustainable_office_costs",
  "over_reliance_on_specific_projects",
  "exit_of_major_clients",
  "decline_in_profits",
  "firing_of_sales_people",
  "pressure_on_remaining_staff",
  "low_staff_morale",
  "non_income_generating_products",
  "time_consuming_non_billable_activities",
  "inefficient_internal_processes"
)

outcome_var <- "overall_contribution_to_firm_collapse"


# 1. Drivers Ranking ---------------------------------------------------------



df <- df %>%
  mutate(across(all_of(c(likert_vars, outcome_var)), as.numeric))

drivers_tbl <- df %>%
  summarise(across(all_of(likert_vars), ~mean(.x, na.rm = TRUE))) %>%
  pivot_longer(everything(), names_to = "factor", values_to = "mean_score") %>%
  arrange(desc(mean_score)) %>%
  mutate(
    factor_clean = factor %>%
      str_replace_all("_", " ") %>%
      str_to_title()
  )

top10_drivers <- drivers_tbl %>% slice_head(n = 10)


# 2. Trends ---------------------------------------------------------------

year_tbl <- df %>%
  group_by(year) %>%
  summarise(
    mean_collapse = mean(.data[[outcome_var]], na.rm = TRUE),
    mean_profit_decline = mean(decline_in_profits, na.rm = TRUE),
    mean_sales_layoffs = mean(firing_of_sales_people, na.rm = TRUE),
    mean_nonbillable = mean(time_consuming_non_billable_activities, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  ) %>%
  arrange(year)



# 3. Role comparison ------------------------------------------------------

role_tbl <- df %>%
  group_by(staff_role) %>%
  summarise(
    mean_collapse = mean(.data[[outcome_var]], na.rm = TRUE),
    mean_profit_decline = mean(decline_in_profits, na.rm = TRUE),
    mean_pressure = mean(pressure_on_remaining_staff, na.rm = TRUE),
    mean_sales_layoffs = mean(firing_of_sales_people, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_collapse))



# Most Associated Drivers -------------------------------------------------

corr_tbl <- df %>%
  select(all_of(c(outcome_var, likert_vars))) %>%
  drop_na() %>%
  summarise(across(all_of(likert_vars), ~cor(.x, .data[[outcome_var]]))) %>%
  pivot_longer(everything(), names_to = "factor", values_to = "corr_with_collapse") %>%
  arrange(desc(corr_with_collapse)) %>%
  mutate(
    factor_clean = factor %>%
      str_replace_all("_", " ") %>%
      str_to_title()
  )

top_corr <- corr_tbl %>% slice_head(n = 8)



# Generating Insights -----------------------------------------------------

make_fallback_exec_summary <- function(top10_drivers, year_tbl, top_corr, role_tbl) {
  top3 <- top10_drivers %>% slice_head(n = 3)
  yr1 <- year_tbl %>% slice_head(n = 1)
  yrL <- year_tbl %>% slice_tail(n = 1)
  worst_role <- role_tbl %>% slice_head(n = 1)
  
  paste0(
    "What happened (2023–2025)\n",
    "• Mean collapse score changed from ", round(yr1$mean_collapse,2), " (", yr1$year,
    ") to ", round(yrL$mean_collapse,2), " (", yrL$year, ").\n",
    "• Profit decline and sales layoffs trend together, indicating weakening revenue engine.\n\n",
    
    "Key drivers (ranked)\n",
    "• ", top3$factor_clean[1], " (mean=", round(top3$mean_score[1],2), ")\n",
    "• ", top3$factor_clean[2], " (mean=", round(top3$mean_score[2],2), ")\n",
    "• ", top3$factor_clean[3], " (mean=", round(top3$mean_score[3],2), ")\n\n",
    
    "Workforce impacts\n",
    "• Sales layoffs are consistently linked to profit decline and pipeline weakness.\n",
    "• Highest pressure reported by: ", as.character(worst_role$staff_role),
    " (mean collapse=", round(worst_role$mean_collapse,2), ").\n\n",
    
    "Operational waste\n",
    "• Time-consuming non-billable activities and non-income products reduce productivity and billable capacity.\n\n",
    
    "Most associated with collapse (correlation)\n",
    paste0("• ", top_corr$factor_clean[1:4], " (r=", round(top_corr$corr_with_collapse[1:4],2), ")", collapse = "\n")
  )
}

exec_summary_text <- make_fallback_exec_summary(top10_drivers, year_tbl, top_corr, role_tbl)


# Charts/Visualization ----------------------------------------------------

p_drivers <- top10_drivers %>%
  ggplot(aes(x = reorder(factor_clean, mean_score), y = mean_score)) +
  geom_col() +
  coord_flip() +
  scale_y_continuous(limits = c(0,5), breaks = 0:5) +
  labs(title = "Top Drivers of Collapse (Mean 1–5)", x = NULL, y = "Mean score")

year_long <- year_tbl %>%
  pivot_longer(cols = c(mean_collapse, mean_profit_decline, mean_sales_layoffs, mean_nonbillable),
               names_to = "metric", values_to = "value") %>%
  mutate(metric = recode(metric,
                         mean_collapse = "Overall collapse",
                         mean_profit_decline = "Profit decline",
                         mean_sales_layoffs = "Sales layoffs",
                         mean_nonbillable = "Non-billable time"))

p_year <- ggplot(year_long, aes(x = year, y = value, group = metric)) +
  geom_line() + geom_point() +
  scale_x_continuous(breaks = sort(unique(year_tbl$year))) +
  scale_y_continuous(limits = c(0,5), breaks = 0:5) +
  labs(title = "Trend Signals (2023–2025)", x = "Year", y = "Mean score (1–5)")

p_role <- role_tbl %>%
  mutate(staff_role = as.character(staff_role)) %>%
  ggplot(aes(x = reorder(staff_role, mean_collapse), y = mean_collapse)) +
  geom_col() +
  coord_flip() +
  scale_y_continuous(limits = c(0,5), breaks = 0:5) +
  labs(title = "Collapse Pressure by Role", x = NULL, y = "Mean collapse score")


# Tables for slides -------------------------------------------------------

ft_drivers <- top10_drivers %>%
  transmute(Factor = factor_clean, Mean = round(mean_score, 2)) %>%
  flextable() %>% autofit()

ft_corr <- top_corr %>%
  transmute(Factor = factor_clean, Correlation = round(corr_with_collapse, 2)) %>%
  flextable() %>% autofit()


# Build PPT ---------------------------------------------------------------

ppt <- read_pptx()

# Cover
ppt <- ppt %>%
  add_slide("Title Slide", master = "Office Theme") %>%
  ph_with("Fall of Budalangi Clinical Research Firm", location = ph_location_type("ctrTitle")) %>%
  ph_with("Synthetic Evidence (n=1,000), 2023–2025", location = ph_location_type("subTitle"))

# Table of Contents
toc <- c(
  "1. Executive Summary",
  "2. Findings: Key Drivers",
  "3. Findings: Trends (2023–2025)",
  "4. Findings: Role Differences",
  "5. Findings: Most Associated Drivers",
  "6. Conclusion & Recommendations",
  "7. Thank You"
)

ppt <- ppt %>%
  add_slide("Title and Content", master = "Office Theme") %>%
  ph_with("Table of Contents", location = ph_location_type("title")) %>%
  ph_with(paste(toc, collapse = "\n"), location = ph_location_type("body"))

# Executive Summary
ppt <- ppt %>%
  add_slide("Title and Content", master = "Office Theme") %>%
  ph_with("Executive Summary", location = ph_location_type("title")) %>%
  ph_with(exec_summary_text, location = ph_location_type("body"))

# Findings: Key Drivers
ppt <- ppt %>%
  add_slide("Two Content", master = "Office Theme") %>%
  ph_with("Findings: Key Drivers", location = ph_location_type("title")) %>%
  ph_with(ft_drivers, location = ph_location_type("body", index = 1)) %>%
  ph_with(dml(ggobj = p_drivers), location = ph_location_type("body", index = 2))

# Findings: Trends 2023–2025
ppt <- ppt %>%
  add_slide("Title and Content", master = "Office Theme") %>%
  ph_with("Findings: Trends (2023–2025)", location = ph_location_type("title")) %>%
  ph_with(dml(ggobj = p_year), location = ph_location_type("body"))

# Findings: Role Differences
ppt <- ppt %>%
  add_slide("Title and Content", master = "Office Theme") %>%
  ph_with("Findings: Role Differences", location = ph_location_type("title")) %>%
  ph_with(dml(ggobj = p_role), location = ph_location_type("body"))

# Findings: Most Associated Drivers (Correlation table)
ppt <- ppt %>%
  add_slide("Title and Content", master = "Office Theme") %>%
  ph_with("Findings: Drivers Most Associated with Collapse", location = ph_location_type("title")) %>%
  ph_with(ft_corr, location = ph_location_type("body"))

# Conclusion & Recommendations (simple, direct)
top6 <- drivers_tbl %>% slice_head(n = 6) %>% pull(factor_clean)
recs <- c(
  "Strengthen financial controls (audit trails, access controls, segregation of duties).",
  "Reduce unsustainable costs (consultants, salary structure, office, discretionary events).",
  "Protect and rebuild the revenue engine (sales capacity, pipeline governance, client retention).",
  "Stop non-income products/activities unless ROI is proven; prioritize billable work.",
  "Diversify projects/clients to reduce over-reliance and improve resilience."
)

conclusion <- paste0(
  "Conclusion\n",
  "• Decline is consistent with governance weaknesses + unsustainable cost structure + strategic concentration risk.\n",
  "• Top contributors: ", paste(top6, collapse = "; "), ".\n\n",
  "Recommendations\n",
  paste0("• ", recs, collapse = "\n")
)

ppt <- ppt %>%
  add_slide("Title and Content", master = "Office Theme") %>%
  ph_with("Conclusion & Recommendations", location = ph_location_type("title")) %>%
  ph_with(conclusion, location = ph_location_type("body"))

# Thank You
ppt <- ppt %>%
  add_slide("Title Slide", master = "Office Theme") %>%
  ph_with("Thank You", location = ph_location_type("ctrTitle")) %>%
  ph_with("Questions & Discussion", location = ph_location_type("subTitle"))

output_pptx <- "Budalangi_Fall_Deck_Report.pptx"

print(ppt, target = output_pptx)

message("PPT created: ", output_pptx)






