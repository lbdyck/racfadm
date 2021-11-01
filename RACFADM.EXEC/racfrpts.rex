/*%NOCOMMENT====================* REXX *==============================*/
/*  PURPOSE:  RACFADM - RACF Reports - Menu option R                  */
/*--------------------------------------------------------------------*/
/*  NOTES:    1) Will create RACF reports via a batch job using       */
/*               - IBM's DFSORT ICETOOL using IRRDBU00 unload dataset */
/*               - IBM's Data Security Monitor (DSMON)                */
/*            2) Reads in panel dataset member $REPORTS to obtain     */
/*               and display the list of reports                      */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @LD  211101  LBD      Fix EDIT on temp dataset                     */
/* @AH  200701  RACFA    Unload - GDG BASE, relative, G#V#, make (+1) */
/* @AG  200630  RACFA    Allow TSO PREFIX has HLQ in dsname           */
/* @AF  200620  RACFA    Added primary command SUBMIT                 */
/* @AE  200619  RACFA    Added line cmd 'R', remove '*'               */
/* @AD  200619  RACFA    F3 out, no disp job card, when RESET typed   */
/* @AC  200619  RACFA    If ALL rpts selected, remove others selected */
/* @AB  200619  RACFA    Init RNUM with number of rows                */
/* @AA  200619  LBD      Place all rpts selected into one job         */
/* @A9  200619  RACFA    Relocated obtaining ISPF Job card variables  */
/* @A8  200618  RACFA    Added SKELETON1 for JOB card                 */
/* @A7  200618  RACFA    Chg SKELETON1/2 to SKELETON2/3               */
/* @A6  200618  RACFA    Obtain ZLLGJOB3/4 variables                  */
/* @A5  200618  RACFA    Chg UNIT to be SYSALLDA, was SYSDA           */
/* @A4  200618  RACFA    Fix chking 1st word in job card no. 1 (Upper)*/
/* @A3  200618  RACFA    Fix when JOB card is defined, save ZCMD      */
/* @A2  200618  RACFA    Use $DEFSETG vars for temp dsn unit/space    */
/* @A1  200618  RACFA    Fixed displaying job card                    */
/* @A0  200617  RACFA    Developed REXX                               */
/*====================================================================*/
PANEL01     = "RACFRPTS"   /* Display reports              */
PANEL99     = "RACFRPTJ"   /* Define JOB card/JCL parms    */
SKELETON1   = "RACFJOB"    /* Job card                     */ /* @A8 */
SKELETON2   = "RACFRPTU"   /* RACF unload pgm (IRRDBU00)   */ /* @A7 */
SKELETON3   = "RACFRPTS"   /* RACF reports (ICETOOL/DSMON) */ /* @A7 */
TABLEA      = "RADM"RANDOM(0,9999)
DDNAME      = 'RACFA'RANDOM(0,999) /* Unique ddname        */
RPTSMBR     = "$REPORTS"   /* List of reports              */
parse source . . REXXPGM .         /* Obtain REXX pgm name */
REXXPGM     = LEFT(REXXPGM,8)
NULL        = ""                                              /* @AA */
SELECTS     = 0                                               /* @AA */

ADDRESS ISPEXEC
  "VGET (SETGDISP SETGPREF SETMSHOW SETMTRAC SETDRPTU",       /* @AG */
        "SETJRPTU SETJRPTS RACFRJCL",                         /* @A2 */
        "ZLLGJOB1 ZLLGJOB2 ZLLGJOB3 ZLLGJOB4) PROFILE"        /* @A9 */

  If (SETMTRAC <> 'NO') then do
     Say "*"COPIES("-",70)"*"
     Say "*"Center("Begin Program = "REXXPGM,70)"*"
     Say "*"COPIES("-",70)"*"
     if (SETMTRAC <> 'PROGRAMS') THEN
        interpret "Trace "SUBSTR(SETMTRAC,1,1)
  end
  IF (RACFRJCL = "") THEN
     RACFRJCL    = "Y"
  IF (SETJRPTU = "") THEN                                     /* @A2 */
     SETJRPTU = "SYSALLDA"                                    /* @A5 */
  IF (SETJRPTS = "") THEN                                     /* @A2 */
     SETJRPTS = "(CYL,(100,100))"                             /* @A2 */

  ZSCROLLD = "CSR"
  "VPUT (ZSCROLLD)"

  "QLIBDEF ISPPLIB TYPE(DATASET) ID(DSNAME)"
  if (RC > 0) then do
     call racfmsgs ERR19
     return
  end
  DSNRPTS = STRIP(DSNAME,,"'")"("RPTSMBR")"

  CALL CREATE_TABLEA

  IF (RNUM = 0) THEN DO
     RACFSMSG = "No entries in file"
     RACFSMSG = "There is are no valid entries in the",
               "dataset: "DSNRPTS
     "SETMSG MSG(RACF011)"
  END
  ELSE
     CALL DISP_PANEL

ADDRESS ISPEXEC
  "TBCLOSE "TABLEA

  If (SETMTRAC <> 'NO') then do
     Say "*"COPIES("-",70)"*"
     Say "*"Center("End Program = "REXXPGM,70)"*"
     Say "*"COPIES("-",70)"*"
  end

EXIT
/*--------------------------------------------------------------------*/
/*  Display Panel                                                     */
/*--------------------------------------------------------------------*/
DISP_PANEL:
  opta   = ' '
  xtdtop = 0
  rsels  = 0
  do forever
     if (rsels < 2) then do
        "TBTOP " TABLEA
        'tbskip' tablea 'number('xtdtop')'
        radmrfnd = 'PASSTHRU'
        'vput (radmrfnd)'
        "TBDISPL" TABLEA "PANEL("PANEL01")"
     end
     else 'tbdispl' tablea
     if (rc > 4) then leave
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
     SELECT
        When (abbrev("FIND",zcmd,1) = 1) then
             call do_finda
        When (abbrev("JOB",zcmd,1) = 1) then
             call DEFINE_JOB_CARD
        WHEN (ABBREV("LOCATE",ZCMD,1) = 1) THEN do
             if (parm <> '') then do
                locarg = parm'*'
                PARSE VAR SORT . "," . "," SEQ
                IF (SEQ = "D") THEN
                   CONDLIST = "LE"
                ELSE
                   CONDLIST = "GE"
                parse value sort with scan_field',' .
                IF (SCAN_FIELD = "DESC") THEN
                   SCAN_FIELD = "DESCCAPS"
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
                str = translate(rec name pgm desc)
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
             if (parm <> '') then
                rfilter = parm
             xtdtop   = 1
             "TBEND" TABLEA
             call CREATE_TABLEA
        END
        WHEN (ABBREV("SORT",ZCMD,1) = 1) THEN DO
             SELECT
                when (ABBREV("REC",PARM,1) = 1) then
                     call sortseq 'REC'
                when (ABBREV("NAME",PARM,1) = 1) then
                     call sortseq 'NAME'
                when (ABBREV("PROGRAM",PARM,1) = 1) then
                     call sortseq 'PGM'
                when (ABBREV("DESCRIPTION",PARM,1) = 1) then
                     call sortseq 'DESC'
                otherwise NOP
           END
           CLRREC   = "GREEN"; CLRNAME = "GREEN"
           CLRPGM   = "GREEN"; CLRDESC = "GREEN"
           PARSE VAR SORT LOCARG "," .
           INTERPRET "CLR"SUBSTR(LOCARG,1,4)" = 'TURQ'"
           "TBSORT "TABLEA" FIELDS("sort")"
           "TBTOP  "TABLEA
        END
        WHEN (ABBREV("SUBMIT",ZCMD,2) = 1) THEN DO            /* @AF */
             if (selects = 1) then do                         /* @AF */
                CALL CHK_ALL                                  /* @AF */
                IF (SUBMIT = "Y") THEN                        /* @AF */
                   CALL CREATE_JCL                            /* @AF */
                CALL CLEAR_DOIT                               /* @AF */
             END                                              /* @AF */
             else do                                          /* @AF */
                RACFSMSG = "No reports selected"              /* @AF */
                RACFLMSG = "Please select at least",          /* @AF */
                           "one report to edit or",           /* @AF */
                           "submit."                          /* @AF */
                "SETMSG MSG(RACF011)"                         /* @AF */
             end                                              /* @AF */
        END                                                   /* @AF */
        WHEN ABBREV("UNLOAD",ZCMD,1) = 1 THEN
             CALL CREATE_JCL
        otherwise NOP
     End /* Select */
     ZCMD = ""; PARM = ""
     'control display save'
     Select
        when (opta = 'S') then do                             /* @AA */
             doit = '*'                                       /* @AA */
             'tbput' tablea                                   /* @AA */
             selects = 1                                      /* @AA */
        end                                                   /* @AA */
        when (opta = 'R') then do                             /* @AE */
             doit = ' '                                       /* @AE */
             'tbput' tablea                                   /* @AE */
        end                                                   /* @AE */
        otherwise nop
     End
     'control display restore'
  END  /* Do Forever */
                                                              /* @AA */
  /*----------------------------------------------------*/    /* @AA */
  /* If any reports were selected then generate the JCL */    /* @AA */
  /*----------------------------------------------------*/    /* @AA */
  if (selects = 1) then do                                    /* @AC */
     CALL CHK_ALL                                             /* @AE */
     IF (SUBMIT = "Y") THEN                                   /* @AE */
        CALL CREATE_JCL
  END                                                         /* @AE */
                                                              /* @AA */
  "VPUT (SETDRPTU RACFRJCL) PROFILE"
RETURN
/*--------------------------------------------------------------------*/
/*  Create/populate table                                             */
/*--------------------------------------------------------------------*/
CREATE_TABLEA:
SELECTS = ""                                                  /* @AD */
ADDRESS ISPEXEC
  "TBCREATE "TABLEA" NAMES(REC DOIT NAME PGM DESC",           /* @AA */
                          "DESCCAPS) NOWRITE REPLACE"         /* @AA */
ADDRESS TSO
  "ALLOC FI("DDNAME") DA('"DSNRPTS"') SHR REUSE"
  "EXECIO * DISKR "DDNAME" (STEM REC. FINIS"
  "FREE FI("DDNAME")"

ADDRESS ISPEXEC
  DOIT = ""                                                   /* @AA */
  DO K = 1 TO REC.0
     PARSE VAR REC.K REC NAME PGM DESC
     IF (SUBSTR(REC.K,1,1) = "*") THEN ITERATE
     REC  = STRIP(REC)
     NAME = STRIP(NAME)
     DESC = STRIP(DESC)
     DESCCAPS = DESC
     UPPER DESCCAPS
     "TBADD "TABLEA
  END
  DROP REC.

  CLRREC = "TURQ"  ; CLRNAME = "GREEN"
  CLRPGM = "GREEN" ; CLRDESC = "GREEN"
  sort   = 'REC,C,A'
  sortid = 'D'; sortacc = 'A'
  "TBQUERY "TABLEA" ROWNUM(RNUM)"                             /* @AB */
  "TBSORT " TABLEA "FIELDS("sort")"
RETURN
/*--------------------------------------------------------------------*/
/*  Process primary command FIND for TABLEA                           */
/*--------------------------------------------------------------------*/
DO_FINDA:
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
        testit = translate(REC NAME PGM DESC)
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
           sort   = sortcol',C,D'
           tmpseq = 'D'
     end
     Otherwise do
        sort   = sortcol',C,A'
        tmpseq = 'A'
     end
  end
  INTERPRET "SORT"SUBSTR(SORTCOL,1,4)" = TMPSEQ"
RETURN
/*--------------------------------------------------------------------*/
/*  Create Batch job                                                  */
/*--------------------------------------------------------------------*/
CREATE_JCL:
ADDRESS ISPEXEC
  /*-----------------------------------------------*/         /* @A1 */
  /* If IBM's ISPF JOB card variable is:           */         /* @A1 */
  /*   ZLLGJOB1 =                                  */         /* @A1 */
  /* or                                            */         /* @A1 */
  /*   ZLLGJOB1 = //USERID   JOB (ACCOUNT),'NAME'  */         /* @A1 */
  /* or                                            */         /* @A1 */
  /*   ZLLGJOB1 = //@??##### JOB (??T),'NAME',etc. */         /* @A1 */
  /* or                                            */         /* @A1 */
  /*   ZLLGJOB1 = //JOB-NAME JOB (???),'NAME',etc. */         /* @A1 */
  /*-----------------------------------------------*/         /* @A1 */
  PARSE UPPER VAR ZLLGJOB1 W1 .                               /* @A1 */
  IF (ZLLGJOB1 = "") | (W1 = "//USERID"),                     /* @A1 */
   | (W1 = "//@??#####") | (W1 = "//JOB-NAME") THEN DO        /* @A1 */
     TMPZCMD = ZCMD                                           /* @A3 */
     CALL DEFINE_JOB_CARD
     ZCMD    = TMPZCMD                                        /* @A3 */
  END

  "FTOPEN TEMP"
  "VGET (ZTEMPF)"                                             /* @A9 */

  TMPDRPTU = STRIP(TMPDRPTU,,"'")
  GDGDSN = "N"                                                /* @AH */
  "FTINCL "SKELETON1                                          /* @A8 */
  IF (ABBREV("UNLOAD",ZCMD,1) = 1) THEN DO                    /* @AH */
     PARSE VAR TMPDRPTU W1 "(" W2 ")" .                       /* @AH */
     IF (W2 <> "") THEN DO                                    /* @AH */
        TMPDRPTU = W1"(+1)"                                   /* @AH */
        GDGDSN = "Y"                                          /* @AH */
     END                                                      /* @AH */
     ELSE DO                                                  /* @AH */
        DSNLEN = LENGTH(TMPDRPTU)                             /* @AH */
        GOOVOO = SUBSTR(TMPDRPTU,DSNLEN-7)                    /* @AH */
        GOOVOO = TRANSLATE(GOOVOO,##########,0123456789)      /* @AH */
        IF (GOOVOO = "G####V##") THEN DO                      /* @AH */
           GDGDSN = "Y"                                       /* @AH */
           TMPDRPTU = SUBSTR(TMPDRPTU,1,DSNLEN-9)"(+1)"       /* @AH */
        END                                                   /* @AH */
        ELSE DO                                               /* @AH */
           X = OUTTRAP("LC.")                                 /* @AH */
           ADDRESS TSO "LISTCAT ENT('"TMPDRPTU"')"            /* @AH */
           X = OUTTRAP("OFF")                                 /* @AH */
           PARSE VAR LC.1 W1 W2 .                             /* @AH */
           IF (W1 = "GDG") & (W2 = "BASE") THEN               /* @AH */
              TMPDRPTU  = TMPDRPTU"(+1)"                      /* @AH */
           DROP LC.                                           /* @AH */
        END /* Else */                                        /* @AH */
     END /* Else */                                           /* @AH */
     CALL GET_RACF_DSNS
     "FTINCL "SKELETON2                                       /* @A7 */
  END /* If UNLOAD */
  ELSE
     "FTINCL "SKELETON3                                       /* @A7 */
  "FTCLOSE"

  IF (RACFRJCL = "Y") THEN do                                 /* @LD */
      'vget (ztempn)'                                         /* @LD */
      "LMINIT DATAID(DATAID) DDNAME("ztempn")"                /* @LD */
      "EDIT DATAID("dataid")"                                 /* @LD */
      "LMFREE DATAID("dataid")"                               /* @LD */
      end                                                     /* @LD */
  ELSE DO
     ADDRESS TSO "SUBMIT '"ztempf"'"
     RACFSMSG = "Job Submitted"
     RACFLMSG = "Batch job was submitted.  Invoke SDSF",
                "to view output"
     "SETMSG MSG(RACF011)"
  END
RETURN
/*--------------------------------------------------------------------*/
/*  Define JOB card and JCL parameters                                */
/*--------------------------------------------------------------------*/
DEFINE_JOB_CARD:
  /*-----------------------------------------------*/         /* @A1 */
  /* If IBM's ISPF JOB card variable is:           */         /* @A1 */
  /*   ZLLGJOB1 =                                  */         /* @A1 */
  /* or                                            */         /* @A1 */
  /*   ZLLGJOB1 = //USERID   JOB (ACCOUNT),'NAME'  */         /* @A1 */
  /* or                                            */         /* @A1 */
  /*   ZLLGJOB1 = //@??##### JOB (??T),'NAME',etc. */         /* @A1 */
  /*-----------------------------------------------*/         /* @A1 */
  PARSE UPPER VAR ZLLGJOB1 W1 .                               /* @A4 */
  IF (ZLLGJOB1 = "") | (W1 = "//USERID") then do              /* @A1 */
     ZLLGJOB1 = "//job-name JOB (acct),'first-last-name',"
     ZLLGJOB2 = "//         MSGCLASS=?,CLASS=?,"||,
                "REGION=0M,NOTIFY=&SYSUID"
     "VPUT (ZLLGJOB1 ZLLGJOB2)"
  END

  'control display save'                                      /* @A1 */
  "ADDPOP"
  DO FOREVER
     "DISPLAY PANEL("PANEL99")"
     IF (RC = 8) THEN LEAVE
  END
  "REMPOP"
  'control display restore'                                   /* @A1 */

  "VPUT (ZLLGJOB1 ZLLGJOB2 ZLLGJOB3 ZLLGJOB4",
        "SETJRPTU SETJRPTS) PROFILE"                          /* @A2 */
RETURN
/*--------------------------------------------------------------------*/
/*  Get RACF primary and backup database names                        */
/*--------------------------------------------------------------------*/
GET_RACF_DSNS:
    cvt      = c2x(storage(10,4))
    cvtrac$  = d2x((x2d(cvt))+992)
    cvtrac   = c2x(storage(cvtrac$,4))
    rcvtsta$ = d2x((x2d(cvtrac))+56)
    RACFDPRM = strip(storage(rcvtsta$,44))
    RCVT     = D2X(X2D(CVT) +X2D(3E0))
    RCVT     = C2X(STORAGE(RCVT,4))
    DSDT     = D2X(X2D(RCVT) + X2D(E0))
    DSDT     = C2X(STORAGE(DSDT,4))
    DSDTBACK = D2X(X2D(DSDT) + X2D(140))
    BNAME    = D2X(X2D(DSDTBACK) + X2D(21))
    RACFDBKP = STRIP(STORAGE(BNAME,44))
    RACFDTMP = RACFDBKP
    if (RACFDBKP = "") then do
        RACFDBKP = "N/A"
        RACFDTMP = RACFDPRM
    end
RETURN
/*--------------------------------------------------------------------*/
/*  Verify at least one report was selected and unselect 'ALL',  @AC  */
/*  if other reports were selected, eliminating duplication      @AC  */
/*--------------------------------------------------------------------*/
CHK_ALL:                                                      /* @AC */
  "TBSORT "TABLEA" FIELDS(REC,C,A)"                           /* @AC */
  "TBSKIP "TABLEA                                             /* @AC */
  "TBGET  "TABLEA                                             /* @AC */
                                                              /* @AC */
  SUBMIT = "N"                                                /* @AE */
  IF (REC = "ALL") & (DOIT = "*") THEN DO                     /* @AC */
     DO J = 2 TO RNUM                                         /* @AC */
        "TBSKIP "TABLEA                                       /* @AC */
        "TBGET  "TABLEA                                       /* @AC */
        IF (DOIT = "*") THEN DO                               /* @AC */
           DOIT = ""                                          /* @AC */
           "TBPUT "TABLEA                                     /* @AC */
        END                                                   /* @AC */
     END                                                      /* @AC */
     SUBMIT = "Y"                                             /* @AE */
  END                                                         /* @AC */
  ELSE DO                                                     /* @AE */
     DO J = 2 TO RNUM                                         /* @AE */
        "TBSKIP "TABLEA                                       /* @AE */
        "TBGET  "TABLEA                                       /* @AE */
        IF (DOIT = "*") THEN                                  /* @AE */
           SUBMIT = "Y"                                       /* @AE */
     END                                                      /* @AE */
  END                                                         /* @AE */
  "TBTOP "TABLEA                                              /* @AC */
RETURN                                                        /* @AC */
/*--------------------------------------------------------------------*/
/*  Clear the DOIT field on all reports                          @AF  */
/*--------------------------------------------------------------------*/
CLEAR_DOIT:                                                   /* @AF */
  "TBTOP "TABLEA                                              /* @AF */
                                                              /* @AF */
  DO J = 2 TO RNUM                                            /* @AF */
     "TBSKIP "TABLEA                                          /* @AF */
     "TBGET  "TABLEA                                          /* @AF */
     IF (DOIT = "*") THEN DO                                  /* @AF */
        DOIT = ""                                             /* @AF */
        "TBPUT "TABLEA                                        /* @AF */
     END                                                      /* @AF */
  END                                                         /* @AF */
  "TBTOP "TABLEA                                              /* @AF */
RETURN                                                        /* @AF */
