/*%NOCOMMENT====================* REXX *==============================*/
/*  PURPOSE:  RACFADM - Dataset Profiles - Menu option 3              */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @CN  220318  LBD      Close open table on exit                     */
/* @CM  200708  TRIDJK   Msg if selection list has no entries ('NONE')*/
/* @CL  200624  RACFA    Allow passing fully qual. dsn with quotes    */
/* @CK  200624  RACFA    Chg line cmd L, added datasets               */
/* @CJ  200618  RACFA    Chged SYSDA to SYSALLDA                      */
/* @CI  200617  RACFA    Added comments to right of variables         */
/* @CH  200616  RACFA    Added capability to SAve file as TXT/CSV     */
/* @CG  200610  RACFA    Added primary command 'SAVE'                 */
/* @CF  200604  RACFA    Fix, prevent from going to top of table      */
/* @CE  200527  RACFA    Fix, allow typing 'S' on multiple rows       */
/* @CD  200520  RACFA    Display line cmd 'P'rofile, when 'Admin=N'   */
/* @CC  200506  RACFA    Drop array immediately when done using       */
/* @CB  200504  TRIDJK   Adding, place in order, prior was at bottom  */
/* @CA  200502  RACFA    Re-worked displaying tables, use DO FOREVER  */
/* @C9  200501  LBD      Add primary commands FIND/RFIND              */
/* @C8  200430  RACFA    Chg tblb to TABLEB, moved def. var. up top   */
/* @C7  200430  RACFA    Chg tbla to TABLEA, moved def. var. up top   */
/* @C6  200429  RACFA    Re-arranged variables (General, Mgmt, TSO)   */
/* @C5  200424  RACFA    Fixed displaying error msg for PERMIT cmd    */
/* @C4  200424  RACFA    Updated RESET, pass filter, ex: R filter     */
/* @C3  200424  RACFA    Chg msg RACF013 to RACF012                   */
/* @C2  200424  RACFA    Move DDNAME at top, standardize/del dups     */
/* @C1  200423  RACFA    Move PARSE REXXPGM name up above IF SETMTRAC */
/* @BZ  200423  RACFA    'Status Interval' by percentage (SETGSTAP)   */
/* @BY  200422  RACFA    Ensure the REXX program name is 8 chars      */
/* @BX  200422  RACFA    Use variable REXXPGM in log msg              */
/* @BW  200413  RACFA    Chg TRACEing to only display banner (P=Pgms) */
/* @BV  200412  RACFA    Chg TRACE to allow 'L'abels or 'R'esults     */
/* @BU  200410  RACFA    Fixed sorting entries prior to displaying    */
/* @BT  200408  RACFA    Chg 'Dataset = NO' to NONE                   */
/* @BS  200407  RACFA    EXCMD removed 'else msg_var = 1 to msg.0'    */
/* @BR  200404  RACFA    'Admin RACF API = Y' then display 'P'rofile  */
/* @BQ  200402  RACFA    Chg LRECL=132 to LRECL=80                    */
/* @BP  200401  RACFA    Create subroutine to VIEW/EDIT/BROWSE        */
/* @BO  200401  RACFA    Chged edit macro RACFLOGE to RACFEMAC        */
/* @BN  200401  RACFA    VIEW/EDIT use edit macro, to turn off HILITE */
/* @BM  200330  RACFA    Chg RACFDSN5 point/shoot ascending/descending*/
/* @BL  200330  RACFA    Allow point-n-shoot sort ascending/descending*/
/* @BK  200324  RACFA    Allow both display/logging of RACF commands  */
/* @BJ  200324  RACFA    Allow logging RACF commands to ISPF Log file */
/* @BI  200316  RACFA    Prevent typing in 'L' line cmd next to '*'   */
/* @BH  200315  RACFA    Added line cmd 'P=Profile'                   */
/* @BG  200305  TRIDJK   TBDELETE if cmd_rc = 0 on DELDSD command     */
/* @BF  200303  RACFA    Chg 'ret_code' to 'cmd_rc' after EXCMD       */
/* @BE  200303  RACFA    Chg 'RL class ALL' to 'RL class * ALL'       */
/* @BD  200303  RACFA    Fixed chking RC and removed TBMOD, not needed*/
/* @BC  200303  RACFA    Chk RC 'LD dsn prms', if RC>0 then 'LD dsn'  */
/* @BB  200303  RACFA    Removed TBMOD in LISP procedure, not needed  */
/* @BA  200302  RACFA    Del TBTOP cmd, prior to TBSCAN for LOCATE    */
/* @B9  200301  RACFA    When grp/ids (RACFUSR5) don't display D-DSN  */
/* @B8  200301  RACFA    Display msg when id is an asterisk (*)       */
/* @B7  200301  RACFA    Fixed displaying userids, was ret_code       */
/* @B6  200301  RACFA    Del EMSG procedure, instead call racfmsgs    */
/* @B5  200228  RACFA    Check for 'NO ENTRIES MEET SEARCH CRITERIA'  */
/* @B4  200227  RACFA    Added line command 'D', display user datasets*/
/* @B3  200226  RACFA    Fix @AZ chg, chg ret_code to cmd_rc          */
/* @B2  200226  RACFA    Fixed 'L List' cmd, added single quotes      */
/* @B1  200226  RACFA    Added 'CONTROL ERRORS RETURN'                */
/* @AZ  200226  RACFA    Added 'Return Code =' when displaying cmd    */
/* @AY  200226  RACFA    Removed double quotes before/after cmd       */
/* @AX  200226  RACFA    Del address TSO "PROFILE PREF("USERID()")"   */
/* @AW  200226  RACFA    Removed 'ADDRESS TSO PROF NOPREFIX'          */
/* @AV  200224  RACFA    Standardize quotes, chg single to double     */
/* @AU  200224  RACFA    Place panels at top of REXX in variables     */
/* @AT  200223  RACFA    Fixed SORTed color column                    */
/* @AS  200223  RACFA    Fixed SORT DATASET                           */
/* @AR  200223  RACFA    Simplified SORT, removed FLD/DFL_SORT vars   */
/* @AQ  200222  RACFA    Allowing abbreviating the column in SORT cmd */
/* @AP  200222  RACFA    Removed translating OPTA/B, not needed       */
/* @AO  200222  RACFA    Allow placing cursor on row and press ENTER  */
/* @AN  200222  RACFA    Added primary commands 'SORT'                */
/* @AM  200221  RACFA    Added primary commands 'LOCATE'              */
/* @AL  200221  RACFA    Added primary commands 'ONLY' and 'RESET'    */
/* @AK  200221  RACFA    Removed "G = '(G)'", not referenced          */
/* @AJ  200221  RACFA    Make 'ADDRESS ISPEXEC' defualt, reduce code  */
/* @AI  200220  RACFA    Fixed displaying all RACF commands           */
/* @AH  200220  RACFA    Added SETMTRAC=YES, then TRACE R             */
/* @AG  200220  RACFA    Removed initializing SETGSTA variable        */
/* @AF  200220  RACFA    Added capability to browse/edit/view file    */
/* @AE  200218  RACFA    Use dynamic area to display SELECT commands  */
/* @AD  200218  RACFA    Added 'Status Interval' option               */
/* @AC  200123  RACFA    Retrieve default filter, Option 0 - Settings */
/* @AB  200123  TRIDJK   If LG fails, then issue a LU                 */
/* @AA  200120  TRIDJK   Fixed displaying NOWARNING                   */
/* @A9  200120  TRIDJK   Chged 'subword(temp,4,1)', was (temp,5,1)    */
/* @A8  200120  RACFA    Removed 'say msg.msg_var' in EXCMD procedure */
/* @A7  200119  RACFA    Standardized/reduced lines of code           */
/* @A6  200119  RACFA    Added comment box above procedures           */
/* @A5  200118  RACFA    Added line command 'L' to list userid        */
/* @A4  200118  RACFA    Fixed NOPREF issue with users TSO PROFILE    */
/* @A3  200117  RACFA    Only 'Refresh Generic Class' if chg was made */
/* @A2  200117  RACFA    Adjusted DISPLAY code                        */
/* @A1  200110  RACFA    Added line command 'L' to list dataset       */
/* @A0  011229  NICORIZ  Created REXX, V2.1, www.rizzuto.it           */
/*====================================================================*/
PANEL01     = "RACFDSN1"   /* Set filter, menu option 3    */ /* @AU */
PANEL02     = "RACFDSN2"   /* List profiles and types      */ /* @AU */
PANEL03     = "RACFDSN3"   /* Add profile                  */ /* @AU */
PANEL04     = "RACFDSN4"   /* Change profile               */ /* @AU */
PANEL05     = "RACFDSN5"   /* Show groups and access       */ /* @AU */
PANEL06     = "RACFDSN6"   /* Change access                */ /* @AU */
PANEL07     = "RACFDSN7"   /* Add access                   */ /* @AU */
PANELM1     = "RACFMSG1"   /* Confirm Request (pop-up)     */ /* @AU */
PANELM2     = "RACFMSG2"   /* Display RACF command and RC  */ /* @AU */
PANELS1     = "RACFSAVE"   /* Obtain DSName to SAVE        */ /* @CG */
SKELETON1   = "RACFDSN2"   /* Save tablea to dataset       */ /* @CG */
SKELETON2   = "RACFDSN5"   /* Save tableb to dataset       */ /* @CG */
EDITMACR    = "RACFEMAC"   /* Edit Macro, turn HILITE off  */ /* @BO */
TABLEA      = 'TA'RANDOM(0,99999)  /* Unique table name A  */ /* @C7 */
TABLEB      = 'TB'RANDOM(0,99999)  /* Unique table name B  */ /* @C8 */
DDNAME      = 'RACFA'RANDOM(0,999) /* Unique ddname        */ /* @C2 */
parse source . . REXXPGM .         /* Obtain REXX pgm name */ /* @C1 */
REXXPGM     = LEFT(REXXPGM,8)                                 /* @C1 */
NULL        = ''                                              /* @C9 */

ADDRESS ISPEXEC                                               /* @AJ */
  Rclass = 'DATASET'
  "CONTROL ERRORS RETURN"                                     /* @B1 */
  "VGET (SETGFLTR SETGSTA  SETGSTAP SETGDISP",                /* @C6 */
        "SETMADMN SETMIRRX SETMSHOW SETMTRAC) PROFILE"        /* @C6 */

  If (SETMTRAC <> 'NO') then do                               /* @BV */
     Say "*"COPIES("-",70)"*"                                 /* @BV */
     Say "*"Center("Begin Program = "REXXPGM,70)"*"           /* @BV */
     Say "*"COPIES("-",70)"*"                                 /* @BV */
     if (SETMTRAC <> 'PROGRAMS') THEN                         /* @BW */
        interpret "Trace "SUBSTR(SETMTRAC,1,1)                /* @BV */
  end                                                         /* @BV */

  If (SETMADMN = "YES") then do                               /* @B2 */
     SELCMDS2 = "ÝS¨Show,ÝL¨List,ÝD¨Dsn,ÝC¨Change,"||,        /* @B9 */
                "ÝA¨Add,ÝR¨Remove"                            /* @B4 */
     IF (SETMIRRX = "YES") THEN                               /* @BR */
        SELCMDS5 = "ÝS¨Show,ÝL¨List,ÝP¨Profile,"||,           /* @BH */
                   "ÝC¨Change,ÝA¨Add,ÝR¨Remove"               /* @BH */
     ELSE                                                     /* @BR */
        SELCMDS5 = "ÝS¨Show,ÝL¨List,"||,                      /* @BR */
                   "ÝC¨Change,ÝA¨Add,ÝR¨Remove"               /* @BR */
  end
  else do
     SELCMDS2 = "ÝS¨Show,ÝL¨list,ÝD¨Dsn"                      /* @B9 */
     IF (SETMIRRX = "YES") THEN                               /* @CD */
        SELCMDS5 = "ÝS¨Show,ÝL¨list,ÝP¨Profile"               /* @CD */
     ELSE                                                     /* @CD */
        SELCMDS5 = "ÝS¨Show,ÝL¨list"                          /* @B9 */
  end

  Rfilter  = SETGFLTR                                         /* @AC */
  rlv      = SYSVAR('SYSLRACF')
  chgsmade = 'N'                                              /* @A3 */

  "DISPLAY PANEL("PANEL01")"                                  /* @AU */
  X = MSG("OFF")                                              /* @CL */
  CHKDSN = SYSDSN(RFILTER)                                    /* @CL */
  X = MSG("ON")                                               /* @CL */
  IF (CHKDSN = "OK") THEN DO                                  /* @CL */
     CALL LIST_FULL_DSN                                       /* @CL */
     RETURN                                                   /* @CL */
  END                                                         /* @CL */

  Do while (rc = 0)
     call Profl
     "DISPLAY PANEL("PANEL01")"                               /* @AU */
  End

  If (chgsmade = "Y") then Do                                 /* @A3 */
     msg='You are about to refresh the generic class: 'rclass /* @A3 */
     Sure_? = Confirm_request(msg)                            /* @A3 */
     If (Sure_? = 'YES') then                                 /* @A3 */
        call EXCMD "SETROPTS GENERIC(DATASET)"                /* @A3 */
  End                                                         /* @A3 */

  If (SETMTRAC <> 'NO') then do                               /* @BW */
     Say "*"COPIES("-",70)"*"                                 /* @BW */
     Say "*"Center("End Program = "REXXPGM,70)"*"             /* @BW */
     Say "*"COPIES("-",70)"*"                                 /* @BW */
  end                                                         /* @BW */
EXIT
/*--------------------------------------------------------------------*/
/*  Show all profiles for a filter                                    */
/*--------------------------------------------------------------------*/
PROFL:
  call CREATE_TABLEA
  if (dataset = 'INVALID') | (dataset = 'NONE') THEN DO       /* @CM */
     "TBEND" tablea                                           /* @CN */
     call racfmsgs 'ERR16'                                    /* @C5 */
     rc=8                                                     /* @CM */
     return
  end
  opta   = ' '
  xtdtop = 0                                                  /* @CA */
  rsels  = 0                                                  /* @CA */
  do forever                                                  /* @CA */
     if (rsels < 2) then do                                   /* @CA */
        "TBTOP " TABLEA                                       /* @CA */
        'tbskip' tablea 'number('xtdtop')'                    /* @CA */
        radmrfnd = 'PASSTHRU'                                 /* @CA */
        'vput (radmrfnd)'                                     /* @CA */
        "TBDISPL" TABLEA "PANEL("PANEL02")"                   /* @CA */
     end                                                      /* @CA */
     else 'tbdispl' tablea                                    /* @CA */
     if (rc > 4) then do                                      /* @CN */
        src = rc                                              /* @CN */
        'tbclose' tablea                                      /* @CN */
        rc = src                                              /* @CN */
        leave                                                 /* @CN */
        end                                                   /* @CN */
     xtdtop   = ztdtop                                        /* @CA */
     rsels    = ztdsels                                       /* @CA */
     radmrfnd = null                                          /* @CA */
     'vput (radmrfnd)'                                        /* @CA */
     PARSE VAR ZCMD ZCMD PARM SEQ                             /* @CA */
     IF (SROW <> "") & (SROW <> 0) THEN                       /* @AO */
        IF (SROW > 0) THEN DO                                 /* @AO */
           "TBTOP " TABLEA                                    /* @AO */
           "TBSKIP" TABLEA "NUMBER("SROW")"                   /* @AO */
        END                                                   /* @AO */
     if (zcmd = 'RFIND') then do                              /* @C9 */
        zcmd = 'FIND'                                         /* @C9 */
        parm = findit                                         /* @C9 */
        'tbtop ' TABLEA                                       /* @C9 */
        'tbskip' TABLEA 'number('last_find')'                 /* @C9 */
     end                                                      /* @C9 */
     Select                                                   /* @AL */
        When (abbrev("FIND",zcmd,1) = 1) then                 /* @C9 */
             call do_finda                                    /* @C9 */
        WHEN (ABBREV("LOCATE",ZCMD,1) = 1) THEN do            /* @BI */
             if (parm <> '') then do                          /* @BI */
                locarg = parm'*'                              /* @BI */
                PARSE VAR SORT . "," . "," SEQ                /* @BI */
                IF (SEQ = "D") THEN                           /* @BI */
                   CONDLIST = "LE"                            /* @BI */
                ELSE                                          /* @BI */
                   CONDLIST = "GE"                            /* @BI */
                parse value sort with scan_field',' .         /* @BI */
                interpret scan_field ' = locarg'              /* @BI */
                'tbtop ' tablea                               /* @BI */
                "TBSCAN "TABLEa" ARGLIST("scan_field")",      /* @BI */
                        "CONDLIST("CONDLIST")",               /* @BI */
                        "position(scanrow)"                   /* @BI */
                xtdtop = scanrow                              /* @BI */
             end                                              /* @BI */
        end                                                   /* @BI */
        WHEN (ABBREV("ONLY",ZCMD,1) = 1) THEN DO              /* @AL */
             find_str = translate(parm)                       /* @AL */
             'tbtop ' TABLEA                                  /* @AL */
             'tbskip' TABLEA                                  /* @AL */
             do forever                                       /* @AL */
                str = translate(dataset type)                 /* @AL */
                if (pos(find_str,str) > 0) then nop           /* @AL */
                else 'tbdelete' TABLEA                        /* @AL */
                'tbskip' TABLEA                               /* @AL */
                if (rc > 0) then do                           /* @AL */
                   'tbtop' TABLEA                             /* @AL */
                   leave                                      /* @AL */
                end                                           /* @AL */
             end                                              /* @AL */
        END                                                   /* @AL */
        WHEN (ABBREV("RESET",ZCMD,1) = 1) THEN DO             /* @AL */
             if (parm <> '') then                             /* @C4 */
                rfilter = parm                                /* @C4 */
             xtdtop   = 1                                     /* @AL */
             "TBEND" TABLEA                                   /* @BL */
             call CREATE_TABLEA                               /* @AL */
        END                                                   /* @AL */
        When (abbrev("SAVE",zcmd,2) = 1) then DO              /* @CG */
             TMPSKELT = SKELETON1                             /* @CG */
             call do_SAVE                                     /* @CG */
        END                                                   /* @CG */
        WHEN (ABBREV("SORT",ZCMD,1) = 1) THEN DO              /* @AN */
             SELECT                                           /* @AN */
                when (ABBREV("PROFILE",PARM,1) = 1) then      /* @AQ */
                     call sortseq 'DATASET'                   /* @BL */
                when (ABBREV("TYPE",PARM,1) = 1) then         /* @AQ */
                     call sortseq 'TYPE'                      /* @BL */
                otherwise NOP                                 /* @AN */
             END                                              /* @AN */
             CLRDATA = "GREEN"; CLRTYPE = "GREEN"             /* @CA */
             PARSE VAR SORT LOCARG "," .                      /* @CA */
             INTERPRET "CLR"SUBSTR(LOCARG,1,4)" = 'TURQ'"     /* @CA */
             "TBSORT "TABLEA "FIELDS("sort")"                 /* @CA */
             "TBTOP  "TABLEA                                  /* @CA */
        END                                                   /* @AN */
        otherwise NOP                                         /* @AM */
     END /* Select */                                         /* @AL */
     ZCMD = ""; PARM = ""                                     /* @CA */
     'control display save'                                   /* @CA */
     Select
        when (opta = 'A') then call Addd
        when (opta = 'C') then call Chgd
        when (opta = 'D')  then do                            /* @B4 */
             "CONTROL DISPLAY SAVE"                           /* @B4 */
             "SELECT PGM(ISRDSLST)",                          /* @B4 */
                     "PARM(DSL '"dataset"')",                 /* @B4 */
                     "SUSPEND SCRNAME(DSL)"                   /* @B4 */
             "CONTROL DISPLAY RESTORE"                        /* @B4 */
        end                                                   /* @B4 */
        when (opta = 'L') then call Lisd                      /* @A1 */
        when (opta = 'R') then call Deld
        when (opta = 'S') then call Disd
        otherwise nop
     End
     'control display restore'                                /* @CA */
  end  /* Do forever) */                                      /* @CA */
RETURN
/*--------------------------------------------------------------------*/
/*  Process primary command FIND for TABLEA                      @C9  */
/*--------------------------------------------------------------------*/
DO_FINDa:                                                     /* @C9 */
  if (parm = null) then do                                    /* @C9 */
     racfsmsg = 'Error'                                       /* @C9 */
     racflmsg = 'Find requires a value to search for.' ,      /* @C9 */
                'Try again.'                                  /* @C9 */
     'setmsg msg(RACF011)'                                    /* @C9 */
     return                                                   /* @C9 */
  end                                                         /* @C9 */
  findit    = translate(parm)                                 /* @C9 */
  last_find = 0                                               /* @C9 */
  wrap      = 0                                               /* @C9 */
  do forever                                                  /* @C9 */
     'tbskip' TABLEA                                          /* @C9 */
     if (rc > 0) then do                                      /* @C9 */
        if (wrap = 1) then do                                 /* @C9 */
           racfsmsg = 'Not Found'                             /* @C9 */
           racflmsg = findit 'not found.'                     /* @C9 */
           'setmsg msg(RACF011)'                              /* @C9 */
           return                                             /* @C9 */
        end                                                   /* @C9 */
        if (wrap = 0) then wrap = 1                           /* @C9 */
        'tbtop' TABLEA                                        /* @C9 */
     end                                                      /* @C9 */
     else do                                                  /* @C9 */
        testit = translate(dataset type)                      /* @C9 */
        if (pos(findit,testit) > 0) then do                   /* @C9 */
           'tbquery' TABLEA 'position(srow)'                  /* @C9 */
           'tbtop'   TABLEA                                   /* @C9 */
           'tbskip'  TABLEA 'number('srow')'                  /* @C9 */
           last_find = srow                                   /* @C9 */
           xtdtop    = srow                                   /* @C9 */
           if (wrap = 0) then                                 /* @C9 */
              racfsmsg = 'Found'                              /* @C9 */
           else                                               /* @C9 */
              racfsmsg = 'Found/Wrapped'                      /* @C9 */
           racflmsg = findit 'found in row' srow + 0          /* @C9 */
           'setmsg msg(RACF011)'                              /* @C9 */
           return                                             /* @C9 */
        end                                                   /* @C9 */
     end                                                      /* @C9 */
  end                                                         /* @C9 */
RETURN                                                        /* @C9 */
/*--------------------------------------------------------------------*/
/*  Define sort sequence, to allow point-n-shoot sorting (A/D)   @BL  */
/*--------------------------------------------------------------------*/
SORTSEQ:                                                      /* @BL */
  parse arg sortcol                                           /* @BL */
  INTERPRET "TMPSEQ = SORT"substr(SORTCOL,1,4)                /* @BL */
  select                                                      /* @BL */
     when (seq <> "") then do                                 /* @BL */
          if (seq = 'A') then                                 /* @BL */
             tmpseq = 'D'                                     /* @BL */
          else                                                /* @BL */
             tmpseq = 'A'                                     /* @BL */
          sort = sortcol',C,'seq                              /* @BL */
     end                                                      /* @BL */
     when (seq = ""),                                         /* @BL */
        & (tmpseq = 'A') then do                              /* @BL */
           sort   = sortcol',C,A'                             /* @BL */
           tmpseq = 'D'                                       /* @BL */
     end                                                      /* @BL */
     Otherwise do                                             /* @BL */
        sort   = sortcol',C,D'                                /* @BL */
        tmpseq = 'A'                                          /* @BL */
     end                                                      /* @BL */
  end                                                         /* @BL */
  INTERPRET "SORT"SUBSTR(SORTCOL,1,4)" = TMPSEQ"              /* @BL */
RETURN                                                        /* @BL */
/*--------------------------------------------------------------------*/
/*  Add new profile                                                   */
/*--------------------------------------------------------------------*/
ADDD:
  chgsmade = "Y"                                              /* @A3 */
  new      = 'NO'
  if (dataset = 'NONE') then
     new = 'YES'
  else
     CALL Getd
  "DISPLAY PANEL("PANEL03")"                                  /* @AU */
  if (rc > 0) then
     return
  if (type = 'DISCRETE') then
     type = ' '
  aud = ' '
  if (fail <> ' ') then
     aud = 'FAILURES('FAIL')'
  if (succ <> ' ') then
     aud = 'SUCCESS('SUCC')' aud
  if (aud <> ' ') then
     aud = 'AUDIT('AUD')'
  wrn = ' '
  if (warn = 'YES') then
     wrn = 'WARNING'
  if (warn = 'NO') then                                       /* @AA */
     wrn = 'NOWARNING'                                        /* @AA */
  xtr = ' '
  if (data <> ' ') then
     xtr = xtr "DATA('"data"')"
  call EXCMD "ADDSD '"DATASET"' OWN("OWNER")",
             "UACC("UACC")" type aud xtr
  if (cmd_rc > 0) then do                                     /* @BE */
     CALL racfmsgs 'ERR01' /* Add failed */                   /* @B6 */
     return
  end
  x = msg('OFF')
  call EXCMD "PERMIT '"DATASET"' ID("USERID()")",
             "DELETE" TYPE
  x = msg('ON')
  if (from <> ' ') then do
     fopt = "FROM('"FROM"') FCLASS(DATASET) FGENERIC"
     call EXCMD "PERMIT '"DATASET"'" TYPE FOPT
     if (cmd_rc > 0) then                                     /* @BE */
        CALL racfmsgs 'ERR04' /* Permit Warn */               /* @B6 */
  end
  if (type = ' ') then
     type = 'DISCRETE'
  "TBMOD" TABLEA "ORDER"                                      /* @CB */
  if (new = 'YES') then do
     dataset = 'NONE'
     type    = 'GEN'
     "TBDELETE" TABLEA
  end
RETURN
/*--------------------------------------------------------------------*/
/*  Change profile                                                    */
/*--------------------------------------------------------------------*/
CHGD:
  chgsmade = "Y"                                              /* @A3 */
  if (dataset = 'NONE') then
     return
  CALL Getd
  "DISPLAY PANEL("PANEL04")"                                  /* @AU */
  if (rc > 0) then return
  if (type = 'DISCRETE') then
     type = ' '
  own = ' '
  if (owner <> ' ') then
     own = 'OWNER('OWNER')'
  uc = ' '
  if (uacc <> ' ') then
     uc = 'UACC('UACC')'
  aud = ' '
  wrn = ' '
  if (warn  = 'YES') then
     wrn = 'WARNING'
  if (warn  = 'NO') then                                      /* @AA */
     wrn = 'NOWARNING'                                        /* @AA */
  if (fail <> ' ') then
     aud = 'FAILURES('FAIL')'
  if (succ <> ' ') then
     aud = 'SUCCESS('SUCC')' aud
  if (aud  <> ' ') then
     aud = 'AUDIT('AUD')'
  xtr = ' '
  if (data <> ' ') then do
     if (data = 'NONE') then
        data = ' '
     xtr = xtr "DATA('"DATA"')"
  end
  msg = "ALTDSD '"DATASET"'" own uc type aud xtr wrn
  call EXCMD "ALTDSD '"DATASET"'" own uc type aud xtr wrn
  if (cmd_rc > 0) then                                        /* @BE */
     call racfmsgs 'ERR07' /* Altdsd failed */                /* @B6 */
  else do
     if (type = ' ') then
        type = 'DISCRETE'
     "tbmod" TABLEA
  end
RETURN
/*--------------------------------------------------------------------*/
/*  Delete profile                                                    */
/*--------------------------------------------------------------------*/
DELD:
  chgsmade = "Y"                                              /* @A3 */
  if (dataset = 'NONE') then
     return
  if (type = 'DISCRETE') then
     type = ' '
  msg    = 'You are about to delete 'dataset
  Sure_? = Confirm_request(msg)
  if (sure_? = 'YES') then do
     call EXCMD "DELDSD '"DATASET"'" type
     if (cmd_rc > 0) then do                                  /* @BE */
        if (type = ' ') then
           type = 'DISCRETE'
        CALL racfmsgs "ERR02" /* Del DSD failed */            /* @BG */
        return                                                /* @BG */
     end
     else
        "TBDELETE" TABLEA                                     /* @BG */
  end
RETURN
/*--------------------------------------------------------------------*/
/*  Display profile permits                                           */
/*--------------------------------------------------------------------*/
DISD:
  if (dataset = 'NONE') then do                               /* @BU */
     call racfmsgs ERR21                                      /* @BU */
     return
  end                                                         /* @BU */
  tmpsort   = sort                                            /* @BM */
  tmprsels  = rsels                                           /* @CE */
  tmpxtdtop = xtdtop                                          /* @CF */
  Do until (RB = 'NO')      /* allow rebuild option */
     call create_TABLEB                                       /* @BM */
     rb     = 'NO'
     xtdtop = 0                                               /* @CA */
     rsels  = 0                                               /* @CA */
     do forever                                               /* @CA */
        if (rsels < 2) then do                                /* @CA */
           optb = ' '                                         /* @CA */
           "TBTOP " TABLEB                                    /* @CA */
           'tbskip' tableb 'number('xtdtop')'                 /* @CA */
           radmrfnd = 'PASSTHRU'                              /* @CA */
           'vput (radmrfnd)'                                  /* @CA */
           "TBDISPL" TABLEB "PANEL("PANEL05")"                /* @CA */
        end                                                   /* @CA */
        else 'tbdispl' tableb                                 /* @CA */
        if (rc > 4) then do                                   /* @CN */
           src = rc                                           /* @CN */
           'tbclose' tableb                                   /* @CN */
           rc = src                                           /* @CN */
           leave                                              /* @CN */
           end                                                /* @CN */
        xtdtop   = ztdtop                                     /* @CA */
        rsels    = ztdsels                                    /* @CA */
        radmrfnd = null                                       /* @CA */
        'vput (radmrfnd)'                                     /* @CA */
        PARSE VAR ZCMD ZCMD PARM SEQ                          /* @CA */
        IF (SROW <> "") & (SROW <> 0) THEN                    /* @AO */
           IF (SROW > 0) THEN DO                              /* @AO */
              "TBTOP " TABLEB                                 /* @AO */
              "TBSKIP" TABLEB "NUMBER("SROW")"                /* @AO */
           END                                                /* @AO */
        if (zcmd = 'RFIND') then do                           /* @C9 */
           zcmd = 'FIND'                                      /* @C9 */
           parm = findit                                      /* @C9 */
           'tbtop' TABLEB                                     /* @C9 */
           'tbskip' TABLEB 'number('last_find')'              /* @C9 */
        end                                                   /* @C9 */
        Select                                                /* @BM */
           When (abbrev("FIND",zcmd,1) = 1) then              /* @C9 */
                call do_findb                                 /* @C9 */
           WHEN (ABBREV("LOCATE",ZCMD,1) = 1) THEN DO         /* @CA */
                if (parm <> '') then do                       /* @CA */
                   locarg = parm'*'                           /* @CA */
                   PARSE VAR SORT . "," . "," SEQ             /* @CA */
                   IF (SEQ = "D") THEN                        /* @CA */
                      CONDLIST = "LE"                         /* @CA */
                   ELSE                                       /* @CA */
                      CONDLIST = "GE"                         /* @CA */
                   parse value sort with scan_field',' .      /* @CA */
                   interpret scan_field ' = locarg'           /* @CA */
                   'tbtop ' tableb                            /* @CA */
                   "TBSCAN "TABLEb" ARGLIST("scan_field")",   /* @CA */
                           "CONDLIST("CONDLIST")",            /* @CA */
                           "position(scanrow)"                /* @CA */
                   xtdtop = scanrow                           /* @CA */
                end                                           /* @CA */
           END                                                /* @CA */
           WHEN (ABBREV("ONLY",ZCMD,1) = 1) THEN DO           /* @BM */
                find_str = translate(parm)                    /* @BM */
                'tbtop ' TABLEB                               /* @BM */
                'tbskip' TABLEB                               /* @BM */
                do forever                                    /* @BM */
                   str = translate(id acc)                    /* @BM */
                   if (pos(find_str,str) > 0) then nop        /* @BM */
                   else 'tbdelete' TABLEB                     /* @BM */
                   'tbskip' TABLEB                            /* @BM */
                   if (rc > 0) then do                        /* @BM */
                      'tbtop' TABLEB                          /* @BM */
                      leave                                   /* @BM */
                   end                                        /* @BM */
                end                                           /* @BM */
           END                                                /* @BM */
           WHEN (ABBREV("RESET",ZCMD,1) = 1) THEN DO          /* @BM */
                xtdtop   = 1                                  /* @BM */
                "TBEND" TABLEB                                /* @BM */
                call create_TABLEB                            /* @BM */
           END                                                /* @BM */
           When (abbrev("SAVE",zcmd,2) = 1) then DO           /* @CG */
                TMPSKELT = SKELETON2                          /* @CG */
                call do_SAVE                                  /* @CG */
           END                                                /* @CG */
           WHEN (ABBREV("SORT",ZCMD,1) = 1) THEN DO           /* @BM */
                SELECT                                        /* @BM */
                   when (ABBREV("GROUP",PARM,1) = 1) then     /* @BM */
                        call sortseq 'ID'                     /* @BM */
                   when (ABBREV("ID",PARM,1) = 1) then        /* @BM */
                        call sortseq 'ID'                     /* @BM */
                   when (ABBREV("ACCESS",PARM,1) = 1) then    /* @BM */
                        call sortseq 'ACC'                    /* @BM */
                   otherwise NOP                              /* @BM */
                END                                           /* @BM */
                PARSE VAR SORT LOCARG "," .                   /* @CA */
                CLRID = "GREEN"; CLRACC = "GREEN"             /* @CA */
                INTERPRET "CLR"SUBSTR(LOCARG,1,4)" = 'TURQ'"  /* @CA */
                "TBSORT" TABLEB "FIELDS("sort")"              /* @CA */
                "TBTOP " TABLEB                               /* @CA */
           END                                                /* @BM */
           otherwise NOP                                      /* @BM */
        END /* Select */                                      /* @BM */
        ZCMD = ""; PARM = ""                                  /* @CA */
        'control display save'                                /* @CA */
        Select
           when (optb = 'A') then call Addp
           when (optb = 'C') then call Chgp
           when (optb = 'L') then call Lisp                   /* @A5 */
           when (optb = 'P') then                             /* @BH */
                call RACFPROF 'GROUP' id                      /* @BH */
           when (optb = 'R') then call Delp
           when (optb = 'S') then call Disp
           otherwise nop
        End
        'control display restore'                             /* @CA */
     end  /* Do forever) */                                   /* @CA */
  end  /* Do until */
  sort   = tmpsort                                            /* @BM */
  rsels  = tmprsels                                           /* @CE */
  xtdtop = tmpxtdtop                                          /* @CF */
RETURN
/*--------------------------------------------------------------------*/
/*  Process primary command FIND for TABLEA                      @C9  */
/*--------------------------------------------------------------------*/
DO_FINDB:                                                     /* @C9 */
  if (parm = null) then do                                    /* @C9 */
     racfsmsg = 'Error'                                       /* @C9 */
     racflmsg = 'Find requires a value to search for.' ,      /* @C9 */
                'Try again.'                                  /* @C9 */
     'setmsg msg(RACF011)'                                    /* @C9 */
     return                                                   /* @C9 */
  end                                                         /* @C9 */
  findit    = translate(parm)                                 /* @C9 */
  last_find = 0                                               /* @C9 */
  wrap      = 0                                               /* @C9 */
  do forever                                                  /* @C9 */
     'tbskip' TABLEB                                          /* @C9 */
     if (rc > 0) then do                                      /* @C9 */
        if (wrap = 1) then do                                 /* @C9 */
           racfsmsg = 'Not Found'                             /* @C9 */
           racflmsg = findit 'not found.'                     /* @C9 */
           'setmsg msg(RACF011)'                              /* @C9 */
           return                                             /* @C9 */
        end                                                   /* @C9 */
        if (wrap = 0) then wrap = 1                           /* @C9 */
        'tbtop' TABLEB                                        /* @C9 */
     end                                                      /* @C9 */
     else do                                                  /* @C9 */
        testit = translate(id acc)                            /* @C9 */
        if (pos(findit,testit) > 0) then do                   /* @C9 */
           'tbquery' TABLEB 'position(srow)'                  /* @C9 */
           'tbtop'   TABLEB                                   /* @C9 */
           'tbskip'  TABLEB 'number('srow')'                  /* @C9 */
           last_find = srow                                   /* @C9 */
           xtdtop    = srow                                   /* @C9 */
           if (wrap = 0) then                                 /* @C9 */
              racfsmsg = 'Found'                              /* @C9 */
           else                                               /* @C9 */
              racfsmsg = 'Found/Wrapped'                      /* @C9 */
           racflmsg = findit 'found in row' srow + 0          /* @C9 */
           'setmsg msg(RACF011)'                              /* @C9 */
           return                                             /* @C9 */
        end                                                   /* @C9 */
     end                                                      /* @C9 */
  end                                                         /* @C9 */
RETURN                                                        /* @C9 */
/*--------------------------------------------------------------------*/
/*  Create table 'B'                                             @BM  */
/*--------------------------------------------------------------------*/
CREATE_TABLEB:                                                /* @BM */
  "TBCREATE" TABLEB "KEYS(ID) NAMES(ACC)",
                  "REPLACE NOWRITE"
  flags = 'OFF'
  audit = ' '
  owner = ' '
  warn  = ' '
  uacc  = ' '
  data  = ' '
  if (type = 'DISCRETE') then
     type = ' '
  cmd = "LISTDSD DA('"DATASET"') AUTH"
  x = OUTTRAP('VAR.')
  address TSO cmd                                             /* @AI */
  cmd_rc = rc                                                 /* @AZ */
  x = OUTTRAP('OFF')
  if (SETMSHOW <> 'NO') then                                  /* @BJ */
     call SHOWCMD                                             /* @AI */
  if (type = ' ') then
     type = 'DISCRETE'
  Do i = 1 to var.0          /* Scan output */
     temp = var.i
     if (rlv > '1081') then  /* RACF 1.9 add blank */
        temp = ' 'temp
     l = LENGTH(temp)
     if (uacc= ' ') then
        if (substr(temp,2,12)= 'LEVEL  OWNER') then do
           i     = i + 2
           temp  = var.i
           owner = subword(temp,2,1)
           uacc  = subword(temp,3,1)
           warn  = subword(temp,4,1)                          /* @A9 */
        end
     if (audit = ' ') then
        if (substr(temp,2,8) = 'AUDITING') then do
           i     = i + 2
           temp  = var.i
           audit = subword(temp,1,1)
        end
     if (data = ' ') then
        if (substr(temp,2,17) = 'INSTALLATION DATA') then do
           i    = i + 2
           temp = var.i
           data = temp
           i    = i + 1
           temp = var.i
           data = data || substr(temp,2)
        end
     if (flags = 'ON') then do
        if (l = 1) | (l = 2) then
           flags = 'OUT'     /* end of access list */
        if (l > 8) then
           if (substr(temp,1,9) = ' ') then
              flags = 'OUT'  /* end of access list */
     end
     if (flags = 'ON') then do
        if (substr(temp,2,10) = 'NO ENTRIES') then do
           id  = 'NONE'        /* empty access list */
           acc = 'DEFINED'
        end
        else do
           id  = subword(temp,1,1)
           acc = subword(temp,2,1)
        end
        "TBMOD" TABLEB
     end
     if (substr(temp,5,13) = 'ID     ACCESS') then do
        flags = 'ON'      /* start of access list */
        i     = i + 1     /* skip */
     end
  end  /* Loop scan output */
  sort   = 'ID,C,A'                                           /* @CA */
  sortid = 'D'; sortacc = 'A'        /* Sort order */         /* @CA */
  CLRID  = "TURQ"; CLRACC = "GREEN"  /* Col colors */         /* @CA */
  "TBSORT " TABLEB "FIELDS("sort")"                           /* @CA */
  "TBTOP  " TABLEB                                            /* @CA */
RETURN                                                        /* @BM */
/*--------------------------------------------------------------------*/
/*  Get LISTDSD info to initialize add or change option               */
/*--------------------------------------------------------------------*/
GETD:
  flags = 'OFF'
  owner = ' '
  warn  = ' '
  uacc  = ' '
  audit = ' '
  data  = ' '
  cmd   = "LISTDSD DA('"DATASET"')"                           /* @AI */
  x = OUTTRAP('VAR.')
  address TSO cmd                                             /* @AI */
  cmd_rc = rc                                                 /* @AZ */
  x = OUTTRAP('OFF')
  if (SETMSHOW <> 'NO') then                                  /* @BJ */
     call SHOWCMD                                             /* @AI */
  Do i = 1 to var.0 while (flags <> 'OUT') /* Scan output */
     temp = var.i
     if (rlv > '1081') then  /* RACF 1.9 add blank */
        temp = ' 'temp
     if (uacc = ' ') then
        if (substr(temp,2,12) = 'LEVEL  OWNER') then do
           i     = i + 2
           temp  = var.i
           owner = subword(temp,2,1)
           uacc  = subword(temp,3,1)
           warn  = subword(temp,4,1)                          /* @A9 */
        end
     if (audit = ' ') then
        if (substr(temp,2,8) = 'AUDITING') then do
           i     = i + 2
           temp  = var.i
           audit = subword(temp,1,1)
        end
     if (data = ' ') then
        if (substr(temp,2,17) = 'INSTALLATION DATA') then do
           i    = i + 2
           temp = var.i
           if (rlv > '1081') then  /* RACF 1.9 add blank */
              temp = ' 'temp
           data = subword(temp,1)
           i    = i + 1
           temp = var.i
           if (rlv > '1081') then  /* RACF 1.9 add blank */
              temp = ' 'temp
           data = data || substr(temp,2)
        end
  end /* i= 1 do */
  a = INDEX(audit,'ALL')
  if (a > 0) then do
     fail = substr(audit,a+4,7)
     succ = substr(audit,a+4,7)
  end
  else do
     f = INDEX(audit,'FAILURES')
     if (f > 0) then
        fail = substr(audit,f+9,7)
     s = INDEX(audit,'SUCCESS')
     if (s > 0) then
        succ = substr(audit,s+8,7)
  end
RETURN
/*--------------------------------------------------------------------*/
/*  Change permit option                                              */
/*--------------------------------------------------------------------*/
CHGP:
  If (id = 'NONE') then
     return
  "DISPLAY PANEL("PANEL06")"                                  /* @AU */
  if (rc > 0) then
     return
  if (type = 'DISCRETE') then
     type = ' '
  call EXCMD "PERMIT '"DATASET"' ID("ID") ACC("ACC")" TYPE
  if (cmd_rc = 0) then do                                     /* @C5 */
     if (type = ' ') then
        type = 'DISCRETE'
     "TBMOD" TABLEB
  end
  else
     Call racfmsgs 'ERR03' /* permit failed */                /* @B6 */
RETURN
/*--------------------------------------------------------------------*/
/*  Add permit option                                                 */
/*--------------------------------------------------------------------*/
ADDP:
  new = 'NO'
  if (id = 'NONE') then
     new = 'YES'
  from = ' '
  "DISPLAY PANEL("PANEL07")"                                  /* @AU */
  if (rc > 0) then
     return
  if (type = 'DISCRETE') then
     type = ' '
  idopt = ' '
  if (id <> ' ') then
     idopt = 'ID('ID') ACCESS('ACC')'
  fopt = ' '
  if (from <> ' ') then do
     fopt = "FROM('"FROM"') FCLASS(DATASET) FGENERIC"
     rb   = 'YES'             /* Cause table rebuild */
  end
  call EXCMD "PERMIT '"DATASET"'" idopt type fopt
  if (cmd_rc = 0) then do                                     /* @C5 */
     "TBMOD" TABLEB
     if (new = 'YES') then do
        id = 'NONE'
        "TBDELETE" TABLEB
     end
  end
  else do
     if (from <> ' ') then
        call racfmsgs 'ERR04' /* Permit Warning/Failed */     /* @B6 */
     else
        call racfmsgs 'ERR05' /* Permit Failed */             /* @B6 */
  end
RETURN
/*--------------------------------------------------------------------*/
/*  Delete permit option                                              */
/*--------------------------------------------------------------------*/
DELP:
  if (id = 'NONE') then
     return
  if (type = 'DISCRETE') then
     type = ' '
  msg    = 'You are about to delete access for 'ID
  Sure_? = Confirm_request(msg)
  if (sure_? = 'YES') then do
     call EXCMD "PERMIT '"DATASET"' ID("ID") DELETE" TYPE
     if (cmd_rc = 0) then                                     /* @C5 */
        "TBDELETE" TABLEB
     else
        call racfmsgs 'ERR06' /* Permit Failed */             /* @B6 */
  end
RETURN
/*--------------------------------------------------------------------*/
/*  Display userid                                                    */
/*--------------------------------------------------------------------*/
DISP:
  if (id = "*") then do  /* Wild card - All other entries */  /* @B8 */
     call RACFMSGS ERR17                                      /* @B8 */
     return                                                   /* @B8 */
  end                                                         /* @B8 */
  x   = msg('OFF')
  cmd = "LU "id                                               /* @AI */
  x = OUTTRAP('trash.')
  address TSO cmd                                             /* @AI */
  cmd_rc = rc
  x = OUTTRAP('OFF')
  if (SETMSHOW <> 'NO') then                                  /* @BJ */
     call SHOWCMD                                             /* @AI */
  x = msg('ON')
  if (cmd_rc = 0) then call RACFUSR id                        /* @B7 */
  else call RACFGRP id
RETURN
/*--------------------------------------------------------------------*/
/*  Confirm delete                                                    */
/*--------------------------------------------------------------------*/
CONFIRM_REQUEST:
  signal off error
  arg message
  answer  = 'NO'
  zwinttl = 'CONFIRM REQUEST'
  Do until (ckey = 'PF03') | (ckey = 'ENTER')
     "CONTROL NOCMD"                                          /* @AV */
     "ADDPOP"                                                 /* @AV */
     "DISPLAY PANEL("PANELM1")"                               /* @AU */
     "REMPOP"                                                 /* @AV */
  end
  select
     when (ckey = 'PF03')  then answer = 'NO'
     when (ckey = 'ENTER') then answer = 'YES'
     otherwise nop
  End
  zwinttl = ' '
RETURN answer
/*--------------------------------------------------------------------*/
/*  Exec command                                                      */
/*--------------------------------------------------------------------*/
EXCMD:
  signal off error
  arg cmd
  x = OUTTRAP('msg.')
  address TSO cmd                                             /* @AY */
  cmd_rc = rc
  x = OUTTRAP('OFF')
  if (SETMSHOW <> 'NO') then                                  /* @BJ */
     call SHOWCMD                                             /* @AI */
  if (subword(msg.1,1,1) = 'ICH11009I') |,
     (subword(msg.1,1,1) = 'ICH10006I') |,
     (subword(msg.1,1,1) = 'ICH06011I') then raclist = 'YES'
RETURN
/*--------------------------------------------------------------------*/
/*  List dataset                                                      */
/*--------------------------------------------------------------------*/
LISD:                                                         /* @A1 */
  CMDPRM  = "ALL DSNS"                                        /* @CK */
  CMD     = "LISTDSD DATASET('"DATASET"')" CMDPRM             /* @B2 */
  X = OUTTRAP("CMDREC.")                                      /* @A1 */
  ADDRESS TSO cmd                                             /* @AI */
  cmd_rc = rc                                                 /* @AZ */
  X = OUTTRAP("OFF")                                          /* @A1 */
  if (SETMSHOW <> 'NO') then                                  /* @BJ */
     call SHOWCMD                                             /* @AI */
  if (cmd_rc > 0) then do   /* Remove parms */                /* @BC */
     CMD = "LISTDSD DATASET('"DATASET"')"                     /* @BC */
     X   = OUTTRAP("CMDREC.")                                 /* @BC */
     ADDRESS TSO cmd                                          /* @BC */
     cmd_rc = rc                                              /* @BC */
     X   = OUTTRAP("OFF")                                     /* @BC */
     if (SETMSHOW <> 'NO') then                               /* @BJ */
        call SHOWCMD                                          /* @BC */
  end                                                         /* @BC */
  call display_info                                           /* @BP */
  if (cmd_rc > 0) then                                        /* @BD */
     CALL racfmsgs "ERR10" /* Generic failure */              /* @B6 */
RETURN                                                        /* @A1 */
/*--------------------------------------------------------------------*/
/*  Display information from line commands 'L' and 'P'           @BP  */
/*--------------------------------------------------------------------*/
DISPLAY_INFO:
  ADDRESS TSO "ALLOC F("DDNAME") NEW REUSE",                  /* @A1 */
              "LRECL(80) BLKSIZE(0) RECFM(F B)",              /* @BQ */
              "UNIT(VIO) SPACE(1 5) CYLINDERS"                /* @A1 */
  ADDRESS TSO "EXECIO * DISKW "DDNAME" (STEM CMDREC. FINIS"   /* @A1 */
  DROP CMDREC.                                                /* @CC */
                                                              /* @CC */
  "LMINIT DATAID(CMDDATID) DDNAME("DDNAME")"                  /* @A1 */
  SELECT                                                      /* @AF */
     WHEN (SETGDISP = "VIEW") THEN                            /* @AF */
          "VIEW DATAID("CMDDATID") MACRO("EDITMACR")"         /* @BN */
     WHEN (SETGDISP = "EDIT") THEN                            /* @AF */
          "EDIT DATAID("CMDDATID") MACRO("EDITMACR")"         /* @BN */
     OTHERWISE                                                /* @AF */
          "BROWSE DATAID("CMDDATID")"                         /* @AF */
  END                                                         /* @AF */
  ADDRESS TSO "FREE FI("DDNAME")"                             /* @A1 */
RETURN                                                        /* @BP */
/*--------------------------------------------------------------------*/
/*  List group                                                        */
/*--------------------------------------------------------------------*/
LISP:                                                         /* @A5 */
  if (id = "*") then do  /* Wild card - All other entries */  /* @BI */
     call RACFMSGS ERR17                                      /* @BI */
     return                                                   /* @BI */
  end                                                         /* @BI */
  CMDPRM  = "CSDATA DFP OMVS OVM TME"                         /* @A5 */
  CMD     = "LG "ID CMDPRM                                    /* @AI */
  X = OUTTRAP("CMDREC.")                                      /* @A5 */
  ADDRESS TSO cmd                                             /* @AI */
  cmd_rc = rc                                                 /* @AZ */
  X = OUTTRAP("OFF")                                          /* @A5 */
  if SETMSHOW <> 'NO' then                                    /* @BJ */
     call SHOWCMD                                             /* @AI */
  if (cmd_rc > 0) then do   /* Remove parms */                /* @AB */
     X = OUTTRAP("CMDREC.")                                   /* @AI */
     CMD    = "LU "ID                                         /* @AI */
     ADDRESS TSO cmd                                          /* @AI */
     cmd_rc = rc                                              /* @AB */
     if (SETMSHOW <> 'NO') then                               /* @BJ */
        call SHOWCMD                                          /* @AI */
     X = OUTTRAP("OFF")                                       /* @AI */
  end                                                         /* @AB */
  call display_info                                           /* @BP */
  if (cmd_rc > 0) then                                        /* @BF */
     CALL racfmsgs "ERR15" /* Generic failure */              /* @B6 */
RETURN                                                        /* @A5 */
/*--------------------------------------------------------------------*/
/*  Display RACF command and return code                         @AI  */
/*--------------------------------------------------------------------*/
SHOWCMD:                                                      /* @AI */
  IF (SETMSHOW = "BOTH") | (SETMSHOW = "DISPLAY") THEN DO     /* @BK */
     PARSE VAR CMD MSG1 60 MSG2 121 MSG3                      /* @AI */
     MSG4 = "Return code = "cmd_rc                            /* @AZ */
     "ADDPOP ROW(6) COLUMN(4)"                                /* @AV */
     "DISPLAY PANEL("PANELM2")"                               /* @AU */
     "REMPOP"                                                 /* @AV */
  END                                                         /* @BJ */
  IF (SETMSHOW = "BOTH") | (SETMSHOW = "LOG") THEN DO         /* @BK */
     zerrsm = "RACFADM "REXXPGM" RC="cmd_rc                   /* @BX */
     zerrlm = cmd                                             /* @BJ */
     'log msg(isrz003)'                                       /* @BJ */
  END                                                         /* @BJ */
RETURN                                                        /* @AI */
/*--------------------------------------------------------------------*/
/*  Create table 'A'                                             @AL  */
/*--------------------------------------------------------------------*/
CREATE_TABLEA:
  "TBCREATE" TABLEA "KEYS(DATASET TYPE) REPLACE NOWRITE"
  cmd = "SEARCH FILTER("RFILTER") CLASS(DATASET)"             /* @AI */
  x = OUTTRAP('var.')
  address TSO cmd                                             /* @AI */
  cmd_rc = rc                                                 /* @AB */
  x = OUTTRAP('OFF')
  if (SETMSHOW <> 'NO') then                                  /* @BJ */
     call SHOWCMD                                             /* @AI */
  if (SETGSTAP <> "") THEN                                    /* @BZ */
     INTERPRET "RECNUM = var.0*."SETGSTAP"%1"                 /* @BZ */
  Do i = 1 to var.0
     temp = var.i
     /*---------------------------------------------*/
     /* Display number of records retrieved        -*/
     /*---------------------------------------------*/
     IF (SETGSTA = "") THEN DO                                /* @BZ */
        IF (RECNUM <> 0) THEN                                 /* @BZ */
           IF (I//RECNUM = 0) THEN DO                         /* @BZ */
              n1 = i; n2 = var.0                              /* @BZ */
              pct = ((n1/n2)*100)%1'%'                        /* @BZ */
              "control display lock"                          /* @BZ */
              "display msg(RACF012)"                          /* @C3 */
           END                                                /* @BZ */
     END                                                      /* @BZ */
     ELSE DO                                                  /* @BZ */
        IF (SETGSTA <> 0) THEN                                /* @BZ */
           IF (I//SETGSTA = 0) THEN DO                        /* @AD */
              n1 = i; n2 = var.0
              pct = ((n1/n2)*100)%1'%'                        /* @BZ */
              "control display lock"
              "display msg(RACF012)"                          /* @C3 */
           END                                                /* @AD */
     END                                                      /* @BZ */

     dataset = SUBWORD(temp,1,1)
     t       = INDEX(temp,g)
     if (t > 0) then
        type = 'GEN'
     else do
        type = 'DISCRETE'
        msgr = SUBWORD(temp,1,1)
        Select
           when (msgr = 'ICH31005I') then do
                dataset = 'NONE'     /* No datasets */
                type    = 'GEN'
           end
           when (msgr = 'ICH31009I') then do
                dataset = 'INVALID'  /* Bad filter  */
                call racfmsgs 'ERR08'                         /* @B6 */
           end
           when (msgr = 'ICH31012I') then do
                dataset = 'INVALID'  /* Bad filter  */
                call racfmsgs 'ERR08'                         /* @B6 */
           end
           when (msgr = 'ICH31014I') then do
                dataset = 'INVALID'  /* Bad filter  */
                call racfmsgs 'ERR08'                         /* @B6 */
           end
           when (msgr = 'ICH31016I') then do
                dataset = 'INVALID'  /* Bad filter  */
                call racfmsgs 'ERR08'                         /* @B6 */
           end
           when (msgr = 'ICH31017I') then do
                dataset = 'INVALID'  /* Bad filter  */
                call racfmsgs 'ERR08'                         /* @B6 */
           end
           when (msgr = 'ICH31018I') then do
                dataset = 'INVALID'  /* Bad filter  */
                call racfmsgs 'ERR08'                         /* @B6 */
           end
           when (msgr= 'IKJ56716I') then do
                dataset = 'INVALID'  /* Bad filter  */
                call racfmsgs 'ERR08'                         /* @B6 */
           end
           when (substr(msgr,1,6) = 'ICH310') then do
                type = ' '           /* Misc. errs  */
                call racfmsgs 'ERR09'                         /* @B6 */
           end
           otherwise nop
        End  /* Select */
     end  /* Else */
     "TBMOD" TABLEA
  end        /* Do i=1 to var.0 */
  sort     = 'DATASET,C,A'                                    /* @CA */
  sortdata = 'D'; sorttype = 'A'         /* Sort order */     /* @CA */
  CLRDATA  = "TURQ"; CLRTYPE = "GREEN"   /* Col colors */     /* @CA */
  "TBSORT " TABLEA "FIELDS("sort")"                           /* @CA */
  "TBTOP  " TABLEA                                            /* @CA */
RETURN
/*--------------------------------------------------------------------*/
/*  Save table to dataset                                        @CG  */
/*--------------------------------------------------------------------*/
DO_SAVE:                                                      /* @CG */
  X = MSG("OFF")                                              /* @CG */
  "ADDPOP COLUMN(40)"                                         /* @CG */
  "VGET (RACFSDSN RACFSMBR RACFSFIL RACFSREP) PROFILE"        /* @CH */
  IF (RACFSDSN = "") THEN         /* SAve - Dataset Name  */  /* @CI */
     RACFSDSN = USERID()".RACFADM.REPORTS"                    /* @EK */
  IF (RACFSFIL = "") THEN         /* SAve - As (TXT/CVS)  */  /* @CI */
     RACFSFIL = "T"                                           /* @EL */
  IF (RACFSREP = "") THEN         /* SAve - Replace (Y/N) */  /* @CI */
     RACFSREP = "N"                                           /* @EK */
                                                              /* @CG */
  DO FOREVER                                                  /* @CG */
     "DISPLAY PANEL("PANELS1")"                               /* @CG */
     IF (RC = 08) THEN DO                                     /* @CG */
        "REMPOP"                                              /* @CG */
        RETURN                                                /* @CG */
     END                                                      /* @CG */
     RACFSDSN = STRIP(RACFSDSN,,"'")                          /* @CG */
     RACFSDSN = STRIP(RACFSDSN,,'"')                          /* @CG */
     RACFSDSN = STRIP(RACFSDSN)                               /* @CG */
     SYSDSORG = ""                                            /* @CG */
     X = LISTDSI("'"RACFSDSN"'")                              /* @CG */
     IF (SYSDSORG = "") | (SYSDSORG = "PS"),                  /* @CG */
      | (SYSDSORG = "PO") THEN                                /* @CG */
        NOP                                                   /* @CG */
     ELSE DO                                                  /* @CG */
        RACFSMSG = "Not PDS/Seq File"                         /* @CG */
        RACFLMSG = "The dataset specified is not",            /* @CG */
                  "a partitioned or sequential",              /* @CG */
                  "dataset, please enter a valid",            /* @CG */
                  "dataset name."                             /* @CG */
       "SETMSG MSG(RACF011)"                                  /* @CG */
       ITERATE                                                /* @CG */
     END                                                      /* @CG */
     IF (SYSDSORG = "PS") & (RACFSMBR <> "") THEN DO          /* @CG */
        RACFSMSG = "Seq File - No mbr"                        /* @CG */
        RACFLMSG = "This dataset is a sequential",            /* @CG */
                  "file, please remove the",                  /* @CG */
                  "member name."                              /* @CG */
       "SETMSG MSG(RACF011)"                                  /* @CG */
       ITERATE                                                /* @CG */
     END                                                      /* @CG */
     IF (SYSDSORG = "PO") & (RACFSMBR = "") THEN DO           /* @CG */
        RACFSMSG = "PDS File - Need Mbr"                      /* @CG */
        RACFLMSG = "This dataset is a partitioned",           /* @CG */
                  "dataset, please include a member",         /* @CG */
                  "name."                                     /* @CG */
       "SETMSG MSG(RACF011)"                                  /* @CG */
       ITERATE                                                /* @CG */
     END                                                      /* @CG */
                                                              /* @CG */
     IF (RACFSMBR = "") THEN                                  /* @CG */
        TMPDSN = RACFSDSN                                     /* @CG */
     ELSE                                                     /* @CG */
        TMPDSN = RACFSDSN"("RACFSMBR")"                       /* @CG */
     DSNCHK = SYSDSN("'"TMPDSN"'")                            /* @CG */
     IF (DSNCHK = "OK" & RACFSREP = "N") THEN DO              /* @CG */
        RACFSMSG = "DSN/MBR Exists"                           /* @CG */
        RACFLMSG = "Dataset/member already exists. ",         /* @CG */
                  "Please type in "Y" to replace file."       /* @CG */
        "SETMSG MSG(RACF011)"                                 /* @CG */
        ITERATE                                               /* @CG */
     END                                                      /* @CG */
     LEAVE                                                    /* @CG */
  END                                                         /* @CG */
  "REMPOP"                                                    /* @CG */
  "VPUT (RACFSDSN RACFSMBR RACFSFIL RACFSREP) PROFILE"        /* @CH */
                                                              /* @CG */
ADDRESS TSO                                                   /* @CG */
  IF (RACFSREP = "Y" & RACFSMBR = "") |,                      /* @CG */
     (DSNCHK <> "OK" & DSNCHK <> "MEMBER NOT FOUND"),         /* @CG */
     THEN DO                                                  /* @CG */
     "DELETE '"RACFSDSN"'"                                    /* @CG */
     IF (RACFSMBR = "") THEN                                  /* @CG */
        "ALLOC  FI(ISPFILE) DA('"RACFSDSN"') NEW",            /* @CG */
            "REUSE SP(1 1) CYLINDER UNIT(SYSALLDA)",          /* @CJ */
            "LRECL(80) RECFM(F B)"                            /* @CG */
     ELSE                                                     /* @CG */
        "ALLOC  FI(ISPFILE) DA('"RACFSDSN"') NEW",            /* @CG */
            "REUSE SP(1 1) CYLINDER UNIT(SYSALLDA)",          /* @CJ */
            "LRECL(80) RECFM(F B)",                           /* @CG */
            "DSORG(PO) DSNTYPE(LIBRARY,2)"                    /* @CG */
  END                                                         /* @CG */
  ELSE                                                        /* @CG */
     "ALLOC  FI(ISPFILE) DA('"RACFSDSN"') SHR REUSE"          /* @CG */
                                                              /* @CG */
ADDRESS ISPEXEC                                               /* @CG */
  "FTOPEN"                                                    /* @CG */
  "FTINCL "TMPSKELT                                           /* @CG */
  IF (RACFSMBR = "") THEN                                     /* @CG */
     "FTCLOSE"                                                /* @CG */
  ELSE                                                        /* @CG */
     "FTCLOSE NAME("RACFSMBR")"                               /* @CG */
  ADDRESS TSO "FREE FI(ISPFILE)"                              /* @CG */
                                                              /* @CG */
  SELECT                                                      /* @CG */
     WHEN (SETGDISP = "VIEW") THEN                            /* @CG */
          "VIEW DATASET('"RACFSDSN"') MACRO("EDITMACR")"      /* @CG */
     WHEN (SETGDISP = "EDIT") THEN                            /* @CG */
          "EDIT DATASET('"RACFSDSN"') MACRO("EDITMACR")"      /* @CG */
     OTHERWISE                                                /* @CG */
          "BROWSE DATASET('"RACFSDSN"')"                      /* @CG */
  END                                                         /* @CG */
  X = MSG("ON")                                               /* @CG */
                                                              /* @CG */
RETURN                                                        /* @CG */
/*--------------------------------------------------------------------*/
/*  List fully qualified dataset with single quotes              @CL  */
/*--------------------------------------------------------------------*/
LIST_FULL_DSN:                                                /* @CL */
  CMDPRM  = "DSNS GEN"                                        /* @CL */
  CMD     = "LISTDSD DATASET("RFILTER")" CMDPRM               /* @CL */
  X = OUTTRAP("CMDREC.")                                      /* @CL */
  ADDRESS TSO cmd                                             /* @CL */
  cmd_rc = rc                                                 /* @CL */
  X = OUTTRAP("OFF")                                          /* @CL */
  if (SETMSHOW <> 'NO') then                                  /* @CL */
     call SHOWCMD                                             /* @CL */
  call display_info                                           /* @CL */
  if (cmd_rc > 0) then                                        /* @CL */
     CALL racfmsgs "ERR10" /* Generic failure */              /* @CL */
RETURN                                                        /* @CL */
