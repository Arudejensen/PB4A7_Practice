clear
set more off 
cd "/Users/annajensen/Documents/GitHub/PB4A7_Practice/Seminar_8"
log using Seminar_8.log, replace
use Seminar_8.dta

* Question 1 *
gen lvio = ln(vio)
gen lrob = ln(rob)
gen lmur = ln(mur)

xtset stateid year

* Question 2 *
xtreg lvio shall, vce(cluster stateid)

global basevars incarc_rate density avginc pop pb1064 pw1064 pm1029
xtreg lvio shall $basevars, vce(cluster stateid)

log close 
