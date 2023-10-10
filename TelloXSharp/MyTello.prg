// MyTello.prg
// Created by    : fabri
// Creation Date : 7/18/2023 5:53:24 PM
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


BEGIN NAMESPACE TelloXSharp

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
			LOCAL modePage AS LONG
			LOCAL cmdCode AS LONG
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
			modePage := 0
			// Now, what do you wanna do ?
			REPEAT
				cmdCode := MenuPage(modePage)
				SWITCH cmdCode
				CASE 1
					IF drone:Command() == Tello.Response.OK
						Console.WriteLine("Ok")
					ENDIF
				CASE 2
					Console.WriteLine(drone:Battery())
				CASE 3
					IF drone:TakeOff() == Tello.Response.OK
						Console.WriteLine("Ok")
					ENDIF
				CASE 4
					IF drone:Land() == Tello.Response.OK
						Console.WriteLine("Ok")
					ENDIF
				CASE 5
					IF drone:TurnClockwise(360) == Tello.Response.OK
						Console.WriteLine("Ok")
					ENDIF
				CASE 6
					Console.WriteLine("Time Of Flight :" + drone:State:tof:ToString())
				CASE 7
					IF drone:StreamOn() == Tello.Response.OK
						// Ok, we will receive some images
						_cancelVideoSource := CancellationTokenSource{}
						_cancelVideo := _cancelVideoSource:Token
						_videoTask := Task{VideoThread, _cancelVideo}
						_videoTask:Start()
						Console.WriteLine("Ok")
					ENDIF
				CASE 8
					IF drone:StreamOff() == Tello.Response.OK
						// Close the Videao Stream
						_cancelVideoSource:Cancel()
						Console.WriteLine("Ok")
					ENDIF
				CASE 9
				CASE 19
					// Change Menu Page
					modePage++
					IF modePage > 1
						modePage := 0
					ENDIF
				CASE 11
					IF drone:MoveUp(20) == Tello.Response.OK
						Console.WriteLine("Ok")
					ENDIF
				CASE 12
					IF drone:MoveDown(20) == Tello.Response.OK
						Console.WriteLine("Ok")
					ENDIF
				CASE 13
					IF drone:MoveLeft(20) == Tello.Response.OK
						Console.WriteLine("Ok")
					ENDIF
				CASE 14
					IF drone:MoveRight(20) == Tello.Response.OK
						Console.WriteLine("Ok")
					ENDIF
				CASE 15
					IF drone:MoveForward(20) == Tello.Response.OK
						Console.WriteLine("Ok")
					ENDIF
				CASE 16
					IF drone:MoveBackward(20) == Tello.Response.OK
						Console.WriteLine("Ok")
					ENDIF
				CASE 17
					// Raw commad
					Console.Write("Command :")
					VAR str := Console.ReadLine()
					VAR action := TelloAction{drone, "Raw Text", str, TelloAction.ActionTypes.Read}
					VAR reponse := drone:SendCommand(action, Tello.TimeOut.Standard)
					Console.WriteLine(reponse)

				END SWITCH
			UNTIL !(cmdCode != 0)
			Console.WriteLine("Press Return to Exit.")
            Console.ReadLine()
            capture:Dispose()
			drone:Dispose()


		PRIVATE  METHOD MenuPage(page AS LONG ) AS LONG
			LOCAL cmd AS STRING
			LOCAL cmdCode AS Int32
			//
			IF page == 0
				Console.WriteLine("0. Quit")
				Console.WriteLine("1. Command")
				Console.WriteLine("2. Battery")
				Console.WriteLine("3. TakeOff")
				Console.WriteLine("4. Land")
				Console.WriteLine("5. Turn Clockwise")
				Console.WriteLine("6. State")
				Console.WriteLine("7. Stream On")
				Console.WriteLine("8. Stream Off")
				Console.WriteLine("9. Next Page")
			ELSE
				Console.WriteLine("0. Quit")
				Console.WriteLine("1. up 20")
				Console.WriteLine("2. down 20")
				Console.WriteLine("3. left 20")
				Console.WriteLine("4. right 20")
				Console.WriteLine("5. forward 20")
				Console.WriteLine("6. backward 20")
				Console.WriteLine("7. Text Command")
				Console.WriteLine("9. Next Page")
			ENDIF
			cmd := Console.ReadLine()
			IF Int32.TryParse(cmd, OUT cmdCode )
				IF cmdCode != 0
					RETURN page * 10 + cmdCode
				ENDIF
				RETURN cmdCode
			ENDIF
			RETURN -1


		PRIVATE  METHOD VideoThread() AS VOID
			LOCAL encoder AS VideoWriter
			LOCAL fileName AS STRING
			LOCAL seq := 0 AS LONG
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