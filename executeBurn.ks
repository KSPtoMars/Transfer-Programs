// Project: KSPtoMars
// Program: executeBurn.ks
// 
// Description: General use program to execute a precise burn.
// 
// Dependencies: 	stearRaw.ks   
//					stearRawSetup.ks
//
// Parameters: 	prograde component	: scalar
//				radial component	: scalar
//				normal component	: scalar
//				start time			: absolute time (seconds)
//				delta time			: seconds
//
// Notes: 	Run the program with enough time for the ship to turn towards the maneuver vector (recomend 3-4 minutes minimum for large ships).
//			Press the ABORT button at any point to cancel the burn.
// 			Automatic shut down will occur if the facing vector doesn't meet (or drifts away from) the maneuver vector.
//				To change the 'buffer' for the above, change 'saftyFactor' to the size, in degrees, that you want.
//


// =========== Preliminary Vars and objects ===========
DECLARE PARAMETER pro, rad, nor, startt, deltat.
SET saftyFactor TO 1.

LOCK vecPro TO prograde:vector:normalized.
LOCK vecRad TO up:vector:normalized.
LOCK vecNor TO VCRS(prograde:vector, up:vector):normalized.
LOCK vecTar TO (vecPro * pro) + (vecRad * rad) + (vecNor * nor).

// =========== Preliminary SetUp ===========
clearscreen.
SAS OFF.
RCS ON.
SET abort to false.
RUN stearRawSetup.ks.

// =========== Display Setup ===========
PRINT "hit abort at any time to cancel the burn.".
PRINT " ".
PRINT "Prograde:  " + pro.
PRINT "Radial:    " + rad.
PRINT "Normal:    " + nor.
PRINT " ".
PRINT "Start Time:" + round(startt, 2).
PRINT "Delta Time:" + round(deltat, 2).
PRINT " ".
PRINT " ".
PRINT " ".
PRINT "YAW : ".
PRINT "PIT : ".
PRINT " ".
// =========== wait for abort or burn to start ===========
SET flag TO false.
UNTIL flag {
	run stearRaw(vecTar).
	
	PRINT "Starting burn in T - " + round(startt - time:seconds,2) + " " AT (0,9). // countdown to burn start
	PRINT "YAW : " + (newAngPolar:X) AT (0,11).
	PRINT "PIT : " + (newAngPolar:Y) AT (0,12).
	
	IF abort { // manual abort
		SET flag TO true.
		PRINT "Manual Abort: Burn Cancelled.".
	}
	IF (time:seconds >= startt) { // time to burn
		SET flag TO true.
	}
}

// =========== If burn not aborted ===========
If (abort = false) {
	LOCK throttle TO 1.0.
	PRINT "Burning.".
	PRINT " ".
	PRINT " ".
	SET flag TO false.
	
	// =======================================
	//				Execute burn
	// =======================================
	UNTIL flag {
		run stearRaw(vecTar).
		
		PRINT "T - " + round((startt + deltat) - time:seconds, 2) + " " AT (0,15). // countdown to burn complete
		
		// =========== end burn conditions ===========
		IF abort { // manual abort
			PRINT "Manual Abort: Burn Stopped.".
			SET flag TO true.
		}
		IF time:seconds > (startt + deltat) { // burn complete
			PRINT "Burn Complete.".
			SET flag TO true.
		}
		IF VANG(SHIP:FACING:VECTOR,vecTar) > saftyFactor { // facing error to great
			SET flag TO true.
			PRINT "ERR: Emergency Shut-down: Bad Facing Angle".
		}
	}
	LOCK throttle TO 0.
}

// =========== clean up =========== 
SAS ON.
SET abort to false.
WAIT 2.
SAS OFF.
