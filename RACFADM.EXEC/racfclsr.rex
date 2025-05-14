/*%NOCOMMENT====================* REXX *==============================*/
/*  PURPOSE:  RACFADM - General Resources - Option 4, List classes    */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @BJ  250513  TRIDJK   Add primary command ALL                      */
/* @BI  241022  TRIDJK   Add primary command CDT                      */
/* @BH  240914  TRIDJK   Add Description to TABLEA and *Action for L/S*/
/* @BG  240913  TRIDJK   Add primary command CLASSes                  */
/* @BF  240906  TRIDJK   Add primary command SETRopts                 */
/* @BE  240905  TRIDJK   ERR28 if 'INVALID RACLIST' on REFRESH        */
/* @BD  240206  TRIDJK   Set MSG("ON") if PF3 in SAVE routine         */
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
  "VGET (SETGDISP SETMADMN SETMSHOW SETMTRAC",                /* @B3 */
        "SETMIRRX) PROFILE"

  If (SETMTRAC <> 'NO') then do                               /* @AW */
     Say "*"COPIES("-",70)"*"                                 /* @AW */
     Say "*"Center("Begin Program = "REXXPGM,70)"*"           /* @AW */
     Say "*"COPIES("-",70)"*"                                 /* @AW */
     if (SETMTRAC <> 'PROGRAMS') THEN                         /* @AX */
        interpret "Trace "SUBSTR(SETMTRAC,1,1)                /* @AW */
  end                                                         /* @AW */

  If (SETMADMN = "YES") then                                  /* @AC */
      SELCMDS = "ÝS¨ShowÝL¨ListÝR¨Refresh"                    /* @AL */
  else                                                        /* @AC */
      SELCMDS = "ÝS¨ShowÝL¨List"                              /* @AL */

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
                  "NAMES(ACTION CDESC) REPLACE NOWRITE"       /* @BH */
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
  Call Class_desc                                             /* @BH */

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
                 & (class <> 'GROUP') then do
                   cdesc = c.class                            /* @BH */
                   "TBMOD" TABLEA
                   end
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
                 & (class <> 'GROUP') then DO
                   cdesc = c.class                            /* @BH */
                   "TBMOD" TABLEA
                   end
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
                str = translate(class action cdesc)           /* @BH */
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
        When (abbrev("CDT",zcmd,3) = 1) then DO               /* @BI */
             /* Interface to SDSF */                          /* @BI */
             if parm = '' then                                /* @BI */
               parm = 'ALL'                                   /* @BI */
             "ADDRESS ISPEXEC"                                /* @BI */
             "CONTROL DISPLAY SAVE"                           /* @BI */
             "SELECT PGM(ISFISP) NEWAPPL(ISF) NOCHECK",       /* @BI */
                    "PARM(RAC "parm")"                        /* @BI */
             "CONTROL DISPLAY RESTORE"                        /* @BI */
        END                                                   /* @BI */
        When (abbrev("RCLS",zcmd,4) = 1) then DO              /* @BI */
             /* Interface to MXI using the MXIREXX API*/      /* @BI */
             cmd = "RCLS"                                     /* @BI */
             cmdrec.0 = 0                                     /* @BI */
             cmdrec. = ""                                     /* @BI */
             x = MXIREXX('cmdrec.',cmd)                       /* @BI */
             call display_info                                /* @BI */
        END                                                   /* @BI */
        When (abbrev("CLASSES",zcmd,5) = 1) then DO           /* @BG */
             call RACFLOG $CLASSES                            /* @BG */
        END                                                   /* @BG */
        When (abbrev("ALL",zcmd,3) = 1) then DO               /* @JK */
             call ALL_Classes                                 /* @JK */
        END                                                   /* @JK */
        When (abbrev("SETROPTS",zcmd,4) = 1) then DO          /* @BF */
             if parm = '' then                                /* @BF */
               parm = 'NONE'                                  /* @BF */
             if (SETMIRRX = 'YES') then                       /* @BF */
               call RACFPROF '_SETROPTS' '_SETROPTS' parm     /* @BF */
        END                                                   /* @BF */
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
        when (opta = 'S') then do   /* call generic */
             action = '*Shown'                                /* @BH */
             "TBMOD" TABLEA                                   /* @BH */
             call RACFCLSG class '**' 'YES'
             end
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
        testit = translate(class action cdesc)                /* @BH */
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
if (SETMIRRX = 'YES') then do                                 /* @BE */
  if chkrac() = 'NO' then do                                  /* @BE */
    say class 'is not RACLISTed'                              /* @BE */
    return                                                    /* @BE */
    end                                                       /* @BE */
  end                                                         /* @BE */
  msg    = 'You are about to refresh class',                  /* @BE */
            class 'in RACLIST'                                /* @BE */
  Sure_? = RACFMSGC(msg)
  if (sure_? = 'YES') then do
     call EXCMD "SETR RACLIST("class") REFRESH"
     if (cmd_rc <> 0) then                                    /* @AO */
       if (subword(msg.1,1,3)) = 'IKJ56702I INVALID RACLIST,' |,
          (subword(msg.1,1,2)) = 'INVALID RACLIST,' then      /* @BE */
         call racfmsgs 'ERR28' class                          /* @BE */
       else
         call racfmsgs "ERR10" /* CMD FAILED */
     else do
        action = '*Refreshed'                                 /* @BH */
        "TBMOD" TABLEA
     end
  end
RETURN
/*--------------------------------------------------------------------*/
/*  Check RACLIST                                                     */
/*--------------------------------------------------------------------*/
CHKRAC:                                                       /* @BE */
myrc=IRRXUTIL("EXTRACT","_SETROPTS","_SETROPTS","CLS")        /* @BE */
if (word(myrc,1)<>0) then do                                  /* @BE */
   say "MYRC="myrc                                            /* @BE */
   say "An IRRXUTIL or R_admin error occurred"                /* @BE */
end                                                           /* @BE */
rac_listed = ''                                               /* @BE */
do t = 1 to CLS.BASE.RACLIST.0                                /* @BE */
  rac_listed = rac_listed cls.base.raclist.t                  /* @BE */
  end                                                         /* @BE */
if wordpos(class,rac_listed) = 0 then                         /* @BE */
  return 'NO'                                                 /* @BE */
else                                                          /* @BE */
  return 'YES'                                                /* @BE */
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
  if cmd_rc = 0 then do
    action = '*List'
    "TBMOD" TABLEA
    end
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
     else do
        action = '*List'
        "TBMOD" TABLEA
     end
  end                                                         /* @AM */
DISPLAY_INFO:
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
        X = MSG("ON")                                         /* @BD */
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
/*--------------------------------------------------------------------*/
/*  Add all resource classes                                     @BJ  */
/*--------------------------------------------------------------------*/
ALL_Classes:
  last_line = sourceline()
  do i = last_line to 1 by -1
    line = sourceline(i)
    if line = "/* Ben Marino */" then leave
    end
  last_line = sourceline()

  do j = i+1 to last_line
    line = sourceline(j)
    if line = "/* Ben Marino */" then leave
    if left(line,2) = 'c.' then do
      class = substr(line,3,8)
      cdesc = substr(line,15,57)
      "TBMOD" TABLEA "ORDER"
      end
    end
RETURN
/*--------------------------------------------------------------------*/
/*  General resource profile descriptions                        @BH  */
/*--------------------------------------------------------------------*/
Class_desc:                                                   /* @BH */
c.         = ""
/* Ben Marino */
c.$ZEMFCLS = "Controls zEMF SMF Exits Management Facility              "
c.$ZRMSCLS = "Controls zRMS Resource Monitor Subsystem                 "
c.$ZSVCCLS = "Controls zRMS Resource Monitor Subsystem                 "
c.APICLASS = "Controls zXPC System Events Listener API                 "
c.AUDITSVC = "Controls zXPC System Events Listener API                 "
c.ECFCLASS = "Controls zECF Event Capture Facility                     "
c.XPCCLASS = "Controls zXPC System Events Listener API                 "

c.ACEECHK  = "Configuration of RACF ACEE Privilege Escalation Detection"
c.ALCSAUTH = "Supports the Airline Control System/MVS (ALCS/MVS)       "
c.APPCLU   = "Verifying the identity of partner logical units during   "
c.APPCPORT = "Controlling which user IDs can access the system from a  "
c.APPCSERV = "Controlling whether a program being run by a user can    "
c.APPCSI   = "Controlling access to APPC side information files        "
c.APPCTP   = "Controlling the use of APPC transaction programs         "
c.APPL     = "Controlling access to applications                       "
c.CACHECLS = "Contains profiles used for saving and restoring cache    "
c.CBIND    = "Controlling the client's ability to bind to the server   "
c.CDT      = "Contains profiles for installation-defined classes       "
c.CFIELD   = "Contains profiles that define the installation's custom  "
c.CONSOLE  = "Controlling access to MCS consoles                       "
c.DASDVOL  = "DASD volumes                                             "
c.DBNFORM  = "Reserved for future IBM use                              "
c.DEVICES  = "Used by MVS allocation to control who can allocate       "
c.DIGTCERT = "Contains digital certificates and info that is related   "
c.DIGTCRIT = "Specifies additional criteria for certificate name       "
c.DIGTNMAP = "Mapping class for certificate name filters               "
c.DIGTRING = "Contains a profile for each key ring                     "
c.DIRAUTH  = "Setting logging options for RACROUTE REQUEST=DIRAUTH     "
c.DLFCLASS = "The data lookaside facility                              "
c.FACILITY = "Miscellaneous uses. Profiles are defined in this class   "
c.FIELD    = "Fields in RACF profiles (field-level access checking)    "
c.GDASDVOL = "Resource group class for DASDVOL class                   "
c.GLOBAL   = "Global access checking table entry                       "
c.GMBR     = "Member class for the GLOBAL class                        "
c.GSDSF    = "Resource group class for SDSF class                      "
c.GSOMDOBJ = "Secure GSOMDOBJ for z/OS objects                         "
c.GTERMINL = "Resource group class for TERMINAL class                  "
c.GXFACILI = "Grouping class for XFACILIT resources                    "
c.HBRADMIN = "Controls whether server resources are enabled or disabled"
c.HBRCMD   = "Specifies user IDs auth to issue zRES commands           "
c.HBRCONN  = "Specifies user IDs auth to connect to zRES exec rule sets"
c.IBMOPC   = "Controlling access to OPC/ESA subsystems                 "
c.IDIDMAP  = "Contains distributed identity filters created with RACMAP"
c.IDTDATA  = "Controls Identity Tokens                                 "
c.IZP      = "Controls resources related to the IBM Unified Mgt Server "
c.JESINPUT = "Conditional access support for jobs entered via JES input"
c.JESJOBS  = "Controlling the submission and cancellation of jobs      "
c.JESSPOOL = "Controlling access to job data sets on the JES spool     "
c.KEYSMSTR = "Contains profiles that hold keys to encrypt data         "
c.LDAP     = "Controls authorization roles for LDAP administration     "
c.LDAPBIND = "Contains the LDAP server URL, bind DN, and bind password "
c.LOGSTRM  = "Controls system logger resources, such as log streams    "
c.NODES    = "Controlling where jobs are allowed to enter the system   "
c.NODMBR   = "Member class for the NODES class                         "
c.OPERCMDS = "Controlling who can issue operator commands              "
c.OPTAUDIT = "Contains profiles which control RACF logging behavior    "
c.PKISERV  = "Controls access to R_PKIServ administration functions    "
c.PMBR     = "Member class for the PROGRAM class                       "
c.PROGRAM  = "Protects executable programs                             "
c.PROPCNTL = "Controlling if user ID propagation can occur             "
c.PSFMPL   = "Used by PSF to perform security functions for printing   "
c.PTKTDATA = "Enables a RACF secured signon secret key with application"
c.RACFEVNT = "LDAP change log notification for changes to RACF profiles"
c.RACFHC   = "Used by IBM Health Checker for z/OS                      "
c.RACFVARS = "RACF variables. Profile names act as RACF variables      "
c.RACGLIST = "Profiles holding results RACROUTE REQUEST=LIST,GLOBAL=YES"
c.RACHCMBR = "Used by IBM Health Checker for z/OS                      "
c.RDATALIB = "Used to control use of the R_datalib callable service    "
c.RRSFDATA = "Used to control RACF remote sharing facility (RRSF)      "
c.RVARSMBR = "Member class for the RACFVARS class                      "
c.SCDMBR   = "Member class for the SECDATA class                       "
c.SDSF     = "Controls the use of authorized commands in the System    "
c.SECDATA  = "Security classification of users and data                "
c.SECLABEL = "If security labels are used, and, their definitions      "
c.SECLMBR  = "Member class for the SECLABEL class                      "
c.SERVAUTH = "Contains profiles used to check client's auth to use srv "
c.SERVER   = "Controlling server's ability to register with the daemon "
c.SMESSAGE = "Controlling to which users a user can send messages      "
c.SOMDOBJS = "Controlling clients ability to invoke method in the class"
c.STARTED  = "Used to assign an identity during processing of START cmd"
c.SURROGAT = "Which user IDs can act as surrogates                     "
c.SYSAUTO  = "IBM Automation Control for z/OS resources                "
c.SYSMVIEW = "Controlling access by SystemView to MVS Launch Window    "
c.TAPEVOL  = "Tape volumes                                             "
c.TEMPDSN  = "Controlling who can access residual temporary data sets  "
c.TERMINAL = "Terminals (TSO or z/VM). See also GTERMINL class         "
c.VTAMAPPL = "Controlling who can open ACBs from non-APF auth programs "
c.WBEM     = "Controls access to the Common Information Model functions"
c.WRITER   = "Controlling the use of JES writers                       "
c.XFACILIT = "Miscellaneous uses. Profile names > 39 characters        "
c.ZOWE     = "Controls resources related to the Zowe project           "

c.ACICSPCT = "CICS program control table                               "
c.BCICSPCT = "Resource group class for the ACICSPCT class              "
c.CCICSCMD = "Used to verify that a user is permitted to use CICS      "
c.CPSMOBJ  = "Used to determine operational controls                   "
c.CPSMXMP  = "Used to identify exemptions from security                "
c.DCICSDCT = "CICS destination control table                           "
c.ECICSDCT = "Resource group class for the DCICSDCT class              "
c.FCICSFCT = "CICS file control table                                  "
c.GCICSTRN = "Resource group class for TCICSTRN class                  "
c.GCPSMOBJ = "Grouping class for CPSMOBJ                               "
c.HCICSFCT = "Resource group class for the FCICSFCT class              "
c.JCICSJCT = "CICS journal control table                               "
c.KCICSJCT = "Resource group class for the JCICSJCT class              "
c.MCICSPPT = "CICS processing program table                            "
c.NCICSPPT = "Resource group class for the MCICSPPT class              "
c.PCICSPSB = "CICS program specification blocks (PSBs)                 "
c.QCICSPSB = "Resource group class for the PCICSPSB class              "
c.RCICSRES = "CICS document templates                                  "
c.SCICSTST = "CICS temporary storage table                             "
c.TCICSTRN = "CICS transactions                                        "
c.UCICSTST = "Resource group class for SCICSTST class                  "
c.VCICSCMD = "Resource group class for the CCICSCMD class              "
c.WCICSRES = "Resource group class for the RCICSRES class              "

c.DSNADM   = "DB2 administrative authority class                       "
c.DSNR     = "Controls access to DB2 subsystems                        "
c.GDSNBP   = "Grouping class for DB2 buffer pool privileges            "
c.GDSNCL   = "Grouping class for DB2 collection privileges             "
c.GDSNDB   = "Grouping class for DB2 database privileges               "
c.GDSNGV   = "Grouping class for Db2z/OS global variables              "
c.GDSNJR   = "Grouping class for Java archive files (JARs)             "
c.GDSNPK   = "Grouping class for DB2 package privileges                "
c.GDSNPN   = "Grouping class for DB2 plan privileges                   "
c.GDSNSC   = "Grouping class for DB2 schemas privileges                "
c.GDSNSG   = "Grouping class for DB2 storage group privileges          "
c.GDSNSM   = "Grouping class for DB2 system privileges                 "
c.GDSNSP   = "Grouping class for DB2 stored procedure privileges       "
c.GDSNSQ   = "Grouping class for DB2 sequences                         "
c.GDSNTB   = "Grouping class for DB2 table, index, or view privileges  "
c.GDSNTS   = "Grouping class for DB2 tablespace privileges             "
c.GDSNUF   = "Grouping class for DB2 user-defined function privileges  "
c.GDSNUT   = "Grouping class for DB2 user-defined distinct type        "
c.MDSNBP   = "Member class for DB2 buffer pool privileges              "
c.MDSNCL   = "Member class for DB2 collection privileges               "
c.MDSNDB   = "Member class for DB2 database privileges                 "
c.MDSNGV   = "Member class for Db2z/OS global variables                "
c.MDSNJR   = "Member class for Java archive files (JARs)               "
c.MDSNPK   = "Member class for DB2 package privileges                  "
c.MDSNPN   = "Member class for DB2 plan privileges                     "
c.MDSNSC   = "Member class for DB2 schema privileges                   "
c.MDSNSG   = "Member class for DB2 storage group privileges            "
c.MDSNSM   = "Member class for DB2 system privileges                   "
c.MDSNSP   = "Member class for DB2 stored procedure privileges         "
c.MDSNSQ   = "Member class for DB2 sequences                           "
c.MDSNTB   = "Member class for DB2 table, index, or view privileges    "
c.MDSNTS   = "Member class for DB2 tablespace privileges               "
c.MDSNUF   = "Member class for DB2 user-defined function privileges    "
c.MDSNUT   = "Member class for DB2 user-defined distinct type          "

c.DCEUUIDS = "Used to define the mapping between a user's RACF user ID "

c.RAUDITX  = "Controls auditing for Enterprise Identity Mapping (EIM)  "

c.EJBROLE  = "Member class for Enterprise Java Beans authorization     "
c.GEJBROLE = "Grouping class for Enterprise Java Beans authorization   "
c.JAVA     = "Contains profiles that are used by Java for z/OS         "

c.AIMS     = "Application group names (AGN)                            "
c.CIMS     = "Command                                                  "
c.DIMS     = "Grouping class for command                               "
c.FIMS     = "Field (in data segment)                                  "
c.GIMS     = "Grouping class for transaction                           "
c.HIMS     = "Grouping class for field                                 "
c.IIMS     = "Program specification block (PSB)                        "
c.JIMS     = "Grouping class for program specification block (PSB)     "
c.LIMS     = "Logical terminal (LTERM)                                 "
c.MIMS     = "Grouping class for logical terminal (LTERM)              "
c.OIMS     = "Other                                                    "
c.PIMS     = "Database                                                 "
c.QIMS     = "Grouping class for database                              "
c.RIMS     = "Open Transaction Manager Access (OTMA) transaction pipe  "
c.SIMS     = "Segment (in database)                                    "
c.TIMS     = "Transaction (trancode)                                   "
c.UIMS     = "Grouping class for segment                               "
c.WIMS     = "Grouping class for other                                 "

c.CRYPTOZ  = "Controls access to PKCS #11 tokens                       "
c.CSFKEYS  = "Controls access to ICSF cryptographic keys               "
c.CSFSERV  = "Controls access to ICSF cryptographic services           "
c.GCSFKEYS = "Resource group class for the CSFKEYS class               "
c.GXCSFKEY = "Resource group class for the XCSFKEY class               "
c.XCSFKEY  = "Controls the exportation of ICSF cryptographic keys      "

c.PRINTSRV = "Controls access to printer definitions for Infoprint     "

c.GINFOMAN = "Grouping class for Information/Management (Tivoli        "
c.INFOMAN  = "Member class for Information/Management (Tivoli Service  "

c.LFSCLASS = "Controls access to file services provided by LFS/ESA     "

c.ILMADMIN = "Controls access to the administrative functions of IBM   "

c.NDSLINK  = "Mapping class for Novell Directory Services for OS/390   "
c.NOTELINK = "Mapping class for Lotus Notes for z/OS user identities   "

c.MFADEF   = "Contains profiles that define MFA factors                "

c.GMQADMIN = "Grouping class for MQSeries administrative options       "
c.GMQCHAN  = "Reserved for MQSeries                                    "
c.GMQNLIST = "Grouping class for MQSeries namelists                    "
c.GMQPROC  = "Grouping class for MQSeries processes                    "
c.GMQQUEUE = "Grouping class for MQSeries queues                       "
c.MQADMIN  = "Protects MQSeries administrative options                 "
c.MQCHAN   = "Reserved for MQSeries                                    "
c.MQCMDS   = "Protects MQSeries commands                               "
c.MQCONN   = "Protects MQSeries connections                            "
c.MQNLIST  = "Protects MQSeries namelists                              "
c.MQPROC   = "Protects MQSeries processes                              "
c.MQQUEUE  = "Protects MQSeries queues                                 "

c.NETCMDS  = "Controls NetView cmds the NetView Op can issue           "
c.NETSPAN  = "Controls NetView cmds the NetView Op can issue in span   "
c.NVASAPDT = "NetView/Access Services                                  "
c.PTKTVAL  = "Used by NetView/Access Services SSI for PassTickets      "

c.RMTOPS   = "NetView Remote Operations                                "
c.RODMMGR  = "NetView Resource Object Data Manager (RODM)              "

c.KERBLINK = "Contains profiles that map local and foreign principals  "
c.REALM    = "Used to define the local and foreign realms              "

c.MGMTCLAS = "SMS management classes                                   "
c.STORCLAS = "SMS storage classes                                      "
c.SUBSYSNM = "Authorizes subsystem to open a VSAM ACB and use VSAM RLS "

c.ROLE     = "Specifies resources and associated access levels req'd   "
c.TMEADMIN = "Maps the user IDs of Tivoli administrators to RACF user  "

c.ACCTNUM  = "TSO account numbers                                      "
c.PERFGRP  = "TSO performance groups                                   "
c.TSOAUTH  = "TSO user authorities such as OPER and MOUNT              "
c.TSOPROC  = "TSO logon procedures                                     "

c.GMXADMIN = "Grouping class for WebSphere MQ administrative options   "
c.GMXNLIST = "Grouping class for WebSphere MQ namelists                "
c.GMXPROC  = "Grouping class for WebSphere MQ processes                "
c.GMXQUEUE = "Grouping class for WebSphere MQ queues                   "
c.GMXTOPIC = "Grouping class for WebSphere MQ topics                   "
c.MXADMIN  = "Protects WebSphere MQ administrative options             "
c.MXNLIST  = "Protects WebSphere MQ namelists                          "
c.MXPROC   = "Protects WebSphere MQ processes                          "
c.MXQUEUE  = "Protects WebSphere MQ queues                             "
c.MXTOPIC  = "Protects WebSphere MQ topics                             "

c.ZMFAPLA  = "Member class for z/OSMF authorization roles              "
c.GZMFAPLA = "Grouping class for z/OSMF authorization roles            "
c.ZMFCLOUD = "Protects z/OS cloud resources                            "

c.DIRACC   = "Controls auditing for access checks for read/write access"
c.DIRSRCH  = "Controls auditing of z/OS UNIX directory searches        "
c.FSACCESS = "Controls access to z/OS UNIX file systems                "
c.FSEXEC   = "Controls execute access to z/OS UNIX file systems        "
c.FSOBJ    = "Controls auditing of all access checks to z/OS UNIX files"
c.FSSEC    = "Controls auditing of changes to the security data (FSP)  "
c.IPCOBJ   = "Controls auditing of access checks for IPC objects       "
c.PROCACT  = "Controls auditing of functions that affect Unix processes"
c.PROCESS  = "Controls auditing of changes to UIDs and GIDs            "
c.UNIXMAP  = "Contains profiles used to map UIDs/GIDs to Userids/Groups"
c.UNIXPRIV = "Contains profiles that are used to grant UNIX privileges "
RETURN
