// Tello.prg
// Created by    : fabri
// Creation Date : 7/19/2023 11:31:08 AM
// Created for   : 
// WorkStation   : FABXPS


USING System
USING System.Collections.Generic
USING System.Text

BEGIN NAMESPACE TelloFakeGUI
	
	/// <summary>
	/// The Tello class.
	/// Keep the Tello informations
	/// </summary>
	PUBLIC CLASS Tello
		PRIVATE _battery AS Long
			
		PRIVATE _altitude AS Long
			
		PRIVATE _speed AS Long
			
		PRIVATE _listeningPort AS Long
			
		PUBLIC PROPERTY Battery AS Long
			GET
				RETURN _battery
			END GET
			SET
				_battery := value
			END SET
		END PROPERTY
		
		PUBLIC PROPERTY Altitude AS Long
			GET
				RETURN _altitude
			END GET
			SET
				_altitude := value
			END SET
		END PROPERTY
		
		PUBLIC PROPERTY ListeningPort AS Long
			GET
				RETURN _listeningPort
			END GET
			SET
				_listeningPort := value
			END SET
		END PROPERTY
		
		PUBLIC PROPERTY Speed AS Long
			GET
				RETURN _speed
			END GET
			SET
				_speed := value
			END SET
		END PROPERTY
		
		PUBLIC PROPERTY IsFlying AS Logic AUTO GET INTERNAL SET 
			
		PUBLIC PROPERTY YPos AS Long AUTO GET INTERNAL SET 
			
		PUBLIC PROPERTY XPos AS Long AUTO GET INTERNAL SET 
			
		PUBLIC CONSTRUCTOR()
			SELF:Battery := 100
			SELF:Speed := 0
			SELF:Altitude := 0
			SELF:ListeningPort := 8889
			
			
	END CLASS
	
END NAMESPACE // TelloFakeGUI