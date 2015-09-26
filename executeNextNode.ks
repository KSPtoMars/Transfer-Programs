// Project: KSPtoMars
// Program: executeNextNode.ks
// 
// Description: Grabes data from next manuver node in flight plan and passes to to executeBurn.ks
// 
// Dependencies: 	A maneuver node must exist.
//					executeBurn.ks
//
// Parameters:	none.
//
// Notes: 	Run the program with enough time for the ship to turn towards the maneuver vector.
//			Press the ABORT button at any point to cancel the burn.
// 			Automatic shut down will occur if doesn't meet (or drifts away from) the maneuver vector.
//

run executeBurn(NEXTNODE:prograde, NEXTNODE:radialout, NEXTNODE:normal, time:seconds + NEXTNODE:ETA).


