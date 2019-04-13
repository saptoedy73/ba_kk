*AddPrinterFormClass.prg
DEFINE CLASS AddPrinterForm AS Custom

HIDDEN cUnit, cPrinterName, nFormHeight, nFormWidth, nLeftMargin, ;
nTopMargin, nRightMargin, nBottomMargin, ;
nInch2mm, nCm2mm, nCoefficient, hHeap

cUnit = "English" && inches or Metric - cm's
cPrinterName = ""
nFormHeight = 0
nFormWidth = 0
nLeftMargin = 0
nTopMargin = 0
nRightMargin = 0
nBottomMargin = 0

nApiErrorCode = 0
cApiErrorMessage = ""
cErrorMessage = ""

nInch2mm = 25.4
nCm2mm = 10
nCoefficient = 0

hHeap = 0

PROCEDURE Init(tcUnit)
IF PCOUNT() = 1 AND INLIST(tcUnit, "English", "Metric")
This.cUnit = PROPER(tcUnit)
ENDIF
This.LoadApiDlls()
This.hHeap = HeapCreate(0, 4096, 0)
* Use Windows default printer
This.cPrinterName = SET("Printer",2)
This.nCoefficient = IIF(PROPER(This.cUnit) = "English", ;
This.nInch2mm, This.nCm2mm) * 1000
ENDPROC

PROCEDURE Destroy
IF This.hHeap <> 0
HeapDestroy(This.hHeap)
ENDIF

ENDPROC

PROCEDURE SetFormMargins(tnLeft, tnTop, tnRight, tnBottom)
WITH This
.nLeftMargin = tnLeft * .nCoefficient
.nTopMargin = tnTop * .nCoefficient
.nRightMargin = tnRight * .nCoefficient
.nBottomMargin = tnBottom * .nCoefficient
ENDWITH
ENDPROC

PROCEDURE AddForm(tcFormName, tnWidth, tnHeight, tcPrinterName)
LOCAL lhPrinter, llSuccess, lcForm

This.nFormWidth = tnWidth * This.nCoefficient
This.nFormHeight = tnHeight * This.nCoefficient
IF PCOUNT() > 3
This.cPrinterName = tcPrinterName
ENDIF

This.ClearErrors()
lhPrinter = 0
IF OpenPrinter(This.cPrinterName, @lhPrinter, 0) = 0
This.cErrorMessage = "Unable to get printer handle for '" ;
+ This.cPrinterName + "."
This.nApiErrorCode = GetLastError()
This.cApiErrorMessage = This.ApiErrorText(This.nApiErrorCode)
RETURN .F.
ENDIF

lnFormName = HeapAlloc(This.hHeap, 0, LEN(tcFormName) + 1)
= SYS(2600, lnFormName, LEN(tcFormName) + 1, tcFormName + CHR(0))

* Build FORM_INFO_1 structure
WITH This
lcForm = This.Num2LOng(0) + ; && Flags
This.Num2LOng(lnFormName) + ;
This.Num2LOng(.nFormWidth) + ;
This.Num2LOng(.nFormHeight) + ;
This.Num2LOng(.nLeftMargin) + ;
This.Num2LOng(.nTopMargin) + ;
This.Num2LOng(.nFormWidth - .nRightMargin) + ;
This.Num2LOng(.nFormHeight - .nBottomMargin)
ENDWITH

* Finally, call the API
IF AddForm(lhPrinter, 1, @lcForm) = 0
This.cErrorMessage = "Unable to Add Form '" + tcFormName + "'."
This.nApiErrorCode = GetLastError()
This.cApiErrorMessage = This.ApiErrorText(This.nApiErrorCode)
llSuccess = .F.
ELSE
llSuccess = .T.
ENDIF
= HeapFree(This.hHeap, 0, lnFormName)
= ClosePrinter(lhPrinter)

RETURN llSuccess

PROCEDURE ClearErrors
This.cErrorMessage = ""
This.nApiErrorCode = 0
This.cApiErrorMessage = ""
ENDPROC

PROCEDURE DeleteForm(tcFormName, tcPrinterName)
LOCAL lhPrinter, llSuccess

IF PCOUNT() > 1
This.cPrinterName = tcPrinterName
ENDIF

This.ClearErrors()
lhPrinter = 0
IF OpenPrinter(This.cPrinterName, @lhPrinter, 0) = 0
This.cErrorMessage = "Unable to get printer handle for '" + This.cPrinterName + "."
This.nApiErrorCode = GetLastError()
This.cApiErrorMessage = This.ApiErrorText(This.nApiErrorCode)
RETURN .F.
ENDIF

* Finally, call the API
IF DeleteForm(lhPrinter, tcFormName) = 0
This.cErrorMessage = "Unable to delete Form '" + tcFormName + "'."
This.nApiErrorCode = GetLastError()
This.cApiErrorMessage = This.ApiErrorText(This.nApiErrorCode)
llSuccess = .F.
ELSE
llSuccess = .T.
ENDIF
= ClosePrinter(lhPrinter)
RETURN llSuccess

FUNCTION Num2LOng(tnNum)
DECLARE RtlMoveMemory IN WIN32API AS RtlCopyLong ;
STRING @Dest, Long @Source, Long Length
LOCAL lcString
lcString = SPACE(4)
=RtlCopyLong(@lcString, BITOR(tnNum,0), 4)
RETURN lcString
ENDFUNC

FUNCTION Long2Num(tcLong)
DECLARE RtlMoveMemory IN WIN32API AS RtlCopyNum ;
Long @Dest, String @Source, Long Length
LOCAL lnNum
lnNum = 0
= RtlCopyNum(@lnNum, tcLong, 4)
RETURN lnNum
ENDFUNC

HIDDEN PROCEDURE ApiErrorText
LPARAMETERS tnErrorCode
Local lcErrBuffer
lcErrBuffer = REPL(CHR(0),1024)
= FormatMessage(0x1000 ,.NULL., tnErrorCode, 0, @lcErrBuffer, 1024,0)
RETURN STRTRAN(LEFT(lcErrBuffer, AT(CHR(0),lcErrBuffer)- 1 ), ;
"file", "form", -1, -1, 3)

ENDPROC

HIDDEN PROCEDURE LoadApiDlls
DECLARE INTEGER OpenPrinter IN winspool.drv;
STRING pPrinterName,;
INTEGER @phPrinter,;
INTEGER pDefault
DECLARE INTEGER ClosePrinter IN winspool.drv;
INTEGER hPrinter
DECLARE INTEGER AddForm IN winspool.drv;
INTEGER hPrinter,;
INTEGER LEVEL,;
STRING @pForm
DECLARE INTEGER DeleteForm IN winspool.drv;
INTEGER hPrinter,;
STRING pFormName
DECLARE INTEGER HeapCreate IN Win32API;
INTEGER dwOptions, INTEGER dwInitialSize,;
INTEGER dwMaxSize
DECLARE INTEGER HeapAlloc IN Win32API;
INTEGER hHeap, INTEGER dwFlags, INTEGER dwBytes
DECLARE lstrcpy IN Win32API;
STRING @lpstring1, INTEGER lpstring2
DECLARE INTEGER HeapFree IN Win32API;
INTEGER hHeap, INTEGER dwFlags, INTEGER lpMem
DECLARE HeapDestroy IN Win32API;
INTEGER hHeap
DECLARE INTEGER GetLastError IN kernel32
Declare Integer FormatMessage In kernel32.dll ;
Integer dwFlags, String @lpSource, ;
Integer dwMessageId, Integer dwLanguageId, ;
String @lpBuffer, Integer nSize, Integer Arguments

ENDPROC

ENDDEFINE
*******************************************

*ooo = NEWOBJECT("AddPrinterForm", "AddPrinterFormClass.fxp")
*IF NOT ooo.AddForm("GiriJayaComputer01", 10,5.5, "EPSON LX-300+")
*? ooo.cErrorMessage
*? ooo.cApiErrorMessage
* Error
*ENDIF
*ooo = Null
*******************************************