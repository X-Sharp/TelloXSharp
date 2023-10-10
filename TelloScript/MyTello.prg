// MyTello.prg
// Created by    : fabri
// Creation Date : 10/10/2023 4:22:51 PM
// Created for   :
// WorkStation   : FABXPS


USING System
USING System.Collections.Generic
USING System.Text
USING System.Collections.Generic
USING System.IO
USING System.Threading
USING System.Threading.Tasks
USING OpenCvSharp
USING TelloLibrary

BEGIN NAMESPACE TelloScript

	/// <summary>
	/// The MyTello class.
	/// </summary>
	// Tello1.Program
	PUBLIC CLASS MyTello

		PRIVATE  _cancelVideoSource AS CancellationTokenSource

		PRIVATE  _cancelVideo AS CancellationToken

		PRIVATE  _videoTask AS Task

		PRIVATE  capture AS VideoCapture

		PUBLIC  METHOD Start( ) AS VOID
			LOCAL ipAddress AS STRING
			LOCAL drone AS Tello
			//
            VAR scriptFile := "Script.tello"
            IF !File.Exists( scriptFile )
                Console.WriteLine("Cannot find Script.Tello !")
                Console.WriteLine("Aborting...")
                RETURN
            ENDIF
            Console.WriteLine("Loading Script.Tello !")
            VAR lines := File.ReadAllLines( scriptFile )
            //
			Console.WriteLine("Starting " + DateTime.Now:ToString() + " session.")
			Console.WriteLine("Initialize OpenCV.....")
			capture := VideoCapture{}
			// Where is the Drone ?
			Console.WriteLine("Open connection to Tello.....")
			Console.Write("IP Address : (empty for default) ")
			ipAddress := Console.ReadLine()
			IF string.IsNullOrEmpty(ipAddress)
				ipAddress := "192.168.10.1"
			ENDIF
			// Get it
			drone := Tello{ipAddress}
			// Now, what do you wanna do ?
            FOREACH VAR codeLine IN lines
                VAR items := codeLine:Split( <CHAR>{ ' '} )
                VAR command := items[ 1 ]
                command := command:ToLower()
                VAR param := ""
                IF items:Length > 1
                    param := items[ 2 ]
                ENDIF
                //
                Console.WriteLine( "-=> " + command + " " + param )
				DO CASE
				CASE command == "command"
					IF drone:Command() == Tello.Response.OK
						Console.WriteLine("Ok")
					ENDIF
				CASE command == "battery?"
					Console.WriteLine(drone:Battery())
				CASE command == "takeoff"
					IF drone:TakeOff() == Tello.Response.OK
						Console.WriteLine("Ok")
					ENDIF
				CASE command == "land"
					IF drone:Land() == Tello.Response.OK
						Console.WriteLine("Ok")
					ENDIF
				CASE command == "cw"
					IF drone:TurnClockwise(Int32.Parse(param)) == Tello.Response.OK
						Console.WriteLine("Ok")
					ENDIF
				CASE command == "tof?"
					Console.WriteLine("Time Of Flight :" + drone:State:tof:ToString())
				CASE command == "streamon"
					IF drone:StreamOn() == Tello.Response.OK
						// Ok, we will receive some images
						_cancelVideoSource := CancellationTokenSource{}
						_cancelVideo := _cancelVideoSource:Token
						_videoTask := Task{VideoThread, _cancelVideo}
						_videoTask:Start()
						Console.WriteLine("Ok")
					ENDIF
				CASE command == "streamoff"
					IF drone:StreamOff() == Tello.Response.OK
						// Close the Videao Stream
						_cancelVideoSource:Cancel()
						Console.WriteLine("Ok")
					ENDIF
				CASE command == "up"
					IF drone:MoveUp(20) == Tello.Response.OK
						Console.WriteLine("Ok")
					ENDIF
				CASE command == "down"
					IF drone:MoveDown(20) == Tello.Response.OK
						Console.WriteLine("Ok")
					ENDIF
				CASE command == "left"
					IF drone:MoveLeft(20) == Tello.Response.OK
						Console.WriteLine("Ok")
					ENDIF
				CASE command == "right"
					IF drone:MoveRight(20) == Tello.Response.OK
						Console.WriteLine("Ok")
					ENDIF
				CASE command == "forward"
					IF drone:MoveForward(20) == Tello.Response.OK
						Console.WriteLine("Ok")
					ENDIF
				CASE command == "back"
					IF drone:MoveBackward(20) == Tello.Response.OK
						Console.WriteLine("Ok")
                    ENDIF
                OTHERWISE
                    Console.WriteLine( "command unknown...")
				ENDCASE
			NEXT
			Console.WriteLine("Press Return to exit.")
			Console.ReadLine()
			drone:Dispose()


		PRIVATE  METHOD VideoThread() AS VOID
			LOCAL encoder AS VideoWriter
			LOCAL fileName AS STRING
			LOCAL seq AS LONG
			//
			encoder := NULL
			fileName := GetUniqueFileName("tello.avi")
			IF capture:Open("udp://0.0.0.0:11111")
				encoder := VideoWriter{ fileName, FourCC.MJPG, 15.0, Size{capture:FrameWidth, capture:FrameHeight} }
				BEGIN USING VAR frame := Mat{}
					WHILE TRUE
						TRY
							IF capture:Read(frame)
								encoder:Write(frame)
								seq++
							ENDIF
							IF _cancelVideo:IsCancellationRequested
								_cancelVideo:ThrowIfCancellationRequested()
							ENDIF

						CATCH e AS Exception
							Console.WriteLine("Error " + e:Message)
							EXIT
						END TRY
					END WHILE
				END USING
			ENDIF
			encoder?:Release()
			capture:Release()


		PRIVATE  METHOD GetUniqueFileName(v AS STRING ) AS STRING
			LOCAL fileName AS STRING
			LOCAL ext AS STRING
			LOCAL max AS LONG
			LOCAL files AS IEnumerable<STRING>
			LOCAL fileInfo AS STRING
			LOCAL number AS LONG
			//
			fileName := Path.GetFileNameWithoutExtension(v)
			ext := Path.GetExtension(v)
			max := 0
			files := Directory.EnumerateFiles(AppContext.BaseDirectory, fileName + "*" + ext)
			FOREACH @@file AS STRING IN files
				fileInfo := Path.GetFileNameWithoutExtension(@@file)
				fileInfo := fileInfo:Substring(fileName:Length)
				number := 0
				IF Int32.TryParse(fileInfo, OUT number)
					max := Math.Max(max, number)
				ENDIF
			NEXT
			RETURN fileName + (max + 1):ToString("D4") + ext


	END CLASS

END NAMESPACE // TelloXSharp