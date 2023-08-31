**IV Regression where the instruments are defined using age eligibility

///Data Cleaning
gen white=0
replace white=1 if Combined_Race==4
label define white 1 "white"

gen black=0
replace black=1 if Combined_Race==2
label define black 1 "black"

gen asian=0
replace asian=1 if Combined_Race==1
label define asian 1 "asian"

gen other=0
replace other=1 if Combined_Race==0
label define other 1 "other or NA"

gen hispanic=0
replace hispanic=1 if Combined_Race==3
label define hispanic 1 "Hispanic or Latino"

destring Gender, generate (FemMale)
gen male = Gender==1
gen female = Gender==0

gen AngelTree = 0
replace AngelTree = 1 if AttendeeAngelTree ==0

gen incstatus = 0
replace incstatus = 1 if Prison ==1 | Jail ==1 | Prison ==1 & Jail ==1

gen Felony=0
replace Felony=1 if CodedCharges==1
label define Felony 1 "Felony"

gen Misdemeanor=0
replace Misdemeanor=1 if CodedCharges==2
label define Misdemeanor 1 "Misdemeanor"

gen Misdemeanor_Felony=0
replace Misdemeanor_Felony=1 if CodedCharges==3
label define Misdemeanor_Felony 1 "Misdemeanor_Felony"

//Combining Discontinued and N/A Buckets//
replace AlumniStatus = 0 if AlumniStatus==2

// rename Alumni1Discontinued0 alumstatus 
destring ZipCode, generate(ZipNum) force

*generate dummy for people who attended Camp Hope (received treatment)
gen attendance = AttendeeAngelTree if AttendeeAngelTree==1

gen Age_8=0
replace Age_8=1 if Age_Start_Program==8

gen Age_9=0
replace Age_9=1 if Age_Start_Program==9

gen Age_10=0
replace Age_10=1 if Age_Start_Program==10

gen Age_11=0
replace Age_11=1 if Age_Start_Program==11

gen Age_12=0
replace Age_12=1 if Age_Start_Program==12

gen Age_8_x_CampHopeZip = Age_8*CampHopeZip
gen Age_9_x_CampHopeZip = Age_9*CampHopeZip
gen Age_10_x_CampHopeZip = Age_10*CampHopeZip
gen Age_11_x_CampHopeZip = Age_11*CampHopeZip
gen Age_12_x_CampHopeZip = Age_12*CampHopeZip

///Labelling 
label variable CurrentAge "Current Age"
label variable AlumniStatus "Alumni"
label variable black "Black"
label variable hispanic "Hispanic"
label variable male "Male"
label variable incstatus "Incarceration"
label variable AgeList "Age Contacted"
label variable AttendeeAngelTree "Attended Camp"
label variable Age_8 "Contacted at Age 8"
label variable Age_9 "Contacted at Age 9"
label variable Age_10 "Contacted at Age 10"
label variable Age_11 "Contacted at Age 11"
label variable Age_12 "Contacted at Age 12"

///OLS specifications///
*Camp Hope
xtset ZipNum
xtreg incstatus CurrentAge male black hispanic AttendeeAngelTree YearsAttended, fe i(ZipNum) 
outreg2 using results.doc, replace ctitle(Incarceration)
*Camp Hope Graduation
xtreg incstatus CurrentAge male black hispanic AlumniStatus, fe i(ZipNum)
outreg2 using results.doc, append ctitle(Incarceration)
*Camp Hope & Camp Hope Graduation
xtreg incstatus CurrentAge male black hispanic AttendeeAngelTree AlumniStatus, fe i(ZipNum)
outreg2 using results.doc, append ctitle(Incarceration)
**Prison
xtreg Prison CurrentAge male black hispanic AttendeeAngelTree AlumniStatus, fe i(ZipNum)
outreg2 using results.doc, append ctitle(Prison)
**Jail
xtreg Jail CurrentAge male black hispanic AttendeeAngelTree AlumniStatus,fe i(ZipNum)
outreg2 using results.doc, append ctitle(Jail)
**Misdemeanor**
xtreg Misdemeanor CurrentAge male black hispanic AttendeeAngelTree AlumniStatus,fe i(ZipNum)
outreg2 using results.doc, append ctitle(Misdemeanor)
**Felony**
xtreg Felony CurrentAge male black hispanic AttendeeAngelTree AlumniStatus,fe i(ZipNum)
outreg2 using results.doc, append ctitle(Felony)

///Latest IVs///
ivregress 2sls incstatus (AttendeeAngelTree = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male i.ZipNum, first
outreg2 using ivresults.doc, replace ctitle(Incarceration)
estat endogenous
estat firststage
estat overid
* Tests show probably should use IV, strong first-stage, and instruments are valid.
* Regression shows small negative point estimate, not statistically significant.
* Compare with OLS:
reg incstatus AttendeeAngelTree black hispanic CurrentAge male i.ZipNum

ivregress 2sls Prison (AttendeeAngelTree = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male i.ZipNum, first
outreg2 using ivresults.doc, append ctitle(Prison)

ivregress 2sls Jail (AttendeeAngelTree = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male i.ZipNum, first
outreg2 using ivresults.doc, append ctitle(Jail)

ivregress 2sls Felony (AttendeeAngelTree = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male i.ZipNum, first
outreg2 using ivresults.doc, append ctitle(Felony)

* Note that there seems to be strong negative effect on felonies!

* Without fixed effects:
ivregress 2sls Prison (AttendeeAngelTree = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male, first
ivregress 2sls Jail (AttendeeAngelTree = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male, first
ivregress 2sls Felony (AttendeeAngelTree = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male, first
* Felonies point estimate is similar buy less significant without FE.

*using alum status
ivregress 2sls incstatus (AlumniStatus = Age_9 Age_10) black hispanic CurrentAge male i.ZipNum, first
outreg2 using alumiv.doc, append ctitle(Inc Alumni)
estat endogenous
estat firststage
estat overid
* Tests show that can't reject OLS efficiency, first-stage is barely strong enough, instruments are valid.
* Tests show positive coefficient, not significant--large standard errors
reg incstatus AlumniStatus black hispanic CurrentAge male i.ZipNum

* Other outcomes:
ivregress 2sls Prison (AlumniStatus = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male i.ZipNum, first
outreg2 using alumiv.doc, append ctitle(Prison Alumni)

ivregress 2sls Jail (AlumniStatus = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male i.ZipNum, first
outreg2 using alumiv.doc, append ctitle(Jail Alumni)

ivregress 2sls Felony (AlumniStatus = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male i.ZipNum, first
outreg2 using alumiv.doc, append ctitle(Felony Alumni)

* Impact on committing Felony is big and borderline significant.


*** Now try doing the two of them together: Attending Camp and Alumni Status
ivregress 2sls incstatus (AttendeeAngelTree AlumniStatus = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male i.ZipNum, first
outreg2 using otheriv.doc, append ctitle(Inc Alumni & Attendee)
estat endogenous
estat firststage
estat overid
* Note: I think you can't do them together because the instruments don't satisfy rank condition, do all heavy lifting on attending camp hope.


//Geography
gen Atlanta = 0
replace Atlanta = 1 if County =="Cherokee County" | County =="Clayton County" | County =="Cobb County" | County =="DeKalb County" | County =="Douglas County" | County =="Fayette County" | County =="Forsyth County" | County =="Fulton County" | County =="Gwinnett County" | County =="Rockdalet County" | County =="Atlanta County" 


//Bruce IV work//

* Using LASSO to select instruments for AttendeeAngelTree and AlumniStatus:
cvlasso AttendeeAngelTree black hispanic CurrentAge male Age_8 Age_9 Age_10 Age_11 Age_8_x_CampHopeZip Age_9_x_CampHopeZip Age_10_x_CampHopeZip Age_11_x_CampHopeZip, seed(123) lopt notpen(black hispanic CurrentAge male) alpha(1) nfolds(10)
* Selected Age_8 Age_9 Age_10 Age_11 Age_8_x_CampHopeZip

cvlasso AlumniStatus black hispanic CurrentAge male Age_8 Age_9 Age_10 Age_11 Age_8_x_CampHopeZip Age_9_x_CampHopeZip Age_10_x_CampHopeZip Age_11_x_CampHopeZip, seed(123) lopt notpen(black hispanic CurrentAge male) alpha(1) nfolds(10)
* LASSO does not select any of the instruments--they appear to be generally weak for AlumniStatus
reg incstatus AttendeeAngelTree black hispanic CurrentAge male i.ZipNum

ivregress 2sls Prison (AttendeeAngelTree = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male i.ZipNum, first
ivregress 2sls Jail (AttendeeAngelTree = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male i.ZipNum, first
ivregress 2sls Felony (AttendeeAngelTree = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male i.ZipNum, first
* Note that there seems to be strong negative effect on felonies!

* Without fixed effects:
ivregress 2sls Prison (AttendeeAngelTree = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male, first
ivregress 2sls Jail (AttendeeAngelTree = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male, first
ivregress 2sls Felony (AttendeeAngelTree = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male, first
* Felonies point estimate is similar buy less significant without FE.



*** Now do Alumni Status:
reg AlumniStatus Age_8 Age_9 Age_10 Age_11 Age_8_x_CampHopeZip Age_9_x_CampHopeZip Age_10_x_CampHopeZip Age_11_x_CampHopeZip black hispanic CurrentAge male i.ZipNum
test Age_8 Age_9 Age_10 Age_11 Age_8_x_CampHopeZip Age_10_x_CampHopeZip Age_11_x_CampHopeZip
* Only going to use Age_9 Age_10 

* Check them:
reg AlumniStatus Age_9 Age_10 black hispanic CurrentAge male i.ZipNum
test Age_9 Age_10 
* Moderate strong F-stat, 8.44.

ivregress 2sls incstatus (AlumniStatus = Age_9 Age_10) black hispanic CurrentAge male i.ZipNum, first
estat endogenous
estat firststage
estat overid
* Tests show that can't reject OLS efficiency, first-stage is barely strong enough, instruments are valid.
* Tests show positive coefficient, not significant--large standard errors
reg incstatus AlumniStatus black hispanic CurrentAge male i.ZipNum

* Other outcomes:
ivregress 2sls Prison (AlumniStatus = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male i.ZipNum, first
ivregress 2sls Jail (AlumniStatus = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male i.ZipNum, first
ivregress 2sls Felony (AlumniStatus = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male i.ZipNum, first
* Impact on committing Felony is big and borderline significant.

* Other outcomes no fixed effects:
ivregress 2sls Prison (AlumniStatus = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male, first
ivregress 2sls Jail (AlumniStatus = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male, first
ivregress 2sls Felony (AlumniStatus = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male, first
* Similar result, though less significant.


*** Now try doing the two of them together: Attending Camp and Alumni Status
ivregress 2sls incstatus (AttendeeAngelTree AlumniStatus = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male i.ZipNum, first
estat endogenous
estat firststage
estat overid
* Note: I think you can't do them together because the instruments don't satisfy rank condition, do all heavy lifting on attending camp hope.






*** First do Attending Camp Hope:
* Use OLS to explore the best instruments:
reg AttendeeAngelTree Age_8 Age_9 Age_10 Age_11 Age_8_x_CampHopeZip Age_9_x_CampHopeZip Age_10_x_CampHopeZip Age_11_x_CampHopeZip black hispanic CurrentAge male i.ZipNum
test Age_8 Age_9 Age_10 Age_11 Age_8_x_CampHopeZip Age_10_x_CampHopeZip Age_11_x_CampHopeZip
* Only going to use Age_9 Age_10 Age_11 Age_10_x_CampHopeZip 

* Check them:
reg AttendeeAngelTree Age_9 Age_10 Age_11 Age_10_x_CampHopeZip black hispanic CurrentAge male i.ZipNum
test Age_9 Age_10 Age_11 Age_10_x_CampHopeZip
* Really strong F-stat, these look good.

ivregress 2sls incstatus (AttendeeAngelTree = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male i.ZipNum, first
estat endogenous
estat firststage
estat overid
* Tests show probably should use IV, strong first-stage, and instruments are valid.
* Regression shows small negative point estimate, not statistically significant.
* Compare with OLS:
reg incstatus AttendeeAngelTree black hispanic CurrentAge male i.ZipNum

ivregress 2sls Prison (AttendeeAngelTree = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male i.ZipNum, first
ivregress 2sls Jail (AttendeeAngelTree = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male i.ZipNum, first
ivregress 2sls Felony (AttendeeAngelTree = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male i.ZipNum, first
* Note that there seems to be strong negative effect on felonies!

* Without fixed effects:
ivregress 2sls Prison (AttendeeAngelTree = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male, first
ivregress 2sls Jail (AttendeeAngelTree = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male, first
ivregress 2sls Felony (AttendeeAngelTree = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male, first
* Felonies point estimate is similar buy less significant without FE.



*** Now do Alumni Status:
reg AlumniStatus Age_8 Age_9 Age_10 Age_11 Age_8_x_CampHopeZip Age_9_x_CampHopeZip Age_10_x_CampHopeZip Age_11_x_CampHopeZip black hispanic CurrentAge male i.ZipNum
test Age_8 Age_9 Age_10 Age_11 Age_8_x_CampHopeZip Age_10_x_CampHopeZip Age_11_x_CampHopeZip
* Only going to use Age_9 Age_10 

* Check them:
reg AlumniStatus Age_9 Age_10 black hispanic CurrentAge male i.ZipNum
test Age_9 Age_10 
* Moderate strong F-stat, 8.44.

ivregress 2sls incstatus (AlumniStatus = Age_9 Age_10) black hispanic CurrentAge male i.ZipNum, first
estat endogenous
estat firststage
estat overid
* Tests show that can't reject OLS efficiency, first-stage is barely strong enough, instruments are valid.
* Tests show positive coefficient, not significant--large standard errors
reg incstatus AlumniStatus black hispanic CurrentAge male i.ZipNum

* Other outcomes:
ivregress 2sls Prison (AlumniStatus = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male i.ZipNum, first
ivregress 2sls Jail (AlumniStatus = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male i.ZipNum, first
ivregress 2sls Felony (AlumniStatus = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male i.ZipNum, first
* Impact on committing Felony is big and borderline significant.

* Other outcomes no fixed effects:
ivregress 2sls Prison (AlumniStatus = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male, first
ivregress 2sls Jail (AlumniStatus = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male, first
ivregress 2sls Felony (AlumniStatus = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male, first
* Similar result, though less significant.


*** Now try doing the two of them together: Attending Camp and Alumni Status
ivregress 2sls incstatus (AttendeeAngelTree AlumniStatus = Age_9 Age_10 Age_11 Age_10_x_CampHopeZip) black hispanic CurrentAge male i.ZipNum, first
estat endogenous
estat firststage
estat overid
* Note: I think you can't do them together because the instruments don't satisfy rank condition, do all heavy lifting on attending camp hope.



// Generating race database for Bruce
gen AfricanAmerican = 0
replace AfricanAmerican = 1 if firstname == "D'Anne"| firstname ==" Deiondre"| firstname ==" Dele"| firstname ==" Denzel"| firstname ==" Dewayne"| firstname ==" Dikembe"| firstname ==" Duante"| firstname ==" Jamar"| firstname ==" Jevonte"| firstname ==" Kadeem"| firstname ==" Kendis"| firstname ==" Kentay"| firstname ==" Keshawn"| firstname ==" Khalon"| firstname ==" Kofi"| firstname ==" Kwamin"| firstname ==" Kyan"| firstname ==" Kyrone"| firstname ==" La Vonn"| firstname ==" Lado"| firstname ==" Laken"| firstname ==" Lakista"| firstname ==" Lamech"| firstname ==" Lavaughn"| firstname ==" LeBron"| firstname ==" Lisimba"| firstname ==" Ludacris"| firstname ==" Mablevi"| firstname ==" Marques"| firstname ==" Mashawn"| firstname ==" Montraie"| firstname ==" Mykelti"| firstname ==" Nabulung"| firstname ==" Naeem"| firstname ==" Napoleon"| firstname ==" Obiajulu"| firstname ==" Quaashie"| firstname ==" Quaddus"| firstname ==" Quadrees"| firstname ==" Quannell"| firstname ==" Quarren"| firstname ==" Quashawn"| firstname ==" Quintavius"| firstname ==" Quoitrel"| firstname ==" Raimy"| firstname ==" Rashon"| firstname ==" Razi"| firstname ==" Roshaun"| firstname ==" Runako"| firstname ==" Salim"| firstname ==" Beyonce"| firstname ==" Cassietta"| firstname ==" Cleotha"| firstname ==" Dericia"| firstname ==" Kacondra"| firstname ==" Kanesha"| firstname ==" Keilantra"| firstname ==" Kendis"| firstname ==" Keshon"| firstname ==" Lachelle"| firstname ==" Lakin"| firstname ==" Lanelle"| firstname ==" Laquanna"| firstname ==" Laqueta"| firstname ==" Laquinta"| firstname ==" Lashawn"| firstname ==" Latanya"| firstname ==" Moesha"| firstname ==" Muncel"| firstname ==" Najwa"| firstname ==" Nakeisha"| firstname ==" Nichelle"| firstname ==" Niesha"| firstname ==" Quanella"| firstname ==" Latonya"| firstname ==" Latoya"| firstname ==" Mekell"| firstname ==" Quanesha"| firstname ==" Quisha"| firstname ==" Ranielle"| firstname ==" Ronnell"| firstname ==" Shandra"| firstname ==" Shaquana"| firstname ==" Shateque"| firstname ==" Sidone"| firstname ==" Talaitha"| firstname ==" Talisa"| firstname ==" Talisha"| firstname ==" Tamika"| firstname ==" Tamira"| firstname ==" Tamyra"| firstname ==" Tanasha"| firstname ==" Tandice"| firstname ==" Tanginika"| firstname ==" Taniel"| firstname ==" Tanisha"| firstname ==" Tariana"| firstname ==" Temma"| firstname ==" Shaquille"| firstname ==" Shevon"| firstname ==" Shontae"| firstname ==" Sulaiman"| firstname ==" Tabansi"| firstname ==" Tabari"| firstname ==" Tamarius"| firstname ==" Tavarius"| firstname ==" Tavon"| firstname ==" Tevaughn"| firstname ==" Tevin"| firstname ==" Trory"| firstname ==" Tyrell"| firstname ==" Uba"| firstname ==" Ulan"| firstname ==" Uzoma"| firstname ==" Vandwon"| firstname ==" Vashon"| firstname ==" Veltry"| firstname ==" Verlyn"| firstname ==" Voshon"| firstname ==" Xayvion"| firstname ==" Xyshaun"| firstname ==" Yobachi"| firstname ==" Zaid"| firstname ==" Zareb"| firstname ==" Zashawn"| firstname ==" Timberly"| firstname ==" Tyesha"| firstname ==" Tyrell"| firstname ==" Tyrina"| firstname ==" Tyronica"| firstname ==" Velinda"| firstname ==" Wyetta"| firstname ==" Yetty"| firstname ==" Aaliyah"| firstname ==" Africa"| firstname ==" Aisha"| firstname ==" Akeem"| firstname ==" Amare"| firstname ==" Amari"| firstname ==" Andre"| firstname ==" Aniya"| firstname ==" Aniyah"| firstname ==" Antoine"| firstname ==" Antwan"| firstname ==" Damarion"| firstname ==" D'Andre"| firstname ==" D'Angelo"| firstname ==" Daquan"| firstname ==" Darnell"| firstname ==" Darryl"| firstname ==" Dashawn"| firstname ==" Davion"| firstname ==" Davon"| firstname ==" Davonte"| firstname ==" DeAndre"| firstname ==" DeAngelo"| firstname ==" Dedrick"| firstname ==" Deion"| firstname ==" Deja"| firstname ==" DeMarcus"| firstname ==" DeMario"| firstname ==" Deniece"| firstname ==" Deon"| firstname ==" Deonte"| firstname ==" Deshaun"| firstname ==" Deshawn"| firstname ==" Devante"| firstname ==" Devontae"| firstname ==" Devonte"| firstname ==" Diamond"| firstname ==" Eboni"| firstname ==" Ebony"| firstname ==" Felecia"| firstname ==" Felisha"| firstname ==" Iesha"| firstname ==" Imani"| firstname ==" Ivory"| firstname ==" Jabari"| firstname ==" Jalen"| firstname ==" Jaliyah"| firstname ==" Jamaal"| firstname ==" Jamaal"| firstname ==" Jamal"| firstname ==" Jamar"| firstname ==" JaMarcus"| firstname ==" Jamari"| firstname ==" Jamarion"| firstname ==" Jamir"| firstname ==" Janiya"| firstname ==" Janiyah"| firstname ==" Jaquan"| firstname ==" Jaren"| firstname ==" Jaron"| firstname ==" Javion"| firstname ==" Javon"| firstname ==" Javonte"| firstname ==" Jaylen"| firstname ==" Jaylin"| firstname ==" Jaylon"| firstname ==" Jelani"| firstname ==" Jermaine"| firstname ==" Kalisha"| firstname ==" Kaliyah"| firstname ==" Kamari"| firstname ==" Kamiyah"| firstname ==" Kanye"| firstname ==" Keisha"| firstname ==" Kenya"| firstname ==" Keshaun"| firstname ==" Keshawn"| firstname ==" Keshia"| firstname ==" Keysha"| firstname ==" Kiana"| firstname ==" Kisha"| firstname ==" Kyree"| firstname ==" Kyrie"| firstname ==" LaChina"| firstname ==" LaDonna"| firstname ==" Lagina"| firstname ==" Lakeisha"| firstname ==" Lakendra"| firstname ==" Lakeshia"| firstname ==" Lakisha"| firstname ==" Lamar"| firstname ==" Lamont"| firstname ==" Laquanna"| firstname ==" Laquisha"| firstname ==" LaShawn"| firstname ==" Lashay"| firstname ==" Lashonda"| firstname ==" Latanya"| firstname ==" Latasha"| firstname ==" Latisha"| firstname ==" LaTonya"| firstname ==" LaToya"| firstname ==" LaWanda"| firstname ==" Levar"| firstname ==" Marques"| firstname ==" Marquis"| firstname ==" Marquise"| firstname ==" Marquita"| firstname ==" Nakeisha"| firstname ==" Nakisha"| firstname ==" Natisha"| firstname ==" Naya"| firstname ==" Nia"| firstname ==" Nikeisha"| firstname ==" Nikisha"| firstname ==" Precious"| firstname ==" Qiana"| firstname ==" Quanna"| firstname ==" Quiana"| firstname ==" Quianna"| firstname ==" Rashaun"| firstname ==" Rashawn"| firstname ==" Shameka"| firstname ==" Shamika"| firstname ==" Shanae"| firstname ==" Shaneka"| firstname ==" Shanequa"| firstname ==" Shanice"| firstname ==" Shanika"| firstname ==" Shaniqua"| firstname ==" Shaniya"| firstname ==" Shaquila"| firstname ==" Shaquille"| firstname ==" Sharonda"| firstname ==" Shavon"| firstname ==" Shavonne"| firstname ==" Shelena"| firstname ==" Tajuana"| firstname ==" Talisha"| firstname ==" Tamia"| firstname ==" Taneka"| firstname ==" Tanesha"| firstname ==" Tanika"| firstname ==" Taniqua"| firstname ==" Tanisha"| firstname ==" Taniya"| firstname ==" Tavon"| firstname ==" Terell"| firstname ==" Terrell"| firstname ==" Tisha"| firstname ==" Toccara"| firstname ==" Trevon"| firstname ==" Treyvon"| firstname ==" Tyquan"| firstname ==" Tyra"| firstname ==" Tyree"| firstname ==" Tyreek"| firstname ==" Tyrell"| firstname ==" Tyrese"| firstname ==" Tyrik"| firstname ==" Tyriq"| firstname ==" Tyrique"| firstname ==" Tyrone"| firstname ==" Tyshawn"| firstname ==" Zaire"| firstname ==" Zendaya"

//Summary Statistics
tabstat CurrentAge incstatus YearsAttended white black asian hispanic male female, by(AttendeeAngelTree) stat(count mean sd min max sum) col(stat) long






///Graphs
hist Age_Start_Program if AttendeeAngelTree==1, bin(20)

///IV Regression
sort ZipNum
capture drop CampHopeZip
egen CampHopeZip = count(AttendeeAngelTree), by (ZipNum)

//gen CampHopeZip = (CampHopeZip > 1)

**Basic IV**
gen AgeList = 0
replace AgeList = 1 if Age_Start_Program >= 8 & Age_Start_Program <=12

gen AgeList_x_CampHopeZip = AgeList*CampHopeZip

**First IV Break Down**

**Alexa & Bruce 4/19/2023
xtset ZipNum
xi: ivreg incstatus (AttendeeAngelTree = Age_9 Age_10 Age_11) black hispanic CurrentAge male i.ZipNum, cluster(ZipNum) first
xi: ivreg incstatus (AlumniStatus = Age_9 Age_10 Age_11) black hispanic CurrentAge male i.ZipNum, cluster(ZipNum) first
estat overid

ivregress 2sls incstatus (AttendeeAngelTree = Age_9 Age_10 Age_11) black hispanic CurrentAge male i.ZipNum, cluster(ZipNum) first



xtset ZipNum
xtivreg incstatus (AttendeeAngelTree = AgeList_x_CampHopeZip) black hispanic AgeList CurrentAge male, fe i(ZipNum) vce(cluster ZipNum) first
esttab using results.doc,replace label

xtset ZipNum
xtivreg Jail (AttendeeAngelTree = AgeList_x_CampHopeZip) black hispanic AgeList CurrentAge male, fe i(ZipNum) vce(cluster ZipNum) first
esttab using results.doc,replace label

xtset ZipNum
xtivreg Prison (AttendeeAngelTree = AgeList_x_CampHopeZip) black hispanic AgeList CurrentAge male, fe i(ZipNum) vce(cluster ZipNum) first
esttab using results.doc,replace label



**IV Dummy Age Broken Up Individually**
xtset ZipNum
xtivreg incstatus (AttendeeAngelTree = Age_8_x_CampHopeZip) Age_8 CurrentAge FemMale, fe i(ZipNum) vce(cluster ZipNum) first

xtset ZipNum
xtivreg incstatus (AttendeeAngelTree = Age_9_x_CampHopeZip) Age_9 CurrentAge FemMale, fe i(ZipNum) vce(cluster ZipNum) first

xtset ZipNum
xtivreg incstatus (AttendeeAngelTree = Age_10_x_CampHopeZip) Age_10 CurrentAge FemMale, fe i(ZipNum) vce(cluster ZipNum) first

xtset ZipNum
xtivreg incstatus (AttendeeAngelTree = Age_11_x_CampHopeZip) Age_11 CurrentAge FemMale, fe i(ZipNum) vce(cluster ZipNum) first

xtset ZipNum
xtivreg incstatus (AttendeeAngelTree = Age_12_x_CampHopeZip) Age_12 CurrentAge FemMale, fe i(ZipNum) vce(cluster ZipNum) first

**Bruce Age IV**

xtivreg incstatus (AttendeeAngelTree AlumniStatus = Age_8_x_CampHopeZip Age_9_x_CampHopeZip Age_10_x_CampHopeZip Age_11_x_CampHopeZip Age_12_x_CampHopeZip) Age_8 Age_9 Age_10 Age_11 Age_12 Combined_Race CurrentAge FemMale, fe i(ZipNum) vce(cluster ZipNum) first

xtivreg incstatus (AttendeeAngelTree AlumniStatus = Age_8 Age_9 Age_10 Age_11  Age_8_x_CampHopeZip) black hispanic CurrentAge FemMale, fe i(ZipNum) vce(cluster ZipNum) first

////Jail IV///
xtivreg Jail (AttendeeAngelTree AlumniStatus = Age_8 Age_9 Age_10 Age_11  Age_8_x_CampHopeZip) black hispanic CurrentAge FemMale, fe i(ZipNum) vce(cluster ZipNum) first

///Prison IV///
xtivreg Prison (AttendeeAngelTree AlumniStatus = Age_8 Age_9 Age_10 Age_11  Age_8_x_CampHopeZip) black hispanic CurrentAge FemMale, fe i(ZipNum) vce(cluster ZipNum) first

///Felony IV//
xtivreg Felony (AttendeeAngelTree AlumniStatus = Age_8 Age_9 Age_10 Age_11  Age_8_x_CampHopeZip) black hispanic CurrentAge FemMale, fe i(ZipNum) vce(cluster ZipNum) first

//Misdemeanor//
xtivreg Misdemeanor (AttendeeAngelTree AlumniStatus = Age_8 Age_9 Age_10 Age_11  Age_8_x_CampHopeZip) black hispanic CurrentAge FemMale, fe i(ZipNum) vce(cluster ZipNum) first

//Misdemeanor_Felony//
xtivreg Misdemeanor_Felony (AttendeeAngelTree AlumniStatus = Age_8 Age_9 Age_10 Age_11  Age_8_x_CampHopeZip) black hispanic CurrentAge FemMale, fe i(ZipNum) vce(cluster ZipNum) first


**IV Alumni Stats**
xtset ZipNum
xtivreg incstatus (AlumniStatus = AgeList_x_CampHopeZip) CurrentAge FemMale, fe i(ZipNum) vce(cluster ZipNum) first
esttab using results.doc,replace label

**Age Bucket IV**
gen AgeList_8_9 = 0 
replace AgeList_8_9 = 1 if Age_Start_Program ==8 | Age_Start_Program ==9

gen AgeList_10_12 = 0 
replace AgeList_10_12 = 1 if Age_Start_Program ==10 | Age_Start_Program ==11 | Age_Start_Program ==12

gen AgeList_8_9_x_CampHopeZip = AgeList_8_9*CampHopeZip

gen AgeList_10_12_x_CampHopeZip = AgeList_10_12*CampHopeZip

xtset ZipNum
xtivreg incstatus (AttendeeAngelTree AlumniStatus = AgeList_8_9_x_CampHopeZip AgeList_10_12*CampHopeZip)  AgeList CurrentAge FemMale, fe i(ZipNum) vce(cluster ZipNum)
esttab using results.doc,replace label


gen iv1 = AttendeeAngelTree * ZipNum 
gen iv2 = iv1 * AgeEligible



