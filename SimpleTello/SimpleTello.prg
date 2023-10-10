// SimpleTello.prg
// Created by    : fabri
// Creation Date : 7/18/2023 6:00:37 PM
// Created for   :
// WorkStation   : FABXPS


USING System
USING System.Collections.Generic
USING System.Text
USING System.Net
USING System.Net.Sockets
USING System.Text
USING System.Threading

BEGIN NAMESPACE SimpleTello

	/// <summary>
	/// The SimpleTello class.
	/// Communicate with the Tello, without the TelloLibrary
	/// </summary>
	PUBLIC CLASS SimpleTello
		PRIVATE  _lastResponse := "" AS string

		PRIVATE  IsNewReponseAvailable := false AS Logic

		PRIVATE  PROPERTY LastResponse AS string
			GET
				IsNewReponseAvailable := false
				RETURN _lastResponse

			END GET
		END PROPERTY

		METHOD Start() AS void
			LOCAL droneEndpoint AS IPEndPoint
			LOCAL localEndPoint AS IPEndPoint
			LOCAL client AS UdpClient
			LOCAL th AS Thread
			LOCAL cmd AS string
			LOCAL cmdData AS Byte[]
			//
			Console.WriteLine("Tello RAW Test")
			Console.WriteLine("Open connection to Tello.....")
			Console.Write("IP Address : (empty for default) ")
			VAR address := Console.ReadLine()
			IF string.IsNullOrEmpty(address)
				address := "192.168.10.1"
			ENDIF
			//
			droneEndpoint := IPEndPoint{IPAddress.Parse(address), 8889}
			localEndPoint := IPEndPoint{IPAddress.Any, 8890}
			client := UdpClient{localEndPoint}
			client:Connect(droneEndpoint)
			// Start the receiving Thread
			th := Thread{RecvThread}
			th:Start(client)
			//
			WHILE true
				Console.Write("Command : ")
				cmd := Console.ReadLine()
				IF string.IsNullOrEmpty(cmd)
					EXIT
				ENDIF
				// Send Command to the Tello
				cmdData := Encoding.UTF8:GetBytes(cmd)
				client:Send(cmdData, cmdData:Length)
				Thread.Sleep(0)
				// Something wrong with the receiving Thread ?
				IF !th:IsAlive
					th:Start(client)
				ENDIF
				Thread.Sleep(0)
				// Wait for a response
				WHILE !IsNewReponseAvailable
					NOP
				END WHILE
				Console.WriteLine(LastResponse)
			END WHILE
			client:Close()
			Console.WriteLine("Press <return> to Close...")
			Console.ReadLine()


		PUBLIC  METHOD RecvThread(param AS Object ) AS void
			LOCAL client AS UdpClient
			LOCAL remoteEndPoint AS IPEndPoint
			LOCAL responseData AS Byte[]
			LOCAL response AS string
			//
			client := (UdpClient)param
			WHILE true
				TRY
					remoteEndPoint := null
					responseData := client:Receive(REF remoteEndPoint)
					response := Encoding.UTF8:GetString(responseData)
					IF !response:StartsWith("mid")
						IsNewReponseAvailable := true
						_lastResponse := response
					ENDIF

				CATCH e AS Exception
					Console.WriteLine(e:Message)
					EXIT
				END TRY
            END WHILE
            // Ugly !! Direct access to the Console from the Thread, but.. ok, it works :)
			Console.WriteLine("-->>...")


	END CLASS

END NAMESPACE // SimpleTello