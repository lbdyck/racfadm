/*%NOCOMMENT====================* REXX *==============================*/
/*PURPOSE:  RACFADM - Digital Certificates, Option CA-LC, List labels */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @AD  260101  TRIDJK   Add M (Listmap) and R (Listring) line cmds   */
/* @AC  251221  TRIDJK   Add CHECK primary command (CHECKCERT)        */
/* @AB  251218  TRIDJK   Color Cond/ID column                         */
/* @L2  251216  LBDyck   Report invalid commands on table panels      */
/* @AA  251119  TRIDJK   Add PERS     primary command, Charles Mills  */
/* @A9  251109  TRIDJK   Add VUEcerts primary command, Charles Mills  */
/* @A8  241027  TRIDJK   Add G (Gencert) line command                 */
/* @A7  240204  TRIDJK   Set MSG("ON") if PF3 in SAVE routine         */
/* @A6  240126  GA       Add new function Chain,Add,Delete,Export,Type*/
/* @A5  240117  GA       Add NO row for certificate not found         */
/* @A4  240111  GA       List ca or user certificate                  */
/* @A3  220317  LBD      Close open table on exit                     */
/* @A2  210309  LBD      Add Cond (expired) to table                  */
/* @A1  201118  TRIDJK   Add X (CA Export) line command               */
/* @A0  200929  TRIDJK   Created REXX                                 */
/*====================================================================*/
PANEL27     = "RACFCERT"   /* List labels                  */
PANEL28     = "RACFCERA"   /* Add certificate              */ /* @A6 */
PANEL29     = "RACFCERG"   /* Generate certificate         */ /* @A8 */
PANELM2     = "RACFMSG2"   /* Display RACF command and RC  */
PANELS1     = "RACFSAVE"   /* Obtain DSName to SAVE        */
PANELXP     = "RACFEXP"    /* Export DSN prompt            */ /* @A1 */
PANELCK     = "RACFCHK"    /* Check DSN prompt             */ /* @AC */
SKELETON1   = "RACFCERT"   /* Save tablea to dataset       */
EDITMACR    = "RACFEMAC"   /* Edit Macro, turn HILITE off  */
TABLEA      = 'TA'RANDOM(0,99999)  /* Unique table name A  */
DDNAME      = 'RACFA'RANDOM(0,999) /* Unique ddname        */
parse source . . REXXPGM .         /* Obtain REXX pgm name */
REXXPGM     = LEFT(REXXPGM,8)
NULL        = ''

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

  Parse Arg user                                              /* @A4 */
  certtype = "CERTAUTH"                                       /* @A4 */
  type = certtype                                             /* @A6 */
  if (user <> NULL) then do                                   /* @A4 */
   certtype = "id("user")"                                    /* @A4 */
   type = user                                                /* @A6 */
  end                                                         /* @A4 */


  cmd = "racdcert "certtype" list(label('DUMMY')"             /* @A4 */
  x    = outtrap('var.')
  Address TSO cmd
  cmd_rc = rc
  x    = outtrap('off')
  if (SETMSHOW <> 'NO') then
     call SHOWCMD
  if cmd_rc = 8 then do
    RACFSMSG = "Not authorized"                               /* @A1 */
    RACFLMSG = "You are not authorized to issue",             /* @A1 */
               "the RACDCERT command."                        /* @A1 */
    "SETMSG MSG(RACF011)"                                     /* @A1 */
    EXIT
    end
  /*
  racflmsg = "Loading awesomeness.."
  "control display lock"
  "display msg(RACF011)"
  Address 'SYSCALL' 'SLEEP (1)'
  */
  if (SETMADMN = "YES") then                                  /* @A6 */
    SELCMDS = "ÝS¨ShowÝX¨ExportÝH¨Chain"||,                   /* @A6 */
                  "ÝA¨AddÝD¨DeleteÝG¨Gencert"                 /* @A8 */
  else                                                        /* @A6 */
    SELCMDS = "ÝS¨ShowÝX¨ExportÝH¨Chain"                      /* @A6 */

  call Select_label
  rc = display_table()
  "TBEND" TABLEA

  If (SETMTRAC <> 'NO') then do
     Say "*"COPIES("-",70)"*"
     Say "*"Center("End Program = "REXXPGM,70)"*"
     Say "*"COPIES("-",70)"*"
  end
EXIT
/*--------------------------------------------------------------------*/
/*  Select label                                                      */
/*--------------------------------------------------------------------*/
SELECT_LABEL:
  seconds = time('S')
  "TBCREATE" TABLEA "KEYS(LABEL)",
                  "NAMES(STDATE ENDATE STATUS COND)" ,        /* @A2 */
                  "REPLACE NOWRITE"                           /* @A2 */

  if type = 'PERSONAL' then                                   /* @AA */
    call get_pers_cert_labels                                 /* @AA */
  else                                                        /* @JK */
    call get_cert_labels                                      /* @JK */

  sort     = 'LABEL,C,A'
  CLRLABE  = "TURQ" ; CLRSTDA = "GREEN"
  CLRENDA  = "GREEN"; CLRSTAT = "GREEN"; CLRCOND = "GREEN"    /* @AB */
  "TBSORT " TABLEA "FIELDS("sort")"
  "TBTOP  " TABLEA
RETURN
/*--------------------------------------------------------------------*/
/*  Display digital certificate labels                                */
/*--------------------------------------------------------------------*/
GET_CERT_LABELS:
  Scan = 'OFF'
  cmd = "racdcert "certtype" list"                            /* @A4 */
  x = OUTTRAP('var.')
  address TSO cmd
  cmd_rc = rc
  x = OUTTRAP('OFF')
  if (SETMSHOW <> 'NO') then
     call SHOWCMD

  cnt = 0
  do x = 1 to var.0
    if pos('Label:',var.x) > 0 then do
      cnt = cnt + 1
      label  = substr(var.x,10,32)
      i = x + 2
      status = substr(var.i,11,9)
      i = i + 1
      stdate = substr(var.i,15,10)
      i = i + 1
      endate = substr(var.i,15,10)
      parse value endate with ey'/'em'/'ed                    /* @A2 */
      tendate = ey''em''ed                                    /* @A2 */
      if tendate < date('s')                                  /* @A2 */
         then cond = '*Expired*'                              /* @A2 */
         else cond = null                                     /* @A2 */
      "TBMOD" TABLEA
      end
    end
  if cnt = 0 then do                                          /* @A5 */
    label   = 'NONE'                                          /* @A8 */
    status  = ''                                              /* @A5 */
    stdate  = ''                                              /* @A5 */
    endate  = ''                                              /* @A5 */
    cond    = ''                                              /* @A5 */
    "TBMOD" TABLEA                                            /* @A5 */
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
        "TBDISPL" TABLEA "PANEL("PANEL27")"
     end
     else 'tbdispl' tablea
     /* Comment Start
     if (rc > 4) then leave
        Comment End */
     if (rc > 4) then do                                      /* @A3 */
        src = rc                                              /* @A3 */
        'tbclose' tablea                                      /* @A3 */
        rc = src                                              /* @A3 */
        leave                                                 /* @A3 */
        end                                                   /* @A3 */
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
     if zcmd /= null then                                     /* @L2 */
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
        WHEN (ABBREV("ONLY",ZCMD,1) = 1) THEN DO              /* @A2 */
             find_str = translate(parm)
             'tbtop ' TABLEA
             'tbskip' TABLEA
             do forever
                str = translate(label stdate endate status cond)
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
        When (abbrev("SAVE",zcmd,2) = 1) then DO
             TMPSKELT = SKELETON1
             call do_SAVE
        END
        WHEN (ABBREV("SORT",ZCMD,1) = 1) THEN DO
             SELECT
                when (ABBREV("LABEL",PARM,1) = 1) then
                     call sortseq 'LABEL'
                when (ABBREV("STDATE",PARM,3) = 1) then
                     call sortseq 'STDATE'
                when (ABBREV("ENDATE",PARM,1) = 1) then
                     call sortseq 'ENDATE'
                when (ABBREV("STATUS",PARM,5) = 1) then
                     call sortseq 'STATUS'
                when (ABBREV("COND",PARM,4) = 1) then         /* @AB */
                     call sortseq 'COND'
                otherwise NOP
           END
        END
        WHEN (ABBREV("TYPE",ZCMD,1) = 1) THEN DO              /* @A6 */
         CALL SWTT                                            /* @A6 */
        END                                                   /* @A6 */
        WHEN (ABBREV("SITE",ZCMD,4) = 1) THEN DO              /* @JK */
         CALL SITE                                            /* @JK */
        END                                                   /* @JK */
        WHEN (ABBREV("CA",ZCMD,2) = 1) THEN DO                /* @JK */
         CALL CERT                                            /* @JK */
        END                                                   /* @JK */
        WHEN (ABBREV("PERS",ZCMD,4) = 1) THEN DO              /* @AA */
         CALL PERS                                            /* @AA */
        END                                                   /* @JK */
        When (abbrev("VUECERTS",zcmd,3) = 1) then DO          /* @A9 */
         CALL RACFVUE  parm seq                               /* @A9 */
        END                                                   /* @A9 */
        WHEN (ABBREV("CHECK",ZCMD,5) = 1) THEN DO             /* @AC */
         CALL CHECKC                                          /* @AC */
        END                                                   /* @AC */
        Otherwise Do                                          /* @L2 */
          racfsmsg = 'Error.'                                 /* @L2 */
          racflmsg = zcmd 'is not a recognized command.' ,    /* @L2 */
                     'Try again.'                             /* @L2 */
          'setmsg msg(RACF011)'                               /* @L2 */
        End                                                   /* @L2 */
     End /* Select */
     CLRLABE  = "GREEN"; CLRSTDA = "GREEN"
     CLRENDA  = "GREEN"; CLRSTAT = "GREEN"; CLRCOND = "GREEN" /* @AB */
     PARSE VAR SORT LOCARG "," .
     INTERPRET "CLR"SUBSTR(LOCARG,1,4)" = 'TURQ'"
     "TBSORT" TABLEA "FIELDS("sort")"
     "TBTOP " TABLEA
     ZCMD = ""; PARM = ""
     'control display save'
     Select
        when (opta = 'S') then call listl
        when (opta = 'X') then call listl                     /* @A1 */
        when (opta = 'H') then call listl                     /* @A6 */
        when (opta = 'A') then call addl                      /* @A6 */
        when (opta = 'D') then call dell                      /* @A6 */
        when (opta = 'G') then call genc                      /* @A8 */
        when (opta = 'M') then call listm                     /* @AD */
        when (opta = 'R') then call listm                     /* @AD */
        otherwise nop
     End
     'control display restore'
  end  /* Do forever) */
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
        testit = translate(label stdate endate status)
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
  IF (OPTA = "X") THEN DO                                     /* @A1 */
     xdsn = label                                             /* @A1 */
     call dsn_chars                                           /* @A1 */
     do x = 1 to length(xdsn)                                 /* @A1 */
        if x // 9 = 0 then do                                 /* @A1 */
           if datatype(substr(xdsn,x+1,1),'M') = 1 then       /* @A1 */
              xdsn = overlay('.',xdsn,x,1)                    /* @A1 */
           else                                               /* @A1 */
              xdsn = overlay('.@',xdsn,x,2)                   /* @A1 */
        end                                                   /* @A1 */
     end                                                      /* @A1 */
     xdsn = "'"userid()"."xdsn".XP'"                          /* @A1 */
     'ADDPOP'                                                 /* @A1 */
     'DISPLAY PANEL('panelxp')'                               /* @A1 */
     disprc = RC                                              /* @A1 */
     'REMPOP'                                                 /* @A1 */
     if (disprc > 0) then do                                  /* @A6 */
        cmd_rc = 8                                            /* @A1 */
        RETURN                                                /* @A1 */
     end                                                      /* @A1 */
     if certtype = "PERSONAL" then                            /* @AA */
      cmd = "racdcert id("cond") export(label('"LABEL"'))"    /* @JK */
     else                                                     /* @JK */
      cmd = "racdcert "certtype" export(label('"LABEL"'))"    /* @A6 */
     cmd = cmd || " dsn("xdsn")"                              /* @A6 */
     if (formatx <> NULL) then                                /* @A6 */
      cmd = cmd || " FORMAT("formatx")"                       /* @A6 */
     if (pwdx  <> NULL) then                                  /* @A6 */
      cmd = cmd || " PASSWORD('"pwdx"')"                      /* @A6 */
     X = OUTTRAP("CMDREC.")                                   /* @A1 */
     ADDRESS TSO cmd                                          /* @A1 */
     cmd_rc = rc                                              /* @A1 */
     X = OUTTRAP("OFF")                                       /* @A1 */
     if (SETMSHOW <> 'NO') then                               /* @A1 */
        call SHOWCMD                                          /* @A1 */
     if (cmd_rc = 0) then do                                  /* @A1 */
       RACFSMSG = "Certificate exported"                      /* @A1 */
       RACFLMSG = "Label '"strip(label)"' was exported to",   /* @A1 */
                  "dataset "xdsn                              /* @A1 */
       "SETMSG MSG(RACF011)"                                  /* @A1 */
       end                                                    /* @A1 */
     else                                                     /* @A6 */
        CALL racfmsgs "ERR10" cmdrec.1 /* Generic failure */  /* @A6 */
     DROP CMDREC.                                             /* @A6 */
  END                                                         /* @A1 */
  ELSE DO                                                     /* @A1 */
     if certtype = "PERSONAL" then do                         /* @AA */
     IF (OPTA = "S") THEN                                     /* @JK */
      cmd = "racdcert id("cond") list(label('"LABEL"'))"      /* @JK */
     ELSE                                                     /* @JK */
      cmd = "racdcert id("cond") listchain(label('"LABEL"'))"
      END                                                     /* @JK */
     ELSE DO                                                  /* @JK */
      IF (OPTA = "S") THEN                                    /* @A6 */
       cmd = "racdcert "certtype" list(label('"LABEL"'))"     /* @A4 */
      ELSE                                                    /* @A6 */
       cmd = "racdcert "certtype" listchain(label('"LABEL"'))"
       END                                                    /* @JK */

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
     'ADDPOP'                                                 /* @AC */
     'DISPLAY PANEL('panelck')'                               /* @AC */
     disprc = RC                                              /* @AC */
     'REMPOP'                                                 /* @AC */
     if (disprc > 0) then do                                  /* @AC */
        cmd_rc = 8                                            /* @AC */
        RETURN                                                /* @AC */
     end                                                      /* @AC */
     X = OUTTRAP("CMDREC.")                                   /* @AC */
     cmd = "racdcert checkcert("cdsn")"                       /* @AC */
     ADDRESS TSO cmd                                          /* @AC */
     cmd_rc = rc                                              /* @AC */
     X = OUTTRAP("OFF")                                       /* @AC */
     if (SETMSHOW <> 'NO') then                               /* @AC */
        call SHOWCMD                                          /* @AC */
     DO J = 1 TO CMDREC.0                                     /* @AC */
        CMDREC.J = SUBSTR(CMDREC.J,1,80)                      /* @AC */
     END                                                      /* @AC */
     ADDRESS TSO "ALLOC F("DDNAME") NEW REUSE",               /* @AC */
                 "LRECL(80) BLKSIZE(0) RECFM(F B)",           /* @AC */
                 "UNIT(VIO) SPACE(1 5) CYLINDERS"             /* @AC */
     ADDRESS TSO "EXECIO * DISKW "DDNAME" (STEM CMDREC. FINIS"/* @AC */
     DROP CMDREC.                                             /* @AC */
                                                              /* @AC */
     "LMINIT DATAID(CMDDATID) DDNAME("DDNAME")"               /* @AC */
     SELECT                                                   /* @AC */
        WHEN (SETGDISP = "VIEW") THEN                         /* @AC */
             "VIEW DATAID("CMDDATID") MACRO("EDITMACR")"      /* @AC */
        WHEN (SETGDISP = "EDIT") THEN                         /* @AC */
             "EDIT DATAID("CMDDATID") MACRO("EDITMACR")"      /* @AC */
        OTHERWISE                                             /* @AC */
             "BROWSE DATAID("CMDDATID")"                      /* @AC */
     END                                                      /* @AC */
     ADDRESS TSO "FREE FI("DDNAME")"                          /* @AC */
     if (cmd_rc > 0) then                                     /* @AC */
        CALL racfmsgs "ERR10" /* Generic failure */           /* @AC */
RETURN                                                        /* @AC */
/*--------------------------------------------------------------------*/
/*  Keep only DSN characters                                     @A1  */
/*--------------------------------------------------------------------*/
DSN_CHARS:                                                    /* @A1 */
   if left(xdsn,1) > 'Z' | left(xdsn,1) = '-' then            /* @A1 */
      xdsn = '@'substr(xdsn,2)                                /* @A1 */
   dsn='abcdefghijklmnopqrstuvwxyz'||,                        /* @A1 */
       'ABCDEFGHIJKLMNOPQRSTUVWXYZ'||,                        /* @A1 */
       '0123456789-@#$'                                       /* @A1 */
   nondsn = space(translate(xdsn,,dsn),0)                     /* @A1 */
   xdsn   = space(translate(xdsn,,nondsn),0)                  /* @A1 */
RETURN                                                        /* @A1 */
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
        X = MSG("ON")                                         /* @A7 */
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
ADDL:                                                         /* @A6 */
  "DISPLAY PANEL("PANEL28")"                                  /* @A6 */
  if (rc > 0) then return                                     /* @A6 */
  if (ownera = 'SITE' |  ownera = 'CERTAUTH') then            /* @A6 */
   cmd = "RACDCERT ADD("DSNA") "OWNERA" "TRUSTA               /* @A6 */
  else                                                        /* @A6 */
   cmd = "RACDCERT ADD("DSNA") id("OWNERA") "TRUSTA           /* @A6 */
  cmd =  cmd || " WITHLABEL('"LABELA"')"                      /* @A6 */
  if (PWDA      <> '') then                                   /* @A6 */
   cmd = cmd || " PASSWORD('"PWDA"')"                         /* @A6 */
  if (PKDSA <> '') then                                       /* @A6 */
   cmd = cmd || " PKDS("PKDSA")"                              /* @A6 */
  x = OUTTRAP('var.')                                         /* @A6 */
  address TSO cmd                                             /* @A6 */
  cmd_rc = rc                                                 /* @A6 */
  x = OUTTRAP('OFF')                                          /* @A6 */
  if (SETMSHOW <> 'NO') then                                  /* @A6 */
   call SHOWCMD                                               /* @A6 */
  if (cmd_rc = 0) then do                                     /* @A6 */
      if label = 'NONE' then                                  /* @A8 */
       "TBDELETE" TABLEA                                      /* @A6 */
      call select_label                                       /* @A6 */
   end                                                        /* @A6 */
  else call racfmsgs 'ERR26' var.1 /* error adding cert. */   /* @A6 */
RETURN                                                        /* @A6 */
/*--------------------------------------------------------------------*/
/*  Generate certificate                                              */
/*--------------------------------------------------------------------*/
GENC:                                                         /* @A8 */
  "DISPLAY PANEL("PANEL29")"                                  /* @A8 */
  if (rc > 0) then return                                     /* @A8 */
  if (ownerg = 'SITE' |  ownerg = 'CERTAUTH') then            /* @A8 */
   cmd = "RACDCERT GENCERT "OWNERG                            /* @A8 */
  else                                                        /* @A8 */
   cmd = "RACDCERT GENCERT id("OWNERG")"                      /* @A8 */
  cmd =  cmd || " WITHLABEL('"LABELG"')"                      /* @A8 */
                                                              /* @A8 */
  sdn = NAMEG||TITLEG||UNITG||ORGG||CITYG||STG||CTRYG         /* @A8 */
  if sdn <> '' then do                                        /* @A8 */
    #sdn = "SUBJECTSDN("||,                                   /* @A8 */
           "CN('"nameg"')"||,       /* Common Name         */ /* @A8 */
           " T('"titleg"')"||,      /* Title               */ /* @A8 */
           "OU('"unitg"')"||,       /* Organizational unit */ /* @A8 */
           " O('"orgg"')"||,        /* Organization        */ /* @A8 */
           " L('"cityg"')"||,       /* Locality            */ /* @A8 */
           "SP('"stg"')"||,         /* State / Province    */ /* @A8 */
           " C('"ctryg"')"||,       /* Country             */ /* @A8 */
           ")"                                                /* @A8 */
    cmd =  cmd || #sdn                                        /* @A8 */
    end                                                       /* @A8 */
  if stdtg <> "" then do                                      /* @A8 */
    nbdt = left(stdtg,10)        /* yyyy-mm-dd */             /* @A8 */
    nbtm = substr(stdtg,12,8)    /* hh:mm:ss   */             /* @A8 */
    if nbtm = '' then                                         /* @A8 */
      nbtm = '00:00:00'                                       /* @A8 */
    #stdtg = "NOTBEFORE(DATE("nbdt") TIME("nbtm"))"           /* @A8 */
    cmd =  cmd || #stdtg                                      /* @A8 */
    end                                                       /* @A8 */
  if endtg <> "" then do                                      /* @A8 */
    nadt = left(endtg,10)        /* yyyy-mm-dd */             /* @A8 */
    natm = substr(endtg,12,8)    /* hh:mm:ss   */             /* @A8 */
    if natm = '' then                                         /* @A8 */
      natm = '23:59:59'                                       /* @A8 */
    #endtg = "NOTAFTER(DATE("nadt") TIME("natm"))"            /* @A8 */
    cmd =  cmd || #endtg                                      /* @A8 */
    end                                                       /* @A8 */
  if (sigwg <> "") then do                                    /* @A8 */
    #signw = "SIGNWITH("sigtg "LABEL('"sigwg"')"              /* @A8 */
    cmd =  cmd || #signw                                      /* @A8 */
    end                                                       /* @A8 */
  if (parmg  <> '') then                                      /* @A8 */
   cmd = cmd || parmg                                         /* @A8 */
                                                              /* @A8 */
  x = OUTTRAP('var.')                                         /* @A8 */
  address TSO cmd                                             /* @A8 */
  cmd_rc = rc                                                 /* @A8 */
  x = OUTTRAP('OFF')                                          /* @A8 */
  if (SETMSHOW <> 'NO') then                                  /* @A8 */
   call SHOWCMD                                               /* @A8 */
  if (cmd_rc = 0) then do                                     /* @A8 */
      if label = 'NONE' then                                  /* @A8 */
       "TBDELETE" TABLEA                                      /* @A8 */
      call select_label                                       /* @A8 */
   end                                                        /* @A8 */
  else call racfmsgs 'ERR26' var.1 /* error adding cert. */   /* @A8 */
RETURN                                                        /* @A8 */
/*--------------------------------------------------------------------*/
/*  Delete label                                                      */
/*--------------------------------------------------------------------*/
DELL:                                                         /* @A6 */
  if (label = 'NONE') then                                    /* @A8 */
     return                                                   /* @A6 */
   msg    ='You are about to delete 'label                    /* @A6 */
   Sure_? = RACFMSGC(msg)                                     /* @A6 */
   if (sure_? = 'YES') then do                                /* @A6 */
   if certtype = "PERSONAL" then                              /* @AA */
    cmd = "racdcert delete(label('"LABEL"')) id("cond")"      /* @JK */
   else                                                       /* @JK */
    cmd = "RACDCERT DELETE(LABEL('"LABEL"')) "certtype        /* @A6 */
    x = OUTTRAP('var.')                                       /* @A6 */
    address TSO cmd                                           /* @A6 */
    cmd_rc = rc                                               /* @A6 */
    x = OUTTRAP('OFF')                                        /* @A6 */
    if (SETMSHOW <> 'NO') then                                /* @A6 */
     call SHOWCMD                                             /* @A6 */
    if (cmd_rc = 0) then do                                   /* @A6 */
     "TBDELETE" TABLEA                                        /* @A6 */
     "TBTOP" TABLEA                                           /* @A6 */
     "TBQUERY" TABLEA 'ROWNUM(nrow)'                          /* @A6 */
    if (nrow = 0) then do                                     /* @A6 */
     label   ='NONE'                                          /* @A8 */
     stdate  = ''                                             /* @A6 */
     endate  = ''                                             /* @A6 */
     status  = ''                                             /* @A6 */
     cond    = ''                                             /* @A6 */
     "TBMOD" TABLEA                                           /* @A6 */
    end                                                       /* @A6 */
   end                                                        /* @A6 */
   else                                                       /* @A6 */
   CALL racfmsgs "ERR27" var.1 /* error deleting cert. */     /* @A6 */
   end                                                        /* @A6 */
RETURN                                                        /* @A6 */
/*--------------------------------------------------------------------*/
/*  LISTMAP/RING                                                 @AD  */
/*--------------------------------------------------------------------*/
LISTM:
   if opta = "M" then
     action = "listmap"
   if opta = "R" then
     action = "listring(*)"

   if certtype = "PERSONAL" then
     cmd = "racdcert "action" id("cond")"
   else
     if left(certtype,3) = "id(" then
       cmd = "racdcert "action certtype
     else
       return

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
/*--------------------------------------------------------------------*/
/*  Switch type CERTAUTH - SITE                                       */
/*--------------------------------------------------------------------*/
SWTT:                                                         /* @A6 */
   if (Certtype = 'CERTAUTH' | Certtype = 'SITE') then do     /* @A6 */
    if (certtype = 'CERTAUTH') then                           /* @A6 */
     certtype = 'SITE'                                        /* @A6 */
    else                                                      /* @A6 */
     certtype = 'CERTAUTH'                                    /* @A6 */
   type = certtype                                            /* @A6 */
   call select_label                                          /* @A6 */
  end                                                         /* @A6 */
RETURN                                                        /* @A6 */
SITE:                                                         /* @JK */
   certtype = 'SITE'                                          /* @JK */
   type = certtype                                            /* @JK */
   call select_label                                          /* @JK */
RETURN                                                        /* @JK */
CERT:                                                         /* @JK */
   certtype = 'CERTAUTH'                                      /* @JK */
   type = certtype                                            /* @JK */
   call select_label                                          /* @JK */
RETURN                                                        /* @JK */
PERS:                                                         /* @AA */
   certtype = 'PERSONAL'                                      /* @AA */
   type = certtype                                            /* @AA */
   call select_label                                          /* @AA */
RETURN                                                        /* @AA */
/*--------------------------------------------------------------------*/
/*  Display digital certificate personal labels                       */
/*--------------------------------------------------------------------*/
GET_PERS_CERT_LABELS:                                         /* @AA */
Address TSO                                                   /* @AA */
"ALLOC F(INDEX) UNIT(VIO) NEW REUSE SPACE(1,1) TRACKS",       /* @AA */
  "LRECL(256) RECFM(F B)"                                     /* @AA */
"ALLOC F(SYSPRINT) UNIT(VIO) NEW REUSE SPACE(15,15) TRACKS",  /* @AA */
  "LRECL(200) RECFM(F B)"                                     /* @AA */
                                                              /* @AA */
Address ISPEXEC                                               /* @AA */
'Select pgm(vuecertp) parm('index')'                          /* @AA */
if rc = 20 then do                                            /* @AA */
  RACFSMSG = "VUE not found"                                  /* @AA */
  RACFLMSG = "VUECERTP program not found"                     /* @AA */
  "SETMSG MSG(RACF011)"                                       /* @AA */
  Address TSO                                                 /* @AA */
  "FREE  F(INDEX)"                                            /* @AA */
  "ALLOC F(SYSPRINT) DA(*) SHR REUSE"                         /* @AA */
  RETURN                                                      /* @AA */
  end                                                         /* @AA */
                                                              /* @AA */
Address TSO                                                   /* @AA */
"EXECIO * DISKR INDEX (STEM INDEX. FINIS"                     /* @AA */
"FREE F(INDEX)"                                               /* @AA */
"ALLOC F(SYSPRINT) DA(*) SHR REUSE"                           /* @AA */
                                                              /* @AA */
do x = 1 to index.0                                           /* @AA */
  parse var index.x . id stdate endate status . . label       /* @AA */
  if left(id,2) <> 'ID' then                                  /* @AA */
    iterate                                                   /* @AA */
  label = strip(label)                                        /* @AA */
  label = strip(label,,"'")                                   /* @AA */
  status = left(status,7)                                     /* @AA */
  parse var id "(" id ")"                                     /* @AA */
  cond = id                                                   /* @AA */
  Address ISPExec                                             /* @AA */
  "TBMOD" TABLEA                                              /* @AA */
  end                                                         /* @AA */
drop index.                                                   /* @AA */
RETURN                                                        /* @AA */
