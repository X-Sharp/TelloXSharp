// Program.prg
// Created by    : fabri
// Creation Date : 7/18/2023 5:51:39 PM
// Created for   : 
// WorkStation   : FABXPS

USING System
USING System.Collections.Generic
USING System.Linq
USING System.Text
USING TelloXSharp

FUNCTION Start() AS VOID STRICT
	VAR tello := MyTello{}
	tello:Start()