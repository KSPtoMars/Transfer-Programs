// Project: KSPtoMars
// Program: executeBurn.ks
// 
// Description: General use program to execute a precise burn.
// 
// Dependencies: None.
//
// Parameters: 	prograde component	:scalar
//				radial component	:scalar
//				normal component	:scalar
//				start time			:absolute time (seconds)
//				delta time			:seconds
//
// Notes: 	Run the program with enough time for the ship to turn towards the maneuver vector.
//			Press the ABORT button at any point to cancel the burn.
// 			Automatic shut down will occur if doesn't meet (or drifts away from) the maneuver vector.
//


// =========== Preliminary Vars ===========
SET debug TO false.
DECLARE PARAMETER pro, rad, nor, startt, deltat.
SET saftyFactor TO 5.

SET vecPro TO prograde:vector.
SET vecRad TO up:vector.
SET vecNor TO VCRS(prograde:vector, up:vector).
SET vecTar TO V(0,0,0).

// =========== Preliminary SetUp ===========
clearscreen.

IF debug {
	//display vectors for debug
	SET drawPro TO vecDrawArgs( V(0,0,0), V(0,0,0), RGB(1.0, 1.0, 0.1), "", 10, true ).
	SET drawRad TO vecDrawArgs( V(0,0,0), V(0,0,0), RGB(0.4, 0.5, 1.0), "", 10, true ).
	SET drawNor TO vecDrawArgs( V(0,0,0), V(0,0,0), RGB(1.0, 0.2, 1.0), "", 10, true ).
	SET drawTar TO vecDrawArgs( V(0,0,0), V(0,0,0), RGB(1.0, 0.0, 0.0), "", 10, true ).
}

SAS OFF.
RCS ON.
SET abort to false.
LOCK steering TO vecTar.

PRINT "Prograde:  " + pro.
PRINT "Radial:    " + rad.
PRINT "Normal:    " + nor.
PRINT " ".
PRINT "Start Time:" + round(startt, 2).
PRINT "Delta Time:" + round(deltat, 2).
PRINT " ".
print "hit abort at any time to cancel the burn.".
PRINT " ".
PRINT " ".

SET flag TO false.
UNTIL flag {
	// =========== update vectors ===========
	SET vecPro TO prograde:vector:normalized.
	SET vecRad TO up:vector:normalized.
	SET vecNor TO VCRS(prograde:vector, up:vector):normalized.
	SET vecTar TO (vecPro * pro) + (vecRad * rad) + (vecNor * nor).
	
	IF debug {
	//update debug vectors
		SET drawPro:vec TO vecPro.
		SET drawRad:vec TO vecRad.
		SET drawNor:vec TO vecNor.
		SET drawTar:vec TO vecTar.
	}
	
	PRINT "Starting burn in T - " + round(startt - time:seconds,2) + " " AT (0,9).
	
	IF abort {
		SET flag TO true.
		PRINT "Manual Abort: Burn Cancelled.".
	}
	IF (time:seconds > startt) {
		SET flag TO true.
	}
}
If (abort = false) {
	LOCK throttle TO 1.0.
	PRINT "Burning.".
	PRINT " ".
	SET flag TO false.
	
	// =======================================
	// 				Execute burn
	// =======================================
	UNTIL flag {
		PRINT "T - " + round((startt + deltat) - time:seconds, 2) + " " AT (0,11).
		
		IF debug {
			//update debug vectors
			SET drawPro:vec TO vecPro.
			SET drawRad:vec TO vecRad.
			SET drawNor:vec TO vecNor.
			SET drawTar:vec TO vecTar.
		}
		// =========== update vectors ===========
		SET vecPro TO prograde:vector:normalized.
		SET vecRad TO up:vector:normalized.
		SET vecNor TO VCRS(prograde:vector, up:vector):normalized.
		SET vecTar TO (vecPro * pro) + (vecRad * rad) + (vecNor * nor).
		
		// =========== end burn conditions ===========
		IF abort {
			PRINT "Manual Abort: Burn Stopped.".
			SET flag TO true.
		}
		IF time:seconds > (startt + deltat) {
			PRINT "Burn Complete.".
			SET flag TO true.
		}
		IF VANG(SHIP:FACING:VECTOR,vecTar) > saftyFactor {
			SET flag TO true.
			PRINT "ERR: Emergency Shut-down: Bad Facing Angle".
		}
	}
	LOCK throttle TO 0.
}
SAS ON.
UNLOCK THROTTLE.
UNLOCK STEERING.
WAIT 2.

IF debug {
	//hide debug vectors
	SET drawPro:show TO false.
	SET drawRad:show TO false.
	SET drawNor:show TO false.
	SET drawTar:show TO false.
}

SAS OFF.








