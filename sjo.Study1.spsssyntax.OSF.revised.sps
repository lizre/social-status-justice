***Demos

COMPUTE age = 2015 - birthyear.
   EXECUTE.

FILTER OFF.
USE ALL.
SELECT IF (age>17).
EXECUTE.

N = 476



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


**Compute variables

COMPUTE retribjorient=MEAN(retribjorient1,retribjorient2,retribjorient3,
retribjorient4,retribjorient5,retribjorient6,retribjorient7,retribjorient8,retribjorient9,retribjorient10,retribjorient11,retribjorient12,
retribjorient13,retribjorient14,retribjorient15).
EXECUTE.

COMPUTE crimethreat=MEAN(crimethreat1,crimethreat2,crimethreat3,crimethreat4,crimethreat5,crimethreat6,crimethreat7).
EXECUTE.

COMPUTE statusresmot=MEAN(statusresmot1,statusresmot2,statusresmot3,statusresmot4,statusresmot5,statusresmot6).
EXECUTE.

COMPUTE sdo=MEAN(socialdom1, socialdom2, socialdom3, socialdom4, socialdom5R, socialdom6R).
EXECUTE.




**Recode so that 10 = highest status and 1 = lowest status.

RECODE criminalmcheck1 (1=10) (2=9) (3=8) (4=7) (5=6) (6=5) (7=4) (8=3) (9=2) (10=1) INTO crimstatus_hilo.
EXECUTE.

**Compute interaction terms.

DATASET ACTIVATE DataSet15.
DESCRIPTIVES VARIABLES=crimstatus_hilo criminalmcheck1 sdo
  /STATISTICS=MEAN STDDEV MIN MAX.


COMPUTE sdo_ctr=sdo-2.01.
EXECUTE.

COMPUTE crimses_ctr=crimstatus_hilo-3.45.
COMPUTE sdoxcrim=sdo_ctr*crimses_ctr.
EXECUTE.


** get coeffs for graphing

DATASET ACTIVATE Dataset1.
REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP CI (95)
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT retribjorient
  /METHOD=ENTER crimses_ctr sdo_ctr sdoxcrim
  /RESIDUALS HIST(ZRESID) NORM(ZRESID)
  /CASEWISE PLOT(ZRESID) OUTLIERS(3) .

## Recode CRIMSES to test simple effects at low and high levels. ##

COMPUTE crim_lo = crimses_ctr + 2.01.
COMPUTE crim_hi = crimses_ctr - 2.01.
EXECUTE .

## Re-center SDO at 1 SD below and above its mean. ##

COMPUTE sdom1sd = sdo_ctr + .96.
COMPUTE sdop1sd = sdo_ctr - .96 .
EXECUTE .

## Create all five interaction terms for simple effects. ##

COMPUTE sdoxcrim = crimses_ctr * sdo_ctr .
COMPUTE sdolcrim = crimses_ctr * sdom1sd .
COMPUTE sdohcrim = crimses_ctr * sdop1sd .
COMPUTE sdocriml = crim_lo * sdo_ctr .
COMPUTE sdocrimh = crim_hi * sdo_ctr .
EXECUTE .

## Simple effect of CRIMSES at 1 SD below the SDO mean. ##

REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP CI (95)
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT retribjorient
  /METHOD=ENTER crimses_ctr sdom1sd sdolcrim
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
  /METHOD=ENTER crimses_ctr sdop1sd sdohcrim
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
  /METHOD=ENTER crim_lo sdo_ctr sdocriml
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
  /METHOD=ENTER crim_hi sdo_ctr sdocrimh
  /RESIDUALS HIST(ZRESID) NORM(ZRESID)
  /CASEWISE PLOT(ZRESID) OUTLIERS(3) .




## Alternate simple effects tests to address skewness of SDO. ##
## This approach examine simple effects of SDO at 1, 4, and 7 on 7-point scale. ##

COMPUTE sdo@1 = sdo - 1.
COMPUTE sdo@4 = sdo - 4.
COMPUTE sdo@7 = sdo - 7.
EXECUTE .

## Make interaction terms. ##

COMPUTE sdo1crim = crimses_ctr * sdo@1 .
COMPUTE sdo4crim = crimses_ctr * sdo@4 .
COMPUTE sdo7crim = crimses_ctr * sdo@7 .
EXECUTE .

## Test simple effects of CRIMSES at 1, 4, and 7 on SDO. ##

REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP CI (95)
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT retribjorient
  /METHOD=ENTER crimses_ctr sdo@1 sdo1crim
  /RESIDUALS HIST(ZRESID) NORM(ZRESID)
  /CASEWISE PLOT(ZRESID) OUTLIERS(3) .

REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP CI (95)
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT retribjorient
  /METHOD=ENTER crimses_ctr sdo@7 sdo7crim
  /RESIDUALS HIST(ZRESID) NORM(ZRESID)
  /CASEWISE PLOT(ZRESID) OUTLIERS(3) .




*** get studentized residuals

REGRESSION
  /DESCRIPTIVES MEAN STDDEV CORR SIG N
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL CHANGE ZPP CI (95)
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT retribjorient
  /METHOD=ENTER crimses_ctr sdo_ctr sdoxcrim
  /RESIDUALS HIST(ZRESID) NORM(ZRESID)
  /CASEWISE PLOT(ZRESID) OUTLIERS(3) 
  /SAVE SDRESID.




**set up for mplus

DATASET ACTIVATE DataSet8.
RECODE retrib resmot cthreat sdoctr sesctr sdostat (SYSMIS=-9).
EXECUTE.

