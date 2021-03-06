

options ls=132 ps=52 nodate nonumber nocenter FORMCHAR='|_---|+|---+=|-/\<>*'; 
title " ";

data _null_; 
line=repeat('_', 132);
call symput("line",line);
run;


data class; 
length region $20.; 
set sashelp.class;
region='USA'; output;
region='Europe'; output;
region='Australia'; output;
run;


%let numcol=5;
%let colw=%sysevalf((132-(&numcol-1))/&numcol); 
%let width=%sysfunc(floor(&colw)); 

data _null_; 
x="Table 14.1 Demographics and Baseline Characteristics"; 
y="Safety Population";
spacex=floor((132-length(x))/2);
spacey=floor((132-length(y))/2);

xnew=repeat(' ',spacex)||x;
ynew=repeat(' ',spacey)||y; 

z="YYY Consulting, Inc.";
w="Page#";
spacez=132-length(z)-length(w)-1; 
znew=z||repeat(' ', spacez)||w; 


call symput("xnew", xnew);
call symput("ynew", ynew);
call symput("znew", znew); 
 
run;


data class; set class;
name='  '||name; 
run;


ods listing file="C:\reporting\class.lst";

proc report data=class headline headskip spacing=1;
columns region name ('SEX AND AGE' '__' sex age) ('HEIGHT AND WEIGHT' '__' height weight);
define region/'Region' group noprint;
define name/'Name' width=&width spacing=0;
define sex/'Sex' width=&width;
define age/'Age' width=&width;
define height/'Height' width=&width;
define weight/'Weight' width=&width;

compute before region;
line @1 region $30.;
endcomp;

compute after region;
line @1 " "; 
endcomp;



title1 "&znew";
title2 "&xnew";
title3 "&ynew";
title4 "&line";

footnote1 "&line";
footnote2 "Generated by report2.sas, &sysdate &systime SAS &sysver in &sysscpl";



run;

ods listing close; 

%macro mpagenum2(input=,mls=%sysfunc(getoption(linesize)),pointer=Page#);
	filename myfile "&input";
	options mprint mlogic symbolgen;

	data _null_;
		infile myfile print lrecl=&mls pad missover end=eof;
		input text $ 1-&mls;
		retain totpage 0;

		if index(text,"&pointer") then
			totpage+1;

		***** if eof then call symput('totpage',compress(totpage));
		if eof then
			call symput('totpage',compress(put(totpage,best.)));
		call symput("date",put(today(),mmddyy10.));
	run;

	data _null_;
		infile myfile print lrecl=&mls pad missover sharebuffers;
		file "%sysfunc(pathname(work))\DELETEME" print ls=&mls notitles;
		length text $&mls;
		input text $char&mls..;
		put text $&mls..;
	run;

	data _null_;
		infile "%sysfunc(pathname(work))\DELETEME" print lrecl=&mls pad missover sharebuffers;
		file "&input" print ls=&mls notitles;
		length text $&mls;
		input text $char&mls..;
		retain page 1;

		if index(text,"&pointer") then
			do;
				pageof=trim("Page "|| compress(trim(put(page, best.)) ) ||" of "||trim(put("&totpage",$10.)));
				a=(length(pageof));
				page+1;
				substr(text,&mls-a+1) = pageof;
			end;

		put text $&mls..;
	run;

%mend;


%mpagenum2(input=C:\reporting\class.lst,mls=%sysfunc(getoption(linesize)),pointer=Page#)
