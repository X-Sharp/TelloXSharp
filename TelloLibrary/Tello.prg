// Tello.prg
// Created by    : fabri
// Creation Date : 7/17/2023 7:31:36 PM
// Created for   : 
// WorkStation   : FABXPS


USING System
USING System.Collections.Generic
USING System.Text
USING System
USING System.Collections.Generic
USING System.Threading
USING System.Threading.Tasks
USING TelloLibrary

BEGIN NAMESPACE TelloLibrary
	
	/// <summary>
	/// A Class to use the DJI Tello.
	/// </summary>
	PUBLIC CLASS Tello IMPLEMENTS IDisposable
		
	PUBLIC ENUM Response
		MEMBER OK
		MEMBER FAIL
		
	END ENUM
	
	PUBLIC ENUM WellKnownPort
		MEMBER SendPort := 8889
		MEMBER RecvPort
		
	END ENUM
	
	PUBLIC ENUM TimeOut
		MEMBER Standard := 4500
		MEMBER Pulse := 6000
		
	END ENUM
	
		PRIVATE _messageQueue AS Queue<string>
			
		PRIVATE _messageEvent AS AutoResetEvent
			
		PRIVATE _client AS TelloUdpClient
			
		PRIVATE _commandMode := false AS Logic
			
		PRIVATE _lastException := null AS Exception
			
		PRIVATE _cancelRecvSource AS CancellationTokenSource
			
		PRIVATE _cancelRecv AS CancellationToken
			
		PRIVATE _messagePump AS Task
			
		PRIVATE _cancelPulseSource AS CancellationTokenSource
			
		PRIVATE _cancelPulse AS CancellationToken
			
			// The ManualEvent (flag) used to indicate that we need to send a Pulse
		PRIVATE _pulseEvent AS ManualResetEvent
			
		PRIVATE _pulseTello AS Task
			
		PRIVATE _state AS TelloState
			
		/// <summary>
		/// Indicate if Command mode is active
		/// </summary>
		PUBLIC PROPERTY CommandModeEnabled AS Logic GET _commandMode
			
		/// <summary>
		/// Access the latest exception
		/// </summary>
		PUBLIC PROPERTY LastException AS Exception GET _lastException
			
		/// <summary>
		/// Return the current TelloState
		/// </summary>
		PUBLIC PROPERTY State AS TelloState GET _state
			
		/// <summary>
		/// Create a Tello Object
		/// </summary>
		/// <param name="droneIP">The IP Address of the Tello Drone</param>
		PUBLIC CONSTRUCTOR(droneIP AS string )
			SELF:_state := TelloState{""}
			SELF:_messageQueue := Queue<string>{}
			SELF:_messageEvent := AutoResetEvent{ false}
			SELF:_client := TelloUdpClient{droneIP}
			SELF:_cancelRecvSource := CancellationTokenSource{}
			SELF:_cancelRecv := SELF:_cancelRecvSource:Token
			SELF:_messagePump := Task{RecvTask, SELF:_cancelRecv}
			SELF:_messagePump:Start()
			SELF:_pulseEvent := ManualResetEvent{false}
			
		/// <summary>
		/// Running task that will receive messages from the Drone
		/// </summary>
		PRIVATE METHOD RecvTask() AS void
			LOCAL response AS string
			//
			WHILE true
				TRY
					// Wait for a message
					response := SELF:_client:RecvMessage()
					IF response:StartsWith("mid")
						// Update Drone State
						BEGIN LOCK SELF:_state
							SELF:_state:State := response
						END LOCK
						LOOP
					ENDIF
					// Put the message in Queue
					BEGIN LOCK SELF:_messageQueue
						SELF:_messageQueue:Enqueue(response)
					END LOCK
					// And raise the flag, indicating we have a message
					SELF:_messageEvent:Set()
				CATCH e AS Exception
					// Mmmm Something went wrong
					Console.WriteLine(e:Message)
					EXIT
				END TRY
				// Should we stop ?
				IF SELF:_cancelRecv:IsCancellationRequested
					SELF:_cancelRecv:ThrowIfCancellationRequested()
				ENDIF
			END WHILE
			
#region Command Set
		/// <summary>
		/// Command response : Wake up the Tello
		/// </summary>
		/// <returns></returns>
		PUBLIC METHOD Command() AS Response
			LOCAL action AS TelloAction
			//
			action := TelloAction{SELF, "Command", "command", TelloAction.ActionTypes.Command}
			action:SendCommand()
			RETURN action:Response
			
		/// <summary>
		/// Auto TakeOff
		/// </summary>
		/// <returns></returns>
		PUBLIC METHOD TakeOff() AS Response
			LOCAL action AS TelloAction
			//
			action := TelloAction{SELF, "Auto takeoff", "takeoff", TelloAction.ActionTypes.Control}
			action:SendCommand(10000)
			IF action:Response == Response.OK
				SELF:StartPulse()
			ENDIF
			RETURN action:Response
			
		/// <summary>
		/// Land drone
		/// </summary>
		/// <returns></returns>
		PUBLIC METHOD Land() AS Response
			LOCAL action AS TelloAction
			//
			action := TelloAction{SELF, "Auto land", "land", TelloAction.ActionTypes.Control}
			action:SendCommand()
			SELF:StopPulse()
			RETURN action:Response
			
			
		PUBLIC METHOD Battery() AS string
			LOCAL action AS TelloAction
			//
			action := TelloAction{SELF, "Get current battery percentage", "battery?", TelloAction.ActionTypes.Read}
			action:SendCommand()
			RETURN action:ServerResponse:Trim('\r', '\n')
			
		/// <summary>
		/// Turn On Video Stream
		/// </summary>
		/// <returns></returns>	
		PUBLIC METHOD StreamOn() AS Response
			LOCAL action AS TelloAction
			//
			action := TelloAction{SELF, "Stream On", "streamon", TelloAction.ActionTypes.Command}
			action:SendCommand()
			RETURN action:Response
			
		/// <summary>
		/// Turn Off Video Stream
		/// </summary>
		/// <returns></returns>
		PUBLIC METHOD StreamOff() AS Response
			LOCAL action AS TelloAction
			//
			action := TelloAction{SELF, "Stream Off", "streamoff", TelloAction.ActionTypes.Command}
			action:SendCommand()
			RETURN action:Response
			
		/// <summary>
		/// Turn clockwise.
		/// </summary>
		/// <param name="degrees">Angle in degrees 1-360°</param>
		/// <returns></returns>
		PUBLIC METHOD TurnClockwise(degrees AS Long ) AS Response
			LOCAL action AS RotateClockwise
			//
			action := RotateClockwise{SELF, "Turn Clockwise", degrees}
			action:SendCommand()
			RETURN action:Response
			
			
		/// <summary>
		/// Turn Counter clockwise.
		/// </summary>
		/// <param name="degrees">Angle in degrees 1-360°</param>
		/// <returns></returns>
		PUBLIC METHOD TurnCounterClockwise(degrees AS Long ) AS Response
			LOCAL action AS RotateCounterClockwise
			//
			action := RotateCounterClockwise{SELF, "Turn CounterClockwise", degrees}
			action:SendCommand()
			RETURN action:Response
			
		/// <summary>
		/// Move Up
		/// </summary>
		/// <param name="distance">cm</param>
		/// <returns></returns>
		PUBLIC METHOD MoveUp(distance AS Long ) AS Response
			LOCAL action AS MoveUp
			//
			action := MoveUp{SELF, "Move Up", distance}
			action:SendCommand()
			RETURN action:Response
			
			
		/// <summary>
		/// Move Down
		/// </summary>
		/// <param name="distance"></param>
		/// <returns></returns>
		PUBLIC METHOD MoveDown(distance AS Long ) AS Response
			LOCAL action AS MoveDown
			//
			action := MoveDown{SELF, "Move Down", distance}
			action:SendCommand()
			RETURN action:Response
			
			
		/// <summary>
		/// Move Left
		/// </summary>
		/// <param name="distance">cm</param>
		/// <returns></returns>
		PUBLIC METHOD MoveLeft(distance AS Long ) AS Response
			LOCAL action AS MoveLeft
			//
			action := MoveLeft{SELF, "Move Left", distance}
			action:SendCommand()
			RETURN action:Response
			
		/// <summary>
		/// Move Right
		/// </summary>
		/// <param name="distance"></param>
		/// <returns></returns>
		PUBLIC METHOD MoveRight(distance AS Long ) AS Response
			LOCAL action AS MoveRight
			//
			action := MoveRight{SELF, "Move Right", distance}
			action:SendCommand()
			RETURN action:Response
			
		/// <summary>
		/// Move Forward
		/// </summary>
		/// <param name="distance"></param>
		/// <returns></returns>
		PUBLIC METHOD MoveForward(distance AS Long ) AS Response
			LOCAL action AS MoveForward
			//
			action := MoveForward{SELF, "Move Forward", distance}
			action:SendCommand()
			RETURN action:Response
			
			
		/// <summary>
		///  Move Backward
		/// </summary>
		/// <param name="distance"></param>
		/// <returns></returns>
		PUBLIC METHOD MoveBackward(distance AS Long ) AS Response
			LOCAL action AS MoveBackward
			//
			action := MoveBackward{SELF, "Move Backward", distance}
			action:SendCommand()
			RETURN action:Response
			
#endregion
			
		/// <summary>
		/// Send a TelloAction, using a TimeOut
		/// </summary>
		/// <param name="action"></param>
		/// <param name="waitTime"></param>
		/// <returns></returns>
		PUBLIC METHOD SendCommand(action AS TelloAction , waitTime AS TimeOut ) AS string
			RETURN SELF:SendCommand(action, (Long)waitTime)
			
		/// <summary>
		/// Send a TelloAction, using a TimeOut
		/// </summary>
		/// <param name="action"></param>
		/// <param name="waitTime"></param>
		/// <returns></returns>
		PUBLIC METHOD SendCommand(action AS TelloAction , waitTime AS Long ) AS string
			BEGIN LOCK SELF
				VAR response := ""
				TRY
					IF SELF:_client == null
						THROW Exception{"Client is null"}
					ENDIF
					IF SELF:_messageQueue:Count != 0
						BEGIN LOCK SELF:_messageQueue
							SELF:_messageQueue:Clear()
						END LOCK
					ENDIF
					// We MUST be in Command mode to send command, except the Command command ;)
					IF (action:ActionType != 0) .AND. (!SELF:CommandModeEnabled)
						// First, go to Command mode
						IF SELF:Command() != 0
							RETURN Response.FAIL:ToString()
						ENDIF
						SELF:_commandMode := true
					ENDIF
					//
					SELF:_client:SendAction(action)
					// Indicate that a message has been sent, no need for pulse
					SELF:_pulseEvent:Set()
					// Wait for a reply
					response := ""
					IF SELF:_messageEvent:WaitOne(waitTime)
						BEGIN LOCK SELF:_messageQueue
							response := SELF:_messageQueue:Dequeue()
						END LOCK
					ENDIF
					
				CATCH AS Exception
					IF action:ActionType == TelloAction.ActionTypes.Command
						//drone is probably already in command mode. Continue
						RETURN Response.OK:ToString()
					ENDIF
					//_lastException = ex;
					RETURN Response.FAIL:ToString()
				END TRY
				RETURN response
			END LOCK
			
		/// <summary>
		/// Dispose the Tello object
		/// </summary>
		PUBLIC METHOD Dispose() AS void
			SELF:_cancelRecvSource:Cancel()
			SELF:_client:Close()
			SELF:StopPulse()
			
#region Pulse Task
		/// <summary>
		/// Pulse Task
		/// Send empty Command to the drone, every Tello.TimeOut.Pulse ms if, in the meantime, no message has been sent.
		/// </summary>
		PRIVATE METHOD PulseTask() AS void
			WHILE true
				TRY
					IF !SELF:_pulseEvent:WaitOne(6000)
						// Send a Command to Keep Alive.
						SELF:Command()
					ENDIF
					SELF:_pulseEvent:Reset()
					
				CATCH e AS Exception
					Console.WriteLine(e:Message)
					EXIT
				END TRY
				IF SELF:_cancelPulse:IsCancellationRequested
					SELF:_cancelPulse:ThrowIfCancellationRequested()
				ENDIF
			END WHILE
			
		/// <summary>
		/// Start the Pulse Task, called when the TakeOff command is sent
		/// </summary>
		INTERNAL METHOD StartPulse() AS void
			IF (SELF:_pulseTello == null) .OR. (SELF:_pulseTello:Status != TaskStatus.Running)
				SELF:_cancelPulseSource := CancellationTokenSource{}
				SELF:_cancelPulse := SELF:_cancelPulseSource:Token
				SELF:_pulseTello := Task{PulseTask, SELF:_cancelPulse}
				SELF:_pulseTello:Start()
			ENDIF
			
		/// <summary>
		/// Stop the Pulse Task, called when Land command is sent
		/// </summary>
		INTERNAL METHOD StopPulse() AS void
			IF (SELF:_pulseTello != null) .AND. (SELF:_pulseTello:Status == TaskStatus.Running)
				SELF:_cancelPulseSource:Cancel()
			ENDIF
			
#endregion
	END CLASS
	
END NAMESPACE // TelloLibrary