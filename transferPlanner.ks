// Project: KSPtoMars
// Program: transferPlaner.ks
//
// Description: 2037 transfer window ejection burn(s) planer. 
//
// Dependencies: Clean flight plan(no planed nodes).
//
// Notes: This program doesn't work: Failure to find maneuver node that brings us close(enough) to Mars.
// 

// =========== Preliminary Vars ===========
SET idealtime 	TO 234147433.		// Ideal transfer burn time within window*
//SET idealtime 	TO 234147433 - (SHIP:OBT:PERIOD / 4). 
SET DVprog 		TO 3750.56380. 		// delta-V prograde*
SET DVnorm 		TO -0.02428. 		// delta-V normal*
SET targetSMA	TO 194995171699.	// target Semi-Major Axis of kerbol orbit*
SET targetEcc	TO 0.22127.			// target Eccentricity of Kerbol orbit*
SET TargetInc	TO 23.951.			// target Inclination of Kerbol orbit*
									// * as calculated by the math team.

SET nodeFlag TO 0.
SET bestErr TO 10.0.
SET nextErr TO 0.0.
SET lastSMA To 0.0.
SET nextSMA To 0.0.
SET bestBurnTime TO idealtime. // goal departure time
SET nextBurnTime TO bestBurnTime.
SET scoot TO 1.

SET node0 TO NODE( nextBurnTime, 0, DVnorm, DVprog ).
ADD node0.
SET nextSMA TO node0:ORBIT:NEXTPATCH:SEMIMAJORAXIS.
REMOVE node0.

clearscreen.
until nodeFlag > 10 {
	//=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
	// Place maneuver node in optimal position by time.
	// Scoot around until at target transfer orbit
	//=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
	
	SET nextBurnTime TO nextBurnTime + scoot.
	SET node0 TO NODE( nextBurnTime, 0, DVnorm, DVprog ).
	ADD node0.
	
	IF node0:ORBIT:NEXTPATCH:BODY:NAME = "Sun" {
		PRINT "Sol." AT (0,2).
	
		SET lastSMA TO nextSMA.
		SET nextSMA TO node0:ORBIT:NEXTPATCH:SEMIMAJORAXIS.
		
		// find %difference of semi-major axis
		SET nextErr TO ( nextSMA + targetSMA )/2.
		SET nextErr TO  abs(( nextSMA - targetSMA ) / nextErr ).
		
		PRINT "nextErr: " + nextErr AT (0,3).
		PRINT "bestErr: " + bestErr AT (0,4).
		
		//Check if next node is better than best node
		IF nextErr < bestErr {
			//if so mark as better option
			SET bestErr TO nextErr.
		}
		
		IF ( nextSMA < lastSMA AND nextSMA < targetSMA ) OR ( nextSMA > lastSMA AND nextSMA > targetSMA ) {
			SET scoot TO 0 - scoot.
			SET nodeFlag TO nodeFlag + 1.
		} ELSE {
			SET bestBurnTime TO nextBurnTime. 
		}
	} ELSE {
		PRINT "Mun." AT (0,2).
		
		SET tempnode0 TO NODE( nextBurnTime + (60*60*35), 0, 0, 0 ).
		ADD tempnode0.
		
		SET lastSMA TO nextSMA.
		SET nextSMA TO tempnode0:ORBIT:NEXTPATCH:SEMIMAJORAXIS.
		
		REMOVE tempnode0.
		
		// find %difference of semi-major axis
		SET nextErr TO ( nextSMA + targetSMA )/2.
		SET nextErr TO  abs(( nextSMA - targetSMA ) / nextErr ).
		
		PRINT "nextErr: " + nextErr AT (0,3).
		PRINT "bestErr: " + bestErr AT (0,4).
		
		//Check if next node is better than best node
		IF nextErr < bestErr {
			//if so mark as better option
			SET bestErr TO nextErr.
		}
		
		IF ( nextSMA < lastSMA AND nextSMA < targetSMA ) OR ( nextSMA > lastSMA AND nextSMA > targetSMA ) {
			SET scoot TO 0 - scoot.
			SET nodeFlag TO nodeFlag + 1.
		} ELSE {
			SET bestBurnTime TO nextBurnTime. 
		}
	}
	
	REMOVE node0.
}

PRINT "Burn Set To: " + floor( bestBurnTime ) + " sec" AT (0,6).

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//correctional node
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
IF bestBurnTime < idealtime {
	SET node1 TO NODE( bestBurnTime - SHIP:OBT:PERIOD , 0, 0, 0 ).
	ADD node1.
	UNTIL ( node1:ORBIT:PERIOD > (idealtime - bestBurnTime) + SHIP:OBT:PERIOD ) {
		SET node1:PROGRADE TO node1:PROGRADE + 1.
	}
} ELSE {
	SET node1 TO NODE( bestBurnTime - (2*SHIP:OBT:PERIOD), 0, 0, 0 ).
	ADD node1.
	UNTIL ( node1:ORBIT:PERIOD > ( 2 * SHIP:OBT:PERIOD ) - ( bestBurnTime - idealtime )) {
		SET node1:PROGRADE TO node1:PROGRADE + 1.
	}
}
SET node0 TO NODE( idealtime, 0, DVnorm, DVprog - node1:PROGRADE ).
ADD node0.





















