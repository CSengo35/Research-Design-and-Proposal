# Clear the environment ---------------------------------------------------
rm(list = ls())


# loading packages --------------------------------------------------------



pkg <- "pacman"


for (x in "pacman") {
  if (!is.element(x, installed.packages()[, 1]))
  {
    install.packages(x, repos = "https://cloud.r-project.org/")
  } else {
    print(paste(x, " library already installed"))
  }
}

pacman::p_load(
  "openxlsx",
  "haven",
  "readxl",
  "dplyr",
  "tidyr",
  "foreign",
  "dplyr",
  "purrr",
  "stringi",
  "forcats",
  "labelled",
  "openxlsx",
  "devtools",
  "janitor",
  "hms",
  "data.table",
  "lubridate",
  "purrr",
  "httr",
  "tidyverse",
  "janitor",
  "broom",
  "ggplot2",
  "data.table",
  "officer",
  "rvg"
) 

setwd("../Early Marriages Project/")

dt <- readxl::read_xlsx("../Early Marriages Project/child_marriage_mock_data.xlsx", sheet = "child_marriage_mock_data", col_types = "text", .name_repair = make.unique)

glimpse(dt)

dt <- dt %>%
  mutate(
    resp_type_f = factor(
      resp_type,
      levels = c(1,2,3),
      labels = c("Girl_u18", "Parent", "AdultWoman_early")
    ),
    a_sex_f = factor(
      A_sex,
      levels = c(1,2),
      labels = c("Male", "Female")
    )
  )

#subset for our main groups

girls <- dt %>%
  filter(resp_type_f == "Girl_u18")

parents <- dt %>%
  filter(resp_type_f == "Parent")

women <- dt %>%
  filter(resp_type_f == "AdultWoman_early")



# 2. RQ1 – PREVALENCE OF EARLY MARRIAGE -----------------------------------


# 2.1 Among adolescent girls (current early marriage) ---------------------

prev_girls <- girls %>%
  summarise(
    n = n(),
    n_ever_married = sum(B_ever_married == 1, na.rm = TRUE),
    prevalence = round(mean(B_ever_married == 1, na.rm = TRUE) * 100,1)
  )

prev_girls



# ## 2.2 Among adult women (historical early marriage) --------------------

prev_women <- women %>%
  summarise(
    n = n(),
    n_early = sum(D_age_marriage < 18, na.rm = TRUE),
    prevalence = round(mean(D_age_marriage < 18, na.rm = TRUE) * 100,1)
  )

prev_women


# 2.3 Among parents (households with daughters married early) -------------

prev_parents <- parents %>%
  summarise(
    n = n(),
    n_hh_with_early = sum(C_any_daughters_early_married == 1, na.rm = TRUE),
    prevalence = round(mean(C_any_daughters_early_married == 1, na.rm = TRUE) * 100 , 1)
  )

prev_parents



# prevalence comparison plot ----------------------------------------------

prev_df <-  bind_rows(
  prev_girls  %>% transmute(group = "Girls <18", prevalence),
  prev_women %>% transmute( group = "Adult women (ever)", prevalence),
  prev_parents %>% transmute(group = "Households (parents)", prevalence)
)


ggplot(prev_df, aes(x = group, y = prevalence)) +
        geom_col() +
         geom_text(aes(label = paste0(prevalence, "%")), vjust = -0.4) +
         labs(
           title = "Prevalence of early marriage in Budalangi",
           x = "",
           y = "Prevalence (%)"
         ) + 
theme_minimal()

ggsave("prevalence_plot.png", width = 7, height = 5, dpi = 300)


# 3. RQ2 – CAUSES OF EARLY MARRIAGE ---------------------------------------

#  3.1 Perceived causes among girls who feel pressure ---------------------

cause_girls <- girls %>%
  filter(B_pressure_marry == 1) %>%
  summarise(
    culture   = mean(replace_na(as.numeric(B_pressure_why_culture),   0)),
    economic  = mean(replace_na(as.numeric(B_pressure_why_economic),  0)),
    honour    = mean(replace_na(as.numeric(B_pressure_why_honour),    0)),
    pregnancy = mean(replace_na(as.numeric(B_pressure_why_pregnancy), 0)),
    norms     = mean(replace_na(as.numeric(B_pressure_why_norms),     0))
  ) %>%
  pivot_longer(everything(), names_to = "cause", values_to = "prop") %>%
  mutate(prop = round(prop * 100, 1)) %>%
  arrange(desc(prop))

cause_girls


## 3.2 Self-reported causes among adult women (realised early marriage)
cause_women <- women %>%
  summarise(
    poverty   = mean(replace_na(as.numeric(D_reason_poverty), 0)),
    pregnancy = mean(replace_na(as.numeric(D_reason_pregnancy), 0)),
    culture   = mean(replace_na(as.numeric(D_reason_culture), 0)),
    pressure  = mean(replace_na(as.numeric(D_reason_family_pressure), 0)),
    escape    = mean(replace_na(as.numeric(D_reason_escape), 0)),
    love      = mean(replace_na(as.numeric(D_reason_love), 0))
  ) %>%
  pivot_longer(everything(), names_to = "cause", values_to = "prop") %>%
  mutate(prop = round(prop * 100, 1)) %>%
  arrange(desc(prop))

cause_women

## 3.3 Parents’ view on causes (for daughters who married early)
cause_parents <- parents %>%
  filter(C_any_daughters_early_married == 1) %>%
  summarise(
    poverty   = mean(replace_na(as.numeric(C_why_poverty), 0)),
    pregnancy = mean(replace_na(as.numeric(C_why_pregnancy), 0)),
    culture   = mean(replace_na(as.numeric(C_why_culture), 0)),
    community = mean(replace_na(as.numeric(C_why_community), 0)),
    daughter_choice = mean(replace_na(as.numeric(C_why_daughter_choice), 0))
  ) %>%
  pivot_longer(everything(), names_to = "cause", values_to = "prop") %>%
  mutate(prop = round(prop * 100, 1)) %>%
  arrange(desc(prop))

cause_parents



# 4. RQ3 – EFFECTS / CONSEQUENCES OF EARLY MARRIAGE -----------------------

## 4.1 Effects on girls who married early
effects_girls <- girls %>%
  filter(B_ever_married == 1) %>%
  summarise(
    dropout    = mean(replace_na(as.numeric(B_chal_dropout),    0)),
    health     = mean(replace_na(as.numeric(B_chal_health),     0)),
    violence   = mean(replace_na(as.numeric(B_chal_violence),   0)),
    financial  = mean(replace_na(as.numeric(B_chal_financial),  0)),
    isolation  = mean(replace_na(as.numeric(B_chal_isolation),  0)),
    restricted = mean(replace_na(as.numeric(B_chal_restricted), 0)),
    emotional  = mean(replace_na(as.numeric(B_chal_emotional),  0))
  ) %>%
  pivot_longer(everything(), names_to = "effect", values_to = "prop") %>%
  mutate(prop = round(prop * 100, 1)) %>%
  arrange(desc(prop))

effects_girls


# 4.2 Long-term effects in adult women
effects_women <- women %>%
  summarise(
    dropout       = mean(replace_na(as.numeric(D_chal_dropout),         0)),
    diff_preg     = mean(replace_na(as.numeric(D_chal_difficult_preg),  0)),
    violence      = mean(replace_na(as.numeric(D_chal_violence),        0)),
    poverty       = mean(replace_na(as.numeric(D_chal_poverty),         0)),
    low_decision  = mean(replace_na(as.numeric(D_chal_decision_power),  0)),
    mental        = mean(replace_na(as.numeric(D_chal_mental),          0)),
    isolation     = mean(replace_na(as.numeric(D_chal_isolation),       0)),
    relationship  = mean(replace_na(as.numeric(D_chal_relationship),    0)),
    longterm_hlt  = mean(replace_na(as.numeric(D_chal_longterm_health), 0))
  ) %>%
  pivot_longer(everything(), names_to = "effect", values_to = "prop") %>%
  mutate(prop = round(prop * 100, 1)) %>%
  arrange(desc(prop))

effects_women


# 4.3 Community perceptions of effects (all respondents)
community_effects <- dt %>%
  summarise(
    dropout   = mean(replace_na(as.numeric(E_chal_dropout),        0)),
    teen_preg = mean(replace_na(as.numeric(E_chal_teen_preg),      0)),
    health    = mean(replace_na(as.numeric(E_chal_health),         0)),
    violence  = mean(replace_na(as.numeric(E_chal_violence),       0)),
    poverty   = mean(replace_na(as.numeric(E_chal_poverty),        0)),
    trauma    = mean(replace_na(as.numeric(E_chal_trauma),         0)),
    limited   = mean(replace_na(as.numeric(E_chal_limited_opps),   0)),
    conflict  = mean(replace_na(as.numeric(E_chal_family_conflict),0))
  ) %>%
  pivot_longer(everything(), names_to = "effect", values_to = "prop") %>%
  mutate(prop = round(prop * 100, 1)) %>%
  arrange(desc(prop))

community_effects


# 5. RQ4 – INFERENTIAL ANALYSIS & RECOMMENDATIONS -------------------------

# * Who is at higher risk of pressure / early marriage?
# * Which causes are linked to worse outcomes?
# * How awareness relates to attitudes?

# 5.1 Model 1 – Among girls: 
# is pressure to marry linked to being in school and education level?

girls_model_df <- girls %>%
  mutate(
    pressure_yes = if_else(B_pressure_marry == 1, 1, 0),
    in_school    = if_else(B_school_now == 1, 1, 0),
    grade_num    = as.numeric(B_highest_grade)
  ) %>%
  filter(!is.na(pressure_yes), !is.na(in_school), !is.na(grade_num))

model1 <- glm(
  pressure_yes ~ in_school + grade_num,
  data = girls_model_df,
  family = binomial
)

summary(model1)
exp(cbind(OR = coef(model1), confint(model1)))  

# Since the predictors here are weak, we need to add more predictors to make the equation strong

girls_model_df <- girls %>%
  mutate(
    pressure_yes = if_else(B_pressure_marry == 1, 1, 0),
    in_school = if_else(B_school_now == 1, 1, 0),
    grade_num = as.numeric(B_highest_grade),
    age = as.numeric(A_age)
  ) %>%
  mutate(
    # perceptions of norms
    too_old       = if_else(as.numeric(E_a_too_old) <= 2, 1, 0),   
    late_better   = if_else(as.numeric(E_b_late_better) <= 2, 1, 0),
    parents_decide = if_else(as.numeric(E_c_parents_decide) <= 2, 1, 0),
    common_here    = if_else(as.numeric(E_e_common_here) <= 2, 1, 0)
  ) %>%
  # remove missing & non-informative
  filter(!is.na(pressure_yes)) 

model1 <- glm(
  pressure_yes ~ 
    age +
    in_school + 
    grade_num +
    too_old + late_better + parents_decide + common_here,
  data = girls_model_df,
  family = binomial
)

summary(model1)
exp(cbind(OR = coef(model1), confint(model1)))

# 5.2 Model 2 – Among adult women:
# factors associated with experiencing violence

women_model_df <- women %>%
  mutate(
    violence_yes = if_else(D_exp_violence == 1, 1, 0),
    reason_poverty   = replace_na(as.numeric(D_reason_poverty),   0),
    reason_culture   = replace_na(as.numeric(D_reason_culture),   0),
    reason_pregnancy = replace_na(as.numeric(D_reason_pregnancy), 0)
  ) %>%
  filter(!is.na(violence_yes))

model2 <- glm(
  violence_yes ~ reason_poverty + reason_culture + reason_pregnancy,
  data = women_model_df,
  family = binomial
)

summary(model2)

exp(cbind(OR = coef(model2),confint(model2)))


# 5.3 Model 3 – All respondents:
# is awareness of legal age linked to favourable attitude 
# ("girls who marry after 18 have better opportunities")?


data_att <- dt %>%
  mutate(
    aware_yes = if_else(F_aware_legal_age == 1, 1, 0),
    late_better_agree = if_else(E_b_late_better %in% c(1, 2), 1, 0)
  ) %>%
  filter(!is.na(aware_yes), !is.na(late_better_agree))

# Chi-square test
chisq_result <- chisq.test(table(data_att$aware_yes, data_att$late_better_agree))
chisq_result



