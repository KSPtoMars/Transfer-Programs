// Project: KSPtoMars
// Program: executeBurn.ks
// 
// Description: Universal program to execute the next burn node in the flight plan.
// 
// Dependencies: 	A maneuver node must exist.
//
// Parameters:	None.
//
// Notes: 	Run the program with enough time for the ship to turn towards the maneuver vector.
//			Press the ABORT button at any point to cancel the burn.
// 			Automatic shut down will occur if doesn't meet (or drifts away from) the maneuver vector.
//

// =========== Preliminary Vars ===========
SET Fthrust 	TO 0. //total thrust of ship
SET mi 			TO 0. //total mass rate
SET burnTime 	TO 0. //
SET dV 			TO NEXTNODE:DELTAV:MAG.

// =========== Preliminary SetUp ===========
SET holdVector TO NEXTNODE:BURNVECTOR.
LOCK STEERING TO holdVector.
SAS OFF.
RCS ON.
clearscreen.

LIST ENGINES IN enginList.
FOR eng IN  enginList {
	IF eng:IGNITION = true {
		SET mi TO mi + ( eng:MAXTHRUST / eng:ISP ).
	}
}
IF (MAXTHRUST = 0) {	// Can't let it go and divide by 0 now :P 
	PRINT "ERROR: 0 MAXTHRUST, Program Terminated.".
} ELSE {
	// =========== calculate burn time ===========
	SET Ispg TO ( MAXTHRUST / mi ) * 9.81.
	SET mf TO MASS / ((constant():e)^(dV / Ispg)).
	SET mr TO MAXTHRUST / Ispg.
	SET burnTime TO (MASS - mf) / mr.



	PRINT "Ispg: " + Ispg + " m/s".
	PRINT "Thrust: " + MAXTHRUST + " N".
	PRINT "dm: " + ((MASS*1000) - mf) + " kg".
	PRINT "dV: " + dV + " m/s".
	PRINT "Burn Time: " + burnTime + " s".
	PRINT " ".
	PRINT " ".
	PRINT " ".
	PRINT "Hit ABORT at any time to cancel".

	// =======================================
	// 				Execute burn
	// =======================================
	SET ABORT TO false.
	SET flag TO false.

	UNTIL flag {
		PRINT "Burn:ETA: " + round( NEXTNODE:ETA - ( burnTime / 2 ), 2) + "  " AT (0,7).
		IF NEXTNODE:ETA < ( burnTime / 2 ) { SET flag TO true. }
		IF ABORT = true {
			SET flag TO true.
			PRINT "Manual Abort: Burn Cancelled.".
		}
	}
	IF ABORT = false {
		SET burnTime TO time:seconds + burnTime.

		PRINT "Burning.".
		PRINT " ".
		LOCK THROTTLE TO 1.
		SET flag TO false.
		UNTIL flag {
			PRINT "Time Remaining: " + round(burnTime - time:seconds, 2) AT (0,10).
			IF (time:seconds > burnTime) {
				SET flag TO true.
				PRINT "Burn Complete".
				REMOVE NEXTNODE.
			}
			IF VANG(SHIP:FACING:VECTOR,holdVector) > 5 {
				SET flag TO true.
				PRINT "ERR: Emergency Shut-down: Bad Facing Angle".
			}
			IF ABORT = true {
				PRINT "Manual Abort: Burn Stopped.".
				SET flag TO true.
			}
		}
	}
	LOCK THROTTLE TO 0.
}
SAS ON.
UNLOCK THROTTLE.
UNLOCK STEERING.
WAIT 2.
SAS OFF.












