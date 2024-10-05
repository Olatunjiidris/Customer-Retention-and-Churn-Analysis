/* creating Grp5 library */
libname Grp5 '/home/u63776954/sasuser.v94/Coursework2';
run;

/* importing the dataset */
proc import datafile= '/home/u63776954/sasuser.v94/Coursework2/WA_Fn-UseC_-Telco-Customer-Churn.csv'
	dbms=csv
	out=telcom
	replace;
	getnames=yes;
run;

/* converting the imported data into SAS data format */
data Grp5.telecom;
	set telcom;
run;

/* previewing the dataset */
proc print data=grp5.telecom (obs=5) noobs;
title"First 5 observations from the Dataset";
run;

/* checking the data properties */
proc contents data=grp5.telecom;
title "Data Properties";
run;


/* Checking for missing values in the dataset */
proc sql;
title "Missing Values Count by Variable";
    select 
        count(case when gender is null then 1 else . end) as Missing_Gender,
        count(case when SeniorCitizen is null then 1 else . end) as Missing_SeniorCitizen,
        count(case when Partner is null then 1 else . end) as Missing_Partner,
        count(case when Dependents is null then 1 else . end) as Missing_Dependents,
        count(case when Tenure is null then 1 else . end) as Missing_Tenure,
        count(case when PhoneService is null then 1 else . end) as Missing_PhoneService,
        count(case when MultipleLines is null then 1 else . end) as Missing_MultipleLines
    from grp5.telecom;

    select 
        count(case when InternetService is null then 1 else . end) as Missing_InternetService,
        count(case when OnlineSecurity is null then 1 else . end) as Missing_OnlineSecurity,
        count(case when OnlineBackup is null then 1 else . end) as Missing_OnlineBackup,
        count(case when DeviceProtection is null then 1 else . end) as Missing_DeviceProtection,
        count(case when TechSupport is null then 1 else . end) as Missing_TechSupport,
        count(case when StreamingTV is null then 1 else . end) as Missing_StreamingTV,
        count(case when StreamingMovies is null then 1 else . end) as Missing_StreamingMovies
    from grp5.telecom;

    select 
        count(case when Contract is null then 1 else . end) as Missing_Contract,
        count(case when PaperlessBilling is null then 1 else . end) as Missing_PaperlessBilling,
        count(case when PaymentMethod is null then 1 else . end) as Missing_PaymentMethod,
        count(case when MonthlyCharges is null then 1 else . end) as Missing_MonthlyCharges,
        count(case when TotalCharges is null then 1 else . end) as Missing_TotalCharges,
        count(case when Churn is null then 1 else . end) as Missing_Churn
    from grp5.telecom;
quit;

/* dropping observations with missing values */
data Grp5.telecomm1;
	set telcom;
	where TotalCharges is not missing;
    if Churn ='Yes' then Churn = 1;
    else if Churn = "No" then Churn = 0;
    Churnn = input (Churn, 8.);
    drop Churn;
run;

/* Checking for duplicate values */
proc sort data= grp5.telecomm1
out = Grp5.telecomm
nodupkey
dupout=duplicate;
by customerID;
run;

proc print data=duplicate;
run;

/* checking descriptive featurs of categorical variables */
proc freq data=Grp5.telecomm;
    title "Categorical Variables Frequecy";
   tables gender SeniorCitizen Partner Dependents PhoneService 
		MultipleLines InternetService OnlineSecurity OnlineBackup DeviceProtection 
		TechSupport StreamingTV StreamingMovies Contract PaperlessBilling 
		PaymentMethod churnn/nocum;
run;

/* Checking descriptive features of continous variables */
proc means data=Grp5.telecomm N MEAN MEDIAN MODE MIN MAX STDDEV VAR;
	title 'Summary statistics for Continous variables';
  	var tenure MonthlyCharges TotalCharges;
run;

/* --------------------------------Exploratory Data Analysis------------------------------- */
/* total charges Histogram  */
proc sgplot data=GRP5.TELECOMM;
	title "Plot showing the distribution of Total Charges to Customers";
	footnote2 justify=left height=12pt "Grp5";
	histogram TotalCharges / scale=count nbins=10 fillattrs=(color=CX00ffff);
	density TotalCharges / type=Kernel lineattrs=(color=red);
	xaxis grid;
	yaxis grid;
run;

/* Monthly Charges Histogram */
proc sgplot data=grp5.telecomm;
    histogram MonthlyCharges / binstart = 0 binwidth = 10 fillattrs=(color=CX00ffff); 
    density MonthlyCharges / type=kernel lineattrs=(color=red);
    title "Histogram for Monthly Charges";
run;

/* Tenure Histogram */
proc sgplot data=grp5.telecomm;
    histogram Tenure / binstart = 0 binwidth = 10 fillattrs=(color=CX00ffff);
    density Tenure / type=kernel lineattrs=(color=red);
    title "Histogram for Tenure";
run;

proc sgplot data=GRP5.TELECOMM;
	title height=14pt "Exploring Median Gender by tenure with the company";
	footnote2 justify=left height=12pt "Grp5";
	vbox tenure / category=gender fillattrs=(color=CXcad0e6);
	yaxis grid;
run;

/* Performing Mann-Whitney U test for median difference*/
proc npar1way data=grp5.telecom wilcoxon;
   class gender;
   var tenure;
run;

/* Renaming Churn classes */
proc format;
    value churnfmt
        0 = "NO"
        1 = "YES";
run;
/* Churn Variable Bar chart */
proc sgplot data=GRP5.TELECOMM;
	title "Barchart for Customer Churn";
	footnote2 justify=left height=12pt "Grp5";
	vbar Churnn / fillattrs=(color=CX00ffff) datalabel;
	yaxis grid;
	format Churnn churnfmt.;
run;

/* Exploring variables with customer Churn */
proc sort data=GRP5.TELECOMM out=WORK.telecomSort;
	by Churnn;
run;
proc boxplot data=work.telecomSort;
title " ";
	plot (tenure TotalCharges MonthlyCharges )*Churnn / boxstyle=schematic;
run;

/* Investigating churn rate across different variables */

proc sgplot data=GRP5.TELECOMM;
    title "Churn by gender Barchart";
    footnote2 justify=left height=12pt "Grp5";
    vbar Churnn / group=gender fillattrs=group groupdisplay=cluster datalabel;
    yaxis grid;
 	format Churnn churnfmt.;
run;

proc sgplot data=GRP5.TELECOMM;
    title "Churn by Partner Barchart";
    footnote2 justify=left height=12pt "Grp5";
    vbar Churnn / group=Partner fillattrs=Partner groupdisplay=cluster datalabel;
    yaxis grid;
    format Churnn churnfmt.;
run;


/*Customer Contract frequency */
proc sgplot data=GRP5.TELECOMM;
	title height=14pt "Contract Distribution";
	footnote2 justify=left height=12pt "Grp5";
	hbar Contract / fillattrs=(color=CXc8474c transparency=0.25) datalabel;
	xaxis grid;
run;

/* Exploring if the Total charges is based off the tenure on the customers */
proc sgplot data=GRP5.TELECOMM;
	title "Tenure vs Total charges Scatter Plot ";
  scatter x=tenure y=TotalCharges;
run;
/* correlation between tenure and totalCharges */
proc corr data=GRP5.TELECOMM pearson nosimple noprob plots=matrix;
	title  "Correlation between Tenure and Total Charges ";
	var TotalCharges;
	with tenure;
run;

/* Investigating churn period */
proc sql;
title 'Maximum and Minmum tenures of customers that left';
   select max(tenure) as MaxYesTenure, min(tenure) as MinYesTenure
   from Grp5.telecomm
   where Churnn = 1;
quit;

proc sql;
title 'Maximum and Minmum tenures of customers retained';
   select max(tenure) as MaxNoTenure, min(tenure) as MinNoTenure
   from Grp5.telecomm
   where churnn = 0;
quit;
/* ----------------Question 1 - What are the key churn indicators?------------- */;

/* ----------------------------Determining feature significance using Random Forest model----------------- */;
proc hpforest data=Grp5.telecomm;
title 'RF model';
    target Churnn/level=binary;
    input gender SeniorCitizen Partner Dependents PhoneService MultipleLines InternetService OnlineSecurity OnlineBackup 
    		DeviceProtection TechSupport StreamingTV StreamingMovies Contract PaperlessBilling PaymentMethod/level=nominal;
    input Tenure MonthlyCharges TotalCharges/level= interval ;
run;

/* ---------------------------investigating the contract variable----------------------- */;

proc tabulate data=grp5.telecomm;
	class Contract Churnn;
	table Contract All, Churnn All /box='Churn Rate by Contract';
	format Churnn churnfmt.;
	title 'Contract Churn';
run;

/* visualizing the contract churn */;
proc sgplot data=grp5.telecomm;
    vbar Contract / response=Churnn;
    yaxis label="Churn Rate";
    xaxis label="Contract Type";
    title "Churn Rate by Contract Type";
run;

/* ------------------------------Question 2- Income by Contract--------------------------- */;

/* counting subscribers across different services provided by telecom */
proc sql;
    create table grp5.income as
    select 
        'PhoneService' as Variable, PhoneService as Class, count(*) as Frequency from Grp5.telecomm group by PhoneService
    union all
    select 
        'MultipleLines', MultipleLines, count(*) from Grp5.telecomm group by MultipleLines
    union all
    select 
        'InternetService', InternetService, count(*) from Grp5.telecomm group by InternetService
    union all
    select 
        'OnlineSecurity', OnlineSecurity, count(*) from Grp5.telecomm group by OnlineSecurity
    union all
    select 
        'OnlineBackup', OnlineBackup, count(*) from Grp5.telecomm group by OnlineBackup
    union all
    select 
        'DeviceProtection', DeviceProtection, count(*) from Grp5.telecomm group by DeviceProtection
    union all
    select 
        'TechSupport', TechSupport, count(*) from Grp5.telecomm group by TechSupport
    union all
    select 
        'StreamingTV', StreamingTV, count(*) from Grp5.telecomm group by StreamingTV
    union all
    select 
        'StreamingMovies', StreamingMovies, count(*) from Grp5.telecomm group by StreamingMovies;
quit;
/* Creating a new variable for the clusters */

data grp5.income;
    set grp5.income;
    Cluster = Variable || '_' || Class;
run;

/*plotting clustered bar chat of telecom services income */
proc sgplot data=grp5.income;
title 'Count of subscribers across telecom services';
    vbarparm category=Cluster response=Frequency / group=Variable;
    xaxis display= all;
    yaxis grid label='Frequency';
    keylegend / title='Variable';
run;

/* checking income/sales by contract */
proc tabulate data=grp5.telecomm;
	class Contract;
	var TotalCharges;
	table Contract, TotalCharges*(N SUM MEAN) /box='Total Income by Contract';
	title 'Income from Contract';
run;

/* Investigating what contract type stayed longer with the company */
proc sgplot data=GRP5.TELECOMM;
  vbox tenure / category=Contract;
  title 'Custutomer duration by Contract';
run;

/* ------------Comparing the percentage of services consumption by customer contract------- */;
proc tabulate data=grp5.telecomm;
	title 'Percentage of service consumption by contract';
	class PhoneService
			MultipleLines
			InternetService
			OnlineSecurity
			OnlineBackup
			DeviceProtection
			TechSupport
			StreamingTV
			StreamingMovies
			Contract;
	table Contract All, 
			PhoneService*ROWPCTN
			MultipleLines*ROWPCTN
			InternetService*ROWPCTN
			OnlineSecurity*ROWPCTN
			OnlineBackup*ROWPCTN
			DeviceProtection*ROWPCTN
			TechSupport*ROWPCTN
			StreamingTV*ROWPCTN
			StreamingMovies*ROWPCTN /box='Investigating the high income rate of 2years';
	
run;

/*                                            Question 3-Customer Retention
 ------------------------------ Predicting the percentage chance of a Customer leaving for early intervention--------------------------- */;

data telrec;
	set grp5.telecomm;
	if gender ='Male' then gender = 1;
	else if gender = "Female" then gender = 0;
	genderec = input (gender, 8.);
	drop gender;
	

    if Contract = 'Month-to-month' then ContractRec = 0;
    else if Contract = 'One year' then ContractRec = 1;
    else ContractRec = 2;
    drop Contract;

	
	if Dependents ='Yes' then Dependents = 1;
	else if Dependents = "No" then Dependents = 0;
	DependantsRec = input (Dependents, 8.);
	drop Dependents;
	
	if Partner ='Yes' then Partner = 1;
	else if Partner = "No" then Partner = 0;
	PartnerRec = input (Partner, 8.);
	drop Partner;
	
	if PhoneService ='Yes' then PhoneService = 1;
	else if PhoneService = "No" then PhoneService = 0;
	PhoneServiceRec = input (PhoneService, 8.);
	drop PhoneService;
	
	if PaperlessBilling ='Yes' then PaperlessBilling = 1;
	else if PaperlessBilling = "No" then PaperlessBilling = 0;
	PaperlessBillingRec = input (PaperlessBilling, 8.);
	drop PaperlessBilling;
	
	if OnlineSecurity ='Yes' then OnlineSecurityrec = 1;
	else if OnlineSecurity = "No" then OnlineSecurityrec = 0;
	else OnlineSecurityrec = 2;
	drop OnlineSecurity;
	
	if MultipleLines ='Yes' then MultipleLinesrec = 1;
	else if MultipleLines = "No" then MultipleLinesrec = 0;
	else MultipleLinesrec = 2;
	drop MultipleLines;
	
	if OnlineBackup ='Yes' then OnlineBackuprec = 1;
	else if OnlineBackup = "No" then OnlineBackuprec = 0;
	else OnlineBackuprec = 2;
	drop OnlineBackup;
	
	if DeviceProtection ='Yes' then DeviceProtectionrec = 1;
	else if DeviceProtection = "No" then DeviceProtectionrec = 0;
	else DeviceProtectionrec = 2;
	drop DeviceProtection;
	
	if TechSupport ='Yes' then TechSupportrec = 1;
	else if TechSupport = "No" then TechSupportrec = 0;
	else TechSupportrec = 2;
	drop TechSupport;
	
	if StreamingTV ='Yes' then StreamingTVrec = 1;
	else if StreamingTV = "No" then StreamingTVrec = 0;
	else StreamingTVrec = 2;
	drop StreamingTV;
	
	if StreamingMovies ='Yes' then StreamingMoviesrec = 1;
	else if StreamingTV = "No" then StreamingMoviesrec = 0;
	else StreamingMoviesrec = 2;
	drop StreamingMovies;
	
	if PaymentMethod ='Bank transfer (automatic)' then PaymentMethodrec = 0;
	else if PaymentMethod = "Credit card (automatic)" then PaymentMethodrec = 1;
	else if PaymentMethod = "Electronic check" then PaymentMethodrec = 2;
	else PaymentMethodrec = 3;
	drop PaymentMethod;
	
	if InternetService ='DSL' then InternetServicerec = 1;
	else if InternetService = "Fiber optic" then InternetServicerec = 2;
	else InternetServicerec = 0;
	drop InternetService;
	
	drop customerID;
run;

proc print data=telrec (obs=5);
title "Variables encoding";	
run;

proc corr data=telrec;
title "Correlation Matrix for the dataset";
run;

/* logistic regression model */
proc logistic data=GRP5.TELECOMM plots=(roc);
	class gender SeniorCitizen Partner Dependents PhoneService 
		MultipleLines InternetService OnlineSecurity OnlineBackup DeviceProtection 
		TechSupport StreamingTV StreamingMovies Contract PaperlessBilling 
		PaymentMethod;
	model Churnn(event='1')=gender SeniorCitizen Partner Dependents 
		PhoneService MultipleLines InternetService OnlineSecurity OnlineBackup 
		DeviceProtection TechSupport StreamingTV StreamingMovies Contract 
		PaperlessBilling PaymentMethod tenure MonthlyCharges TotalCharges;
	Output out=grp5.model pred=PredictedProb xbeta=LogOdds;
run;

/* calculating the percentage leaving based on the model  */
data grp5.model;
	set grp5.model;
	OddsLeaving = EXP(LogOdds);
	PercentageLeaving = OddsLeaving / (1 + OddsLeaving) * 100;
run;

/* printing the calculated percentages */
proc print data=grp5.model (obs=20);
	title 'Customers Percentage of Churning';
	var customerID Churnn PercentageLeaving; 
run;
