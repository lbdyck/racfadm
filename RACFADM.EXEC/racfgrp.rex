/*%NOCOMMENT====================* REXX *==============================*/
/*  PURPOSE:  RACFADM - Group Profiles - Menu option 2                */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @D2  2200318 LBD      Clean up open tables                         */
/* @CZ  201201  RACFA    Unhide line command 'X' for ADMIN users      */
/* @CY  201130  TRIDJK   Added hidden line command 'X'                */
/* @CV  200708  TRIDJK   Msg if selection list has no entries ('NONE')*/
/* @CU  200618  RACFA    Chged SYSDA to SYSALLDA                      */
/* @CT  200617  RACFA    Added comments to right of variables         */
/* @CS  200616  RACFA    Fix OWNER, was including CREATED date        */
/* @CR  200616  RACFA    Added capability to SAve file as TXT/CSV     */
/* @CQ  200610  RACFA    Added primary command 'SAVE'                 */
/* @CP  200608  RACFA    Fix, F3 (END) out of search panel            */
/* @CO  200604  RACFA    Fix, prevent from going to top of table      */
/* @CN  200527  RACFA    Fix, allow typing 'S' on multiple rows       */
/* @CM  200520  RACFA    Display line cmd 'P'rofile, when 'Admin=N'   */
/* @CL  200506  RACFA    Drop array immediately when done using       */
/* @CK  200504  TRIDJK   Adding, place in order, prior was at bottom  */
/* @CJ  200502  RACFA    Re-worked displaying tables, use DO FOREVER  */
/* @CI  200501  RACFA    Fixed F3 (END) out of panel RACFGRP8         */
/* @CH  200501  LBD      Add primary commands FIND/RFIND              */
/* @CG  200430  RACFA    Chg tblb to TABLEB, moved def. var. up top   */
/* @CF  200430  RACFA    Chg tbla to TABLEA, moved def. var. up top   */
/* @CE  200429  RACFA    Re-arranged variables (General, Mgmt, TSO)   */
/* @CD  200424  RACFA    Updated RESET, pass filter, ex: R filter     */
/* @CA  200424  RACFA    Chg msg RACF013 to RACF012                   */
/* @C9  200424  RACFA    Move DDNAME at top, standardize/del dups     */
/* @C8  200423  RACFA    Move PARSE REXXPGM name up above IF SETMTRAC */
/* @C7  200423  RACFA    'Status Interval' by percentage (SETGSTAP)   */
/* @C6  200423  TRIDJK   Change ACC to '', when no rows               */
/* @C5  200422  RACFA    Ensure the REXX program name is 8 chars      */
/* @C4  200422  RACFA    Use variable REXXPGM in log msg              */
/* @C3  200417  RACFA    Changed date to 'U'SA, was 'O'rdered         */
/* @C2  200417  TRIDJK   Added 'Created' date                         */
/* @C1  200413  RACFA    Chg TRACEing to only display banner (P=Pgms) */
/* @BZ  200412  RACFA    Chg TRACE to allow 'L'abels or 'R'esults     */
/* @BY  200410  RACFA    Do not display 'Segment' or 'Command'        */
/* @BX  200410  RACFA    If id = 'None' only allow line cmd 'A'dd     */
/* @BW  200407  RACFA    EXCMD removed 'else msg_var = 1 to msg.0'    */
/* @BV  200406  RACFA    Remove spaces between sub-groups             */
/* @BU  200406  RACFA    Added 'NONE' to subgroups when NO SUBGROUPS  */
/* @BT  200406  TRIDJK   Added subgroups to RACFGRP5 panel            */
/* @BS  200404  RACFA    'Admin RACF API = Y' then display 'P'rofile  */
/* @BR  200402  RACFA    Chg LRECL=132 to LRECL=80                    */
/* @BQ  200401  RACFA    Create subroutine to VIEW/EDIT/BROWSE        */
/* @BP  200401  RACFA    Chged edit macro RACFLOGE to RACFEMAC        */
/* @BO  200401  RACFA    VIEW/EDIT use edit macro, to turn off HILITE */
/* @BN  200331  RACFA    Fix SORT order, ex line cmd and no TURQ      */
/* @BM  200330  RACFA    Chg RACFGRP5 point/shoot ascending/descending*/
/* @BL  200330  RACFA    Allow point-n-shoot sort ascending/descending*/
/* @BK  200324  RACFA    Allow both display/logging of RACF commands  */
/* @BJ  200324  RACFA    Allow logging RACF commands to ISPF Log file */
/* @BI  200315  RACFA    Added line cmd 'P' for RACFGRP5 panel        */
/* @BH  200315  RACFA    Placed 'P-Prof' next to other list commands  */
/* @BG  200315  RACFA    Renamed RACFGRPP to RACFPROF, in 2nd SELECT  */
/* @BF  200315  RACFA    Renamed RACFGRPP to RACFPROF                 */
/* @BE  200313  RACFA    Del XPROF subroutine, call RACFGRPP directly */
/* @BD  200313  RACFA    Renamed RACFGHPS to RACFGRPP (P-Profile)     */
/* @BC  200313  TRIDJK   Add Supgrp and Owner to group list           */
/* @BB  200303  RACFA    Del 'ret_code = rc', not referenced          */
/* @BA  200303  RACFA    Chg 'RL class ALL' to 'RL class * ALL'       */
/* @B9  200302  RACFA    Chk RC 'LU id prms', if RC>0 then 'LU id'    */
/* @B8  200303  RACFA    Fixed chking RC after executing command      */
/* @B7  200302  RACFA    Chk RC 'LG grp prms', if RC>0 then 'LG grp'  */
/* @B6  200302  RACFA    Del TBTOP cmd, prior to TBSCAN for LOCATE    */
/* @B5  200301  RACFA    Del EMSG procedure, instead call RACFMSGS    */
/* @B4  200228  RACFA    Do not display User=No, Access=Command       */
/* @B3  200228  RACFA    Check for 'NO ENTRIES MEET SEARCH CRITERIA'  */
/* @B2  200226  RACFA    Fix @AZ chg, chg ret_code to cmd_rc          */
/* @B1  200226  RACFA    Added 'CONTROL ERRORS RETURN'                */
/* @AZ  200226  RACFA    Added 'Return Code =' when displaying cmd    */
/* @AY  200226  RACFA    Removed double quotes before/after cmd       */
/* @AX  200224  RACFA    Standardize quotes, chg single to double     */
/* @AW  200224  RACFA    Place panels at top of REXX in variables     */
/* @AV  200223  RACFA    Del 'address TSO "PROFILE MSGID"', not needed*/
/* @AU  200223  RACFA    Simplified SORT, removed FLD/DFL_SORT vars   */
/* @AT  200222  RACFA    Allowing abbreviating the column in SORT cmd */
/* @AS  200222  RACFA    Removed translating OPTA/B, not needed       */
/* @AR  200222  RACFA    Allow placing cursor on row and press ENTER  */
/* @AQ  200221  RACFA    Removed "G = '(G)'", not referenced          */
/* @AP  200221  LBD      Add ONLY primary command                     */
/* @AO  200221  RACFA    Make 'ADDRESS ISPEXEC' defualt, reduce code  */
/* @AN  200220  RACFA    Fixed displaying all RACF commands           */
/* @AM  200220  RACFA    Added SETMTRAC=YES, then TRACE R             */
/* @AL  200220  RACFA    Removed initializing SETGSTA variable        */
/* @AK  200220  RACFA    Added capability to browse/edit/view file    */
/* @AJ  200218  RACFA    Use dynamic area to display SELECT commands  */
/* @AI  200218  RACFA    Added 'Status Interval' option               */
/* @AH  200216  RACFA    Chg color to turq/green, was white/turq      */
/* @AG  200207  RACFA    Fix color of sort col, when F3, diff. id     */
/* @AF  200207  RACFA    Fix SORT, place at top of table              */
/* @AE  200207  RACFA    Fix RESET, was not placing at top of table   */
/* @AD  200207  RACFA    Fix LOCATE, not working when sort descending */
/* @AC  200206  TRIDJK   Allow A/D in SORT command                    */
/* @AB  200123  RACFA    Retrieve default filter, Option 0 - Settings */
/* @AA  200122  RACFA    Del TBTOP placed in by change @A3            */
/* @A9  200122  TRIDJK   Test/del MFA option from 'LU userid' command */
/* @A8  200120  RACFA    Removed 'say msg.msg_var' in EXCMD procedure */
/* @A7  200119  RACFA    Standardized/reduced lines of code           */
/* @A6  200119  RACFA    Added comment box above procedures           */
/* @A5  200118  RACFA    Added line command 'L', list userid          */
/* @A4  200116  RACFA    Changed colors, White/Turq, was Turq/Blue    */
/* @A3  200115  RACFA    Add SORT/LOCATE/RESET commands               */
/* @A2  200113  RACFA    Add alloc/exec/free, instead of RACFLIST     */
/* @A1  200110  RACFA    Invoke RACFLIST when displaying a userid     */
/* @A0  011229  NICORIZ  Created REXX, V2.1, www.rizzuto.it           */
/*====================================================================*/
PANEL01     = "RACFGRP1"   /* Set filter, menu option 2    */ /* @AW */
PANEL02     = "RACFGRP2"   /* Add group                    */ /* @AW */
PANEL04     = "RACFGRP4"   /* Alter profile                */ /* @AW */
PANEL05     = "RACFGRP5"   /* List userids and access      */ /* @AW */
PANEL06     = "RACFGRP6"   /* Change connection            */ /* @AW */
PANEL07     = "RACFGRP7"   /* Add connection               */ /* @AW */
PANEL08     = "RACFGRP8"   /* List groups and descriptions */ /* @AW */
PANELM1     = "RACFMSG1"   /* Confirm Request (pop-up)     */ /* @AW */
PANELM2     = "RACFMSG2"   /* Display RACF command and RC  */ /* @AW */
PANELS1     = "RACFSAVE"   /* Obtain DSName to SAVE        */ /* @CQ */
SKELETON1   = "RACFGRP8"   /* Save tablea to dataset       */ /* @CQ */
SKELETON2   = "RACFGRP5"   /* Save tableb to dataset       */ /* @CQ */
EDITMACR    = "RACFEMAC"   /* Edit Macro, turn HILITE off  */ /* @BO */
TABLEA      = 'TA'RANDOM(0,99999)  /* Unique table name A  */ /* @CF */
TABLEB      = 'TB'RANDOM(0,99999)  /* Unique table name B  */ /* @CG */
DDNAME      = 'RACFA'RANDOM(0,999) /* Unique ddname        */ /* @C9 */
parse source . . REXXPGM .         /* Obtain REXX pgm name */ /* @C8 */
REXXPGM     = LEFT(REXXPGM,8)                                 /* @C8 */
NULL        = ''                                              /* @CH */

ADDRESS ISPEXEC                                               /* @AO */
  Rclass = 'GROUP'
  Arg Rfilter
  If (Rfilter = '') Then Do                                   /* @AB */
     "VGET (SETGFLTR) PROFILE"                                /* @AB */
     Rfilter = SETGFLTR                                       /* @AB */
  end                                                         /* @AB */

  "CONTROL ERRORS RETURN"                                     /* @B1 */
  "VGET (SETGSTA  SETGSTAP SETGDISP SETMADMN",                /* @CE */
        "SETMIRRX SETMSHOW SETMTRAC) PROFILE"                 /* @CE */

  If (SETMTRAC <> 'NO') then do                               /* @BZ */
     Say "*"COPIES("-",70)"*"                                 /* @BZ */
     Say "*"Center("Begin Program = "REXXPGM,70)"*"           /* @BZ */
     Say "*"COPIES("-",70)"*"                                 /* @BZ */
     if (SETMTRAC <> 'PROGRAMS') THEN                         /* @C1 */
        interpret "Trace "SUBSTR(SETMTRAC,1,1)                /* @BZ */
  end

  If (SETMADMN = "YES") then                                  /* @B2 */
     If (SETMIRRX = "YES") then                               /* @BS */
        SELCMDS = "ÝS¨Show,ÝL¨List,ÝP¨Profile,"||,            /* @BH */
                  "ÝC¨Change,ÝA¨Add,"||,                      /* @BH */
                  "ÝR¨Remove,ÝX¨Xref"                         /* @CZ */
     Else                                                     /* @BS */
        SELCMDS = "ÝS¨Show,ÝL¨List,"||,                       /* @BS */
                  "ÝC¨Change,ÝA¨Add,"||,                      /* @BS */
                  "ÝR¨Remove,ÝX¨Xref"                         /* @CZ */
  else do                                                     /* @CM */
     If (SETMIRRX = "YES") then                               /* @CM */
        SELCMDS = "ÝS¨Show,ÝL¨list,ÝP¨Profile"                /* @CM */
     else                                                     /* @CM */
        SELCMDS = "ÝS¨Show,ÝL¨list"                           /* @AJ */
  end                                                         /* @CM */

  rlv    = SYSVAR('SYSLRACF')
  called = SYSVAR('SYSNEST')
  If (called = 'YES') then "CONTROL NONDISPL ENTER"

  "DISPLAY PANEL("PANEL01")" /* get profile filter */         /* @AW */
  Do while (rc < 8)                                           /* @CI */
     call Profl
     If (called <> 'YES') then
        "DISPLAY PANEL("PANEL01")"                            /* @AW */
  end

  If (SETMTRAC <> 'NO') then do                               /* @BZ */
     Say "*"COPIES("-",70)"*"                                 /* @BZ */
     Say "*"Center("End Program = "REXXPGM,70)"*"             /* @BZ */
     Say "*"COPIES("-",70)"*"                                 /* @BZ */
  end                                                         /* @BZ */
EXIT
/*--------------------------------------------------------------------*/
/*  Show all profiles for a filter                                    */
/*--------------------------------------------------------------------*/
PROFL:
  call CREATE_TABLEA                                          /* @AP */
  if (group = 'INVALID') | (group = 'NONE') then do           /* @CV */
     "TBEND" tablea                                           /* @D2 */
     call racfmsgs 'ERR16'                                    /* @C5 */
     rc=8                                                     /* @CV */
     return
  end
  opta   = ' '                                                /* @CJ */
  xtdtop = 0                                                  /* @CJ */
  rsels  = 0                                                  /* @CJ */
  do forever                                                  /* @CJ */
     if (rsels < 2) then do                                   /* @CJ */
        "TBTOP  " TABLEA                                      /* @CJ */
        'tbskip' tablea 'number('xtdtop')'                    /* @CJ */
        radmrfnd = 'PASSTHRU'                                 /* @CJ */
        'vput (radmrfnd)'                                     /* @CJ */
        "TBDISPL" TABLEA "PANEL("PANEL08")"                   /* @CJ */
     end                                                      /* @CJ */
     else 'tbdispl' tablea                                    /* @CJ */
     if (rc > 4) then leave                                   /* @CP */
     xtdtop   = ztdtop                                        /* @CJ */
     rsels    = ztdsels                                       /* @CJ */
     radmrfnd = null                                          /* @CJ */
     'vput (radmrfnd)'                                        /* @CJ */
     PARSE VAR ZCMD ZCMD PARM SEQ                             /* @CJ */
     IF (SROW <> "") & (SROW <> 0) THEN                       /* @AR */
        IF (SROW > 0) THEN DO                                 /* @AR */
           "TBTOP " TABLEA                                    /* @AR */
           "TBSKIP" TABLEA "NUMBER("SROW")"                   /* @AR */
        END                                                   /* @AR */
     if (zcmd = 'RFIND') then do                              /* @CH */
        zcmd = 'FIND'                                         /* @CH */
        parm = findit                                         /* @CH */
        'tbtop ' TABLEA                                       /* @CH */
        'tbskip' TABLEA 'number('last_find')'                 /* @CH */
     end                                                      /* @CH */
     Select
        When (abbrev("FIND",zcmd,1) = 1) then                 /* @CH */
             call do_finda                                    /* @CH */
        WHEN (ABBREV("LOCATE",ZCMD,1) = 1) THEN do            /* @CJ */
             if (parm <> '') then do                          /* @CJ */
                locarg = parm'*'                              /* @CJ */
                PARSE VAR SORT . "," . "," SEQ                /* @CJ */
                IF (SEQ = "D") THEN                           /* @CJ */
                   CONDLIST = "LE"                            /* @CJ */
                ELSE                                          /* @CJ */
                   CONDLIST = "GE"                            /* @CJ */
                parse value sort with scan_field',' .         /* @CJ */
                interpret scan_field ' = locarg'              /* @CJ */
                'tbtop ' tablea                               /* @CJ */
                "TBSCAN "TABLEA" ARGLIST("scan_field")",      /* @CJ */
                        "CONDLIST("CONDLIST")",               /* @CJ */
                        "position(scanrow)"                   /* @CJ */
                xtdtop = scanrow                              /* @CJ */
             end                                              /* @CJ */
        end
        WHEN (ABBREV("ONLY",ZCMD,1) = 1) THEN DO              /* @AP */
             find_str = translate(parm)                       /* @AP */
             'tbtop ' TABLEA                                  /* @AP */
             'tbskip' TABLEA                                  /* @AP */
             do forever                                       /* @AP */
                str = translate(group supgrp owner data)      /* @BC */
                if (pos(find_str,str) > 0) then nop           /* @AP */
                else 'tbdelete' TABLEA                        /* @AP */
                'tbskip' TABLEA                               /* @AP */
                if (rc > 0) then do                           /* @AP */
                   'tbtop' TABLEA                             /* @AP */
                   leave                                      /* @AP */
                end                                           /* @AP */
             end                                              /* @AP */
        END                                                   /* @AP */
        WHEN (ABBREV("RESET",ZCMD,1) = 1) THEN DO             /* @AE */
             if (parm <> '') then                             /* @CD */
                rfilter = parm                                /* @CD */
             xtdtop   = 1                                     /* @AE */
             "TBEND" TABLEA                                   /* @BL */
             call CREATE_TABLEA                               /* @AP */
        END                                                   /* @AE */
        When (abbrev("SAVE",zcmd,2) = 1) then DO              /* @CQ */
             TMPSKELT = SKELETON1                             /* @CQ */
             call do_SAVE                                     /* @CQ */
        END                                                   /* @CQ */
        WHEN (ABBREV("SORT",ZCMD,1) = 1) THEN DO              /* @AF */
             SELECT                                           /* @A3 */
                when (ABBREV("GROUP",PARM,1) = 1) then        /* @AT */
                     call sortseq 'GROUP'                     /* @BL */
                when (ABBREV("SUPGRP",PARM,1) = 1) then       /* @BC */
                     call sortseq 'SUPGRP'                    /* @BL */
                when (ABBREV("OWNER",PARM,1) = 1) then        /* @BC */
                     call sortseq 'OWNER'                     /* @BL */
                when (ABBREV("DESCRIPTION",PARM,1) = 1) then  /* @AT */
                     call sortseq 'DATA'                      /* @BL */
                otherwise NOP                                 /* @A3 */
             END                                              /* @A3 */
             PARSE VAR SORT LOCARG "," .                      /* @CJ */
             CLRGROU = "GREEN"; CLRDATA = "GREEN"             /* @CJ */
             CLRSUPG = "GREEN"; CLROWNE = "GREEN"             /* @CJ */
             INTERPRET "CLR"SUBSTR(LOCARG,1,4)" = 'TURQ'"     /* @CJ */
             "TBSORT" TABLEA "FIELDS("sort")"                 /* @CJ */
             "TBTOP " TABLEA                                  /* @CJ */
        END                                                   /* @AF */
        otherwise NOP
     End  /* Select */
     ZCMD = ""; PARM = ""                                     /* @CJ */
     'control display save'                                   /* @CJ */
     Select
        when (opta = 'A') then call Addd
        when (opta = 'C') then call Chgd
        when (opta = 'L') then call Lisd
        when (opta = 'X') then Call RACFUSRX group JCC        /* @CY */
        when (opta = 'P') then                                /* @BE */
             call RACFPROF 'GROUP' group                      /* @BF */
        when (opta = 'R') then call Deld
        when (opta = 'S') then call Disd
        otherwise nop
     End /* Select */
     'control display restore'                                /* @CJ */
  end  /* Do forever) */                                      /* @CJ */
  src = rc                                                    /* @D2 */
  'tbclose' tablea                                            /* @D2 */
  rc = src                                                    /* @D2 */
RETURN
/*--------------------------------------------------------------------*/
/*  Process primary command FIND for TABLEA                      @CH  */
/*--------------------------------------------------------------------*/
DO_FINDA:                                                     /* @CH */
  if (parm = null) then do                                    /* @CH */
     racfsmsg = 'Error'                                       /* @CH */
     racflmsg = 'Find requires a value to search for.' ,      /* @CH */
                'Try again.'                                  /* @CH */
     'setmsg msg(RACF011)'                                    /* @CH */
     return                                                   /* @CH */
  end                                                         /* @CH */
  findit    = translate(parm)                                 /* @CH */
  last_find = 0                                               /* @CH */
  wrap      = 0                                               /* @CH */
  do forever                                                  /* @CH */
     'tbskip' TABLEA                                          /* @CH */
     if (rc > 0) then do                                      /* @CH */
        if (wrap = 1) then do                                 /* @CH */
           racfsmsg = 'Not Found'                             /* @CH */
           racflmsg = findit 'not found.'                     /* @CH */
           'setmsg msg(RACF011)'                              /* @CH */
           return                                             /* @CH */
        end                                                   /* @CH */
        if (wrap = 0) then wrap = 1                           /* @CH */
        'tbtop' TABLEA                                        /* @CH */
     end                                                      /* @CH */
     else do                                                  /* @CH */
        testit = translate(group supgrp owner data)           /* @CH */
        if (pos(findit,testit) > 0) then do                   /* @CH */
           'tbquery' TABLEA 'position(srow)'                  /* @CH */
           'tbtop'   TABLEA                                   /* @CH */
           'tbskip'  TABLEA 'number('srow')'                  /* @CH */
           last_find = srow                                   /* @CH */
           xtdtop    = srow                                   /* @CH */
           if (wrap = 0) then                                 /* @CH */
              racfsmsg = 'Found'                              /* @CH */
           else                                               /* @CH */
              racfsmsg = 'Found/Wrapped'                      /* @CH */
           racflmsg = findit 'found in row' srow + 0          /* @CH */
           'setmsg msg(RACF011)'                              /* @CH */
           return                                             /* @CH */
        end                                                   /* @CH */
     end                                                      /* @CH */
  end                                                         /* @CH */
RETURN                                                        /* @CH */
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
  new = 'NO'
  if (group = 'NONE') then
     new ='YES'
  else
     CALL Getd
  "DISPLAY PANEL("PANEL02")"                                  /* @AW */
  if (rc > 0) then
     return
  xtr = ' '
  if (data <> ' ') then
     xtr = xtr "DATA('"data"')"
  call EXCMD "AG ("group") OWNER("owner")",
             "SUPGROUP("supgrp")" xtr
  if (cmd_rc > 0) then do                                     /* @BA */
     CALL racfmsgs 'ERR01' /* Add failed */                   /* @B5 */
     return
  end
  "TBMOD" TABLEA "ORDER"                                      /* @CK */
  if (new = 'YES') then do
     group = 'NONE'
     "TBDELETE"  TABLEA
  end
RETURN
/*--------------------------------------------------------------------*/
/*  Add new profile                                                   */
/*--------------------------------------------------------------------*/
CHGD:
  if (group = 'NONE') then
     return
  CALL Getd
  "DISPLAY PANEL("PANEL04")"                                  /* @AW */
  if (rc > 0) then return
  xtr = ' '
  if (data <> ' ') then do
     if data = 'NONE' then
        data = ' '
     xtr = xtr "DATA('"DATA"')"
  end
  call EXCMD "ALG ("group") OWNER("OWNER")",
             "SUPGROUP("SUPGRP")" xtr
  if (cmd_rc > 0) then                                        /* @BA */
     call racfmsgs 'ERR07' /* Altgroup failed */              /* @B5 */
  else
     "TBMOD" TABLEA
RETURN
/*--------------------------------------------------------------------*/
/*  Delete profile                                                    */
/*--------------------------------------------------------------------*/
DELD:
  if (group = 'NONE') then
     return
  msg    = 'You are about to delete 'group
  Sure_? = Confirm_delete(msg)
  if (sure_? = 'YES') then do
     call EXCMD "DG ("group")"
     if (cmd_rc = 0) then                                     /* @BA */
        "TBDELETE" TABLEA
     else
       CALL racfmsgs "ERR02" /* RDELETE failed */             /* @B5 */
  end
RETURN
/*--------------------------------------------------------------------*/
/*  Display profile permits                                           */
/*--------------------------------------------------------------------*/
DISD:
  if (group = 'NONE') then
     return
  tmpsort   = sort                                            /* @BM */
  tmprsels  = rsels                                           /* @CN */
  tmpxtdtop = xtdtop                                          /* @CO */
  Do until (RB = 'NO')   /* allow rebuild option to loop */
     call create_TABLEB                                       /* @BM */
     rb   = 'NO'
     drop rownum
     "TBQUERY" TABLEB "ROWNUM("rownum")"
     if (rownum = 0) then do
        id  = 'NONE'
        acc = ''                                              /* @C6 */
        "TBMOD" TABLEB
     end
     xtdtop = 0                                               /* @CJ */
     rsels  = 0                                               /* @CJ */
     do forever                                               /* @CJ */
        if (rsels < 2) then do                                /* @CJ */
           optb = ' '                                         /* @CJ */
           "TBTOP " TABLEB                                    /* @CJ */
           'tbskip' tableb 'number('xtdtop')'                 /* @CJ */
           radmrfnd = 'PASSTHRU'                              /* @CJ */
           'vput (radmrfnd)'                                  /* @CJ */
           "TBDISPL" TABLEB "PANEL("PANEL05")"                /* @CJ */
        end                                                   /* @CJ */
        else 'tbdispl' tableb                                 /* @CJ */
        if (rc > 4) then leave                                /* @CJ */
        xtdtop   = ztdtop                                     /* @CJ */
        rsels    = ztdsels                                    /* @CJ */
        radmrfnd = null                                       /* @CJ */
        'vput (radmrfnd)'                                     /* @CJ */
        PARSE VAR ZCMD ZCMD PARM SEQ                          /* @CJ */
        IF (SROW <> "") & (SROW <> 0) THEN                    /* @AR */
           IF (SROW > 0) THEN DO                              /* @AR */
              "TBTOP " TABLEB                                 /* @AR */
              "TBSKIP" TABLEB "NUMBER("SROW")"                /* @AR */
           END                                                /* @AR */
        if (zcmd = 'RFIND') then do                           /* @CH */
           zcmd = 'FIND'                                      /* @CH */
           parm = findit                                      /* @CH */
           'tbtop ' TABLEB                                    /* @CH */
           'tbskip' TABLEB 'number('last_find')'              /* @CH */
        end                                                   /* @CH */
        Select                                                /* @BM */
           When (abbrev("FIND",zcmd,1) = 1) then              /* @CH */
                call do_findb                                 /* @CH */
           WHEN (ABBREV("LOCATE",ZCMD,1) = 1) THEN DO         /* @CJ */
                if (parm <> '') then do                       /* @CJ */
                   locarg = parm'*'                           /* @CJ */
                   PARSE VAR SORT . "," . "," SEQ             /* @CJ */
                   IF (SEQ = "D") THEN                        /* @CJ */
                      CONDLIST = "LE"                         /* @CJ */
                   ELSE                                       /* @CJ */
                      CONDLIST = "GE"                         /* @CJ */
                   parse value sort with scan_field',' .      /* @CJ */
                   interpret scan_field ' = locarg'           /* @CJ */
                   'tbtop ' tableb                            /* @CJ */
                   "TBSCAN "TABLEB" ARGLIST("scan_field")",   /* @CJ */
                           "CONDLIST("CONDLIST")",            /* @CJ */
                           "position(scanrow)"                /* @CJ */
                   xtdtop = scanrow                           /* @CJ */
                end                                           /* @CJ */
           END                                                /* @CJ */
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
                sort     = 'ID,C,A'                           /* @BM */
                sortid   = 'D'; sortacc = 'A'                 /* @BM */
                xtdtop   = 1                                  /* @BM */
                "TBEND" TABLEB                                /* @BM */
                call create_TABLEB                            /* @BM */
           END                                                /* @BM */
           When (abbrev("SAVE",zcmd,2) = 1) then DO           /* @CQ */
                TMPSKELT = SKELETON2                          /* @CQ */
                call do_SAVE                                  /* @CQ */
           END                                                /* @CQ */
           WHEN (ABBREV("SORT",ZCMD,1) = 1) THEN DO           /* @BM */
                SELECT                                        /* @BM */
                   when (ABBREV("USERID",PARM,1) = 1) then    /* @BM */
                        call sortseq 'ID'                     /* @BM */
                   when (ABBREV("ACCESS",PARM,1) = 1) then    /* @BM */
                        call sortseq 'ACC'                    /* @BM */
                   otherwise NOP                              /* @BM */
                END                                           /* @BM */
                PARSE VAR SORT LOCARG "," .                   /* @CJ */
                CLRID = "GREEN"; CLRACC = "GREEN"             /* @CJ */
                INTERPRET "CLR"SUBSTR(LOCARG,1,4)" = 'TURQ'"  /* @CJ */
                "TBSORT" TABLEB "FIELDS("sort")"              /* @CJ */
                "TBTOP " TABLEB                               /* @CJ */
           END                                                /* @BM */
           otherwise NOP                                      /* @BM */
        End  /* Select */                                     /* @BM */
        ZCMD = ""; PARM = ""                                  /* @CJ */
        'control display save'                                /* @CJ */
        if (optb <> 'A') & (id = 'NONE') then                 /* @BX */
           Call RACFMSGS ERR21                                /* @BX */
        else do                                               /* @BX */
           Select
              when (optb = 'A')  then call Addp
              when (optb = 'C')  then call Chgp
              when (optb = 'L')  then call Lisp               /* @A5 */
              when (optb = 'P') then                          /* @BI */
                   call RACFPROF 'USER' id                    /* @BI */
              when (optb = 'R')  then call Delp
              when (optb = 'S')  then call RACFUSR id
              when (optb = 'SE') then call RACFCLSS id
              when (optb = 'X') then Call RACFUSRX id JCC     /* @CY */
              otherwise nop
           End
        end
        'control display restore'                             /* @CJ */
     end  /* Do forever) */                                   /* @CJ */
     "TBEND" TABLEB
  end /* Do until */
  sort   = tmpsort                                            /* @BM */
  rsels  = tmprsels                                           /* @CN */
  xtdtop = tmpxtdtop                                          /* @CO */
RETURN
/*--------------------------------------------------------------------*/
/*  Process primary command FIND for TABLEB                      @CH  */
/*--------------------------------------------------------------------*/
DO_FINDB:                                                     /* @CH */
  if (parm = null) then do                                    /* @CH */
     racfsmsg = 'Error'                                       /* @CH */
     racflmsg = 'Find requires a value to search for.' ,      /* @CH */
                'Try again.'                                  /* @CH */
     'setmsg msg(RACF011)'                                    /* @CH */
     return                                                   /* @CH */
  end                                                         /* @CH */
  findit    = translate(parm)                                 /* @CH */
  last_find = 0                                               /* @CH */
  wrap      = 0                                               /* @CH */
  do forever                                                  /* @CH */
     'tbskip' TABLEB                                          /* @CH */
     if (rc > 0) then do                                      /* @CH */
        if (wrap = 1) then do                                 /* @CH */
           racfsmsg = 'Not Found'                             /* @CH */
           racflmsg = findit 'not found.'                     /* @CH */
           'setmsg msg(RACF011)'                              /* @CH */
           return                                             /* @CH */
        end                                                   /* @CH */
        if (wrap = 0) then wrap = 1                           /* @CH */
        'tbtop' TABLEB                                        /* @CH */
     end                                                      /* @CH */
     else do                                                  /* @CH */
        testit = translate(id acc)                            /* @CH */
        if (pos(findit,testit) > 0) then do                   /* @CH */
           'tbquery' TABLEB 'position(srow)'                  /* @CH */
           'tbtop'   TABLEB                                   /* @CH */
           'tbskip'  TABLEB 'number('srow')'                  /* @CH */
           last_find = srow                                   /* @CH */
           xtdtop    = srow                                   /* @CH */
           if (wrap = 0) then                                 /* @CH */
              racfsmsg = 'Found'                              /* @CH */
           else                                               /* @CH */
              racfsmsg = 'Found/Wrapped'                      /* @CH */
           racflmsg = findit 'found in row' srow + 0          /* @CH */
           'setmsg msg(RACF011)'                              /* @CH */
           return                                             /* @CH */
        end                                                   /* @CH */
     end                                                      /* @CH */
  end                                                         /* @CH */
RETURN                                                        /* @CH */
/*--------------------------------------------------------------------*/
/*  Create table 'B'                                             @BM  */
/*--------------------------------------------------------------------*/
CREATE_TABLEB:                                                /* @BM */
  "TBCREATE" TABLEB "KEYS(ID) NAMES(ACC)",
                  "REPLACE NOWRITE"
  flags  = 'OFF'
  audit  = ' '
  owner  = ' '
  subgrp = 'NONE'                                             /* @BU */
  uacc   = ' '
  data   = ' '
  cmd    = "LG "group                                         /* @AN */
  x = OUTTRAP('VAR.')
  address TSO cmd                                             /* @AN */
  cmd_rc = rc                                                 /* @AZ */
  x = OUTTRAP('OFF')
  if (SETMSHOW <> 'NO') then                                  /* @BJ */
     call SHOWCMD                                             /* @AN */
  Do i = 1 to var.0          /* Scan output */
     temp = var.i
     if (rlv > '1081') then  /* RACF 1.9 add blank */
        temp = ' 'temp
     l = LENGTH(temp)
     if (uacc = ' ') then
        if (substr(temp,6,14) = 'SUPERIOR GROUP') then do
           temp    = var.i
           uacc    = substr(temp,20,8)
           supgrp  = substr(temp,20,8)
           owner   = substr(temp,39,8)
           datecre = substr(temp,59,6)                        /* @C2 */
           datecre = SUBSTR(datecre,1,2)SUBSTR(datecre,4,3)   /* @C2 */
           datecre = DATE('U',datecre,'J')                    /* @C3 */
        end
     if (data = ' ') then
        if (substr(temp,6,17) = 'INSTALLATION DATA') then do
           temp = var.i
           data =  substr(temp,23,45)
           i    = i + 1
           temp = var.i
           if (substr(temp,5,8) <> 'NO MODEL') &,
              (substr(temp,5,5) <> 'MODEL') then
              data = data || strip(substr(temp,23,45),'t')
         end
     if (subgrp = 'NONE') then                                /* @BU */
        if (subword(temp,1,1) = 'SUBGROUP(S)=') then do       /* @BT */
           temp = var.i                                       /* @BT */
           subgrp = substr(temp,18,54)                        /* @BT */
           i    = i + 1                                       /* @BT */
           temp = var.i                                       /* @BT */
           do while substr(temp,1,17) = ' '                   /* @BT */
              subgrp = subgrp""substr(temp,18,54)             /* @BT */
              i    = i + 1                                    /* @BT */
              temp = var.i                                    /* @BT */
           end                                                /* @BT */
           tmpsubgrp = subgrp                                 /* @BV */
           subgrp    = word(tmpsubgrp,1)                      /* @BV */
           do JJ = 2 TO WORDS(tmpsubgrp)                      /* @BV */
              subgrp = subgrp" "WORD(tmpsubgrp,JJ)            /* @BV */
           end                                                /* @BV */
        end                                                   /* @BT */
     if (flags = 'ON') then do
        if (l = 1) | (l = 2) then
           flags = 'OUT'     /* end access list */
        if (l > 8) then
           if (substr(temp,1,60) = ' ') then
              flags = 'OUT'  /* end access list */
     end
     if (flags = 'ON') then do
        if (substr(temp,2,10) = 'No Command') then iterate    /* @B4 */
        if (substr(temp,2,10) = 'Command Au') then iterate    /* @BY */
        if (substr(temp,2,10) = 'Segment:  ') then iterate    /* @BY */
        if (substr(temp,2,10) = 'NO ENTRIES') then do
           id  = 'NONE'       /* empty access list */
           acc = 'DEFINED'
        end
        else do
           id  = subword(temp,1,1)
           acc = subword(temp,2,1)
        end
        if (substr(temp,8,2) <> ' ') then
           "TBMOD" TABLEB
     end
     if (subword(temp,1,1) = 'USER(S)=') then do
        flags = 'ON'   /* start access list */
     end
  end /* loop scan output */
  sort   = 'ID,C,A'                                           /* @CJ */
  sortid = 'D'; sortacce = 'A'         /* Sort order */       /* @CJ */
  CLRID  = "TURQ"; CLRACC = "GREEN"    /* COL COLORS */       /* @CJ */
  "TBSORT " TABLEB "FIELDS("sort")"                           /* @CJ */
  "TBTOP  " TABLEB                                            /* @CJ */
RETURN                                                        /* @BM */
/*--------------------------------------------------------------------*/
/*  Get LG info to initialize add or change option                    */
/*--------------------------------------------------------------------*/
GETD:
  owner  = ' '
  data   = ' '
  supgrp = ' '
  cmd    = "LG "group                                         /* @AN */
  x = OUTTRAP('details.')
  address TSO cmd                                             /* @AN */
  cmd_rc = rc                                                 /* @AZ */
  x = OUTTRAP('OFF')
  if (SETMSHOW <> 'NO') then                                  /* @BJ */
     call SHOWCMD                                             /* @AN */
  parse var details.2 'SUPERIOR GROUP=' supgrp,               /* @CS */
          'OWNER=' owner .                                    /* @CS */
  parse var details.3 'INSTALLATION DATA=' data_1st_line
  data_2nd_line = details.4
  if (subword(data_2nd_line,2,1) = 'MODEL') |,
     (subword(data_2nd_line,1,1) = 'MODEL') then
     data = data_1st_line
  else
     data = data_1st_line||strip(substr(data_2nd_line,23,45),'t')
RETURN
/*--------------------------------------------------------------------*/
/*  Change permit option                                              */
/*--------------------------------------------------------------------*/
CHGP:
  If (id = 'NONE') then
     return
  "DISPLAY PANEL("PANEL06")"                                  /* @AW */
  if (rc > 0) then
     return
  call EXCMD "CONNECT ("id") GROUP("group") AUTH("acc")"
  if (cmd_rc = 0) then                                        /* @BA */
     "TBMOD" TABLEB
  else
     Call racfmsgs 'ERR03' /* Permit failed */                /* @B5 */
RETURN
/*--------------------------------------------------------------------*/
/*  List group                                                        */
/*--------------------------------------------------------------------*/
LISD:
  CMDPRM   = "CSDATA DFP OMVS OVM TME"                        /* @A2 */
  cmd      = "LG "GROUP" "CMDPRM                              /* @AN */
  X = OUTTRAP("CMDREC.")                                      /* @A2 */
  ADDRESS TSO cmd                                             /* @AN */
  cmd_rc   = rc                                               /* @AZ */
  X = OUTTRAP("OFF")                                          /* @A2 */
  if (SETMSHOW <> 'NO') then                                  /* @BJ */
     call SHOWCMD                                             /* @AN */
  if (cmd_rc > 0) then DO    /* Remove parms */               /* @B7 */
     cmd = "LG "GROUP                                         /* @B7 */
     X = OUTTRAP("CMDREC.")                                   /* @B7 */
     ADDRESS TSO cmd                                          /* @B7 */
     cmd_rc   = rc                                            /* @B7 */
     X = OUTTRAP("OFF")                                       /* @B7 */
     if (SETMSHOW <> 'NO') then                               /* @BJ */
        call SHOWCMD                                          /* @B7 */
  END                                                         /* @B7 */
  call display_info                                           /* @BQ */
  if (cmd_rc > 0) then                                        /* @B8 */
     CALL racfmsgs "ERR10" /* Generic failure */              /* @B5 */
RETURN
/*--------------------------------------------------------------------*/
/*  Display information from line commands 'L' and 'P'           @BQ  */
/*--------------------------------------------------------------------*/
DISPLAY_INFO:                                                 /* @BQ */
  ADDRESS TSO "ALLOC F("DDNAME") NEW REUSE",                  /* @A2 */
              "LRECL(80) BLKSIZE(0) RECFM(F B)",              /* @BR */
              "UNIT(VIO) SPACE(1 5) CYLINDERS"                /* @A2 */
  ADDRESS TSO "EXECIO * DISKW "DDNAME" (STEM CMDREC. FINIS"   /* @A2 */
  DROP CMDREC.                                                /* @CL */
                                                              /* @CL */
  "LMINIT DATAID(CMDDATID) DDNAME("DDNAME")"                  /* @A2 */
  SELECT                                                      /* @AK */
     WHEN (SETGDISP = "VIEW") THEN                            /* @AK */
          "VIEW DATAID("CMDDATID") MACRO("EDITMACR")"         /* @BO */
     WHEN (SETGDISP = "EDIT") THEN                            /* @AK */
          "EDIT DATAID("CMDDATID") MACRO("EDITMACR")"         /* @BO */
     OTHERWISE                                                /* @AK */
          "BROWSE DATAID("CMDDATID")"                         /* @AK */
  END                                                         /* @AK */
  ADDRESS TSO "FREE FI("DDNAME")"                             /* @A2 */
RETURN                                                        /* @BQ */
/*--------------------------------------------------------------------*/
/*  List userid                                                       */
/*--------------------------------------------------------------------*/
LISP:
  CMDPRM  = "CICS CSDATA DCE DFP EIM KERB LANGUAGE",          /* @A5 */
            "LNOTES MFA NDS NETVIEW OMVS OPERPARM",           /* @A5 */
            "OVM PROXY TSO WORKATTR"                          /* @A5 */
  call get_setropts_options                                   /* @A9 */
  if (rcvtsmfa = 'NO') then do                                /* @A9 */
     mfa_pos = pos('MFA',CMDPRM)                              /* @A9 */
     CMDPRM = delstr(CMDPRM,mfa_pos,4)                        /* @A9 */
  end                                                         /* @A9 */
  cmd = "LU "ID CMDPRM                                        /* @AN */
  X = OUTTRAP("CMDREC.")                                      /* @A5 */
  ADDRESS TSO cmd                                             /* @AN */
  cmd_rc = rc                                                 /* @AZ */
  X = OUTTRAP("OFF")                                          /* @A5 */
  if (SETMSHOW <> 'NO') then                                  /* @BJ */
     call SHOWCMD                                             /* @AN */
  if (cmd_rc > 0) then DO    /* Remove parms */               /* @B9 */
     cmd = "LU "ID                                            /* @B9 */
     X = OUTTRAP("CMDREC.")                                   /* @B9 */
     ADDRESS TSO cmd                                          /* @B9 */
     cmd_rc = rc                                              /* @B9 */
     X = OUTTRAP("OFF")                                       /* @B9 */
     if (SETMSHOW <> 'NO') then                               /* @BJ */
        call SHOWCMD                                          /* @B9 */
  END                                                         /* @B9 */
  call display_info                                           /* @BQ */
  if (cmd_rc > 0) then                                        /* @B9 */
     CALL RACFMSGS "ERR10" /* Generic failure */              /* @B5 */
RETURN
/*--------------------------------------------------------------------*/
/*  Get Multi Factor Authentication (MFA) option from RCVT            */
/*--------------------------------------------------------------------*/
GET_SETROPTS_OPTIONS:                                         /* @A9 */
  cvt     = c2x(storage(10,4))      /* cvt address        */  /* @A9 */
  cvtrac$ = d2x((x2d(cvt))+992)     /* cvt+3E0 = cvtrac $ */  /* @A9 */
  cvtrac  = c2x(storage(cvtrac$,4)) /* cvtrac=access cntl */  /* @A9 */
  rc      = setbool(rcvtsmfa,633,'02','NO','YES') /* mfa  */  /* @A9 */
RETURN                                                        /* @A9 */
/*--------------------------------------------------------------------*/
/*  Set boolean value for mask                                        */
/*--------------------------------------------------------------------*/
SETBOOL:
  variable = arg(1)                                           /* @A9 */
  offset   = arg(2)                                           /* @A9 */
  value    = arg(3)                                           /* @A9 */
  status1  = arg(4)                                           /* @A9 */
  status2  = arg(5)                                           /* @A9 */
  interpret "rcvtsta$= d2x((x2d("cvtrac"))+"offset")"         /* @A9 */
  x        = storage(rcvtsta$,1)                              /* @A9 */
  interpret variable '= 'status1                              /* @A9 */
  interpret "x=bitand(x,'"value"'x)" /*remove bad bits*/      /* @A9 */
  interpret "if (x= '"value"'x) then "variable"="status2      /* @A9 */
RETURN 0                                                      /* @A9 */
/*--------------------------------------------------------------------*/
/*  Add permit option                                                 */
/*--------------------------------------------------------------------*/
ADDP:
  new = 'NO'
  if (id = 'NONE') then
     new = 'YES'
  from = ' '
  "DISPLAY PANEL("PANEL07")"                                  /* @AW */
  if (rc > 0) then
     return
  idopt = ' '
  if (id <> ' ') then
     idopt = 'ID('ID') ACCESS('ACC')'
  fopt = ' '
  call EXCMD "CONNECT ("id") GROUP("group") AUTH("acc")"
  if (cmd_rc = 0) then do                                     /* @BA */
     "TBMOD" TABLEB "ORDER"                                   /* @D1 */
     if (new = 'YES') then do
        id = 'NONE'
        "TBDELETE" TABLEB
     end
  end
  else do
     if (from <> ' ') then
        call racfmsgs 'ERR04' /* Permit Warning/Failed */     /* @B5 */
     else
        call racfmsgs 'ERR05' /* Permit Failed */             /* @B5 */
  end
RETURN
/*--------------------------------------------------------------------*/
/*   Delete permit option                                             */
/*--------------------------------------------------------------------*/
DELP:
  if (id = 'NONE') then
     return
  msg    = 'You are about to delete access for 'ID
  Sure_? = Confirm_delete(msg)
  if (sure_? = 'YES') then do
     call EXCMD "REMOVE "id" GROUP("group")"
     if (cmd_rc = 0) then                                     /* @BA */
        "TBDELETE" TABLEB
     else
        call racfmsgs 'ERR06' /* Permit Failed */             /* @B5 */
  end
RETURN
/*--------------------------------------------------------------------*/
/*  Confirm delete                                                    */
/*--------------------------------------------------------------------*/
CONFIRM_DELETE:
  signal off error
  arg message
  answer  = 'NO'
  zwinttl = 'CONFIRM REQUEST'
  Do until (ckey = 'PF03') | (ckey = 'ENTER')
    "CONTROL NOCMD"                                           /* @AX */
    "ADDPOP"                                                  /* @AX */
    "DISPLAY PANEL("PANELM1")"                                /* @AW */
    "REMPOP"                                                  /* @AX */
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
  address TSO cmd                                             /* @AY */
  cmd_rc = rc
  x = OUTTRAP('OFF')
  if (SETMSHOW <> 'NO') then                                  /* @BJ */
     call SHOWCMD                                             /* @AN */
  if (subword(msg.1,1,1)= 'ICH11009I') |,
     (subword(msg.1,1,1)= 'ICH10006I') |,
     (subword(msg.1,1,1)= 'ICH06011I') then raclist = 'YES'
RETURN
/*--------------------------------------------------------------------*/
/*  Display RACF command and return code                         @AN  */
/*--------------------------------------------------------------------*/
SHOWCMD:                                                      /* @AN */
  IF (SETMSHOW = "BOTH") | (SETMSHOW = "DISPLAY") THEN DO     /* @BK */
     PARSE VAR CMD MSG1 60 MSG2 121 MSG3                      /* @AN */
     MSG4 = "Return code = "cmd_rc                            /* @AN */
     "ADDPOP ROW(6) COLUMN(4)"                                /* @AZ */
     "DISPLAY PANEL("PANELM2")"                               /* @AX */
     "REMPOP"                                                 /* @AW */
  END                                                         /* @BJ */
  IF (SETMSHOW = "BOTH") | (SETMSHOW = "LOG") THEN DO         /* @BK */
     zerrsm = "RACFADM "REXXPGM" RC="cmd_rc                   /* @C4 */
     zerrlm = cmd                                             /* @BJ */
     'log msg(isrz003)'                                       /* @BJ */
  END                                                         /* @BJ */
RETURN                                                        /* @AN */
/*--------------------------------------------------------------------*/
/*  Create table 'A'                                             @AP  */
/*--------------------------------------------------------------------*/
CREATE_TABLEA:                                                /* @AP */
  seconds = TIME('S')
  "TBCREATE" TABLEA "KEYS(GROUP) NAMES(DATA SUPGRP OWNER)",   /* @BC */
           "REPLACE NOWRITE"
  cmd = "SEARCH FILTER("RFILTER") CLASS("rclass")"            /* @AN */
  x = OUTTRAP('var.')
  address TSO cmd                                             /* @AN */
  cmd_rc = rc                                                 /* @AZ */
  x = OUTTRAP('OFF')
  if (SETMSHOW <> 'NO') then                                  /* @BJ */
     call SHOWCMD                                             /* @AN */
  if (SETGSTAP <> "") THEN                                    /* @C7 */
     INTERPRET "RECNUM = var.0*."SETGSTAP"%1"                 /* @C7 */
  Do i = 1 to var.0
     temp  = var.i
     group = SUBWORD(temp,1,1)
     msgr  = SUBWORD(temp,1,1)
     Select
        when (msgr = 'ICH31005I') then
             group = 'NONE'       /* No groups  */
        when (msgr = 'ICH31009I') then do
             group = 'INVALID'    /* Bad filter */
             call racfmsgs 'ERR08'                            /* @B5 */
        end
        when (msgr = 'ICH31012I') then do
             group = 'INVALID'    /* Bad filter */
             call racfmsgs 'ERR08'                            /* @B5 */
        end
        when (msgr = 'ICH31014I') then do
             group = 'INVALID'    /* Bad filter */
             call racfmsgs 'ERR08'                            /* @B5 */
        end
        when (msgr = 'ICH31016I') then do
             group = 'INVALID'    /* Bad filter */
             call racfmsgs 'ERR08'                            /* @B5 */
        end
        when (msgr = 'ICH31017I') then do
             group = 'INVALID'    /* Bad filter */
             call racfmsgs 'ERR08'                            /* @B5 */
        end
        when (msgr = 'ICH31018I') then do
             group = 'INVALID'    /* Bad filter */
             call racfmsgs 'ERR08'                            /* @B5 */
        end
        when (msgr = 'IKJ56716I') then do
             group = 'INVALID'    /* Bad filter */
             call racfmsgs 'ERR08'                            /* @B5 */
        end
        when (substr(msgr,1,6) = 'ICH310') then
             call racfmsgs 'ERR09'                            /* @B5 */
        otherwise nop
     End  /* Select */
     /*---------------------------------------------*/
     /* Display number of records retrieved        -*/
     /*---------------------------------------------*/
     IF (SETGSTA = "") THEN DO                                /* @C7 */
        IF (RECNUM <> 0) THEN                                 /* @C7 */
           IF (I//RECNUM = 0) THEN DO                         /* @C7 */
              n1 = i; n2 = var.0                              /* @C7 */
              pct = ((n1/n2)*100)%1'%'                        /* @C7 */
              "control display lock"                          /* @C7 */
              "display msg(RACF012)"                          /* @CA */
           END                                                /* @C7 */
     END                                                      /* @C7 */
     ELSE DO                                                  /* @C7 */
        IF (SETGSTA <> 0) THEN                                /* @C7 */
           IF (I//SETGSTA = 0) THEN DO                        /* @AI */
              n1 = i; n2 = var.0
              pct = ((n1/n2)*100)%1'%'                        /* @C7 */
              "control display lock"
              "display msg(RACF012)"                          /* @CA */
           END                                                /* @AI */
     END                                                      /* @C7 */
     /* Get further information */
     Call GETD
     "TBMOD" TABLEA
  end /* Do i=1 to var.0 */
  sort     = 'GROUP,C,A'                                      /* @CJ */
  sortgrou = 'D'; sortsupg = 'A'         /* Sort order */     /* @CJ */
  sortowne = 'A'; sortdata = 'A'                              /* @CJ */
  CLRGROU  = "TURQ";  CLRDATA = "GREEN"  /* Col colors */     /* @CJ */
  CLRSUPG  = "GREEN"; CLROWNE = "GREEN"                       /* @CJ */
  "TBSORT " TABLEA "FIELDS("sort")"                           /* @CJ */
  "TBTOP  " TABLEA                                            /* @CJ */
RETURN                                                        /* @AP */
/*--------------------------------------------------------------------*/
/*  Save table to dataset                                        @CQ  */
/*--------------------------------------------------------------------*/
DO_SAVE:                                                      /* @CQ */
  X = MSG("OFF")                                              /* @CQ */
  "ADDPOP COLUMN(40)"                                         /* @CQ */
  "VGET (RACFSDSN RACFSMBR RACFSFIL RACFSREP) PROFILE"        /* @CR */
  IF (RACFSDSN = "") THEN         /* SAve - Dataset Name  */  /* @CT */
     RACFSDSN = USERID()".RACFADM.REPORTS"                    /* @EK */
  IF (RACFSFIL = "") THEN         /* SAve - As (TXT/CVS)  */  /* @CT */
     RACFSFIL = "T"                                           /* @EL */
  IF (RACFSREP = "") THEN         /* SAve - Replace (Y/N) */  /* @CT */
     RACFSREP = "N"                                           /* @EK */
                                                              /* @CQ */
  DO FOREVER                                                  /* @CQ */
     "DISPLAY PANEL("PANELS1")"                               /* @CQ */
     IF (RC = 08) THEN DO                                     /* @CQ */
        "REMPOP"                                              /* @CQ */
        RETURN                                                /* @CQ */
     END                                                      /* @CQ */
     RACFSDSN = STRIP(RACFSDSN,,"'")                          /* @CQ */
     RACFSDSN = STRIP(RACFSDSN,,'"')                          /* @CQ */
     RACFSDSN = STRIP(RACFSDSN)                               /* @CQ */
     SYSDSORG = ""                                            /* @CQ */
     X = LISTDSI("'"RACFSDSN"'")                              /* @CQ */
     IF (SYSDSORG = "") | (SYSDSORG = "PS"),                  /* @CQ */
      | (SYSDSORG = "PO") THEN                                /* @CQ */
        NOP                                                   /* @CQ */
     ELSE DO                                                  /* @CQ */
        RACFSMSG = "Not PDS/Seq File"                         /* @CQ */
        RACFLMSG = "The dataset specified is not",            /* @CQ */
                  "a partitioned or sequential",              /* @CQ */
                  "dataset, please enter a valid",            /* @CQ */
                  "dataset name."                             /* @CQ */
       "SETMSG MSG(RACF011)"                                  /* @CQ */
       ITERATE                                                /* @CQ */
     END                                                      /* @CQ */
     IF (SYSDSORG = "PS") & (RACFSMBR <> "") THEN DO          /* @CQ */
        RACFSMSG = "Seq File - No mbr"                        /* @CQ */
        RACFLMSG = "This dataset is a sequential",            /* @CQ */
                  "file, please remove the",                  /* @CQ */
                  "member name."                              /* @CQ */
       "SETMSG MSG(RACF011)"                                  /* @CQ */
       ITERATE                                                /* @CQ */
     END                                                      /* @CQ */
     IF (SYSDSORG = "PO") & (RACFSMBR = "") THEN DO           /* @CQ */
        RACFSMSG = "PDS File - Need Mbr"                      /* @CQ */
        RACFLMSG = "This dataset is a partitioned",           /* @CQ */
                  "dataset, please include a member",         /* @CQ */
                  "name."                                     /* @CQ */
       "SETMSG MSG(RACF011)"                                  /* @CQ */
       ITERATE                                                /* @CQ */
     END                                                      /* @CQ */
                                                              /* @CQ */
     IF (RACFSMBR = "") THEN                                  /* @CQ */
        TMPDSN = RACFSDSN                                     /* @CQ */
     ELSE                                                     /* @CQ */
        TMPDSN = RACFSDSN"("RACFSMBR")"                       /* @CQ */
     DSNCHK = SYSDSN("'"TMPDSN"'")                            /* @CQ */
     IF (DSNCHK = "OK" & RACFSREP = "N") THEN DO              /* @CQ */
        RACFSMSG = "DSN/MBR Exists"                           /* @CQ */
        RACFLMSG = "Dataset/member already exists. ",         /* @CQ */
                  "Please type in "Y" to replace file."       /* @CQ */
        "SETMSG MSG(RACF011)"                                 /* @CQ */
        ITERATE                                               /* @CQ */
     END                                                      /* @CQ */
     LEAVE                                                    /* @CQ */
  END                                                         /* @CQ */
  "REMPOP"                                                    /* @CQ */
  "VPUT (RACFSDSN RACFSMBR RACFSFIL RACFSREP) PROFILE"        /* @CR */
                                                              /* @CQ */
ADDRESS TSO                                                   /* @CQ */
  IF (RACFSREP = "Y" & RACFSMBR = "") |,                      /* @CQ */
     (DSNCHK <> "OK" & DSNCHK <> "MEMBER NOT FOUND"),         /* @CQ */
     THEN DO                                                  /* @CQ */
     "DELETE '"RACFSDSN"'"                                    /* @CQ */
     IF (RACFSMBR = "") THEN                                  /* @CQ */
        "ALLOC  FI(ISPFILE) DA('"RACFSDSN"') NEW",            /* @CQ */
            "REUSE SP(1 1) CYLINDER UNIT(SYSALLDA)",          /* @CU */
            "LRECL(132) RECFM(F B)"                           /* @CR */
     ELSE                                                     /* @CQ */
        "ALLOC  FI(ISPFILE) DA('"RACFSDSN"') NEW",            /* @CQ */
            "REUSE SP(1 1) CYLINDER UNIT(SYSALLDA)",          /* @CU */
            "LRECL(132) RECFM(F B)",                          /* @CR */
            "DSORG(PO) DSNTYPE(LIBRARY,2)"                    /* @CQ */
  END                                                         /* @CQ */
  ELSE                                                        /* @CQ */
     "ALLOC  FI(ISPFILE) DA('"RACFSDSN"') SHR REUSE"          /* @CQ */
                                                              /* @CQ */
ADDRESS ISPEXEC                                               /* @CQ */
  "FTOPEN"                                                    /* @CQ */
  "FTINCL "TMPSKELT                                           /* @CQ */
  IF (RACFSMBR = "") THEN                                     /* @CQ */
     "FTCLOSE"                                                /* @CQ */
  ELSE                                                        /* @CQ */
     "FTCLOSE NAME("RACFSMBR")"                               /* @CQ */
  ADDRESS TSO "FREE FI(ISPFILE)"                              /* @CQ */
                                                              /* @CQ */
  SELECT                                                      /* @CQ */
     WHEN (SETGDISP = "VIEW") THEN                            /* @CQ */
          "VIEW DATASET('"RACFSDSN"') MACRO("EDITMACR")"      /* @CQ */
     WHEN (SETGDISP = "EDIT") THEN                            /* @CQ */
          "EDIT DATASET('"RACFSDSN"') MACRO("EDITMACR")"      /* @CQ */
     OTHERWISE                                                /* @CQ */
          "BROWSE DATASET('"RACFSDSN"')"                      /* @CQ */
  END                                                         /* @CQ */
  X = MSG("ON")                                               /* @CQ */
                                                              /* @CQ */
RETURN                                                        /* @CQ */
