/*%NOCOMMENT====================* REXX *==============================*/
/*  PURPOSE:  RACFADM - Digital Certificates, Option CA, List labels  */
/*--------------------------------------------------------------------*/
/* FLG  YYMhDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @A3  220317  LBD      Close open table on exit                     */
/* @A2  210309  LBD      Add State (expired) to table                 */
/* @A1  201118  TRIDJK   Add X (CA Export) line command               */
/* @A0  200929  TRIDJK   Created REXX                                 */
/*====================================================================*/
PANEL27     = "RACFCERT"   /* List labels                  */
PANELM2     = "RACFMSG2"   /* Display RACF command and RC  */
PANELS1     = "RACFSAVE"   /* Obtain DSName to SAVE        */
PANELXP     = "RACFEXP"    /* Export DSN prompt            */ /* @A1 */
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

  cmd = "racdcert certauth list(label('DUMMY')"
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

  racflmsg = "Loading awesomeness.."
  "control display lock"
  "display msg(RACF011)"
  Address 'SYSCALL' 'SLEEP (1)'

  SELCMDS = "ÝS¨ShowÝX¨Export"                                /* @A1 */

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
                  "NAMES(STDATE ENDATE STATUS STATE)" ,       /* @A2 */
                  "REPLACE NOWRITE"                           /* @A2 */
  call get_cert_labels
  sort     = 'LABEL,C,A'
  CLRLABE  = "TURQ" ; CLRSTDA = "GREEN"
  CLRENDA  = "GREEN"; CLRSTAT = "GREEN"
  "TBSORT " TABLEA "FIELDS("sort")"
  "TBTOP  " TABLEA
RETURN
/*--------------------------------------------------------------------*/
/*  Display digital certificate labels                                */
/*--------------------------------------------------------------------*/
GET_CERT_LABELS:
  Scan = 'OFF'
  cmd = "racdcert certauth list"
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
         then state = '*Expired*'                             /* @A2 */
         else state = null                                    /* @A2 */
      "TBMOD" TABLEA
      end
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
                str = translate(label stdate endate status state)
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
                when (ABBREV("STDATE",PARM,1) = 1) then
                     call sortseq 'STDATE'
                when (ABBREV("ENDATE",PARM,1) = 1) then
                     call sortseq 'ENDATE'
                when (ABBREV("STATUS",PARM,1) = 1) then
                     call sortseq 'STATUS'
                when (ABBREV("STATE",PARM,1) = 1) then        /* @A2 */
                     call sortseq 'STATE'
                otherwise NOP
           END
        END
        OTHERWISE NOP
     End /* Select */
     CLRLABE  = "GREEN"; CLRSTDA = "GREEN"
     CLRENDA  = "GREEN"; CLRSTAT = "GREEN"
     PARSE VAR SORT LOCARG "," .
     INTERPRET "CLR"SUBSTR(LOCARG,1,4)" = 'TURQ'"
     "TBSORT" TABLEA "FIELDS("sort")"
     "TBTOP " TABLEA
     ZCMD = ""; PARM = ""
     'control display save'
     Select
        when (opta = 'L') then call listl
        when (opta = 'S') then call listl
        when (opta = 'X') then call listl                     /* @A1 */
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
     if (disprc = 8) then do                                  /* @A1 */
        cmd_rc = 8                                            /* @A1 */
        RETURN                                                /* @A1 */
     end                                                      /* @A1 */
     cmd = "racdcert certauth export(label('"LABEL"')) dsn("xdsn")"
     X = OUTTRAP("CMDREC.")                                   /* @A1 */
     ADDRESS TSO cmd                                          /* @A1 */
     cmd_rc = rc                                              /* @A1 */
     X = OUTTRAP("OFF")                                       /* @A1 */
     if (SETMSHOW <> 'NO') then                               /* @A1 */
        call SHOWCMD                                          /* @A1 */
     DROP CMDREC.                                             /* @A1 */
     if (cmd_rc = 0) then do                                  /* @A1 */
       RACFSMSG = "Certificate exported"                      /* @A1 */
       RACFLMSG = "Label '"strip(label)"' was exported to",   /* @A1 */
                  "dataset "xdsn                              /* @A1 */
       "SETMSG MSG(RACF011)"                                  /* @A1 */
       end                                                    /* @A1 */
  END                                                         /* @A1 */
  ELSE DO                                                     /* @A1 */
     cmd = "racdcert certauth list(label('"LABEL"'))"
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
