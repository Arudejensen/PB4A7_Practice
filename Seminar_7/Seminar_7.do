clear
set more off 
cd "/Users/annajensen/Documents/GitHub/PB4A7_Practice/Seminar_7"
log using Seminar_7.log, replace
use Seminar_7.dta

*Question 1*
logit frame donate
margins

log close
