How can I add a TIMEOUT clause to the MESSAGEBOX function?

If you want to use a TIMEOUT clause with the MESSAGEBOX function, try the following:-

Create a new class based on the timer class and call it tmrMsgBox

Set .Enabled = .F. and .Interval = 2500

Add a new property called .Key and a new method called .KeyToPress().

In the .KeyToPress() event put:-

LPARAMETERS lcKey, lnInterval

WITH THIS
    IF EMPTY(lcKey)
        .Enabled = .F.
    ELSE
        .Key = lcKey
        .Enabled = .T.
    ENDIF    
    IF !EMPTY(lnInterval) AND VAL(lnInterval) # 0
        .Interval = VAL(lnInterval) * 1000
    ENDI    
ENDW


In the .Timer() event put:-

WITH THIS
    DO CASE
    CASE .Key = "O"
        KEYBOARD CHR(13)
    CASE .Key = "C"
        KEYBOARD CHR(27)
    CASE .Key = "A"
        KEYBOARD CHR(65)
    CASE .Key = "R"
        KEYBOARD CHR(82)
    CASE .Key = "I"
        KEYBOARD CHR(73)
    CASE .Key = "Y"
        KEYBOARD CHR(89)
    CASE .Key = "N"
        KEYBOARD CHR(78)
    ENDC
    .Key         = .F.
    .Interval     = 2500
    .Enabled    = .F.
ENDW
        

Save the class and drop it on a form.

Add the following code immediately before and after MESSAGEBOX...

THISFORM.tmrMsgBox.KeyToPress("O")
MESSAGEBOX("This is to test if this thing works!",;
    0 + 64 + 0 ,;
    "Keypress test")
THISFORM.tmrMsgBox.KeyToPress()



The following character in () represents the choice of first parameter to pass to tmrMsgBox, and should correspond to the first value in the second parameter passed to MESSAGEBOX().

0 + 64 + 0 -> (O)K button only 
1 + 64 + 0 -> (O)K and (C)ancel buttons 
2 + 64 + 0 -> (A)bort, (R)etry, and (I)gnore buttons 
3 + 64 + 0 -> (Y)es, (N)o, and (C)ancel buttons 
4 + 64 + 0 -> (Y)es and (N)o buttons 
5 + 64 + 0 -> (R)etry and (C)ancel buttons 

The second optional parameter is "n", (seconds interval, default = 2.5 seconds), 
eg THISFORM.tmrMsgBox.KeyToPress("Y","4")

IF the user does not keypress/click within the default/developer designated time,
tmrMsgBox.Timer() will KEYBOARD CHR(n) and close the messagebox with normal return values.
 

 
