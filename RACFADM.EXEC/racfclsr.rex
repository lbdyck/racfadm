/*%NOCOMMENT====================* REXX *==============================*/
/*  PURPOSE:  RACFADM - General Resources - Option 4, List classes    */
/*--------------------------------------------------------------------*/
/* FLG  YYMhDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @BC  220317  LBD      Close table on exit                          */
/* @BB  200618  RACFA    Chged SYSDA to SYSALLDA                      */
/* @BA  200617  RACFA    Added comments to right of variables         */
/* @B9  200616  RACFA    Added capability to SAve file as TXT/CSV     */
/* @B8  200610  RACFA    Added primary command 'SAVE'                 */
/* @B7  200506  RACFA    Drop array immediately when done using       */
/* @B6  200502  RACFA    Re-worked displaying tables, use DO FOREVER  */
/* @B5  200501  LBD      Add primary commands FIND/RFIND              */
/* @B4  200430  RACFA    Chg tbla to TABLEA, moved def. var. up top   */
/* @B3  200429  RACFA    Re-arranged variables (General, Mgmt, TSO)   */
/* @B2  200424  RACFA    Move DDNAME at top, standardize/del dups     */
/* @B1  200423  RACFA    Move PARSE REXXPGM name up above IF SETMTRAC */
/* @AZ  200422  RACFA    Ensure the REXX program name is 8 chars      */
/* @AY  200422  RACFA    Use variable REXXPGM in log msg              */
/* @AX  200413  RACFA    Chg TRACEing to only display banner (P=Pgms) */
/* @AW  200412  RACFA    Chg TRACE to allow 'L'abels or 'R'esults     */
/* @AV  200407  RACFA    EXCMD removed 'else msg_var = 1 to msg.0'    */
/* @AU  200402  RACFA    Chg LRECL=132 to LRECL=80                    */
/* @AT  200401  RACFA    Chged edit macro RACFLOGE to RACFEMAC        */
/* @AS  200401  RACFA    VIEW/EDIT use edit macro, to turn off HILITE */
/* @AR  200330  RACFA    Allow point-n-shoot sort ascending/descending*/
/* @AQ  200324  RACFA    Allow both display/logging of RACF commands  */
/* @AP  200324  RACFA    Allow logging RACF commands to ISPF Log file */
/* @AO  200303  RACFA    Chg 'RC/Ret_code' to 'cmd_rc' after EXCMD    */
/* @AN  200303  RACFA    Chg 'RL class ALL' to 'RL class * ALL'       */
/* @AM  200303  RACFA    Chk RC 'RL cls prms', if RC>0 then 'RL cls'  */
/* @AL  200303  RACFA    Added line cmd 'L-List'                      */
/* @AK  200226  RACFA    Fix @AI chg, chg ret_code to cmd_rc          */
/* @AJ  200226  RACFA    Added 'CONTROL ERRORS RETURN'                */
/* @AI  200226  RACFA    Added 'Return Code =' when displaying cmd    */
/* @AH  200226  RACFA    Removed double quotes before/after cmd       */
/* @AG  200224  RACFA    Standardize quotes, chg single to double     */
/* @AF  200224  RACFA    Place panels at top of REXX in variables     */
/* @AE  200223  RACFA    Del 'address TSO "PROFILE MSGID"', not needed*/
/* @AD  200223  RACFA    Added primary command SORT                   */
/* @AC  200223  RACFA    Use dynamic area to display SELECT commands  */
/* @AB  200222  RACFA    Removed translating OPTA/B, not needed       */
/* @AA  200222  RACFA    Allow placing cursor on row and press ENTER  */
/* @A9  200221  RACFA    Added primary commands 'ONLY' and 'RESET'    */
/* @A8  200221  RACFA    Allow abbreviating the 'LOCATE' command      */
/* @A7  200221  RACFA    Make 'ADDRESS ISPEXEC' defualt, reduce code  */
/* @A6  200220  RACFA    Fixed displaying all RACF commands           */
/* @A5  200220  RACFA    Added SETMTRAC=YES, then TRACE R             */
/* @A4  200218  RACFA    Condense VGETs into one line                 */
/* @A3  200120  RACFA    Removed 'say msg.msg_var' in EXCMD procedure */
/* @A2  200119  RACFA    Standardized/reduced lines of code           */
/* @A1  200119  RACFA    Placed comment boxes above procedures        */
/* @A0  011229  NICORIZ  Created REXX, V2.1, www.rizzuto.it           */
/*====================================================================*/
PANEL27     = "RACFCLSR"   /* List classes (show, refresh) */ /* @AF */
PANELM2     = "RACFMSG2"   /* Display RACF command and RC  */ /* @AF */
PANELS1     = "RACFSAVE"   /* Obtain DSName to SAVE        */ /* @B8 */
SKELETON1   = "RACFCLSR"   /* Save tablea to dataset       */ /* @B8 */
EDITMACR    = "RACFEMAC"   /* Edit Macro, turn HILITE off  */ /* @AT */
TABLEA      = 'TA'RANDOM(0,99999)  /* Unique table name A  */ /* @B4 */
DDNAME      = 'RACFA'RANDOM(0,999) /* Unique ddname        */ /* @B2 */
parse source . . REXXPGM .         /* Obtain REXX pgm name */ /* @B1 */
REXXPGM     = LEFT(REXXPGM,8)                                 /* @B1 */
NULL        = ''                                              /* @B5 */

ADDRESS ISPEXEC                                               /* @A7 */
  Arg class
  "CONTROL ERRORS RETURN"                                     /* @AJ */
  "VGET (SETGDISP SETMADMN SETMSHOW SETMTRAC) PROFILE"        /* @B3 */

  If (SETMTRAC <> 'NO') then do                               /* @AW */
     Say "*"COPIES("-",70)"*"                                 /* @AW */
     Say "*"Center("Begin Program = "REXXPGM,70)"*"           /* @AW */
     Say "*"COPIES("-",70)"*"                                 /* @AW */
     if (SETMTRAC <> 'PROGRAMS') THEN                         /* @AX */
        interpret "Trace "SUBSTR(SETMTRAC,1,1)                /* @AW */
  end                                                         /* @AW */

  If (SETMADMN = "YES") then                                  /* @AC */
      SELCMDS = "ÝS¨Show,ÝL¨List,ÝR¨Refresh"                  /* @AL */
  else                                                        /* @AC */
      SELCMDS = "ÝS¨Show,ÝL¨List"                             /* @AL */

  rlv = SYSVAR('SYSLRACF')
  if (class = '') then DO                                     /* @A9 */
     call Select_class
     rc = display_table()                                     /* @A9 */
     "TBEND" TABLEA                                           /* @A9 */
  END                                                         /* @A9 */
  else
     call RACFCLSG class '**' 'YES' /*generic prof routine*/

  If (SETMTRAC <> 'NO') then do                               /* @AW */
     Say "*"COPIES("-",70)"*"                                 /* @AW */
     Say "*"Center("End Program = "REXXPGM,70)"*"             /* @AW */
     Say "*"COPIES("-",70)"*"                                 /* @AW */
  end                                                         /* @AW */
EXIT
/*--------------------------------------------------------------------*/
/*  Select class                                                      */
/*--------------------------------------------------------------------*/
SELECT_CLASS:
  seconds = time('S')
  "TBCREATE" TABLEA "KEYS(CLASS)",
                  "NAMES(ACTION) REPLACE NOWRITE"
  call get_act_class
  sort     = 'CLASS,C,A'                                      /* @B6 */
  sortclas = 'D'                                              /* @B6 */
  "TBSORT " TABLEA "FIELDS("sort")"                           /* @B6 */
  "TBTOP  " TABLEA                                            /* @B6 */
RETURN
/*--------------------------------------------------------------------*/
/*  Display profile permits                                           */
/*--------------------------------------------------------------------*/
GET_ACT_CLASS:
  Scan = 'OFF'
  cmd  = "SETROPTS LIST"                                      /* @A6 */
  x = OUTTRAP('var.')
  address TSO cmd                                             /* @A6 */
  cmd_rc = rc                                                 /* @AI */
  x = OUTTRAP('OFF')
  if (SETMSHOW <> 'NO') then                                  /* @AP */
     call SHOWCMD                                             /* @A6 */
  Do i = 1 to var.0         /* Scan output */
     temp = var.i
     if (rlv > '1081') then  /* RACF 1.9 add blank */
        temp= ' 'temp
     Select
        when (substr(temp,2,16) = 'ACTIVE CLASSES =') then do
             scan   = 'ON'
             record = substr(temp,18,80)
             nwords = words(record)
             do t = 1 to nwords
                class = subword(record,t,1)
                if (class <> 'USER'),
                 & (class <> 'DATASET'),
                 & (class <> 'GROUP') then
                   "TBMOD" TABLEA
             end
        end
        when (substr(temp,2,25) = 'GENERIC',
             'PROFILE CLASSES =') then leave
        otherwise
          if (scan = 'ON') then do
             record = var.i
             nwords = words(record)
             do t = 1 to nwords
                class = subword(record,t,1)
                if (class <> 'USER'),
                 & (class <> 'DATASET'),
                 & (class <> 'GROUP') then
                   "TBMOD" TABLEA
             end
        end
     End  /* end_select */
  end /* do i */
RETURN
/*--------------------------------------------------------------------*/
/*  Profiles table display section                                    */
/*--------------------------------------------------------------------*/
DISPLAY_TABLE:
  opta   = ' '
  xtdtop = 0                                                  /* @B6 */
  rsels  = 0                                                  /* @B6 */
  do forever                                                  /* @B6 */
     if (rsels < 2) then do                                   /* @B6 */
        "TBTOP " TABLEA                                       /* @B6 */
        'tbskip' tablea 'number('xtdtop')'                    /* @B6 */
        radmrfnd = 'PASSTHRU'                                 /* @B6 */
        'vput (radmrfnd)'                                     /* @B6 */
        "TBDISPL" TABLEA "PANEL("PANEL27")"                   /* @B6 */
     end                                                      /* @B6 */
     else 'tbdispl' tablea                                    /* @B6 */
     if (rc > 4) then do                                      /* @BC */
        src = rc                                              /* @BC */
        'tbclose' tablea                                      /* @BC */
         rc = src                                             /* @BC */
         leave                                                /* @BC */
         end                                                  /* @BC */
     xtdtop   = ztdtop                                        /* @B6 */
     rsels    = ztdsels                                       /* @B6 */
     radmrfnd = null                                          /* @B6 */
     'vput (radmrfnd)'                                        /* @B6 */
     PARSE VAR ZCMD ZCMD PARM SEQ                             /* @B6 */
     IF (SROW <> "") & (SROW <> 0) THEN                       /* @AA */
        IF (SROW > 0) THEN DO                                 /* @AA */
           "TBTOP " TABLEA                                    /* @AA */
           "TBSKIP" TABLEA "NUMBER("SROW")"                   /* @AA */
        END                                                   /* @AA */
     if (zcmd = 'RFIND') then do                              /* @B5 */
        zcmd = 'FIND'                                         /* @B5 */
        parm = findit                                         /* @B5 */
        'tbtop ' TABLEA                                       /* @B5 */
        'tbskip' TABLEA 'number('last_find')'                 /* @B5 */
     end                                                      /* @B5 */
     Select
        When (abbrev("FIND",zcmd,1) = 1) then                 /* @B5 */
             call do_find                                     /* @B5 */
        WHEN (ABBREV("LOCATE",ZCMD,1) = 1) THEN do            /* @B6 */
             if (parm <> '') then do                          /* @B6 */
                locarg = parm'*'                              /* @B6 */
                PARSE VAR SORT . "," . "," SEQ                /* @B6 */
                IF (SEQ = "D") THEN                           /* @B6 */
                   CONDLIST = "LE"                            /* @B6 */
                ELSE                                          /* @B6 */
                   CONDLIST = "GE"                            /* @B6 */
                parse value sort with scan_field',' .         /* @B6 */
                interpret scan_field ' = locarg'              /* @B6 */
                'tbtop ' tablea                               /* @B6 */
                "TBSCAN "TABLEA" ARGLIST("scan_field")",      /* @B6 */
                        "CONDLIST("CONDLIST")",               /* @B6 */
                        "position(scanrow)"                   /* @B6 */
                xtdtop = scanrow                              /* @B6 */
             end                                              /* @B6 */
        end                                                   /* @B6 */
        WHEN (ABBREV("ONLY",ZCMD,1) = 1) THEN DO              /* @A9 */
             find_str = translate(parm)                       /* @A9 */
             'tbtop ' TABLEA                                  /* @A9 */
             'tbskip' TABLEA                                  /* @A9 */
             do forever                                       /* @A9 */
                str = translate(class action)                 /* @A9 */
                if (pos(find_str,str) > 0) then nop           /* @A9 */
                else 'tbdelete' TABLEA                        /* @A9 */
                'tbskip' TABLEA                               /* @A9 */
                if (rc > 0) then do                           /* @A9 */
                   'tbtop' TABLEA                             /* @A9 */
                   leave                                      /* @A9 */
                end                                           /* @A9 */
             end                                              /* @A9 */
        END                                                   /* @A9 */
        WHEN (ABBREV("RESET",ZCMD,1) = 1) THEN DO             /* @A9 */
             call select_class                                /* @A9 */
             sort     = 'CLASS,C,A'                           /* @AD */
             sortclas = 'D'                                   /* @AR */
             xtdtop   = 1                                     /* @A9 */
        END                                                   /* @A9 */
        When (abbrev("SAVE",zcmd,2) = 1) then DO              /* @B8 */
             TMPSKELT = SKELETON1                             /* @B8 */
             call do_SAVE                                     /* @B8 */
        END                                                   /* @B8 */
        WHEN (ABBREV("SORT",ZCMD,1) = 1) THEN DO              /* @B6 */
             call sortseq 'CLASS'                             /* @AR */
             "TBSORT" TABLEA "FIELDS("sort")"                 /* @B6 */
             "TBTOP " TABLEA                                  /* @B6 */
        END
        OTHERWISE NOP                                         /* @A8 */
     End
     ZCMD = ""; PARM = ""                                     /* @B6 */
     'control display save'                                   /* @B6 */
     Select
        when (opta = 'L') then call lisp                      /* @AL */
        when (opta = 'R') then call REFRESH
        when (opta = 'S') then   /* call generic */
             call RACFCLSG class '**' 'YES'
        otherwise nop
     End
     'control display restore'                                /* @B6 */
  end  /* Do forever) */                                      /* @B6 */
RETURN 0
/*--------------------------------------------------------------------*/
/*  Process primary command FIND                                 @B5  */
/*--------------------------------------------------------------------*/
DO_FIND:                                                      /* @B5 */
  if (parm = null) then do                                    /* @B5 */
     racfsmsg = 'Error'                                       /* @B5 */
     racflmsg = 'Find requires a value to search for.' ,      /* @B5 */
                'Try again.'                                  /* @B5 */
     'setmsg msg(RACF011)'                                    /* @B5 */
     return                                                   /* @B5 */
  end                                                         /* @B5 */
  findit    = translate(parm)                                 /* @B5 */
  last_find = 0                                               /* @B5 */
  wrap      = 0                                               /* @B5 */
  do forever                                                  /* @B5 */
     'tbskip' TABLEA                                          /* @B5 */
     if (rc > 0) then do                                      /* @B5 */
        if (wrap = 1) then do                                 /* @B5 */
           racfsmsg = 'Not Found'                             /* @B5 */
           racflmsg = findit 'not found.'                     /* @B5 */
           'setmsg msg(RACF011)'                              /* @B5 */
           return                                             /* @B5 */
        end                                                   /* @B5 */
        if (wrap = 0) then wrap = 1                           /* @B5 */
        'tbtop' TABLEA                                        /* @B5 */
     end                                                      /* @B5 */
     else do                                                  /* @B5 */
        testit = translate(class action)                      /* @B5 */
        if (pos(findit,testit) > 0) then do                   /* @B5 */
           'tbquery' TABLEA 'position(srow)'                  /* @B5 */
           'tbtop'   TABLEA                                   /* @B5 */
           'tbskip'  TABLEA 'number('srow')'                  /* @B5 */
           last_find = srow                                   /* @B5 */
           xtdtop    = srow                                   /* @B5 */
           if (wrap = 0) then                                 /* @B5 */
              racfsmsg = 'Found'                              /* @B5 */
           else                                               /* @B5 */
              racfsmsg = 'Found/Wrapped'                      /* @B5 */
           racflmsg = findit 'found in row' srow + 0          /* @B5 */
           'setmsg msg(RACF011)'                              /* @B5 */
           return                                             /* @B5 */
        end                                                   /* @B5 */
     end                                                      /* @B5 */
  end                                                         /* @B5 */
RETURN                                                        /* @B5 */
/*--------------------------------------------------------------------*/
/*  Define sort sequence, to allow point-n-shoot sorting (A/D)   @AR  */
/*--------------------------------------------------------------------*/
SORTSEQ:                                                      /* @AR */
  parse arg sortcol                                           /* @AR */
  INTERPRET "TMPSEQ = SORT"substr(SORTCOL,1,4)                /* @AR */
  select                                                      /* @AR */
     when (seq <> "") then do                                 /* @AR */
          if (seq = 'A') then                                 /* @AR */
             tmpseq = 'D'                                     /* @AR */
          else                                                /* @AR */
             tmpseq = 'A'                                     /* @AR */
          sort = sortcol',C,'seq                              /* @AR */
     end                                                      /* @AR */
     when (seq = ""),                                         /* @AR */
        & (tmpseq = 'A') then do                              /* @AR */
           sort   = sortcol',C,A'                             /* @AR */
           tmpseq = 'D'                                       /* @AR */
     end                                                      /* @AR */
     Otherwise do                                             /* @AR */
        sort   = sortcol',C,D'                                /* @AR */
        tmpseq = 'A'                                          /* @AR */
     end                                                      /* @AR */
  end                                                         /* @AR */
  INTERPRET "SORT"SUBSTR(SORTCOL,1,4)" = TMPSEQ"              /* @AR */
RETURN                                                        /* @AR */
/*--------------------------------------------------------------------*/
/*  Refresh class                                                     */
/*--------------------------------------------------------------------*/
REFRESH:
  msg    = 'You are about to refresh class 'class
  Sure_? = RACFMSGC(msg)
  if (sure_? = 'YES') then do
     call EXCMD "SETR RACLIST("class") REFRESH"
     if (cmd_rc <> 0) then                                    /* @AO */
        call racfmsgs "ERR10" /* CMD FAILED */
     else do
        action = '*REFRESHED'
        "TBMOD" TABLEA
     end
  end
RETURN
/*--------------------------------------------------------------------*/
/*  Exec command                                                      */
/*--------------------------------------------------------------------*/
EXCMD:
  signal off error
  arg cmd
  x = OUTTRAP('msg.')
  address TSO cmd                                             /* @AH */
  cmd_rc = rc
  x = OUTTRAP('OFF')
  if (SETMSHOW <> 'NO') then                                  /* @AP */
     call SHOWCMD                                             /* @A6 */
  if (subword(msg.1,1,1)= 'ICH11009I') |,
     (subword(msg.1,1,1)= 'ICH10006I') |,
     (subword(msg.1,1,1)= 'ICH06011I') then
     raclist = 'YES'
RETURN
/*--------------------------------------------------------------------*/
/*  List class                                                   @AL  */
/*--------------------------------------------------------------------*/
LISP:
  cmd     = "RL "CLASS" * ALL"                                /* @AN */
  X = OUTTRAP("CMDREC.")
  ADDRESS TSO cmd
  cmd_rc = rc
  X = OUTTRAP("OFF")
  if (SETMSHOW <> 'NO') then                                  /* @AP */
     call SHOWCMD
  if (cmd_rc > 0) then do    /* Remove parms */               /* @AM */
     cmd     = "RL "CLASS" *"                                 /* @AN */
     X = OUTTRAP("CMDREC.")                                   /* @AM */
     ADDRESS TSO cmd                                          /* @AM */
     cmd_rc = rc                                              /* @AM */
     X = OUTTRAP("OFF")                                       /* @AM */
     if (SETMSHOW <> 'NO') then                               /* @AP */
        call SHOWCMD                                          /* @AM */
  end                                                         /* @AM */

  ADDRESS TSO "ALLOC F("DDNAME") NEW REUSE",
              "LRECL(80) BLKSIZE(0) RECFM(F B)",              /* @AU */
              "UNIT(VIO) SPACE(1 5) CYLINDERS"
  ADDRESS TSO "EXECIO * DISKW "DDNAME" (STEM CMDREC. FINIS"
  DROP CMDREC.                                                /* @B7 */
                                                              /* @B7 */
  "LMINIT DATAID(CMDDATID) DDNAME("DDNAME")"
  SELECT
     WHEN (SETGDISP = "VIEW") THEN
          "VIEW DATAID("CMDDATID") MACRO("EDITMACR")"         /* @AS */
     WHEN (SETGDISP = "EDIT") THEN
          "EDIT DATAID("CMDDATID") MACRO("EDITMACR")"         /* @AS */
     OTHERWISE
          "BROWSE DATAID("CMDDATID")"
  END
  ADDRESS TSO "FREE FI("DDNAME")"
  if (cmd_rc > 0) then                                        /* @AC */
     CALL racfmsgs "ERR10" /* Generic failure */              /* @AC */
RETURN
/*--------------------------------------------------------------------*/
/*  Display RACF command and return code                         @A6  */
/*--------------------------------------------------------------------*/
SHOWCMD:                                                      /* @A6 */
  IF (SETMSHOW = "BOTH") | (SETMSHOW = "DISPLAY") THEN DO     /* @AQ */
     PARSE VAR CMD MSG1 60 MSG2 121 MSG3                      /* @A6 */
     MSG4 = "Return code = "cmd_rc                            /* @AI */
     "ADDPOP ROW(6) COLUMN(4)"                                /* @AG */
     "DISPLAY PANEL("PANELM2")"                               /* @AF */
     "REMPOP"                                                 /* @AG */
  END                                                         /* @AP */
  IF (SETMSHOW = "BOTH") | (SETMSHOW = "LOG") THEN DO         /* @AQ */
     zerrsm = "RACFADM "REXXPGM" RC="cmd_rc                   /* @AY */
     zerrlm = cmd                                             /* @AP */
     'log msg(isrz003)'                                       /* @AP */
  END                                                         /* @AP */
RETURN                                                        /* @A6 */
/*--------------------------------------------------------------------*/
/*  Save table to dataset                                        @B8  */
/*--------------------------------------------------------------------*/
DO_SAVE:                                                      /* @B8 */
  X = MSG("OFF")                                              /* @B8 */
  "ADDPOP COLUMN(40)"                                         /* @B8 */
  "VGET (RACFSDSN RACFSMBR RACFSFIL RACFSREP) PROFILE"        /* @B9 */
  IF (RACFSDSN = "") THEN         /* SAve - Dataset Name  */  /* @BA */
     RACFSDSN = USERID()".RACFADM.REPORTS"                    /* @EK */
  IF (RACFSFIL = "") THEN         /* SAve - As (TXT/CVS)  */  /* @BA */
     RACFSFIL = "T"                                           /* @EL */
  IF (RACFSREP = "") THEN         /* SAve - Replace (Y/N) */  /* @BA */
     RACFSREP = "N"                                           /* @EK */
                                                              /* @B8 */
  DO FOREVER                                                  /* @B8 */
     "DISPLAY PANEL("PANELS1")"                               /* @B8 */
     IF (RC = 08) THEN DO                                     /* @B8 */
        "REMPOP"                                              /* @B8 */
        RETURN                                                /* @B8 */
     END                                                      /* @B8 */
     RACFSDSN = STRIP(RACFSDSN,,"'")                          /* @B8 */
     RACFSDSN = STRIP(RACFSDSN,,'"')                          /* @B8 */
     RACFSDSN = STRIP(RACFSDSN)                               /* @B8 */
     SYSDSORG = ""                                            /* @B8 */
     X = LISTDSI("'"RACFSDSN"'")                              /* @B8 */
     IF (SYSDSORG = "") | (SYSDSORG = "PS"),                  /* @B8 */
      | (SYSDSORG = "PO") THEN                                /* @B8 */
        NOP                                                   /* @B8 */
     ELSE DO                                                  /* @B8 */
        RACFSMSG = "Not PDS/Seq File"                         /* @B8 */
        RACFLMSG = "The dataset specified is not",            /* @B8 */
                  "a partitioned or sequential",              /* @B8 */
                  "dataset, please enter a valid",            /* @B8 */
                  "dataset name."                             /* @B8 */
       "SETMSG MSG(RACF011)"                                  /* @B8 */
       ITERATE                                                /* @B8 */
     END                                                      /* @B8 */
     IF (SYSDSORG = "PS") & (RACFSMBR <> "") THEN DO          /* @B8 */
        RACFSMSG = "Seq File - No mbr"                        /* @B8 */
        RACFLMSG = "This dataset is a sequential",            /* @B8 */
                  "file, please remove the",                  /* @B8 */
                  "member name."                              /* @B8 */
       "SETMSG MSG(RACF011)"                                  /* @B8 */
       ITERATE                                                /* @B8 */
     END                                                      /* @B8 */
     IF (SYSDSORG = "PO") & (RACFSMBR = "") THEN DO           /* @B8 */
        RACFSMSG = "PDS File - Need Mbr"                      /* @B8 */
        RACFLMSG = "This dataset is a partitioned",           /* @B8 */
                  "dataset, please include a member",         /* @B8 */
                  "name."                                     /* @B8 */
       "SETMSG MSG(RACF011)"                                  /* @B8 */
       ITERATE                                                /* @B8 */
     END                                                      /* @B8 */
                                                              /* @B8 */
     IF (RACFSMBR = "") THEN                                  /* @B8 */
        TMPDSN = RACFSDSN                                     /* @B8 */
     ELSE                                                     /* @B8 */
        TMPDSN = RACFSDSN"("RACFSMBR")"                       /* @B8 */
     DSNCHK = SYSDSN("'"TMPDSN"'")                            /* @B8 */
     IF (DSNCHK = "OK" & RACFSREP = "N") THEN DO              /* @B8 */
        RACFSMSG = "DSN/MBR Exists"                           /* @B8 */
        RACFLMSG = "Dataset/member already exists. ",         /* @B8 */
                  "Please type in "Y" to replace file."       /* @B8 */
        "SETMSG MSG(RACF011)"                                 /* @B8 */
        ITERATE                                               /* @B8 */
     END                                                      /* @B8 */
     LEAVE                                                    /* @B8 */
  END                                                         /* @B8 */
  "REMPOP"                                                    /* @B8 */
  "VPUT (RACFSDSN RACFSMBR RACFSFIL RACFSREP) PROFILE"        /* @B9 */
                                                              /* @B8 */
ADDRESS TSO                                                   /* @B8 */
  IF (RACFSREP = "Y" & RACFSMBR = "") |,                      /* @B8 */
     (DSNCHK <> "OK" & DSNCHK <> "MEMBER NOT FOUND"),         /* @B8 */
     THEN DO                                                  /* @B8 */
     "DELETE '"RACFSDSN"'"                                    /* @B8 */
     IF (RACFSMBR = "") THEN                                  /* @B8 */
        "ALLOC  FI(ISPFILE) DA('"RACFSDSN"') NEW",            /* @B8 */
            "REUSE SP(1 1) CYLINDER UNIT(SYSALLDA)",          /* @BB */
            "LRECL(80) RECFM(F B)"                            /* @B8 */
     ELSE                                                     /* @B8 */
        "ALLOC  FI(ISPFILE) DA('"RACFSDSN"') NEW",            /* @B8 */
            "REUSE SP(1 1) CYLINDER UNIT(SYSALLDA)",          /* @BB */
            "LRECL(80) RECFM(F B)",                           /* @B8 */
            "DSORG(PO) DSNTYPE(LIBRARY,2)"                    /* @B8 */
  END                                                         /* @B8 */
  ELSE                                                        /* @B8 */
     "ALLOC  FI(ISPFILE) DA('"RACFSDSN"') SHR REUSE"          /* @B8 */
                                                              /* @B8 */
ADDRESS ISPEXEC                                               /* @B8 */
  "FTOPEN"                                                    /* @B8 */
  "FTINCL "TMPSKELT                                           /* @B8 */
  IF (RACFSMBR = "") THEN                                     /* @B8 */
     "FTCLOSE"                                                /* @B8 */
  ELSE                                                        /* @B8 */
     "FTCLOSE NAME("RACFSMBR")"                               /* @B8 */
  ADDRESS TSO "FREE FI(ISPFILE)"                              /* @B8 */
                                                              /* @B8 */
  SELECT                                                      /* @B8 */
     WHEN (SETGDISP = "VIEW") THEN                            /* @B8 */
          "VIEW DATASET('"RACFSDSN"') MACRO("EDITMACR")"      /* @B8 */
     WHEN (SETGDISP = "EDIT") THEN                            /* @B8 */
          "EDIT DATASET('"RACFSDSN"') MACRO("EDITMACR")"      /* @B8 */
     OTHERWISE                                                /* @B8 */
          "BROWSE DATASET('"RACFSDSN"')"                      /* @B8 */
  END                                                         /* @B8 */
  X = MSG("ON")                                               /* @B8 */
                                                              /* @B8 */
RETURN                                                        /* @B8 */
