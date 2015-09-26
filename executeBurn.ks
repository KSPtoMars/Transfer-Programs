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
// Notes: 	Run the program with enough time for the ship to turn towards the maneuver vector.
//			Press the ABORT button at any point to cancel the burn.
// 			Automatic shut down will occur if the facing vector doesn't meet (or drifts away from) the maneuver vector.
//			To change the 'buffer angel' for the above, change 'saftyFactor' to the size, in degrees, that you want.
// 


// =========== Preliminary Vars and objects ===========
DECLARE PARAMETER pro, rad, nor, burnt.
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
RUN stearRawSetup.

// =========== calculate burn time ===========
SET dV TO vecTar:MAG.
SET mi TO 0. //total mass rate

LIST ENGINES IN enginList.
FOR eng IN  enginList {
	IF eng:IGNITION = true {
		SET mi TO mi + ( eng:MAXTHRUST / eng:ISP ).
	}
}

IF MAXTHRUST <> 0 {
	SET Ispg TO ( MAXTHRUST / mi ) * 9.81.
	SET mf TO MASS / ((constant():e)^(dV / Ispg)).
	SET mr TO MAXTHRUST / Ispg.
	SET burnTime TO (MASS - mf) / mr.
} ELSE {
	SET burnTime TO 0.
}
SET startt TO burnt - (burnTime/2).


// =========== Display Setup ===========
PRINT "hit abort at any time to cancel the burn.".
PRINT " ".
PRINT "dV Prograde:  " + round(pro,2).
PRINT "dV Radial:    " + round(rad,2).
PRINT "dV Normal:    " + round(nor,2).
PRINT " ".
PRINT "Start Time:" + round(startt, 2).
PRINT "Delta Time:" + round(burnTime, 2).
PRINT " ".
PRINT "<><><><><><><><><><><><><><><><><>".
PRINT " ".
PRINT "YAW : ".
PRINT "PIT : ".
PRINT " ".
PRINT " ".
PRINT " ".

// =========== wait for abort or burn to start ===========
SET flag TO false.
UNTIL flag {
	run stearRaw(vecTar,1).
	
	PRINT "YAW : " + round(newAngPolar:X, 4) + " " AT (0,11).
	PRINT "PIT : " + round(newAngPolar:Y, 4) + " " AT (0,12).
	PRINT "Starting burn in T - " + round(startt - time:seconds,2) + " " AT (0,14). // countdown to burn start
	
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
	SET flag TO false.
	
	// =======================================
	//				Execute burn
	// =======================================
	UNTIL flag {
		run stearRaw(vecTar,1).
		
		PRINT "YAW : " + round(newAngPolar:X, 4) + " " AT (0,11).
		PRINT "PIT : " + round(newAngPolar:Y, 4) + " " AT (0,12).
		PRINT "T - " + round((startt + burnTime) - time:seconds, 2) + " " AT (0,16). // countdown to burn complete
		
		// =========== end burn conditions ===========
		IF abort { // manual abort
			PRINT "Manual Abort: Burn Stopped.".
			SET flag TO true.
		}
		IF time:seconds >= (startt + burnTime) { // burn complete
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
SET SHIP:CONTROL:PITCH TO 0.
SET SHIP:CONTROL:YAW TO 0.
SAS ON.
SET abort to false.
WAIT 2.
SAS OFF.
