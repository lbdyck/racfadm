/*%NOCOMMENT====================* REXX *==============================*/
/*  PURPOSE:  RACFADM - General Resources - Generic class profile     */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @C9  220317  LBD      Close table on exit                          */
/* @C8  220317  TRIDJK   Intialize OPTB in Do Forever,rsels < 2 logic */
/* @C7  220317  TRIDJK   Fix Add literal in SELCMDS                   */
/* @C6  200618  RACFA    Chged SYSDA to SYSALLDA                      */
/* @C5  200617  RACFA    Added comments to right of variables         */
/* @C4  200616  RACFA    Added capability to SAve file as TXT/CSV     */
/* @C3  200610  RACFA    Added primary command 'SAVE'                 */
/* @C2  200604  RACFA    Fix, prevent from going to top of table      */
/* @C1  200527  RACFA    Fix, allow typing 'S' on multiple rows       */
/* @BZ  200520  RACFA    Display line cmd 'P'rofile, when 'Admin=N'   */
/* @BY  200506  RACFA    Drop array immediately when done using       */
/* @BX  200504  TRIDJK   Adding, place in order, prior was at bottom  */
/* @BW  200502  RACFA    Re-worked displaying tables, use DO FOREVER  */
/* @BV  200501  LBD      Add primary commands FIND/RFIND              */
/* @BU  200430  RACFA    Chg tblb to TABLEB, moved def. var. up top   */
/* @BT  200430  RACFA    Chg tbla to TABLEA, moved def. var. up top   */
/* @BS  200429  RACFA    Re-arranged variables (General, Mgmt, TSO)   */
/* @BR  200424  RACFA    Updated RESET, pass filter, ex: R filter     */
/* @BQ  200424  RACFA    Chg msg RACF013 to RACF012                   */
/* @BP  200424  RACFA    Move DDNAME at top, standardize/del dups     */
/* @BO  200423  RACFA    Move PARSE REXXPGM name up above IF SETMTRAC */
/* @BN  200423  RACFA    'Status Interval' by percentage (SETGSTAP)   */
/* @BM  200422  RACFA    Ensure the REXX program name is 8 chars      */
/* @BL  200422  RACFA    Use variable REXXPGM in log msg              */
/* @BK  200413  RACFA    Chg TRACEing to only display banner (P=Pgms) */
/* @BJ  200412  RACFA    Chg TRACE to allow 'L'abels or 'R'esults     */
/* @BI  200407  RACFA    EXCMD removed 'else msg_var = 1 to msg.0'    */
/* @BH  200404  RACFA    'Admin RACF API = Y' then display 'P'rofile  */
/* @BG  200402  RACFA    Chg LRECL=132 to LRECL=80                    */
/* @BF  200401  RACFA    Fixed point-n-shoot default sort (RACFCLS5)  */
/* @BE  200401  RACFA    Create subroutine to VIEW/EDIT/BROWSE        */
/* @BD  200401  RACFA    Chged edit macro RACFLOGE to RACFEMAC        */
/* @BC  200401  RACFA    VIEW/EDIT use edit macro, to turn off HILITE */
/* @BB  200331  RACFA    Deleted variable SELCMDS1/2, now SELCMDS     */
/* @BA  200331  TRIDJK   Added 'P'rofile to panel                     */
/* @B9  200330  RACFA    Chg RACFDLS5 point/shoot ascending/descending*/
/* @B8  200330  RACFA    Allow point-n-shoot sort ascending/descending*/
/* @B7  200324  RACFA    Allow both display/logging of RACF commands  */
/* @B6  200324  RACFA    Allow logging RACF commands to ISPF Log file */
/* @B5  200315  RACFA    Added line cmd 'P=Profile'                   */
/* @B4  200303  RACFA    Chg 'RC/Ret_code' to 'cmd_rc' after EXCMD    */
/* @B3  200303  RACFA    Fixed RC and del TBDMOD, not needed          */
/* @B2  200303  RACFA    Chk RC 'RLIST prms', if RC>0 then 'RLIST'    */
/* @B1  200303  RACFA    Del CMDPRM and get_setropts_options          */
/* @AZ  200303  RACFA    Fixed chking RC, del TBMOD, not needed       */
/* @AY  200302  RACFA    Del TBTOP cmd, prior to TBSCAN for LOCATE    */
/* @AW  200301  RACFA    Fixed displaying userids, was ret_code       */
/* @AU  200301  RACFA    Del EMSG procedure, instead call racfmsgs    */
/* @AT  200226  RACFA    Fix @AR chg, chg ret_code to cmd_rc          */
/* @AS  200226  RACFA    Added 'CONTROL ERRORS RETURN'                */
/* @AR  200226  RACFA    Added 'Return Code =' when displaying cmd    */
/* @AQ  200226  RACFA    Removed double quotes before/after cmd       */
/* @AP  200225  RACFA    Chg PANEL09=RACFCLS9 to PANEL02=RACFCLS2     */
/* @AO  200225  TRIDJK   Fix ONLY search argument for profiles        */
/* @AN  200224  RACFA    Standardize quotes, chg single to double     */
/* @AM  200224  RACFA    Place panels at top of REXX in variables     */
/* @AL  200223  RACFA    Deleted panel RACFCLS2, no longer needed     */
/* @AK  200223  RACFA    Added primary cmds SORT, LOCATE, ONLY, RESET */
/* @AJ  200223  RACFA    Del 'address TSO "PROFILE MSGID"', not needed*/
/* @AI  200222  RACFA    Allow placing cursor on row and press ENTER  */
/* @AH  200221  RACFA    Removed "G = '(G)'", not referenced          */
/* @AG  200221  RACFA    Make 'ADDRESS ISPEXEC' defualt, reduce code  */
/* @AF  200220  RACFA    Fixed displaying all RACF commands           */
/* @AE  200220  RACFA    When SETMTRAC=YES, then TRACE R, was I       */
/* @AD  200220  RACFA    Removed initializing SETGSTA variable        */
/* @AC  200220  RACFA    Added capability to browse/edit/view file    */
/* @AB  200218  RACFA    Use dynamic area to display SELECT commands  */
/* @AA  200218  RACFA    Added 'Status Interval' option               */
/* @A9  200123  RACFA    Retrieve default filter, Option 0 - Settings */
/* @A8  200123  TRIDJK   If LG fails, then issue a LU                 */
/* @A7  200122  RACFA    set rfilter='', so as not to tie up terminal */
/* @A6  200122  TRIDJK   Test/del MFA option from 'LU userid' command */
/* @A5  200120  RACFA    Removed 'say msg.msg_var' in EXCMD procedure */
/* @A4  200119  RACFA    Standardized/reduced lines of code           */
/* @A3  200119  RACFA    Added comment box above procedures           */
/* @A2  200118  RACFA    Added line command L-List to display group   */
/* @A1  200118  RACFA    Added line command L-List to execute RLIST   */
/* @A0  011229  NICORIZ  Created REXX, V2.1, www.rizzuto.it           */
/*====================================================================*/
PANEL01     = "RACFCLS1"   /* Set filter, menu option 4    */ /* @AM */
PANEL02     = "RACFCLS2"   /* List profiles/descriptions   */ /* @AP */
PANEL03     = "RACFCLS3"   /* Add class                    */ /* @AM */
PANEL04     = "RACFCLS4"   /* Change class                 */ /* @AM */
PANEL05     = "RACFCLS5"   /* List group/ids and access    */ /* @AM */
PANEL06     = "RACFCLS6"   /* Change access                */ /* @AM */
PANEL07     = "RACFCLS7"   /* Add access                   */ /* @AM */
PANEL12     = "RACFCLSB"   /* List members                 */ /* @AM */
PANEL13     = "RACFCLSC"   /* Add class                    */ /* @AM */
PANELM1     = "RACFMSG1"   /* Confirm Request (pop-up)     */ /* @AM */
PANELM2     = "RACFMSG2"   /* Display RACF command and RC  */ /* @AM */
PANELS1     = "RACFSAVE"   /* Obtain DSName to SAVE        */ /* @C3 */
SKELETON1   = "RACFCLS2"   /* Save tablea to dataset       */ /* @C3 */
SKELETON2   = "RACFCLS5"   /* Save tableb to dataset       */ /* @C3 */
EDITMACR    = "RACFEMAC"   /* Edit Macro, turn HILITE off  */ /* @BD */
TABLEA      = 'TA'RANDOM(0,99999)  /* Unique table name A  */ /* @BT */
TABLEB      = 'TB'RANDOM(0,99999)  /* Unique table name B  */ /* @BU */
DDNAME      = 'RACFA'RANDOM(0,999) /* Unique ddname        */ /* @BP */
NULL        = ''                                              /* @BV */
parse source . . REXXPGM .         /* Obtain REXX pgm name */ /* @BO */
REXXPGM     = LEFT(REXXPGM,8)                                 /* @BO */

ADDRESS ISPEXEC                                               /* @AG */
  Arg Rclass Rfilter Rdisp
  If (Rfilter = '') Then Do                                   /* @A9 */
     "VGET (SETGFLTR) PROFILE"                                /* @A9 */
     Rfilter = SETGFLTR                                       /* @A9 */
  end                                                         /* @A9 */

  Raclist       = 'NO'
  Pnl_list_prof = PANEL02                                     /* @AP */
  Rclass        = strip(rclass)

  "CONTROL ERRORS RETURN"                                     /* @AS */
  "VGET (SETGSTA  SETGSTAP SETGDISP SETGCONF",                /* @BS */
        "SETMADMN SETMIRRX SETMSHOW SETMTRAC"                 /* @BS */

  If (SETMTRAC <> 'NO') then do                               /* @BJ */
     Say "*"COPIES("-",70)"*"                                 /* @BJ */
     Say "*"Center("Begin Program = "REXXPGM,70)"*"           /* @BJ */
     Say "*"COPIES("-",70)"*"                                 /* @BJ */
     if (SETMTRAC <> 'PROGRAMS') THEN                         /* @BK */
        interpret "Trace "SUBSTR(SETMTRAC,1,1)                /* @BJ */
  end

  If (SETMADMN = "YES") then do                               /* @B5 */
     IF (SETMIRRX = "YES") THEN                               /* @BH */
        SELCMDS = "ÝS¨Show,ÝL¨List,ÝP¨Profile,"||,            /* @BB */
                  "ÝC¨Change,ÝA¨Add,ÝR¨Remove"                /* @B5 */
     ELSE                                                     /* @BH */
        SELCMDS = "ÝS¨Show,ÝL¨List,"||,                       /* @BH */
                  "ÝC¨Change,ÝA¨Add,ÝR¨Remove"                /* @BH */
  end                                                         /* @B5 */
  else do                                                     /* @BZ */
     IF (SETMIRRX = "YES") THEN                               /* @BH */
        SELCMDS = "ÝS¨Show,ÝL¨list,ÝP¨Profile"                /* @BZ */
     ELSE                                                     /* @BZ */
        SELCMDS = "ÝS¨Show,ÝL¨list"                           /* @AB */
  end                                                         /* @BZ */

  rlv    = SYSVAR('SYSLRACF')
  called = SYSVAR('SYSNEST')
  If (called = 'YES') & (rdisp <> 'YES') then
     "CONTROL NONDISPL ENTER"

  "DISPLAY PANEL("PANEL01")"                                  /* @AM */
  Do while (rc = 0)
     call Profl
     if (called <> 'YES') | (rdisp = 'YES') then
        "DISPLAY PANEL("PANEL01")"                            /* @AM */
  end

  If (raclist = 'YES') then do
     msg    = 'You are about to refresh class',
               rclass 'in RACLIST'
     Sure_? = Confirm_request(msg)
     if (sure_? = 'YES') then do
        cmd = "SETROPTS RACLIST("rclass") REFRESH"            /* @AF */
        address TSO cmd                                       /* @AF */
        cmd_rc = rc                                           /* @AR */
        if (SETMSHOW <> 'NO') then                            /* @B6 */
           call SHOWCMD                                       /* @AF */
     end
  end

  If (SETMTRAC <> 'NO') then do                               /* @BJ */
     Say "*"COPIES("-",70)"*"                                 /* @BJ */
     Say "*"Center("End Program = "REXXPGM,70)"*"             /* @BJ */
     Say "*"COPIES("-",70)"*"                                 /* @BJ */
  end                                                         /* @BJ */
RETURN 0
/*--------------------------------------------------------------------*/
/*  Show all profiles for a filter                                    */
/*--------------------------------------------------------------------*/
PROFL:
  Call CREATE_TABLEA
  opta   = ' '
  xtdtop = 0                                                  /* @BW */
  rsels  = 0                                                  /* @BW */
  do forever                                                  /* @BW */
     if (rsels < 2) then do                                   /* @BW */
        "TBTOP " TABLEA                                       /* @BW */
        'tbskip' tablea 'number('xtdtop')'                    /* @BW */
        radmrfnd = 'PASSTHRU'                                 /* @BW */
        'vput (radmrfnd)'                                     /* @BW */
        "TBDISPL" TABLEA "PANEL("Pnl_list_prof")"             /* @BW */
     end                                                      /* @BW */
     else 'tbdispl' tablea                                    /* @BW */
     if (rc > 4) then do                                      /* @C9 */
        src = rc                                              /* @C9 */
        'tbclose' tablea                                      /* @C9 */
        rc = src                                              /* @C9 */
        leave                                                 /* @C9 */
        end                                                   /* @C9 */
     xtdtop   = ztdtop                                        /* @BW */
     rsels    = ztdsels                                       /* @BW */
     radmrfnd = null                                          /* @BW */
     'vput (radmrfnd)'                                        /* @BW */
     PARSE VAR ZCMD ZCMD PARM SEQ                             /* @BW */
     IF (SROW <> "") & (SROW <> 0) THEN                       /* @AI */
        IF (SROW > 0) THEN DO                                 /* @AI */
           "TBTOP " TABLEA                                    /* @AI */
           "TBSKIP" TABLEA "NUMBER("SROW")"                   /* @AI */
        END                                                   /* @AI */
     if (zcmd = 'RFIND') then do                              /* @BV */
        zcmd = 'FIND'                                         /* @BV */
        parm = findit                                         /* @BV */
        'tbtop ' TABLEA                                       /* @BV */
        'tbskip' TABLEA 'number('last_find')'                 /* @BV */
     end                                                      /* @BV */
     Select                                                   /* @AK */
        When (abbrev("FIND",zcmd,1) = 1) then                 /* @BV */
             call do_finda                                    /* @BV */
        WHEN (ABBREV("LOCATE",ZCMD,1) = 1) THEN do            /* @A5 */
             if (parm <> '') then do                          /* @BW */
                locarg = parm'*'                              /* @BW */
                PARSE VAR SORT . "," . "," SEQ                /* @BW */
                IF (SEQ = "D") THEN                           /* @BW */
                   CONDLIST = "LE"                            /* @BW */
                ELSE                                          /* @BW */
                   CONDLIST = "GE"                            /* @BW */
                parse value sort with scan_field',' .         /* @BW */
                interpret scan_field ' = locarg'              /* @BW */
                'tbtop ' tablea                               /* @BW */
                "TBSCAN "TABLEA" ARGLIST("scan_field")",      /* @BW */
                        "CONDLIST("CONDLIST")",               /* @BW */
                        "position(scanrow)"                   /* @BW */
                xtdtop = scanrow                              /* @BW */
             end                                              /* @BW */
        end                                                   /* @BW */
        WHEN (ABBREV("ONLY",ZCMD,1) = 1) THEN DO              /* @AK */
             find_str = translate(parm)                       /* @AK */
             'tbtop ' TABLEA                                  /* @AK */
             'tbskip' TABLEA                                  /* @AK */
             do forever                                       /* @AK */
                str = translate(profile data)                 /* @AO */
                if (pos(find_str,str) > 0) then nop           /* @AK */
                else 'tbdelete' TABLEA                        /* @AK */
                'tbskip' TABLEA                               /* @AK */
                if (rc > 0) then do                           /* @AK */
                   'tbtop' TABLEA                             /* @AK */
                   leave                                      /* @AK */
                end                                           /* @AK */
             end                                              /* @AK */
        END                                                   /* @AK */
        WHEN (ABBREV("RESET",ZCMD,1) = 1) THEN DO             /* @AK */
             if (parm <> '') then                             /* @BR */
                rfilter = parm                                /* @BR */
             sort     = 'PROFILE,C,A'                         /* @AK */
             sortprof = 'D'; sortdata = 'A'                   /* @B8 */
             xtdtop   = 1                                     /* @AK */
             "TBEND" TABLEA                                   /* @B8 */
             call CREATE_TABLEA                               /* @AK */
        END                                                   /* @AK */
        When (abbrev("SAVE",zcmd,2) = 1) then DO              /* @C3 */
             TMPSKELT = SKELETON1                             /* @C3 */
             call do_SAVE                                     /* @C3 */
        END                                                   /* @C3 */
        WHEN (ABBREV("SORT",ZCMD,1) = 1) THEN DO              /* @AK */
             SELECT                                           /* @AK */
                when (ABBREV("PROFILE",PARM,1) = 1) then      /* @AK */
                     call sortseq 'PROFILE'                   /* @B8 */
                when (ABBREV("DESCRIPTION",PARM,1) = 1) then  /* @AK */
                     call sortseq 'DATA'                      /* @B8 */
                otherwise NOP                                 /* @AK */
             END                                              /* @AK */
             PARSE VAR SORT LOCARG "," .                      /* @BW */
             CLRPROF = "GREEN"; CLRDATA = "GREEN"             /* @BW */
             INTERPRET "CLR"SUBSTR(LOCARG,1,4)" = 'TURQ'"     /* @BW */
             "TBSORT" TABLEA "FIELDS("sort")"                 /* @BW */
             "TBTOP " TABLEA                                  /* @BW */
        END                                                   /* @AK */
        otherwise NOP                                         /* @AK */
     END /* Select */                                         /* @AK */
     ZCMD = ""; PARM = ""                                     /* @BW */
     'control display save'                                   /* @BW */
     Select
        when (opta = 'A') then call Addd
        when (opta = 'C') then call Chgd
        when (opta = 'L') then call Lisd                      /* @A1 */
        when (opta = 'M') then call Dism
        when (opta = 'P') then                                /* @BA */
             call RACFPROF rclass profile                     /* @BA */
        when (opta = 'R') then call Deld
        when (opta = 'S') then call Disd
        otherwise nop
     End
     'control display restore'                                /* @BW */
  end  /* Do forever) */                                      /* @BW */
RETURN
/*--------------------------------------------------------------------*/
/*  Process primary command FIND for TABLEA                      @BV  */
/*--------------------------------------------------------------------*/
DO_FINDA:                                                     /* @BV */
  if (parm = null) then do                                    /* @BV */
     racfsmsg = 'Error'                                       /* @BV */
     racflmsg = 'Find requires a value to search for.' ,      /* @BV */
                'Try again.'                                  /* @BV */
     'setmsg msg(RACF011)'                                    /* @BV */
     return                                                   /* @BV */
  end                                                         /* @BV */
  findit    = translate(parm)                                 /* @BV */
  last_find = 0                                               /* @BV */
  wrap      = 0                                               /* @BV */
  do forever                                                  /* @BV */
     'tbskip' TABLEA                                          /* @BV */
     if (rc > 0) then do                                      /* @BV */
        if (wrap = 1) then do                                 /* @BV */
           racfsmsg = 'Not Found'                             /* @BV */
           racflmsg = findit 'not found.'                     /* @BV */
           'setmsg msg(RACF011)'                              /* @BV */
           return                                             /* @BV */
        end                                                   /* @BV */
        if (wrap = 0) then wrap = 1                           /* @BV */
        'tbtop' TABLEA                                        /* @BV */
     end                                                      /* @BV */
     else do                                                  /* @BV */
        testit = translate(profile data)                      /* @BV */
        if (pos(findit,testit) > 0) then do                   /* @BV */
           'tbquery' TABLEA 'position(srow)'                  /* @BV */
           'tbtop'   TABLEA                                   /* @BV */
           'tbskip'  TABLEA 'number('srow')'                  /* @BV */
           last_find = srow                                   /* @BV */
           xtdtop    = srow                                   /* @BV */
           if (wrap = 0) then                                 /* @BV */
              racfsmsg = 'Found'                              /* @BV */
           else                                               /* @BV */
              racfsmsg = 'Found/Wrapped'                      /* @BV */
           racflmsg = findit 'found in row' srow + 0          /* @BV */
           'setmsg msg(RACF011)'                              /* @BV */
           return                                             /* @BV */
        end                                                   /* @BV */
     end                                                      /* @BV */
  end                                                         /* @BV */
RETURN                                                        /* @BV */
/*--------------------------------------------------------------------*/
/*  Define sort sequence, to allow point-n-shoot sorting (A/D)   @B8  */
/*--------------------------------------------------------------------*/
SORTSEQ:                                                      /* @B8 */
  parse arg sortcol                                           /* @B8 */
  INTERPRET "TMPSEQ = SORT"substr(SORTCOL,1,4)                /* @B8 */
  select                                                      /* @B8 */
     when (seq <> "") then do                                 /* @B8 */
          if (seq = 'A') then                                 /* @B8 */
             tmpseq = 'D'                                     /* @B8 */
          else                                                /* @B8 */
             tmpseq = 'A'                                     /* @B8 */
          sort = sortcol',C,'seq                              /* @B8 */
     end                                                      /* @B8 */
     when (seq = ""),                                         /* @B8 */
        & (tmpseq = 'A') then do                              /* @B8 */
           sort   = sortcol',C,A'                             /* @B8 */
           tmpseq = 'D'                                       /* @B8 */
     end                                                      /* @B8 */
     Otherwise do                                             /* @B8 */
        sort   = sortcol',C,D'                                /* @B8 */
        tmpseq = 'A'                                          /* @B8 */
     end                                                      /* @B8 */
  end                                                         /* @B8 */
  INTERPRET "SORT"SUBSTR(SORTCOL,1,4)" = TMPSEQ"              /* @B8 */
RETURN                                                        /* @B8 */
/*--------------------------------------------------------------------*/
/*  Add new profile                                                   */
/*--------------------------------------------------------------------*/
ADDD:
  new ='NO'
  if (profile = 'NONE') then
     new = 'YES'
  else
     CALL Getd
  "DISPLAY PANEL("PANEL03")"                                  /* @AM */
  if (rc > 0) then
     return
  if (type = 'DISCRETE') then
     type = ' '
  aud = ' '
  wrn = ' '
  if (warn = 'YES') then
     wrn = 'WARNING'
  if (fail <> ' ') then
     aud = 'FAILURES('FAIL')'
  if (succ <> ' ') then
     aud = 'SUCCESS('SUCC')' aud
  if (aud <> ' ') then
     aud = 'AUDIT('AUD')'
  xtr = ' '
  if (data <> ' ') then
     xtr = xtr "DATA('"data"')"
  call EXCMD "RDEF "RCLASS" ("PROFILE") OWN("OWNER")",
             "UACC("UACC")" aud xtr wrn
  if (cmd_rc > 0) then do                                     /* @B4 */
     CALL racfmsgs 'ERR01' /* Add failed */                   /* @AU */
     return
  end
  x = msg('OFF')
  call EXCMD "PE "PROFILE" CLASS("RCLASS")",
             "ID("USERID()") DELETE" TYPE
  x = msg('ON')
  if (from <> ' ') then do
     if (type <> ' ') then ftype = 'FGENERIC'
     else ftype = ''
     fopt = "FROM("FROM") FCLASS("FCLASS") "FTYPE""
     call EXCMD "PERMIT "PROFILE" CLASS("RCLASS")",
                 TYPE FOPT
     if (cmd_rc > 0) then                                     /* @B4 */
        CALL racfmsgs 'ERR04' /* Permit Warn */               /* @AU */
  end
  if (type = ' ') then
     type = 'DISCRETE'
  "TBMOD" TABLEA "ORDER"                                      /* @BX */
  if (new = 'YES') then do
     profile = 'NONE'
     type    = 'GEN'
     "TBDELETE"  TABLEA
  end
RETURN
/*--------------------------------------------------------------------*/
/*  Change profile                                                    */
/*--------------------------------------------------------------------*/
CHGD:
  if (profile = 'NONE') then
     return
  CALL Getd
  "DISPLAY PANEL("PANEL04")"                                  /* @AM */
  if (rc > 0) then return
  own = ' '
  if (owner <> ' ') then
     own = 'OWNER('OWNER')'
  wrn = ' '
  if (warn  = 'YES') then
     wrn = 'WARNING'
  else
     wrn = 'NOWARNING'
  uc = ' '
  if (uacc <> ' ') then
     uc = 'UACC('UACC')'
  aud = ' '
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
  call EXCMD "RALTER "RCLASS" ("PROFILE")",
             own uc aud xtr wrn
  if (cmd_rc > 0) then                                        /* @B4 */
     call racfmsgs 'ERR07' /* Altdsd failed */                /* @AU */
  else do
      if (type = ' ') then
         type = 'DISCRETE'
      "TBMOD" TABLEA
  end
RETURN
/*--------------------------------------------------------------------*/
/*  Delete Profile                                                    */
/*--------------------------------------------------------------------*/
DELD:
  if (profile = 'NONE') then
     return
  if (type = 'DISCRETE') then
     type = ' '
  msg    ='You are about to delete 'profile
  Sure_? = Confirm_request(msg)
  if (sure_? = 'YES') then do
     call EXCMD "RDELETE "RCLASS PROFILE
     if (cmd_rc = 0) then do                                  /* @B4 */
        if type = ' ' then
           type = 'DISCRETE'
        "TBDELETE" TABLEA
     end
     else
        CALL racfmsgs "ERR02" /* RDELETE failed */            /* @AU */
  end
RETURN
/*--------------------------------------------------------------------*/
/*  Display member list                                               */
/*--------------------------------------------------------------------*/
DISM:
  if (profile = 'NONE') then
     return
  "TBCREATE" TABLEB "KEYS(ID) NAMES(ACC) REPLACE NOWRITE"
  id = 'NONE'
  /* Populate table */
  call GETM
  /* Permit table display section */
  rb   = 'NO'
  optb = ' '
  /* Ability to perform actions on different profile */
  Real_profile = profile||rclass
  Profchg      = 'NO'
  If (profile||rclass <> Real_profile) then Profchg = 'YES'
  "TBSORT " TABLEB "FIELDS(ID)"
  "TBTOP  " TABLEB
  xtdtop = 0                                                  /* @BW */
  rsels = 0                                                   /* @BW */
  do forever                                                  /* @BW */
     if (rsels < 2) then do                                   /* @BW */
        optb = ' '                                            /* @C8 */
        "TBTOP " TABLEB                                       /* @BW */
        'tbskip' tableb 'number('xtdtop')'                    /* @BW */
        radmrfnd = 'PASSTHRU'                                 /* @BW */
        'vput (radmrfnd)'                                     /* @BW */
        "TBDISPL" TABLEB "PANEL("PANEL12")"                   /* @BW */
     end                                                      /* @BW */
     else 'tbdispl' tablea                                    /* @BW */
     if (rc > 4) then do                                      /* @C9 */
        src = rc                                              /* @C9 */
        'tbclose' tablea                                      /* @C9 */
        rc = src                                              /* @C9 */
        leave                                                 /* @C9 */
        end                                                   /* @C9 */
     xtdtop   = ztdtop                                        /* @BW */
     rsels    = ztdsels                                       /* @BW */
     radmrfnd = null                                          /* @BW */
     'vput (radmrfnd)'                                        /* @BW */
     PARSE VAR ZCMD ZCMD PARM SEQ                             /* @BW */
     IF (SROW <> "") & (SROW <> 0) THEN                       /* @AI */
        IF (SROW > 0) THEN DO                                 /* @AI */
           "TBTOP " TABLEB                                    /* @AI */
           "TBSKIP" TABLEB "NUMBER("SROW")"                   /* @AI */
        END                                                   /* @AI */
     ZCMD = ""; PARM = ""                                     /* @BW */
     'control display save'                                   /* @BW */
     Select
        when (optb = 'A') then call Addm
        when (optb = 'R') then call Delm
        otherwise nop
     End
     'control display restore'                                /* @BW */
  end  /* Do forever) */                                      /* @BW */
  "TBEND" TABLEB
RETURN
/*--------------------------------------------------------------------*/
/*  Add member                                                        */
/*--------------------------------------------------------------------*/
ADDM:
  new = 'NO'
  if (id = 'NONE') then
     new = 'YES'
  "DISPLAY PANEL("PANEL13")"                                  /* @AM */
  if (rc > 0) then return
  addmem = 'ADDMEM('id')'
  call EXCMD "RALTER "RCLASS PROFILE ADDMEM
  if (cmd_rc = 0) then do                                     /* @B4 */
     "TBMOD" TABLEB
     if (new = 'YES') then do
        id = 'NONE'
        "TBDELETE" TABLEB
     end
  end
  else call racfmsgs 'ERR10' /* Add member Failed */          /* @AU */
RETURN
/*--------------------------------------------------------------------*/
/*  Remove Member                                                     */
/*--------------------------------------------------------------------*/
DELM:
  if (id = 'NONE') then
     return
  msg    ='You are about to delete 'id
  Sure_? = Confirm_request(msg)
  if (sure_? = 'YES') then do
     delmem = 'DELMEM('id')'
     call EXCMD "RALTER "RCLASS PROFILE DELMEM
     if (cmd_rc = 0) then                                     /* @B4 */
        "TBDELETE" TABLEB
     else
        CALL racfmsgs "ERR14"   /* RDELETE failed */          /* @AU */
  end
RETURN
/*--------------------------------------------------------------------*/
/*  Get member list                                                   */
/*--------------------------------------------------------------------*/
GETM:
  cmd = "RLIST "RCLASS PROFILE" AUTH"                         /* @AF */
  x = OUTTRAP('var.')
  address TSO cmd                                             /* @AF */
  cmd_rc = rc                                                 /* @AR */
  x = OUTTRAP('OFF')
  if (SETMSHOW <> 'NO') then                                  /* @B6 */
     call SHOWCMD                                             /* @AF */
  dism_max = var.0
  rsce_beg = 0
  rsce_end = 0
  Do dism_count=0 to dism_max
     rsce_beg = POS('RESOURCES IN GROUP',var.dism_count)
     if rsce_beg then
        do until rsce_end
           dism_count = dism_count+1
           parse var var.dism_count id rest
           rsce_end = POS('LEVEL  OWNER',var.dism_count)
           if (id <> '') & (id <> '---------') & ^rsce_end
             then "TBMOD" TABLEB
        end
  end
RETURN
/*--------------------------------------------------------------------*/
/*  Display profile permits                                           */
/*--------------------------------------------------------------------*/
DISD:
  if (profile = 'NONE') then
     return
  tmpsort   = sort                                            /* @B9 */
  tmprsels  = rsels                                           /* @C1 */
  tmpxtdtop = xtdtop                                          /* @C2 */
  Do until (RB='NO')     /* allow rebuild option */
     call create_TABLEB                                       /* @B9 */
     Real_profile = profile||rclass
     rb      = 'NO'
     Profchg = 'NO'
     xtdtop  = 0                                              /* @BW */
     rsels   = 0                                              /* @BW */
     do forever                                               /* @BW */
        if (rsels < 2) then do                                /* @BW */
           optb = ' '                                         /* @BW */
           "TBTOP " TABLEB                                    /* @BW */
           'tbskip' tableb 'number('xtdtop')'                 /* @BW */
           radmrfnd = 'PASSTHRU'                              /* @BW */
           'vput (radmrfnd)'                                  /* @BW */
           "TBDISPL" TABLEB "PANEL("PANEL05")"                /* @BW */
        end                                                   /* @BW */
        else 'tbdispl' tableb                                 /* @BW */
        retb = rc                                             /* @BW */
        if (retb > 4) then do                                 /* @C9 */
           src = rc                                           /* @C9 */
           'tbclose' tableb                                   /* @C9 */
           rc = src                                           /* @C9 */
           leave                                              /* @C9 */
           end                                                /* @C9 */
        xtdtop   = ztdtop                                     /* @BW */
        rsels    = ztdsels                                    /* @BW */
        radmrfnd = null                                       /* @BW */
        'vput (radmrfnd)'                                     /* @BW */
        PARSE VAR ZCMD ZCMD PARM SEQ                          /* @BW */
        IF (SROW <> "") & (SROW <> 0) THEN                    /* @AI */
           IF (SROW > 0) THEN DO                              /* @AI */
              "TBTOP " TABLEB                                 /* @AI */
              "TBSKIP" TABLEB "NUMBER("SROW")"                /* @AI */
           END                                                /* @AI */
        if (zcmd = 'RFIND') then do                           /* @BV */
           zcmd = 'FIND'                                      /* @BV */
           parm = findit                                      /* @BV */
           'tbtop ' TABLEB                                    /* @BV */
           'tbskip' TABLEB 'number('last_find')'              /* @BV */
        end                                                   /* @BV */
        Select                                                /* @B9 */
           When (abbrev("FIND",zcmd,1) = 1) then              /* @BV */
                call do_findb                                 /* @BV */
           WHEN (ABBREV("LOCATE",ZCMD,1) = 1) THEN DO         /* @BW */
                if (parm <> '') then do                       /* @BW */
                   locarg = parm'*'                           /* @BW */
                   PARSE VAR SORT . "," . "," SEQ             /* @BW */
                   IF (SEQ = "D") THEN                        /* @BW */
                      CONDLIST = "LE"                         /* @BW */
                   ELSE                                       /* @BW */
                      CONDLIST = "GE"                         /* @BW */
                   parse value sort with scan_field',' .      /* @BW */
                   interpret scan_field ' = locarg'           /* @BW */
                   'tbtop ' tableb                            /* @BW */
                   "TBSCAN "TABLEB" ARGLIST("scan_field")",   /* @BW */
                           "CONDLIST("CONDLIST")",            /* @BW */
                           "position(scanrow)"                /* @BW */
                   xtdtop = scanrow                           /* @BW */
                end                                           /* @BW */
           end                                                /* @BW */
           WHEN (ABBREV("ONLY",ZCMD,1) = 1) THEN DO           /* @B9 */
                find_str = translate(parm)                    /* @B9 */
                'tbtop ' TABLEB                               /* @B9 */
                'tbskip' TABLEB                               /* @B9 */
                do forever                                    /* @B9 */
                   str = translate(id acc)                    /* @B9 */
                   if (pos(find_str,str) > 0) then nop        /* @B9 */
                   else 'tbdelete' TABLEB                     /* @B9 */
                   'tbskip' TABLEB                            /* @B9 */
                   if (rc > 0) then do                        /* @B9 */
                      'tbtop' TABLEB                          /* @B9 */
                      leave                                   /* @B9 */
                   end                                        /* @B9 */
                end                                           /* @B9 */
           END                                                /* @B9 */
           WHEN (ABBREV("RESET",ZCMD,1) = 1) THEN DO          /* @B9 */
                if (parm <> '') then                          /* @BR */
                   rfilter = parm                             /* @BR */
                SORT   = 'ID,C,A'                             /* @B9 */
                sortid = 'D'; sortacc = 'A'                   /* @B9 */
                xtdtop   = 1                                  /* @B9 */
                "TBEND" TABLEB                                /* @B9 */
                call create_TABLEB                            /* @B9 */
           END                                                /* @B9 */
           When (abbrev("SAVE",zcmd,2) = 1) then DO           /* @C3 */
                TMPSKELT = SKELETON2                          /* @C3 */
                call do_SAVE                                  /* @C3 */
           END                                                /* @C3 */
           WHEN (ABBREV("SORT",ZCMD,1) = 1) THEN DO           /* @B9 */
                SELECT                                        /* @B9 */
                   when (ABBREV("GROUP",PARM,1) = 1) then     /* @B9 */
                        call sortseq 'ID'                     /* @B9 */
                   when (ABBREV("ID",PARM,1) = 1) then        /* @B9 */
                        call sortseq 'ID'                     /* @B9 */
                   when (ABBREV("ACCESS",PARM,1) = 1) then    /* @B9 */
                        call sortseq 'ACC'                    /* @B9 */
                   otherwise NOP                              /* @B9 */
                END                                           /* @B9 */
                PARSE VAR SORT LOCARG "," .                   /* @BW */
                CLRID = "GREEN"; CLRACC = "GREEN"             /* @BW */
                INTERPRET "CLR"SUBSTR(LOCARG,1,4)" = 'TURQ'"  /* @BW */
                "TBSORT" TABLEB "FIELDS("sort")"              /* @BW */
                "TBTOP " TABLEB                               /* @BW */
           END                                                /* @B9 */
           otherwise NOP                                      /* @B9 */
        END /* Select */                                      /* @B9 */
        ZCMD = ""; PARM = ""                                  /* @BW */
        'control display save'                                /* @BW */
        Select
           when (optb = 'A') then call Addp
           when (optb = 'C') then call Chgp
           when (optb = 'L') then call Lisp                   /* @A2 */
           when (optb = 'P') then                             /* @B5 */
                call RACFPROF 'GROUP' ID                      /* @B5 */
           when (optb = 'R') then call Delp
           when (optb = 'S') then call Disp
           otherwise nop
        End
        'control display restore'                             /* @BW */
     end  /* Do forever) */                                   /* @BW */
     "TBEND" TABLEB
  end  /* Do until */
  sort   = tmpsort                                            /* @B9 */
  rsels  = tmprsels                                           /* @C1 */
  xtdtop = tmpxtdtop                                          /* @C2 */
RETURN
/*--------------------------------------------------------------------*/
/*  Process primary command FIND for TABLEB                      @BV  */
/*--------------------------------------------------------------------*/
DO_FINDB:                                                     /* @BV */
  if (parm = null) then do                                    /* @BV */
     racfsmsg = 'Error'                                       /* @BV */
     racflmsg = 'Find requires a value to search for.' ,      /* @BV */
                'Try again.'                                  /* @BV */
     'setmsg msg(RACF011)'                                    /* @BV */
     return                                                   /* @BV */
  end                                                         /* @BV */
  findit    = translate(parm)                                 /* @BV */
  last_find = 0                                               /* @BV */
  wrap      = 0                                               /* @BV */
  do forever                                                  /* @BV */
     'tbskip' TABLEB                                          /* @BV */
     if (rc > 0) then do                                      /* @BV */
        if (wrap = 1) then do                                 /* @BV */
           racfsmsg = 'Not Found'                             /* @BV */
           racflmsg = findit 'not found.'                     /* @BV */
           'setmsg msg(RACF011)'                              /* @BV */
           return                                             /* @BV */
        end                                                   /* @BV */
        if (wrap = 0) then wrap = 1                           /* @BV */
        'tbtop' TABLEB                                        /* @BV */
     end                                                      /* @BV */
     else do                                                  /* @BV */
        testit = translate(id acc)                            /* @BV */
        if (pos(findit,testit) > 0) then do                   /* @BV */
           'tbquery' TABLEB 'position(srow)'                  /* @BV */
           'tbtop'   TABLEB                                   /* @BV */
           'tbskip'  TABLEB 'number('srow')'                  /* @BV */
           last_find = srow                                   /* @BV */
           xtdtop    = srow                                   /* @BV */
           if (wrap = 0) then                                 /* @BV */
              racfsmsg = 'Found'                              /* @BV */
           else                                               /* @BV */
              racfsmsg = 'Found/Wrapped'                      /* @BV */
           racflmsg = findit 'found in row' srow + 0          /* @BV */
           'setmsg msg(RACF011)'                              /* @BV */
           return                                             /* @BV */
        end                                                   /* @BV */
     end                                                      /* @BV */
  end                                                         /* @BV */
RETURN                                                        /* @BV */
/*--------------------------------------------------------------------*/
/*  Create table 'B'                                             @B9  */
/*--------------------------------------------------------------------*/
CREATE_TABLEB:                                                /* @B9 */
  "TBCREATE" TABLEB "KEYS(ID)",
                  "NAMES(ACC) REPLACE NOWRITE"
  flags = 'OFF'
  audit = ' '
  owner = ' '
  uacc  = ' '
  data  = ' '
  warn  = ' '
  if (type = 'DISCRETE') then
     type = ' '
  cmd = "RLIST "RCLASS PROFILE" AUTH"                         /* @AF */
  x = OUTTRAP('VAR.')
  address TSO cmd                                             /* @AF */
  cmd_rc = rc                                                 /* @AR */
  x = OUTTRAP('OFF')
  if (SETMSHOW <> 'NO') then                                  /* @B6 */
     call SHOWCMD                                             /* @AF */
  if (type = ' ') then
     type = 'DISCRETE'
  Do i = 1 to var.0                /* Scan output */
     temp = var.i
     if (rlv > '1081') then  /* RACF 1.9 add blank */
        temp= ' 'temp
     l = LENGTH(temp)
     if (uacc = ' ') then
        if (substr(temp,2,12)= 'LEVEL  OWNER') then do
           i     = i + 2
           temp  = var.i
           owner = subword(temp,2,1)
           uacc  = subword(temp,3,1)
           warn  = subword(temp,5,1)
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
           id  = 'NONE'       /* empty access list */
           acc = 'DEFINED'
        end
        else do
           id  = subword(temp,1,1)
           acc = subword(temp,2,1)
        end
        "TBMOD" TABLEB
     end
     if (substr(temp,1,17) = 'USER      ACCESS') then do
        flags = 'ON'   /* start of access list */
        i     = i + 1      /* skip */
     end
  end  /* Loop scan output */
  sort     = 'ID,C,A'                                         /* @BW */
  sortid   = 'D'; sortacc  = 'A'                              /* @BW */
  CLRID = "TURQ"; CLRACC = "GREEN"   /* Col. colors */        /* @BW */
  "TBSORT " TABLEB "FIELDS("sort")"                           /* @BW */
  "TBTOP  " TABLEB                                            /* @BW */
RETURN                                                        /* @B9 */
/*--------------------------------------------------------------------*/
/*  Get RLIST info                                                    */
/*--------------------------------------------------------------------*/
GETD:
  flags  = 'OFF'
  owner  = ' '
  uacc   = ' '
  audit  = ' '
  data   = ' '
  warn   = ' '
  memcls = ' '
  cmd    = "RLIST "RCLASS PROFILE                             /* @AF */
  x = OUTTRAP('getd_var.')
  address TSO cmd                                             /* @AF */
  cmd_rc = rc                                                 /* @AR */
  x = OUTTRAP('OFF')
  if (SETMSHOW <> 'NO') then                                  /* @B6 */
     call SHOWCMD                                             /* @AF */
  Do getd_i = 1 to getd_var.0 while (flags<> 'OUT') /* Scan output */
     getd_temp = getd_var.getd_i
     if (rlv > '1081') then         /* RACF 1.9 add blank */
        getd_temp= ' 'getd_temp
     if (uacc = ' ') then
        if (substr(getd_temp,2,12) = 'LEVEL  OWNER') then do
           getd_i    = getd_i + 2
           getd_temp = getd_var.getd_i
           owner     = subword(getd_temp,2,1)
           uacc      = subword(getd_temp,3,1)
           warn      = subword(getd_temp,5,1)
        end
     if (memcls = ' ') then
        if (substr(getd_temp,2,17) = 'MEMBER CLASS NAME') then do
           getd_i        = getd_i + 2
           getd_temp     = getd_var.getd_i
           memcls        = subword(getd_temp,1,1)
           If (SETMADMN = "YES") then                         /* @AL */
               SELCMDS = "ÝS¨Show,ÝL¨list,ÝC¨Change,"||,      /* @AL */
                         "ÝA¨Add,ÝR¨Remove,ÝM¨Member"         /* @C7 */
           else                                               /* @AL */
               SELCMDS = "ÝS¨Show,ÝL¨list"                    /* @AL */
        end
     if (audit = ' ') then
        if (substr(getd_temp,2,8) = 'AUDITING') then do
           getd_i    = getd_i + 2
           getd_temp = getd_var.getd_i
           audit     = subword(getd_temp,1,1)
        end
     if (data = ' ') then
        if (substr(getd_temp,2,17) = 'INSTALLATION DATA') then do
           getd_i        = getd_i + 2
           getd_temp     = getd_var.getd_i
           data_1st_line = getd_temp
           getd_i        = getd_i+ 1
           getd_temp     = getd_var.getd_i
           data_2nd_line = getd_temp
           data = data_1st_line||strip(data_2nd_line,'t')
        end
  end  /* Getd_i= 1 do */

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
  "DISPLAY PANEL("PANEL06")"                                  /* @AM */
  if (rc > 0) then
     return
  if (type = 'DISCRETE') then
     type = ' '
  call EXCMD "PE "PROFILE" CLASS("RCLASS")",
             "ID("ID") ACC("ACC")" TYPE
  if (cmd_rc = 0) then do                                     /* @B4 */
     if (type = ' ') then
        type = 'DISCRETE'
     "TBMOD" TABLEB
  end
  else
     Call racfmsgs 'ERR03' /* Permit failed */                /* @AU */
RETURN
/*--------------------------------------------------------------------*/
/*  Display userid                                                    */
/*--------------------------------------------------------------------*/
DISP:
  x   = msg('OFF')
  cmd = "LU "id                                               /* @AF */
  x = OUTTRAP('trash.')
  address TSO cmd                                             /* @AF */
  cmd_rc = rc
  x = OUTTRAP('OFF')
  if (SETMSHOW <> 'NO') then                                  /* @B6 */
     call SHOWCMD                                             /* @AF */
  x = msg('ON')
  if (cmd_rc = 0) then call RACFUSR id                        /* @AW */
  else call RACFGRP id
RETURN
/*--------------------------------------------------------------------*/
/*  Add permit option                                                 */
/*--------------------------------------------------------------------*/
ADDP:
  new = 'NO'
  if (id = 'NONE') then
     new = 'YES'
  from = ' '
  "DISPLAY PANEL("PANEL07")"                                  /* @AM */
  if (rc > 0) then
     return
  if (type = 'DISCRETE') then
     type = ' '
  idopt = ' '
  if (id <> ' ') then
     idopt = 'ID('ID') ACCESS('ACC')'
  fopt = ' '
  if (from <> ' ') then do
     fopt = "FROM('"FROM"') FCLASS("RCLASS") FGENERIC"
     rb   = 'YES'             /* Cause table rebuild */
  end
  call EXCMD "PERMIT "PROFILE" CLASS("RCLASS") ",
              idopt type fopt
  if (cmd_rc = 0) then do                                     /* @B4 */
     "TBMOD" TABLEB
     if (new = 'YES') then do
        id = 'NONE'
        "TBDELETE" TABLEB
     end
  end
  else do
     if (from <> ' ') then
        call racfmsgs 'ERR04' /* Permit Warning/Failed */     /* @AU */
     else
        call racfmsgs 'ERR05' /* Permit Failed */             /* @AU */
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
  msg    ='You are about to delete access for 'ID
  Sure_? = Confirm_request(msg)
  if (sure_? = 'YES') then do
     call EXCMD "PE "PROFILE" CLASS("RCLASS")",
                "ID("ID") DELETE" TYPE
     if (cmd_rc = 0) then                                     /* @B4 */
        "TBDELETE" TABLEB
     else
        call racfmsgs 'ERR06'     /* Permit Failed */         /* @AU */
  end
RETURN
/*--------------------------------------------------------------------*/
/*  Confirm delete                                                    */
/*--------------------------------------------------------------------*/
CONFIRM_REQUEST:
  signal off error
  arg message
  answer  = 'NO'
  zwinttl = 'CONFIRM REQUEST'
  ckey    = ''
  if (SETGCONF ='NO') then ckey = 'ENTER'
  Do while (ckey <> 'PF03') & (ckey <> 'ENTER')
     "CONTROL NOCMD"                                          /* @AN */
     "ADDPOP"                                                 /* @AN */
     "DISPLAY PANEL("PANELM1")"                               /* @AM */
     "REMPOP"                                                 /* @AN */
  end
  Select
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
  address TSO cmd                                             /* @AQ */
  cmd_rc = rc
  x = OUTTRAP('OFF')
  if (SETMSHOW <> 'NO') then                                  /* @B6 */
     call SHOWCMD                                             /* @AF */
  if (subword(msg.1,1,1) = 'ICH11009I') |,
     (subword(msg.1,1,1) = 'ICH10006I') |,
     (subword(msg.1,1,1) = 'ICH06011I') then raclist = 'YES'
RETURN
/*--------------------------------------------------------------------*/
/*  List class's profile                                              */
/*--------------------------------------------------------------------*/
LISD:                                                         /* @A1 */
  cmd = "RLIST "RCLASS PROFILE" AUTH"                         /* @AF */
  X = OUTTRAP("CMDREC.")                                      /* @A1 */
  ADDRESS TSO cmd                                             /* @AF */
  cmd_rc = rc                                                 /* @AR */
  X = OUTTRAP("OFF")                                          /* @A1 */
  if (SETMSHOW <> 'NO') then                                  /* @B6 */
     call SHOWCMD                                             /* @AF */
  if (cmd_rc > 0) then do    /* Remove parms */               /* @B2 */
     cmd = "RLIST "RCLASS PROFILE                             /* @B2 */
     X = OUTTRAP("CMDREC.")                                   /* @B2 */
     ADDRESS TSO cmd                                          /* @B2 */
     cmd_rc = rc                                              /* @B2 */
     X = OUTTRAP("OFF")                                       /* @B2 */
     if (SETMSHOW <> 'NO') then                               /* @B6 */
        call SHOWCMD                                          /* @B2 */
  end                                                         /* @B2 */
  call display_info                                           /* @BE */
  if (cmd_rc > 0) then                                        /* @AZ */
     CALL racfmsgs "ERR10" /* Generic failure */              /* @AU */
RETURN                                                        /* @A1 */
/*--------------------------------------------------------------------*/
/*  Set boolean value for mask                                        */
/*--------------------------------------------------------------------*/
SETBOOL:
  variable = arg(1)                                           /* @A6 */
  offset   = arg(2)                                           /* @A6 */
  value    = arg(3)                                           /* @A6 */
  status1  = arg(4)                                           /* @A6 */
  status2  = arg(5)                                           /* @A6 */
  interpret "rcvtsta$= d2x((x2d("cvtrac"))+"offset")"         /* @A6 */
  x        = storage(rcvtsta$,1)                              /* @A6 */
  interpret variable '= 'status1                              /* @A6 */
  interpret "x=bitand(x,'"value"'x)" /*remove bad bits*/      /* @A6 */
  interpret "if (x= '"value"'x) then "variable"="status2      /* @A6 */
RETURN 0                                                      /* @A6 */
/*--------------------------------------------------------------------*/
/*  List group                                                        */
/*--------------------------------------------------------------------*/
LISP:                                                         /* @A2 */
  CMDPRM  = "CSDATA DFP OMVS OVM TME"                         /* @A2 */
  cmd     = "LG "ID CMDPRM                                    /* @AF */
  X = OUTTRAP("CMDREC.")                                      /* @A2 */
  ADDRESS TSO cmd                                             /* @AF */
  cmd_rc = rc                                                 /* @AR */
  X = OUTTRAP("OFF")                                          /* @A2 */
  if (SETMSHOW <> 'NO') then                                  /* @B6 */
     call SHOWCMD                                             /* @AF */
  if (cmd_rc > 0) then do                                     /* @A8 */
     X = OUTTRAP("CMDREC.")                                   /* @A2 */
     CMD     = "LU "ID                                        /* @AF */
     ADDRESS TSO cmd                                          /* @AR */
     cmd_rc = rc                                              /* @AR */
     X = OUTTRAP("OFF")                                       /* @A2 */
     if (SETMSHOW <> 'NO') then                               /* @B6 */
        call SHOWCMD                                          /* @AF */
  end                                                         /* @A8 */
  call display_info                                           /* @BE */
  if (cmd_rc > 0) then                                        /* @B3 */
     CALL racfmsgs "ERR13"   /* Generic failure */            /* @AU */
RETURN                                                        /* @A2 */
/*--------------------------------------------------------------------*/
/*  Display information from line commands 'L' and 'P'           @BE  */
/*--------------------------------------------------------------------*/
DISPLAY_INFO:                                                 /* @BE */
  ADDRESS TSO "ALLOC F("DDNAME") NEW REUSE",                  /* @A2 */
              "LRECL(80) BLKSIZE(0) RECFM(F B)",              /* @BG */
              "UNIT(VIO) SPACE(1 5) CYLINDERS"                /* @A2 */
  ADDRESS TSO "EXECIO * DISKW "DDNAME" (STEM CMDREC. FINIS"   /* @A2 */
  DROP CMDREC.                                                /* @BY */
                                                              /* @BY */
  "LMINIT DATAID(CMDDATID) DDNAME("DDNAME")"                  /* @A2 */
  SELECT                                                      /* @AC */
     WHEN (SETGDISP = "VIEW") THEN                            /* @AC */
          "VIEW DATAID("CMDDATID") MACRO("EDITMACR")"         /* @BC */
     WHEN (SETGDISP = "EDIT") THEN                            /* @AC */
          "EDIT DATAID("CMDDATID") MACRO("EDITMACR")"         /* @BC */
     OTHERWISE                                                /* @AC */
          "BROWSE DATAID("CMDDATID")"                         /* @AC */
  END                                                         /* @AC */
  ADDRESS TSO "FREE FI("DDNAME")"                             /* @A2 */
RETURN                                                        /* @BE */
/*--------------------------------------------------------------------*/
/*  Display RACF command and return code                         @AF  */
/*--------------------------------------------------------------------*/
SHOWCMD:                                                      /* @AF */
  IF (SETMSHOW = "BOTH") | (SETMSHOW = "DISPLAY") THEN DO     /* @B7 */
     PARSE VAR CMD MSG1 60 MSG2 121 MSG3                      /* @AF */
     MSG4 = "Return code = "cmd_rc                            /* @AR */
     "ADDPOP ROW(6) COLUMN(4)"                                /* @AN */
     "DISPLAY PANEL("PANELM2")"                               /* @AM */
     "REMPOP"                                                 /* @AN */
  END                                                         /* @B6 */
  IF (SETMSHOW = "BOTH") | (SETMSHOW = "LOG") THEN DO         /* @B7 */
     zerrsm = "RACFADM "REXXPGM" RC="cmd_rc                   /* @BL */
     zerrlm = cmd                                             /* @B6 */
     'log msg(isrz003)'                                       /* @B6 */
  END                                                         /* @B6 */
RETURN                                                        /* @AF */
/*--------------------------------------------------------------------*/
/*  Create table 'A'                                             @AK  */
/*--------------------------------------------------------------------*/
CREATE_TABLEA:
  seconds = TIME('S')
  "TBCREATE" TABLEA "KEYS(PROFILE TYPE)",
                  "NAMES(RCLASS DATA) REPLACE NOWRITE"
  cmd = "SEARCH FILTER("RFILTER") CLASS("rclass")"            /* @AF */
  x = OUTTRAP('var.')
  address TSO cmd                                             /* @AF */
  cmd_rc = rc                                                 /* @AR */
  x = OUTTRAP('OFF')
  if (SETMSHOW <> 'NO') then                                  /* @B6 */
     call SHOWCMD                                             /* @AF */
  if (SETGSTAP <> "") THEN                                    /* @BN */
     INTERPRET "RECNUM = var.0*."SETGSTAP"%1"                 /* @BN */
  Do i = 1 to var.0
     temp    = var.i
     profile = SUBWORD(temp,1,1)
     t       = INDEX(temp,g)
     if (t > 0) then
        type = 'GEN'
     else do
        type = 'DISCRETE'
        msgr = SUBWORD(temp,1,1)
        Select
           when (msgr = 'ICH31005I') then do
                profile = 'NONE'     /* No profiles */
                type    = 'GEN'
           end
           when (msgr = 'ICH31009I') then do
                profile = 'INVALID'  /* Bad filter  */
                call racfmsgs 'ERR08'                         /* @AU */
           end
           when (msgr = 'ICH31012I') then do
                profile = 'INVALID'  /* Bad filter  */
                call racfmsgs 'ERR08'                         /* @AU */
           end
           when (msgr = 'ICH31014I') then do
                profile = 'INVALID'  /* Bad filter  */
                call racfmsgs 'ERR08'                         /* @AU */
           end
           when (msgr = 'ICH31016I') then do
                profile = 'INVALID'  /* Bad filter  */
                call racfmsgs 'ERR08'                         /* @AU */
           end
           when (msgr = 'ICH31017I') then do
                profile = 'INVALID'  /* Bad filter  */
                call racfmsgs 'ERR08'                         /* @AU */
           end
           when (msgr= 'ICH31018I') then do
                profile = 'INVALID'  /* Bad filter  */
                call racfmsgs 'ERR08'                         /* @AU */
           end
           when (msgr = 'IKJ56716I') then do
                profile = 'INVALID'  /* Bad filter  */
                call racfmsgs 'ERR08'                         /* @AU */
           end
           when (substr(msgr,1,6) = 'ICH310') then do
                type = ' '           /* Misc. errs  */
                call racfmsgs 'ERR09'                         /* @AU */
           end
           otherwise nop
        End  /* Select */
     end  /* Else */
     /*---------------------------------------------*/
     /* Display number of records retrieved        -*/
     /*---------------------------------------------*/
     IF (SETGSTA = "") THEN DO                                /* @BN */
        IF (RECNUM <> 0) THEN                                 /* @BN */
           IF (I//RECNUM = 0) THEN DO                         /* @BN */
              n1 = i; n2 = var.0                              /* @BN */
              pct = ((n1/n2)*100)%1'%'                        /* @BN */
              "control display lock"                          /* @BN */
              "display msg(RACF012)"                          /* @BQ */
           END                                                /* @BN */
     END                                                      /* @BN */
     ELSE DO                                                  /* @BN */
        IF (SETGSTA <> 0) THEN                                /* @BN */
           IF (I//SETGSTA = 0) THEN DO                        /* @AA */
              n1 = i; n2 = var.0
              pct = ((n1/n2)*100)%1'%'                        /* @BN */
              "control display lock"
              "display msg(RACF012)"                          /* @BQ */
           END                                                /* @AA */
     END                                                      /* @BN */
     /* Get Further information */
     call GETD
     "TBMOD" TABLEA
  end  /* Do i=1 to var.0 */
  if (profile = 'INVALID') then do
     "TBEND" TABLEA
     return
  end
  sort     = 'PROFILE,C,A'                                    /* @BW */
  sortprof = 'D'; sortdata = 'A'                              /* @BW */
  CLRPROF = "TURQ"; CLRDATA = "GREEN"   /* Col. colors */     /* @BW */
  "TBSORT " TABLEA "FIELDS("sort")"                           /* @BW */
  "TBTOP  " TABLEA                                            /* @BW */
RETURN                                                        /* @AK */
/*--------------------------------------------------------------------*/
/*  Save table to dataset                                        @C3  */
/*--------------------------------------------------------------------*/
DO_SAVE:                                                      /* @C3 */
  X = MSG("OFF")                                              /* @C3 */
  "ADDPOP COLUMN(40)"                                         /* @C3 */
  "VGET (RACFSDSN RACFSMBR RACFSFIL RACFSREP) PROFILE"        /* @C4 */
  IF (RACFSDSN = "") THEN         /* SAve - Dataset Name  */  /* @C5 */
     RACFSDSN = USERID()".RACFADM.REPORTS"                    /* @EK */
  IF (RACFSFIL = "") THEN         /* SAve - As (TXT/CVS)  */  /* @C5 */
     RACFSFIL = "T"                                           /* @EL */
  IF (RACFSREP = "") THEN         /* SAve - Replace (Y/N) */  /* @C5 */
     RACFSREP = "N"                                           /* @EK */
                                                              /* @C3 */
  DO FOREVER                                                  /* @C3 */
     "DISPLAY PANEL("PANELS1")"                               /* @C3 */
     IF (RC = 08) THEN DO                                     /* @C3 */
        "REMPOP"                                              /* @C3 */
        RETURN                                                /* @C3 */
     END                                                      /* @C3 */
     RACFSDSN = STRIP(RACFSDSN,,"'")                          /* @C3 */
     RACFSDSN = STRIP(RACFSDSN,,'"')                          /* @C3 */
     RACFSDSN = STRIP(RACFSDSN)                               /* @C3 */
     SYSDSORG = ""                                            /* @C3 */
     X = LISTDSI("'"RACFSDSN"'")                              /* @C3 */
     IF (SYSDSORG = "") | (SYSDSORG = "PS"),                  /* @C3 */
      | (SYSDSORG = "PO") THEN                                /* @C3 */
        NOP                                                   /* @C3 */
     ELSE DO                                                  /* @C3 */
        RACFSMSG = "Not PDS/Seq File"                         /* @C3 */
        RACFLMSG = "The dataset specified is not",            /* @C3 */
                  "a partitioned or sequential",              /* @C3 */
                  "dataset, please enter a valid",            /* @C3 */
                  "dataset name."                             /* @C3 */
       "SETMSG MSG(RACF011)"                                  /* @C3 */
       ITERATE                                                /* @C3 */
     END                                                      /* @C3 */
     IF (SYSDSORG = "PS") & (RACFSMBR <> "") THEN DO          /* @C3 */
        RACFSMSG = "Seq File - No mbr"                        /* @C3 */
        RACFLMSG = "This dataset is a sequential",            /* @C3 */
                  "file, please remove the",                  /* @C3 */
                  "member name."                              /* @C3 */
       "SETMSG MSG(RACF011)"                                  /* @C3 */
       ITERATE                                                /* @C3 */
     END                                                      /* @C3 */
     IF (SYSDSORG = "PO") & (RACFSMBR = "") THEN DO           /* @C3 */
        RACFSMSG = "PDS File - Need Mbr"                      /* @C3 */
        RACFLMSG = "This dataset is a partitioned",           /* @C3 */
                  "dataset, please include a member",         /* @C3 */
                  "name."                                     /* @C3 */
       "SETMSG MSG(RACF011)"                                  /* @C3 */
       ITERATE                                                /* @C3 */
     END                                                      /* @C3 */
                                                              /* @C3 */
     IF (RACFSMBR = "") THEN                                  /* @C3 */
        TMPDSN = RACFSDSN                                     /* @C3 */
     ELSE                                                     /* @C3 */
        TMPDSN = RACFSDSN"("RACFSMBR")"                       /* @C3 */
     DSNCHK = SYSDSN("'"TMPDSN"'")                            /* @C3 */
     IF (DSNCHK = "OK" & RACFSREP = "N") THEN DO              /* @C3 */
        RACFSMSG = "DSN/MBR Exists"                           /* @C3 */
        RACFLMSG = "Dataset/member already exists. ",         /* @C3 */
                  "Please type in "Y" to replace file."       /* @C3 */
        "SETMSG MSG(RACF011)"                                 /* @C3 */
        ITERATE                                               /* @C3 */
     END                                                      /* @C3 */
     LEAVE                                                    /* @C3 */
  END                                                         /* @C3 */
  "REMPOP"                                                    /* @C3 */
  "VPUT (RACFSDSN RACFSMBR RACFSFIL RACFSREP) PROFILE"        /* @C4 */
                                                              /* @C3 */
ADDRESS TSO                                                   /* @C3 */
  IF (RACFSREP = "Y" & RACFSMBR = "") |,                      /* @C3 */
     (DSNCHK <> "OK" & DSNCHK <> "MEMBER NOT FOUND"),         /* @C3 */
     THEN DO                                                  /* @C3 */
     "DELETE '"RACFSDSN"'"                                    /* @C3 */
     IF (RACFSMBR = "") THEN                                  /* @C3 */
        "ALLOC  FI(ISPFILE) DA('"RACFSDSN"') NEW",            /* @C3 */
            "REUSE SP(1 1) CYLINDER UNIT(SYSALLDA)",          /* @C6 */
            "LRECL(80) RECFM(F B)"                            /* @C3 */
     ELSE                                                     /* @C3 */
        "ALLOC  FI(ISPFILE) DA('"RACFSDSN"') NEW",            /* @C3 */
            "REUSE SP(1 1) CYLINDER UNIT(SYSALLDA)",          /* @C6 */
            "LRECL(80) RECFM(F B)",                           /* @C3 */
            "DSORG(PO) DSNTYPE(LIBRARY,2)"                    /* @C3 */
  END                                                         /* @C3 */
  ELSE                                                        /* @C3 */
     "ALLOC  FI(ISPFILE) DA('"RACFSDSN"') SHR REUSE"          /* @C3 */
                                                              /* @C3 */
ADDRESS ISPEXEC                                               /* @C3 */
  "FTOPEN"                                                    /* @C3 */
  "FTINCL "TMPSKELT                                           /* @C3 */
  IF (RACFSMBR = "") THEN                                     /* @C3 */
     "FTCLOSE"                                                /* @C3 */
  ELSE                                                        /* @C3 */
     "FTCLOSE NAME("RACFSMBR")"                               /* @C3 */
  ADDRESS TSO "FREE FI(ISPFILE)"                              /* @C3 */
                                                              /* @C3 */
  SELECT                                                      /* @C3 */
     WHEN (SETGDISP = "VIEW") THEN                            /* @C3 */
          "VIEW DATASET('"RACFSDSN"') MACRO("EDITMACR")"      /* @C3 */
     WHEN (SETGDISP = "EDIT") THEN                            /* @C3 */
          "EDIT DATASET('"RACFSDSN"') MACRO("EDITMACR")"      /* @C3 */
     OTHERWISE                                                /* @C3 */
          "BROWSE DATASET('"RACFSDSN"')"                      /* @C3 */
  END                                                         /* @C3 */
  X = MSG("ON")                                               /* @C3 */
                                                              /* @C3 */
RETURN                                                        /* @C3 */
