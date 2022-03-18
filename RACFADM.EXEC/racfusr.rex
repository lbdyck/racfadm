/*%NOCOMMENT====================* REXX *==============================*/
/*  PURPOSE:  RACFADM - User Profiles - Menu option 1                 */
/*--------------------------------------------------------------------*/
/*  NOTES:    1) Line command 'XR', Cross Reference Report, is not    */
/*               displayed (hidden) on panel RACFUSR2                 */
/*               - Reason for this is sites with a large RACF         */
/*                 database, the time for 'IRRUT100' to read/obtain   */
/*                 the data is significant                            */
/*               - This command can only be accessed/used when        */
/*                 Settings (option 0) 'Administration = Y'           */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @EW  220318  LBD      Clean up opened Tables (LBD)                 */
/* @EV  201220  RACFA    Display action for Xref line command         */
/* @EU  201201  RACFA    Unhide line command X for ADMIN users        */
/* @ET  201130  TRIDJK   Added hidden line commands X and XR          */
/* @ES  200913  LBD      Bypass AUTOUID if a UID exists               */
/* @ER  200911  LBD      Enclose OMVS home/program in quotes          */
/* @EQ  200821  TRIDJK   Password phrase support                      */
/* @EP  200708  TRIDJK   Msg if selection list has no entries ('NONE')*/
/* @EO  200622  TRIDJK   Line cmd A/C, added DATA field               */
/* @EN  200618  RACFA    Chged SYSDA to SYSALLDA                      */
/* @EM  200617  RACFA    Added comments to right of variables         */
/* @EL  200616  RACFA    Added capability to SAve file as TXT/CSV     */
/* @EK  200610  RACFA    Added primary command 'SAVE'                 */
/* @EJ  200604  RACFA    Fix, prevent from going to top of table      */
/* @EI  200527  RACFA    Fix, allow typing 'S' on multiple rows       */
/* @EH  200520  RACFA    Display line cmd 'P'rofile, when 'Admin=N'   */
/* @EG  200517  LBD      Prevent user from deleting their own userid  */
/* @EF  200504  TRIDJK   Adding, place in order, prior was at bottom  */
/* @EE  200502  LBD      Re-worked displaying tables, use DO FOREVER  */
/* @ED  200501  LBD      Add primary commands FIND/RFIND              */
/* @EC  200430  RACFA    Chg tblb to TABLEB, moved def. var. up top   */
/* @EB  200430  RACFA    Chg tbla to TABLEA, moved def. var. up top   */
/* @EA  200429  RACFA    Re-arranged variables (General, Mgmt, TSO)   */
/* @E9  200426  RACFA    Chged var. ERAIPSWD to SETTPSWD (user pswd)  */
/* @E8  200425  RACFA    Chk Settings (Opt 0) 'Initial Password' field*/
/* @E7  200424  RACFA    Chged 'A'dd, 'C'hange and 'P'roile act msg   */
/* @E6  200424  RACFA    Changed ZAP to ALTUSR (line cmd AL)          */
/* @E5  200424  RACFA    Added lower case to random password          */
/* @E4  200424  RACFA    Updated RESET, pass filter, ex: R filter     */
/* @E3  200424  RACFA    Chg msg RACF013 to RACF012                   */
/* @E2  200424  RACFA    Move DDNAME at top, standardize/del dups     */
/* @E1  200424  RACFA    Add linc cmd, create/display random password */
/* @DZ  200423  RACFA    Move PARSE REXXPGM name up above IF SETMTRAC */
/* @DY  200423  RACFA    'Status Interval' by percentage (SETGSTAP)   */
/* @DX  200423  RACFA    Don't make ATT=YES, when userid is 'REVOKED' */
/* @DW  200422  TRIDJK   Fixed IRRXUTIL RC when displaying RACF cmds  */
/* @DV  200422  RACFA    Ensure the REXX program name is 8 chars      */
/* @DU  200422  RACFA    Use variable REXXPGM in log msg              */
/* @DT  200422  RACFA    Updated comments above @ADDD/@CHGD           */
/* @DS  200421  RACFA    Renamed RACFUSR#/@ to RACFUSR5/6             */
/* @DR  200421  RACFA    Del panels RACFUSR6/7 (addd/chgd)            */
/* @DQ  200421  RACFA    Del subroutine ADDD/CHGD, and some code      */
/* @DP  200420  TRIDJK   Use panel RACFUSR@ for SETMIRRX='YES/NO'     */
/* @DO  200417  RACFA    Changed date to 'U'SA, was 'O'rdered         */
/* @DN  200417  TRIDJK   Added 'Created' date                         */
/* @DM  200413  RACFA    Chg TRACEing to only display banner (P=Pgms) */
/* @DL  200412  RACFA    If line cmds Add/Change fail, display err msg*/
/* @DK  200412  RACFA    Chg TRACE to allow 'L'abels or 'R'esults     */
/* @DJ  200408  RACFA    Removed duplicate line cmd (R-Rem)           */
/* @DI  200407  RACFA    Added another dynamic area to RACFUSR2 panel */
/* @DH  200407  RACFA    Display PW when 'Admin RACF API = N'         */
/* @DG  200407  RACFA    Added line command 'PW', Password            */
/* @DF  200407  RACFA    EXCMD removed 'else msg_var = 1 to msg.0'    */
/* @DE  200407  RACFA    Let user type in password on panel           */
/* @DD  200406  RACFA    'Admin RACF API = Y', chged password to user */
/* @DC  200404  RACFA    Fixed IRRXUTIL, needed quotes around variable*/
/* @DB  200404  RACFA    Fixed IRRXUTIL, needed quotes around USER    */
/* @DA  200404  RACFA    Chk RACF cmd length, use necessary msg panel */
/* @D9  200404  RACFA    Chged subroutine comments in flower box      */
/* @D8  200404  RACFA    Chged message variable names                 */
/* @D7  200404  RACFA    'Admin RACF API = Y' then display 'P'rofile  */
/* @D6  200403  RACFA    If adding userid fails return                */
/* @D5  200403  RACFA    Allow displaying/logging command             */
/* @D4  200403  TRIDJK   Added RACF API opt for A and C line commands */
/* @D3  200402  RACFA    Chg LRECL=132 to LRECL=80                    */
/* @D2  200401  RACFA    Create subroutine to VIEW/EDIT/BROWSE        */
/* @D1  200401  RACFA    Chged edit macro RACFLOGE to RACFEMAC        */
/* @CZ  200401  RACFA    VIEW/EDIT use edit macro, to turn off HILITE */
/* @CY  200330  RACFA    RACFUSR3, point/shoot sort ascend/descending */
/* @CX  200330  RACFA    Allow point-n-shoot sort ascending/descending*/
/* @CW  200325  RACFA    Line cmd 'P', add '*Prof' to row             */
/* @CV  200324  RACFA    Allow both Display/logging of RACF commands  */
/* @CU  200324  RACFA    Allow logging RACF commands to ISPF Log file */
/* @CT  200322  RACFA    Del an unnecessary END statement on Line 629 */
/* @CS  200320  RACFA    Relocate code to upd attrs and row           */
/* @CR  200319  RACFA    Fix changing a TSO userid when 'TSO User=N'  */
/* @CQ  200317  RACFA    Fix obtaining TSO acct, proc, size and unit  */
/* @CP  200317  RACFA    Init TSOLIB=Y/N, if SETTUDSN has dsname      */
/* @CO  200315  RACFA    Added line command 'P-Profile' to RACFUSR3   */
/* @CN  200315  RACFA    Fixed typing in L as 1st line command        */
/* @CM  200315  RACFA    Placed 'P-Prof' next to other list commands  */
/* @CL  200315  RACFA    Renamed RACFSEQ to RACFPROF                  */
/* @CK  200315  RACFA    Added line command 'P-Profile'               */
/* @CJ  200313  RACFA    Chg subroutine name CHKATTR to UPDATTR       */
/* @CI  200313  RACFA    After 'C'hanging userid, upd attribute vars  */
/* @CH  200312  RACFA    Renamed attribute variables                  */
/* @CG  200311  ZDOHK    Fix Atributes for user change                */
/* @CF  200305  TRIDJK   Fix DELETE msgs for ISPPROF and TSOLIB       */
/* @CE  200304  RACFA    Update ATT field on panel, when updated      */
/* @CD  200304  RACFA    Del unnecessary double quotes                */
/* @CC  200303  RACFA    Del 'ret_code' lines for PANEL01... While    */
/* @CB  200303  RACFA    Chg 'ret_code = 0' to 'cmd_rc = rc'          */
/* @CA  200303  RACFA    Chg 'RL class ALL' to 'RL class * ALL'       */
/* @C9  200303  RACFA    Chk RC 'LG grp prms', if RC>0 then 'LU grp'  */
/* @C8  200303  RACFA    Fixed chking RC after executing command      */
/* @C7  200302  RACFA    Removed DO...END around code, not needed     */
/* @C6  200302  RACFA    Chk RC 'LU ID PRMS', if RC>0 then 'LU ID'    */
/* @C5  200301  RACFA    Check for 'NO ENTRIES MEET SEARCH CRITERIA'  */
/* @C4  200228  RACFA    Removed quote/commas, using PARSE ARG instead*/
/* @C3  200228  RACFA    Place single quotes around comma, prevent err*/
/* @C2  200228  RACFA    Added PASSWORD() to ADDUSER                  */
/* @C1  200228  RACFA    Removed ERAMCAT from VGET, not used          */
/* @BZ  200227  RACFA    Had to add "" for contuation to work properly*/
/* @BY  200227  RACFA    Fix continuation of statement                */
/* @BX  200227  TRIDJK   Fix for add and change (NONE/PROTECTED)      */
/* @BW  200227  RACFA    Added line command 'D', display user datasets*/
/* @BU  200226  RACFA    Fix @BS chg, chg ret_code to cmd_rc          */
/* @BT  200226  RACFA    Added 'CONTROL ERRORS RETURN'                */
/* @BS  200226  RACFA    Added 'Return Code =' when displaying cmd    */
/* @BR  200226  RACFA    Removed double quotes before/after cmd       */
/* @BQ  200226  RACFA    Place NO in TSO field                        */
/* @BP  200226  RACFA    Place NO in REVOKE field                     */
/* @BO  200226  RACFA    Fixed SORTing ATTR2, was ATTR, and added NO  */
/* @BN  200226  RACFA    Fixed ATTR color when sorting                */
/* @BM  200224  RACFA    Standardize quotes, chg single to double     */
/* @BL  200224  RACFA    Place panels at top of REXX in variables     */
/* @BK  200223  RACFA    Del 'address TSO "PROFILE MSGID"', not needed*/
/* @BJ  200223  RACFA    Simplified SORT, removed FLD/DFL_SORT vars   */
/* @BI  200222  RACFA    Allowing abbreviating the column in SORT cmd */
/* @BH  200222  RACFA    Removed translating OPTA/B, not needed       */
/* @BG  200222  RACFA    Allow placing cursor on row and press ENTER  */
/* @BF  200221  RACFA    Removed "G = '(G)'", not referenced          */
/* @BE  200221  LBD      Add ONLY primary command                     */
/* @BD  200221  RACFA    Display '*Search' to right of userid         */
/* @BC  200221  RACFA    Make 'ADDRESS ISPEXEC' defualt, reduce code  */
/* @BB  200220  RACFA    Fixed displaying all RACF commands           */
/* @BA  200220  RACFA    Added SETMTRAC=YES, then TRACE R             */
/* @B9  200220  RACFA    Removed initializing SETGSTA variable        */
/* @B8  200220  RACFA    Removed SE (Search) when general user (USR3) */
/* @B7  200220  RACFA    Added capability to browse/edit/view file    */
/* @B6  200220  RACFA    Removed SE (Search) from panel RACFUSR3      */
/* @B5  200220  RACFA    Chged REXX pgm name RACFTSO to RACFUSRT      */
/* @B4  200219  RACFA    Display SE (Search), was a hidden line cmd   */
/* @B3  200218  RACFA    Use dynamic area to display SELECT commands  */
/* @B2  200218  RACFA    Chged SETMADMN to YES/NO, was userid         */
/* @B1  200218  RACFA    Fixed SETMADMN, was ERAADMIN                 */
/* @AZ  200218  RACFA    Added 'Status Interval' option               */
/* @AY  200216  RACFA    Chg color to turq/green, was white/turq      */
/* @AX  200214  RACFA    Changed REXX pgm name RACFXREF to RACFUSRX   */
/* @AU  200206  RACFA    Fix color of sort col, when F3, diff. id     */
/* @AT  200206  RACFA    Fix SORT, place at top of table              */
/* @AS  200206  RACFA    Fix RESET, was not placing at top of table   */
/* @AR  200206  RACFA    Fix LOCATE, not working when sort descending */
/* @AQ  200205  TRIDJK   Allow A/D in SORT command                    */
/* @AP  200131  TRIDJK   Simulate irr* permanent user profiles        */
/* @AO  200131  TRIDJK   Fixed logon date for digital certicate logons*/
/* @AN  200126  TRIDJK   Chged yy.jjj to yy/mm/dd                     */
/* @AM  200123  RACFA    Retrieve default filter, Option 0 - Settings */
/* @AL  200123  TRIDJK   Add XR (cross reference report) line command */
/* @AK  200122  RACFA    Del TBTOP after selecting row, was chg @A7   */
/* @AJ  200122  TRIDJK   Test/del MFA option from 'LU userid' command */
/* @AI  200122  RACFA    Fixed displaying logon date                  */
/* @AH  200120  RACFA    Removed 'say msg.msg_var' in EXCMD procedure */
/* @AG  200120  RACFA    Fixed continuation issue                     */
/* @AF  200119  RACFA    Standardized/reduced lines of code           */
/* @AE  200119  RACFA    Added comment box above procedures           */
/* @AD  200119  RACFA    Fixed F3 (END) when adding/changing TSO user */
/* @AC  200118  RACFA    Added line command 'L', list group           */
/* @AB  200117  RACFA    Fixed attributes on Change/Add screens       */
/* @AA  200116  RACFA    Changed colors, White/Turq, was Turq/Blue    */
/* @A9  200115  RACFA    If id has attributes, place YES in 'Att' col */
/* @A8  200115  RACFA    Renamed variable WFLOCARG to LOCARG          */
/* @A7  200115  RACFA    Fixed sort/locate, multiple issues           */
/* @A6  200114  RACFA    Change the color for sorted column           */
/* @A5  200114  RACFA    Allow abbrev, locate on sorted column, reset */
/* @A4  200114  TRIDJK   Changed action (msg)                         */
/* @A3  200114  RACFA    Fixed SORT command thanks to John Kalinich   */
/* @A2  200113  RACFA    Add alloc/exec/free, instead of RACFLIST     */
/* @A1  200110  RACFA    Invoke RACFLIST when displaying a userid     */
/* @A0  011229  NICORIZ  Created REXX, V2.1, www.rizzuto.it           */
/*====================================================================*/
PANEL01     = "RACFUSR1"   /* Set filter, menu option 1    */ /* @BL */
PANEL02     = "RACFUSR2"   /* List userids (admin/user)    */ /* @D4 */
PANEL03     = "RACFUSR3"   /* Show groups and access       */ /* @BL */
PANEL04     = "RACFUSR4"   /* Connect profile              */ /* @BL */
PANEL05     = "RACFUSR5"   /* Alter userids (admin)        */ /* @E6 */
PANEL06     = "RACFUSR6"   /* Add/change userid            */ /* @DT */
PANEL07     = "RACFUSR7"   /* Change connection            */ /* @BL */
PANEL08     = "RACFUSR8"   /* Alter TSO segment            */ /* @BL */
PANELM2     = "RACFMSG2"   /* Display RACF command and RC  */ /* @BL */
PANELM3     = "RACFMSG3"   /* Display RACF IRXXUTIL Cmd    */ /* @D4 */
PANELS1     = "RACFSAVE"   /* Obtain DSName to SAVE        */ /* @EK */
SKELETON1   = "RACFUSR2"   /* Save tablea to dataset       */ /* @EK */
SKELETON2   = "RACFUSR3"   /* Save tableb to dataset       */ /* @EK */
EDITMACR    = "RACFEMAC"   /* Edit Macro, turn HILITE off  */ /* @CZ */
TABLEA      = 'TA'RANDOM(0,99999)  /* Unique table name A  */ /* @EB */
TABLEB      = 'TB'RANDOM(0,99999)  /* Unique table name B  */ /* @EC */
DDNAME      = 'RACFA'RANDOM(0,999) /* Unique ddname        */ /* @E2 */
parse source . . REXXPGM .         /* Obtain REXX pgm name */ /* @DZ */
REXXPGM     = LEFT(REXXPGM,8)                                 /* @DZ */
NULL        = ''                                              /* @ED */

ADDRESS ISPEXEC                                               /* @BC */
  Arg Rfilter
  If (Rfilter = '') Then Do                                   /* @AM */
     "VGET (SETGFLTR) PROFILE"                                /* @AM */
     Rfilter = SETGFLTR                                       /* @AM */
  end                                                         /* @AM */
  Call Digital_Certs                                          /* @AP */
  Rclass = 'USER'

  "CONTROL ERRORS RETURN"                                     /* @B1 */
  "VGET (SETGSTA  SETGSTAP SETGDISP SETMADMN",                /* @EA */
        "SETMIRRX SETMSHOW SETMTRAC SETTPSWD",                /* @EA */
        "SETTPROF SETTUDSN SETMPHRA) PROFILE"                 /* @EQ */

  If (SETMTRAC <> 'NO') then do                               /* @DK */
     Say "*"COPIES("-",70)"*"                                 /* @DK */
     Say "*"Center("Begin Program = "REXXPGM,70)"*"           /* @DK */
     Say "*"COPIES("-",70)"*"                                 /* @DK */
     if (SETMTRAC <> 'PROGRAMS') THEN                         /* @DM */
        interpret "Trace "SUBSTR(SETMTRAC,1,1)                /* @DK */
  end                                                         /* @DK */

  If (SETTUDSN <> "") then                                    /* @CP */
     TSOLIB = 'Y'                                             /* @CP */
  else                                                        /* @CP */
     TSOLIB = 'N'                                             /* @CP */

  If (SETMADMN = "YES") then do                               /* @B2 */
     IF (SETMIRRX = "YES") then do                            /* @D7 */
        SELCMD2A = "ÝS¨ShowÝSE¨SrchÝL¨ListÝP¨Prof"||,         /* @DI */
                   "ÝD¨DsnÝPW¨PswdÝC¨ChgÝA¨AddÝR¨Rem"||,      /* @DI */
                   "ÝRS¨Res"                                  /* @DI */
        SELCMD2B = " ÝRV¨RevÝAL¨AltÝX¨Xref"                   /* @EU */
        SELCMDS3 = "ÝS¨Show,ÝL¨List,ÝP¨Profile,"||,           /* @CO */
                   "ÝC¨Change,ÝA¨Add,ÝR¨Remove"               /* @CO */
     end                                                      /* @D7 */
     else do                                                  /* @D7 */
        SELCMD2A = "ÝS¨ShowÝSE¨SrchÝL¨List"||,                /* @DI */
                   "ÝD¨DsnÝPW¨PswdÝC¨ChgÝA¨AddÝR¨Rem"||,      /* @DI */
                   "ÝRS¨ResÝRV¨Rev"                           /* @DJ */
        SELCMD2B = "        ÝAL¨AltÝX¨Xref"                   /* @EU */
        SELCMDS3 = "ÝS¨Show,ÝL¨List,"||,                      /* @D7 */
                   "ÝC¨Change,ÝA¨Add,ÝR¨Remove"               /* @D7 */
     end                                                      /* @D7 */
  end
  else do
     IF (SETMIRRX = "YES") then do                            /* @EH */
        SELCMD2A = "ÝS¨Show,ÝSE¨Search,ÝL¨list,"||,           /* @EH */
                   "ÝP¨Profile,ÝD¨Dsn"                        /* @EH */
        SELCMDS3 = "ÝS¨Show,ÝL¨list,ÝP¨Profile"               /* @EH */
     end
     else do                                                  /* @EH */
        SELCMD2A = "ÝS¨Show,ÝSE¨Search,ÝL¨list,ÝD¨Dsn"        /* @DI */
        SELCMDS3 = "ÝS¨Show,ÝL¨list"                          /* @B8 */
     end                                                      /* @EH */
     SELCMD2B = ""                                            /* @DI */
  end

  rlv       = SYSVAR('SYSLRACF')
  called    = SYSVAR('SYSNEST')
  if (called = 'YES') then "CONTROL NONDISPL ENTER"

  "DISPLAY PANEL("PANEL01")" /* get profile */                /* @BL */
  Do while (rc = 0)
     call Profl
     if (called <> 'YES') then
        "DISPLAY PANEL("PANEL01")"                            /* @BL */
  End

  If (SETMTRAC <> 'NO') then do                               /* @DK */
     Say "*"COPIES("-",70)"*"                                 /* @DK */
     Say "*"Center("End Program = "REXXPGM,70)"*"             /* @DK */
     Say "*"COPIES("-",70)"*"                                 /* @DK */
  end                                                         /* @DK */
EXIT
/*--------------------------------------------------------------------*/
/*  Show all profiles for a filter                                    */
/*--------------------------------------------------------------------*/
PROFL:
  call CREATE_TABLEA                                          /* @BE */
  if (USER = 'INVALID') | (USER = 'NONE') THEN DO             /* @EP */
     "TBEND" tablea                                           /* @EW */
     call racfmsgs 'ERR16' msg.1                              /* @X1 */
     rc=8                                                     /* @EP */
     return
  end
  opta   = ' '
  xtdtop = 0                                                  /* @EE */
  rsels  = 0                                                  /* @EE */
  do forever                                                  /* @EE */
     if (rsels < 2) then do                                   /* @EE */
        "TBTOP " TABLEA                                       /* @EE */
        'tbskip' tablea 'number('xtdtop')'                    /* @EE */
        radmrfnd = 'PASSTHRU'                                 /* @EE */
        'vput (radmrfnd)'                                     /* @EE */
        "TBDISPL" TABLEA "PANEL("PANEL02")"                   /* @EE */
     end                                                      /* @EE */
     else 'tbdispl' tablea                                    /* @EE */
        if (rc > 4) then do                                   /* @EW */
           src = rc                                           /* @EW */
           'tbclose' tablea                                   /* @EW */
            rc = src                                          /* @EW */
            leave                                             /* @EW */
            end                                               /* @EW */
     xtdtop   = ztdtop                                        /* @EE */
     rsels    = ztdsels                                       /* @EE */
     radmrfnd = null                                          /* @EE */
     'vput (radmrfnd)'                                        /* @EE */
     PARSE VAR ZCMD ZCMD PARM SEQ                             /* @EE */
     IF (SROW <> "") & (SROW <> 0) THEN                       /* @BG */
        IF (SROW > 0) THEN DO                                 /* @BG */
           "TBTOP " TABLEA                                    /* @BG */
           "TBSKIP" TABLEA "NUMBER("SROW")"                   /* @BG */
        END                                                   /* @BG */
     if (zcmd = 'RFIND') then do                              /* @ED */
        zcmd = 'FIND'                                         /* @ED */
        parm = findit                                         /* @ED */
        'tbtop ' TABLEA                                       /* @ED */
        'tbskip' TABLEA 'number('last_find')'                 /* @ED */
     end                                                      /* @ED */
     Select
        When (abbrev("FIND",zcmd,1) = 1) then                 /* @ED */
             call do_finda                                    /* @ED */
        WHEN (ABBREV("LOCATE",ZCMD,1) = 1) THEN do            /* @A5 */
             if (parm <> '') then do
                locarg = parm'*'
                PARSE VAR SORT . "," . "," SEQ                /* @BJ */
                IF (SEQ = "D") THEN                           /* @AR */
                   CONDLIST = "LE"                            /* @AR */
                ELSE                                          /* @AR */
                   CONDLIST = "GE"                            /* @AR */
                parse value sort with scan_field',' .
                interpret scan_field ' = locarg'
                'tbtop ' tablea
                "TBSCAN "TABLEA" ARGLIST("scan_field")",
                        "CONDLIST("CONDLIST")",
                        "position(scanrow)"
                xtdtop = scanrow
             end
        end
        WHEN (ABBREV("ONLY",ZCMD,1) = 1) THEN DO              /* @BE */
             find_str = translate(parm)                       /* @BE */
             'tbtop ' TABLEA                                  /* @BE */
             'tbskip' TABLEA                                  /* @BE */
             do forever                                       /* @BE */
                str = translate(user name defgrp owner attr2) /* @BO */
                if (pos(find_str,str) > 0) then nop           /* @BE */
                else 'tbdelete' TABLEA                        /* @BE */
                'tbskip' TABLEA                               /* @BE */
                if (rc > 0) then do                           /* @BE */
                   'tbtop' TABLEA                             /* @BE */
                   leave                                      /* @BE */
                end                                           /* @BE */
             end                                              /* @BE */
        END                                                   /* @LB */
        WHEN (ABBREV("RESET",ZCMD,1) = 1) THEN DO             /* @AS */
             if (parm <> '') then                             /* @E4 */
                rfilter = parm                                /* @E4 */
             xtdtop   = 1                                     /* @AS */
             "TBEND" TABLEA                                   /* @BE */
             call CREATE_TABLEA                               /* @BE */
        END                                                   /* @AS */
        When (abbrev("SAVE",zcmd,2) = 1) then DO              /* @EK */
             TMPSKELT = SKELETON1                             /* @EK */
             call do_SAVE                                     /* @EK */
        END                                                   /* @EK */
        WHEN (ABBREV("SORT",ZCMD,1) = 1) THEN DO              /* @AT */
             SELECT                                           /* @A5 */
                when (ABBREV("USERID",PARM,1) = 1) then
                     call sortseq 'USER'                      /* @CX */
                when (ABBREV("NAME",PARM,1) = 1) then
                     call sortseq 'NAME'                      /* @CX */
                when (ABBREV("GROUP",PARM,1) = 1) then        /* @BI */
                     call sortseq 'DEFGRP'                    /* @CX */
                when (ABBREV("LOGON",PARM,1) = 1) then        /* @BI */
                     call sortseq 'DATELGN'                   /* @CX */
                when (ABBREV("OWNER",PARM,1) = 1) then        /* @BI */
                     call sortseq 'OWNER'                     /* @CX */
                when (ABBREV("REV",PARM,1) = 1) then          /* @BI */
                     call sortseq 'REVOKED'                   /* @CX */
                when (ABBREV("ATT",PARM,1) = 1) then          /* @BN */
                     call sortseq 'ATTR2'                     /* @CX */
                when (ABBREV("TSO",PARM,1) = 1) then          /* @BI */
                     call sortseq 'TSOUSER'                   /* @CX */
                otherwise NOP                                 /* @A5 */
           END                                                /* @A5 */
           CLRUSER  = "GREEN"; CLRNAME = "GREEN"              /* @EE */
           CLRDEFG  = "GREEN"; CLRDATE = "GREEN"              /* @EE */
           CLROWNE  = "GREEN"; CLRREVO = "GREEN"              /* @EE */
           CLRATTR  = "GREEN"; CLRTSOU = "GREEN"              /* @EE */
           PARSE VAR SORT LOCARG "," .                        /* @EE */
           INTERPRET "CLR"SUBSTR(LOCARG,1,4)" = 'TURQ'"       /* @EE */
           "TBSORT "TABLEA" FIELDS("sort")"                   /* @EE */
           "TBTOP  "TABLEA                                    /* @EE */
        END                                                   /* @AT */
        otherwise NOP
     End /* Select */
     ZCMD = ""; PARM = ""                                     /* @EE */
     'control display save'                                   /* @EE */
     Select
        when (opta = 'A')  then call @Addd                    /* @DQ */
        when (opta = 'C')  then call @Chgd                    /* @DQ */
        when (opta = 'D')  then do                            /* @BW */
             "CONTROL DISPLAY SAVE"                           /* @BW */
             "SELECT PGM(ISRDSLST)",                          /* @BW */
                    "PARM(DSL '"user"')",                     /* @BW */
                    "SUSPEND SCRNAME(DSL)"                    /* @BW */
             "CONTROL DISPLAY RESTORE"                        /* @BW */
             action = '*Dsn'                                  /* @BW */
             "TBMOD" TABLEA                                   /* @BW */
        end                                                   /* @BW */
        when (opta = 'L')  then call Lisd
        when (opta = 'P') then do                             /* @CK */
             call RACFPROF 'USER' user                        /* @CK */
             action = '*Prof'                                 /* @CW */
             "TBMOD" TABLEA                                   /* @CW */
        end                                                   /* @CW */
        when (opta = 'PW') then do                            /* @DG */
             RC = RACFPSWD(user)                              /* @DG */
             if (RC = 0) then do                              /* @DG */
                action = '*Pswd'                              /* @DG */
                "TBMOD" TABLEA                                /* @DG */
             end                                              /* @DG */
        end
        when (opta = 'R')  then call Deld
        when (opta = 'RS') then call Resd
        when (opta = 'RV') then call Revd
        when (opta = 'S')  then call Disd
        when (opta = 'SE') then do
             if (revoked <> 'YES') then
                call RACFCLSS user
             else
                call racfmsgs 'ERR12' msg.1 /* user revoked */
             action = '*Search'                               /* @BD */
             "TBMOD" TABLEA                                   /* @BD */
        end
        when (opta = 'XR') then call RACFUSRX user            /* @ET */
        when (opta = 'X') then do                             /* @EV */
             call RACFUSRX user JCC                           /* @EV */
             action = '*Xref'                                 /* @EV */
             'TBMOD 'tablea                                   /* @EV */
        end                                                   /* @EV */
        when (opta = 'AL') then call Altd                     /* @E6 */
        otherwise nop
     End
     'control display restore'                                /* @EE */
  end  /* Do forever) */                                      /* @EE */
RETURN
/*--------------------------------------------------------------------*/
/*  Process primary command FIND for TABLEA                      @ED  */
/*--------------------------------------------------------------------*/
DO_FINDA:                                                     /* @ED */
  if (parm = null) then do                                    /* @ED */
     racfsmsg = 'Error'                                       /* @ED */
     racflmsg = 'Find requires a value to search for.' ,      /* @ED */
                'Try again.'                                  /* @ED */
     'setmsg msg(RACF011)'                                    /* @ED */
     return                                                   /* @ED */
  end                                                         /* @ED */
  findit    = translate(parm)                                 /* @ED */
  last_find = 0                                               /* @ED */
  wrap      = 0                                               /* @ED */
  do forever                                                  /* @ED */
     'tbskip' TABLEA                                          /* @ED */
     if (rc > 0) then do                                      /* @ED */
        if (wrap = 1) then do                                 /* @ED */
           racfsmsg = 'Not Found'                             /* @ED */
           racflmsg = findit 'not found.'                     /* @ED */
           'setmsg msg(RACF011)'                              /* @ED */
           return                                             /* @ED */
        end                                                   /* @ED */
        if (wrap = 0) then wrap = 1                           /* @ED */
        'tbtop' TABLEA                                        /* @ED */
     end                                                      /* @ED */
     else do                                                  /* @ED */
        testit = translate(user name)                         /* @ED */
        if (pos(findit,testit) > 0) then do                   /* @ED */
           'tbquery' TABLEA 'position(srow)'                  /* @ED */
           'tbtop'   TABLEA                                   /* @ED */
           'tbskip'  TABLEA 'number('srow')'                  /* @ED */
           last_find = srow                                   /* @ED */
           xtdtop    = srow                                   /* @ED */
           if (wrap = 0) then                                 /* @ED */
              racfsmsg = 'Found'                              /* @ED */
           else                                               /* @ED */
              racfsmsg = 'Found/Wrapped'                      /* @ED */
           racflmsg = findit 'found in row' srow + 0          /* @ED */
           'setmsg msg(RACF011)'                              /* @ED */
           return                                             /* @ED */
        end                                                   /* @ED */
     end                                                      /* @ED */
  end                                                         /* @ED */
RETURN                                                        /* @ED */
/*--------------------------------------------------------------------*/
/*  Define sort sequence, to allow point-n-shoot sorting (A/D)   @CX  */
/*--------------------------------------------------------------------*/
SORTSEQ:                                                      /* @CX */
  parse arg sortcol                                           /* @CX */
  INTERPRET "TMPSEQ = SORT"substr(SORTCOL,1,4)                /* @CX */
  select                                                      /* @CX */
     when (seq <> "") then do                                 /* @CX */
          if (seq = 'A') then                                 /* @CX */
             tmpseq = 'D'                                     /* @CX */
          else                                                /* @CX */
             tmpseq = 'A'                                     /* @CX */
          sort = sortcol',C,'seq                              /* @CX */
     end                                                      /* @CX */
     when (seq = ""),                                         /* @CX */
        & (tmpseq = 'A') then do                              /* @CX */
           sort   = sortcol',C,A'                             /* @CX */
           tmpseq = 'D'                                       /* @CX */
     end                                                      /* @CX */
     Otherwise do                                             /* @CX */
        sort   = sortcol',C,D'                                /* @CX */
        tmpseq = 'A'                                          /* @CX */
     end                                                      /* @CX */
  end                                                         /* @CX */
  INTERPRET "SORT"SUBSTR(SORTCOL,1,4)" = TMPSEQ"              /* @CX */
RETURN                                                        /* @CX */
/*--------------------------------------------------------------------*/
/*  Resume/reset userid                                               */
/*--------------------------------------------------------------------*/
RESD:
  action = '*Reset'                                           /* @A4 */
  msg    = 'You are about to resume/reset 'USER NAME
  Sure_? = RACFMSGC(msg)
  if (sure_? = 'YES') then do
     if (SETTPSWD = "") then                                  /* @EQ */
        userp = "user.user.user"                              /* @EQ */
     else                                                     /* @EQ */
        userp = left(SETTPSWD,14)                             /* @EQ */
     if SETMPHRA = 'YES' then                                 /* @EQ */
        call EXCMD "ALTUSER "user" RESUME PHRASE('"userp"')"  /* @EQ */
     else                                                     /* @EQ */
        call EXCMD "ALTUSER "user" RESUME PASSWORD("user")"   /* @EQ */
     if (cmd_rc = 0) then do                                  /* @CA */
        revoked ='NO'                                         /* @BP */
        "TBMOD" TABLEA
     end
     else
        CALL racfmsgs "ERR07" msg.1 /* Alter failed */        /* @X1 */
  end
RETURN
/*--------------------------------------------------------------------*/
/*  Revoke userid                                                     */
/*--------------------------------------------------------------------*/
REVD:
  action = "*Revoke"                                          /* @A4 */
  msg    = 'You are about to revoke 'USER NAME
  Sure_? = RACFMSGC(msg)
  if (sure_? = 'YES') then do
     call EXCMD "ALTUSER "user" REVOKE"
     if (cmd_rc = 0) then do                                  /* @CA */
        revoked ='YES'
        "TBMOD" TABLEA
     end
     else
        CALL racfmsgs "ERR07" msg.1 /* Alter failed */        /* @X1 */
  end
RETURN
/*--------------------------------------------------------------------*/
/*  List userid                                                       */
/*--------------------------------------------------------------------*/
LISD:
  action  = '*Listed'                                         /* @A4 */
  CMDPRM  = "CICS CSDATA DCE DFP EIM KERB LANGUAGE",          /* @A2 */
            "LNOTES MFA NDS NETVIEW OMVS OPERPARM",           /* @A2 */
            "OVM PROXY TSO WORKATTR"                          /* @A2 */
  call get_setropts_options                                   /* @AJ */
  if (rcvtsmfa = 'NO') then do                                /* @AJ */
     mfa_pos = pos('MFA',CMDPRM)                              /* @AJ */
     CMDPRM = delstr(CMDPRM,mfa_pos,4)                        /* @AJ */
  end                                                         /* @AJ */
  cmd = "LU "USER CMDPRM                                      /* @BB */
  X = OUTTRAP("CMDREC.")                                      /* @A2 */
  ADDRESS TSO cmd                                             /* @BB */
  cmd_rc = rc                                                 /* @BS */
  if (SETMSHOW <> 'NO') then                                  /* @CU */
     call SHOWCMD                                             /* @BS */
  X = OUTTRAP("OFF")                                          /* @A2 */
  IF (cmd_rc > 0) then DO    /* Removed parms */              /* @C6 */
     X = OUTTRAP("CMDREC.")                                   /* @C6 */
     cmd = "LU "USER                                          /* @C6 */
     ADDRESS TSO cmd                                          /* @C6 */
     cmd_rc = rc                                              /* @C6 */
     X = OUTTRAP("OFF")                                       /* @C6 */
     if (SETMSHOW <> 'NO') then                               /* @CU */
        call SHOWCMD                                          /* @C6 */
  END                                                         /* @C6 */
  if (user = 'irrcerta') then do                              /* @AP */
     CMDREC. = ''                                             /* @AP */
     CMDREC.0 = 3                                             /* @AP */
     CMDREC.1 = irrcerta.1                                    /* @AP */
     CMDREC.2 = irrcerta.3                                    /* @AP */
     CMDREC.3 = irrcerta.6                                    /* @AP */
  end                                                         /* @AP */
  if (user = 'irrmulti') then do                              /* @AP */
     CMDREC. = ''                                             /* @AP */
     CMDREC.0 = 3                                             /* @AP */
     CMDREC.1 = irrmulti.1                                    /* @AP */
     CMDREC.2 = irrmulti.3                                    /* @AP */
     CMDREC.3 = irrmulti.6                                    /* @AP */
  end                                                         /* @AP */
  if (user = 'irrsitec') then do                              /* @AP */
     CMDREC. = ''                                             /* @AP */
     CMDREC.0 = 3                                             /* @AP */
     CMDREC.1 = irrsitec.1                                    /* @AP */
     CMDREC.2 = irrsitec.3                                    /* @AP */
     CMDREC.3 = irrsitec.6                                    /* @AP */
  end                                                         /* @AP */
  call display_info                                           /* @D2 */
  if (cmd_rc = 0) then                                        /* @C8 */
     "TBMOD" TABLEA
  else
     CALL racfmsgs "ERR10" msg.1 /* Generic failure */        /* @X1 */
RETURN
/*--------------------------------------------------------------------*/
/*  Display information from line commands 'L' and 'P'           @D2  */
/*--------------------------------------------------------------------*/
DISPLAY_INFO:                                                 /* @D2 */
  ADDRESS TSO "ALLOC F("DDNAME") NEW REUSE",                  /* @A2 */
              "LRECL(80) BLKSIZE(0) RECFM(F B)",              /* @D3 */
              "UNIT(VIO) SPACE(1 5) CYLINDERS"                /* @A2 */
  ADDRESS TSO "EXECIO * DISKW "DDNAME" (STEM CMDREC. FINIS"   /* @A2 */
  DROP CMDREC.                                                /* @A2 */
                                                              /* @A2 */
  "LMINIT DATAID(CMDDATID) DDNAME("DDNAME")"                  /* @A2 */
  SELECT                                                      /* @B7 */
     WHEN (SETGDISP = "VIEW") THEN                            /* @B7 */
          "VIEW DATAID("CMDDATID") MACRO("EDITMACR")"         /* @CZ */
     WHEN (SETGDISP = "EDIT") THEN                            /* @B7 */
          "EDIT DATAID("CMDDATID") MACRO("EDITMACR")"         /* @CZ */
     OTHERWISE                                                /* @B7 */
          "BROWSE DATAID("CMDDATID")"                         /* @B7 */
  END                                                         /* @B7 */
  ADDRESS TSO "FREE FI("DDNAME")"                             /* @A2 */
RETURN                                                        /* @D2 */
/*--------------------------------------------------------------------*/
/*  Get Multi Factor Authentication (MFA) option from RCVT            */
/*--------------------------------------------------------------------*/
GET_SETROPTS_OPTIONS:                                         /* @AJ */
  cvt     = c2x(storage(10,4))      /* cvt address        */  /* @AJ */
  cvtrac$ = d2x((x2d(cvt))+992)     /* cvt+3E0 = cvtrac $ */  /* @AJ */
  cvtrac  = c2x(storage(cvtrac$,4)) /* cvtrac=access cntl */  /* @AJ */
  rc      = setbool(rcvtsmfa,633,'02','NO','YES') /* mfa  */  /* @AJ */
RETURN                                                        /* @AJ */
/*--------------------------------------------------------------------*/
/*  Set boolean value for mask                                        */
/*--------------------------------------------------------------------*/
SETBOOL:
  variable = arg(1)                                           /* @AJ */
  offset   = arg(2)                                           /* @AJ */
  value    = arg(3)                                           /* @AJ */
  status1  = arg(4)                                           /* @AJ */
  status2  = arg(5)                                           /* @AJ */
  interpret  "rcvtsta$= d2x((x2d("cvtrac"))+"offset")"        /* @AJ */
  x        = storage(rcvtsta$,1)                              /* @AJ */
  interpret variable '= 'status1                              /* @AJ */
  interpret "x=bitand(x,'"value"'x)" /*remove bad bits*/      /* @AJ */
  interpret "if (x= '"value"'x) then "variable"="status2      /* @AJ */
RETURN 0                                                      /* @AJ */
/*--------------------------------------------------------------------*/
/*  List group                                                        */
/*--------------------------------------------------------------------*/
LISP:
  action  = '*Prof'                                           /* @E7 */
  CMDPRM  = "CSDATA DFP OMVS OVM TME"                         /* @AC */
  cmd     = "LG "ID" "CMDPRM                                  /* @BB */
  X = OUTTRAP("CMDREC.")                                      /* @AC */
  ADDRESS TSO cmd                                             /* @BB */
  cmd_rc = rc                                                 /* @BS */
  X = OUTTRAP("OFF")                                          /* @AC */
  if (SETMSHOW <> 'NO') then                                  /* @CU */
     call SHOWCMD                                             /* @BB */
  if (cmd_rc > 0) then do /* Remove Parms */                  /* @C9 */
     cmd     = "LG "ID                                        /* @C9 */
     X = OUTTRAP("CMDREC.")                                   /* @C9 */
     ADDRESS TSO cmd                                          /* @C9 */
     cmd_rc = rc                                              /* @C9 */
     X = OUTTRAP("OFF")                                       /* @C9 */
     if (SETMSHOW <> 'NO') then                               /* @CU */
        call SHOWCMD                                          /* @C9 */
  END                                                         /* @C9 */
  call display_info                                           /* @D2 */
  if (cmd_rc = 0) then                                        /* @C8 */
     "TBMOD" TABLEB                                           /* @AC */
  else                                                        /* @AC */
     CALL racfmsgs "ERR10" msg.1 /* Generic failure */        /* @X1 */
RETURN                                                        /* @AC */
/*--------------------------------------------------------------------*/
/*  Obtain userid attributes                                     @CI  */
/*--------------------------------------------------------------------*/
UPDATTR:                                                      /* @CJ */
  cmd    = "LU "USER" TSO"                                    /* @CI */
  x      = OUTTRAP('details.')                                /* @CI */
  address TSO cmd                                             /* @CI */
  cmd_rc = rc                                                 /* @CI */
  x      = OUTTRAP('OFF')                                     /* @CI */
  if (SETMSHOW <> 'NO') then                                  /* @CU */
     call SHOWCMD                                             /* @CI */
  parse var details.3 'ATTRIBUTES='attribute1                 /* @CI */
  parse var details.4 'ATTRIBUTES='attribute2                 /* @CI */
  attr = STRIP(attribute1) STRIP(attribute2)                  /* @CI */
  none  = POS('NONE',attr)                                    /* @CI */
  if (none <> 0) then                                         /* @CI */
     attr = delstr(attr,none,4)      /* Delete 'NONE'    */   /* @CI */
  none  = POS('REVOKED',attr)                                 /* @DX */
  if (none <> 0) then                                         /* @DX */
     attr = delstr(attr,revoked,7)   /* Delete 'REVOKED' */   /* @DX */
  attr2 = 'NO'                                                /* @CI */
  if (none = 0) then do                                       /* @CI */
     attr2 = 'YES'                                            /* @CI */
  end                                                         /* @CI */
RETURN                                                        /* @CI */
/*--------------------------------------------------------------------*/
/*  Delete profile                                                    */
/*--------------------------------------------------------------------*/
DELD:
  ACTION = "*Delete"                                          /* @A4 */
  if (USER = 'NONE') then
     return
  if (user = userid()) then do                                /* @EG */
     racflmsg = 'You can NOT delete your userid',             /* @EG */
                '('user').  This is for your own',            /* @EG */
                'safety!'                                     /* @EG */
     'setmsg msg(RACF011)'                                    /* @EG */
     return
  end
  msg    = 'You are about to delete 'USER
  Sure_? = RACFMSGC(msg)
  if (sure_? = 'YES') then do
     if (tsouser = 'YES') then do
        msg    = user'.'SETTPROF                              /* @CF */
        if SETTUDSN <> '' then                                /* @CF */
        msg    = msg || ' and 'user'.'SETTUDSN                /* @CF */
        msg    = msg || ' will be deleted'                    /* @CF */
        Sure_? = RACFMSGC(msg)
        if (sure_? = 'YES') then
           ret_code = RACFUSRT('DELD' user tsoproc,           /* @C4 */
                      tsoacct defgrp owner tsolib)            /* @C4 */
        if (ret_code <= 8) then do
           call EXCMD "DELUSER ("USER")"
           if (cmd_rc = 0) then                               /* @CA */
              "TBDELETE" TABLEA
           else CALL racfmsgs "ERR02" msg.1 /* RDELETE failed */
        end
        else CALL racfmsgs "ERR02"  msg.1 /* RDELETE failed */
     end
     else do
        call EXCMD "DELUSER ("USER")"
        if (cmd_rc = 0) then                                  /* @CA */
           "TBDELETE" TABLEA
        else CALL racfmsgs "ERR02" msg.1  /* RDELETE failed */
     end
  end  /* Confirm-delete */
RETURN
/*--------------------------------------------------------------------*/
/*  Display profile permits                                           */
/*--------------------------------------------------------------------*/
DISD:
  action = '*Shown'                                           /* @A4 */
  "TBMOD" TABLEA
  if (USER = 'NONE') then
     return
  tmpsort   = sort                                            /* @CY */
  tmprsels  = rsels                                           /* @EI */
  tmpxtdtop = xtdtop                                          /* @EJ */
  Do until (RB='NO')   /* allow rebuild option to loop */
     call CREATE_TABLEB                                       /* @CY */
     rb     = 'NO'
     xtdtop = 0                                               /* @EE */
     rsels  = 0                                               /* @EE */
     do forever                                               /* @EE */
        if (rsels < 2) then do                                /* @EE */
           optb = ' '                                         /* @EE */
           "TBTOP " TABLEB                                    /* @EE */
           'tbskip' tableb 'number('xtdtop')'                 /* @EE */
           radmrfnd = 'PASSTHRU'                              /* @EE */
           'vput (radmrfnd)'                                  /* @EE */
           "TBDISPL" TABLEB "PANEL("PANEL03")"                /* @EE */
        end                                                   /* @EE */
        else 'tbdispl' tableb                                 /* @EE */
        if (rc > 4) then do                                   /* @EW */
           src = rc                                           /* @EW */
           'tbclose' tableb                                   /* @EW */
            rc = src                                          /* @EW */
            leave                                             /* @EW */
            end                                               /* @EW */
        xtdtop   = ztdtop                                     /* @EE */
        rsels    = ztdsels                                    /* @EE */
        radmrfnd = null                                       /* @EE */
        'vput (radmrfnd)'                                     /* @EE */
        PARSE VAR ZCMD ZCMD PARM SEQ                          /* @EE */
        IF (SROW <> "") & (SROW <> 0) THEN                    /* @BG */
           IF (SROW > 0) THEN DO                              /* @BG */
              "TBTOP " TABLEB                                 /* @BG */
              "TBSKIP" TABLEB "NUMBER("SROW")"                /* @BG */
           END                                                /* @BG */
        if (zcmd = 'RFIND') then do                           /* @ED */
           zcmd = 'FIND'                                      /* @ED */
           parm = findit                                      /* @ED */
           'tbtop ' TABLEB                                    /* @ED */
           'tbskip' TABLEB 'number('last_find')'              /* @ED */
        end                                                   /* @ED */
        Select                                                /* @CY */
           When (abbrev("FIND",zcmd,1) = 1) then              /* @ED */
                call do_findb                                 /* @ED */
           WHEN (ABBREV("LOCATE",ZCMD,1) = 1) THEN DO
                if (parm <> '') then do                       /* @EE */
                   locarg = parm'*'                           /* @EE */
                   PARSE VAR SORT . "," . "," SEQ             /* @EE */
                   IF (SEQ = "D") THEN                        /* @EE */
                      CONDLIST = "LE"                         /* @EE */
                   ELSE                                       /* @EE */
                      CONDLIST = "GE"                         /* @EE */
                   parse value sort with scan_field',' .      /* @EE */
                   interpret scan_field ' = locarg'           /* @EE */
                   'tbtop ' tableb                            /* @EE */
                   "TBSCAN "TABLEB" ARGLIST("scan_field")",   /* @EE */
                           "CONDLIST("CONDLIST")",            /* @EE */
                           "position(scanrow)"                /* @EE */
                   xtdtop = scanrow                           /* @EE */
                end                                           /* @EE */
           end
           WHEN (ABBREV("ONLY",ZCMD,1) = 1) THEN DO           /* @CY */
                find_str = translate(parm)                    /* @CY */
                'tbtop ' TABLEB                               /* @CY */
                'tbskip' TABLEB                               /* @CY */
                do forever                                    /* @CY */
                   str = translate(id acc)                    /* @CY */
                   if (pos(find_str,str) > 0) then nop        /* @CY */
                   else 'tbdelete' TABLEB                     /* @CY */
                   'tbskip' TABLEB                            /* @CY */
                   if (rc > 0) then do                        /* @CY */
                      'tbtop' TABLEB                          /* @CY */
                      leave                                   /* @CY */
                   end                                        /* @CY */
                end                                           /* @CY */
           END                                                /* @CY */
           WHEN (ABBREV("RESET",ZCMD,1) = 1) THEN DO          /* @CY */
                xtdtop = 1                                    /* @CY */
                "TBEND" TABLEB                                /* @CY */
                call CREATE_TABLEB                            /* @CY */
           END                                                /* @CY */
           When (abbrev("SAVE",zcmd,2) = 1) then DO           /* @EK */
                TMPSKELT = SKELETON2                          /* @EK */
                call do_SAVE                                  /* @EK */
           END                                                /* @EK */
           WHEN (ABBREV("SORT",ZCMD,1) = 1) THEN DO           /* @CY */
                SELECT                                        /* @CY */
                   when (ABBREV("GROUP",PARM,1) = 1) then     /* @CY */
                        call sortseq 'ID'                     /* @CY */
                   when (ABBREV("ACCESS",PARM,1) = 1) then    /* @CY */
                        call sortseq 'ACC'                    /* @CY */
                   otherwise NOP                              /* @CY */
                END                                           /* @CY */
                PARSE VAR SORT LOCARG "," .                   /* @EE */
                CLRID   = "GREEN"; CLRACC  = "GREEN"          /* @EE */
                INTERPRET "CLR"SUBSTR(LOCARG,1,4)" = 'TURQ'"  /* @EE */
                "TBSORT" TABLEB "FIELDS("sort")"              /* @EE */
                "TBTOP " TABLEB                               /* @EE */
           END                                                /* @CY */
           otherwise NOP                                      /* @CY */
        End /* Select */                                      /* @CY */
        ZCMD = ""; PARM = ""                                  /* @EE */
        'control display save'                                /* @EE */
        Select
           when (optb = 'A') then call Addp
           when (optb = 'C') then call Chgp
           when (optb = 'L') then call Lisp                   /* @CN */
           when (optb = 'P') then do                          /* @CO */
                call RACFPROF 'GROUP' id                      /* @CO */
                action = '*Prof'                              /* @CW */
                "TBMOD" TABLEB                                /* @CW */
           end                                                /* @CW */
           when (optb = 'R') then call Delp
           when (optb = 'S') then call RACFGRP id
           otherwise nop
        End
        'control display restore'                             /* @EE */
     end  /* Do forever) */                                   /* @EE */
     "TBEND" TABLEB
  end  /* Do until */
  sort   = tmpsort                                            /* @CY */
  rsels  = tmprsels                                           /* @EI */
  xtdtop = tmpxtdtop                                          /* @EJ */
RETURN
/*--------------------------------------------------------------------*/
/*  Process primary command FIND for TABLEB                      @ED  */
/*--------------------------------------------------------------------*/
DO_FINDB:                                                     /* @ED */
  if (parm = null) then do                                    /* @ED */
     racfsmsg = 'Error'                                       /* @ED */
     racflmsg = 'Find requires a value to search for.' ,      /* @ED */
                'Try again.'                                  /* @ED */
     'setmsg msg(RACF011)'                                    /* @ED */
     return                                                   /* @ED */
  end                                                         /* @ED */
  findit    = translate(parm)                                 /* @ED */
  last_find = 0                                               /* @ED */
  wrap      = 0                                               /* @ED */
  do forever                                                  /* @ED */
     'tbskip' TABLEB                                          /* @ED */
     if (rc > 0) then do                                      /* @ED */
        if (wrap = 1) then do                                 /* @ED */
           racfsmsg = 'Not Found'                             /* @ED */
           racflmsg = findit 'not found.'                     /* @ED */
           'setmsg msg(RACF011)'                              /* @ED */
           return                                             /* @ED */
        end                                                   /* @ED */
        if (wrap = 0) then wrap = 1                           /* @ED */
        'tbtop' tableb                                        /* @ED */
     end                                                      /* @ED */
     else do                                                  /* @ED */
        testit = translate(id acc)                            /* @ED */
        if (pos(findit,testit) > 0) then do                   /* @ED */
           'tbquery' TABLEB 'position(srow)'                  /* @ED */
           'tbtop'   TABLEB                                   /* @ED */
           'tbskip'  TABLEB 'number('srow')'                  /* @ED */
           last_find = srow                                   /* @ED */
           xtdtop    = srow                                   /* @ED */
           if (wrap = 0) then                                 /* @ED */
              racfsmsg = 'Found'                              /* @ED */
           else                                               /* @ED */
              racfsmsg = 'Found/Wrapped'                      /* @ED */
           racflmsg = findit 'found in row' srow + 0          /* @ED */
           'setmsg msg(RACF011)'                              /* @ED */
           return                                             /* @ED */
        end                                                   /* @ED */
     end                                                      /* @ED */
  end                                                         /* @ED */
RETURN                                                        /* @ED */
/*--------------------------------------------------------------------*/
/*  Create table 'B'                                             @CY  */
/*--------------------------------------------------------------------*/
CREATE_TABLEB:                                                /* @CY */
  "TBCREATE" TABLEB "KEYS(ID) NAMES(ACC)",
                  "REPLACE NOWRITE"
  flags = 'OFF'
  uacc  = ' '
  cmd   = "LU "USER                                           /* @BB */
  x = OUTTRAP('VAR.')
  address TSO cmd                                             /* @BB */
  cmd_rc = rc                                                 /* @BS */
  x = OUTTRAP('OFF')
  if (SETMSHOW <> 'NO') then                                  /* @CU */
     call SHOWCMD                                             /* @BB */
  Do i = 1 to var.0  /* Scan output */
     temp = var.i
     if (substr(temp,3,5) = 'GROUP') then do
        id  = substr(temp,9,8)
        acc = substr(temp,24,8)
        "TBMOD" TABLEB
     end
  end
  sort   = 'ID,C,A'                                           /* @EE */
  sortid = 'D'; sortacc = 'A'                                 /* @EE */
  CLRID  = "TURQ"; CLRACC  = "GREEN"                          /* @EE */
  "TBSORT " TABLEB "FIELDS("sort")"                           /* @EE */
  "TBTOP  " TABLEB                                            /* @EE */
RETURN                                                        /* @CY */
/*--------------------------------------------------------------------*/
/*  Get user info to initialize add or change option                  */
/*--------------------------------------------------------------------*/
GETD:
  owner    = ' '
  name     = ' '
  defgrp   = ' '
  data     = ' '
  datecre  = ' '
  datelgn  = ' '
  datepass = ' '
  intpass  = ' '
  revoked  = 'NO'                                             /* @BP */
  tsouser  = ''
  attr     = ''
  attrspec = 'N'      /* Special:    Y=Yes, N=No */           /* @CH */
  attroper = 'N'      /* Operations: Y=Yes, N=No */           /* @CH */
  attraudi = 'N'      /* Auditor:    Y=Yes, N=No */           /* @CH */
  cmd      = "LU "USER" TSO"                                  /* @BB */

  x        = OUTTRAP('details.')
  address TSO cmd                                             /* @BB */
  cmd_rc = rc                                                 /* @BS */
  x        = OUTTRAP('OFF')
  if (SETMSHOW <> 'NO') then                                  /* @CU */
     call SHOWCMD                                             /* @BB */
  getd_max = details.0

  if (user = 'irrcerta') then do                              /* @AP */
     details.1 = irrcerta.1                                   /* @AP */
     details.3 = irrcerta.3                                   /* @AP */
     details.6 = irrcerta.6                                   /* @AP */
  end                                                         /* @AP */
  if (user = 'irrmulti') then do                              /* @AP */
     details.1 = irrmulti.1                                   /* @AP */
     details.3 = irrmulti.3                                   /* @AP */
     details.6 = irrmulti.6                                   /* @AP */
  end                                                         /* @AP */
  if (user = 'irrsitec') then do                              /* @AP */
      details.1 = irrsitec.1                                  /* @AP */
      details.3 = irrsitec.3                                  /* @AP */
      details.6 = irrsitec.6                                  /* @AP */
  end                                                         /* @AP */

  parse var details.1 ,
  'USER=' x 'NAME=' name 'OWNER=' owner 'CREATED=' datecre
  if datecre <> '' then do                                    /* @DN */
     datecre = SUBSTR(datecre,1,2)SUBSTR(datecre,4,3)         /* @DN */
     datecre = DATE('U',datecre,'J')                          /* @DO */
  end                                                         /* @DN */

  parse var details.2 ,
        'DEFAULT-GROUP=' defgrp 'PASSDATE=',
        datepass 'PASS-INTERVAL=' Intpass

  parse var details.3 'ATTRIBUTES='attribute1                 /* @AB */
  parse var details.4 'ATTRIBUTES='attribute2                 /* @AB */
  attr = STRIP(attribute1) STRIP(attribute2)                  /* @AB */
  if (POS('SPECIAL',attr) > 0)    then ATTRSPEC = "Y"         /* @CH */
  if (POS('OPERATIONS',attr) > 0) then ATTROPER = "Y"         /* @CH */
  if (POS('AUDITOR',attr) > 0)    then ATTRAUDI = "Y"         /* @CH */

  rev  = POS('REVOKED',attr)
  if (rev <> 0) then do                                       /* @BX */
     revoked = 'YES'                                          /* @BX */
     attr = delstr(attr,rev,7)   /* Del 'REVOKED' */          /* @BX */
  end                                                         /* @BX */
  none  = POS('NONE',attr)                                    /* @A9 */
  if (none <> 0) then                                         /* @BX */
     attr = delstr(attr,none,4)  /* Del 'NONE'    */          /* @BX */
  attr2 = 'NO'                                                /* @BO */
  if (none = 0) then do                                       /* @A9 */
     attr2 = 'YES'                                            /* @AB */
  end                                                         /* @A9 */
  prot  = POS('PROTECTED',attr)                               /* @BX */
  if (prot <> 0) then attr = delstr(attr,prot,9)              /* @BX */

  parse var details.5 'LAST-ACCESS=' datelgn5                 /* @AI */
  parse var details.6 'LAST-ACCESS=' datelgn6                 /* @AI */
  Select                                                      /* @AI */
     When (datelgn5 <> "") Then                               /* @AI */
          datelgn = datelgn5                                  /* @AI */
     otherwise                                                /* @AI */
          datelgn = datelgn6                                  /* @AI */
  end                                                         /* @AI */
  if (datelgn = 'UNKNOW') then                                /* @AN */
     datelgn = 'UNKNOWN'                                      /* @AN */
  if (datelgn = " ") | (datelgn = 'UNKNOWN') then             /* @AO */
     nop                                                      /* @AO */
  else do                                                     /* @AR */
     datelgn = SUBSTR(datelgn,1,2)SUBSTR(datelgn,4,3)         /* @AN */
     datelgn = DATE('O',datelgn,'J')                          /* @AN */
  end                                                         /* @AN */

  parse var details.7 'INSTALLATION-DATA=' data
  TSOUSER = "NO"                                              /* @BQ */
  do getd_count=8 to getd_max
     if (details.getd_count = 'NO TSO INFORMATION') then leave
     if (details.getd_count = 'TSO INFORMATION') then do
        tsouser    ='YES'
        getd_count = getd_count + 1                           /* @CQ */
        do k = getd_count to getd_max                         /* @CQ */
           parse var details.k W1 W2                          /* @CQ */
           W2 = STRIP(W2)                                     /* @CQ */
           Select                                             /* @CQ */
              When (W1 = 'ACCTNUM=') then tsoacct = W2        /* @CQ */
              When (W1 = 'PROC=')    then tsoproc = W2        /* @CQ */
              When (W1 = 'SIZE=')    then tsosize = W2        /* @CQ */
              When (W1 = 'UNIT=')    then tsounit = W2        /* @CQ */
              otherwise nop                                   /* @CQ */
           end                                                /* @CQ */
        end                                                   /* @CQ */
        if (tsosize <> ' ') then tsosize = format(tsosize)
        leave
     end  /* Tso-info */
  end  /* Do count */
RETURN
/*--------------------------------------------------------------------*/
/*  Change permit option                                              */
/*--------------------------------------------------------------------*/
CHGP:
  If (id = 'NONE') then
     return
  "DISPLAY PANEL("PANEL07")"                                  /* @BL */
  if (rc > 0) then
     return
  call EXCMD "PE "USER" CLASS("RCLASS") ID("ID")",
             "ACC("ACC")" TYPE
  if (cmd_rc = 0) then                                        /* @CA */
     "TBMOD" TABLEB
  else
     Call racfmsgs 'ERR03' msg.1 /* permit failed */          /* @X1 */
RETURN
/*--------------------------------------------------------------------*/
/*  Add permit option                                                 */
/*--------------------------------------------------------------------*/
ADDP:
  new = 'NO'
  if (id = 'NONE') then
     new = 'YES'
  from = ' '
  "DISPLAY PANEL("PANEL04")"                                  /* @BL */
  if (rc > 0) then
     return
  idopt = ' '
  if (id <> ' ') then
     idopt = 'ID('ID') ACCESS('ACC')'
  fopt = ' '
  if (from <> ' ') then do
     fopt = "FROM('"FROM"') FCLASS("RCLASS") FGENERIC"
     rb   = 'YES'             /* Cause table rebuild */
  end
  call EXCMD "CONNECT ("user") GROUP("id") AUTH("acc")"
  if (cmd_rc = 0) then do                                     /* @CA */
     "TBMOD" TABLEB
     if (new = 'YES') then do
        id = 'NONE'
        "TBDELETE" TABLEB
     end
  end
  else do
     if (from <> ' ') then
        call racfmsgs 'ERR04' msg.1 /* Permit Warning/Failed */
     else
        call racfmsgs 'ERR05' msg.1 /* Permit Failed */       /* @X1 */
  end
RETURN
/*--------------------------------------------------------------------*/
/*  Delete permit option                                              */
/*--------------------------------------------------------------------*/
DELP:
  if (id = 'NONE') then
     return
  msg    = 'You are about to delete access for 'ID
  Sure_? = RACFMSGC(msg)
  if (sure_? = 'YES') then do
     call EXCMD "REMOVE ("user") GROUP("id")"
     if (cmd_rc = 0) then                                     /* @CA */
        "TBDELETE" TABLEB
     else
        call racfmsgs 'ERR06'  msg.1   /* Permit Failed */    /* @X1 */
  end
RETURN
/*--------------------------------------------------------------------*/
/*  Exec command                                                      */
/*--------------------------------------------------------------------*/
EXCMD:
  signal off error
  parse arg cmd    /* preserve lower case for OMVS seg */     /* @D4 */
  x = OUTTRAP('msg.')
  address TSO cmd                                             /* @BR */
  cmd_rc = rc                                                 /* @BS */
  x = OUTTRAP('OFF')
  if (SETMSHOW <> 'NO') then                                  /* @CU */
     call SHOWCMD                                             /* @BB */
  if (subword(msg.1,1,1)= 'ICH11009I') |,
     (subword(msg.1,1,1)= 'ICH10006I') |,
     (subword(msg.1,1,1)= 'ICH06011I') then raclist = 'YES'
RETURN
/*--------------------------------------------------------------------*/
/*  Simulate digital certificate user profiles                        */
/*--------------------------------------------------------------------*/
DIGITAL_CERTS:                                                /* @AP */
  irrcerta.  = ''
  irrmulti.  = ''
  irrsitec.  = ''

  irrcerta.1 = 'USER=irrcerta  NAME=CERTAUTH Anchor',         /* @AP */
               'OWNER=irrcerta  CREATED=99.195'               /* @AP */
  irrcerta.3 = ' ATTRIBUTES=REVOKED'                          /* @AP */
  irrcerta.6 = ' LAST-ACCESS=UNKNOWN'                         /* @AP */

  irrmulti.1 = 'USER=irrmulti  NAME=Criteria Anchor',         /* @AP */
               'OWNER=irrmulti  CREATED=99.195'               /* @AP */
  irrmulti.3 = ' ATTRIBUTES=REVOKED'                          /* @AP */
  irrmulti.6 = ' LAST-ACCESS=UNKNOWN'                         /* @AP */

  irrsitec.1 = 'USER=irrsitec  NAME=SITE Anchor',             /* @AP */
               'OWNER=irrsitec  CREATED=99.195'               /* @AP */
  irrsitec.3 = ' ATTRIBUTES=REVOKED'                          /* @AP */
  irrsitec.6 = ' LAST-ACCESS=UNKNOWN'                         /* @AP */
RETURN                                                        /* @AP */
/*--------------------------------------------------------------------*/
/*  Display RACF command and return code                         @BB  */
/*--------------------------------------------------------------------*/
SHOWCMD:                                                      /* @BB */
  IF (SETMSHOW = "BOTH") | (SETMSHOW = "DISPLAY") THEN DO     /* @CV */
     PARSE VAR CMD MSG1   60 MSG2 121 MSG3 181 MSG3A,         /* @D8 */
               241 MSG3B 301 MSG3C                            /* @D8 */
     MSG4 = "Return code = "cmd_rc                            /* @D8 */
     "ADDPOP ROW(6) COLUMN(4)"                                /* @BB */
     if (MSG3A = "") THEN                                     /* @DA */
        "DISPLAY PANEL("PANELM2")"                            /* @D4 */
     else                                                     /* @DA */
        "DISPLAY PANEL("PANELM3")"                            /* @D4 */
     "REMPOP"                                                 /* @BB */
  END                                                         /* @CU */
  IF (SETMSHOW = "BOTH") | (SETMSHOW = "LOG") THEN DO         /* @CV */
     zerrsm = "RACFADM "REXXPGM" RC="cmd_rc                   /* @DU */
     zerrlm = cmd                                             /* @CU */
     'log msg(isrz003)'                                       /* @CU */
  END                                                         /* @CU */
RETURN                                                        /* @BB */
/*--------------------------------------------------------------------*/
/*  Create table 'A'                                             @BE  */
/*--------------------------------------------------------------------*/
CREATE_TABLEA:                                                /* @BE */
  action    = ''
  seconds   = TIME('S')
  "TBCREATE" TABLEA ,
       "KEYS(USER) NAMES(ACTION NAME OWNER DEFGRP DATELGN DATECRE",
                        "REVOKED ATTR TSOUSER DATA ATTR2)",
                        "REPLACE NOWRITE"
  cmd = "SEARCH FILTER("RFILTER") CLASS("rclass")"            /* @BB */
  x = OUTTRAP('var.')
  address TSO cmd                                             /* @BB */
  cmd_rc = rc                                                 /* @BS */
  x = OUTTRAP('OFF')
  if (SETMSHOW <> 'NO') then                                  /* @CU */
     call SHOWCMD                                             /* @BB */
  if (SETGSTAP <> "") THEN                                    /* @DY */
     INTERPRET "RECNUM = var.0*."SETGSTAP"%1"                 /* @DY */
  Do i = 1 to var.0
     temp = var.i
     USER = SUBWORD(temp,1,1)
     t    = INDEX(temp,g)
     if (t > 0) then nop
     else do
        msgr = SUBWORD(temp,1,1)
        Select
           when (msgr = 'ICH31005I') then do
                USER = 'NONE'        /* No USERs */
           end
           when (msgr = 'ICH31009I') then do
                USER = 'INVALID'     /* Bad filter */
                call racfmsgs 'ERR08' msg.1                   /* @X1 */
           end
           when (msgr = 'ICH31012I') then do
                USER = 'INVALID'     /* Bad filter */
                call racfmsgs 'ERR08' msg.1                   /* @X1 */
           end
           when (msgr = 'ICH31014I') then do
                USER = 'INVALID'     /* Bad filter */
                call racfmsgs 'ERR08' msg.1                   /* @X1 */
           end
           when (msgr = 'ICH31016I') then do
                USER = 'INVALID'     /* Bad filter */
                call racfmsgs 'ERR08' msg.1                   /* @X1 */
           end
           when (msgr = 'ICH31017I') then do
                USER = 'INVALID'     /* Bad filter */
                call racfmsgs 'ERR08' msg.1                   /* @X1 */
           end
           when (msgr = 'ICH31018I') then do
                USER = 'INVALID'     /* Bad filter */
                call racfmsgs 'ERR08' msg.1                   /* @X1 */
           end
           when (msgr = 'IKJ56716I') then do
                USER = 'INVALID'     /* Bad filter */
                call racfmsgs 'ERR08' msg.1                   /* @X1 */
           end
           when (substr(msgr,1,6) = 'ICH310') then do
                call racfmsgs 'ERR09' msg.1                   /* @X1 */
           end
           otherwise nop
        End  /* Select */
     end  /* Else */
     /*---------------------------------------------*/
     /* Display number of users retrieved          -*/
     /*---------------------------------------------*/
     IF (SETGSTA = "") THEN DO                                /* @DY */
        IF (RECNUM <> 0) THEN                                 /* @DY */
           IF (I//RECNUM = 0) THEN DO                         /* @DY */
              n1 = i; n2 = var.0                              /* @DY */
              pct = ((n1/n2)*100)%1'%'                        /* @DY */
              "control display lock"                          /* @DY */
              "display msg(RACF012)"                          /* @E3 */
           END                                                /* @DY */
     END                                                      /* @DY */
     ELSE DO
        IF (SETGSTA <> 0) THEN                                /* @DY */
           IF (I//SETGSTA = 0) THEN DO                        /* @AZ */
              n1 = i; n2 = var.0
              pct = ((n1/n2)*100)%1'%'                        /* @DY */
              "control display lock"
              "display msg(RACF012)"                          /* @E3 */
           END                                                /* @AZ */
     END
     /*---------------------------------------------*/
     /* Get further info                           -*/
     /*---------------------------------------------*/
     call GETD
     "TBMOD" TABLEA
  end  /* Do i=1 to var.0 */

  sort     = 'USER,C,A'                                       /* @EE */
  sortuser = 'D'; sortname = 'A'         /* Sort order */     /* @EE */
  sortdefg = 'A'; sortdate = 'D'                              /* @EE */
  sortowne = 'A'; sortrevo = 'D'                              /* @EE */
  sortattr = 'D'; sorttsou = 'D'                              /* @EE */
  CLRUSER  = "TURQ" ; CLRNAME = "GREEN"  /* Col colors */     /* @EE */
  CLRDEFG  = "GREEN"; CLRDATE = "GREEN"                       /* @EE */
  CLROWNE  = "GREEN"; CLRREVO = "GREEN"                       /* @EE */
  CLRATTR  = "GREEN"; CLRTSOU = "GREEN"                       /* @EE */
  "TBSORT " TABLEA "FIELDS("sort")"                           /* @EE */
  "TBTOP  " TABLEA                                            /* @EE */
RETURN                                                        /* @BE */
/*--------------------------------------------------------------------*/
/*  Add new profile                                              @DT  */
/*--------------------------------------------------------------------*/
@ADDD:                                                        /* @D4 */
  action = '*Add'                                             /* @E7 */
  if (SETTPSWD = "") then                                     /* @E9 */
     pswd = newpswd()                                         /* @E1 */
  else                                                        /* @E8 */
     pswd = SETTPSWD                                          /* @E9 */
  "DISPLAY PANEL("PANEL06")"                                  /* @DS */
  if (rc = 8) then                                            /* @D4 */
     return                                                   /* @D4 */
  if (pswd = '') then                                         /* @DE */
     pswd = user                                              /* @DE */
  if SETMPHRA = 'YES' then                                    /* @EQ */
     add1 = "ADDUSER "user" OWNER("bowner") PHRASE('"pswd"')" /* @EQ */
  else                                                        /* @EQ */
     add1 = "ADDUSER "user" OWNER("bowner") PASSWORD("pswd")" /* @EQ */
                                                              /* @EQ */
  add2 = ' DFLTGRP('defgrp') NAME('''name''') ' attr          /* @EQ */
  cmd = add1 add2                                             /* @EQ */
  if (ohome||oprogram = '') then                              /* @D4 */
     nop                                                      /* @D4 */
  else do                                                     /* @D4 */
     parse value '' with o1 o2                                /* @D4 */
     cmd = cmd||,                                             /* @D4 */
           ' OMVS('                                           /* @D4 */
           if ohome    <> '' then                             /* @ER */
              o1 = "HOME('"ohome"')"                          /* @ER */
           if oprogram <> '' then                             /* @ER */
              o2 = "PROGRAM('"oprogram"')"                    /* @ER */
           cmd = cmd||o1 o2 'AUTOUID'||,                      /* @D4 */
           ')'                                                /* @D4 */
  end                                                         /* @D4 */
  if (tsoproc||tsoacct||tsosize||tsounit = '') then           /* @D4 */
     nop                                                      /* @D4 */
  else do                                                     /* @D4 */
     parse value '' with t1 t2 t3 t4                          /* @D4 */
     cmd = cmd||,                                             /* @D4 */
           ' TSO('                                            /* @D4 */
           if tsoproc <> '' then t1 = 'PROC('tsoproc')'       /* @D4 */
           if tsoacct <> '' then t2 = 'ACCTNUM('tsoacct')'    /* @D4 */
           if tsosize <> '' then t3 = 'SIZE('tsosize')'       /* @D4 */
           if tsounit <> '' then t4 = 'UNIT('tsounit')'       /* @D4 */
           cmd = cmd||t1 t2 t3 t4||,                          /* @D4 */
           ')'                                                /* @D4 */
    end                                                       /* @D4 */
  if (copclass||copident||copprty||ctimeout = '') then        /* @D4 */
     nop                                                      /* @D4 */
  else do                                                     /* @D4 */
     parse value '' with c1 c2 c3 c4                          /* @D4 */
     cmd = cmd||,                                             /* @D4 */
           ' CICS('                                           /* @D4 */
           if copclass <> '' then c1 = 'OPCLASS('copclass')'  /* @D4 */
           if copident <> '' then c2 = 'OPIDENT('copident')'  /* @D4 */
           if copprty  <> '' then c3 = 'OPPRTY('copprty')'    /* @D4 */
           if ctimeout <> '' then c4 = 'TIMEOUT('ctimeout')'  /* @D4 */
           cmd = cmd||c1 c2 c3 c4||,                          /* @D4 */
           ')'                                                /* @D4 */
  end                                                         /* @D4 */
  if (ddatacls||dmgmtcls||dstorcls = '') then                 /* @D4 */
     nop                                                      /* @D4 */
  else do                                                     /* @D4 */
     parse value '' with d1 d2 d3                             /* @D4 */
     cmd = cmd||,                                             /* @D4 */
           ' DFP('                                            /* @D4 */
           if ddatacls <> '' then d1 = 'DATACLAS('ddatacls')' /* @D4 */
           if dmgmtcls <> '' then d2 = 'MGMTCLAS('dmgmtcls')' /* @D4 */
           if dstorcls <> '' then d3 = 'STORCLAS('dstorcls')' /* @D4 */
           cmd = cmd||d1 d2 d3||,                             /* @D4 */
           ')'                                                /* @D4 */
  end                                                         /* @D4 */
  if (idata = '') then                                        /* @EO */
     nop                                                      /* @EO */
  else                                                        /* @EO */
     cmd = cmd||' DATA('''idata''') '                         /* @EO */
  call excmd cmd                                              /* @D4 */
  if (cmd_rc > 0) then do                                     /* @DL */
     call racfmsgs ERR01 msg.1 /* Add failed */               /* @X1 */
     return                                                   /* @D6 */
  end                                                         /* @DL */
  cmd_rc = RACFUSRT('ADDD' user tsoproc,                      /* @DL */
           tsoacct defgrp bowner)                             /* @D4 */
  if (cmd_rc > 0) then do                                     /* @DL */
     call racfmsgs ERR01 msg.1   /* Add failed */             /* @X1 */
     return                                                   /* @D6 */
  end                                                         /* @DL */
  call @chkattr                                               /* @D4 */
  "TBMOD" TABLEA "ORDER"                                      /* @EF */
  call disd /* Connect basic group */                         /* @D4 */
RETURN                                                        /* @D4 */
/*--------------------------------------------------------------------*/
/*  Generate password                                            @E1  */
/*--------------------------------------------------------------------*/
NEWPSWD:                                                      /* @E1 */
  /* No vowels, or "V" or "Z" */                              /* @E1 */
  choices  = 'BCDFGHJKLMNPQRSTWXYbcdfghjklmnpqrstwxy'         /* @E5 */
  chars.   = ''                                               /* @E1 */
  password = ''                                               /* @E1 */
  /* Initialize stem variables */                             /* @E1 */
  do n = 1 to length(choices)                                 /* @E1 */
     chars.n = substr(choices,n,1)                            /* @E1 */
  end                                                         /* @E1 */
  /* n character password */                                  /* @EQ */
  psize = 6                                                   /* @EQ */
  do forever                                                  /* @E1 */
     pick = random(1,length(choices))                         /* @E1 */
     /* No repeating characters */                            /* @E1 */
     if (pos(chars.pick,password) > 0) then                   /* @E1 */
        nop                                                   /* @E1 */
     else                                                     /* @E1 */
        password = password||chars.pick                       /* @E1 */
     if (length(password) > (psize-1)) then                   /* @EQ */
        leave                                                 /* @E1 */
  end                                                         /* @E1 */
  /* Plug in 1 numeric character */                           /* @E1 */
  number   = random(1,9)                                      /* @E1 */
  place    = random(2,psize)                                  /* @EQ */
  password = overlay(number,password,place,1)                 /* @E1 */
RETURN password                                               /* @E1 */
/*--------------------------------------------------------------------*/
/*  Change profile                                               @DT  */
/*--------------------------------------------------------------------*/
@CHGD:                                                        /* @D4 */
  action = "*Change"                                          /* @E7 */
  "DISPLAY PANEL("PANEL06")"                                  /* @D4 */
  if (rc = 8) then                                            /* @D4 */
     return                                                   /* @D4 */
  call outtrap 'x.'                                           /* @X1 */
  address tso 'lu' user 'omvs'                                /* @X1 */
  call outtrap 'off'                                          /* @X1 */
  autouid = 'AUTOUID'                                         /* @X1 */
  do xi = 1 to x.0                                            /* @X1 */
     if left(x.xi,4) = 'UID=' then autouid = ''               /* @X1 */
     end                                                      /* @X1 */
  cmd = 'ALTUSER 'user' OWNER('bowner')'||,                   /* @D4 */
        ' DFLTGRP('defgrp') NAME('''name''') ' attr           /* @D4 */
  if (ohome||oprogram = '') then                              /* @D4 */
     nop                                                      /* @D4 */
  else do                                                     /* @D4 */
     parse value '' with o1 o2                                /* @D4 */
     cmd = cmd||,                                             /* @D4 */
           ' OMVS('                                           /* @D4 */
           if ohome    <> '' then o1 = 'HOME('ohome')'        /* @D4 */
           if oprogram <> '' then o2 = 'PROGRAM('oprogram')'  /* @D4 */
           cmd = cmd||o1 o2 autouid')'                        /* @X1 */
  end                                                         /* @D4 */
  if (tsoproc||tsoacct||tsosize||tsounit = '') then           /* @D4 */
     nop                                                      /* @D4 */
  else do                                                     /* @D4 */
      parse value '' with t1 t2 t3 t4                         /* @D4 */
      cmd = cmd||,                                            /* @D4 */
          ' TSO('                                             /* @D4 */
          if (tsoproc <> '') then t1 = 'PROC('tsoproc')'      /* @D4 */
          if (tsoacct <> '') then t2 = 'ACCTNUM('tsoacct')'   /* @D4 */
          if (tsosize <> '') then t3 = 'SIZE('tsosize')'      /* @D4 */
          if (tsounit <> '') then t4 = 'UNIT('tsounit')'      /* @D4 */
          cmd = cmd||t1 t2 t3 t4||,                           /* @D4 */
          ')'                                                 /* @D4 */
    end                                                       /* @D4 */
  if (copclass||copident||copprty||ctimeout = '') then        /* @D4 */
     nop                                                      /* @D4 */
  else do                                                     /* @D4 */
     parse value '' with c1 c2 c3 c4                          /* @D4 */
     cmd = cmd||,                                             /* @D4 */
         ' CICS('                                             /* @D4 */
         if (copclass <> '') then c1 = 'OPCLASS('copclass')'  /* @D4 */
         if (copident <> '') then c2 = 'OPIDENT('copident')'  /* @D4 */
         if (copprty  <> '') then c3 = 'OPPRTY('copprty')'    /* @D4 */
         if (ctimeout <> '') then c4 = 'TIMEOUT('ctimeout')'  /* @D4 */
         cmd = cmd||c1 c2 c3 c4||,                            /* @D4 */
         ')'                                                  /* @D4 */
  end                                                         /* @D4 */
  if (ddatacls||dmgmtcls||dstorcls = '') then                 /* @D4 */
     nop                                                      /* @D4 */
  else do                                                     /* @D4 */
     parse value '' with d1 d2 d3                             /* @D4 */
     cmd = cmd||,                                             /* @D4 */
         ' DFP('                                              /* @D4 */
         if (ddatacls <> '') then d1 = 'DATACLAS('ddatacls')' /* @D4 */
         if (dmgmtcls <> '') then d2 = 'MGMTCLAS('dmgmtcls')' /* @D4 */
         if (dstorcls <> '') then d3 = 'STORCLAS('dstorcls')' /* @D4 */
         cmd = cmd||d1 d2 d3||,                               /* @D4 */
         ')'                                                  /* @D4 */
  end                                                         /* @D4 */
  if idata = '' then                                          /* @EO */
     nop                                                      /* @EO */
  else                                                        /* @EO */
     cmd = cmd||' DATA('''idata''') '                         /* @EO */
  call excmd cmd                                              /* @D4 */
  if (cmd_rc > 0) then do                                     /* @DL */
     call racfmsgs ERR07 msg.1   /* Changed failed */         /* @X1 */
     return                                                   /* @D6 */
  end                                                         /* @DL */
  call @chkattr                                               /* @D4 */
  /*- Authorize logon and account to default group  -*/       /* @D4 */
  if (tsouser = 'YES') then do                                /* @D4 */
     cmd = "PE "tsoacct" CLASS(ACCTNUM) ACC(READ)",           /* @D4 */
           "ID("defgrp")"                                     /* @D4 */
     call excmd cmd                                           /* @D4 */
     if (cmd_rc > 0) then                                     /* @DL */
        call racfmsgs ERR03  msg.1  /* Permit failed */       /* @X1 */
     cmd = "PE "tsoproc" CLASS(TSOPROC) ACC(READ)",           /* @D4 */
           "ID("defgrp")"                                     /* @D4 */
     call excmd cmd                                           /* @D4 */
     if (cmd_rc > 0) then                                     /* @DL */
        call racfmsgs ERR03   msg.1 /* Permit failed */       /* @X1 */
  end                                                         /* @D4 */
  "TBMOD" TABLEA                                              /* @D4 */
RETURN                                                        /* @D4 */
/*--------------------------------------------------------------------*/
/*  Delete profile attributes, when 'Admin RACF API = Y'         @D4  */
/*--------------------------------------------------------------------*/
ALTD:                                                         /* @E6 */
  action = "*Alter"                                           /* @E6 */
  "DISPLAY PANEL("PANEL05")"                                  /* @DS */
  if (rc = 8) then                                            /* @D4 */
     return                                                   /* @D4 */
  cmd = 'ALTUSER 'user nos                                    /* @D4 */
  call excmd cmd                                              /* @D4 */
  call @chkattr                                               /* @D4 */
  "TBMOD" TABLEA                                              /* @D4 */
RETURN                                                        /* @D4 */
/*--------------------------------------------------------------------*/
/*  Chk TSO segment/REVOKED/ATTRIB, when 'Admin RACF API = Y'    @D4  */
/*--------------------------------------------------------------------*/
@CHKATTR:                                                     /* @D4 */
  if (SETMIRRX = 'NO') then do                                /* @DP */
    call GETD                                                 /* @DP */
    RETURN                                                    /* @DP */
    end                                                       /* @DP */
  cmd = "IRRXUTIL('EXTRACT','USER','"user"','RACF',)"         /* @DC */
  interpret 'cmd_rc = 'cmd                                    /* @D5 */
  cmd_rc = WORD(cmd_rc,1)                                     /* @DW */
  if (SETMSHOW <> 'NO') then                                  /* @D5 */
     call SHOWCMD                                             /* @D5 */
  if (WORD(cmd_rc,1) <> 0) then do                            /* @D5 */
     call racfmsgs ERR20 msg.1                                /* @X1 */
     return                                                   /* @D4 */
  end                                                         /* @D5 */
  tsouser = 'NO'                                              /* @D4 */
  do seg=1 to racf.0                                          /* @D4 */
     if (racf.seg = 'TSO') then                               /* @D4 */
        tsouser = 'YES'                                       /* @D4 */
  end                                                         /* @D4 */
  if (racf.base.revokefl.1 = 'TRUE') then                     /* @D4 */
     revoked = 'YES'                                          /* @D4 */
  else                                                        /* @D4 */
     revoked = 'NO'                                           /* @D4 */
  if (racf.base.special.1 = 'TRUE') |,                        /* @D4 */
     (racf.base.oper.1    = 'TRUE') |,                        /* @D4 */
     (racf.base.grpacc.1  = 'TRUE') |,                        /* @D4 */
     (racf.base.auditor.1 = 'TRUE') |,                        /* @D4 */
     (racf.base.roaudit.1 = 'TRUE') |,                        /* @D4 */
     (racf.base.rest.1    = 'TRUE') |,                        /* @D4 */
     (racf.base.adsp.1    = 'TRUE') then                      /* @D4 */
     attr2 = 'YES'                                            /* @D4 */
  else                                                        /* @D4 */
     attr2 = 'NO'                                             /* @D4 */
RETURN                                                        /* @D4 */
/*--------------------------------------------------------------------*/
/*  Save table to dataset                                        @EK  */
/*--------------------------------------------------------------------*/
DO_SAVE:                                                      /* @EK */
  X = MSG("OFF")                                              /* @EK */
  "ADDPOP COLUMN(40)"                                         /* @EK */
  "VGET (RACFSDSN RACFSMBR RACFSFIL RACFSREP) PROFILE"        /* @EL */
  IF (RACFSDSN = "") THEN         /* SAve - Dataset Name  */  /* @EM */
     RACFSDSN = USERID()".RACFADM.REPORTS"                    /* @EK */
  IF (RACFSFIL = "") THEN         /* SAve - As (TXT/CVS)  */  /* @EM */
     RACFSFIL = "T"                                           /* @EL */
  IF (RACFSREP = "") THEN         /* SAve - Replace (Y/N) */  /* @EM */
     RACFSREP = "N"                                           /* @EK */
                                                              /* @EK */
  DO FOREVER                                                  /* @EK */
     "DISPLAY PANEL("PANELS1")"                               /* @EK */
     IF (RC = 08) THEN DO                                     /* @EK */
        "REMPOP"                                              /* @EK */
        RETURN                                                /* @EK */
     END                                                      /* @EK */
     RACFSDSN = STRIP(RACFSDSN,,"'")                          /* @EK */
     RACFSDSN = STRIP(RACFSDSN,,'"')                          /* @EK */
     RACFSDSN = STRIP(RACFSDSN)                               /* @EK */
     SYSDSORG = ""                                            /* @EK */
     X = LISTDSI("'"RACFSDSN"'")                              /* @EK */
     IF (SYSDSORG = "") | (SYSDSORG = "PS"),                  /* @EK */
      | (SYSDSORG = "PO") THEN                                /* @EK */
        NOP                                                   /* @EK */
     ELSE DO                                                  /* @EK */
        RACFSMSG = "Not PDS/Seq File"                         /* @EK */
        RACFLMSG = "The dataset specified is not",            /* @EK */
                  "a partitioned or sequential",              /* @EK */
                  "dataset, please enter a valid",            /* @EK */
                  "dataset name."                             /* @EK */
       "SETMSG MSG(RACF011)"                                  /* @EK */
       ITERATE                                                /* @EK */
     END                                                      /* @EK */
     IF (SYSDSORG = "PS") & (RACFSMBR <> "") THEN DO          /* @EK */
        RACFSMSG = "Seq File - No mbr"                        /* @EK */
        RACFLMSG = "This dataset is a sequential",            /* @EK */
                  "file, please remove the",                  /* @EK */
                  "member name."                              /* @EK */
       "SETMSG MSG(RACF011)"                                  /* @EK */
       ITERATE                                                /* @EK */
     END                                                      /* @EK */
     IF (SYSDSORG = "PO") & (RACFSMBR = "") THEN DO           /* @EK */
        RACFSMSG = "PDS File - Need Mbr"                      /* @EK */
        RACFLMSG = "This dataset is a partitioned",           /* @EK */
                  "dataset, please include a member",         /* @EK */
                  "name."                                     /* @EK */
       "SETMSG MSG(RACF011)"                                  /* @EK */
       ITERATE                                                /* @EK */
     END                                                      /* @EK */
                                                              /* @EK */
     IF (RACFSMBR = "") THEN                                  /* @EK */
        TMPDSN = RACFSDSN                                     /* @EK */
     ELSE                                                     /* @EK */
        TMPDSN = RACFSDSN"("RACFSMBR")"                       /* @EK */
     DSNCHK = SYSDSN("'"TMPDSN"'")                            /* @EK */
     IF (DSNCHK = "OK" & RACFSREP = "N") THEN DO              /* @EK */
        RACFSMSG = "DSN/MBR Exists"                           /* @EK */
        RACFLMSG = "Dataset/member already exists. ",         /* @EK */
                  "Please type in "Y" to replace file."       /* @EK */
        "SETMSG MSG(RACF011)"                                 /* @EK */
        ITERATE                                               /* @EK */
     END                                                      /* @EK */
     LEAVE                                                    /* @EK */
  END                                                         /* @EK */
  "REMPOP"                                                    /* @EK */
  "VPUT (RACFSDSN RACFSMBR RACFSFIL RACFSREP) PROFILE"        /* @EL */
                                                              /* @EK */
ADDRESS TSO                                                   /* @EK */
  IF (RACFSREP = "Y" & RACFSMBR = "") |,                      /* @EK */
     (DSNCHK <> "OK" & DSNCHK <> "MEMBER NOT FOUND"),         /* @EK */
     THEN DO                                                  /* @EK */
     "DELETE '"RACFSDSN"'"                                    /* @EK */
     IF (RACFSMBR = "") THEN                                  /* @EK */
        "ALLOC  FI(ISPFILE) DA('"RACFSDSN"') NEW",            /* @EK */
            "REUSE SP(1 1) CYLINDER UNIT(SYSALLDA)",          /* @EN */
            "LRECL(80) RECFM(F B)"                            /* @EK */
     ELSE                                                     /* @EK */
        "ALLOC  FI(ISPFILE) DA('"RACFSDSN"') NEW",            /* @EK */
            "REUSE SP(1 1) CYLINDER UNIT(SYSALLDA)",          /* @EN */
            "LRECL(80) RECFM(F B)",                           /* @EK */
            "DSORG(PO) DSNTYPE(LIBRARY,2)"                    /* @EK */
  END                                                         /* @EK */
  ELSE                                                        /* @EK */
     "ALLOC  FI(ISPFILE) DA('"RACFSDSN"') SHR REUSE"          /* @EK */
                                                              /* @EK */
ADDRESS ISPEXEC                                               /* @EK */
  "FTOPEN"                                                    /* @EK */
  "FTINCL "TMPSKELT                                           /* @EK */
  IF (RACFSMBR = "") THEN                                     /* @EK */
     "FTCLOSE"                                                /* @EK */
  ELSE                                                        /* @EK */
     "FTCLOSE NAME("RACFSMBR")"                               /* @EK */
  ADDRESS TSO "FREE FI(ISPFILE)"                              /* @EK */
                                                              /* @EK */
  SELECT                                                      /* @EK */
     WHEN (SETGDISP = "VIEW") THEN                            /* @EK */
          "VIEW DATASET('"RACFSDSN"') MACRO("EDITMACR")"      /* @EK */
     WHEN (SETGDISP = "EDIT") THEN                            /* @EK */
          "EDIT DATASET('"RACFSDSN"') MACRO("EDITMACR")"      /* @EK */
     OTHERWISE                                                /* @EK */
          "BROWSE DATASET('"RACFSDSN"')"                      /* @EK */
  END                                                         /* @EK */
  X = MSG("ON")                                               /* @EK */
                                                              /* @EK */
RETURN                                                        /* @EK */
