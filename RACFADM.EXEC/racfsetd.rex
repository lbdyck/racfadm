/*%NOCOMMENT====================* REXX *==============================*/
/*  PURPOSE:  RACFADM - Settings - Executes when RACFADM is invoked   */
/*--------------------------------------------------------------------*/
/*  NOTES:    1) This member will read in $DEFSETG to obtain the      */
/*               default Settings (Option 0) for new users and if     */
/*               necessary, force a refresh of a sections variables   */
/*               (General, Management, etc.) by setting the variable  */
/*               'SETR??? = Y'                                        */
/*                                                                    */
/*            2) To override these settings, create a member called   */
/*               $DEFSITE and define/set any variables                */
/*               - The $DEFSITE member is optional, but if it exists, */
/*                 it will be read and override any settings defined  */
/*                 in member $DEFSETG                                 */
/*               - This will prevent from having to update the        */
/*                 $DEFSETG member everytime a new version of         */
/*                 RACFADM is installed                               */
/*                                                                    */
/*            3) The following are the naming standard for variables  */
/*               used to save the user's Settings (Option 0)          */
/*               - Syntax                                             */
/*                   SET#????                                         */
/*               - Where                                              */
/*                   SET .... Settings (Option 0)                     */
/*                   # ...... G=General, M=Management, T=Adding TSO   */
/*                            Userid, P=Program/Panel (Load, REXX or  */
/*                            CLIST member), D=Dataset, J=JCL and     */
/*                            R=Refresh                               */
/*                   ???? ... Field name, any characters and for      */
/*                            Refresh variables (4th chr = R) the     */
/*                            variables (4th chr = R) the section     */
/*                            name (GEN, MGT, TSO, MVS and IBM)       */
/*               - The REXX programs and panels will translate the    */
/*                 abbreviated contents to its full word, in hopes    */
/*                 of making it easier to understand/maintain the     */
/*                 code, for example: Y, will be translated to YES    */
/*                                                                    */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @AN  201220  RACFA    Fix/deleted code for SETTPSWD                */
/* @AM  201130  RACFA    Validate GDG base, without recalling gens    */
/* @AL  200720  LBD      Fix to honor lowercase password              */
/* @AK  200702  RACFA    Reduced lines of code, easier to maintain    */
/* @AJ  200702  RACFA    Fix refreshing SHOWMVS variables             */
/* @AI  200702  RACFA    Allow symbolic in dsnames                    */
/* @AH  200627  RACFA    Validate RACFMSG backup log DSN is valid     */
/* @AG  200627  RACFA    Upper case record                            */
/* @AF  200627  RACFA    Chg LOG to MSG                               */
/* @AE  200627  RACFA    Chg SLOG to LOG and chk cols 5-7, was 4-8    */
/* @AD  200625  RACFA    Fixed refreshing SDSF Log file file          */
/* @AC  200624  RACFA    Chg/standardize site variable for SDSF log   */
/* @AB  200620  RACFA    Add code to refresh RACFMSGs OPERLOG Bkp dsn */
/* @AA  200617  RACFA    Add code to refresh RACFRPTs IRRDBU00 dsn    */
/* @A9  200617  RACFA    Fix refreshing several sections (TSO/MGT/etc)*/
/* @A8  200528  RACFA    Allow forcing redefining a sections variables*/
/* @A7  200523  LBD      Allow a site override mbr, called $DEFSITE   */
/* @A6  200522  RACFA    Added DROP REC.                              */
/* @A5  200519  RACFA    Validate SHOWMVS DSN exit/valid              */
/* @A4  200512  RACFA    Validate IBM RACF DSNs exist/valid           */
/* @A3  200512  RACFA    Moved chking/defining var W3 out of SELECT   */
/* @A2  200511  RACFA    Remove single/double quotes                  */
/* @A1  200511  RACFA    Added SETMIBM                                */
/* @A0  200501  RACFA    Created REXX                                 */
/*====================================================================*/
MBRDSETG    = "$DEFSETG"   /* Default Settings member      */
MBRDSITE    = "$DEFSITE"   /* Site Default Overrides       */ /* @A7 */
DDNAME      = 'RACFA'RANDOM(0,999) /* Unique ddname        */
NEWUSER     = 'N'                  /* New user?            */ /* @A8 */

ADDRESS ISPEXEC
  'vget (SETMADMN) profile'
  if (setmadmn = "") then                                     /* @A8 */
     newuser = 'Y'                                            /* @A8 */

  "QLIBDEF ISPPLIB TYPE(DATASET) ID(DSNAMEW)"                 /* @A7 */
  if (RC > 0) then
     call RACFMSGS ERR19
  DSNAME  = "'"STRIP(DSNAMEW,,"'")"("MBRDSETG")'"             /* @A7 */
  SITEDSN = "'"STRIP(DSNAMEW,,"'")"("MBRDSITE")'"             /* @A7 */

ADDRESS TSO
  "ALLOC FI("DDNAME") DA("DSNAME") SHR REUSE"
  "EXECIO * DISKR "DDNAME" (STEM REC. FINIS"
  "FREE FI("DDNAME")"

/* ------------------------------- *                          /* @A7 */
 | Check for Site Over-Ride Member |                          /* @A7 */
 | And if so combine into REC. stem|                          /* @A7 */
 * ------------------------------- */                         /* @A7 */
 if (sysdsn(sitedsn) = 'OK') then do                          /* @A7 */
    "ALLOC FI("DDNAME") DA("SITEDSN") SHR REUSE"              /* @A7 */
    "EXECIO * DISKR "DDNAME" (STEM site. FINIS"               /* @A7 */
    "FREE FI("DDNAME")"                                       /* @A7 */
    oc = rec.0                                                /* @A7 */
    do i = 1 to site.0                                        /* @A7 */
       oc = oc + 1                                            /* @A7 */
       rec.oc = site.i                                        /* @A7 */
    end                                                       /* @A7 */
    rec.0 = oc                                                /* @A7 */
  end                                                         /* @A7 */
  drop site.                                                  /* @A7 */

ADDRESS ISPEXEC
  DO J = 1 TO REC.0
     IF (SUBSTR(REC.J,1,1) = "*") THEN ITERATE
     PARSE UPPER VAR REC.J W1 W2 W3 W4 .                      /* @AG */
     IF (W3 = "/*") THEN W3 = ""                              /* @AG */
     IF (W3 = "Y")  THEN W3 = "YES"                           /* @AG */
     IF (W3 = "N")  THEN W3 = "NO"                            /* @AG */
     CKCHR4    = SUBSTR(W1,4,1)                               /* @AK */
     CKCHR4TO7 = SUBSTR(W1,4,4)                               /* @AK */
     SELECT
        WHEN (W1 = "SETGDISP") THEN
             SELECT
                WHEN (W3 = "B")  THEN W3 = "BROWSE"           /* @A7 */
                WHEN (W3 = "E")  THEN W3 = "EDIT"             /* @A7 */
                WHEN (W3 = "V")  THEN W3 = "VIEW"             /* @A7 */
                OTHERWISE NOP
             END
        WHEN (W1 = "SETMSHOW") THEN
             SELECT
                WHEN (W3 = "D")  THEN W3 = "DISPLAY"          /* @A7 */
                WHEN (W3 = "L")  THEN W3 = "LOG"              /* @A7 */
                WHEN (W3 = "B")  THEN W3 = "BOTH"             /* @A7 */
                OTHERWISE NOP
             END
        WHEN (W1 = "SETMTRAC") THEN
             SELECT
                WHEN (W3 = "L")  THEN W3 = "LABELS"           /* @A7 */
                WHEN (W3 = "P")  THEN W3 = "PROGRAMS"         /* @A7 */
                WHEN (W3 = "R")  THEN W3 = "RESULTS"          /* @A7 */
                OTHERWISE NOP
             END
        WHEN (CKCHR4 = "D") & (W3 <> "") THEN DO              /* @AK */
             PARSE VAR W3 DSN1 "&" SYMBOL "." DSN2            /* @AK */
             SYMBVAL = MVSVAR("SYMDEF",SYMBOL)                /* @AK */
             TSTW3   = DSN1""SYMBVAL""DSN2                    /* @AK */
             PARSE VAR TSTW3 TSTW3 "(" .                      /* @AK */
             TSTW3   = STRIP(TSTW3,,"'")                      /* @AK */
             TSTW3   = STRIP(TSTW3,,'"')                      /* @AK */
             X = OUTTRAP("LCRPT.",1)                          /* @AM */
             ADDRESS TSO "LISTCAT ENT('"TSTW3"')"             /* @AM */
             X = OUTTRAP("OFF")                               /* @AM */
             PARSE VAR LCRPT.1 W1 W2 W3 W4                    /* @AM */
             IF (W1 <> "GDG") & (W2 <> "BASE") THEN           /* @AM */
                IF (SYSDSN("'"TSTW3"'") <> "OK") THEN DO      /* @AM */
                   RACFSMSG = "$DEFSETG - Invalid DSN"        /* @AM */
                   RACFLMSG = "The variable "W1" has a",      /* @AM */
                              "dataset defined to it, that",  /* @AM */
                              "DOES NOT EXIST, DSN="TSTW3".", /* @AM */
                              " Please update/fix the site",  /* @AM */
                              "default settings in the",      /* @AM */
                              "panel member $DEFSETG or",     /* @AM */
                              "$DEFSITE."                     /* @AM */
                   "SETMSG MSG(RACF011)"                      /* @AM */
                END                                           /* @AM */
             IF (CKCHR4TO7 = "DMVS"),                         /* @AK */
              | (CKCHR4TO7 = "DIBM") THEN DO                  /* @AK */
                W3 = STRIP(W3,,"'")                           /* @AK */
                W3 = STRIP(W3,,'"')                           /* @AK */
             END                                              /* @AK */
        END                                                   /* @AK */
        OTHERWISE NOP
     END

     INTERPRET W1" = W3"                                      /* @A7 */
     CKCHR1TO4 = SUBSTR(W1,1,4)                               /* @A9 */
     CKCHR5TO7 = SUBSTR(W1,5,3)                               /* @AE */
     SELECT                                                   /* @A8 */
        /* Is this a variable used to Refresh?     */         /* @A8 */
        WHEN (CKCHR1TO4 = "SETR") THEN                        /* @A9 */
             CKRESVAR = W1                                    /* @A9 */
        /* Refresh 'General' variables?            */         /* @A8 */
        WHEN (CKRESVAR = "SETRGEN"),                          /* @A9 */
           & (SETRGEN = "YES") THEN                           /* @A9 */
             IF (CKCHR1TO4 = "SETG") THEN                     /* @A9 */
                INTERPRET "'VPUT ("W1") PROFILE'"             /* @A8 */
        /* Refresh 'Management' variables?         */         /* @A8 */
        WHEN (CKRESVAR = "SETRMGT"),                          /* @A9 */
           & (SETRMGT = "YES") THEN                           /* @A9 */
             IF (CKCHR1TO4 = "SETM") THEN                     /* @A9 */
                INTERPRET "'VPUT ("W1") PROFILE'"             /* @A8 */
        /* Refresh 'Adding TSO Userid' variables?  */         /* @A8 */
        WHEN (CKRESVAR = "SETRTSO"),                          /* @A9 */
           & (SETRTSO = "YES") THEN                           /* @A9 */
             IF (CKCHR1TO4 = "SETT") THEN                     /* @A9 */
                INTERPRET "'VPUT ("W1") PROFILE'"             /* @A8 */
        /* Refresh SHOWMVS program and dataset?    */         /* @A8 */
        WHEN (CKRESVAR = "SETRMVS"),                          /* @AJ */
           & (SETRMVS = "YES") THEN                           /* @A9 */
             IF (CKCHR5TO7 = "MVS") THEN                      /* @AE */
                INTERPRET "'VPUT ("W1") PROFILE'"             /* @A8 */
        /* Refresh IBM RACF panel and datasets?    */         /* @A8 */
        WHEN (CKRESVAR = "SETRIBM"),                          /* @A9 */
           & (SETRIBM = "YES") THEN                           /* @A9 */
             IF (CKCHR5TO7 = "IBM") THEN                      /* @AE */
                INTERPRET "'VPUT ("W1") PROFILE'"             /* @A8 */
        /* Refresh RACFRPTS IRRDBU00 dataset?      */         /* @AA */
        WHEN (CKRESVAR = "SETRRPT"),                          /* @AA */
           & (SETRRPT = "YES") THEN                           /* @AA */
             IF (CKCHR5TO7 = "RPT") THEN                      /* @AE */
                INTERPRET "'VPUT ("W1") PROFILE'"             /* @AA */
        /* Refresh RACFMSG variables?              */         /* @AF */
        WHEN (CKRESVAR = "SETRMSG"),                          /* @AF */
           & (SETRMSG = "YES") THEN                           /* @AE */
             IF (CKCHR5TO7 = "MSG") THEN                      /* @AF */
                INTERPRET "'VPUT ("W1") PROFILE'"             /* @AB */
        /* Not a new user?                         */         /* @A8 */
        WHEN (NEWUSER = 'N') then                             /* @A8 */
             NOP                                              /* @A8 */
        /* Must be a new user then                 */         /* @A8 */
        OTHERWISE                                             /* @A8 */
             INTERPRET "'VPUT ("W1") PROFILE'"                /* @A8 */
     END                                                      /* @A8 */
  END
  DROP REC.                                                   /* @A6 */
RETURN
