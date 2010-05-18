
$ONUELLIST
OPTIONS ITERLIM = 500000000
*OPTIONS LIMROW = 1000  ** UNCOMMENT TO GET LISTING OF ALL CONSTRAINTS
OPTIONS WORK = 800000
OPTION MIP = CPLEX;

SETS
	J1	Sections	/S0*S2/
	M1	Time Steps	/0*30/

ALIAS ( J1, K1 )
ALIAS ( M1, R1 )

PARAMETERS

	L( J1 ) section length
	    /
		S2	0.490000
		S1	0.455000

	    /
	    	TABLE P(J1,M1) Evidence
          0     1     2     3     4     5     6     7     8     9    10    11    12    13    14    15    16    17    18    19    20    21    22    23    24    25    26    27    28    29    30
   S2   1.0   1.0   1.0   1.0   1.0   1.0   1.0   0.0   0.0   1.0   1.0   1.0   1.0   1.0   1.0   1.0   1.0   1.0   1.0   1.0   0.0   1.0   1.0   1.0   1.0   1.0   1.0   1.0   1.0   1.0   1.0
   S1   1.0   1.0   0.0   1.0   1.0   1.0   0.0   0.0   0.0   1.0   1.0   1.0   1.0   1.0   1.0   1.0   1.0   1.0   1.0   1.0   0.0   1.0   1.0   1.0   1.0   1.0   1.0   1.0   1.0   1.0   1.0
   S0   0.5   0.5   0.5   0.5   0.5   0.5   0.5   0.5   0.5   0.5   0.5   0.5   0.5   0.5   0.5   0.5   0.5   0.5   0.5   0.5   0.5   0.5   0.5   0.5   0.5   0.5   0.5   0.5   0.5   0.5   0.5
	TABLE V( J1, M1 )
          0     1     2     3     4     5     6     7     8     9    10    11    12    13    14    15    16    17    18    19    20    21    22    23    24    25    26    27    28    29    30
   S2  67.6  68.9  67.9  68.8  70.2  68.5  67.8  65.9  66.3  67.0  68.6  67.0  67.3  68.4  68.3  68.6  68.7  68.1  68.6  68.2  67.5  68.7  68.3  69.6  70.4  76.1  73.3  72.0  70.9  69.5  69.5
   S1  68.4  68.9  66.2  67.4  68.9  67.1  65.7  64.3  65.6  66.7  68.2  66.4  67.6  68.0  68.0  67.9  67.1  67.0  66.6  67.2  65.3  67.5  67.9  69.0  69.2  70.4  69.7  70.1  69.8  69.3  70.4
   S0  64.0  64.3  63.8  64.1  64.5  63.7  62.8  62.5  63.1  63.1  63.8  63.2  63.7  63.5  63.9  63.9  63.5  63.4  63.4  63.1  62.1  63.6  63.8  64.2  64.1  65.1  64.6  64.5  64.5  64.5  64.7
	TABLE AV( J1, M1 )
          0     1     2     3     4     5     6     7     8     9    10    11    12    13    14    15    16    17    18    19    20    21    22    23    24    25    26    27    28    29    30
   S2  68.3  68.7  68.6  68.5  68.4  68.6  68.7  68.6  68.4  68.4  68.6  68.3  68.5  68.7  68.6  68.7  68.7  68.7  68.9  68.8  69.0  69.1  68.9  68.9  69.0  69.6  69.2  69.0  68.9  69.1  68.9
   S1  67.7  68.0  67.9  67.9  67.8  68.0  67.9  67.9  67.8  67.7  67.8  67.7  67.7  68.3  68.0  67.9  67.8  67.9  68.1  68.0  68.1  68.2  68.0  67.9  68.1  68.4  68.1  68.0  67.9  68.0  68.0
   S0  73.3  73.0  72.8  73.0  72.4  72.9  72.9  72.8  73.0  73.2  72.4  73.6  74.0  73.9  73.7  74.0  73.7  73.6  73.4  73.2  73.4  73.7  73.5  73.6  73.6  74.0  74.0  73.4  73.6  72.7  72.6
	TABLE F( J1, M1 )
          0     1     2     3     4     5     6     7     8     9    10    11    12    13    14    15    16    17    18    19    20    21    22    23    24    25    26    27    28    29    30
   S2   466   431   254   315   284   413   448   453   451   449   459   437   462   421   444   460   429   442   445   486   485   396   418   416   391   398   405   412   346   439   408
   S1   459   458   248   326   295   424   464   456   458   447   479   433   481   408   454   481   424   445   461   483   491   395   437   422   403   360   413   406   371   436   418
   S0   460   464   271   385   312   424   450   455   472   420   453   455   456   405   426   465   405   437   460   445   484   380   422   415   418   377   433   412   376   444   434
	TABLE AF( J1, M1 )
          0     1     2     3     4     5     6     7     8     9    10    11    12    13    14    15    16    17    18    19    20    21    22    23    24    25    26    27    28    29    30
   S2   451   450   440   443   443   447   444   448   447   443   451   444   437   440   435   441   431   434   427   426   427   431   423   425   416   421   416   417   410   409   417
   S1   457   454   446   448   448   453   450   455   454   451   457   449   446   449   439   447   436   436   432   434   434   433   432   430   419   424   425   419   414   410   420
   S0   463   472   454   454   458   460   462   471   463   454   467   454   452   455   435   449   443   440   425   434   433   434   437   437   421   426   434   424   419   419   431

VARIABLES
	Z		objective
	D(J1,M1)	incident state
	Y		total incident delay
	A		average delay
	N		net delay

BINARY VARIABLE D

EQUATIONS
OBJECTIVE
EQ1
EQ2
 EQ3
 EQ4
 EQ5
 EQ6
 EQ7
TOTDELAY
AVGDELAY
NETDELAY
;

 OBJECTIVE ..	Z=E=SUM( J1, SUM( M1, P( J1, M1 ) * D( J1, M1 ) + ( 1 - P( J1, M1 ) ) * ( 1 - D( J1, M1 ) ) ) ); 
* OBJECTIVE ..	Z=E=SUM( J1, SUM( M1, -0.1 * D( J1, M1 ) + P(J1,M1) * D( J1, M1 ) + ( 1 - P( J1, M1 ) ) * ( 1 - D( J1, M1 ) ) ) ); 
* OBJECTIVE ..	Z=E=SUM( J1, SUM( M1, 0.1*P(J1,M1) * D( J1, M1 ) + ( 1 - P( J1, M1 ) ) * ( 1 - D( J1, M1 ) ) ) ); 
EQ1(J1,M1) ..	SUM( K1$(ORD( K1 ) < ORD( J1 ) ), D( K1, M1 ) ) =l= CARD(J1) -  CARD(J1) * ( D( J1, M1 ) - D( J1-1, M1 ) );
EQ2(J1,M1) ..	SUM( R1$(ORD( R1 ) > ORD( M1 ) ), D( J1, R1 ) ) =l= CARD(M1) -  CARD(M1) * ( D( J1, M1 ) - D( J1, M1+1 ) );
 EQ3(J1,M1) ..	SUM( R1$(ORD( R1 ) > ORD( M1 ) ), D( J1, R1 ) ) =l= CARD(M1) +  CARD(M1) * ( D( J1, M1 ) - D( J1-1, M1 ) );
***             the sum over all cells upstream and later than the target cell must be zero if the target cell is a boundary cell in space(-) and time(+)
 EQ4(J1,M1) ..	SUM( K1$(ORD( K1 ) < ORD( J1 ) ), SUM( R1$(ORD( R1 ) > ORD( M1 ) ), D( K1, R1 ) ) ) 
                  =l= 2*CARD(M1) * CARD(J1) -  CARD(M1) * CARD(J1) * ( D( J1, M1 ) - D( J1-1, M1 ) + D( J1, M1 ) - D( J1, M1+1 ) );
***             the sum over all cells downstream and later than the target cell must be zero if the target cell is a boundary cell in space(+) and time(+)
 EQ5(J1,M1) ..	SUM( K1$(ORD( K1 ) > ORD( J1 ) ), SUM( R1$(ORD( R1 ) > ORD( M1 ) ), D( K1, R1 ) ) ) 
                  =l= 2*CARD(M1) * CARD(J1) -  CARD(M1) * CARD(J1) * ( D( J1, M1 ) - D( J1+1, M1 ) + D( J1, M1 ) - D( J1, M1+1 ) );
***             the sum over all cells downstream and earlier than the target cell must be zero if the target cell is a boundary cell in space(+) and time(-)
 EQ6(J1,M1) ..	SUM( K1$(ORD( K1 ) > ORD( J1 ) ), SUM( R1$(ORD( R1 ) < ORD( M1 ) ), D( K1, R1 ) ) ) 
                  =l= 2*CARD(M1) * CARD(J1) -  CARD(M1) * CARD(J1) * ( D( J1, M1 ) - D( J1+1, M1 ) + D( J1, M1 ) - D( J1, M1-1 ) );
***             the sum over all cells upstream and earlier than the target cell must be zero if the target cell is a boundary cell in space(-) and time(-)
 EQ7(J1,M1) ..	SUM( K1$(ORD( K1 ) < ORD( J1 ) ), SUM( R1$(ORD( R1 ) < ORD( M1 ) ), D( K1, R1 ) ) ) 
                  =l= 2*CARD(M1) * CARD(J1) -  CARD(M1) * CARD(J1) * ( D( J1, M1 ) - D( J1-1, M1 ) + D( J1, M1 ) - D( J1, M1-1 ) );
TOTDELAY ..	Y=E=SUM( J1, SUM( M1, L( J1 ) / V(J1,M1) * F( J1, M1 ) ) );
AVGDELAY ..	A=E=SUM( J1, SUM( M1, L( J1 ) / AV(J1,M1) * AF( J1, M1 ) ) );
NETDELAY ..	N=E=Y-A

MODEL BASE / ALL /;
SOLVE BASE USING MIP MINIMIZING Z;
DISPLAY D.l;
