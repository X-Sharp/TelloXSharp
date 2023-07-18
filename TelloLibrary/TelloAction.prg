// TelloAction.prg
// Created by    : fabri
// Creation Date : 7/17/2023 6:29:32 PM
// Created for   : 
// WorkStation   : FABXPS


USING System
USING System.Collections.Generic
USING System.Text

BEGIN NAMESPACE TelloLibrary
	
	/// <summary>
	/// The TelloAction class.
	/// </summary>
	
	PUBLIC CLASS TelloAction
		
		
	PUBLIC ENUM ActionTypes
		MEMBER Command
		MEMBER Control
		MEMBER Set
		MEMBER Read
		
	END ENUM
	
		PROTECTED _drone AS Tello
			
		PRIVATE _response AS string
			
		PROTECTED _actionName AS string
			
		PROTECTED _actionCommand AS string
			
		PRIVATE _actionType AS ActionTypes
			
		/// <summary>
		/// Description of the command. Used for loggin (not implemented now), maybe used in Log File ??
		/// </summary>
		PUBLIC PROPERTY Name AS string GET _actionName
		/// <summary>
		/// The command string sent to the Tello
		/// </summary>
		PUBLIC PROPERTY Command AS string GET _actionCommand
			
		/// <summary>
		/// What kind of Command is it ?
		/// </summary>
		PUBLIC PROPERTY ActionType AS ActionTypes GET _actionType
			
		/// <summary>
		/// The Tello response to the Command (the original string)
		/// </summary>
		PUBLIC PROPERTY ServerResponse AS string GET _response
			
		/// <summary>
		/// The Tello response to the Command (OK/FAIL)
		/// </summary>
		PUBLIC PROPERTY Response AS Tello.Response GET IIF((!(_response:ToUpper() == "OK")) , Tello.Response.FAIL , Tello.Response.OK)
			
		/// <summary>
		/// Create a Tello Action
		/// </summary>
		/// <param name="drone">The Tello object that will send the command, and give a response</param>
		/// <param name="name">The description of the Command</param>
		/// <param name="command">The Command sent to the Tello</param>
		/// <param name="type">The type of this Action</param>
		PUBLIC CONSTRUCTOR(drone AS Tello , name AS string , command AS string , actionType AS ActionTypes )
			SELF:_actionCommand := command
			SELF:_actionName := name
			SELF:_actionType := actionType
			SELF:_drone := drone
			
		/// <summary>
		/// Send the Command
		/// </summary>
		/// <param name="waitTime">The TimeOut of the Response</param>
		/// <returns></returns>
		PUBLIC METHOD SendCommand(waitTime AS Long ) AS string
			SELF:_response := SELF:_drone:SendCommand(SELF, waitTime)
			RETURN SELF:_response
			
		/// <summary>
		/// Send the Command 
		/// </summary>
		/// <param name="waitTime">The TimeOut of the Response, Tello.TimeOut.Standard per default</param>
		/// <returns></returns>
		PUBLIC METHOD SendCommand(waitTime := Tello.TimeOut.Standard AS Tello.TimeOut ) AS string
			RETURN SELF:_response := SELF:SendCommand((Long)waitTime)
			
			
	END CLASS
	
END NAMESPACE // TelloLibrary