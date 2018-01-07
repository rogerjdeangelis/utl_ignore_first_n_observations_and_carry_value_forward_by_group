Ignore first n observations and carry value forward  by group

github
https://goo.gl/byt4ta
https://github.com/rogerjdeangelis/utl_ignore_first_n_observations_and_carry_value_forward_by_group

WPS/SAS Solution

Another SAS/WPS  differentiator - DOW loop.

Made one small change to input.
Used informat $6, for quarter instaed of yyq6.


INPUT
=====

  WORK.HAVE total obs=16          |     RULES
                                  |
     QUARTER    GVKEY    MEANCOST |
                                  |
     2001Q1      1001       11    |   2001Q1      1001       .     1st group of 4 quarters
     2001Q2      1001       11    |   2001Q2      1001       .     Set group to 1
     2001Q3      1001       11    |   2001Q3      1001       .     Since 1 is odd save meancost
     2001Q4      1001       11    |   2001Q4      1001       .     and apply to next group
     2002Q1      1001       12    |   2002Q1      1001       11
     2002Q2      1001       12    |   2002Q2      1001       11    group=2 which is even
     2002Q3      1001       12    |   2002Q3      1001       11    so apply previous 'odd' group
     2002Q4      1001       12    |   2002Q4      1001       11    meancost
     2006Q1      1002       65    |   2006Q1      1002       .
     2006Q2      1002       65    |   2006Q2      1002       .
     2006Q3      1002       65    |   2006Q3      1002       .
     2006Q4      1002       65    |   2006Q4      1002       .
     2007Q1      1002       70    |   2007Q1      1002       65
     2007Q2      1002       70    |   2007Q2      1002       65
     2007Q3      1002       70    |   2007Q3      1002       65
     2007Q4      1002       70    |   2007Q4      1002       65

WORKING CODE
============

  length quarter $4;      * limit to year for by statement;
  do until(last.quarter);
     set have;
     by quarter;
     if first.quarter then do;
        grp=grp+1;
        if mod(grp,2)=1 then do;  * keep track of odd/even groups;
           savcst=meancost;       * if odd save meancost for even groups;
           _meancost=.;           * if odd then set meancost to missing;
        end;
     end;
  end;
  do until(last.quarter);
  set have;
  by quarter;
  if mod(grp,2)=0 then _meancost=savcst; * if even group set maancost to odd meancost;
  output;
  end;

OUTPUT
========

 WORK.WANT total obs=16

   GVKEY    QUARTER    MEANCOST    _MEANCOST

    1001    2001Q1        11            .
    1001    2001Q1        11            .
    1001    2001Q1        11            .
    1001    2001Q1        11            .
    1001    2002Q2        12           11
    1001    2002Q2        12           11
    1001    2002Q2        12           11
    1001    2002Q2        12           11
    1002    2006Q3        65            .
    1002    2006Q3        65            .
    1002    2006Q3        65            .
    1002    2006Q3        65            .
    1002    2007Q4        70           65
    1002    2007Q4        70           65
    1002    2007Q4        70           65
    1002    2007Q4        70           65


see
https://goo.gl/g3rLDF
https://communities.sas.com/t5/General-SAS-Programming/ignore-first-n-observations-by-group/m-p/425482

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;


data have;
informat Quarter   $6.;
input GVKEY Quarter  Meancost;
cards4;
1001 2001Q1 11 .
1001 2001Q2 11 .
1001 2001Q3 11 .
1001 2001Q4 11 .
1001 2002Q1 12 11
1001 2002Q2 12 11
1001 2002Q3 12 11
1001 2002Q4 12 11
1002 2006Q1 65 .
1002 2006Q2 65 .
1002 2006Q3 65 .
1002 2006Q4 65 .
1002 2007Q1 70 65
1002 2007Q2 70 65
1002 2007Q3 70 65
1002 2007Q4 70 65
;;;;
run;quit;

%utl_submit_wps64('
libname wrk sas7bdat "%sysfunc(pathname(work))";
data wrk.want(rename=qtr=quarter);
  retain gvkey qtr meancost _meancost;
  keep   gvkey qtr meancost _meancost;
  length quarter $4;
  retain savcst grp 0;
  do until(last.quarter);
     set wrk.have;
     by quarter;
     if first.quarter then do;
        grp=grp+1;
        if mod(grp,2)=1 then do;
           savcst=meancost;
           _meancost=.;
        end;
     end;
  end;
  do until(last.quarter);
  set wrk.have;
  by quarter;
  if mod(grp,2)=0 then _meancost=savcst;
  qtr=cats(quarter,"Q",put(_n_,1.));
  output;
  end;
run;quit;
');
