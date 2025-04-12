


GET FILE = "C:\Users\ckarani\Desktop\Christine Karani\Christine\Git\research-survey-cleaning\Covid_Vaccine_KE_Data_2021-03-04.sav".

freq Admin1ENKenya

recode Admin1ENKenya
("Baringo" = "1")
("Bomet" = "2")
("Bungoma" = "3")
("Busia" = "4")
("Elgeyo-Marakwet" = "5")
("Embu" = "6")
("Garissa" = "7")
("Homa Bay" = "8")
("Isiolo" = "9")
("Kajiado" = "10")
("Kakamega" = "11")
("Kericho" = "12")
("Kiambu" = "13")
("Kilifi" = "14")
("Kirinyaga" = "15")
("Kisii" = "16")
("Kisumu" = "17")
("Kitui" = "18")
("Kwale" = "19")
("Laikipia" = "20")
("Lamu" = "21")
("Machakos" = "22")
("Makueni" = "23")
("Mandera" = "24")
("Marsabit" = "25")
("Meru" = "26")
("Migori" = "27")
("Mombasa" = "28")
("Murang'a" = "29")
("Nairobi" = "30")
("Nakuru" = "31")
("Nandi" = "32")
("Narok" = "33")
("Nyamira" = "34")
("Nyandarua" = "35")
("Nyeri" = "36")
("Samburu" = "37")
("Siaya" = "38")
("Taita-Taveta" = "39")
("Tana River" = "40")
("Tharaka-Nithi" = "41")
("Trans Nzoia" = "42")
("Turkana" = "43")
("Uasin Gishu" = "44")
("Vihiga" = "45")
("Wajir" = "46")
("West Pokot" = "47").
exe.

VALUE LABELS Admin1ENKenya
1"Baringo"
2"Bomet"
3"Bungoma"
4"Busia"
5"Elgeyo-Marakwet"
6"Embu"
7"Garissa"
8"Homa Bay"
9"Isiolo"
10"Kajiado"
11"Kakamega"
12"Kericho"
13"Kiambu"
14"Kilifi"
15"Kirinyaga"
16"Kisii"
17"Kisumu"
18"Kitui"
19"Kwale"
20"Laikipia"
21"Lamu"
22"Machakos"
23"Makueni"
24"Mandera"
25"Marsabit"
26"Meru"
27"Migori"
28"Mombasa"
29"Murang'a"
30"Nairobi"
31"Nakuru"
32"Nandi"
33"Narok"
34"Nyamira"
35"Nyandarua"
36"Nyeri"
37"Samburu"
38"Siaya"
39"Taita-Taveta"
40"Tana River"
41"Tharaka-Nithi"
42"Trans Nzoia"
43"Turkana"
44"Uasin Gishu"
45"Vihiga"
46"Wajir"
47"West Pokot".


freq Gender

RECODE Gender
("Female" = "1")
("Male" = "2").
exe.

VALUE LABELS Gender
1"Female"
2"Male".

freq AgeGroup

recode AgeGroup
("18-24" = "1")
("25-34" = "2")
("35+" = "3").
exe.

VALUE LABELS AgeGroup
1"18-24"
2"25-34"
3"35+".

freq Confidence

recode Confidence
("Not at all confident" = "1")
("Not very confident" = "2")
("Unsure" = "3")
("Fairly confident" = "4")
("Very confident" = "5").
exe.

VALUE LABELS Confidence
1"Not at all confident"
2"Not very confident"
3"Unsure"
4"Fairly confident"
5"Very confident".

freq Likelihood

recode Likelihood
("Definitely not" = "1")
("Probably not" = "2")
("Unsure" = "3")
("Probably" = "4")
("Definitely" = "5").
exe.

VALUE LABELS Likelihood
1"Definitely not"
2"Probably not"
3"Unsure"
4"Probably"
5"Definitely".


recode Reason2
("Lack of knowledge/awareness" = "1")
("COVID-19 isn't a threat" = "2")
("Religious/cultural/personal belief" = "3")
("Uncertain of vaccine effectiveness" = "4")
("Potential health risk" = "5").
exe.

VALUE LABELS Reason2
1"Lack of knowledge/awareness"
2"COVID-19 isn't a threat"
3"Religious/cultural/personal belief"
4"Uncertain of vaccine effectiveness"
5"Potential health risk".

recode VaccineCost
("Yes" = "1")
("No" = "2")
("Unsure/depends on cost" = "3").
exe.

VALUE LABELS VaccineCost
1"Yes"
2"No"
3"Unsure/depends on cost".

ALTER TYPE Admin1ENKenya to VaccineCost(f4.0).


VARIABLE LABELS SurveyId"SurveyId".
VARIABLE LABELS Country"Country".
VARIABLE LABELS SurveyCreatedDate"Survey Created Date".
VARIABLE LABELS Admin1ENKenya"What County do you currently live in?".
VARIABLE LABELS Gender"Are you male or female?".
VARIABLE LABELS RESPAge"Respondent Age".
VARIABLE LABELS AgeGroup"Respondent Agegroup".
VARIABLE LABELS BirthYear"In what year were you born?".
VARIABLE LABELS Confidence"How confident are you in a COVID-19 vaccine?".
VARIABLE LABELS Likelihood"If a COVID-19 vaccine was available for free today, would you get it as soon as possible?".
VARIABLE LABELS Reason"What is the primary reason you aren't likely to take the vaccine?Reply 1 to see answer".
VARIABLE LABELS Reason2"What is the primary reason you aren't likely to take the vaccine?".
VARIABLE LABELS VaccineCost"Would you be willing to pay full or part of the cost of the vaccine?".


compute Base=1.
EXECUTE.

VARIABLE LABELS Base 'Total'.
VALUE LABELS Base 1 ' '.


                 
                                      
OMS /SELECT tables
/if COMMANDS = 'CTables'
SUBTYPES = 'Custom Table'
/DESTINATION FORMAT = XLSX
OUTFILE = 'C:\Users\ckarani\Desktop\Christine Karani\Christine\Git\research-survey-cleaning\Covid_Vaccine_Kenya_Tables_2025_04_04.xlsx'.




CTABLES /TABLES Admin1ENKenya by (Base +  AgeGroup + Gender) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = Admin1ENKenya TOTAL = Yes POSITION = Before  empty = exclude
/TITLES title = 'Admin1ENKenya'.

CTABLES /TABLES AgeGroup by (Base + Admin1ENKenya + Gender) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = AgeGroup TOTAL = Yes POSITION = Before  empty = exclude
/TITLES title = 'AgeGroup'.

CTABLES /TABLES Confidence by (Base + Admin1ENKenya + AgeGroup + Gender) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = Confidence TOTAL = Yes POSITION = Before  empty = exclude
/TITLES title = 'Confidence'.

CTABLES /TABLES Likelihood by (Base + Admin1ENKenya + AgeGroup + Gender) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = Likelihood TOTAL = Yes POSITION = Before
/TITLES title = 'Likelihood'.


CTABLES /TABLES Reason2 by (Base + Admin1ENKenya + AgeGroup + Gender) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = Reason2 TOTAL = Yes POSITION = Before empty = exclude
/TITLES title = 'Reason2'.

CTABLES /TABLES VaccineCost by (Base + Admin1ENKenya + AgeGroup + Gender) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = VaccineCost TOTAL = Yes POSITION = Before empty = exclude
/TITLES title = 'VaccineCost'.

                     
OMSEND.

