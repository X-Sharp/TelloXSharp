// MyFakeTello.prg
// Created by    : fabri
// Creation Date : 7/18/2023 5:02:32 PM
// Created for   : 
// WorkStation   : FABXPS


USING System
USING System.Collections.Generic
USING System.Text
USING System.Net
USING System.Net.Sockets

BEGIN NAMESPACE TelloFake
	
	/// <summary>
	/// The MyFakeTello class.
	/// </summary>
	
	PUBLIC CLASS MyFakeTello
		
		PRIVATE CONST listenPort := 8889 AS Long
		
		PRIVATE speed := 0 AS Long
			
		PRIVATE battery := 100 AS Long
			
		PUBLIC METHOD Start() AS Long
			LOCAL listener AS UdpClient
			LOCAL clientEP AS IPEndPoint
			LOCAL fini AS Logic
			LOCAL rawData AS Byte[]
			LOCAL command AS string
			LOCAL resp AS string
			//
			listener := UdpClient{8889}
			clientEP := IPEndPoint{IPAddress.Any, 8889}
			TRY
				fini := false
				WHILE !fini
					Console.WriteLine()
					Console.WriteLine("Waiting for Command...")
					rawData := listener:Receive(REF clientEP)
					Console.WriteLine("--> Packet from {0}", clientEP:ToString())
					command := Encoding.ASCII:GetString(rawData, 0, rawData:Length)
					Console.WriteLine("--> Command : {0}", command)
					IF command:IndexOf("?") > -1
						resp := processReadCommand(command)
						SendMessage(listener, resp, clientEP)
					ELSE
						processCommand(command)
						SendMessage(listener, "OK", clientEP)
					ENDIF
				END WHILE
				
			CATCH e AS Exception
				WriteError(e:ToString())
				SendMessage(listener, e:Message, clientEP)
			END TRY
			listener:Close()
			RETURN 0
			
			
		PRIVATE METHOD SendMessage(client AS UdpClient , message AS string , endpoint AS IPEndPoint ) AS void
			LOCAL msgData AS Byte[]
			//
			msgData := Encoding.ASCII:GetBytes(message)
			client:Connect(endpoint)
			client:Send(msgData, msgData:Length)
			
			
		PRIVATE METHOD processReadCommand(command AS string ) AS string
			SWITCH command
			CASE "speed?"
				RETURN speed:ToString()
			CASE "battery?"
				RETURN battery:ToString()
			CASE "time?"
				RETURN "10"
			END SWITCH
			RETURN string.Empty 
			
			
			
		PRIVATE METHOD processCommand(command AS string ) AS void
			LOCAL cmdPart AS string[]
			//
			cmdPart := command:Split(' ')
			Console.WriteLine(e"Received Command : " + command)
			//
			SWITCH cmdPart[1]
			CASE "command"
				Console.WriteLine(e"Mode Command ON")
			CASE "takeoff"
				Console.WriteLine("Auto take off")
			CASE "land"
				Console.WriteLine("Auto landing")
			CASE "up"
				IF cmdPart:Length == 1
					WriteError("Missing Up param.")
				ELSE
					Console.WriteLine("Move : up " + cmdPart[2])
				ENDIF
			CASE "down"
				IF cmdPart:Length == 1
					WriteError("Missing Down param.")
				ELSE
					Console.WriteLine("Move : down " + cmdPart[2])
				ENDIF
			CASE "left"
				IF cmdPart:Length == 1
					WriteError("Missing Left param.")
				ELSE
					Console.WriteLine("Move : left " + cmdPart[2])
				ENDIF
			CASE "right"
				IF cmdPart:Length == 1
					WriteError("Missing Right param.")
				ELSE
					Console.WriteLine("Move : right " + cmdPart[2])
				ENDIF
			CASE "forward"
				IF cmdPart:Length == 1
					WriteError("Missing Forward param.")
				ELSE
					Console.WriteLine("Move : forward " + cmdPart[2])
				ENDIF
			CASE "back"
				IF cmdPart:Length == 1
					WriteError("Missing Back param.")
				ELSE
					Console.WriteLine("Move : back " + cmdPart[2])
				ENDIF
			CASE "cw"
				IF cmdPart:Length == 1
					WriteError("Missing ClockWise param.")
				ELSE
					Console.WriteLine("Move : cw " + cmdPart[2])
				ENDIF
			CASE "ccw"
				IF cmdPart:Length == 1
					WriteError("Missing CounterClockWise param.")
				ELSE
					Console.WriteLine("Move : ccw " + cmdPart[2])
				ENDIF
			CASE "flip"
				IF cmdPart:Length == 1
					WriteError("Flip Impossible, missing direction.")
				ELSE
					Console.WriteLine("Move : flip " + cmdPart[2])
				ENDIF
			CASE "speed"
				IF cmdPart:Length == 1
					WriteError("Speed Impossible, missing value.")
				ELSE
					speed := Convert.ToInt32(cmdPart[2])
					Console.WriteLine("Speed is {0} cm/s", cmdPart[2])
				ENDIF
			END SWITCH
			
			
		PRIVATE METHOD WriteError(message AS string ) AS void
			LOCAL oldColor AS ConsoleColor
			LOCAL oldBg AS ConsoleColor
			//
			oldColor := Console.ForegroundColor
			oldBg := Console.BackgroundColor
			Console.ForegroundColor := ConsoleColor.White
			Console.BackgroundColor := ConsoleColor.Red
			Console.WriteLine("Error: " + message)
			Console.BackgroundColor := oldBg
			Console.ForegroundColor := oldColor
			
			
	END CLASS
END NAMESPACE // TelloFake