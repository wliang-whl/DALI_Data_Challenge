set more off
capture log close
cap clear matrix
clear

import delimited using "/Users/wliang/Desktop/data_challenge/Superstore.csv"
log using "SupStoredataAnalysis.log", replace


/* 1) Multivariable Regression of sales on shipping mode */
/* Interpretations: what's the sale gap between different shipping method
shipdum1 - FirstClass
shipdum2 - SameDay
shipdum3 - SecondClass
omitted - Standard Class

*/

// create dummies for each ship mode
tab shipmode, gen(shipdum) 
rename shipdum1 FirstClass
rename shipdum2 SameDay
rename shipdum3 SecondClass

// regress sales on three of the four ship mode dummies
reg sales FirstClass SameDay SecondClass



/* 2) ANOVA for testing difference in efficiency between different shipping modes */

//generate variables for start and end dates
generate startdate = date(orderdate, "MDY")
generate enddate = date(shipdate, "MDY")

//generate variable to store how many days it took for a shipment to arrive
generate daystaken = enddate - startdate

//do oneway anova 
oneway daystaken shipmode, tabulate



/* 3) t-test if each shipping mode has shipping that are generally faster than its mean */
// ttest for each shipmode to check if actual days taken are less than estimated days taken

ttest daystaken == 2.1827048 if shipmode == "First Class" 
ttest daystaken == 0.0441989 if shipmode == "Same Day"  
ttest daystaken == 3.2380463 if shipmode == "Second Class"
ttest daystaken == 5.0065349 if shipmode == "Standard Class"
/* Conclusion: we cannot conclude that average of actual days to ships is less than
average of estimate days to ship for any ship mode*/



/* 4) Multivariable Regression with interaction variables (days taken to ship * region)*/
/*
regiondum1 Central
regiondum2 East
regiondum3 South
omitted (_cons)- West 
interpretations of above coefficients (uninteracted): 
In West at days taken to ship = 0, sales is 249.4152
at days taken to ship = 0, the sales of South > West > East> Central

regi1days CentralDaysTaken
regi2days EastDaysTaken
regi3days SouthDaysTaken
omitted (daystaken)- WestDaysTaken
interpretations of the above coefficients (interacted):
In West, each additional day taken for shipping decreases sale by 5.832936
*/

//create dummies uninteracted for each region
tab region, gen(regiondum)
//create dummies interacted for each region interacting with daystaken (days taken for shipping)
forvalues i = 1/3{
	gen regi`i'days = regiondum`i' * daystaken
}

//rename all dummies
rename regiondum1 Central
rename regiondum2 East
rename regiondum3 South
rename regi1days CentralDaysTaken
rename regi2days EastDaysTaken
rename regi3days SouthDaysTaken

//regress sales on the uninteracted dummies (region) and the interacted dummies (region*daystaken)
regress sales Central East South daystaken CentralDaysTaken EastDaysTaken SouthDaysTaken, robust

capture log close /* last command in any program */
