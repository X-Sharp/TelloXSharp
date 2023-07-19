using System
using System.Collections.Generic
using System.ComponentModel
using System.Data
using System.Drawing

using System.Text

using System.Windows.Forms

USING System.Net
USING System.Net.Sockets
USING System.Threading
USING System.Threading.Tasks
USING System.Windows.Forms

begin namespace TelloFakeGUI
	
	public partial class MainWindow inherit System.Windows.Forms.Form
		
		PRIVATE _cancelMainTaskSource AS CancellationTokenSource
			
		PRIVATE _cancelMainTask AS CancellationToken
			
		PRIVATE _taskTello AS Task
			
		PRIVATE leTello AS Tello
			
		PRIVATE _cancelListenSource AS CancellationTokenSource
			
		PRIVATE _cancelListen AS CancellationToken
			
			
		PUBLIC CONSTRUCTOR()
			SELF:InitializeComponent()
			SELF:leTello := Tello{}
			
			
		PRIVATE METHOD buttonStart_Click(sender AS Object , e AS EventArgs ) AS void
			SELF:buttonStart:Visible := false
			SELF:buttonStop:Visible := true
			SELF:StartTello()
			
			
		PRIVATE METHOD buttonStop_Click(sender AS Object , e AS EventArgs ) AS void
			SELF:buttonStart:Visible := true
			SELF:buttonStop:Visible := false
			
			
		INTERNAL METHOD StartTello() AS void
			IF (SELF:_taskTello == null) .OR. (SELF:_taskTello:Status != TaskStatus.Running)
				SELF:_cancelMainTaskSource := CancellationTokenSource{}
				SELF:_cancelMainTask := SELF:_cancelMainTaskSource:Token
				SELF:_taskTello := Task{TelloTask, SELF:_cancelMainTask}
				SELF:_taskTello:Start()
			ENDIF
			
			
		PRIVATE ASYNC METHOD TelloTask() AS void
			LOCAL listener AS UdpClient
			LOCAL clientEP AS IPEndPoint
			LOCAL fini AS Logic
			LOCAL listenTask AS Task<UdpReceiveResult>
			LOCAL rawData AS Byte[]
			LOCAL command AS string
			LOCAL resp AS string
			//
			listener := UdpClient{SELF:leTello:ListeningPort}
			clientEP := IPEndPoint{IPAddress.Any, SELF:leTello:ListeningPort}
			TRY
				fini := false
				WHILE !fini
					SELF:_cancelListenSource := CancellationTokenSource{}
					SELF:_cancelListen := SELF:_cancelMainTaskSource:Token
					listenTask := listener:ReceiveAsync()
					listenTask:Wait(SELF:_cancelListen)
					IF !SELF:_cancelListen:IsCancellationRequested
						clientEP := listenTask:Result:RemoteEndPoint
						rawData := listenTask:Result:Buffer
						command := Encoding.ASCII:GetString(rawData, 0, rawData:Length)
						IF command:IndexOf("?") > -1
							resp := SELF:processReadCommand(command)
							SELF:SendMessage(listener, resp, clientEP)
						ELSE
							SELF:processCommand(command)
							SELF:SendMessage(listener, "OK", clientEP)
						ENDIF
					ELSE
						fini := true
					ENDIF
				END WHILE
				
			CATCH ex AS Exception
				SELF:WriteError(ex:ToString())
				SELF:SendMessage(listener, ex:Message, clientEP)
			END TRY
			listener:Close()
			
			
		PRIVATE METHOD processReadCommand(command AS string ) AS string
			SWITCH command
			case "speed?"
				return SELF:leTello:Speed:ToString()
			case "battery?"
				return SELF:leTello:Battery:ToString()
			case "time?"
				return "10"
			END SWITCH
			return string.Empty
			
			
			
		PRIVATE METHOD processCommand(command AS string ) AS void
			LOCAL cmdPart AS string[]
			//
			cmdPart := command:Split(' ')
			SELF:WriteTextMessage( "Received Command : " + command)
			//
			SWITCH cmdPart[1]
			CASE "command"
				SELF:WriteTextMessage( "Mode Command ON")
			CASE "takeoff"
				SELF:WriteTextMessage("Auto take off")
				SELF:leTello:IsFlying := true
				SELF:leTello:Altitude := 50
			CASE "forward"
				IF cmdPart:Length == 1
					SELF:WriteError("Missing Forward parameter.")
					RETURN
				ENDIF
				SELF:WriteTextMessage("Move : forward " + cmdPart[2])
				SELF:leTello:YPos += Int32.Parse(cmdPart[2])
			CASE "land"
				SELF:WriteTextMessage("Auto landing")
				SELF:leTello:IsFlying := false
				SELF:leTello:Altitude := 0
			CASE "down"
				IF cmdPart:Length == 1
					SELF:WriteError("Missing Down parameter.")
					RETURN
				ENDIF
				SELF:WriteTextMessage("Move : down " + cmdPart[2])
				SELF:leTello:Altitude -= Int32.Parse(cmdPart[2])
			CASE "left"
				IF cmdPart:Length == 1
					SELF:WriteError("Missing Left parameter.")
					RETURN
				ENDIF
				SELF:WriteTextMessage("Move : left " + cmdPart[2])
				SELF:leTello:XPos -= Int32.Parse(cmdPart[2])
			CASE "back"
				IF cmdPart:Length == 1
					SELF:WriteError("Missing Back parameter.")
					RETURN
				ENDIF
				SELF:WriteTextMessage("Move : back " + cmdPart[2])
				SELF:leTello:YPos -= Int32.Parse(cmdPart[2])
			CASE "flip"
				IF cmdPart:Length == 1
					SELF:WriteError("Cannot Flip, missing direction.")
				ELSE
					SELF:WriteTextMessage("Move : flip " + cmdPart[2])
				ENDIF
			CASE "up"
				IF cmdPart:Length == 1
					SELF:WriteError("Missing Up parameter.")
					RETURN
				ENDIF
				SELF:WriteTextMessage("Move : up " + cmdPart[2])
				SELF:leTello:Altitude += Int32.Parse(cmdPart[2])
			CASE "cw"
				IF cmdPart:Length == 1
					SELF:WriteError("Missing ClockWise parameter.")
				ELSE
					SELF:WriteTextMessage("Move : cw " + cmdPart[2])
				ENDIF
			CASE "right"
				IF cmdPart:Length == 1
					SELF:WriteError("Missing Right parameter.")
					RETURN
				ENDIF
				SELF:WriteTextMessage("Move : right " + cmdPart[2])
				SELF:leTello:XPos += Int32.Parse(cmdPart[2])
			CASE "speed"
				IF cmdPart:Length == 1
					SELF:WriteError("Cannot set Speed, missing value.")
					RETURN
				ENDIF
				SELF:leTello:Speed := Convert.ToInt32(cmdPart[2])
				SELF:WriteTextMessage( "Speed is " + cmdPart[2] + " cm/s")
			CASE "ccw"
				IF cmdPart:Length == 1
					SELF:WriteError("Missing CounterClockWise parameter.")
				ELSE
					SELF:WriteTextMessage("Move : ccw " + cmdPart[2])
				ENDIF
			END SWITCH
			SELF:UpdateTello()
			
			
		PRIVATE METHOD SendMessage(client AS UdpClient , message AS string , endpoint AS IPEndPoint ) AS void
			LOCAL msgData AS Byte[]
			//
			msgData := Encoding.ASCII:GetBytes(message)
			client:Connect(endpoint)
			client:Send(msgData, msgData:Length)
			
			
		PRIVATE METHOD WriteError(v AS string ) AS void
			LOCAL safeWrite AS Action
			//
			safeWrite := { =>
			SELF:WriteErrorSafe(v)
			}
			Invoke(safeWrite)
			
			
		PRIVATE METHOD WriteTextMessage(v AS string ) AS void
			LOCAL safeWrite AS Action
			//
			safeWrite := { =>
			SELF:WriteTextSafe(v)
			}
			Invoke(safeWrite)
			
			
		PRIVATE METHOD WriteErrorSafe(v AS string ) AS void
			SELF:statusLabel:ForeColor := Color.Red
			SELF:statusLabel:Text := v
			
			
		PRIVATE METHOD WriteTextSafe(v AS string ) AS void
			SELF:textMessages:AppendText(v + Environment.NewLine)
			
			
		PRIVATE METHOD UpdateTello() AS void
			LOCAL safeWrite AS Action
			//
			safeWrite := { =>
			SELF:UpdateTelloSafe()
			}
			Invoke(safeWrite)
			
			
		PRIVATE METHOD UpdateTelloSafe() AS void
			LOCAL sb AS StringBuilder
			//
			IF SELF:leTello:IsFlying
				SELF:pictureAlt:Location := Point{17, 0}
			ELSE
				SELF:pictureAlt:Location := Point{17, SELF:panel2:Height - SELF:pictureAlt:Height - 5}
			ENDIF
			sb := StringBuilder{}
			sb:AppendLine("Etat du Tello")
			sb:AppendLine(" Alt. : " + SELF:leTello:Altitude:ToString())
			sb:AppendLine(" Speed : " + SELF:leTello:Speed:ToString())
			sb:AppendLine("Position")
			sb:AppendLine(" X : " + SELF:leTello:XPos:ToString())
			sb:AppendLine(" Y : " + SELF:leTello:YPos:ToString())
			SELF:labelInfo:Text := sb:ToString()
			
			
			
	END CLASS
	
end namespace
