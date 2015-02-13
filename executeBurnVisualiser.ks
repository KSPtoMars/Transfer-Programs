// Project: KSPtoMars
// Program: executeBurnVisualiser.ks
// 
// Description: program to add visual representation of inputs for executeBurn.ks
// 
// Dependencies: executeBurn.ks
//
// Parameters: 	prograde component	:scalar
//				radial component	:scalar
//				normal component	:scalar
//				start time			:absolute time (seconds)
//				delta time			:seconds
//
// Notes: THIS PROGRAM DOES NOT EXECUTE THE MANUVER NODE.
//			It just adds a maneuver node to the flight plan for easy visual inspection of the planned burn.
//			
//

clearscreen.
DECLARE PARAMETER pro, rad, nor, startt, deltat.

SET mi TO 0.

// =-=-=-=-=-= Calculate and add dummy maneuver node =-=-=-=-=-=-=
LIST ENGINES IN enginList.
FOR eng IN  enginList {
	IF eng:IGNITION = true {
		SET mi TO mi + ( eng:MAXTHRUST / eng:ISP ).
	}
}

SET Ispg TO ( MAXTHRUST / mi ) * 9.81.
SET mr TO MAXTHRUST / Ispg.
SET mf TO MASS - ( deltat * mr ).
SET dV TO Ispg * ln( MASS / mf ).
SET tempV TO V( rad, nor, pro ):NORMALIZED.

SET tempNode TO NODE(
	startt + (.5 * deltat),
	tempV:X * dV, 
	tempV:Y * dV,
	tempV:Z * dV
	).
ADD tempNode.

RUN executeBurn(pro, rad, nor, startt, deltat).

REMOVE tempNode.
