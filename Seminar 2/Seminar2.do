capture log close 
set more off 
set mem 700m 
cd "/Users/annajensen/Documents/LSE/Quantitative Applications for Behavioural Science/Seminars/Seminar 2"
log using Seminar2.log, replace
use Seminar2, clear

*Question 1*
histogram yearsexp, percent

*Question 2*
summarize yearsexp, detail

*Question 3*
tabulate yearsexp
table yearsexp

/*Tabulate returns frequence, percent, and cummulative percent. 
Table returns only frequence*/

*Question 4*
tab female

*76.92% are female, and 23.08 are male*

*Question 5*
tab female, sum(yearsexp)

*Women have more experience on average. The standard deviations are similar*

*Question 6*
summarize education female yearsexp black, detail

/*The mean describes central tendence, and the variance and standard variance
describe the spread of the data*/

*Question 7*
sort female
by female: summarize (yearsexp)

sort black
by black: summarize (yearsexp)

*Years of experience only vary very slightly by race*

*Question 8*
hist yearsexp, normal

*No the distribution does not look normal, it is skewed right*

*Question 9*
hist female
hist female, discrete

*Yes, the graph changes when you add discrete. They are equally accurate*

*Question 10*
hist black, percent discrete

/*The dsitribution tells us that there are equally many black and white people 
in the sample*/

log close


