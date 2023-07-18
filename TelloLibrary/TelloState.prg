// TelloState.prg
// Created by    : fabri
// Creation Date : 7/17/2023 6:34:47 PM
// Created for   : 
// WorkStation   : FABXPS


USING System
USING System.Collections.Generic
USING System.Text

BEGIN NAMESPACE TelloLibrary
	
	/// <summary>
	/// State of the Tello
	/// </summary>
	PUBLIC CLASS TelloState
		PRIVATE _state AS string
			
		PRIVATE states AS Dictionary<string, string>
			
		/// <summary>
		/// A String indicating the current state of the Tello
		/// </summary>
		PUBLIC PROPERTY State AS string
			GET
				RETURN _state
				
			END GET
			INTERNAL SET
				LOCAL elements AS string[]
				LOCAL itemValue AS string[]
				// The State string
				_state := value
				// Remove trailing \r\n
				_state := _state:Trim('\r', '\n')
				// Split each elements
				elements := _state:Split(<Char>{';'}, StringSplitOptions.RemoveEmptyEntries)
				// For each element, retrieve the Keyp/Value pairs
				FOREACH item AS string IN elements
					itemValue := item:Split(':')
					//if the key doesn't exist add-it, or update
					IF states:ContainsKey(itemValue[1])
						states[itemValue[1]] := itemValue[2]
					ELSE
						states:Add(itemValue[1], itemValue[2])
					ENDIF
				NEXT
				
			END SET
		END PROPERTY
		
		/// <summary>
		/// The ID of the mission Pad
		/// </summary>
		PUBLIC PROPERTY mid AS Long GET RetrieveIntValue("mid")
			
		/// <summary>
		/// The "x" coordinate detected on the Mission Pad.
		/// </summary>
		PUBLIC PROPERTY x AS Long GET RetrieveIntValue("x")
			
		/// <summary>
		/// The "y" coordinate detected on the Mission Pad.
		/// </summary>
		PUBLIC PROPERTY y AS Long GET RetrieveIntValue("y")
			
		/// <summary>
		/// The "z" coordinate detected on the Mission Pad.
		/// </summary>
		PUBLIC PROPERTY z AS Long GET RetrieveIntValue("z")
			
		/// <summary>
		/// The degree of the attitude pitch
		/// </summary>
		PUBLIC PROPERTY pitch AS Long GET RetrieveIntValue("pitch")
			
		/// <summary>
		/// The degree of the attitude roll
		/// </summary>
		PUBLIC PROPERTY roll AS Long GET RetrieveIntValue("roll")
			
		/// <summary>
		/// The degree of the attitude yaw
		/// </summary>
		PUBLIC PROPERTY yaw AS Long GET RetrieveIntValue("yaw")
			
		/// <summary>
		/// The speed of "x" axis
		/// </summary>
		PUBLIC PROPERTY vgx AS Long GET RetrieveIntValue("vgx")
			
		/// <summary>
		/// The speed of "y" axis
		/// </summary>
		PUBLIC PROPERTY vgy AS Long GET RetrieveIntValue("vgy")
			
		/// <summary>
		/// The speed of "z" axis
		/// </summary>
		PUBLIC PROPERTY vgz AS Long GET RetrieveIntValue("vgz")
			
		/// <summary>
		/// The lowest temperature in degree Celsius
		/// </summary>
		PUBLIC PROPERTY templ AS Long GET RetrieveIntValue("templ")
			
		/// <summary>
		/// The highest temperature in degree Celsius
		/// </summary>
		PUBLIC PROPERTY temph AS Long GET RetrieveIntValue("temph")
			
		/// <summary>
		/// The time of flight distance in cm
		/// </summary>
		PUBLIC PROPERTY tof AS Long GET RetrieveIntValue("tof")
			
		/// <summary>
		/// The height in cm
		/// </summary>
		PUBLIC PROPERTY height AS Long GET RetrieveIntValue("h")
			
		/// <summary>
		/// The percentage of the current battery level
		/// </summary>
		PUBLIC PROPERTY bat AS Long GET RetrieveIntValue("bat")
			
		/// <summary>
		/// The barometer measurement in cm
		/// </summary>
		PUBLIC PROPERTY baro AS real8 GET RetrieveDoubleValue("baro")
			
			
		/// <summary>
		/// The amount of time the motor has been used
		/// </summary>
		PUBLIC PROPERTY time AS Long GET RetrieveIntValue("time")
			
		/// <summary>
		/// The acceleration of the "x" axis
		/// </summary>
		PUBLIC PROPERTY agx AS real8 GET RetrieveDoubleValue("agx")
		/// <summary>
		/// The acceleration of the "y" axis
		/// </summary>
		PUBLIC PROPERTY agy AS real8 GET RetrieveDoubleValue("agy")
			
		/// <summary>
		/// The acceleration of the "z" axis
		/// </summary>
		PUBLIC PROPERTY agz AS real8 GET RetrieveDoubleValue("agz")
			
		PUBLIC CONSTRUCTOR(msgState AS string )
			SELF:states := Dictionary<string, string>{}
			SELF:State := msgState
			
			#region Key/Value Helpers
		PRIVATE METHOD RetrieveIntValue(key AS string ) AS Long
			LOCAL itemValue AS STRING
			LOCAL itemInt AS INT
			//
			IF (SELF:states:TryGetValue(key, OUT itemValue )) .AND. (Int32.TryParse(itemValue, OUT itemInt ))
				RETURN itemInt
			ENDIF
			RETURN 0
			
			
		PRIVATE METHOD RetrieveDoubleValue(key AS string ) AS real8
			LOCAL itemValue AS STRING
			LOCAL itemDouble AS Double
			//
			IF (SELF:states:TryGetValue(key, OUT itemValue )) .AND. (Double.TryParse(itemValue, OUT itemDouble ))
				RETURN itemDouble
			ENDIF
			RETURN 0.0
			#endregion
			
	END CLASS
	
END NAMESPACE // TelloLibrary