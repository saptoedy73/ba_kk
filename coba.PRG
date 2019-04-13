**********************************************************************************
*... FTPGet.PRG ...*

PARAMETERS lcHost, lcUser, lcPwd, lcRemoteFile, lcNewFile, lnXFerType     

*.................................................................................
*:   Usage: DO ftpget WITH ;
*:         'ftp.host', 'name', 'password', 'source.file', 'target.file'[, 1 | 2]
*:
*:  Where:  lcHost       = Host computer IP address or name
*:          lcUser       = user name - anonymous may be used
*:          lcPwd        = password
*:          lcRemoteFile = source file name
*:          lcNewFile    = target file name
*:          lnXFerType   = 1 (default) for ascii, 2 for binary
*.................................................................................

*...set up API calls
DECLARE INTEGER InternetOpen IN wininet;
   STRING sAgent, INTEGER lAccessType, STRING sProxyName,;
   STRING sProxyBypass, STRING  lFlags

DECLARE INTEGER InternetCloseHandle IN wininet INTEGER hInet

DECLARE INTEGER InternetConnect IN wininet.DLL;
   INTEGER hInternetSession,;
   STRING  lcHost,;
   INTEGER nServerPort,;
   STRING  lcUser,;
   STRING  lcPassword,;
   INTEGER lService,;
   INTEGER lFlags,;
   INTEGER lContext

DECLARE INTEGER FtpGetFile IN wininet;
   INTEGER hftpSession, ;
   STRING  lcRemoteFile,;
   STRING  lcNewFile, ;
   INTEGER fFailIfExists,;
   INTEGER dwFlagsAndAttributes,;
   INTEGER dwFlags, ;
   INTEGER dwContext

lcHost       = ALLTRIM(lcHost) 
lcUser       = ALLTRIM(lcUser)
lcPwd        = ALLTRIM(lcPwd)
lcRemoteFile = ALLTRIM(lcRemoteFile)
lcNewFile    = ALLTRIM(lcNewFile)

sAgent = "vfp"

sProxyName = CHR(0)     &&... no proxy
sProxyBypass = CHR(0)   &&... nothing to bypass
lFlags = 0              &&... no flags used

*... initialize access to Inet functions
hOpen = InternetOpen (sAgent, 1,;
   sProxyName, sProxyBypass, lFlags)

IF hOpen = 0
   WAIT WINDOW  "Unable to get access to WinInet.Dll" TIMEOUT 2
   RETURN
ENDIF

*... The first '0' says use the default port, usually 21.
hftpSession = InternetConnect (hOpen, lcHost,;
   0, lcUser, lcPwd, 1, 0, 0)   &&... 1 = ftp protocol

IF hftpSession = 0
   *... close access to Inet functions and exit
   = InternetCloseHandle (hOpen)
   WAIT WINDOW "Unable to connect to " + lcHost + '.' TIMEOUT 2
   RETURN
ELSE
   WAIT WINDOW "Connected to " + lcHost + " as: [" + lcUser + "]"  TIMEOUT 1
ENDIF

*... 0 to automatically overwrite file
*... 1 to fail if file already exists
fFailIfExists  = 0  
dwContext      = 0  &&... used for callback

WAIT WINDOW 'Transferring ' + lcRemoteFile + ' to ' + lcNewFile + '...' NOWAIT 
lnResult = FtpGetFile (hftpSession, lcRemoteFile, lcNewFile,;
   fFailIfExists, 128, lnXFerType,;
   dwContext)

*... 128 = #define FILE_ATTRIBUTE_NORMAL     0x00000080 
*... See CreateFile for other attributes

* close handles
= InternetCloseHandle (hftpSession)
= InternetCloseHandle (hOpen)

IF lnResult = 1
   *... successful download, do what you want here
   WAIT WINDOW 'Completed.' TIMEOUT 1
   MODI FILE (lcNewFile)
ELSE
   WAIT WINDOW  "Unable to download selected file" TIMEOUT 2
ENDIF

RETURN
*** End of ftpGet.PRG *************************************************************


**********************************************************************************
*... FTPPut.PRG ...*

PARAMETERS lcHost, lcUser, lcPassword, lcSource, lcTarget, lnXFerType

*.................................................................................
*:   Usage: DO ftpput WITH ;
*:         'ftp.host', 'name', 'password', 'source.file', 'target.file'[, 1 | 2]
*:
*:  Where:  lcHost     = Host computer IP address or name
*:          lcUser     = user name - anonymous may be used
*:          lcPassword = password
*:          lcSource   = source file name (remote)
*:          lcTarget   = target file name (local)
*:          lnXFerType = 1 (default) for ascii, 2 for binary
*.................................................................................

DECLARE INTEGER InternetOpen IN wininet.DLL;
   STRING  sAgent,;
   INTEGER lAccessType,;
   STRING  sProxyName,;
   STRING  sProxyBypass,;
   STRING  lFlags

DECLARE INTEGER InternetCloseHandle IN wininet.DLL INTEGER hInet

DECLARE INTEGER InternetConnect IN wininet.DLL;
   INTEGER hInternetSession,;
   STRING  lcHost,;
   INTEGER nServerPort,;
   STRING  lcUser,;
   STRING  lcPassword,;
   INTEGER lService,;
   INTEGER lFlags,;
   INTEGER lContext

DECLARE INTEGER FtpPutFile IN wininet.DLL;
   INTEGER hConnect,;
   STRING  lpszLocalFile,;
   STRING  lpszNewRemoteFile,;
   INTEGER dwFlags,;
   INTEGER dwContext

PUBLIC hOpen, hftpSession

lcHost     = ALLTRIM(lcHost) 
lcUser     = ALLTRIM(lcUser) 
lcPassword = ALLTRIM(lcPassword) 
lcSource   = ALLTRIM(lcSource)
lcTarget   = ALLTRIM(lcTarget)

IF connect2ftp (lcHost, lcUser, lcPassword)
   WAIT WINDOW 'Transferring....' NOWAIT
   IF FtpPutFile(hftpSession, lcSource,;
         lcTarget, lnXFerType, 0) = 1
      WAIT WINDOW lcSource + ' transferred.' TIMEOUT 2
   ENDIF

   = InternetCloseHandle (hftpSession)
   = InternetCloseHandle (hOpen)
ENDIF

*..................... connect2ftp .........................................
*...  Makes sure there is actually a valid connection to the host
FUNCTION  connect2ftp (lcHost, lcUser, lcPassword)   
   * open access to Inet functions    
   hOpen = InternetOpen ("vfp", 1, 0, 0, 0)    

   IF hOpen = 0    
      ? "Unable to get access to WinInet.Dll"   
      RETURN .F.   
   ENDIF   

   *... The first '0' says use the default port, usually 21.
   hftpSession = InternetConnect (hOpen, lcHost,;
      0, lcUser, lcPassword, 1, 0, 0)   &&... 1 = ftp protocol

   IF hftpSession = 0    
   * close access to Inet functions and exit    
      = InternetCloseHandle (hOpen)    
      ? "ftp " + lcHost + " is not available"   
      RETURN .F.   
   ELSE    
      ? "Connected to " + lcHost
   ENDIF    
RETURN .T.   
RETURN
*** End of ftpPut.PRG *************************************************************


Now if you want to delete the remote file after downloading it,
you can use FtpDelete.PRG:

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