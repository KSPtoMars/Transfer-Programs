// Project: KSPtoMars
// Program: stearRaw.ks
// 
// Description: General use program to rotate a ship to face a target vecter as precicely as posible.
//				The use of this program is not recomended in an atmoshere or on a planets serface.
// 
// Dependencies: stearRawSetUp.ks  <- this program must be executed at some point prior to this program.
//
// Parameters: 	vecTar	- Type : Vector - the target vector to rotate towards
//
// Notes: 	This program is designed to be called inside of a loop in another program.
// 			stearRawSetUp.ks must be run prior to the loop containing this program.
//

DECLARE PARAMETER vecTarget.

//Set up rotation relative to target vector.
SET vecTarRel TO ship:facing:inverse*vecTarget.
SET vecTarAng TO VANG(SHIP:FACING:FOREVECTOR, vecTarget).

//Tick forward.
SET oldAngPolar TO newAngPolar.
SET preTickTime TO postTickTime.
SET postTickTime TO TIME:SECONDS.

//Set up yaw, pitch, and roll of target vector relative to self
SET newAngPolar TO V(
	arcsin(vecTarRel:X), //YAW
	arcsin(vecTarRel:Y), //PITCH	
	0
).
//current rotation speed
SET dAngPolar TO (newAngPolar - oldAngPolar) / (postTickTime - preTickTime).

//If the angel between our facing and the target vectors is outside the buffer
IF (vecTarAng > 1) {
	// KSPtoMarz project condition
	RCS ON.
	
	//target rotational speed based on difstance from target vecort
	IF (vecTarRel:Z >= 0) { //This distinction is important for math reasons
		SET targetdAngPolar TO -(newAngPolar / 10).
	} ELSE {
		SET targetdAngPolar TO (newAngPolar:NORMALIZED * 10).
	}
	
	//the direction and magnatude to activate the controles based on curent and target rotations
	SET correctionPolar TO (dAngPolar - targetdAngPolar) / 10.
	
	//This line corrects for when the math would tell the reaction controls to turn harder than they can
	IF (correctionPolar:MAG > 1) {SET correctionPolar TO correctionPolar:NORMALIZED.}
	
	//Forward the calculated values to the ship controles
	IF (vecTarRel:Z >= 0) {//again, math reasons make this distiction necessary
		SET SHIP:CONTROL:YAW TO correctionPolar:X.
		SET SHIP:CONTROL:PITCH TO correctionPolar:Y.
	} ELSE {
		SET SHIP:CONTROL:YAW TO -correctionPolar:X.
		SET SHIP:CONTROL:PITCH TO -correctionPolar:Y.
	}
} ELSE { //When inside buffer ('close' to target) this describes the control behavior
	RCS OFF. // KSPtoMarz project condition
	
	IF ( dAngPolar:X * newAngPolar:X > 0 ){ // Only correct if drifting away from target facing vector.
		SET SHIP:CONTROL:YAW TO newAngPolar:X.
	} ELSE {
		SET SHIP:CONTROL:YAW TO 0.
	}
	IF ( dAngPolar:Y * newAngPolar:Y > 0 ){ // Only correct if drifting away from target facing vector.
		SET SHIP:CONTROL:PITCH TO newAngPolar:Y.
	} ELSE {
		SET SHIP:CONTROL:PITCH TO 0.
	}
}






