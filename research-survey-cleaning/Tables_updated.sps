
                      
cd 'C:\Users\ckarani\One Drive\Financial India\Data\Tables'.   
cd '%HOMEDRIVE%%HOMEPATH%\One Drive\Financial India\Data\Tables'.   


GET FILE = '..\Internal\Financial_India__2025_04_04.sav'.

compute Base=1.
EXECUTE.


VARIABLE LABELS Base 'Total'.


VALUE LABELS Base 1 ' '.



*recode ProtectedArea (else = copy) into state.
*exe.



*APPLY DICTIONARY from *
*/SOURCE VARIABLES = ProtectedArea
*/TARGET VARIABLES = state.
*/NEWVARS.





recode Age_group (else = copy) into Age_groupx.
exe.



APPLY DICTIONARY from *
/SOURCE VARIABLES = Age_group
/TARGET VARIABLES = Age_groupx
/NEWVARS.



                                      
recode gender (else = copy) into Genderx.
exe.



APPLY DICTIONARY from *
/SOURCE VARIABLES = gender
/TARGET VARIABLES = Genderx
/NEWVARS.



ALTER TYPE age totalphones(f4.0).
                 
                                      
OMS /SELECT tables
/if COMMANDS = 'CTables'
SUBTYPES = 'Custom Table'
/DESTINATION FORMAT = XLSX
OUTFILE = 'C:\Users\ckarani\Financial India\Data\Tables\Financial_India__2025_04_04.xlsx'.




CTABLES /TABLES Language by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = Language TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'Language'.

CTABLES /TABLES intro by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = intro TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'intro'.

CTABLES /TABLES consent by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = consent TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'consent'.

CTABLES /TABLES Age_group by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = Age_group TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'Age_group'.

CTABLES /TABLES age_2 by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = age_2 TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'age_2'.

CTABLES /TABLES gender by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = gender TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'gender'.

CTABLES /TABLES state by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = state TOTAL = Yes POSITION = Before empty = exclude
/CATEGORIES VARIABLES =   Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'state'.

CTABLES /TABLES zone1 by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = zone1 TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'zone1'.

CTABLES /TABLES zone2 by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = zone2 TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'zone2'.

CTABLES /TABLES zone3 by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = zone3 TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'zone3'.

CTABLES /TABLES zone4 by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = zone4 TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'zone4'.

CTABLES /TABLES zone5 by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = zone5 TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'zone5'.

CTABLES /TABLES zone6 by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = zone6 TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'zone6'.

CTABLES /TABLES confirmusage by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = confirmusage TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'confirmusage'.

CTABLES /TABLES frequencyofuser by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = frequencyofuser TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'frequencyofuser'.

CTABLES /TABLES accesstype by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = accesstype TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'accesstype'.

CTABLES /TABLES occupation by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = occupation TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'occupation'.

 * CTABLES /TABLES occupation_other by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = occupation_other TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'occupation_other'.

CTABLES /TABLES finances by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = finances TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'finances'.

 * CTABLES /TABLES finances_other by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = finances_other TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'finances_other'.

CTABLES /TABLES live by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = live TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'live'.

CTABLES /TABLES live_text by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = live_text TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'live_text'.

CTABLES /TABLES householdsizeadults by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = householdsizeadults TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'householdsizeadults'.

CTABLES /TABLES householdsizeminors by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = householdsizeminors TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'householdsizeminors'.

CTABLES /TABLES ownsmartphone by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = ownsmartphone TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'ownsmartphone'.

CTABLES /TABLES phonesharing by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = phonesharing TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'phonesharing'.

CTABLES /TABLES totalphones by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = totalphones TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'totalphones'.

CTABLES /TABLES educationheadofhousehold by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = educationheadofhousehold TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'educationheadofhousehold'.

CTABLES /TABLES fruits by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = fruits TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'fruits'.

CTABLES /TABLES bottledwater by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = bottledwater TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'bottledwater'.

CTABLES /TABLES gasoline by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = gasoline TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'gasoline'.

CTABLES /TABLES car by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = car TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'car'.

CTABLES /TABLES twowheeler by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = twowheeler TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'twowheeler'.

CTABLES /TABLES electricity by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = electricity TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'electricity'.

CTABLES /TABLES generator by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = generator TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'generator'.

CTABLES /TABLES save by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = save TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'save'.

CTABLES /TABLES bread by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = bread TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'bread'.

CTABLES /TABLES refrigerator by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = refrigerator TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'refrigerator'.

CTABLES /TABLES cattle by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = cattle TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'cattle'.

CTABLES /TABLES cooler by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = cooler TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'cooler'.

CTABLES /TABLES washingmachine by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = washingmachine TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'washingmachine'.

CTABLES /TABLES roof by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = roof TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'roof'.

CTABLES /TABLES water by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = water TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'water'.

CTABLES /TABLES eggs by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = eggs TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'eggs'.

CTABLES /TABLES milk by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = milk TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'milk'.

CTABLES /TABLES income by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = income TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'income'.

CTABLES /TABLES Language2 by (Base + state + Age_groupx + Genderx) [count] [colpct pct3.0]
/CATEGORIES VARIABLES = Language2 TOTAL = Yes POSITION = Before
/CATEGORIES VARIABLES = state Age_groupx Genderx TOTAL = No POSITION = Before empty = exclude
/TITLES title = 'Language2'.



                     
OMSEND.

