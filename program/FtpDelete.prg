**********************************************************************************
*... FtpDelete.PRG ...*

PARAMETERS lcHost, lcUser, lcPwd, lcRemoteFile

*.................................................................................
*:   Usage: DO ftpdelete WITH ;
*:         'ftpserver.host', 'name', 'password', 'delete.file'
*:
*:  Where:  lcHost       = Host computer IP address or name
*:          lcUser       = user name - anonymous may be used
*:          lcPwd        = password
*:          lcRemoteFile = file to delete
*.................................................................................

*...set up API calls
PUBLIC hOpen, hftpSession
DECLARE INTEGER InternetOpen IN wininet.DLL;
   STRING  sAgent,;
   INTEGER lAccessType,;
   STRING  sProxyName,;
   STRING  sProxyBypass,;
   STRING  lFlags

DECLARE INTEGER InternetCloseHandle IN wininet.DLL INTEGER hInet

DECLARE INTEGER InternetConnect IN wininet.DLL;
   INTEGER hInternetSession,;
   STRING  sServerName,;
   INTEGER nServerPort,;
   STRING  sUsername,;
   STRING  sPassword,;
   INTEGER lService,;
   INTEGER lFlags,;
   INTEGER lContext

DECLARE INTEGER FtpDeleteFile IN wininet.DLL;
   INTEGER hConnect,;
   STRING  lpszFileName

*... open access to Inet functions
hOpen = InternetOpen ("vfp", 1, 0, 0, 0)

IF hOpen = 0
   ? "Unable to get access to WinInet.Dll"
   RETURN .F.
ENDIF

*... connect to ftp host
hftpSession = InternetConnect (hOpen, lcHost, 0,;
   lcUser, lcPwd, 1, 0, 0)

IF hftpSession = 0
   * close access to Inet functions and exit
   = InternetCloseHandle (hOpen)
   WAIT WINDOW "ftp " + strHost + " is not available"  TIMEOUT 2
ELSE
   WAIT WINDOW "Connected to " + lcHost + " as: [" + lcUser + "]"  NOWAIT
   IF FtpDeleteFile(hftpSession, lcRemoteFile) = 1
      WAIT WINDOW lcRemoteFile + ' deleted.' TIMEOUT 1
   ELSE
      WAIT WINDOW 'Error deleting ' + lcRemoteFile + "." TIMEOUT 1
   ENDIF
ENDIF
= InternetCloseHandle (hftpSession)
= InternetCloseHandle (hOpen)
*** End of ftpDelete.PRG *************************************************************