/*%NOCOMMENT====================* REXX *==============================*/
/*PURPOSE:  RACFADM - Digital Rings, Option LR, List labels           */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @A1  240204  TRIDJK   Set MSG("ON") if PF3 in SAVE routine         */
/* @A0  240117  GA       Created REXX                                 */
/*====================================================================*/
PANEL01     = "RACFRIN1"   /* List ring                    */
PANEL02     = "RACFRIN2"   /* List labels for ring         */
PANEL03     = "RACFRINA"   /* add ring                     */
PANEL04     = "RACFRINC"   /* connect certificate to ring  */
PANELM2     = "RACFMSG2"   /* Display RACF command and RC  */
PANELS1     = "RACFSAVE"   /* Obtain DSName to SAVE        */
PANELXP     = "RACFEXP"    /* Export DSN prompt            */
SKELETON1   = "RACFRIN1"   /* Save tablea to dataset ring  */
SKELETON2   = "RACFRIN2"   /* Save tablea to dataset list  */
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

  Parse Arg user ringf

  cmd = "racdcert id("user") listring(DUMMY)"
  x    = outtrap('var.')
  Address TSO cmd
  cmd_rc = rc
  x    = outtrap('off')
  if (SETMSHOW <> 'NO') then
     call SHOWCMD
  if cmd_rc = 8 then do
    RACFSMSG = "Not authorized"
    RACFLMSG = "You are not authorized to issue",
               "the RACDCERT command."
    "SETMSG MSG(RACF011)"
    EXIT
    end
  /*
  racflmsg = "Loading awesomeness.."
  "control display lock"
  "display msg(RACF011)"
  Address 'SYSCALL' 'SLEEP (1)'
  */
  if (ringf = NULL) then
   if (SETMADMN = 'YES') then
    SELCMDS = "ÝL¨ListÝA¨AddÝD¨Delete"
   else
    SELCMDS = "ÝL¨List"
  else
   if (SETMADMN = 'YES') then
    SELCMDS = "ÝS¨ShowÝX¨ExportÝH¨ChainÝC¨ConnectÝR¨Remove"
   else
    SELCMDS = "ÝS¨ShowÝX¨ExportÝH¨Chain"

  call Select_Ring
  rc = display_table()
  "TBEND" TABLEA

  If (SETMTRAC <> 'NO') then do
     Say "*"COPIES("-",70)"*"
     Say "*"Center("End Program = "REXXPGM,70)"*"
     Say "*"COPIES("-",70)"*"
  end
EXIT
/*--------------------------------------------------------------------*/
/*  Select ring                                                       */
/*--------------------------------------------------------------------*/
SELECT_RING:
  seconds = time('S')
   if (ringf = NULL) then do
   "TBCREATE" TABLEA "KEYS(RING)",
                   "REPLACE NOWRITE"
   end
  else do
   "TBCREATE" TABLEA "KEYS(LABEL)",
                   "NAMES(OWNER USAGE DEFAULT)",
                   "REPLACE NOWRITE"
   end

  call get_ring_labels
  if (ringf = NULL) then do
   sort     = 'RING,C,A'
   CLRRING  = "TURQ"
   end
  else do
   sort     = 'LABEL,C,A'
   CLRLABE  = "TURQ" ; CLRUSAG = "GREEN" ; CLRDEFA = "GREEN"
   CLROWNE  = "GREEN"
  end

  "TBSORT " TABLEA "FIELDS("sort")"
  "TBTOP  " TABLEA
RETURN
/*--------------------------------------------------------------------*/
/*  Display digital ring labels                                       */
/*--------------------------------------------------------------------*/
GET_RING_LABELS:
  Scan = 'OFF'

  if (ringf = NULL) then
   cmd = "racdcert id("user") listring(*)"
  else
   cmd = "racdcert id("user") listring("ringf")"

  x = OUTTRAP('var.')
  address TSO cmd
  cmd_rc = rc
  x = OUTTRAP('OFF')
  if (SETMSHOW <> 'NO') then
     call SHOWCMD

  cnt = 0
  do x = 1 to var.0
     if (substr(var.x,3,5)='Ring:') then
      ring=""
     if pos('>',var.x) > 0 then do
       line = substr(var.x,pos('>',var.x)+1,pos('<',var.x)-pos('>',var.x)-1)
       ring = ring||line
     end
     if substr(var.x,66,3) = 'YES' | substr(var.x,66,3)= 'NO' then do
      cnt = cnt + 1
      label  = substr(var.x,3,32)
      owner = substr(var.x,38,12)
      usage = substr(var.x,53,8)
      default = substr(var.x,66,3)
      "TBMOD" TABLEA
     end
     if substr(var.x,3,3)  = '***' then do
      cnt = cnt + 1
      label  = 'NO'
      "TBMOD" TABLEA
     end
  end
  if cnt = 0 then do
      ring = 'NONE'                                           /* @JK */
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
        if (ringf = NULL) then
         "TBDISPL" TABLEA "PANEL("PANEL01")"
        else
         "TBDISPL" TABLEA "PANEL("PANEL02")"
     end
     else
       if (ringf = NULL) then
         "TBDISPL" TABLEA "PANEL("PANEL01")"
       else
         "TBDISPL" TABLEA "PANEL("PANEL02")"
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
                if (ringf = NULL) then
                 str = translate(ring)
                else
                 str = translate(label owner usage default)
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
             call select_ring
             if (ringf = NULL) then
              sort     = 'RING,C,A'
             else
              sort     = 'LABEL,C,A'
             xtdtop   = 1
        END
        WHEN (abbrev("SAVE",zcmd,2) = 1) then DO
             if (ringf = NULL) then
              TMPSKELT = SKELETON1
             else
              TMPSKELT = SKELETON2
             call do_SAVE
        END
        when (ABBREV("SORT",ZCMD,1) = 1) THEN DO
             if (ringf = NULL) then do
              SELECT
                when (ABBREV("RING",PARM,1) = 1) then
                     call sortseq 'RING'
                otherwise NOP
              END
             end
            else do
              SELECT
                when (ABBREV("LABEL",PARM,1) = 1) then
                     call sortseq 'LABEL'
                when (ABBREV("OWNER",PARM,1) = 1) then
                     call sortseq 'OWNER'
                when (ABBREV("USAGE",PARM,1) = 1) then
                     call sortseq 'USAGE'
                when (ABBREV("DEFAULT",PARM,1) = 1) then
                     call sortseq 'DEFAULT'
                otherwise NOP
              END
            end
        END
        OTHERWISE NOP
     End /* Select */
     CLRRING  = "GREEN"; CLROWNE = "GREEN"
     CLRLABE  = "GREEN"; CLRUSAG = "GREEN"; CLRDEFA = "GREEN"
     PARSE VAR SORT LOCARG "," .
     INTERPRET "CLR"SUBSTR(LOCARG,1,4)" = 'TURQ'"
     "TBSORT" TABLEA "FIELDS("sort")"
     "TBTOP " TABLEA
     ZCMD = ""; PARM = ""
     'control display save'
     Select
        when (opta = 'L') then call racfring user ring
        when (opta = 'A') then call ADDR
        when (opta = 'D') then call DELR
        when (opta = 'C') then call CONL
        when (opta = 'R') then call REML
        when (opta = 'S') then call listl
        when (opta = 'X') then call listl
        when (opta = 'H') then call listl
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
        if (ringf = NULL) then
         testit = translate(ring)
        else
         testit = translate(label owner usage default)
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
     cmd = "racdcert "owner" export(label('"LABEL"')) dsn("xdsn")"
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
  END
  ELSE DO
     IF (OPTA = "S") THEN
      cmd = "racdcert "owner" list(label('"LABEL"'))"
     ELSE
      cmd = "racdcert "owner" listchain(label('"LABEL"'))"
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
        X = MSG("ON")                                         /* @A1 */
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
/*  Add ring                                                          */
/*--------------------------------------------------------------------*/
ADDR:
  "DISPLAY PANEL("PANEL03")"
  if (rc > 0) then return
  cmd = "RACDCERT ID("user") ADDRING("ringa")"
  x = OUTTRAP('var.')
  address TSO cmd
  cmd_rc = rc
  x = OUTTRAP('OFF')
  if (SETMSHOW <> 'NO') then
    call SHOWCMD

  if (cmd_rc = 0) then do
     if ring = 'NONE' then                                    /* @JK */
       "TBDELETE" TABLEA
     call select_ring
   end
  else call racfmsgs 'ERR23' var.1 /* error adding ring */
RETURN
/*--------------------------------------------------------------------*/
/*  Delete ring                                                       */
/*--------------------------------------------------------------------*/
DELR:
  if (ring = 'NONE') then                                     /* @JK */
     return
  msg    ='You are about to delete 'ring
  Sure_? = RACFMSGC(msg)
  if (sure_? = 'YES') then do
    cmd = "RACDCERT ID("user") DELRING("ring")"
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
         ring='NO'
         "TBMOD" TABLEA
        end
      end
     else
        CALL racfmsgs "ERR22" var.1 /* error deleting ring */
  end
RETURN
/*--------------------------------------------------------------------*/
/*  Connect label certificate to ring */
/*--------------------------------------------------------------------*/
CONL:
  "DISPLAY PANEL("PANEL04")"
  if (rc > 0) then return
  IF (OWNERC='SITE' | OWNERC='CERTAUTH') THEN
   cmd = "RACDCERT CONNECT("OWNERC" LABEL('"LABELC"') RING("RING") "
  ELSE
   cmd = "RACDCERT CONNECT(ID("OWNERC") LABEL('"LABELC"') RING("RING") "
  if (DFC ='YES') then cmd = cmd || "DEFAULT"
  cmd = cmd || " USAGE("USAGEC")) ID("USER")"
  x = OUTTRAP('var.')
  address TSO cmd
  cmd_rc = rc
  x = OUTTRAP('OFF')
  if (SETMSHOW <> 'NO') then
    call SHOWCMD

  if (cmd_rc = 0) then do
     if label = 'NO' then
       "TBDELETE" TABLEA
     CALL select_ring
   end
  else call racfmsgs 'ERR24' var.1 /* error connecting */
RETURN
/*--------------------------------------------------------------------*/
/*  Remove label certificate from ring                                */
/*--------------------------------------------------------------------*/
REML:
  if (label = 'NO') then
     return
  msg    ='You are about to remove 'label
  Sure_? = RACFMSGC(msg)
  if (sure_? = 'YES') then do
    cmd = "RACDCERT REMOVE("OWNER" LABEL ('"LABEL"') RING("RING")) ID("USER")"
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
         label   ='NO'
         owner   = ''
         usage   = ''
         default = ''
         "TBMOD" TABLEA
        end
      end
     else
        CALL racfmsgs "ERR25" var.1 /* error removing */
  end
RETURN
