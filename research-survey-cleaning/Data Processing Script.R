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
) #  "reshape",  "splitstackshape",


## Working directory setup -----



file_path <-
  "/One Drive/Covid Vaccine/Data/Internal"


sub_form_file_name <-  "/Covid Survey_Kenya_CATI_v6.xlsx"

output_file_name_sav_excel <- "Covid_Vaccine_Kenya_Data_"





export_subform = TRUE

##Financial package dataPrep
# detach("package:dataPrep", unload = TRUE)
# install.packages("~/collections/R/dataPrep_0.0.0.9000.tar.gz", repos = NULL, type = "source")
# devtools::install("~/collections/R/dataPrep_0.0.0.9000.tar.gz")
# install.packages("../Script/dataPrep_0.0.0.9001.tar.gz", repos = NULL, type = "source")


library(dataPrep)



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

### OUTPUT :::: File Names -------
#---------------------------#

sav_file_name <- paste0(output_file_name_sav_excel,
                        "_",
                        format(Sys.time(), "%Y_%m_%d"),
                        ".sav")

excel_file_name <- paste0(output_file_name_sav_excel,
                          "_",
                          format(Sys.time(), "%Y_%m_%d"),
                          ".xlsx")


### INPUTS ::::Loading files -------
#---------------------------#


sub_form = read_excel(paste0("../Script/",
                             sub_form_file_name),
                      skip = 2)





#Read raw data ----

#Creating a list of excel files to read


list_of_files <-
  list.files("../Raw/All States_NewFormat/",  pattern = ".csv", full.names = TRUE)


list_of_files <- sort(list_of_files, decreasing = TRUE)

list_of_files_size <- ""

for(i in seq_along(list_of_files)){
  list_of_files_size[i] <- file.size(list_of_files[i])
}

list_of_files <- list_of_files[!as.numeric(list_of_files_size) <= 5152]


#Reading list of execle files

#dt <- readr::read_csv(list_of_files, col_types = list("c" ))


dt <- list_of_files %>%
  set_names(nm = list_of_files) %>% #giving names of file to variable
  map_dfr(
    readr::read_csv,
    #skip = 1,
    col_types = cols(.default = col_character()), #list( col_character() ) #"text" #,
    name_repair = make.unique ,
    .id = "mode"
  )



dt <- dt %>% 
  mutate_all(as.character)



colnames(dt)[colnames(dt) == "#Email"] <- "Enumerator Id"
colnames(dt)[colnames(dt) == "#SurveyId"] <- "SurveyId"
colnames(dt)[colnames(dt) == "#FirstName"] <- "First Name"
colnames(dt)[colnames(dt) == "#LastName"] <- "Last Name"
colnames(dt)[colnames(dt) == "#IsOffline"] <- "Is Offline"
colnames(dt)[colnames(dt) == "#MobileNumber"] <- "Mobile Number"
colnames(dt)[colnames(dt) == "#Optin Date"] <- "OptIn Date"
colnames(dt)[colnames(dt) == "#NewTotalCaseDuration"] <- "New Total Case Duration"
colnames(dt)[colnames(dt) == "#SurveyCreatedDate"] <- "Survey Created Date"
colnames(dt)[colnames(dt) == "#UserPollStateId"] <- "UserPollStateId"
colnames(dt)[colnames(dt) == "#AppVersion"] <- "AppVersion"
colnames(dt)[colnames(dt) == "#SurveyCall"] <- "Survey Call"
colnames(dt)[colnames(dt) == "#SurveyState"] <- "Survey State"
colnames(dt)[colnames(dt) == "#UserId"] <- "UserId"
colnames(dt)[colnames(dt) == "#LocalCreatedDateTime"] <- "LocalCreatedDateTime"





# #SurveyState
# 
# 
# colnames(dt) <- colnames(dt) %>% 
#   str_remove("\\#")

#Removing duplicate surveyIDs
dt <- dt %>%
  distinct(SurveyId, .keep_all = TRUE)



####Extract Poll ID----


dt <- dt %>%
  mutate(PollID = str_extract(mode, "_[0-9]{5,}_")) %>%
  mutate(PollID = str_extract(PollID, "[0-9]{5,}"))



dt <- dt %>% 
  mutate(Country = case_when(
    str_detect(mode, "Nigeria") ~ "Nigeria",
    str_detect(mode, "Tanzania") ~ "Tanzania",
    str_detect(mode, "Kenya") ~ "Kenya",
    str_detect(mode, "Angola") ~ "Angola",
    str_detect(mode, "India")~ "India",
    str_detect(mode, "Mali$") ~ "Mali",
    str_detect(mode, "India$") ~ "India"))


source("../Script/0.Functions_auto_script.R")



dt_debug_delete <- read_xlsx("../Rejected Case Log/Covid Vaccine_Kenya case log.xlsx",
                             col_types = 'text', 
                             sheet = "Summary")

dt <- dt %>%
  filter(!SurveyId %in% dt_debug_delete$SurveyId)






# Drop Enumerators --------------------------------------------------------


Enumerators_drop <- dt[dt$`Enumerator Id` %in% c("mutwirii609@gmail.com","allan@gmail.com","moureen@gmail.com","defence@gmail.com",
                                                 "godfrey.sakia@gmail.com","wcrl.test@gmail.com","yvonnemeggie438@gmail.com","elixodero450@gmail.com")
                                                ,c("SurveyId","UserId","Enumerator Id","OptIn Date","New Total Case Duration", "Country")]  #,"Mobile Number","Province",





debug_function(dataset_name = Enumerators_drop,
               Reason_text = "Enumerator Blacklisted",
               dataset_full = dt,
               renamed = FALSE)


dt <- dt %>% 
  filter(!SurveyId %in% Enumerators_drop$SurveyId)


dt <- dt %>% 
  filter(!`Enumerator Id` %in% c("mutwirii609@gmail.com","allan@gmail.com","moureen@gmail.com","defence@gmail.com"
                                 ,"godfrey.sakia@gmail.com","wcrl.test@gmail.com","yvonnemeggie438@gmail.com","elixodero450@gmail.com"))

# drop_case <- c("UPS-4890676565261083790","UPS-7338071208667748263","UPS-54549031194621951")
# 
# 
# dt <- dt %>% 
#   filter(!SurveyId %in% drop_case)



dt <- dt %>%
  mutate(across(everything(),
                ~ str_remove_all(.,"\\|.*")))



#Adding EnumeratorID
# Enumerator <- readxl::read_xlsx("../Script/Enumerators.xlsx")
# dt <- left_join(dt,Enumerator, by = "Enumerator Id")



dt <- dt %>% 
  distinct(SurveyId, .keep_all = TRUE)


# Corrections in data ----------------------------------------------------------




cat("=============================list_all Districts to be united=============================\n\n")


#######
# Corrections in data ----------------------------------------------------------

dt <-select(dt,-ends_with("_Note")) 



colnames(dt) <-  str_replace(colnames(dt),"Other \\[specify\\]_Other","Other [specify]_other")




########################################################.



### Subform Check -------
#---------------------------#

str(sub_form)

#Working on the various subform iterations

code_working_list <- func_subform()

code_working <- code_working_list$code_working
code_working3 <- code_working_list$code_working3


code_db_values <- tibble::tibble(QNumber = NA,
                                 QName = c("UserId","mode","Enumerator Id","App Version","First Name",
                                           "Last Name","UserPollStateId","SurveyId",
                                           "User Created Date","Survey State","Carrier", "Gender.db","Age.db",
                                           "YearOfBirth","LSM","Latitude","Longitude","Country",
                                           "ADM1.db","ADM2.db","City.db","question Type","Survey Created Date",
                                           "OptIn Date",
                                           "Survey Call","Recording State","Resumed From Call Back",
                                           "Front End Duration","Survey Content Duration","Total Case Duration"
                                           ,"New Total Case Duration"))


code_working4 <- code_db_values %>%
  bind_rows(code_working3)


#code_working4 <- code_working3


if(export_subform){
  
  writexl::write_xlsx(code_working4, "../Script/subform_questions_v2.xlsx")
  
}


#-------


# Change Survey to -> SurveyOutcome ---------------------------------------


dt <- dt %>% 
  mutate(SurveyOutcome = case_when(
    `Survey State` %in% c("Completed") ~ "Completed",
    (!`Survey State` %in% c("Completed","Ineligible","Rejected",
                            "LanguageProblemIneligible","QuotaReached") & 
       intro == "CONTINUE" & is.na(Language2) )  ~ "Breakoff",
    `Survey State` %in% c("Ineligible",
                          "LanguageProblemIneligible") ~ "Ineligible",
    `Survey State` %in% c("QuotaReached") ~ "Quota Reached",
    `Survey State` %in% c("Refusal","Declined") ~ "Refusal",
    (`Survey State` %in% c("Running") & 
       !intro %in% ("CONTINUE") )  ~ "Refusal",
    `Survey State` %in% c("Rejected","UnderReview","UnmatchedRejected",
                          "CompletedUnderReview",
                          "LanguageProblem","Rejected",
                          "Running") ~ "Rejected",
    `Survey State` %in% c("AnsweringMachine","CallBack",
                          "Disconnected","Expired","NoAnswer","CallDropped") ~ "Non-Response"
    
  ))

dt <- dt %>% 
  mutate(OrderSurveyOutcome = case_when(
    `Survey State` %in% c("Completed") ~ 1,
    (!`Survey State` %in% c("Completed","Ineligible","Rejected",
                            "LanguageProblemIneligible","QuotaReached") & 
       intro == "CONTINUE" & is.na(Language2) )~ 2,
    `Survey State` %in% c("Ineligible",
                          "LanguageProblemIneligible") ~ 3,
    `Survey State` %in% c("QuotaReached") ~ 4,
    `Survey State` %in% c("Refusal","Declined") ~ 5,
    `Survey State` %in% c("Running") & 
      !intro %in% c("Continue") ~ 5,
    `Survey State` %in% c("Rejected","UnderReview","UnmatchedRejected",
                          "CompletedUnderReview",
                          "LanguageProblem","Rejected",
                          "Running") ~ 6,
    `Survey State` %in% c("AnsweringMachine","CallBack",
                          "Disconnected","Expired","NoAnswer","CallDropped") ~ 7
    
  ))


table(dt$`Survey State`, dt$SurveyOutcome, exclude = "n")
table(dt$`Survey State`, dt$OrderSurveyOutcome, exclude = "n")

table(dt$`Survey State`, dt$Language2, exclude = "n")
table(dt$SurveyOutcome, dt$Language2, exclude = "n")



dt <- dt %>%
  mutate(Complete_Incomplete = case_when(
    SurveyOutcome == "Completed" ~ "Completed",
    SurveyOutcome %in% c("Breakoff","Ineligible","Quota Reached") ~ "Incomplete",
    TRUE ~ as.character("")
    
  ))


table(dt$`Survey State`, dt$Complete_Incomplete, exclude = "n")


# Remove duplicate Mobile Numbers -----------------------------------------

  
  dt <- dt %>% 
    distinct(`Mobile Number`, .keep_all = TRUE)
  
  



#Correcting loop and Merge evoked from OE SATA ---


if ("Gender.1" %in% colnames(dt)) {
  dt <- dt %>%
    rename(Gender.db = "Gender", Gender = "Gender.1")
}

if ("Age.1" %in% colnames(dt)) {
  dt <- dt %>%
    rename(Age.db = "Age", Age = "Age.1")
}

if ("Country.1" %in% colnames(dt)) {
  dt <- dt %>%
    rename(Country.db = "Country", Country = "Country.1")
}

if ("ADM1.1" %in% colnames(dt)) {
  dt <- dt %>%
    rename(ADM1.db = "ADM1", ADM1 = "ADM1.1")
}

if ("ADM2.1" %in% colnames(dt)) {
  dt <- dt %>%
    rename(ADM2.db = "ADM2", ADM2 = "ADM2.1")
}


if ("City.1" %in% colnames(dt)) {
  dt <- dt %>%
    rename(City.db = "City", City = "City.1")
}


dt <- dt %>%
  select(-ends_with("_Note"))# %>%
# select(
#   -c(
#     "Enumerator Id":"Last Name",
#     "Mobile Number":"User Created Date",
#     "Latitude":"Longitude",
#     "Survey Call":"Total Case Duration")
# )

# Dealing with hyphen special characters
colnames(dt) <- colnames(dt) %>%
  str_replace_all("\\u2019", "'") %>%
  str_replace_all("\\u2019","'") %>%
  str_remove_all("amp;")


dt <- dt %>%
  mutate(across(everything(), ~str_replace_all(., "\\u2019","'"))) %>%
  mutate(across(everything(), ~str_remove(., "amp;")))



# Adding Survey Start time -----------------------------------------------------

dt$StartTime <- dt$`OptIn Date`

#dt$StartTime <- data.table::as.ITime(dt$StartTime)
dt$StartTime <- hms::as_hms( str_extract(dt$StartTime, "[0-9]+\\:[0-9]+\\:[0-9]+") )

# Convert OptIn Date to correct date format ------------------------------------

dt$`OptIn Date`<- substr(dt$`OptIn Date`,1,10)

#table(dt$OptInDate)
table(dt$`OptIn Date`)

# Adding Survey Date variable --------------------------------------------------

dt$`Survey Date` <- dt$`OptIn Date`

table(dt$`Survey Date`)

# Converting Total Case Duration to seconds ------------------------------------


dt$EndTime <- hms::as_hms(dt$StartTime) + hms::as_hms(as.numeric(dt$`New Total Case Duration`))

#dt$EndTime <- data.table::as.ITime(dt$EndTime)
dt$EndTime <- hms::as_hms(dt$EndTime)

dt$`New Total Case Duration` <- as.character( hms::as_hms(as.numeric(dt$`New Total Case Duration`)) )



dt$StartTime <- as.character(dt$StartTime)
dt$`Survey Date` <- as.character(dt$`Survey Date`)
dt$`EndTime` <- as.character(dt$`EndTime`)

dt_full_order <- code_working4$QName %>%
  purrr::map_dfc(setNames, object = list(character()))

table(colnames(dt) %in% colnames(dt_full_order))

colnames(dt)[!colnames(dt) %in% colnames(dt_full_order)]

dt0_backup <- dt

dt <- dt_full_order %>%
  bind_rows(dt0_backup)

dt <- dt %>%
  select(-any_of(c("App Version","UserPollStateId",
                   "User Created Date","Carrier","Gender.db","Age.db",
                   "YearOfBirth","LSM","Latitude","Longitude","ADM1.db","ADM2.db","City.db","question Type",
                   "Survey Created Date","Recording State",
                   "Resumed From Call Back","Front End Duration","Survey Content Duration"))) #"First Name","Last Name",,"New Total Case Duration","Total Case Duration","Survey State"


#DT_LOI STUFFF -----



#Editting OE-SATA TO SATA to allow merger-----

list_OE_SATA <- code_working %>%
  filter(QType == "Open Ended-Select All That Apply") %>%
  pull(QName)





#######

dt <- dt %>%
  select(SurveyId, everything())


## LIST OF VARIABLES ------

#subform edits

code_working <- code_working %>% 
  mutate(QType = str_replace(QType, "Open Ended-Select All That Apply",
                             "Select All That Apply"))

dt1 <- dt

# dt1 <- dt1 %>%
#   filter(!SurveyId %in% drop_cases1$SurveyId)

# dt1 <- convert_to_factor(var_name = "Refusal_Why", data_name = dt)

open_ended_single_choice <- code_working %>%
  filter(QType == 'Open Ended-Single Choice') %>%
  pull(QName)

single_choice <- code_working4 %>%
  filter(QType == 'Single Choice') %>%
  pull(QName)

sata_rating <- code_working %>%
  filter(QType == "Select All That Apply Rating") %>%
  pull(QName)

open_ended <- code_working %>%
  filter(QType == 'Open Ended') %>%
  pull(QName)

range_open_end <- code_working %>%
  filter(QType == 'Range') %>%
  pull(QName)

Open_Ended_sata <- code_working %>%
  filter(QType == 'Open Ended-Select All That Apply') %>%
  pull(QName)

sata <- code_working %>%
  filter(QType %in% c('Select All That Apply')) %>%
  pull(QName)

matrix_qtype <- code_working %>%
  filter(QType == 'MatrixTable') %>%
  pull(QName)

## Loops for conversion ----
cat("## Loops for conversion ----")

for (i in seq_along(single_choice)) {
  #print(single_choice[i])
  dt1 <- func_factor_conversion(var_name = single_choice[i],
                                data_name = dt1,
                                question_type = "Single Choice")
}


for (i in seq_along(open_ended_single_choice)) {
  #print(open_ended_single_choice[i])
  dt1 <- func_factor_conversion(var_name = open_ended_single_choice[i],
                                data_name = dt1,
                                question_type = 'Open Ended-Single Choice')
}

for (i in seq_along(Open_Ended_sata)) {
  #print(Open_Ended_sata[i])
  dt1 <- func_factor_conversion(var_name = Open_Ended_sata[i],
                                data_name = dt1,
                                question_type = "Open Ended-Select All That Apply")
}

for (i in seq_along(sata_rating)) {
  dt1 <- func_factor_conversion(var_name = sata_rating[i],
                                data_name = dt1,
                                question_type = "Select All That Apply Rating")
}

for (i in seq_along(sata)) {
  dt1 <- func_factor_conversion(var_name = sata[i],
                                data_name = dt1,
                                question_type = "Select All That Apply")
}

for (i in seq_along(matrix_qtype)) {
  dt1 <- func_factor_conversion(var_name = matrix_qtype[i],
                                data_name = dt1,
                                question_type = "MatrixTable")
}

# 
# dt1 <- dt1 %>% 
#   mutate(ProblemsRanking_1 = if_else(`ProblemsRanking_1_Other [specify]_other` == "No",
#                                                              NA_integer_, ProblemsRanking_1)) %>% 
#   mutate(ProblemsRanking_2 = if_else(`ProblemsRanking_2_Other [specify]_other` == "No",
#                                      NA_integer_, ProblemsRanking_1)) %>% 
#   mutate(ProblemsRanking_3 = if_else(`ProblemsRanking_3_Other [specify]_other` == "No",
#                                      NA_integer_, ProblemsRanking_3))

dt0_backup_allstate <- dt1



dt1 <- dt1 %>% 
  filter(`Survey State` == "Completed")



dt2<- dt1

dt2$`total phones`[dt2$SurveyId == "UPS6459881177808277589"] <- NA


## LOgic check -------

source("../Script/1.2 Logic check.R", local = TRUE,
       encoding = "UTF-8")





dt1_all <- dt0_backup_allstate %>% 
  filter(`Survey State` != "Completed")


dt1_complete <- dt1 %>% 
  filter(!SurveyId %in% drop_cases1$SurveyId)



dt_sample$`Mobile Number` <- paste0("91", dt_sample$`Mobile Number`)






dt_sample <- dt_sample %>% 
  distinct(`Mobile Number`, .keep_all = TRUE)


wrong_samples <- dt1[!dt1$`Mobile Number` %in% dt_sample$`Mobile Number`, ]







dt2 <- dt1_complete %>% 
  bind_rows(dt1_all)

writexl::write_xlsx(dt2,"Data with all variables.xlsx")

# dt2 <- dt2 %>% 
#   mutate( SampleType = if_else(PollID == "20720408",
#                                "Indexed Sample","RDD Sample"))


dt3 <- dt2 %>% 
  select(SurveyId, "SurveyState" = `Survey State` ,Country, "TotalCaseDuration" = `New Total Case Duration`,
         "OptInDate" = `OptIn Date`, "Language":"Language2") %>%
  select(-any_of(c("UserId","mode","Enumerator Id","First Name","Last Name","Survey Call","Optin","CallDispo","NoAnswer","Non-Working Number",
                   "Agree","Refusal_why","Refusal_why_Other [specify]_other","WhenCallBack","CallbackMessageEN","Ineligible","Refusal")))



# dt3 <- dt3 %>% 
#   relocate(c("SurveyOutcome","Complete_Incomplete"), .after = last_col())



openxlsx::write.xlsx(tibble(org = colnames(dt3)), "../Script/Var_names_20250303.xlsx")


#list_dt_rename <- readxl::read_xlsx("../Script/Var_names_20240906_updated.xlsx")


dt4 <- dt3


#colnames(dt4) <- list_dt_rename$Changed_var

dt4 <- dt4 %>% 
  mutate(across(everything(), ~str_remove(.,"\\.00$")))


writexl::write_xlsx(dt4,"All data.xlsx")

dt4 <- dt4 %>% 
  filter(SurveyState %in% c("Completed"))




dt4$Country <- "Kenya"



openxlsx::write.xlsx(dt4, 
                     paste0("Raw_", excel_file_name),
                     overwrite = TRUE,
                     colWidths = "auto",
                     firstActiveRow  = 2,
                     firstActiveCol   = 7
)

openxlsx::write.xlsx(dt4, 
                     paste0("../Client Facing/", excel_file_name),
                     overwrite = TRUE,
                     colWidths = "auto",
                     firstActiveRow  = 2,
                     firstActiveCol   = 7
)


# End of Script -----------------------------------------------------------

# 
# source("../API Upload/Script/2.Transformation_upload.R",
#        encoding = "UTF-8")

open_ended_single_choice <- code_working %>%
  filter(QType == 'Open Ended-Single Choice') %>%
  pull(QName)

single_choice <- code_working4 %>%
  filter(QType == 'Single Choice') %>%
  pull(QName)

sata_rating <- code_working %>%
  filter(QType == "Select All That Apply Rating") %>%
  pull(QName)

open_ended <- code_working %>%
  filter(QType == 'Open Ended') %>%
  pull(QName)

range_open_end <- code_working %>%
  filter(QType == 'Range') %>%
  pull(QName)

Open_Ended_sata <- code_working %>%
  filter(QType == 'Open Ended-Select All That Apply') %>%
  pull(QName)

sata <- code_working %>%
  filter(QType %in% c('Select All That Apply')) %>%
  pull(QName)

matrix_qtype <- code_working %>%
  filter(QType == 'MatrixTable') %>%
  pull(QName)


## Loops for conversion ----

for (i in seq_along(single_choice)) {
  print(single_choice[i])
  dt4 <- func_factor_conversion(var_name = single_choice[i],
                                data_name = dt4,
                                question_type = "Single Choice")
}


for (i in seq_along(open_ended_single_choice)) {
  print(open_ended_single_choice[i])
  dt4 <- func_factor_conversion(var_name = open_ended_single_choice[i],
                                data_name = dt4,
                                question_type = 'Open Ended-Single Choice')
}

for (i in seq_along(Open_Ended_sata)) {
  #print(Open_Ended_sata[i])
  dt4 <- func_factor_conversion(var_name = Open_Ended_sata[i],
                                data_name = dt4,
                                question_type = "Open Ended-Select All That Apply")
}

for (i in seq_along(sata_rating)) {
  dt4 <- func_factor_conversion(var_name = sata_rating[i],
                                data_name = dt4,
                                question_type = "Select All That Apply Rating")
}

for (i in seq_along(sata)) {
  dt4 <- func_factor_conversion(var_name = sata[i],
                                data_name = dt4,
                                question_type = "Select All That Apply")
}

for (i in seq_along(matrix_qtype)) {
  dt4 <- func_factor_conversion(var_name = matrix_qtype[i],
                                data_name = dt4,
                                question_type = "MatrixTable")
}





#######SPSS Output#########




dt2<- dt4

# dt2 <- dt2 %>%
#   rename_with(~ gsub("^TRAINING_PERSONELL \\(You did not receive training any training in the last 12 months\\)", 
#                      "TRAINING_PERSONELL (No past 12 months)", .))

# dt2 <- dt2 %>% 
#   filter(SurveyState2 == "Completed")


#Create code that will truncate names and log for sub_form

colnames(dt2) <- colnames(dt2) %>%
  spss_func()


colnames(dt2)[(duplicated(colnames(dt2)))]

## [Loop] Single choice ----

for (i in seq_along(single_choice)) {
  #print(single_choice[i])
  
  spss_single_choice <- single_choice[i] %>% spss_func()
  if (spss_single_choice %in% colnames(dt2)) {
    dt2 <- func_var_lab_spss(
      var_name = single_choice[i],
      data_name = dt2,
      question_type = 'Single Choice'
    )
  }
}

## [Loop] Open Ended-Single Choice ----

for (i in seq_along(open_ended_single_choice)) {
  print(open_ended_single_choice[i])
  
  spss_open_ended_single_choice <-
    open_ended_single_choice[i] %>% spss_func()
  if (spss_open_ended_single_choice %in% colnames(dt2)) {
    #print(open_ended_single_choice[i])
    dt2 <- func_var_lab_spss(
      var_name = open_ended_single_choice[i],
      data_name = dt2,
      question_type = 'Open Ended-Single Choice'
    )
  }
}

## [Loop] Open Ended ----

for (i in seq_along(open_ended)) {
  if (spss_func(open_ended[i]) %in% colnames(dt2)) {
    #print(open_ended[i])
    dt2 <- func_var_lab_spss(
      var_name = open_ended[i],
      data_name = dt2,
      question_type = 'Open Ended'
    )
  }
  
}

## [Loop] Range ----

for (i in seq_along(range_open_end)) {
  if (range_open_end[i] %in% colnames(dt2)) {
    # print(range_open_end[i])
    dt2 <- func_var_lab_spss(
      var_name = range_open_end[i],
      data_name = dt2,
      question_type = 'Range'
    )
  }
  
}

## [Loop] Select All That Apply Rating ----

for (i in seq_along(sata_rating)) {
  #print(sata_rating[i])
  
  spss_sata_rating <- sata_rating[i] %>% spss_func()
  
  dt2 <- func_var_lab_spss(var_name = sata_rating[i],
                           data_name = dt2,
                           question_type = "Select All That Apply Rating")
}

## [Loop] Select All That Apply ----

for (i in seq_along(sata)) {
  #print(sata[i])
  dt2 <- func_var_lab_spss(var_name = sata[i],
                           data_name = dt2,
                           question_type = "Select All That Apply")
}

## [Loop] Matrix table ----

for (i in seq_along(matrix_qtype)) {
  #print(matrix_qtype[i])
  dt2 <- func_var_lab_spss(var_name = matrix_qtype[i],
                           data_name = dt2,
                           question_type = "MatrixTable")
}

## [Loop] Open Ended-Select All That Apply ----

for (i in seq_along(Open_Ended_sata)) {
  #print(Open_Ended_sata[i])
  dt2 <- func_var_lab_spss(var_name = Open_Ended_sata[i],
                           data_name = dt2,
                           question_type = "Open Ended-Select All That Apply")
}

dtx <- dt2



# Exporting data ------

dt3 <- dt2

  

## SPSS NAMING & LABELING ---

open_ended_adj <- code_working3 %>%
  filter(QType == 'Open Ended') %>%
  pull(QName)

dt4 <- dt3

#dt3$MobileNumber <- NULL


colnames(dt3)[(duplicated(colnames(dt3)))]

dict_data <- look_for(dt3) %>% lookfor_to_long_format()

dict_data_filtered <- dict_data %>%
  mutate(len = str_length(levels)) %>%
  group_by(variable) %>%
  mutate(x = 1, seq = cumsum(x)) %>%
  filter(len > 120) %>%
  mutate(
    labels_orginal = levels,
    levels = str_trunc(
      levels,
      width = 120,
      side = "right",
      ellipsis = ""
    )
  ) %>%
  distinct(variable, .keep_all = TRUE)

for (i in seq_along(dict_data_filtered$pos)) {
  
  var_select <- dict_data_filtered[["variable"]][i]
  num <- dict_data_filtered[["seq"]][i]
  val_fix <- dict_data_filtered[["levels"]][i]
  
  
  dt4[[var_select]] <-
    fct_relabel(dt4[[var_select]], ~ str_trunc(
      .,
      width = 120,
      side = "right",
      ellipsis = ""
    ))
  #attr(dt4[[var_select]] , )
  
}


chk <- dt3 %>%
  map(attributes) %>%
  map('levels')

chk_label <- dt3 %>%
  map(attributes) %>%
  map('label')


chk_missing_levels <- names(chk[chk %>% map(is_empty) %>% unlist()])
chk_missing_labels <-
  names(chk_label[chk_label %>% map(is_empty) %>% unlist()])


for (i in seq_along(chk_missing_labels)) {
  var_select <- chk_missing_labels[i]
  
  attr(dt4[[var_select]], "label") <- ""
}





dt6 <- dt4

#colnames(dt6)[str_detect(colnames(dt6),"EquipmentHave_OrdinaryMobilePhone")]

dt6[duplicated(dt6$SurveyId),c("SurveyId")] #,,"UserId"

dt7 <- subset(dt6,!duplicated(dt6$SurveyId))




dt8 <- dt7

colnames(dt8) <- colnames(dt8) %>% 
  spss_func()

colnames(dt8) <- str_replace(colnames(dt8), "\\.$","")


colnames(dt8)[str_length(colnames(dt8)) == 64] <- str_trunc(colnames(dt8)[str_length(colnames(dt8)) == 64], side = 'right', width = 63,
                                                            ellipsis = "")


##Age Group

dt8 <- dt8 %>%
  mutate(Age_group = case_when(dplyr::between(as.numeric(age),18,24) ~ "18-24",
                               dplyr::between(as.numeric(age),25,34) ~ "25-34",
                               dplyr::between(as.numeric(age),35,44) ~ "35-44",
                               dplyr::between(as.numeric(age),45,54) ~ "45-54",
                               dplyr::between(as.numeric(age),55,100) ~ "55+",
                               .default = ""))



#var_label(dt8$Age_group) <- "Age Group"
attr(dt8[["Age_group"]], "label") <- "Age Group"

dt8[["Age_group"]] <- factor(dt8[["Age_group"]],
                             levels = c("18-24","25-34","35-44",
                                        "45-54","55+"))


## Outputing SAV and XLSX files -----

# colnames(dt8)[colnames(dt8)=="VID_CNT_HOME_RELATED‘HOWTO‘DOITYOURSELF"] <- "VID_CNT_HOME_RELATEDHOWTODOITYOURSELF"
# colnames(dt8)[colnames(dt8)=="#LocalCompletedDate"] <- "Local_CompletedDate"
# colnames(dt8)[colnames(dt8)=="#RejectedReason"] <- "QRejectedReason"
# colnames(dt8)[colnames(dt8)=="#Carrier"] <- "QCarrier"
# colnames(dt8)[colnames(dt8)=="#LocalCreatedDateTime"] <- "QLocalCreatedDateTime"



# 
# dt8 <- dt8 %>% 
#   rename("Q9a"= `9a`,"Q9b"= `9b`,"Q10a"= `10a`,"Q12a"= `12a`,"Q12b"= `12b`,"Q13a"= `13a`,"Q13b"= `13b`)

list_numeric <- dt8 %>% select(matches("^[0-9]")) %>% colnames()

list_correct <- str_c("Q",list_numeric)

for (i in seq_along(list_numeric)){
  colnames(dt8)[colnames(dt8)==list_numeric[i]] <- list_correct[i]
}


haven::write_sav(dt8, sav_file_name)

write.xlsx(dt8, excel_file_name, overwrite = TRUE,
           colWidths="auto")




# Generating SpSS Table Syntax --------------------------------------------


spss_lab <- look_for(dt8, values = FALSE) %>% 
  select(variable, label) %>% 
  distinct(variable, .keep_all = TRUE)

spss_lab <- spss_lab %>% 
  #filter(is.na(label)) %>% 
  mutate(multi = if_else(is.na(label), "Yes", "No")) %>% 
  separate(variable, c("QVal","QItem"), sep = "_",remove = FALSE) %>% 
  mutate(variablex = if_else(multi == "Yes", QVal, variable))


spss_lab <- spss_lab %>% 
  mutate(multi = if_else( QVal %in% code_working$QName[code_working$QType == "MatrixTable"], "No", multi ))

spss_mulit_var_collapse <- spss_lab %>% 
  filter(multi == "Yes") %>% 
  group_by(variablex) %>% 
  summarise(across(everything(), str_c, collapse=" ")) %>% 
  mutate(syntax_x = str_c("MRSETS /MDGROUP NAME = $", variablex, " VARIABLES = ", variable,"
VALUE = 1 LABEL = '", variablex, "'.\n\n"))

spss_lab <- spss_lab %>% 
  mutate(variable = if_else(multi == "Yes", QVal, variable)) %>% 
  distinct(variable, .keep_all = TRUE)


spss_mulit_unique <- spss_lab$variablex[spss_lab$multi == "Yes"]




more_stuff <- tibble(var_name = "base",
                     syntax_x = str_c("
*recode ProtectedArea (else = copy) into ProtectedAreax.
*exe.\n\n\n
*APPLY DICTIONARY from *
*/SOURCE VARIABLES = ProtectedArea
*/TARGET VARIABLES = ProtectedAreax.
*/NEWVARS.\n\n\n


recode Age_group (else = copy) into Age_groupx.
exe.\n\n\n
APPLY DICTIONARY from *
/SOURCE VARIABLES = Age_group
/TARGET VARIABLES = Age_groupx
/NEWVARS.\n\n\n
                                      
recode gender (else = copy) into Genderx.
exe.\n\n\n
APPLY DICTIONARY from *
/SOURCE VARIABLES = gender
/TARGET VARIABLES = Genderx
/NEWVARS.\n\n\n

                 
                                      
OMS /SELECT tables
/if COMMANDS = 'CTables'
SUBTYPES = 'Custom Table'
/DESTINATION FORMAT = XLSX
OUTFILE = 'table_",excel_file_name,"'.


"))


end_stuff <- tibble(var_name = "base",
                    syntax_x = str_c("
                     
OMSEND.
"))


spss_var <- tibble(var_name = spss_lab$variable ) %>% 
  #mutate(labels = if_else( spss_lab$multi == "Yes" , var_name, labels) ) %>% 
  mutate(var_name = if_else( spss_lab$multi == "Yes" , str_c("$",var_name), var_name) ) %>% 
  mutate(crosstab_by = "Base + ProtectedAreax + Age_groupx + Genderx",
         cat_crosstab_by = "ProtectedAreax Age_groupx Genderx",
         labels = spss_lab$label) %>% 
  mutate(labels = if_else( is.na(labels), str_replace(var_name, "\\$",""), labels))

spss_var_2 <- spss_var %>% 
  mutate(syntax_x = str_c("CTABLES /TABLES ",var_name, " by (" ,crosstab_by, ") [count] [colpct pct3.0]\n",
                          "/CATEGORIES VARIABLES = ", var_name, " TOTAL = Yes POSITION = Before\n",
                          "/CATEGORIES VARIABLES = ", cat_crosstab_by, " TOTAL = No POSITION = Before empty = exclude\n",
                          "/TITLES title = '", var_name, "'.\n"))

# spss_var_2x <- spss_var %>% 
#   mutate(syntax_x = )

spss_var_3 <- spss_var_2 %>% 
  filter(!var_name %in% c("SurveyId","SurveyState","Country","TotalCaseDuration", "EnumeratorId","Introduction","Introduction2","OptInDate","SurveyCall","Location","StartTime","MSISDN1","SurveyOutcome","Wave"))
                          



other_stuff <- tibble(var_name = "base",
                      syntax_x = str_c("
                      
cd 'C:\\Users\\ckarani\\Financial\\One Drive\\Financial India\\Data\\Tables'.   
cd '%HOMEDRIVE%%HOMEPATH%\\Financial\\One Drive\\Financial India\\Data\\Tables'.   


GET FILE = '..\\Internal\\",sav_file_name,"'.

compute Base=1.
EXECUTE.\n\n
VARIABLE LABELS Base 'Total'.\n\n
VALUE LABELS Base 1 ' '.\n\n"))


spss_var_4 <- other_stuff %>% 
  bind_rows(more_stuff , spss_mulit_var_collapse %>% 
              select(var_name = "QVal" , syntax_x), spss_var_3, end_stuff)





write(spss_var_4$syntax_x[!is.na(spss_var_4$syntax_x)],
      paste0("../Script/","TableScript_xx.sps"))


