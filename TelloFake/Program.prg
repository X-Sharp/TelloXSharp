// Program.prg
// Created by    : fabri
// Creation Date : 7/18/2023 4:53:05 PM
// Created for   : 
// WorkStation   : FABXPS

USING System
USING System.Collections.Generic
USING System.Linq
USING TelloFake


FUNCTION Start() AS VOID STRICT
    Console.WriteLine("My Fake Tello Application")
    //
	VAR fake := MyFakeTello{}
	fake:Start()
	//

