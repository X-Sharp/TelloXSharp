// TelloUdp.prg
// Created by    : fabri
// Creation Date : 7/17/2023 7:29:07 PM
// Created for   : 
// WorkStation   : FABXPS


USING System
USING System.Collections.Generic
USING System.Text
USING System.Net
USING System.Net.Sockets
USING System.Text
USING TelloLibrary

BEGIN NAMESPACE TelloLibrary
	
	/// <summary>
	/// The TelloUdp class.
	/// </summary>
	INTERNAL CLASS TelloUdpClient
		PRIVATE _udpClient AS UdpClient
			
		PRIVATE _droneEndpoint AS IPEndPoint
			
		PUBLIC PROPERTY Host AS string GET _droneEndpoint:Address:ToString()
		
		PRIVATE CONSTRUCTOR(droneEndpoint AS IPEndPoint )
			LOCAL localEndPoint AS IPEndPoint
			//
			localEndPoint := IPEndPoint{IPAddress.Any, 8890}
			SELF:_udpClient := UdpClient{localEndPoint}
			SELF:_udpClient:Connect(droneEndpoint)
			SELF:_droneEndpoint := droneEndpoint
			
		/// <summary>
		/// Create a UDPClient to use with Tello
		/// </summary>
		/// <param name="droneIP">The IPAddress of the Drone</param>
		PUBLIC CONSTRUCTOR(droneIP AS string )
			SELF(IPEndPoint{IPAddress.Parse(droneIP), 8889})
			
			
		INTERNAL METHOD SendMessage(action AS TelloAction ) AS void
			LOCAL data AS Byte[]
			//
			IF SELF:_udpClient == null
				THROW Exception{"UdpClient is Null"}
			ENDIF
			data := Encoding.UTF8:GetBytes(action:Command:ToLower())
			SELF:_udpClient:Send(data, data:Length)
			
			
		INTERNAL METHOD RecvMessage() AS string
			LOCAL remoteIpEndPoint AS IPEndPoint
			LOCAL receiveBytes AS Byte[]
			//
			remoteIpEndPoint := null
			receiveBytes := SELF:_udpClient:Receive(REF remoteIpEndPoint)
			RETURN Encoding.UTF8:GetString(receiveBytes)
			
			
		PUBLIC METHOD Close() AS void
			SELF:_udpClient:Close()
			SELF:_udpClient:Dispose()
			
			
	END CLASS
	
END NAMESPACE // TelloLibrary