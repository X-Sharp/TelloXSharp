// Program.prg
// Created by    : fabri
// Creation Date : 10/10/2023 4:16:49 PM
// Created for   :
// WorkStation   : FABXPS

USING System
USING System.Collections.Generic
USING System.Linq
USING System.Text

USING TelloScript

FUNCTION Start() AS VOID STRICT
	VAR tello := MyTello{}
	tello:Start()