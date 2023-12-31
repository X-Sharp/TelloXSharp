# TelloLibrary

X# Library to ease the use the communication with DJI Tello, with at least SDK 2.0  
_**Documentation**_ :  
 https://dl-cdn.ryzerobotics.com/downloads/Tello/Tello%20SDK%202.0%20User%20Guide.pdf

#### Usage
1. Create a Tello Object, indicating it's IP Address
2. Send commands and get replies
3. If you send **TakeOff**, a background Thread will run and send a Pulse to the Drone in order to keep the connection alive.
4. If you send **Land**, the background Thread is closed

# SimpleTello

Raw-mode Console App to send command to the TELLO.  
Does not use the TelloLibrary (Pure UDP exchanges), without the Pulse (Keep-Alive) Task.

# TelloXSharp

Simple console app that can get the video stream using the OpenCV Library

# TelloFake

Fake-Drone console app : It will emulate the drone (except the need for the KeepAlive signal), and print received commands
