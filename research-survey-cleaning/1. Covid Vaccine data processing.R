## Package Setup -----

rm(list = ls())


for (x in "pacman") {
  if (!is.element(x, installed.packages()[, 1]))
  {
    install.packages(x, repos = "https://cloud.r-project.org/")
  } else {
    print(paste(x, " library already installed"))
  }
}




pacman::p_load(
  "stringr",
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
  "readr",
  'data.table',
  "janitor",
  "writexl"
) 


## Working directory setup -----



file_path <-
  "/../Desktop/Christine Karani/Christine/Git/research-survey-cleaning"


sub_form_file_name <-  "/Questionnaire.xlsx"





#Capture different paths where drive is different

if(file.exists(paste0("~/..", file_path))) {
  setwd(paste0("~/..", file_path))
}
if(file.exists(paste0("D:", file_path))) {
  setwd(paste0("D:", file_path))
}
if(file.exists(paste0("E:", file_path))) {
  setwd(paste0("E:", file_path))
}

getwd()




sub_form = read_excel(paste0("../research-survey-cleaning/",
                             sub_form_file_name),
                      skip = 2)





#Read raw data ----

dt <- readxl::read_xlsx("../research-survey-cleaning/Raw Data.xlsx")



dt <- dt %>% 
  mutate_all(as.character)



#Removing duplicate surveyIDs
dt <- dt %>%
  distinct(SurveyId, .keep_all = TRUE)



dt$Country <- "Kenya"



#######
# Corrections in data ----------------------------------------------------------

dt <-select(dt,-ends_with("_Note")) 



colnames(dt) <-  str_replace(colnames(dt),"Other \\[specify\\]_Other","Other [specify]_other")





### Questionnaire Check -------


str(sub_form)



dt$RESPAge <- as.numeric(dt$RESPAge)

dt <- dt %>%
  mutate(AgeGroup = case_when(
    RESPAge < 25 ~ "18-24",
    RESPAge >=25  & RESPAge <= 34 ~ "25-34",
    RESPAge >= 35 ~ "35+"
  ))

colnames(dt)

dt <- dt %>%
  relocate("AgeGroup",.after = "RESPAge") %>%
  relocate(c("Admin1ENKenya","Gender"),.after ="SurveyCreatedDate" )

writexl::write_xlsx(dt,"Covid_Vaccine_KE_Data_2021-03-04.xlsx")

write_sav(dt,"Covid_Vaccine_KE_Data_2021-03-04.sav")

