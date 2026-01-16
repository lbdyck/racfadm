/* EDIT macro for VUECERTS */

Copyright = "Copyright 2025 Charles Mills Consulting, LLC"

/* ************************************************************************** */
/* ****                 Description                                      **** */
/* ************************************************************************** */

/*

VUECERTL is part of the Charles Mills Consulting, LLC product VUECERTS. It is
intended to be invoked from within a VUECERTS interactive VIEW.

To view the full RACDCERT LIST detail for any certificate displayed in the
report (including in diagnostic messages and the keyring section) position the
cursor on the line containing the certificate information and enter the
VUECERTL command.

The use of the VUECERTL command is facilitated by mapping the command to a
PF key.

*/

/* ************************************************************************** */
/* ****   Initialize variables that we use in Cleanup to prevent errors  **** */
/* ************************************************************************** */

Signal On  Syntax  name Sig_Recv
Signal On  Novalue name Sig_Recv

/* Initialize constants */
TRUE = 1
FALSE = 0

/* Initialize fields that we reference in Cleanup */
DD_List = ""
ID_List = ""

/* Initialize message codes */
Msg_Warn = "ISRZ001"   /* Yellow message */
Msg_Info = "ISRZ000"   /* White message */

/* *** Note requires, in addition to what VUECERTS requires:
PERMIT IRR.DIGTCERT.LIST CLASS(FACILITY) ID(GROUPCRP) ACCESS(CONTROL)
for all certificates
READ for your own
UPDATE for other personal
*/

/* ************************************************************************** */
/* ****      Sort out whether under ISPF and/or ISPF EDIT                **** */
/* ************************************************************************** */

  IsISPF = FALSE
  Options = Arg(1)
  If Sysvar("SYSISPF") = "ACTIVE" Then Do
    IsISPF = TRUE

    Call Addr_ISP "CONTROL ERRORS RETURN"   /* So errors are not fatal */

    /* Why do we need or want ISRDEDIT MACRO? */
    /* Because otherwise we can't read the screen */
    Address ISREDIT "MACRO"

    If RC <> 0 Then Do
      Call DispMag Msg_Info, "Reentered", ,
        "VUECERTL is not intended to be used from within BROWSE"
      /* Say "Error" RC "issuing ISREDIT MACRO" */
      ReturnCode = 16
      Signal Sig_EndPgm
      End   /* Not 0 */
    End              /* SYSISPF */
  Else Do
    Say "VUECERTL is intended only for use under ISPF VIEW"
    ReturnCode = 16
    Signal Sig_EndPgm
    End   /* Not ISPF */

/* Get cursor line data from screen */
/* Trace r */
Call Addr_ISP "ISREDIT (MYLINE, MYCOL) = CURSOR"
Call Addr_ISP "ISREDIT (USRLINE) = LINE &MYLINE"
Call Addr_ISP "VPUT (USRLINE)"
Call Addr_ISP "VGET (USRLINE)"

/* Get GSK database name
Call Addr_ISP "VGET (CMCGSKKB)"
   Say "CMCGSKKB =" CMCGSKKB */

/* parse it into userid and label */
Call ParseCertLine

Select
  When Item_Type = 1 Then Do  /* RACF Cert */
    ListCmd = "RACDCERT" Item_User "LIST (LABEL('"Item_Label"'))"
    Call IssueListCmd
    End   /* RACF Cert */

  When Item_Type = 2 Then Do   /* RACF Keyring */
    ListCmd = "RACDCERT" Item_User "LISTRING("Item_Label")"
    Call IssueListCmd
    End  /* RACF Keyring */

  When Item_Type = 3 Then Do    /* gskkyman cert */
    Call SYSCALLS "ON"
    If RC <> 0 Then Do
      Call DispMag Msg_Warn, "Syscalls error", ,
      "Syscalls returned RC" RC
      Signal Sig_EndPgm
      End
    ListCmd = 'gskkyman -dcv -l "'Item_Label'"' ,
      '-k "'CMCGSKKB'" -sth'
    Call BPXWUNIX ListCmd, , "ListOut."
    End  /* gskkyman cert */

  Otherwise
    Say "Unexpected Item_Type" Item_Type
    End

Call CreateListDS

/* Strip blanks -- otherwise lines are more than 80 long */
/* Could skip for gskkyman */
/* Some lines go to zero length but EXECIO does not seem to have a problem */
Do i = 1 to ListOut.0
  ListOut.i = Strip(ListOut.i, 'T')
  /* Say Length(ListOut.i) */
  End i

/* Set the title */
Title.1 = " "
If Length(ListCmd) > 80 Then ListCmd = Left(ListCmd, 77)"..."
Title.2 = Center(ListCmd, 80)
Title.3 = Copies('-', 80)

EXECIOreq = "EXECIO" 3 "DISKW" DD_List "(STEM Title. OPEN"
ADDRESS TSO EXECIOreq

/* Copy the trapped LIST output to the dataset */
EXECIOreq = "EXECIO" ListOut.0 "DISKW" DD_List "(STEM ListOut. FINIS"
ADDRESS TSO EXECIOreq

If RC <> 0 Then Do
  ReturnCode = RC
  Call DispMag Msg_Info, "EXECIO Error", ,
  "Unexpected return code" ReturnCode "from" EXECIOreq
  /* Say "Unexpected return code" ReturnCode "from" EXECIOreq */
  Signal Sig_EndPgm
  End  /* RC <> 0 */

/* Browse the output */
Call Addr_ISP "BROWSE DATAID("ID_List")"  /* PANEL(BROWSEP)"  */

/* All done! */
ReturnCode = 0
Signal Sig_EndPgm

/* ************************************************************************** */
/* ************************************************************************** */
/* ****      Mainline above this point; Subroutines below                **** */
/* ************************************************************************** */
/* ************************************************************************** */

/* ************************************************************************** */
/* ****           Addr_ISP: Issue Address ISPEXEC and check for errors   **** */
/* ************************************************************************** */

Addr_ISP:
  /* No return -- Ends the program on errors */
  req = Arg(1)
  Address ISPEXEC req
  RetCd = RC
  If RetCd <> 0 Then Do
    Trace O
    Say "Unexpected Return Code" RetCd "from Address ISPEXEC on line" ,
      SIGL":" req
    If RetCd > 8 Then Do
      Address ISPEXEC "SETMSG MSG(ISRZ002) COND"    /* Log first error */
      Address ISPEXEC "LOG MSG(ISRZ002)"
      End /* RetCd > 8 */
    ReturnCode = 12
    Signal Sig_EndPgm
    End  /* Bad Address ISPEXEC Return Code */

  Return

/* ************************************************************************** */
/* ****           DynReq: Issue BPXWDYN and check for errors             **** */
/* ************************************************************************** */

DynReq:
  /* No return -- Ends the program on errors */
  req = Arg(1)
  RetCd = BPXWDYN(req)
  If RetCd <> 0 Then Do
    Call DispMag Msg_Info, "BPXWDYN Error", ,
      "Unexpected Return Code" RetCd ,
      "("D2X(RetCD,8)") from BPXWDYN on line" SIGL":" req
    /* Say "Unexpected Return Code" RetCd ,
      "("D2X(RetCD,8)") from BPXWDYN on line" SIGL":" req */
    ReturnCode = 12
    Signal Sig_EndPgm
    End  /* Bad BPXWDYN Return Code */

  Return

Sig_Recv:
  Trace O
  SigType = Condition('C')
  If SigType = "SYNTAX" Then ,
    SigInfo = Errortext(RC)
  Else ,
    SigInfo = Condition('D')
  SigLine = Strip(Sourceline(SIGL))
  Say "Signal received:" SigType SigInfo "on line" SIGL
  Say SigLine

  ReturnCode = 16

  /* Fall through to Sig_EndPgm */

Sig_EndPgm:
  Call Cleanup
  Exit ReturnCode

/* ************************************************************************** */
/* ****  IssueListCmd: Issue the TSO command in ListCmd trapping output  **** */
/* ************************************************************************** */

IssueListCmd:
  Foo = OutTrap("ListOut.")
  ListCmd   /* "RACDCERT" LIST or LISTRING */
  Foo = OutTrap("OFF")

  Return

/* ************************************************************************** */
/* ****    CreateListDS: Create BROWSE Data Set and get DATAID for it    **** */
/* ************************************************************************** */

CreateListDS:
  Call DynReq "ALLOC RTDDN(DD_List) BLKSIZE(0) LRECL(80) ",
    "NEW DELETE RECFM(FB) TRACKS SPACE(1,1) UNIT(SYSALLDA) REUSE ",
    "DSORG(PS) RTDSN(DSNList)"
  Call Addr_ISP "LMINIT DATAID(ID_List) DDNAME("DD_List")"

  Return

/* ************************************************************************** */
/* ****  ParseCertLine: Parse Line from terminal into userid and label   **** */
/* ************************************************************************** */

/* Return Item_User, Item_Label, and Item_Type
   Item_Type is 0 = Unknown (no return), 1 = RACF Cert, 2 = RACF Ring,
   3 = gskkyman Cert */

ParseCertLine:
  /* Trace R */
  /* Parse USERLINE into Item_User and Item_Label */

  /* Say "Line:" USRLINE */

  /* See if it is a Keyring line */
  /* (1) JES2UID/FTP.Key.Ring */
   If Left(USRLINE, 2) = " (" Then Do
    Parse Var USRLINE . Item_User '/' Item_Label .
    Item_Type = 2  /* Keyring */
    End  /* Keyring line */

  /* Check for CMC0037I   CERTAUTH 'AAA AAA USERtrust' etc. */
  Else Do
    If Left(USRLINE, 5) = " CMC0" Then Do
      Parse Var USRLINE msgid Item_User "'" Item_Label "'"
      Item_Type = 1   /* RACF Cert */
      End  /* CMC0 message */
    Else Do  /* Check for regular Cert line */
      /* Say "First else" */
      Parse Var USRLINE Item_User "'" Item_Label "'"
      Item_User = Strip(Item_User)  /* Get rid of leading blanks */
      /* Say "Item_User" Item_User "Item_Label" Item_Label  */

      /* Check for a keyring cert line (B.) SYS06    'CMC Endpoint' CN = Cha
         or a line with a | on it */
      If Left(Item_User,1) = '(' | Item_User = '|' Then Do
        Parse Var USRLINE prefix Item_User "'" Item_Label "'"
        /* Say "prefix" pref1 "Item_User" Item_User "Item_Label" Item_Label */

        /* Check for got another | */
        If Item_User = '|' Then ,
          Parse Var USRLINE pref1 pref2 Item_User "'" Item_Label "'"

        /* Maybe we have to check for another | -- I don't know */
        If Item_User = '|' Then ,
          Parse Var USRLINE pref1 pref2 pref3 Item_User "'" Item_Label "'"

        End   /* End (B.) or | */

      Item_Type = 1   /* RACF Cert, probably */

      End   /* End of NOT the CMC0037I message */
    End  /* End of NOT a keyring line */

  /* Check for successful parse */
  /* Bad lines have no 'label' or junk as the first "word" */
  Item_User = Strip(Item_User)
  If Item_Label = "" | Length(Item_User) > 8 Then Do
    Call DispMag Msg_Warn, "Not a certifcate", ,
      "Cursor appears to be on a line that does not identify" ,
      "a certifcate or keyring. Line contents: '"Strip(USRLINE)"'"

    ReturnCode = 8
    Signal Sig_EndPgm
    End /* No label */

  Item_User = Strip(Item_User)  /* Get rid of leading blanks */

  If Item_User == "gskkyman" Then Do
    Item_Type = 3
    Return
    End  /* End gskkyman */

    /*
    Call DispMag Msg_Warn, "gskkyman", ,
      "RACF certificate LIST is not available for gskkyman" ,
      "key database certificates"

    ReturnCode = 8
    Signal Sig_EndPgm
    End
    */

  /* Say "Item_User <" C2X(Item_User) "> Item_Label" Item_Label  */

  If Item_User <> "CERTAUTH" & Item_User <> "SITE" Then ,
    Item_User = "ID("Item_User")"

  Return

/* ************************************************************************** */
/* ****           DispMag: Display an ISPF message                       **** */
/* ************************************************************************** */

DispMag:

  /* Arguments are a Msg_Xxxx code, a short message, and a long message */

  msg = Arg(1)        /* ISRZ000 or ISRZ001 */
  ZEDSMSG = Arg(2)    /* Short message */
  ZEDLMSG = Arg(3)    /* Long message  */

  Address ISPEXEC "SETMSG MSG("msg")"

  Return

/* ************************************************************************** */
/* ****           Cleanup: Silently unallocate everything                **** */
/* ************************************************************************** */

Cleanup:

  /* We might want to supporess all messages here but it seems we do
     not get any errors  */

  /* We use Address ISPEXEC directly rather than calling Addr_ISP because
     we do not care about errors and don't want to recurse Cleanup  */

  /* Foo = Msg("OFF") */    /* Suppress any messages */

  /* Only here if ISPF */
  If ID_List <> "" Then Address ISPEXEC "LMFREE DATAID("ID_List")"

  /* Clean up everything else unconditionally */
  If DD_List <> "" Then "FREE FI("DD_List")"

  Foo = Msg("ON")    /* Get messages back */

  Return

