*Birth recode file
clear
clear matrix
clear mata
set maxvar 30000

use "D:\Dissertation - PG\NFHS-5\IABR7BFL.DTA"
drop if v044==0
//only those selected for DV module//
*marital status
recode v501 (4 5=5), gen(mstatus)
label define mstatus 1 "Married" 3 "Widowed" 5 "Divorced/Separated"
label val mstatus mstatus
keep if mstatus==1
*We wish to restrict our sample to children aged 0-59 months*
gen child_age_years=b8
recode child_age_years(0/4=1) (5/37=2)
br v137 b8 b19
gen child_age_months=b19
recode child_age_months (0/59=1) (60/452=2)
tab child_age_years
tab child_age_months
keep if child_age_months==1
*sex of the child
gen sex_child=b4
replace sex_child=0 if b4==1
replace sex_child=1 if b4==2
label define sex_child 0"male" 1"female" ,replace
label val sex_child sex_child

*eldest son
gen eldest_son = 0
forvalues i = 1/16 {
     replace eldest_son = 1 if bord_`i' == 1 & b4_`=string(`i', "%02.0f")' == 1
}
label define eldest_son 0"Not having an eldest son" 1"Having an eldest son"
label val eldest_son eldest_son

*brother sibling
gen male_count = 0
gen female_count = 0
forvalues i = 1/16 {
    replace male_count = male_count + 1 if b4_`=string(`i', "%02.0f")' == 1
    replace female_count = female_count + 1 if b4_`=string(`i', "%02.0f")' == 2
}
gen brother_sibling=1
replace brother_sibling=0 if male_count==0
label define brother_sibling 0"Not having a brother sibling" 1"Having a brother sibling"
label val brother_sibling brother_sibling

*hw70/ HAZ score indicates stunting status*
*hw71/ WAZ score indicates underweight status*
*hw72/ WHZ score indicates wasting status*
drop if hw70==9998
drop if hw70==9997
drop if hw71==9998
br hw13 hw70 hw71
drop if hw72==9996
drop if hw72==9998

*HAZ score*
gen haz_score = hw70/100
gen stunted=0
replace stunted=1 if haz_score<-2
label define stunted 0"Not Stunted" 1"Stunted"
label val stunted stunted

*WAZ score*
gen waz_score =hw71/100
gen underwt=0
replace underwt=1 if waz_score<-2
label define underwt 0"Not Underweight" 1"Underweight"
label val underwt underwt

*WHZ score*
gen whz_score=hw72/100
gen wasting=0
replace wasting=1 if whz_score<-2
label define wasting 0 "no wasting" 1 "wasting"
label val wasting wasting 

*metarnal healthcare
*antenatal healthcare (4 or more antenatalcheckups during pregnancy)
gen ANC=1 if m14>=4
replace ANC=0 if m14<4
replace ANC=0 if m14==.|m14==98
*institutional_delivery
gen institutional_delivery=0 if m15==11|m15==12|m15==13|m15==96
replace institutional_delivery=1 if institutional_delivery==.

*postnatal care (whether the child received postnatal check before dischange)
gen PNC=0 if s470==0|s470==8
replace PNC=0 if s470==.
replace PNC=1 if s470==1

gen maternal_care=1 if ANC==1|institutional_delivery==1|PNC==1
replace maternal_care=0 if maternal_care==.

*Stunting, based on a child's height and age, is a measure of chronic nutritional deficiency. Wasting, based on a child's weight and height, is a measure of acute nutritional deficiency. Underweight, based on weight and age, is a composite measure of both acute and chronic statuses. Overweight, based on weight and height, is a measure of excess weight than is optimally healthy.
*HAZ score for mother (we will not use it)
*codebook hw73
*drop if hw73==9998

*gen BMI_mother= hw73/100

*Birth Order*
recode bord (1=1) (2=2) (3/14=3), gen(birth_order)
label define birth_order_lbl 1 "1" 2 "2" 3 "3+"
label values birth_order birth_order

*Age at first birth*
recode v212 (10 /18 =1) (19/ 25=2) (26/ 30=3) (31/ 35=4) (36/46=5), gen(age_first_birth)
label define age_first_birth 1 "<18 years old" 2 "19-25 years old" 3 "26-30 years old" 4 "31-35 years old" 5 ">36 years old"
label values age_first_birth  age_first_birth

*interview_dummy creation
gen interview_dummy=1 if v008==1451|v008==1452|v008==1453|v008==1454|v008==1455|v008==1456|v008==1457
replace interview_dummy=0 if interview_dummy==.
label define interview_dummy 1 "postcovid" 2 "precovid" 
label values interview_dummy interview_dummy

*BMI of Mother

gen BMI_mother= v445/100
drop if v445==9998
codebook BMI_mother
gen mother_undernourished=1 if BMI_mother<18.5
replace mother_undernourished=0 if mother_undernourished==.

*Birth outcome
recode m18 (1/2 =1) (3=2) (4/5=3) (8=4), gen(size_at_birth)
label define size_at_birth 1 "above average" 2 "average" 3 "below average" 4 "don't know"
label values size_at_birth  size_at_birth

save "D:\Dissertation - PG\NFHS-5\Final\DV_BR.DTA"

//NFHS-5 HH data
clear
clear matrix
clear mata
set maxvar 30000
set more off
use "D:\Dissertation - PG\NFHS-5\IAHR7BFL.DTA"
gen Toilet = 0 if hv205== 31
replace Toilet = 1 if hv205~=31
replace Toilet = 0 if hv205==.
replace Toilet = 0 if hv225==1

label define Toilet_lbl 1 "Toilet" 0 "No_Toilet or shared toilet"
gen hh_head = hv219
replace hh_head =0 if hh_head ==1
replace hh_head =1 if hh_head ==2
label define head_lbl 0 "Male" 1"Female"
label values hh_head head_lbl
label var hh_head "sex of head of household"

gen hh_size = hv009
copydesc hv009 hh_size

gen number_hh_women = hv010
copydesc hv010 number_hh_women
ssc install copydesc

*HH infra 

gen type_house = shnfhs2
replace type_house =1 if type_house ==2
label define house_lbl 1 "kaccha" 3 "pucca"
label values type_house house_lbl
label var type_house " House is kaccha or pucca "
gen elec_house = hv206
copydesc hv206 elec_house
gen water_source = hv201
recode water_source (11/32= 1) ( 41/96 = 0), gen(water_source1)
tab water_source1
gen hh_infra = ( water_source1 + elec_house + type_house)/3
gen hh_infra1 = ( water_source1 + elec_house + type_house)/3

* SLI PCA 

global xlist hv207 hv208 hv209 sh50b sh50c sh50d sh50e sh50f sh50g sh50i sh50j sh50k sh50n sh50q sh50r sh50x sh50y sh50z hv210 hv221 hv211 hv212 hv243a hv243b hv243c
global ncomp 5
pca $xlist
screeplot
pca $xlist, mineigen(1)
pca $xlist, mineigen(1) blanks (.3)
rotate
predict SLI PCA

* pca avg 

gen SLI_avg = (hv207 + hv208 + hv209 + sh50b + sh50c + sh50d  + sh50e + sh50f + sh50g + sh50i + sh50j + sh50k + sh50n + sh50q + sh50r + sh50x + sh50y + sh50z + hv210 + hv221 + hv211 + hv212 + hv243a + hv243b + hv243c) /24

gen wi=hv271/100000
bysort shdist: egen wealthmed=median(wi)
drop if hv044==0
save "D:\Dissertation - PG\NFHS-5\Final\DV_HR.dta"
////NFHS5 hh's data

*Open the IR file
clear
clear matrix
clear mata
set maxvar 30000
set more off
use "D:\Dissertation - PG\NFHS-5\IAIR7BFL.DTA"
//education is captured for all the observations
bysort sdist v025: egen meanedu=mean(v133)
//keep only those observations selected for state module
keep if ssmod==1
//work status and gender attitudes are captured only for those interviewed for state module

recode v731 (1 2 3=1), gen(work_pastyr)
recode v741 (0 3 .=0) (1 2 =1), gen (work_cash)
bysort sdist: egen flfp_pastyr=mean(work_pastyr)
bysort sdist: egen work_cash1=mean(work_cash)
//gender attitudes questions from woman's questionnaire
//husband and wife relations

*Aggregating WIFE BEATING questions
//recode dont know answer as yes.
recode v744a v744b v744c v744d v744e (8=1)
egen wifebeatjust=rowtotal(v744a v744b v744c v744d v744e)
*Gives you the number of scenarios where a lady believes that wife beating is justified
label variable wifebeat "number of scenarios where the woman believes that wife beating is justified"
//control issues
recode d101a d101b d101c d101d d101e d101f (8=0)
gen control_spouse=d102
_crcslbl control_spouse d102

* Decision Making Index 
//decision making authority (only respondent decides)
gen decisionauth1=(v743a==1 & v743b==1 & v743d==1 & v743f==1)

//decision making authority (spouse/others decide)
recode v743a v743b v743d v743f (4 5 6 = 4)
gen decisionauth2=(v743a==4 & v743b==4 & v743d==4 & v743f==4)

//decision making authority (respondents decides alone or with husband)
recode v743a v743b v743d v743f (2=1) (4 5 6 = 0)
label def decision 0 "respondent has no say" 1 "respondent has a say"
label val v743a v743b v743d v743f  decision
gen decisionauth=(v743a==1 & v743b==1 & v743d==1 & v743f==1)

//mobility for IPV
recode s930a s930b s930c (2=0)
label define mobility 0 "not allowed/allowed with someone" 1 "Alone"
label val s930a s930b s930c mobility
gen mobility=(s930a==1 & s930b==1 & s930c==1)

//owns assets individually or jointly
recode v745a (1 2 3=1) (0=0) (.=.), gen(ownshouse)
recode v745b (1 2 3=1) (0=0) (.=.), gen(ownsland)
gen ownsasset=(ownshouse==1 | ownsland==1)
label variable ownsasset "owns land or house individually or jointly"

//Financial literacy
gen bank_ac = s931
gen mon_own = s929
label define mon_own 0 "does not own any money that alone can decide to spend" 1 "does own money"
label define bank_ac 0 "does not own a bank or savings account " 1 "does own bank or savings account"

gen mobile_ownership=s932
gen mobile_fin_transac=s933
codebook s932
codebook s933
replace mobile_fin_transac=0 if s933==.
gen internet_use=s934
codebook s934
codebook s937
gen read_text_message=s937
replace read_text_message=0 if s937==.
egen fin_literacy=rowtotal(bank_ac mobile_ownership mobile_fin_transac internet_use read_text_message)
codebook fin_literacy
recode fin_literacy (0 = 0 "No literacy") ( 1/2 = 1 "Low literacy") (3/5 = 2 "High literacy"), gen (fin_literacy_index)
label var fin_literacy_index "Level of financial literacy"

//gender relation/attitude dummies - woman's questionnaire

//if wife says husband exhibits marital control in at least one scenario
gen control_spoused=control_spouse>0

// if wife has mobility and decision making authority
gen hautonomy1= (decisionauth1==1 & mobility==1)
gen hautonomy= (decisionauth==1 & mobility==1)

//if wife justifies beating in at least one scenario
gen wifebeatjustd=wifebeatjust>0

//.........................................//
bysort sdist: egen dautonomy=mean(hautonomy)
bysort sdist: egen dmcontrol=mean(control_spoused)
bysort sdist: egen downsasset=mean(ownsasset)
bysort sdist: egen dfinliteracy=mean(fin_literacy)
bysort sdist: egen dflfp_pastyr=mean(work_pastyr)

//.........................................//
*Exposure to media 

gen newspaper = v157
copydesc v157 newspaper
gen radio = v158
copydesc v158 radio
gen tv = v159
copydesc v159 tv
codebook newspaper
replace newspaper=0 if newspaper == 1
replace newspaper =1 if newspaper ==2 | newspaper==3
codebook newspaper
label define news_lbl 0 "Almost No" 1 "Yes"  
label values  newspaper news_lbl
codebook newspaper
replace tv=0 if tv == 1
replace tv =1 if tv==2 | tv==3
codebook tv
label define tv_lbl 0 "Almost No" 1 "Yes"  
label values  tv tv_lbl
replace radio=0 if radio == 1
replace radio =1 if radio ==2 | radio==3
codebook radio
label define radio_lbl 0 "Almost No" 1 "Yes"  
label values  radio radio_lbl
egen exp_media = rowmax(newspaper tv radio )
label define media_lbl 0 "No Exposure" 1 "Exposed to atleast one media"  
label values exp_media media_lbl
codebook exp_media

*Other IR variables

gen area_res = v025
gen state= v024
copydesc v024 state

replace area_res =0 if area_res ==1
replace area_res =1 if area_res ==2
label define area_lbl 0 "Urban" 1"Rural"
label values area_res area_lbl

//current marital status
recode v501 (4 5=5), gen(mstatus)
label define mstatus 1 "Married" 3 "Widowed" 5 "Divorced/Separated"
label val mstatus mstatus

//woman and spouse age
gen woman_ageint=v013
_crcslbl woman_ageint v013 
gen woman_age=v012
_crcslbl woman_age v012
gen spouse_age=v730
_crcslbl spouse_age v730

label val woman_ageint V013 

//woman and spouse occupation
recode v705 (0=0) (1 3 4 =1) (6=2) (5 7 9 = 3) (98=.), gen(spouse_occu) 
 replace spouse_occu=4 if spouse_occu==.
recode v717 (0=0) (1 3 4 =1) (6=2) (5 7 9 = 3) (98=.), gen(woman_occu)
 replace woman_occu=4 if woman_occu==.
label define occu 0 "not working/no occupation" 1 "Prof./clerical/sales" 2 "agricultural" 3 "services/manual"  4 "Don't know"
label val spouse_occu occu
label val woman_occu occu

*woman and spouse education attainment
gen woman_educ=v149 
_crcslbl woman_educ v149 
label val woman_educ V149 
gen woman_yrschool=v133
_crcslbl woman_yrschool v133

gen spouse_educ=v729
_crcslbl spouse_educ v729
label val spouse_educ V729
gen spouse_yrschool=v715
_crcslbl spouse_yrschool v715

//number of living children
recode v218 (0=0) (1 2=1) (3 4=2) (5/13 =3), gen(children)
label define kids 0 "no children" 1 "1-2 children" 2 "3-4 children" 3 "5ormore children"
label values children kids

//age at marriage
replace s308c=. if s308c==9998 | s308c==9997
replace s309=. if s309==98
gen ageatmarr=(s308c-v011)/12 if s308c!=. & v011!=.
replace ageatmarr=s309 if s309!=.
replace ageatmarr=. if ageatmarr<=0

egen ageatmarrint=cut(ageatmarr), at(0,15,18,21,25,31,49) label
replace ageatmarrint=6 if ageatmarr==.
label define marr 0 "0-14" 1 "15-17" 2 "18-20" 3 "21-24" 4 "25-30" 5 ">31" 6 "Missing"
label val ageatmarrint marr

//age at cohabitation
gen cohabitage=v511
_crcslbl cohabitage v511

//caste, religion, hhsize, wealth
recode s116 (8=4), gen(caste_group)
replace caste_group=4 if v131==993
label define caste 1 "SC" 2 "ST" 3 "OBC" 4 "None"
label val caste caste
_crcslbl caste_group s116

recode v130 ( 5 6  8 9 96= 96), gen(religion)
label define religion 1 "Hindu" 2 "Muslim" 3 "Christian" 4 "Sikh" 96 "Other"
label val religion religion
_crcslbl religion v130

recode v136 (1 2 =1) (3 4=2) (5 6=3) (7 8=4) (8/40=5), gen(hhsize)
label define hhsize 1 "1-2 members" 2 "3-4 members" 3 "5-6 members" 4 "7-8 members" 5 ">8 members"
label values hhsize hhsize

gen wealthgroup=v190
_crcslbl wealthgroup v190
label val wealthgroup V190 
//.............................................//
bysort sdist: egen dageatmarr=mean(ageatmarr)
bysort sdist: egen dfertility=mean(children)

//*REGION
recode v024 (1 2 3 4 5 6 7 8 37 =1)(28 29 31 32 33 34 35 36=2) (10 19 20 21=3) (11 12 13 14 15 16 17 18=4)  ( 24 25 27 30=5) (9 23 22=6), gen(region_new)
label def region_new 1 "North India" 2 "South India" 3 "East India" 4 "North-East India" 5 "West India" 6 "cental"
tab region_new
codebook region_new
//.......//
*Saving the IR file for all the other papers
save "D:\Dissertation - PG\NFHS-5\Final\IR_file.dta"
//drop those not selected for domestic violence module
codebook v044
drop if v044==0

*Using Survey Weights- DV weights have been divided by 1000000 to bring to 6 decimal places as specified in recode manual
gen psu= v021
gen strata= v023
gen dvwt=d005/1000000
svyset psu [pweight=dvwt], strata(strata)

//Ever-experienced IPV

*EVER EXPERIENCE
*Emotional Violence 
gen emovio=0
replace emovio=1 if d103a==1 | d103a==2 | d103a==3
replace emovio=1 if d103b==1 | d103b==2 | d103b==3
replace emovio=1 if d103c==1 | d103c==2 | d103c==3
replace emovio=. if d103a==. | d103b==. | d103c==.

*Physical Violence
gen physvio=0
//less severe
replace physvio=1 if d105a==1 |  d105a==2 | d105a==3
replace physvio=1 if d105b==1 | d105b==2 | d105b==3
replace physvio=1 if d105c==1 | d105c==2 | d105c==3
replace physvio=1 if d105j==1 | d105j==2 | d105j==3
replace physvio=. if d105a==. | d105b==. | d105c==. | d105j==.

//severe
replace physvio=1 if d105d==1 | d105d==2 | d105d==3 
replace physvio=1 if d105e==1 | d105e==2 | d105e==3
replace physvio=1 if d105f==1 | d105f==2 | d105f==3
replace physvio=. if d105d==. | d105e==. | d105f==.

*Sexual Violence
gen sexvio=0
replace sexvio=1 if d105h==1 | d105h==2 | d105h==3
replace sexvio=1 if d105i==1 | d105i==2 | d105i==3
replace sexvio=1 if d105k==1 | d105k==2 | d105k==3
replace sexvio=. if d105h==. | d105i==. | d105k==.

svy: tab emovio, percent
svy: tab d104, percent
svy: tab physvio, percent
svy: tab sexvio, percent
svy: tab d108, percent

 *All forms of DV - IPV
gen ipv=0
replace ipv=1 if emovio==1 | sexvio==1 | physvio==1
replace ipv=. if emovio==. | sexvio==. | physvio==.
svy: tab ipv, percent

*********************************
*PAST 12 MONTHS
*Emotional Violence 
gen emovio12=0
replace emovio12=1 if d103a==1 | d103a==2
replace emovio12=1 if d103b==1 | d103b==2
replace emovio12=1 if d103c==1 | d103c==2
replace emovio12=. if d103a==. | d103b==. | d103c==.

*Physical Violence
gen physvio12=0
replace physvio12=1 if d105a==1 | d105a==2
replace physvio12=1 if d105b==1 | d105b==2
replace physvio12=1 if d105c==1 | d105c==2
replace physvio12=1 if d105d==1 | d105d==2
replace physvio12=1 if d105e==1 | d105e==2
replace physvio12=1 if d105f==1 | d105f==2
replace physvio12=1 if d105j==1 | d105j==2

replace physvio12=. if d105a==. | d105b==. | d105c==. | d105d==. | d105e==. | d105f==. | d105j==.

*Sexual Violence
gen sexvio12=0
replace sexvio12=1 if d105h==1 | d105h==2
replace sexvio12=1 if d105i==1 | d105i==2
replace sexvio12=1 if d105k==1 | d105k==2
replace sexvio12=. if d105h==. | d105i==. | d105k==. 

*IPV past 12 mos
gen ipv12=0
replace ipv12=1 if emovio12==1 | sexvio12==1 | physvio12==1
replace ipv12=. if emovio12==. | physvio12==. | sexvio12==.

svy: tab emovio12, percent
svy: tab physvio12, percent
svy: tab sexvio12, percent
svy: tab ipv12, percent


*********************************
*IPV experienced before 1 year (not in the past 12 months)
*Emotional Violence 
gen emoviopast=0
replace emoviopast=1 if d103a==3
replace emoviopast=1 if d103b==3
replace emoviopast=1 if d103c==3
replace emoviopast=. if d103c==.

*Physical Violence
gen physviopast=0
//less severe
replace physviopast=1 if d105a==3
replace physviopast=1 if d105b==3
replace physviopast=1 if d105c==3
replace physviopast=1 if d105j==3
replace physviopast=. if d105a==. | d105b==. | d105c==. | d105j==.

//severe
replace physviopast=1 if d105d==3 
replace physviopast=1 if d105e==3
replace physviopast=1 if d105f==3
replace physviopast=. if d105d==. | d105e==. | d105f==.

*Sexual Violence
gen sexviopast=0
replace sexviopast=1 if d105h==3
replace sexviopast=1 if d105i==3
replace sexviopast=1 if d105k==3
replace sexviopast=. if d105h==. | d105i==. | d105k==.

svy: tab emoviopast, percent
svy: tab physviopast, percent
svy: tab sexviopast, percent

*All forms of DV - IPV
gen ipvpast=0
replace ipvpast=1 if emoviopast==1 | sexviopast==1 | physviopast==1
replace ipvpast=. if emoviopast==. | sexviopast==. | physviopast==.
svy: tab ipvpast, percent

//--------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------

bysort sdist: egen ipvrate=mean(ipv)
bysort sdist: egen ipv12rate=mean(ipv12)
bysort sdist: egen physvio12rate=mean(physvio12)
bysort sdist: egen emovio12rate=mean(emovio12)
bysort sdist: egen sexvio12rate=mean(sexvio12)

bysort sdist: egen ipvpastrate=mean(ipvpast)
bysort sdist: egen physviorate=mean(physvio)
bysort sdist: egen emoviorate=mean(emovio)
bysort sdist: egen sexviorate=mean(sexvio)

gen abusehistory=d121
_crcslbl abusehistory d121
label val abusehistory D121

bysort v021: egen cabusehistory=mean(abusehistory)

gen hv024=v024
gen hv001=v001
sort hv024 hv001 hv002
save "D:\Dissertation - PG\NFHS-5\Final\DV_IR.dta", replace

*Merging with  BR IR file

clear
clear matrix
clear mata
set maxvar 30000
set more off
use "D:\Dissertation - PG\NFHS-5\Final\DV_BR.dta"
sort v024 v001 v002 v003

merge m:1 v024 v001 v002 v003 using "D:\Dissertation - PG\NFHS-5\Final\DV_IR.dta"

keep if _merge==3
drop _merge
save "D:\Dissertation - PG\NFHS-5\Final\DV_BR_IR_married.dta"

//merge houshold structure from household data
sort hv024 hv001 hv002
merge m:1 hv024 hv001 hv002 using "D:\Dissertation - PG\NFHS-5\Final\DV_HR.dta"
keep if _merge==3
drop _merge
save "D:\Dissertation - PG\NFHS-5\Final\DV_BR_IR_HR_married.dta"

// merge men's and household files
//--------------------------------------------------------------------------------------------------------------------------------------

//merge details from men's data
gen mv001= v001
gen mv002=v002
gen mv003=v034

merge m:1 mv001 mv002 mv003 using "D:\Dissertation - PG\NFHS-5\IAMR7BFL.DTA"
////husband's details are available for 48,129 women only
gen spouseinterview=_merge==3
drop if _merge==2
drop _merge

//merge houshold structure from household data
sort hv024 hv001 hv002

merge m:1 hv024 hv001 hv002 using "D:\Dissertation - PG\NFHS-5\Final\DV_hh_IR_married_1.dta"
keep if _merge==3
drop _merge
save "D:\Dissertation - PG\NFHS-5\Final\DV_HH_IR_IPV_married_1.dta"

tab spouseinterview
drop if spouseinterview==0
*Father alcoholic
recode d113 (0=0) (1=1), gen(spouse_alcohol)
recode v505 (0=0) (1/9 = 1) (98=2) (.=2), gen(polygamy)
label define polygamy 0 "No" 1 "Yes" 2 "Missing"
label  val polygamy polygamy

*Abuse History of Wife (Did father ever beat her mother?--but it only measures physical violence)
gen abusehistory=d121
_crcslbl abusehistory d121
label val abusehistory D121

*Abuse history of husband(Did father ever beat his mother?
gen abusehistory_husband=sm716
_crcslbl abusehistory_husband sm716
label val abusehistory_husband sm716

*Merging of BR IR HR and Dowry Death data
clear
use "D:\Dissertation - PG\NFHS-5\Final\DV_BR_IR_HR_married.dta"
gen state_id = string(v024, "%02.0f")
gen district_id = string(sdist, "%03.0f")
gen unique_id = state_id + "-" + district_id

merge m:1 unique_id using "D:\Dissertation - PG\NFHS-5\Final\Dowry deaths - 2020 (districts).dta"
keep if _merge==3
save "D:\Dissertation - PG\NFHS-5\Final\DV_BR_IR_HR_married_dowry.dta", replace

*Merging of BR IR HR and MR
clear
use "D:\Dissertation - PG\NFHS-5\Final\DV_BR_IR_HR_married.dta" 
gen mv001= v001
gen mv002=v002
gen mv003=v034

merge m:1 mv001 mv002 mv003 using "D:\Dissertation - PG\NFHS-5\IAMR7BFL.DTA"
keep if _merge==3
save "D:\Dissertation - PG\NFHS-5\Final\DV_BR_IR_HR_MR_married.dta", replace

*Merging BR IR HR and Patriarchy Index data
clear
use "D:\Dissertation - PG\NFHS-5\Final\DV_BR_IR_HR_married_dowry.dta"
merge m:1 state2 using "D:\Dissertation - PG\NFHS-5\Final\Patriarchy_State.dta"
keep if _merge==3
save "D:\Dissertation - PG\NFHS-5\Final\DV_BR_IR_HR_married_dowry_Patriarchy.dta" ,replace

collapse (mean) patriarchy_index =patriarchy_index, by(state2)
rename state2 State_Name

merge 1:1 State_Name using "D:\Dissertation - PG\Map File\state1.dta"

xtile terpatriarchy= patriarchy_index, nq(3)
label define tercile 1"Low" 2"Middle" 3"High" ,replace
label values terpatriarchy tercile

list State_Name if terpatriarchy==1
list State_Name if terpatriarchy==2
list State_Name if terpatriarchy==3
save "D:\Dissertation - PG\NFHS-5\Final\data_for_patriarchy_map.dta", replace

spmap terpatriarchy using "D:\Dissertation - PG\Map File\dsbankcoord.dta" , id(id) fcolor(YlGn) ocolor(black)  clmethod(unique)  ndfcolor(gray) ndocolor(black) legend(on) title(Patriarchy Index)

graph export "patriarchy.png", replace

*Indicators of Malnutrition

//map: stunted//
clear
use "D:\Dissertation - PG\NFHS-5\Final\DV_BR.dta"
collapse (mean) stunted =stunted, by(v024)
decode v024, gen(State_Name)
merge 1:1 State_Name using "D:\Dissertation - PG\Map File\state1.dta"

xtile terstunted= stunted, nq(3)
label define tercile 1"Low" 2"Middle" 3"High" ,replace
label values terstunted tercile

spmap terstunted using "D:\Dissertation - PG\Map File\dsbankcoord.dta" , id(id) fcolor(YlGn) ocolor(black)  clmethod(unique)  ndfcolor(gray) ndocolor(black) legend(on) title(Malnutrition-Stunted)

graph export "stunted.png", replace

//map: underweight//
clear
use "D:\Dissertation - PG\NFHS-5\Final\DV_BR.dta"
collapse (mean) underwt=underwt, by(v024)
decode v024, gen(State_Name)
merge 1:1 State_Name using "D:\Dissertation - PG\Map File\state1.dta"

xtile terunderweight= underwt, nq(3)
label define tercile 1"Low" 2"Middle" 3"High" ,replace
label values terunderweight tercile

spmap terunderweight using "D:\Dissertation - PG\Map File\dsbankcoord.dta" , id(id) fcolor(YlGn) ocolor(black)  clmethod(unique)  ndfcolor(gray) ndocolor(black) legend(on) title(Malnutrition-Underweight)

graph export "underweight.png", replace

//map: wasting//
clear
use "D:\Dissertation - PG\NFHS-5\Final\DV_BR.dta"
collapse (mean) wasting=wasting, by(v024)
decode v024, gen(State_Name)
merge 1:1 State_Name using "D:\Dissertation - PG\Map File\state1.dta"

xtile terwasting= wasting, nq(3)
label define tercile 1"Low" 2"Middle" 3"High" ,replace
label values terwasting tercile

spmap terwasting using "D:\Dissertation - PG\Map File\dsbankcoord.dta" , id(id) fcolor(YlGn) ocolor(black)  clmethod(unique)  ndfcolor(gray) ndocolor(black) legend(on) title(Malnutrition-Wasting)

graph export "wasting.png", replace

*IPV Map
clear
use "D:\Dissertation - PG\NFHS-5\Final\DV_BR_IR_HR_married.dta"
collapse (mean) ipv= ipv, by(State_Name)
save "D:\Dissertation - PG\NFHS-5\Final\IPV.dta" ,replace

use "D:\Dissertation - PG\Map File\state1.dta", clear 
merge 1:1 State_Name using "D:\Dissertation - PG\NFHS-5\Final\IPV.dta"
//make sure that the state name and variable name "State_Name" are same in both ipv.dta and dsbank.dta files

xtile teripv= ipv, nq(3)
label define tercile 1"Low" 2"Middle" 3"High" ,replace
label values teripv tercile

spmap teripv using "D:\Dissertation - PG\Map File\dsbankcoord.dta" , id(id) fcolor(Blues2) ocolor(black)  clmethod(unique)  ndfcolor(gray) ndocolor(black) legend(on) title(Intimate Partner Violence)

graph export "ipv.png", replace

*IV generation
clear
use "D:\Dissertation - PG\NFHS-5\Final\DV_BR_IR_HR_married_dowry.dta"

svyset psu [pweight=dvwt], singleunit(certainty) strata(strata)
svy: reg  ipv  cabusehistory  i.state
svy: reg ipv dowry_deaths  i.state

**Health Care Provisional Variables

* 1. Distance to health facility
gen distance_healthfac=.
replace distance_healthfac=0 if v467d==0|v467d==2
replace distance_healthfac=1 if v467d==1
label define distance_healthfac 0 "No Problem" 1 "Big Problem"
label values distance_healthfac distance_healthfac
label var distance_healthfac "Distance to health facility"
 
* 2. During pregnancy received tetanus injection
gen tet_rec=.
replace tet_rec=0 if m1==0|m1==8|m1==.
replace tet_rec=1 if m1>=1 & m1<=7
label define tet_rec  0 "Not Received" 1 "Received",modify
label values tet_rec tet_rec
label var tet_rec "Tetanus Injection Received"

* 3. Received Benefits from anganwadi centre during pregnancy
gen Rec_ben_anganwadi_ICDS=.
replace Rec_ben_anganwadi_ICDS=0 if s562==0|s562==.
replace Rec_ben_anganwadi_ICDS=1 if s562==1
label define  Rec_ben_anganwadi_ICDS 0 "Not Received" 1 "Received",modify
label value Rec_ben_anganwadi_ICDS Rec_ben_anganwadi_ICDS
label var Rec_ben_anganwadi_ICDS "Received Benefits from anganwadi centre during pregnancy"

* 4. Respondant Check up after delivery
gen checkup_delivery=.
replace checkup_delivery=0 if m66==0|m66==.
replace checkup_delivery=1 if m66==1
label define checkup_delivery  0 "No" 1 "Yes",modify
label values checkup_delivery checkup_delivery
label var checkup_delivery "Respondant Check up after delivery"

* 5. Received Skilled Assistance during pregnancy
gen skill_assis_preg=.
replace skill_assis_preg=0 if m3a==0|m3a==.|m3b==0|m3b==.
replace skill_assis_preg=1 if m3a==1|m3b==1
label define skill_assis_preg 0 "Not Received" 1 "Received",modify
label value skill_assis_preg skill_assis_preg
label var skill_assis_preg "Received Skilled Assistance during pregnancy"

* 6. Receive Mother and Child Protection Card after registration
gen rec_protcard=.
replace rec_protcard=0 if s412==0|s412==.
replace rec_protcard=1 if s412==1
label define rec_protcard  0 "No" 1 "Yes",modify
label values rec_protcard rec_protcard
label var rec_protcard "Receive Mother and Child Protection Card" 
 
*Health care utilization variables

* 1. Minimum four antenatal vist
gen antenatal_visit=.
replace antenatal_visit=0 if m14==0|m14==98|m14>=1 & m14<=3|m14==.
replace antenatal_visit=1 if m14>=4 & antenatal_visit!=0
label define antenatal_visit 0 "No" 1 "Yes"
label values antenatal_visit antenatal_visit
label var antenatal_visit "Minimum four antenatal vist"

* 2. Place of deivery
gen place_delivery=. if m15==.
replace place_delivery=0 if inlist(m15,10,11,12,13)
replace place_delivery=1 if inlist(m15,20,21,22,23,24,25,26,27,30,31,32,33,96)
label define place_delivery 0 "Home delivery" 1 "Institutional delivery", modify
label values place_delivery place_delivery
label var place_delivery "Place of deivery"

* 3. Pregnancy Registered
gen preg_reg=.
replace preg_reg=0 if s409==0|s409==.
replace preg_reg=1 if s409==1
label define preg_reg  0 "No" 1 "Yes",modify
label values preg_reg preg_reg
label var preg_reg "Pregnancy Registered" 

* 4. During last 3 months of pregnancy: met ANM, LHV, ASHA, anganwadi worker or other
gen met_anm_lhv_preg=.
replace met_anm_lhv_preg=0 if s436==0|s436==.
replace met_anm_lhv_preg=1 if s436==1
label define met_anm_lhv_preg  0 "No" 1 "Yes",modify
label values met_anm_lhv_preg met_anm_lhv_preg
label var  met_anm_lhv_preg "During last 3 months of pregnancy: met ANM, LHV, ASHA, anganwadi worker or other"

* 5. Place of first check up of baby
gen baby_first_checkup=. 
replace  baby_first_checkup=0 if m73==10| m73==11|m73==12|m73==13|m73==.|m73==0
replace  baby_first_checkup=1 if m73==20| m73==21|m73==22| m73==23|m73==24|m73==25|m73==26|m73==27|m73==28|m73==30|m73==31|m73==32|m73==33| m73==96
label define  baby_first_checkup 0 "Home" 1 "Institution", modify
label values  baby_first_checkup  baby_first_checkup
label var baby_first_checkup "Place of first check up of baby" 

* 6. Baby postnatal checkup
gen baby_pnc=.
replace baby_pnc=0 if m70==0|m70==8| m70==.
replace baby_pnc=1 if m70==1
label define baby_pnc  0 "Not Received" 1 "Received",modify
label values baby_pnc baby_pnc
label var baby_pnc "Baby postnatal checkup received"

**Principal Component Variables

*Creation of Provisional Index
pca distance_healthfac tet_rec Rec_ben_anganwadi_ICDS checkup_delivery skill_assis_preg rec_protcard [aw=dvwt]
predict provisional_index,score
label var provisional_index "provisional_index"

*Creation of Utilization_index
pca antenatal_visit place_delivery preg_reg met_anm_lhv_preg baby_first_checkup baby_pnc [aw=dvwt]
predict Utilization_index,score
label var Utilization_index "Utilization_index"

*Anaemia
gen severe_mod_anemia=0
replace severe_mod_anemia=1 if  v457==1 
replace severe_mod_anemia=1 if  v457==2

*Education and wealth group
recode woman_educ (0/2 =1) (3 =2) (4=3) (5=4), gen (edugroup)
recode woman_educ (0/2 =1) (3 =2) (4 5=3), gen (medugroup)
recode v729 (0/1 8=1) (3=2) (4 5=3), gen (sedugroup)
xtile wgroupu1=s191s, nq(3)
xtile wgroupu=s191s, nq(4)

*Difference in parental education
gen edu_diff=.
replace edu_diff=0 if sedugroup==1 | medugroup==1
replace edu_diff=0 if sedugroup==2 | medugroup==2
replace edu_diff=0 if sedugroup==3 | medugroup==3
replace edu_diff=0 if sedugroup>medugroup
replace edu_diff=1 if sedugroup<medugroup
tab edu_diff

save "D:\Dissertation - PG\NFHS-5\Final\DV_BR_IR_HR_married_dowry.dta", replace

//Descriptive statistics
local controls1 provisional_index Utilization_index birth_order eldest_son BMI_mother sex_child hh_head woman_educ spouse_educ woman_occu spouse_occu area_res caste_group religion region wealthgroup shstruc

qui tabout stunted `controls1' ipv  using table1.xls , cells(row) format(1p) clab(_ _ _) layout(rb) h3(nil) replace
ttest ipv, by(stunted)

qui tabout stunted `controls1' emovio  using table1.xls , cells(row) format(1p) clab(_ _ _) layout(rb) h3(nil) append
ttest emovio, by(stunted)

qui tabout stunted `controls1' physvio  using table1.xls , cells(row) format(1p) clab(_ _ _) layout(rb) h3(nil) append
ttest physvio, by(stunted)

qui tabout stunted `controls1' sexvio  using table1.xls , cells(row) format(1p) clab(_ _ _) layout(rb) h3(nil) append
ttest sexvio, by(stunted)

qui tabout `controls1' stunted  using table2.xls , cells(row) format(1p) clab(_ _ _) layout(rb) h3(nil) replace

*underweight

qui tabout underwt `controls1' ipv  using table3.xls , cells(row) format(1p) clab(_ _ _) layout(rb) h3(nil) replace
ttest ipv, by(underwt)

qui tabout underwt `controls1' emovio  using table3.xls , cells(row) format(1p) clab(_ _ _) layout(rb) h3(nil) append
ttest emovio, by(underwt)

qui tabout underwt `controls1' physvio  using table3.xls , cells(row) format(1p) clab(_ _ _) layout(rb) h3(nil) append
ttest physvio, by(underwt)

qui tabout underwt `controls1' sexvio  using table3.xls , cells(row) format(1p) clab(_ _ _) layout(rb) h3(nil) append
ttest sexvio, by(underwt)

qui tabout `controls1' underwt  using table3.xls , cells(row) format(1p) clab(_ _ _) layout(rb) h3(nil) append

*wasting

qui tabout wasting `controls1' ipv  using table4.xls , cells(row) format(1p) clab(_ _ _) layout(rb) h3(nil) replace
ttest ipv, by(wasting)

qui tabout wasting `controls1' emovio  using table4.xls , cells(row) format(1p) clab(_ _ _) layout(rb) h3(nil) append
ttest emovio, by(wasting)

qui tabout wasting `controls1' physvio  using table4.xls , cells(row) format(1p) clab(_ _ _) layout(rb) h3(nil) append
ttest physvio, by(wasting)

qui tabout wasting `controls1' sexvio  using table4.xls , cells(row) format(1p) clab(_ _ _) layout(rb) h3(nil) append
ttest sexvio, by(wasting)

qui tabout `controls1' wasting  using table4.xls , cells(row) format(1p) clab(_ _ _) layout(rb) h3(nil) append

qui tabout wasting `controls2' ipv  using table8.xls , cells(row) format(1p) clab(_ _ _) layout(rb) h3(nil) replace

*spousal control and IPV

qui tabout ipv `controls1' control_spoused   using table5.xls , cells(row) format(1p) clab(_ _ _) layout(rb) h3(nil) append

qui tabout ipv `controls1' wifebeatjustd   using table5.xls , cells(row) format(1p) clab(_ _ _) layout(rb) h3(nil) append

*eldest son and elder brother
clear
use "D:\Dissertation - PG\NFHS-5\Final\DV_BR_IR_HR_married_dowry.dta"

ttest ipv, by(eldest_son)
ttest ipv, by(elder_brother)

*suffering from any kind of malnourishment
gen malnourished=1 if stunted==1 | underwt==1|wasting==1
replace malnourished=0 if malnourished==.
ttest ipv, by(malnourished)
ttest physvio, by(malnourished)
ttest emovio, by(malnourished)
ttest sexvio, by(malnourished)
ttest ipv if b19<12, by(malnourished)
ttest ipv if b19>12 & b19<59, by(malnourished)
ttest physvio if b19>12 & b19<59, by(malnourished)
ttest physvio if b19<12, by(malnourished)
ttest emovio if b19>12 & b19<59, by(malnourished)
ttest emovio if b19<12, by(malnourished)
ttest sexvio if b19<12, by(malnourished)
ttest sexvio if b19>12 & b19<59, by(malnourished)

*patriarchy index
clear
use "D:\Dissertation - PG\NFHS-5\Final\DV_BR_IR_HR_married_dowry_Patriarchy.dta"

xtile terpatriarchy= patriarchy_index, nq(3)
label define tercile 1"Low" 2"Middle" 3"High" ,replace
label values terpatriarchy tercile

gen low_patriarchy_index=0
gen middle_patriarchy_index=0
gen high_patriarchy_index=0

replace low_patriarchy_index=1 if terpatriarchy==1
replace middle_patriarchy_index=1 if terpatriarchy==2
replace high_patriarchy_index=1 if terpatriarchy==3

ttest ipv, by(low_patriarchy_index)
ttest ipv, by(middle_patriarchy_index)
ttest ipv, by(high_patriarchy_index)

*main regression
//IV: cabusehistory
clear
use "D:\Dissertation - PG\NFHS-5\Final\DV_BR_IR_HR_married.dta"

local control1 i.ANC i.PNC i.institutional_delivery i.mother_undernourished birth_order age_first_birth size_at_birth height_mother i.sex_child i.hh_head i.woman_educ i.spouse_educ i.woman_occu i.spouse_occu i.area_res i.caste_group i.religion i.wealthgroup i.shstruc meanedu wealthmed dageatmarr i.state

*appendix
biprobit (stunted= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021)
margins,dydx(*) post
outreg2 using margins1.doc, replace

biprobit (underwt= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021)
margins,dydx(*) post
outreg2 using margins1.doc, replace

biprobit (wasting= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021)
margins,dydx(*) post
outreg2 using margins1.doc, replace

biprobit (stunted= i.emovio `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021)
margins,dydx(emovio) post
outreg2 using margins1.doc, replace

biprobit (stunted= i.sexvio `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021)
margins,dydx(sexvio) post
outreg2 using margins1.doc, replace

biprobit (stunted= i.physvio `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021)
margins,dydx(physvio) post
outreg2 using margins1.doc, replace

*baseline regression
biprobit (stunted= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021)
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (stunted= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021)
margins,dydx(cabusehistory) post
outreg2 using margins1.doc, replace

biprobit (underwt= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021)
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (underwt= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021)
margins,dydx(cabusehistory) post
outreg2 using margins1.doc, replace

biprobit (wasting= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021)
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (wasting= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021)
margins,dydx(cabusehistory) post
outreg2 using margins1.doc, replace

*both are coming insignificant. So we go for subsample and interaction
//eldest son
biprobit (stunted= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if eldest_son==1
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (stunted= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if eldest_son==0
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (stunted= i.ipv##eldest_son `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021)
margins,dydx(ipv eldest_son) post

biprobit (stunted= i.ipv##eldest_son `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021)
margins r.eldest_son, over(r.ipv) contrast(effects nowald) predict(pmarg1) force post


biprobit (underwt= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if eldest_son==1
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (underwt= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if eldest_son==0
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (underwt= i.ipv##eldest_son `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021)
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (wasting= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if eldest_son==1
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (wasting= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if eldest_son==0
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (wasting= i.ipv##eldest_son `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021)
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

//brother sibling
biprobit (stunted= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if brother_sibling==1
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (stunted= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if brother_sibling==0
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (stunted= i.ipv##brother_sibling `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021)
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (underwt= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if brother_sibling==1
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (underwt= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if brother_sibling==0
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (underwt= i.ipv##brother_sibling `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021)
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (wasting= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if brother_sibling==1
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (wasting= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if brother_sibling==0
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (wasting= i.ipv##brother_sibling `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021)
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

*Assortative mating
replace edu_diff=2 if sedugroup>medugroup

biprobit (stunted= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if edu_diff==0
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (stunted= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if edu_diff==1
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (stunted= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if edu_diff==2
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (underwt= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if edu_diff==0
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (underwt= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if edu_diff==1
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (underwt= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if edu_diff==2
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (wasting= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if edu_diff==0
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (wasting= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if edu_diff==1
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (wasting= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if edu_diff==2
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

*wifebeatjust
biprobit (stunted= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if wifebeatjustd==1
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (stunted= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if wifebeatjustd==0
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (underwt= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if wifebeatjustd==1
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (underwt= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if wifebeatjustd==0
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (wasting= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if wifebeatjustd==1
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (wasting= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if wifebeatjustd==0
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

*patriarchy dummy
use "D:\Dissertation - PG\NFHS-5\Final\DV_BR_IR_HR_married_dowry_Patriarchy.dta"
gen avg_patriarchy_index= patriarchy_index
cluster kmeans avg_patriarchy_index, k(4) measure(L2) start(krandom)
tabulate _clus_1
by _clus_1, sort : summarize avg_patriarchy_index
tab state if _clus_1==1
tab state if _clus_1==2
tab state if _clus_1==3
tab state if _clus_1==4
egen cluster_mean = mean(avg_patriarchy_index), by(_clus_1)
gen patriarchy_dummy=.
replace patriarchy_dummy=1 if _clus_1 == 2
replace patriarchy_dummy=2 if _clus_1 == 3
replace patriarchy_dummy=3 if _clus_1 == 4
replace patriarchy_dummy=4 if _clus_1 == 1
drop if patriarchy_dummy==.
gen lower_patriarchy_dummy=0
gen middle_patriarchy_dummy=0
gen higher_patriarchy_dummy=0
gen highest_patriarchy_dummy=0
replace lower_patriarchy_dummy=1 if patriarchy_dummy==1
replace middle_patriarchy_dummy=1 if patriarchy_dummy==2
replace higher_patriarchy_dummy=1 if patriarchy_dummy==3
replace highest_patriarchy_dummy=1 if patriarchy_dummy==4

biprobit (stunted= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if low_patriarchy_index==1
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (underwt= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if low_patriarchy_index==1
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (wasting= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if low_patriarchy_index==1
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (stunted= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if middle_patriarchy_index==1
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (underwt= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if middle_patriarchy_index==1
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (wasting= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if middle_patriarchy_index==1
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (stunted= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if high_patriarchy_index==1
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (underwt= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if high_patriarchy_index==1
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (wasting= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if high_patriarchy_index==1
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

*girl child
local control1 i.ANC i.PNC i.institutional_delivery i.mother_undernourished birth_order age_first_birth size_at_birth height_mother i.hh_head i.woman_educ i.spouse_educ i.woman_occu i.spouse_occu i.area_res i.caste_group i.religion i.wealthgroup i.shstruc meanedu wealthmed dageatmarr i.state

biprobit (stunted= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if sex_child==1
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (stunted= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if sex_child==0
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (stunted= i.ipv##sex_child `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021)
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (underwt= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if sex_child==1
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (underwt= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if sex_child==0
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (underwt= i.ipv##sex_child `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021)
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (wasting= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if sex_child==1
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (wasting= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if sex_child==0
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

biprobit (wasting= i.ipv##sex_child `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021)
margins,dydx(ipv) post
outreg2 using margins1.doc, replace

*dummy variable for eager to get a boy child or not
gen eagerboychild = 0
forvalues i = 2/16 {
	replace eagerboychild = 1 if bord_`=string(`i', "%02.0f")' == 1 & b4_`=string(`i', "%02.0f")' == 2 & b11_`=string(`=`i'-1', "%02.0f")' < 15
}
label define eagerboychild 0"Not so eager to get a boy child" 1"Eager to get a boy child"
label val eagerboychild eagerboychild


*Descriptive Statistics
ttest ipv, by(eldest_son)
ttest ipv, by(elder_brother)
ttest ipv, by(eagerboychild)

ttest physvio, by(eldest_son)
ttest physvio, by(elder_brother)
ttest physvio, by(eagerboychild)

local control1 i.ANC i.PNC i.institutional_delivery i.mother_undernourished birth_order age_first_birth size_at_birth height_mother i.hh_head i.woman_educ i.spouse_educ i.woman_occu i.spouse_occu i.area_res i.caste_group i.religion i.wealthgroup i.shstruc meanedu wealthmed dageatmarr i.state

biprobit (stunted= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if eagerboychild==1
margins,dydx(ipv) post

*New regressions

biprobit (stunted= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if eagerboychild==1
margins,dydx(ipv) post

biprobit (stunted= i.ipv `control1') (ipv=cabusehistory `control1')[pweight=dvwt],vce(cluster v021), if eagerboychild==0
margins,dydx(ipv) post

*repeat for underweight and wasting

