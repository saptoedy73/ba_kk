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