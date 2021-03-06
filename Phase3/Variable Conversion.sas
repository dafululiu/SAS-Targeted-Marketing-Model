/*This program reads in d*/
libname storage '/folders/myfolders/';

proc import datafile='/folders/myfolders/Practise/cd.csv' 
	out=resp_data dbms=csv replace;
run;

/*macros*/
%include '/folders/myfolders/Practise/data_prep_macros.sas';
/*ata and transforms variables for regression. */
/*change program to fit your data and model*/


/* no. of missing observations */
proc means data=resp_data nmiss;
run;

/*looking at data to understand variables and determine how to work with them*/
proc contents data=resp_data;
run;

proc print data=resp_data (obs=10);
run;

data tmp;
set resp_data;
drop seqnum resp_data;
run;

/*be careful with variables with HIGH Cumulative % */
proc freq data=tmp order=freq; 
tables _all_ /maxlevels=5;
run;


proc univariate data=resp_data;
var mgemom; /* continous variable*/
run;

/***resetting ordinal variables**/
data resp_data2;
set  resp_data;

/*0, 25 are midpoints of L4 variable categories */

array origf[10] (0, 1, 2,  3,  4,  5,   6,   7,    8,    9);
array newf [10] (0,25,75,150,350,750,3000,7500,15000,30000);
retain origf1-origf10 newf1-newf10; 
do i=1 to dim(origf); 
 if pwapar=origf[i] then pwapar2=newf[i];
 if PAANHA=origf[i] then PAANHA2=newf[i];
 if PPERSA=origf[i] then PPERSA2=newf[i];
end;
drop origf1--origf10 newf1--newf10 i; 
*******************************************************;

/* L1 variable has midpoints 10 (0-20 years) , 25, 35 etc in years  */
array origy[10] (0, 1, 2, 3, 4, 5, 6, 7, 8, 9);
array newy[10] (10, 25, 35, 45, 55, 65, 75, 85, 95, 105);
retain origy1-origy10 newy1-newy10;

do i=1 to dim(origy); 
 if MGEMLE=origy[i] then MGEMLE2=newy[i];
end;
drop origy1--origy10 newy1--newy10 i; 



***************************************************;
array orig[10](0,  1, 2, 3, 4, 5, 6, 7, 8,  9);
array new[10] (0,5.5,17,30,43,56,69,82,94,100);
retain orig1-orig10 new1-new10; 
do i=1 to dim(orig); 
if MGODRK =orig[i] then MGODRK2 =new[i];
if MGODPR =orig[i] then MGODPR2 =new[i];
if MRELGE =orig[i] then MRELGE2 =new[i];
if MFALLE =orig[i] then MFALLE2 =new[i];
if MFWEKI =orig[i] then MFWEKI2 =new[i];
if MOPLHO =orig[i] then MOPLHO2 =new[i];
if MSKA   =orig[i] then MSKA2 =new[i];
if MSKB1  =orig[i] then MSKB12 =new[i];
if MSKB2  =orig[i] then MSKB22 =new[i];
if MSKC   =orig[i] then MSKC2 =new[i];
if MHHUUR =orig[i] then MHHUUR2 =new[i];
if MAUT1  =orig[i] then MAUT12 =new[i];
if MAUT2  =orig[i] then MAUT22 =new[i];
if MAUT0  =orig[i] then MAUT02 =new[i];
if MINKGE =orig[i] then MINKGE2 =new[i];
end;
drop orig1--orig10 new1--new10 i; 
*************************************************;
run;
/* after above code..u see that no of variables increased*/

*QA;
proc freq data=resp_data2;
tables
MGODRK*MGODRK2
MGODPR*MGODPR2
MRELGE*MRELGE2
MFALLE*MFALLE2
MFWEKI*MFWEKI2
MOPLHO*MOPLHO2
MSKA*MSKA2
MSKB1*MSKB12
MSKB2*MSKB22
MSKC*MSKC2
MHHUUR*MHHUUR2
MAUT1*MAUT12
MAUT2*MAUT22
MAUT0*MAUT02
MINKGE*MINKGE2
MGEMLE*MGEMLE2
pwapar*pwapar2
PAANHA*PAANHA2
PPERSA*PPERSA2 / list;  /*good representation */
run;

data resp_data2;
set  resp_data2;
drop pwapar paanha ppersa
MGODRK
MGODPR
MRELGE
MFALLE
MFWEKI
MOPLHO
MSKA
MSKB1
MSKB2
MSKC
MHHUUR
MAUT1
MAUT2
MAUT0
MINKGE
MGEMLE
;
run;

/**resetting categorical to binary variables*/
data resp_data3;
set resp_data2;

%macro binarycreate(varname, numcat);
%do i=1 %to &numcat;
	if &varname =&i then &varname&i=1; else &varname&i=0;
%end;
%mend;

%binarycreate(moshoo, 10);  /* create 10 new variables moshoo1, moshoo2... */
%binarycreate(mostyp, 41);

drop moshoo mostyp;

run;

proc print data=resp_data2 (obs=10);
run;


proc print data=resp_data3 (obs=10);
run;

/** looking at graphs- predictors by response**/
*get var list;
data indep;                                                                   
set  resp_data2 (drop=resp seqnum moshoo mostyp);                                                 
run;                                                                          
                                                                              
%ObsAndVars(indep);                                                           
%varlist(indep);                                                              

*run macro for graphs;
%macro GraphLoop;     
options mprint; 
 %do i=1 %to &nvars;                                                               
   %let variable=%scan(&varlist,&i);                                          
%DissGraphMakerLogOdds(resp_data2,10,&variable,resp);
 %end;             
options nomprint; 
%mend GraphLoop;                                                              
%GraphLoop; 

/** testing for linear vs quadratic form**/
data resp_data4;
set  resp_data3;

mskb12sq=mskb12**2;
mgodpr2sq=mgodpr2**2;
Sqrmfalle2=(mfalle2-6)**2;
mgodrk2sq=mgodrk2**2;
mgemomsq=mgemom**2;
ppersa2sq=ppersa2**2;
paanha2sq=paanha2**2;
pwapar2sq=pwapar2**2;
amotscsq=amotsc**2;
run;
/*......................    */

proc logistic data=resp_data4 descending;
model resp=mskb12;
title "mskb12 LINEAR Model";
run;
title;

proc logistic data=resp_data4 descending;
model resp=mskb12 mskb12sq;
title "mskb1  QUADRATIC Model";
run;
title;

/*   */
proc logistic data=resp_data4 descending;
model resp=mgodpr2;
title "mgodpr2 LINEAR Model";
run;
title;

proc logistic data=resp_data4 descending;
model resp=mgodpr2 mgodpr2sq;
title "mgodpr2 QUADRATIC Model";
run;
title;

/*..................*/

proc logistic data=resp_data4 descending;
model resp=mfalle2;
title "mfalle2 LINEAR Model";
run;
title;

proc logistic data=resp_data4 descending;
model resp=mfalle2 sqrmfalle2;
title "mfalle2 QUADRATIC Model";
run;
title;

/*.............*/
proc logistic data=resp_data4 descending;
model resp=ppersa2;
title "ppersa2 LINEAR Model";
run;
title;

proc logistic data=resp_data4 descending;
model resp=ppersa2 ppersa2sq;
title "ppersa2 QUADRATIC Model";
run;
title;

/*.............*/
proc logistic data=resp_data4 descending;
model resp=paanha2;
title "paanha2 LINEAR Model";
run;
title;

proc logistic data=resp_data4 descending;
model resp=paanha2 paanha2sq;
title "paanha2 QUADRATIC Model";
run;
title;

/*.............*/
proc logistic data=resp_data4 descending;
model resp=pwapar2;
title "pwapar2 LINEAR Model";
run;
title;

proc logistic data=resp_data4 descending;
model resp=pwapar2 pwapar2sq;
title "pwapar2 QUADRATIC Model";
run;
title;

/*.............*/
proc logistic data=resp_data4 descending;
model resp=amotsc;
title "amotsc LINEAR Model";
run;
title;

proc logistic data=resp_data4 descending;
model resp=amotsc amotscsq;
title "amotsc QUADRATIC Model";
run;
title;

/*.............*/




proc logistic data=resp_data4 descending;
model resp=mgemom;
title "Mgemom LINEAR Model";
run;
title;
proc logistic data=resp_data4 descending;
model resp=mgemom mgemomsq;
title "Mgemom QUADRATIC Model";
run;
title;

/*
SqrSCDJOBINC=(SCDJOBINC-6)**2;
mgemomsq=mgemom**2;

run;

proc logistic data=resp_data4 descending;
model resp=scdjobinc;
title "scdjobinc linear";
run;

proc logistic data=resp_data4 descending;
model resp=Sqrscdjobinc scdjobinc;
title "Sqrscdjobinc quadratic";
run;
title; */

/**final dataset for modeling**/

data storage.model_vars;
set resp_data4;

/*additional programming as needed*/

run;

proc contents data=storage.model_vars;
run;

proc print data=storage.model_vars (obs=10);
run;

*get var list;

proc datasets noprint;
 delete indep;
run;

data indep;                                                                   
set  storage.model_vars (drop=resp seqnum);                                                 
run;                                                                          
                                                                                                                                      
%varlist(indep);       
