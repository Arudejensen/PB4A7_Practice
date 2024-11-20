clear
set more off 
cd "/Users/annajensen/Documents/GitHub/PB4A7_Practice/Seminar_4"
log using Seminar_4.log, replace

use Seminar_4, clear

*Question 1*
reg birthweight smoker

*Question 2*
reg birthweight i.smoker##c.birthweight

/*Children of smoking mothers weight on average ~253 grams less than children of
non smokers.*/

*Question 3*
reg birthweight smoker age educ

/*Yes, the smoking coeffecient becomes smaller. Age and education both increase
birthweight slightly.*/

*Question 4*
logit unmarried birthweight smoker

*Question 5*
gen birthweight_sq = birthweight^2
reg birthweight birthweight_sq smoker

log close

