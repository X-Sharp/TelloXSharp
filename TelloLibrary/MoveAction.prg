// MoveAction.prg
// Created by    : fabri
// Creation Date : 7/17/2023 6:24:45 PM
// Created for   : 
// WorkStation   : FABXPS


USING System
USING System.Collections.Generic
USING System.Text

BEGIN NAMESPACE TelloLibrary
	
	/// <summary>
	/// The MoveAction class.
	/// </summary>
	PUBLIC CLASS MoveAction inherit TelloAction
		
		//
		PUBLIC CONSTRUCTOR(drone as Tello , name as string , cmd as string , distance as Long )
			super(drone, name, "", ActionTypes.Control)
			if (distance < 20) .OR. (distance > 500)
				throw ArgumentException{"Invalid distance value", "distance"}
			endif
			if String.IsNullOrEmpty(cmd)
				throw ArgumentException{"Invalid command string", "cmd"}
			endif
			_actionCommand := cmd + " " + distance:ToString()
	END CLASS
	
	
	PUBLIC CLASS MoveBackward INHERIT MoveAction
		PUBLIC CONSTRUCTOR(drone AS Tello , name AS string , distance AS Long )
			SUPER(drone, name, "back", distance)
	END CLASS
	
	PUBLIC CLASS MoveDown INHERIT MoveAction
		PUBLIC CONSTRUCTOR(drone AS Tello , name AS string , distance AS Long )
			SUPER(drone, name, "down", distance)
	END CLASS
	
	PUBLIC CLASS MoveForward INHERIT MoveAction
		PUBLIC CONSTRUCTOR(drone AS Tello , name AS string , distance AS Long )
			SUPER(drone, name, "forward", distance)
	END CLASS
	
	PUBLIC CLASS MoveLeft INHERIT MoveAction
		PUBLIC CONSTRUCTOR(drone AS Tello , name AS string , distance AS Long )
			SUPER(drone, name, "left", distance)
	END CLASS
	
	PUBLIC CLASS MoveRight INHERIT MoveAction
		PUBLIC CONSTRUCTOR(drone AS Tello , name AS string , distance AS Long )
			SUPER(drone, name, "right", distance)
	END CLASS
	
	PUBLIC CLASS MoveUp INHERIT MoveAction
		PUBLIC CONSTRUCTOR(drone AS Tello , name AS string , distance AS Long )
			SUPER(drone, name, "up", distance)
	END CLASS
	
	
END NAMESPACE // TelloLibrary