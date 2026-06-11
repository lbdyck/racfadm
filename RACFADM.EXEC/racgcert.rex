/*%NOCOMMENT====================* REXX *==============================*/
/*PURPOSE:  RACFADM - Digital Certificates, Option GC, GETCERTS       */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @A4  260610  TRIDJK   Added Q (Genreq) line command                */
/* @A3  260609  TRIDJK   Added ADDCERT and GENCERT primary commands   */
/* @A2  260518  TRIDJK   Added CERTDETL function                      */
/* @A1  260501  TRIDJK   Added CERTSUMM and RINGSUMM functions        */
/* @A0  260424  TRIDJK   Created REXX, Charles Mills GETCERTS rexx    */
/*====================================================================*/
PANELD1     = "RACFDISP"   /* Display report with colors   */
PANEL27     = "RACGCERT"   /* List labels                  */
PANEL28     = "RACFCERO"   /* Add certificate (_Owner)     */
PANEL29     = "RACFCERG"   /* Generate certificate         */
PANELM2     = "RACFMSG2"   /* Display RACF command and RC  */
PANELS1     = "RACFSAVE"   /* Obtain DSName to SAVE        */
PANELGR     = "RACFGREQ"   /* Generate Request DSN prompt  */
PANELXP     = "RACFEXPE"   /* Export DSN prompt            */
PANELCK     = "RACFCHK"    /* Check DSN prompt             */
SKELETON1   = "RACGCERT"   /* Save tablea to dataset       */
SKELETO1A   = "RACGCER2"   /* Save tablea to dataset       */
EDITMACR    = "RACFEMAC"   /* Edit Macro, turn HILITE off  */
TABLEA      = 'TA'RANDOM(0,99999)  /* Unique table name A  */
DDNAME      = 'RACFA'RANDOM(0,999) /* Unique ddname        */
parse source . . REXXPGM .         /* Obtain REXX pgm name */
REXXPGM     = LEFT(REXXPGM,8)
NULL        = ''
GCRINGS     = 0

ADDRESS ISPEXEC
  "CONTROL ERRORS RETURN"
  "VGET (SETGDISP SETMADMN SETMSHOW SETMTRAC) PROFILE"

  If (SETMTRAC <> 'NO') then do
     Say "*"COPIES("-",70)"*"
     Say "*"Center("Begin Program = "REXXPGM,70)"*"
     Say "*"COPIES("-",70)"*"
     if (SETMTRAC <> 'PROGRAMS') THEN
        interpret "Trace "SUBSTR(SETMTRAC,1,1)
  end

  if (SETMADMN = "YES") then do
    SELCMDS = "ÝS¨ShowÝX¨ExportÝH¨Chain"||,
                  "ÝD¨DeleteÝM¨MapÝR¨Ring"
    SELCMD2 = "ÝL¨ListÝQ¨Genreq"
    end
  else do
    SELCMDS = "ÝS¨ShowÝX¨ExportÝH¨Chain"
    SELCMD2 = "ÝL¨List"
    end
  call Select_label
  rc = display_table()
  "TBEND" TABLEA

  If (SETMTRAC <> 'NO') then do
     Say "*"COPIES("-",70)"*"
     Say "*"Center("End Program = "REXXPGM,70)"*"
     Say "*"COPIES("-",70)"*"
  end
Exit:
  Call 'EZSUBCOM' 'DELETE', 'GETCERTS'
  retcode = RESULT
  zerrsm = "RACFADM EZSUBCOM"
  zerrlm = "EZSUBCOM DELETE RC =" retcode
  Address ISPexec'log msg(isrz003)'
EXIT
/*--------------------------------------------------------------------*/
/*  Select label                                                      */
/*--------------------------------------------------------------------*/
SELECT_LABEL:
  "TBCREATE" TABLEA "KEYS(LABEL)",
                   "NAMES(CERNUM",
                         "CERTUSER",
                         "NOTBEF",
                         "NOTAFT",
                         "ISSUER",
                         "CERTDADD",
                         "CERTUADD",
                         "KEYALGO",
                         "KEYLEN",
                         "KEYTYPE",
                         "CAUSAGE",
                         "PRIVKEY",
                         "SELFSIGN",
                         "TRUST",
                         "SIGALGO",
                         "SUBJECT) REPLACE NOWRITE"
  Call Get_Cert_Labels

  sort     = 'LABEL,C,A'
  CLRLABE = "TURQ" ; CLRCERN = "GREEN"; CLRCERT = "GREEN"
  CLRNOTB = "GREEN"; CLRNOTA = "GREEN"; CLRISSU = "GREEN"
  CLRDADD = "GREEN"; CLRUADD = "GREEN"; CLRKEYA = "GREEN"
  CLRKEYL = "GREEN"; CLRCAUS = "GREEN"; CLRPRIV = "GREEN"
  CLRSELF = "GREEN"; CLRTRUS = "GREEN"; CLRSIGA = "GREEN"
  CLRSUBJ = "GREEN"; CLRKEYA = "GREEN"
  "TBSORT " TABLEA "FIELDS("sort")"
  "TBTOP  " TABLEA
RETURN
/*--------------------------------------------------------------------*/
/*  Display digital certificate labels                                */
/*--------------------------------------------------------------------*/
GET_CERT_LABELS:
  Address ISPExec "QLIBDEF ISPLLIB TYPE(DATASET) ID(DSNAME)"
  QLIBRC = RC
  IF (QLIBRC = 0) THEN DO
     Address TSO "alloc f(ezsubcom) da("dsname") shr reuse"
     END

  x = Msg('OFF')
  ADDRESS TSO "ALLOC FI(GCPRINT) SYSOUT(H) HOLD REUSE"
  x = Msg('ON')

  Call 'EZSUBCOM' 'ADDLESUB', 'GETCERTS', , , 'EZSUBCOM'
  retcode = RESULT
  zerrsm = "RACFADM EZSUBCOM"
  zerrlm = "EZSUBCOM GETCERTS RC =" retcode
  Address ISPexec'log msg(isrz003)'

  Prefix = "C_"
  ADDRESS GETCERTS 'CERTSUMM PREFIX' Prefix /* 'VERBOSE' */
  retcode = RC
  zerrsm = "RACFADM GETCERTS"
  zerrlm = "GETCERTS CERTSUMM RC =" retcode
  Address ISPexec'log msg(isrz003)'

  cnt = 0
  if c_label.0 > 0 then
    cnt = cnt + 1

  Do I = 1 To C_LABEL.0
    CERNUM   = Right(i,4,'0')
    LABEL    = C_LABEL.i
    CERTUSER = C_CERTUSER.i
    NOTAFT   = Left(C_NOTAFTER.i,10)
    NOTBEF   = Left(C_NOTBEFOR.i,10)
    CERTDADD = Left(C_CERTDADD.i,10)
    CERTUADD = C_CERTUADD.i
    ISSUER   = C_ISSUER.i
    KEYALGO  = C_KEYALGO.i
    KEYLEN   = C_KEYLEN.i
    KEYTYPE  = C_KEYTYPE.i
    CAUSAGE  = YesNo(C_CAUSAGE.i)
    PRIVKEY  = YesNo(C_PRIVKEY.i)
    SELFSIGN = YesNo(C_SELFSIGN.i)
    TRUST    = YesNo(C_TRUST.i)
    SIGALGO  = C_SIGALGO.i
    SUBJECT = C_SUBJECT.i
    Address ISPExec "TBMOD" TABLEA
    End

  if cnt = 0 then do
    label   = 'NONE'
    "TBMOD" TABLEA
    end

RETURN
/*--------------------------------------------------------------------*/
/*  Labels table display section                                      */
/*--------------------------------------------------------------------*/
DISPLAY_TABLE:
  opta   = ' '
  xtdtop = 0
  rsels  = 0
  do forever
     if (rsels < 2) then do
        "TBTOP " TABLEA
        'tbskip' tablea 'number('xtdtop')'
        radmrfnd = 'PASSTHRU'
        'vput (radmrfnd)'
        'control passthru lrscroll pason'
        "TBDISPL" TABLEA "PANEL("PANEL27")"
     end
     else do
       'control passthru lrscroll pason'
       'tbdispl' tablea
       end
     /* Comment Start
     if (rc > 4) then leave
        Comment End */
     if (rc > 4) then do
        src = rc
        'tbclose' tablea
        rc = src
        leave
        end
     xtdtop   = ztdtop
     rsels    = ztdsels
     radmrfnd = null
     'vput (radmrfnd)'
     PARSE VAR ZCMD ZCMD PARM SEQ
     IF (SROW <> "") & (SROW <> 0) THEN
        IF (SROW > 0) THEN DO
           "TBTOP " TABLEA
           "TBSKIP" TABLEA "NUMBER("SROW")"
        END
     if (zcmd = 'RFIND') then do
        zcmd = 'FIND'
        parm = findit
        'tbtop ' TABLEA
        'tbskip' TABLEA 'number('last_find')'
     end
     'control passthru lrscroll pasoff'
     if zcmd /= null then
     Select
        When (abbrev("FIND",zcmd,1) = 1) then
             call do_find
        WHEN (ABBREV("LOCATE",ZCMD,1) = 1) THEN do
             if (parm <> '') then do
                locarg = parm'*'
                PARSE VAR SORT . "," . "," SEQ
                IF (SEQ = "D") THEN
                   CONDLIST = "LE"
                ELSE
                   CONDLIST = "GE"
                parse value sort with scan_field',' .
                interpret scan_field ' = locarg'
                'tbtop ' tablea
                "TBSCAN "TABLEA" ARGLIST("scan_field")",
                        "CONDLIST("CONDLIST")",
                        "position(scanrow)"
                xtdtop = scanrow
             end
        end
        WHEN (ABBREV("ONLY",ZCMD,1) = 1) THEN DO
             find_str = translate(parm)
             'tbtop ' TABLEA
             'tbskip' TABLEA
             do forever
                str = translate(LABEL ,
                                CERNUM ,
                                CERTUSER ,
                                NOTBEF ,
                                NOTAFT ,
                                ISSUER ,
                                CERTDADD ,
                                CERTUADD ,
                                KEYALGO ,
                                KEYLEN ,
                                KEYTYPE ,
                                CAUSAGE ,
                                PRIVKEY ,
                                SELFSIGN ,
                                TRUST ,
                                SIGALGO ,
                                SUBJECT)
                if (pos(find_str,str) > 0) then nop
                else 'tbdelete' TABLEA
                'tbskip' TABLEA
                if (rc > 0) then do
                   'tbtop' TABLEA
                   leave
                end
             end
        END
        WHEN (ABBREV("RESET",ZCMD,1) = 1) THEN DO
             call select_label
             sort     = 'LABEL,C,A'
             xtdtop   = 1
        END
/*      When (abbrev("SAVE",zcmd,2) = 1) then DO
             if panel27 = 'RACGCERT' THEN
               TMPSKELT = SKELETON1
             else
               TMPSKELT = SKELETO1A
             call do_SAVE
        END */
        WHEN (ABBREV("SORT",ZCMD,1) = 1) THEN DO
             SELECT
                when (ABBREV("LABEL",PARM,1) = 1) then
                     call sortseq 'LABEL'
                when (ABBREV("NOTBEF",PARM,4) = 1) then
                     call sortseq 'NOTBEF'
                when (ABBREV("NOTAFT",PARM,4) = 1) then
                     call sortseq 'NOTAFT'
                when (ABBREV("CERNUM",PARM,4) = 1) then
                     call sortseq 'CERNUM'
                when (ABBREV("CERTUSER",PARM,4) = 1) then
                     call sortseq 'CERTUSER'
                when (ABBREV("CERTDADD",PARM,8) = 1) then
                     call sortseq 'CERTDADD'
                when (ABBREV("DADD",PARM,4) = 1) then
                     call sortseq 'CERTDADD'
                when (ABBREV("CERTUADD",PARM,8) = 1) then
                     call sortseq 'CERTUADD'
                when (ABBREV("UADD",PARM,4) = 1) then
                     call sortseq 'CERTUADD'
                when (ABBREV("CAUSAGE",PARM,4) = 1) then
                     call sortseq 'CAUSAGE'
                when (ABBREV("PRIVKEY",PARM,4) = 1) then
                     call sortseq 'PRIVKEY'
                when (ABBREV("SELFSIGN",PARM,4) = 1) then
                     call sortseq 'SELFSIGN'
                when (ABBREV("TRUST",PARM,4) = 1) then
                     call sortseq 'TRUST'
                when (ABBREV("SUBJECT",PARM,4) = 1) then
                     call sortseq 'SUBJECT'
                when (ABBREV("ISSUER",PARM,4) = 1) then
                     call sortseq 'ISSUER'
                when (ABBREV("KEYALGO",PARM,4) = 1) then
                     call sortseq 'KEYALGO'
                when (ABBREV("KEYALGO",PARM,4) = 1) then
                     call sortseq 'KEYALGO'
                otherwise NOP
           END
        END
        WHEN (ABBREV("1",ZCMD,1) = 1) THEN DO       /*UNDOC*/ /* @JK */
          panel27 = 'RACGCERT'                                /* @JK */
        END                                                   /* @JK */
        WHEN (ABBREV("2",ZCMD,1) = 1) THEN DO       /*UNDOC*/ /* @JK */
          panel27 = 'RACGCER2'                                /* @JK */
        END                                                   /* @JK */
        WHEN (ABBREV("3",ZCMD,1) = 1) THEN DO       /*UNDOC*/ /* @JK */
          panel27 = 'RACGCER3'                                /* @JK */
        END                                                   /* @JK */
        WHEN (ABBREV("ALT",ZCMD,3) = 1) THEN DO     /*UNDOC*/ /* @JK */
          panel27 = 'RACGCER2'                                /* @JK */
        END                                                   /* @JK */
        WHEN (ABBREV("NORM",ZCMD,4) = 1) THEN DO    /*UNDOC*/ /* @JK */
          panel27 = 'RACGCERT'                                /* @JK */
        END                                                   /* @JK */
        WHEN (ABBREV("LEFT",ZCMD,4) = 1) THEN DO
          if panel27 = 'RACGCERT' then
            panel27 = 'RACGCER3'
          else
          if panel27 = 'RACGCER2' then
            panel27 = 'RACGCERT'
          else
          if panel27 = 'RACGCER3' then
            panel27 = 'RACGCER2'
        END
        WHEN (ABBREV("RIGHT",ZCMD,5) = 1) THEN DO
          if panel27 = 'RACGCERT' then
            panel27 = 'RACGCER2'
          else
          if panel27 = 'RACGCER2' then
            panel27 = 'RACGCER3'
          else
          if panel27 = 'RACGCER3' then
            panel27 = 'RACGCERT'
        END
        WHEN (ABBREV("CHECK",ZCMD,5) = 1) THEN DO
         CALL CHECKC
        END
        WHEN (ABBREV("RRINGS",ZCMD,5) = 1) THEN DO
         CALL RACRINGS
        END
        WHEN (ABBREV("RINGS",ZCMD,5) = 1) THEN DO
         CALL GCRINGS
        END
        WHEN (ABBREV("ADDCERT",ZCMD,3) = 1) THEN DO
         CALL ADDL
        END
        WHEN (ABBREV("GENCERT",ZCMD,3) = 1) THEN DO
         CALL GENC
        END
        Otherwise Do
          racfsmsg = 'Error.'
          racflmsg = zcmd 'is not a recognized command.' ,
                     'Try again.'
          'setmsg msg(RACF011)'
        End
     End /* Select */
     CLRLABE = "GREEN"; CLRCERN = "GREEN"; CLRCERT = "GREEN"
     CLRNOTB = "GREEN"; CLRNOTA = "GREEN"; CLRISSU = "GREEN"
     CLRDADD = "GREEN"; CLRUADD = "GREEN"; CLRKEYA = "GREEN"
     CLRKEYL = "GREEN"; CLRCAUS = "GREEN"; CLRPRIV = "GREEN"
     CLRSELF = "GREEN"; CLRTRUS = "GREEN"; CLRSIGA = "GREEN"
     CLRSUBJ = "GREEN"; CLRKEYA = "GREEN"
     PARSE VAR SORT LOCARG "," .

     IF LOCARG = 'CERTDADD' | LOCARG = 'CERTUADD' THEN
       LOCARG = RIGHT(LOCARG,4)||LEFT(LOCARG,4)

     INTERPRET "CLR"SUBSTR(LOCARG,1,4)" = 'TURQ'"
     "TBSORT" TABLEA "FIELDS("sort")"
     "TBTOP " TABLEA
     ZCMD = ""; PARM = ""
     'control display save'
     Select
        when (opta = 'S') then call gccerts
        when (opta = 'L') then call listl
        when (opta = 'X') then call listl
        when (opta = 'H') then call listl
        when (opta = 'A') then call addl
        when (opta = 'D') then call dell
        when (opta = 'G') then call genc
        when (opta = 'Q') then call gencr
        when (opta = 'M') then call listm
        when (opta = 'R') then call listm
        otherwise nop
     End
     'control display restore'
  end  /* Do forever) */
  'control passthru lrscroll pasoff'
RETURN 0
/*--------------------------------------------------------------------*/
/*  Process primary command FIND                                      */
/*--------------------------------------------------------------------*/
DO_FIND:
  if (parm = null) then do
     racfsmsg = 'Error'
     racflmsg = 'Find requires a value to search for.' ,
                'Try again.'
     'setmsg msg(RACF011)'
     return
  end
  findit    = translate(parm)
  last_find = 0
  wrap      = 0
  do forever
     'tbskip' TABLEA
     if (rc > 0) then do
        if (wrap = 1) then do
           racfsmsg = 'Not Found'
           racflmsg = findit 'not found.'
           'setmsg msg(RACF011)'
           return
        end
        if (wrap = 0) then wrap = 1
        'tbtop' TABLEA
     end
     else do
        testit = translate(LABEL ,
                           CERNUM ,
                           CERTUSER ,
                           NOTBEF ,
                           NOTAFT ,
                           ISSUER ,
                           CERTDADD ,
                           CERTUADD ,
                           KEYALGO ,
                           KEYLEN ,
                           KEYTYPE ,
                           CAUSAGE ,
                           PRIVKEY ,
                           SELFSIGN ,
                           TRUST ,
                           SIGALGO ,
                           SUBJECT)
        if (pos(findit,testit) > 0) then do
           'tbquery' TABLEA 'position(srow)'
           'tbtop'   TABLEA
           'tbskip'  TABLEA 'number('srow')'
           last_find = srow
           xtdtop    = srow
           if (wrap = 0) then
              racfsmsg = 'Found'
           else
              racfsmsg = 'Found/Wrapped'
           racflmsg = findit 'found in row' srow + 0
           'setmsg msg(RACF011)'
           return
        end
     end
  end
RETURN
/*--------------------------------------------------------------------*/
/*  Define sort sequence, to allow point-n-shoot sorting (A/D)        */
/*--------------------------------------------------------------------*/
SORTSEQ:
  parse arg sortcol
  INTERPRET "TMPSEQ = SORT"substr(SORTCOL,1,4)
  select
     when (seq <> "") then do
          if (seq = 'A') then
             tmpseq = 'D'
          else
             tmpseq = 'A'
          sort = sortcol',C,'seq
     end
     when (seq = ""),
        & (tmpseq = 'A') then do
           sort   = sortcol',C,A'
           tmpseq = 'D'
     end
     Otherwise do
        sort   = sortcol',C,D'
        tmpseq = 'A'
     end
  end
  INTERPRET "SORT"SUBSTR(SORTCOL,1,4)" = TMPSEQ"
RETURN
/*--------------------------------------------------------------------*/
/*  List/Export label                                                 */
/*--------------------------------------------------------------------*/
LISTL:
  certtype = FmtId(certuser)
  IF (OPTA = "X") THEN DO
     xdsn = label
     call dsn_chars
     do x = 1 to length(xdsn)
        if x // 9 = 0 then do
           if datatype(substr(xdsn,x+1,1),'M') = 1 then
              xdsn = overlay('.',xdsn,x,1)
           else
              xdsn = overlay('.@',xdsn,x,2)
        end
     end
     xdsn = "'"userid()"."xdsn".XP'"
     'ADDPOP'
     'DISPLAY PANEL('panelxp')'
     disprc = RC
     'REMPOP'
     if (disprc > 0) then do
        cmd_rc = 8
        RETURN
     end
     cmd = "racdcert "certtype" export(label('"LABEL"'))"
     cmd = cmd || " dsn("xdsn")"
     if (formatx <> NULL) then
      cmd = cmd || " FORMAT("formatx")"
     if (pwdx  <> NULL) then
      cmd = cmd || " PASSWORD('"pwdx"')"
     X = OUTTRAP("CMDREC.")
     ADDRESS TSO cmd
     cmd_rc = rc
     X = OUTTRAP("OFF")
     if (SETMSHOW <> 'NO') then
        call SHOWCMD
     if (cmd_rc = 0) then do
       RACFSMSG = "Certificate exported"
       RACFLMSG = "Label '"strip(label)"' was exported to",
                  "dataset "xdsn
       "SETMSG MSG(RACF011)"
       end
     else
        CALL racfmsgs "ERR10" cmdrec.1 /* Generic failure */
     DROP CMDREC.
     if EDITXP = 'Y' then do
       SELECT
          WHEN (SETGDISP = "VIEW") THEN
               "VIEW DATASET("XDSN")"
          WHEN (SETGDISP = "EDIT") THEN
               "EDIT DATASET("XDSN")"
          OTHERWISE
               "BROWSE DATASET("XDSN")"
       END
       end
  END
  ELSE DO
     IF (OPTA = "L") THEN
       cmd = "racdcert "certtype" list(label('"LABEL"'))"
     IF (OPTA = "H") THEN
       cmd = "racdcert "certtype" listchain(label('"LABEL"'))"
     X = OUTTRAP("CMDREC.")
     ADDRESS TSO cmd
     cmd_rc = rc
     X = OUTTRAP("OFF")
     if (SETMSHOW <> 'NO') then
        call SHOWCMD
     DO J = 1 TO CMDREC.0
        CMDREC.J = SUBSTR(CMDREC.J,1,80)
     END
     ADDRESS TSO "ALLOC F("DDNAME") NEW REUSE",
                 "LRECL(80) BLKSIZE(0) RECFM(F B)",
                 "UNIT(VIO) SPACE(1 5) CYLINDERS"
     ADDRESS TSO "EXECIO * DISKW "DDNAME" (STEM CMDREC. FINIS"
     DROP CMDREC.

     "LMINIT DATAID(CMDDATID) DDNAME("DDNAME")"
     SELECT
        WHEN (SETGDISP = "VIEW") THEN
             "VIEW DATAID("CMDDATID") MACRO("EDITMACR")"
        WHEN (SETGDISP = "EDIT") THEN
             "EDIT DATAID("CMDDATID") MACRO("EDITMACR")"
        OTHERWISE
             "BROWSE DATAID("CMDDATID")"
     END
     ADDRESS TSO "FREE FI("DDNAME")"
     if (cmd_rc > 0) then
        CALL racfmsgs "ERR10" /* Generic failure */
  END
RETURN
/*--------------------------------------------------------------------*/
/*  Check certificate or certificate chain                            */
/*--------------------------------------------------------------------*/
CHECKC:
     'ADDPOP'
     'DISPLAY PANEL('panelck')'
     disprc = RC
     'REMPOP'
     if (disprc > 0) then do
        cmd_rc = 8
        RETURN
     end
     X = OUTTRAP("CMDREC.")
     cmd = "racdcert checkcert("cdsn")"
     ADDRESS TSO cmd
     cmd_rc = rc
     X = OUTTRAP("OFF")
     if (SETMSHOW <> 'NO') then
        call SHOWCMD
     DO J = 1 TO CMDREC.0
        CMDREC.J = SUBSTR(CMDREC.J,1,80)
     END
     ADDRESS TSO "ALLOC F("DDNAME") NEW REUSE",
                 "LRECL(80) BLKSIZE(0) RECFM(F B)",
                 "UNIT(VIO) SPACE(1 5) CYLINDERS"
     ADDRESS TSO "EXECIO * DISKW "DDNAME" (STEM CMDREC. FINIS"
     DROP CMDREC.

     "LMINIT DATAID(CMDDATID) DDNAME("DDNAME")"
     SELECT
        WHEN (SETGDISP = "VIEW") THEN
             "VIEW DATAID("CMDDATID") MACRO("EDITMACR")"
        WHEN (SETGDISP = "EDIT") THEN
             "EDIT DATAID("CMDDATID") MACRO("EDITMACR")"
        OTHERWISE
             "BROWSE DATAID("CMDDATID")"
     END
     ADDRESS TSO "FREE FI("DDNAME")"
     if (cmd_rc > 0) then
        CALL racfmsgs "ERR10" /* Generic failure */
RETURN
/*--------------------------------------------------------------------*/
/*  Display Certificate labels with GETCERTS                          */
/*--------------------------------------------------------------------*/
GCCERTS:
gcert. = ''
y = 0
indx = strip(cernum,,'0')
Call CertsCosmetic indx
gcert.0 = y
Call ViewCerts
RETURN
/*--------------------------------------------------------------------*/
/*  Display Keyring values with GETCERTS                              */
/*--------------------------------------------------------------------*/
GCRINGS:
If gcrings = 0 then do
  Prefix = "C_"
  ADDRESS GETCERTS 'RINGSUMM PREFIX' Prefix /* 'VERBOSE' */
  retcode = RC
  zerrsm = "RACFADM GETCERTS"
  zerrlm = "GETCERTS RINGSUMM RC =" retcode
  Address ISPexec'log msg(isrz003)'
  end

/* Cosmetic display of keyring values */
gcrings = 1
gcert. = ''
y = 0
Call RingsCosmetic
gcert.0 = y
Call ViewCerts
RETURN
/*--------------------------------------------------------------------*/
/*  Keep only DSN characters                                          */
/*--------------------------------------------------------------------*/
DSN_CHARS:
   if left(xdsn,1) > 'Z' | left(xdsn,1) = '-' then
      xdsn = '@'substr(xdsn,2)
   dsn='abcdefghijklmnopqrstuvwxyz'||,
       'ABCDEFGHIJKLMNOPQRSTUVWXYZ'||,
       '0123456789-@#$'
   nondsn = space(translate(xdsn,,dsn),0)
   xdsn   = space(translate(xdsn,,nondsn),0)
RETURN
/*--------------------------------------------------------------------*/
/*  Keep only DSN characters                                          */
/*--------------------------------------------------------------------*/
DSN_CHARS_CR:
   if left(gdsn,1) > 'Z' | left(gdsn,1) = '-' then
      gdsn = '@'substr(gdsn,2)
   dsn='abcdefghijklmnopqrstuvwxyz'||,
       'ABCDEFGHIJKLMNOPQRSTUVWXYZ'||,
       '0123456789-@#$'
   nondsn = space(translate(gdsn,,dsn),0)
   gdsn   = space(translate(gdsn,,nondsn),0)
RETURN
/*--------------------------------------------------------------------*/
/*  Display RACF command and return code                              */
/*--------------------------------------------------------------------*/
SHOWCMD:
  IF (SETMSHOW = "BOTH") | (SETMSHOW = "DISPLAY") THEN DO
     PARSE VAR CMD MSG1 60 MSG2 121 MSG3
     MSG4 = "Return code = "cmd_rc
     "ADDPOP ROW(6) COLUMN(4)"
     "DISPLAY PANEL("PANELM2")"
     "REMPOP"
  END
  IF (SETMSHOW = "BOTH") | (SETMSHOW = "LOG") THEN DO
     zerrsm = "RACFADM "REXXPGM" RC="cmd_rc
     zerrlm = cmd
     'log msg(isrz003)'
  END
RETURN
/*--------------------------------------------------------------------*/
/*  Save table to dataset                                             */
/*--------------------------------------------------------------------*/
DO_SAVE:
  X = MSG("OFF")
  "ADDPOP COLUMN(40)"
  "VGET (RACFSDSN RACFSMBR RACFSFIL RACFSREP) PROFILE"
  IF (RACFSDSN = "") THEN         /* SAve - Dataset Name  */
     RACFSDSN = USERID()".RACFADM.REPORTS"
  IF (RACFSFIL = "") THEN         /* SAve - As (TXT/CVS)  */
     RACFSFIL = "T"
  IF (RACFSREP = "") THEN         /* SAve - Replace (Y/N) */
     RACFSREP = "N"

  DO FOREVER
     "DISPLAY PANEL("PANELS1")"
     IF (RC = 08) THEN DO
        "REMPOP"
        X = MSG("ON")
        RETURN
     END
     RACFSDSN = STRIP(RACFSDSN,,"'")
     RACFSDSN = STRIP(RACFSDSN,,'"')
     RACFSDSN = STRIP(RACFSDSN)
     SYSDSORG = ""
     X = LISTDSI("'"RACFSDSN"'")
     IF (SYSDSORG = "") | (SYSDSORG = "PS"),
      | (SYSDSORG = "PO") THEN
        NOP
     ELSE DO
        RACFSMSG = "Not PDS/Seq File"
        RACFLMSG = "The dataset specified is not",
                  "a partitioned or sequential",
                  "dataset, please enter a valid",
                  "dataset name."
       "SETMSG MSG(RACF011)"
       ITERATE
     END
     IF (SYSDSORG = "PS") & (RACFSMBR <> "") THEN DO
        RACFSMSG = "Seq File - No mbr"
        RACFLMSG = "This dataset is a sequential",
                  "file, please remove the",
                  "member name."
       "SETMSG MSG(RACF011)"
       ITERATE
     END
     IF (SYSDSORG = "PO") & (RACFSMBR = "") THEN DO
        RACFSMSG = "PDS File - Need Mbr"
        RACFLMSG = "This dataset is a partitioned",
                  "dataset, please include a member",
                  "name."
       "SETMSG MSG(RACF011)"
       ITERATE
     END

     IF (RACFSMBR = "") THEN
        TMPDSN = RACFSDSN
     ELSE
        TMPDSN = RACFSDSN"("RACFSMBR")"
     DSNCHK = SYSDSN("'"TMPDSN"'")
     IF (DSNCHK = "OK" & RACFSREP = "N") THEN DO
        RACFSMSG = "DSN/MBR Exists"
        RACFLMSG = "Dataset/member already exists. ",
                  "Please type in "Y" to replace file."
        "SETMSG MSG(RACF011)"
        ITERATE
     END
     LEAVE
  END
  "REMPOP"
  "VPUT (RACFSDSN RACFSMBR RACFSFIL RACFSREP) PROFILE"

ADDRESS TSO
  IF (RACFSREP = "Y" & RACFSMBR = "") |,
     (DSNCHK <> "OK" & DSNCHK <> "MEMBER NOT FOUND"),
     THEN DO
     "DELETE '"RACFSDSN"'"
     IF (RACFSMBR = "") THEN
        "ALLOC  FI(ISPFILE) DA('"RACFSDSN"') NEW",
            "REUSE SP(1 1) CYLINDER UNIT(SYSALLDA)",
            "LRECL(80) RECFM(F B)"
     ELSE
        "ALLOC  FI(ISPFILE) DA('"RACFSDSN"') NEW",
            "REUSE SP(1 1) CYLINDER UNIT(SYSALLDA)",
            "LRECL(80) RECFM(F B)",
            "DSORG(PO) DSNTYPE(LIBRARY,2)"
  END
  ELSE
     "ALLOC  FI(ISPFILE) DA('"RACFSDSN"') SHR REUSE"

ADDRESS ISPEXEC
  "FTOPEN"
  "FTINCL "TMPSKELT
  IF (RACFSMBR = "") THEN
     "FTCLOSE"
  ELSE
     "FTCLOSE NAME("RACFSMBR")"
  ADDRESS TSO "FREE FI(ISPFILE)"

  SELECT
     WHEN (SETGDISP = "VIEW") THEN
          "VIEW DATASET('"RACFSDSN"') MACRO("EDITMACR")"
     WHEN (SETGDISP = "EDIT") THEN
          "EDIT DATASET('"RACFSDSN"') MACRO("EDITMACR")"
     OTHERWISE
          "BROWSE DATASET('"RACFSDSN"')"
  END
  X = MSG("ON")

RETURN
/*--------------------------------------------------------------------*/
/*  Add certificate                                                   */
/*--------------------------------------------------------------------*/
ADDL:
  "DISPLAY PANEL("PANEL28")"
  if (rc > 0) then return
  if (ownera = 'SITE' |  ownera = 'CERTAUTH') then
   cmd = "RACDCERT ADD("DSNA") "OWNERA" "TRUSTA
  else
   cmd = "RACDCERT ADD("DSNA") id("OWNERA") "TRUSTA
  cmd =  cmd || " WITHLABEL('"LABELA"')"
  if (PWDA      <> '') then
   cmd = cmd || " PASSWORD('"PWDA"')"
  if (PKDSA <> '') then
   cmd = cmd || " PKDS("PKDSA")"
  x = OUTTRAP('var.')
  address TSO cmd
  cmd_rc = rc
  x = OUTTRAP('OFF')
  if (SETMSHOW <> 'NO') then
   call SHOWCMD
  if (cmd_rc = 0) then do
      if label = 'NONE' then
       "TBDELETE" TABLEA
      call select_label
   end
  else call racfmsgs 'ERR26' var.1 /* error adding cert. */
RETURN
/*--------------------------------------------------------------------*/
/*  Generate certificate                                              */
/*--------------------------------------------------------------------*/
GENC:
  "DISPLAY PANEL("PANEL29")"
  if (rc > 0) then return
  if (ownerg = 'SITE' |  ownerg = 'CERTAUTH') then
   cmd = "RACDCERT GENCERT "OWNERG
  else
   cmd = "RACDCERT GENCERT id("OWNERG")"
  cmd =  cmd || " WITHLABEL('"LABELG"')"

  sdn = NAMEG||TITLEG||UNITG||ORGG||CITYG||STG||CTRYG
  if sdn <> '' then do
    #sdn = "SUBJECTSDN("||,
           "CN('"nameg"')"||,       /* Common Name         */
           " T('"titleg"')"||,      /* Title               */
           "OU('"unitg"')"||,       /* Organizational unit */
           " O('"orgg"')"||,        /* Organization        */
           " L('"cityg"')"||,       /* Locality            */
           "SP('"stg"')"||,         /* State / Province    */
           " C('"ctryg"')"||,       /* Country             */
           ")"
    cmd =  cmd || #sdn
    end
  if stdtg <> "" then do
    nbdt = left(stdtg,10)        /* yyyy-mm-dd */
    nbtm = substr(stdtg,12,8)    /* hh:mm:ss   */
    if nbtm = '' then
      nbtm = '00:00:00'
    #stdtg = "NOTBEFORE(DATE("nbdt") TIME("nbtm"))"
    cmd =  cmd || #stdtg
    end
  if endtg <> "" then do
    nadt = left(endtg,10)        /* yyyy-mm-dd */
    natm = substr(endtg,12,8)    /* hh:mm:ss   */
    if natm = '' then
      natm = '23:59:59'
    #endtg = "NOTAFTER(DATE("nadt") TIME("natm"))"
    cmd =  cmd || #endtg
    end
  if (sigwg <> "") then do
    #signw = "SIGNWITH("sigtg "LABEL('"sigwg"')"
    cmd =  cmd || #signw
    end
  if (parmg  <> '') then
   cmd = cmd || parmg

  x = OUTTRAP('var.')
  address TSO cmd
  cmd_rc = rc
  x = OUTTRAP('OFF')
  if (SETMSHOW <> 'NO') then
   call SHOWCMD
  if (cmd_rc = 0) then do
      if label = 'NONE' then
       "TBDELETE" TABLEA
      call select_label
   end
  else call racfmsgs 'ERR26' var.1 /* error adding cert. */
RETURN
/*--------------------------------------------------------------------*/
/*  Generate Certificate Request                                      */
/*--------------------------------------------------------------------*/
GENCR:
  certtype = FmtId(certuser)
  gdsn = label
  call dsn_chars_cr
  do x = 1 to length(gdsn)
     if x // 9 = 0 then do
        if datatype(substr(gdsn,x+1,1),'M') = 1 then
           gdsn = overlay('.',gdsn,x,1)
        else
           gdsn = overlay('.@',gdsn,x,2)
     end
  end
  gdsn = "'"userid()"."gdsn".GR'"
  'ADDPOP'
  'DISPLAY PANEL('panelgr')'
  disprc = RC
  'REMPOP'
  if (disprc > 0) then do
     cmd_rc = 8
     RETURN
  end
  cmd = "racdcert "certtype" genreq(label('"LABEL"'))"
  cmd = cmd || " dsn("gdsn")"
  X = OUTTRAP("CMDREC.")
  ADDRESS TSO cmd
  cmd_rc = rc
  X = OUTTRAP("OFF")
  if (SETMSHOW <> 'NO') then
     call SHOWCMD
  if (cmd_rc = 0) then do
    RACFSMSG = "Certificate request generated"
    RACFLMSG = "Certificate request for label '"strip(label)"'",
               "was generated to dataset "gdsn
    "SETMSG MSG(RACF011)"
    end
  else
     CALL racfmsgs "ERR10" cmdrec.1 /* Generic failure */
  DROP CMDREC.
  if EDITGR = 'Y' then do
    SELECT
       WHEN (SETGDISP = "VIEW") THEN
            "VIEW DATASET("GDSN")"
       WHEN (SETGDISP = "EDIT") THEN
            "EDIT DATASET("GDSN")"
       OTHERWISE
            "BROWSE DATASET("GDSN")"
    END
    end
RETURN
/*--------------------------------------------------------------------*/
/*  Delete label                                                      */
/*--------------------------------------------------------------------*/
DELL:
  certtype = FmtId(certuser)
  if (label = 'NONE') then
     return
   msg    ='You are about to delete 'label
   Sure_? = RACFMSGC(msg)
   if (sure_? = 'YES') then do
    cmd = "RACDCERT DELETE(LABEL('"LABEL"')) "certtype
    x = OUTTRAP('var.')
    address TSO cmd
    cmd_rc = rc
    x = OUTTRAP('OFF')
    if (SETMSHOW <> 'NO') then
     call SHOWCMD
    if (cmd_rc = 0) then do
     "TBDELETE" TABLEA
     "TBTOP" TABLEA
     "TBQUERY" TABLEA 'ROWNUM(nrow)'
    if (nrow = 0) then do
     label   ='NONE'
     stdate  = ''
     endate  = ''
     status  = ''
     cond    = ''
     "TBMOD" TABLEA
    end
   end
   else
   CALL racfmsgs "ERR27" var.1 /* error deleting cert. */
   end
RETURN
/*--------------------------------------------------------------------*/
/*  LISTMAP/RING                                                      */
/*--------------------------------------------------------------------*/
LISTM:
   if opta = "R" then do
     call RACFRING certuser
     return
     end
   if opta = "M" then
     cmd = "racdcert listmap id("certuser")"

   X = OUTTRAP("CMDREC.")
   ADDRESS TSO cmd
   cmd_rc = rc
   X = OUTTRAP("OFF")
   if (SETMSHOW <> 'NO') then
      call SHOWCMD

   DO J = 1 TO CMDREC.0
      CMDREC.J = SUBSTR(CMDREC.J,1,80)
   END
   ADDRESS TSO "ALLOC F("DDNAME") NEW REUSE",
               "LRECL(80) BLKSIZE(0) RECFM(F B)",
               "UNIT(VIO) SPACE(1 5) CYLINDERS"
   ADDRESS TSO "EXECIO * DISKW "DDNAME" (STEM CMDREC. FINIS"
   DROP CMDREC.

   "LMINIT DATAID(CMDDATID) DDNAME("DDNAME")"
   SELECT
      WHEN (SETGDISP = "VIEW") THEN
           "VIEW DATAID("CMDDATID") MACRO("EDITMACR")"
      WHEN (SETGDISP = "EDIT") THEN
           "EDIT DATAID("CMDDATID") MACRO("EDITMACR")"
      OTHERWISE
           "BROWSE DATAID("CMDDATID")"
   END
   ADDRESS TSO "FREE FI("DDNAME")"
RETURN

ViewCerts:
DO J = 1 TO gcert.0
   gcert.J = SUBSTR(gcert.J,1,255)
END
ADDRESS TSO "ALLOC F("DDNAME") NEW REUSE",
            "LRECL(255) BLKSIZE(0) RECFM(F B)",
            "UNIT(VIO) SPACE(1 5) CYLINDERS"
ADDRESS TSO "EXECIO * DISKW "DDNAME" (STEM gcert. FINIS"
DROP gcert.

"LMINIT DATAID(CMDDATID) DDNAME("DDNAME")"
SELECT
   WHEN (SETGDISP = "VIEW") THEN
        "VIEW DATAID("CMDDATID") MACRO("EDITMACR") panel("paneld1")"
   WHEN (SETGDISP = "EDIT") THEN
        "EDIT DATAID("CMDDATID") MACRO("EDITMACR") panel("paneld1")"
   OTHERWISE
        "BROWSE DATAID("CMDDATID")"
END
ADDRESS TSO "FREE FI("DDNAME")"
RETURN

YesNo:
  If Arg(1) Then Return "Yes"
  Else Return "No"
FmtID:
  id = Arg(1)
  If id == "irrcerta" Then Return "CERTAUTH"
  Else
  If id == "irrsitec" Then Return "SITE"
  Else Return "ID("id")"
RingsCosmetic:
  /* The following is a cosmetic display of ring values */
  Do i = 1 to C_RINGUSER.0
    y = y + 1
    gcert.y = "The certificates connected to" C_RINGUSER.i"/"C_NAME.i":"
    If Length(C_CONCERT#.i) = 0 Then Do
      y = y + 1
      gcert.y = '  ** No certificates connected **'
    End
    Else Call DisplayCertList C_CONCERT#.i
    End i
  Return
CertsCosmetic:
  y = y + 1
  gcert.y = "Digital certificate information for" FmtId(certuser)":"
  y = y + 1
  gcert.y = " "
  Call DisplayVar 'CERTUSER'
  Call DisplayVar 'LABEL'
  Call DisplayVar 'CERTDADD'
  Call DisplayVar 'CERTUADD'
  Call DisplayVar 'AUTHKID'
  Call DisplayVar 'CAUSAGE'
  Call DisplayVar 'FINGERPR'
  Call DisplayVar 'ISSUER'
  Call DisplayVar 'KEYALGO'
  Call DisplayVar 'KEYLEN'
  Call DisplayVar 'KEYTYPE'
  Call DisplayVar 'NOTAFTER'
  Call DisplayVar 'NOTBEFOR'
  Call DisplayVar 'PRIVKEY'
  Call DisplayVar 'SELFSIGN'
  Call DisplayVar 'SERIAL'
  Call DisplayVar 'SIGALGO'
  Call DisplayVar 'SUBJECT'
  Call DisplayVar 'THUMBPR'
  Call DisplayVar 'SUBJKID'
  Call DisplayVar 'TRUST'
CertDetail:
  ADDRESS GETCERTS 'CERTDETL PREFIX' Prefix "CERTINDX" indx /* 'VERBO   SE' */
  ReturnCode = RC
  Do i = 1 to C_EXTUSAGE.0
    y = y + 1
    gcert.y = "EXTUSAGE =" "<"C_EXTUSAGE.i">"
    End i
  Do i = 1 to C_KEYUSAGE.0
    y = y + 1
    gcert.y = "KEYUSAGE =" "<"C_KEYUSAGE.i">"
    End i
  Do i = 1 to C_SAN.0
    y = y + 1
    gcert.y = "ALTNAME  =" "<"C_SAN.i">"
    End i
CertsSigned:
  If Length(C_LEAF#.indx) > 0 Then Do
    y = y + 1
    gcert.y = "Certificates signed by this certificate:"
    Call DisplayCertList C_LEAF#.indx
    End
  Return
DisplayVar:
  v = Arg(1)
  x = LEFT(v,8) "=" VarValue(v)
  if length(vv) = 0 Then Return
  Else do
    y = y + 1
    gcert.y = x
    end
  Return
VarValue:
  v = Arg(1)
  vv = Value(Prefix||v".Indx")
  if wordpos(v,'CAUSAGE PRIVKEY SELFSIGN TRUST') > 0 then
    vv = YesNo(vv)
  If Length(vv) <= 60 Then Return "<"vv">"
  Else Return "<"Left(vv, 57)"...> ("Length(vv)")"
DisplayCertList:
  Procedure Expose C_CERTUSER. C_LABEL. C_SUBJECT. GCERT. Y
  List = Arg(1)
  Do j = 1 to Words(List)
    k = Word(List, j)
    y = y + 1
    gcert.y = " " CertIdent(k)
    End j
  Return
CertIdent:
  Procedure Expose C_CERTUSER. C_LABEL. C_SUBJECT.
  /* Call with CertIndx of Cert to "Identify" */
  /* Returns ID(FOO)      'certificate label' CN=whatever */
  ii = Arg(1)
  Return Left(FmtId(C_CERTUSER.ii) ,12) "'"C_LABEL.ii"' " C_SUBJECT.ii
