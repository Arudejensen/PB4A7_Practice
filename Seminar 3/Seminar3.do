capture log close
clear
set more off 
set mem 700m 
cd "/Users/annajensen/Documents/LSE/Quantitative Applications for Behavioural Science/Seminars/Seminar 3"
log using Seminar3.log, replace

use Seminar2, clear

*Question 1*
regress yearsexp education 

/*The results show us, that we can not reject the null hypothesis that there
 is no relationship between education and years of experience*/
 
*Question 2*
tabulate education, generate(e)
regress yearsexp e1 e2 e3 e4 e5

*Question 3*
/*The alternative hypothesis is that there is an effect of having a college 
degree on years of experience*/

regress yearsexp e5

/*a: there is a negative relationship between years of experience
and having a college degree, however, the relationship is not significant. 
b: we do not reject the null hypothesis, as the t-statistic is not statistically
significant, which is indicated by the p-value. Additionally, 0 lies within 
the bounds of the confidence interval, and we can therefore, not be sure that 
the true value is not 0. 
c: 8.032943
d: 7.7688357 */

*Bonus question*

*Question 4*
regress yearsexp e5, vce(robust)

*No, the coefficient values do not change*

*Question 5*
anova yearsexp e5

log close
