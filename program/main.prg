*!*	IF AppRun('glba.EXE') >1
*!*		MESSAGEBOX('Anda membuka program yang sama lebih dari 1 kali',16,'Informasi')
*!*	ELSE 
	DO FORM f_main
	READ EVENTS

*!*	ENDIF 

*!*	*-- Cek AppRun pada Processlist WindowManagement
*!*	FUNCTION AppRun(cFileRun)
*!*		oWMI = GetObject("winmgmts:\\.\root\cimv2")
*!*		oProcesses = oWMI.ExecQuery( 'Select * from Win32_Process' )
*!*		lAppRun = 0
*!*		For Each oProcess In oProcesses
*!*			IF UPPER(oProcess.Name) = UPPER(cFileRun)
*!*				lAppRun=lAppRun+1	
*!*			ENDIF 
*!*			IF lAppRun>1
*!*				EXIT
*!*			ENDIF 
*!*		Next
*!*		RETURN lAppRun
*!*	ENDFUNC 