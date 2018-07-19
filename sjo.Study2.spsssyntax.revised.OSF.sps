***Demos

COMPUTE age = 2015 - birthyear.
   EXECUTE.

FILTER OFF.
USE ALL.
SELECT IF (age>17).
EXECUTE.

RECODE @_3 ('highses'=1) ('lowses'=0) INTO criminal_ses.
EXECUTE.


***Reliability 

RELIABILITY
  /VARIABLES= retribjorient1 retribjorient2 retribjorient3 retribjorient4 retribjorient5 retribjorient6 
retribjorient7 retribjorient8 retribjorient9 retribjorient10 retribjorient11 retribjorient12 
retribjorient13 retribjorient14 retribjorient15
  /SCALE('ALL VARIABLES') ALL
  /MODEL=ALPHA.

RELIABILITY
  /VARIABLES= crimethreat1 crimethreat2 crimethreat3 crimethreat4 crimethreat5 crimethreat6 crimethreat7
  /SCALE('ALL VARIABLES') ALL
  /MODEL=ALPHA.

RELIABILITY
  /VARIABLES= statusresmot1 statusresmot2 statusresmot3 statusresmot4 statusresmot5 statusresmot6
  /SCALE('ALL VARIABLES') ALL
  /MODEL=ALPHA.

RECODE socialdom5 (1=7) (2=6) (3=5) (4=4) (7=1) (6=2) (5=3) INTO socialdom5R.
VARIABLE LABELS socialdom5R 'socialdom5R'.
EXECUTE.

RECODE socialdom6 (1=7) (2=6) (3=5) (4=4) (7=1) (6=2) (5=3) INTO socialdom6R.
VARIABLE LABELS socialdom6R 'socialdom6R'.
EXECUTE.

RELIABILITY
  /VARIABLES= socialdom1 socialdom2 socialdom3 socialdom4 socialdom5R socialdom6R
  /SCALE('ALL VARIABLES') ALL
  /MODEL=ALPHA.

.68

RELIABILITY
  /VARIABLES= deterrence1 deterrence2 deterrence3
  /SCALE('ALL VARIABLES') ALL
  /MODEL=ALPHA.



**Compute vars

COMPUTE retribjorient=MEAN(retribjorient1,retribjorient2,retribjorient3,
retribjorient4,retribjorient5,retribjorient6,retribjorient7,retribjorient8,retribjorient9,retribjorient10,retribjorient11,retribjorient12,
retribjorient13,retribjorient14,retribjorient15).
COMPUTE crimethreat=MEAN(crimethreat1,crimethreat2,crimethreat3,crimethreat4,crimethreat5,crimethreat6,crimethreat7).
COMPUTE statusresmot=MEAN(statusresmot1,statusresmot2,statusresmot3,statusresmot4,statusresmot5,statusresmot6).
COMPUTE sdo=MEAN(socialdom1, socialdom2, socialdom3, socialdom4, socialdom5R, socialdom6R).
COMPUTE deterrence=MEAN(deterrence1, deterrence2, deterrence3).
EXECUTE.


***Create interaction

DESCRIPTIVES VARIABLES=sdo politicalid 
  /STATISTICS=MEAN STDDEV MIN MAX.

COMPUTE sdo_ctr=sdo-2.09.
EXECUTE.

SD = 1.01



COMPUTE sdobycriminalses=sdo_ctr*criminal_ses.
RECODE criminal_ses (1=1)(0=-1) INTO criminal_ses_ones.
COMPUTE sdobycriminalsesones=sdo_ctr*criminal_ses_ones.
EXECUTE.



**Simple slopes
**Standardize vars.

      DESCRIPTIVES  VARIABLES = sdo politicalid
       /SAVE.


## Recode CRIMSES so that the intercept (outcome) reflects the difference between the two CRIMSES conditions. ##

RECODE
  criminal_ses_ones (-1=-.5)  (1=.5)  INTO crimses.
EXECUTE .

## Recode CRIMSES to test simple effects at low and high levels. ##

COMPUTE crim_lo = crimses + .5 .
COMPUTE crim_hi = crimses - .5 .
EXECUTE .

## Mean-center SDO. ##

COMPUTE sdo_c = sdo - 2.09 .
EXECUTE .

## Re-center SDO at 1 SD below and above its mean. ##

COMPUTE sdom1sd = sdo_c + 1.01 .
COMPUTE sdop1sd = sdo_c - 1.01 .
EXECUTE .

## Create all five interaction terms for simple effects. ##

COMPUTE sdoxcrim = crimses * sdo_c .
COMPUTE sdolcrim = crimses * sdom1sd .
COMPUTE sdohcrim = crimses * sdop1sd .
COMPUTE sdocriml = crim_lo * sdo_c .
COMPUTE sdocrimh = crim_hi * sdo_c .
EXECUTE .

## Main Model. Basis for predicted score and graph. ##

REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP CI (95)
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT retribjorient
  /METHOD=ENTER crimses sdo_c sdoxcrim
  /RESIDUALS HIST(ZRESID) NORM(ZRESID)
  /CASEWISE PLOT(ZRESID) OUTLIERS(3) .

## Simple effect of CRIMSES at 1 SD below the SDO mean. ##

REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP CI (95)
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT retribjorient
  /METHOD=ENTER crimses sdom1sd sdolcrim
  /RESIDUALS HIST(ZRESID) NORM(ZRESID)
  /CASEWISE PLOT(ZRESID) OUTLIERS(3) .

## Simple effect of CRIMSES at 1 SD above the SDO mean. ##

REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP CI (95)
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT retribjorient
  /METHOD=ENTER crimses sdop1sd sdohcrim
  /RESIDUALS HIST(ZRESID) NORM(ZRESID)
  /CASEWISE PLOT(ZRESID) OUTLIERS(3) .

## Simple effect of SDO at low CRIMSES. ##

REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP CI (95)
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT retribjorient
  /METHOD=ENTER crim_lo sdo_c sdocriml
  /RESIDUALS HIST(ZRESID) NORM(ZRESID)
  /CASEWISE PLOT(ZRESID) OUTLIERS(3) .

## Simple effect of SDO at high CRIMSES. ##

REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP CI (95)
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT retribjorient
  /METHOD=ENTER crim_hi sdo_c sdocrimh
  /RESIDUALS HIST(ZRESID) NORM(ZRESID)
  /CASEWISE PLOT(ZRESID) OUTLIERS(3) .

## Alternate simple effects tests to address skewness of SDO. ##
## This approach examine simple effects of SDO at 1, 4, and 7 on 7-point scale. ##

COMPUTE sdo@1 = sdo - 1.
COMPUTE sdo@4 = sdo - 4.
COMPUTE sdo@7 = sdo - 7.
EXECUTE .

## Make interaction terms. ##

COMPUTE sdo1crim = crimses * sdo@1 .
COMPUTE sdo4crim = crimses * sdo@4 .
COMPUTE sdo7crim = crimses * sdo@7 .
EXECUTE .

## Test simple effects of CRIMSES at 1, 4, and 7 on SDO. ##

REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP CI (95)
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT retribjorient
  /METHOD=ENTER crimses sdo@1 sdo1crim
  /RESIDUALS HIST(ZRESID) NORM(ZRESID)
  /CASEWISE PLOT(ZRESID) OUTLIERS(3) .

REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP CI (95)
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT retribjorient
  /METHOD=ENTER crimses sdo@4 sdo4crim
  /RESIDUALS HIST(ZRESID) NORM(ZRESID)
  /CASEWISE PLOT(ZRESID) OUTLIERS(3) .


REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP CI (95)
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT retribjorient
  /METHOD=ENTER crimses sdo@7 sdo7crim
  /RESIDUALS HIST(ZRESID) NORM(ZRESID)
  /CASEWISE PLOT(ZRESID) OUTLIERS(3) .





## Main Model controlling for deterrence

REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP CI (95)
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT retribjorient
  /METHOD=ENTER crimses sdo_c sdoxcrim deterrence
  /RESIDUALS HIST(ZRESID) NORM(ZRESID)
  /CASEWISE PLOT(ZRESID) OUTLIERS(3) .




## Main Model predicting deterrence

REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP CI (95)
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT deterrence
  /METHOD=ENTER crimses sdo_c sdoxcrim retribjorient
  /RESIDUALS HIST(ZRESID) NORM(ZRESID)
  /CASEWISE PLOT(ZRESID) OUTLIERS(3) .



*** get studentized residuals

DATASET ACTIVATE DataSet2.
REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT retribjorient
  /METHOD=ENTER sdo_c crimses sdoxcrim
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID)
  /CASEWISE PLOT(ZRESID) OUTLIERS(3)
  /SAVE SDRESID.



**set up for mplus
DATASET ACTIVATE DataSet1.
RECODE retrib resmot cthreat sdo crimses sdostat (SYSMIS=-9).
EXECUTE.





