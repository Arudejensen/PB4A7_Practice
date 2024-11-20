clear
set more off 
cd "/Users/annajensen/Documents/GitHub/PB4A7_Practice/Seminar_5"
log using Seminar_5.log, replace
use "/Users/annajensen/Documents/GitHub/PB4A7_Practice/Seminar_4/Seminar_4.dta"

*Question 1*
reg birthweight smoker

/*The likely sign is negative, since it is resonable to assume that smking will 
be negatively related to birthweight*/

*Question 2*
/*The estimated effect of smoking on birthweight is -253.2284 meaning that
smoking will decrease birthweight by ~-250 grams on average*/

*Question 3*
/*Other potential factors that might influence birthweight is the age of the
mother with older mother with older mothers giving birth to lighter children, 
and alcohol with mothers drinking during pregnancy giving birth to lighter
children. This puts into question the causal interpretation of the above model,
as age and alcohol might both be related to smoking and to birthweight,
for example, older women might be more likely to smoke, as the health
consequences were less understood in their youth.*/

*Question 4*
reg birthweight smoker alcohol nprevist

/*The estimated effect of smoking on birthweight is somewhat smaller when 
controlling for alcohol consumption and prenatal visits*/

*Question 5*
*The R-squared is larger by approximately 0.05 points*

*Question 6*
/* I would interpret the nprevist coeffecient as a correlational and not causal
effect, because most likely, prenatal visits does not affect birthweight
directly but is correlated to birthweight through a confounding factor capturing
the overall effort the mother puts into the pregnancy.*/

*Question 7*
reg birthweight smoker alcohol nprevist tripre0 tripre1 tripre2 tripre3

log close
