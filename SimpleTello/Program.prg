// Program.prg
// Created by    : fabri
// Creation Date : 7/18/2023 5:59:09 PM
// Created for   : 
// WorkStation   : FABXPS

USING System
USING System.Collections.Generic
USING System.Linq
USING System.Text
USING SimpleTello

FUNCTION Start() AS VOID STRICT
	Console.WriteLine("Simple Tello Test App")
	//
	VAR tello := SimpleTello{}
	tello:Start()
