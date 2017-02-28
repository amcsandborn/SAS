/*-
Summarize crop rotations for 2007 -2016
*/

LIBNAME DataRaw "N:\USERS\Avery\ND08_change\Crop_Rotation" ;*COMPRESS=BINARY;
LIBNAME Library 'N:\Estimates\SAS\SAS_AF_64b';

%LET PathIn = N:\USERS\Avery\ND08_change\Crop_Rotation;

/*- Avery's data for MN */
%LET FileIn = mn_nlcd_sampling_tool_10.csv;  %LET DataOut= mn; 

/*- Avery's data for ND */
%LET FileIn = nd_nlcd_sampling_tool_10.csv;  %LET DataOut= nd; 

/*- Avery's data for SD */
%LET FileIn = sd_nlcd_sampling_tool_10.csv;  %LET DataOut= sd; 


DATA &DataOut   ;
  %LET _EFIERR_ = 0; /* set the ERROR detection macro variable */
/*  infile 'G:\Research\FSA_mgmt_zone_tab\zone_x_2014cutlv.csv'*/
  INFILE "&PathIn\&FileIn"  DELIMITER = ',' MISSOVER DSD LRECL=32767 ;
  LENGTH X Y 6 CDL07-CDL16 CLT 3;
     INFORMAT x best32. ;
     INFORMAT y best32. ;
     INFORMAT CDL07 best32. ;
     INFORMAT CDL08 best32. ;
     INFORMAT CDL09 best32. ;
     INFORMAT CDL10 best32. ;
     INFORMAT CDL11 best32. ;
     INFORMAT CDL12 best32. ;
     INFORMAT CDL13 best32. ;
     INFORMAT CDL14 best32. ;
     INFORMAT CDL15 best32. ;
     INFORMAT CDL16 best32. ;
     INFORMAT CLT        6.;

     FORMAT CDL07 6. ;
     FORMAT CDL08 6. ;
     FORMAT CDL09 6. ;
     FORMAT CDL10 6. ;
     FORMAT CDL11 6. ;
     FORMAT CDL12 6. ;
     FORMAT CDL13 6. ;
     FORMAT CDL14 6. ;
     FORMAT CDL15 6. ;
     FORMAT CDL16 6. ;
     FORMAT CLT   6. ;
  INPUT   x      y
        CDL07  CDL08  CDL09  CDL10  CDL11  CDL12  CDL13  CDL14  CDL15 CDL16
        CLT ;
  DROP X Y;
  IF _ERROR_ THEN CALL SYMPUTX('_EFIERR_',1);  /* set ERROR detection macro variable */
  RUN;


PROC SQL NOPRINT;
  /*- Get total cultivated count for percent calc. */
	SELECT COUNT(*) INTO :CountCult FROM &DataOut WHERE CLT = 2 ;

  /*- count unique across 2015-16 years */
  CREATE TABLE DataRaw.&DataOut._allcombos_15_16 AS SELECT
       CLT
      ,CDL15, CDL16
	 	  ,PUT(CDL15,Cat12Name.) AS CDL_2015 LABEL='CDL 2015'
	 	  ,PUT(CDL16,Cat12Name.) AS CDL_2016 LABEL='CDL 2016'
      ,COUNT(*) AS Count_CDL_15_16
 		  ,CALCULATED Count_CDL_15_16/&CountCult *100 AS Count_Pct FORMAT=8.5
 		  ,PUT(CDL15,Cat04Name.)||' - '||PUT(CDL16,Cat04Name.) AS Abbrev_15_16_c4 LABEL='Mastercat abbrev. 4'    FROM &DataOut R
	  WHERE CLT = 2
    GROUP BY CLT,  CDL15, CDL16
    ORDER BY CLT, Count_CDL_15_16 DESC
    ;

  /*- count unique across 10 years */
  CREATE TABLE DataRaw.&DataOut._allcombos_07_16 AS SELECT
      	CLT
     	,CDL07, CDL08, CDL09, CDL10, CDL11, CDL12, CDL13, CDL14, CDL15, CDL16
     	,COUNT(*) AS Count_CDL_07_16
		 	,CALCULATED Count_CDL_07_16/&CountCult *100 AS Count_Pct
    FROM &DataOut 
	  WHERE CLT = 2
	GROUP BY CLT, CDL07, CDL08, CDL09, CDL10, CDL11, CDL12, CDL13, CDL14, CDL15, CDL16
    ORDER BY CLT, Count_CDL_07_16 DESC
    ;

  /*- count unique across 10 years and only output combos with corn, soybeans, or spring wheat*/
  CREATE TABLE DataRaw.&DataOut._only3crops_07_16 AS SELECT
      	CLT
     	,CDL07, CDL08, CDL09, CDL10, CDL11, CDL12, CDL13, CDL14, CDL15, CDL16
     	,COUNT(*) AS Count_CDL_07_16
		 	,CALCULATED Count_CDL_07_16/&CountCult *100 AS Count_Pct
    FROM &DataOut 
	  WHERE CLT = 2
	  AND ( CDL07 in (1, 5, 23) OR CDL08 in (1, 5, 23) OR CDL09 in (1, 5, 23) OR CDL10 in (1, 5, 23) OR CDL11 in (1, 5, 23) OR CDL12 in (1, 5, 23) OR CDL13 in (1, 5, 23) OR CDL14 in (1, 5, 23) OR CDL15 in (1, 5, 23) OR CDL16 in (1, 5, 23) )
    GROUP BY CLT, CDL07, CDL08, CDL09, CDL10, CDL11, CDL12, CDL13, CDL14, CDL15, CDL16
    ORDER BY CLT, Count_CDL_07_16 DESC
    ;

  /*- count unique across 10 years and only output combos with only corn and soybeans*/
  CREATE TABLE DataRaw.&DataOut._only1and5_07_16 AS SELECT
      	CLT
     	,CDL07, CDL08, CDL09, CDL10, CDL11, CDL12, CDL13, CDL14, CDL15, CDL16
     	,COUNT(*) AS Count_CDL_07_16
		 	,CALCULATED Count_CDL_07_16/&CountCult *100 AS Count_Pct
    FROM &DataOut 
	  WHERE CLT = 2
	  AND ( CDL07 in (1, 5) OR CDL08 in (1, 5) OR CDL09 in (1, 5) OR CDL10 in (1, 5) OR CDL11 in (1, 5) OR CDL12 in (1, 5) OR CDL13 in (1, 5) OR CDL14 in (1, 5) OR CDL15 in (1, 5) OR CDL16 in (1, 5) )
    GROUP BY CLT, CDL07, CDL08, CDL09, CDL10, CDL11, CDL12, CDL13, CDL14, CDL15, CDL16
    ORDER BY CLT, Count_CDL_07_16 DESC
    ;

  /*- count unique across first 5 years */
  CREATE TABLE DataRaw.&DataOut._allcombos_07_11 AS SELECT
      	CLT
     	,CDL07, CDL08, CDL09, CDL10, CDL11
     	,COUNT(*) AS Count_CDL_07_11
		 	,CALCULATED Count_CDL_07_11/&CountCult *100 AS Count_Pct
    FROM &DataOut 
	  WHERE CLT = 2
    GROUP BY CLT, CDL07, CDL08, CDL09, CDL10, CDL11
    ORDER BY CLT, Count_CDL_07_11 DESC
    ;

  /*- count unique across first 5 years */
  CREATE TABLE DataRaw.&DataOut._allcombos_08_12 AS SELECT
      	CLT
     	,CDL08, CDL09, CDL10, CDL11, CDL12
     	,COUNT(*) AS Count_CDL_08_12
		 	,CALCULATED Count_CDL_08_12/&CountCult *100 AS Count_Pct
    FROM &DataOut 
	  WHERE CLT = 2
    GROUP BY CLT, CDL08, CDL09, CDL10, CDL11, CDL12
    ORDER BY CLT, Count_CDL_08_12 DESC
    ;

  /*- count unique across first 5 years */
  CREATE TABLE DataRaw.&DataOut._allcombos_09_13 AS SELECT
      	CLT
     	,CDL09, CDL10, CDL11, CDL12, CDL13
     	,COUNT(*) AS Count_CDL_09_13
		 	,CALCULATED Count_CDL_09_13/&CountCult *100 AS Count_Pct
    FROM &DataOut 
	  WHERE CLT = 2
    GROUP BY CLT, CDL09, CDL10, CDL11, CDL12, CDL13
    ORDER BY CLT, Count_CDL_09_13 DESC
    ;

  /*- count unique across first 5 years */
  CREATE TABLE DataRaw.&DataOut._allcombos_10_14 AS SELECT
      	CLT
     	,CDL10, CDL11, CDL12, CDL13, CDL14
     	,COUNT(*) AS Count_CDL_10_14
		 	,CALCULATED Count_CDL_10_14/&CountCult *100 AS Count_Pct
    FROM &DataOut 
	  WHERE CLT = 2
    GROUP BY CLT, CDL10, CDL11, CDL12, CDL13, CDL14
    ORDER BY CLT, Count_CDL_10_14 DESC
    ;

  /*- count unique across first 5 years */
  CREATE TABLE DataRaw.&DataOut._allcombos_11_15 AS SELECT
      	CLT
     	,CDL11, CDL12, CDL13, CDL14, CDL15
     	,COUNT(*) AS Count_CDL_11_15
		 	,CALCULATED Count_CDL_11_15/&CountCult *100 AS Count_Pct
    FROM &DataOut 
	  WHERE CLT = 2
    GROUP BY CLT, CDL11, CDL12, CDL13, CDL14, CDL15
    ORDER BY CLT, Count_CDL_11_15 DESC
    ;

  /*- count unique across last 5 years */
  CREATE TABLE DataRaw.&DataOut._allcombos_12_16 AS SELECT
      	CLT
     	,CDL12, CDL13, CDL14, CDL15, CDL16
     	,COUNT(*) AS Count_CDL_12_16
		 	,CALCULATED Count_CDL_12_16/&CountCult *100 AS Count_Pct
    FROM &DataOut 
	  WHERE CLT = 2
	GROUP BY CLT, CDL12, CDL13, CDL14, CDL15, CDL16
    ORDER BY CLT, Count_CDL_12_16 DESC
    ;


