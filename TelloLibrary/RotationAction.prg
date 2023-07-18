// RotationAction.prg
// Created by    : fabri
// Creation Date : 7/17/2023 7:44:58 PM
// Created for   : 
// WorkStation   : FABXPS


USING System
USING System.Collections.Generic
USING System.Text

BEGIN NAMESPACE TelloLibrary
	
	/// <summary>
	/// The RotationAction class.
	/// </summary>
	PUBLIC CLASS RotateClockwise INHERIT TelloAction
		
		PUBLIC CONSTRUCTOR(drone AS Tello , name AS string , degrees AS Long )
			SUPER(drone, name, "", ActionTypes.Control)
			IF (degrees < 0) .OR. (degrees > 3600)
				THROW ArgumentException{"Invalid degrees value", "degrees"}
			ENDIF
			_actionCommand := "cw " + degrees:ToString()
			
	END CLASS
	
	PUBLIC CLASS RotateCounterClockwise INHERIT TelloAction
		
		PUBLIC CONSTRUCTOR(drone AS Tello , name AS string , degrees AS Long )
			SUPER(drone, name, "", ActionTypes.Control)
			IF (degrees < 0) .OR. (degrees > 3600)
				THROW ArgumentException{"Invalid degrees value", "degrees"}
			ENDIF
			_actionCommand := "ccw " + degrees:ToString()
			
	END CLASS
END NAMESPACE // TelloLibrary