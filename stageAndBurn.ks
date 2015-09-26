// Project: KSPtoMars
// Program: stearRaw.ks
// 
// Description: all this program does is stage the craft while passing info to executeBurn.ks
// 
// Dependencies: executeBurn.ks
// 
// Parameters: 	a, b, c, d. literally just passing values to executeburn.ks
// 
// Notes: 
// 

DECLARE PARAMETER a, b, c, d.

stage.

run executeBurn(a,b,c,d).

