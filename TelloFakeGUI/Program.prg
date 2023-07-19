USING System
USING System.Collections.Generic
USING System.Linq
USING System.Text
USING System.Windows.Forms

USING TelloFakeGUI

[STAThread] ;
FUNCTION Start() AS VOID

Application.EnableVisualStyles()
Application.SetCompatibleTextRenderingDefault( FALSE )
Application.Run( MainWindow{} )

RETURN
