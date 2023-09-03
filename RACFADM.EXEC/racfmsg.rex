/*%NOCOMMENT====================* REXX *==============================*/
/*  PURPOSE:  RACFADM - RACF Messages - Menu Option M                 */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @L5  230830  LBD      Use Grep to filter isfline (sdsf)            */
/* @EEJ 230320  EEJ      Update by Ed Jaffe for (E)JES Support        */
/* @L3  230319  LBD      Add ToDate along with FromDate               */
/*                       Translae out x'00' in error message (ejes)   */
/* @L2  230317  LBD      Use RACFCLOG to test for OPERLOG/SYSLOG      */
/* @L1  230316  LBD      Fix Message Scan                             */
/* @AJ  200918  RACFA    Fix 'Type=A', was displaying same msg        */
/* @AI  200903  RACFA    Added 'OMVS' to USS messages                 */
/* @AH  200903  RACFA    Display all ICH408I msgs, except pswd invalid*/
/* @AG  200702  RACFA    Allow symbolic in dsname                     */
/* @AF  200701  RACFA    Initialize command field (zcmd)              */
/* @AE  200630  RACFA    Added "=" for today's date                   */
/* @AD  200630  RACFA    Allow TSO PREFIX has HLQ in dsname           */
/* @AC  200629  RACFA    Fixed EJES, when date=*                      */
/* @AB  200629  RACFA    Fix display SYSLOG/OPERLOG, del some code    */
/* @AA  200629  RACFA    Allow an asterick as a date                  */
/* @A9  200627  RACFA    Batch, chg parm syntax and upper case        */
/* @A8  200627  RACFA    Create variables for USERID and LPAR         */
/* @A7  200627  RACFA    Executing batch, chg display of parameters   */
/* @A6  200627  RACFA    Added EJES and chged variable names          */
/* @A5  200625  RACFA    Make DATE=today and LOG=A as default         */
/* @A4  200624  RACFA    ICH408I in W7 for SYSLOG and W8 for OPERLOG  */
/* @A3  200624  RACFA    When batch, fix comments in SYSTSPRT         */
/* @A2  200624  RACFA    Get site variable to use SYSLOG or OPERLOG   */
/* @A1  200622  TRIDJK   Fix JDATE                                    */
/* @A0  200620  RACFA    Created REXX                                 */
/*====================================================================*/
TODAY      = DATE("U")
ENV        = SYSVAR(SYSENV)
USERID     = USERID()                                         /* @A8 */
LPAR       = MVSVAR("SYMDEF","SYSNAME")                       /* @A8 */

ADDRESS ISPEXEC
  ADDRESS TSO "PROFILE VARSTORAGE(HIGH)"
  IF (ENV = "FORE") THEN
     CALL FOREGROUND
  ELSE
     CALL BATCH
EXIT
/*--------------------------------------------------------------------*/
/*  Execution in foreground mode                                      */
/*--------------------------------------------------------------------*/
FOREGROUND:
  PANEL01    = "RACFMSG"            /* Pop-up data entry  */
  PANEL02    = "RACFDISP"           /* ICH408I Color=Turq */
  SKELETON1  = "RACFJOB"            /* JOB card           */
  SKELETON2  = "RACFMSG"            /* TSO PARM=RACFERRS  */

  "VGET (RACFMID  RACFMLPR RACFMDAT RACFMTYP",
        "RACFMUSS RACFMMOD RACFMJCL RACFMSCN",                /* @A6 */
        "SETGPREF SETMTRAC SETPMSG  SETDMSG",                 /* @L2 */
        "ZLLGJOB1 ZLLGJOB2 ZLLGJOB3 ZLLGJOB4) PROFILE"

  rc = racfclog(setpmsg) /* Get Operlog or SYSLOG */       /* @L3 */
  if rc = 0 then setlmsg = 'S'                             /* @L3 */
  else setlmsg = 'O'                                       /* @L3 */

  If (SETMTRAC <> 'NO') then do
     Say "*"COPIES("-",70)"*"
     Say "*"Center("Begin Program = "REXXPGM,70)"*"
     Say "*"COPIES("-",70)"*"
     if (SETMTRAC <> 'PROGRAMS') THEN
        interpret "Trace "SUBSTR(SETMTRAC,1,1)
  end
  IF (RACFMID  = "") THEN RACFMID  = "*"
  IF (RACFMLPR = "") THEN RACFMLPR = "*"
  SELECT                                                      /* @AA */
     WHEN (RACFMDAT = "")  THEN RACFMDAT = DATE("U")          /* @AA */
     WHEN (RACFMDAT = "*") THEN NOP                           /* @AA */
     OTHERWISE RACFMDAT = DATE("U")                           /* @AA */
  END                                                         /* @AA */
  SELECT                                                      /* @AA */
     WHEN (RACFTDAT = "")  THEN RACFTDAT = DATE("U")          /* @L3 */
     WHEN (RACFTDAT = "*") THEN NOP                           /* @L3 */
     OTHERWISE RACFTDAT = DATE("U")                           /* @L3 */
  END                                                         /* @L3 */
  IF (RACFMTYP = "") THEN RACFMTYP = "A"
  IF (RACFMUSS = "") THEN RACFMUSS = "N"
  RACFMMOD = "F"                                              /* @AA */
  IF (RACFMJCL = "") THEN RACFMJCL = "Y"
  IF (SETPMSG  = "") THEN SETPMSG  = "SDSF"                   /* @A6 */
  RACFMSCN = "A"                                              /* @A5 */

  /*-----------------------------------------------*/
  /* If IBM's ISPF JOB card variable is:           */
  /*   ZLLGJOB1 =                                  */
  /* or                                            */
  /*   ZLLGJOB1 = //USERID   JOB (ACCOUNT),'NAME'  */
  /* or                                            */
  /*   ZLLGJOB1 = //@??##### JOB (??T),'NAME',etc. */
  /*-----------------------------------------------*/
  PARSE UPPER VAR ZLLGJOB1 W1 .
  IF (ZLLGJOB1 = "") | (W1 = "//USERID") then do
     ZLLGJOB1 = "//job-name JOB (acct),'first-last-name',"
     ZLLGJOB2 = "//         MSGCLASS=?,CLASS=?,"||,
                "REGION=0M,NOTIFY=&SYSUID"
     "VPUT (ZLLGJOB1 ZLLGJOB2)"
  END

  CALL CLIST_DSN                                              /* @A6 */

  DO FOREVER
     DSNRPT = USERID".RACFERRS.RPT"RANDOM()
     ZCMD = ""                                                /* @AF */
     "DISPLAY PANEL("PANEL01")"
     IF (RC = 8) THEN LEAVE

     call Fixup_dates

     IF (RACFMDAT = "*") THEN                                 /* @AA */
        JDATE = "*"
     ELSE DO                                                  /* @AA */
        PARSE VAR racfmdat MM "/" DD "/" YY .
        YYYYMMDD = "20"YY""MM""DD
        DDD      = DATE("D",YYYYMMDD,"S")
        JDATE    = YY""RIGHT(DDD,3,'0')                       /* @A1 */
     END                                                      /* @AA */

     IF (RACFMMOD = "F") THEN
        CALL FOREGROUND_LOG
     ELSE
        CALL FOREGROUND_CREATE_JCL
  END

  "VPUT (RACFMID  RACFMLPR RACFMDAT RACFMTYP",                /* @AA */
        "RACFMUSS RACFMMOD RACFMJCL RACFMSCN",                /* @A6 */
        "SETGPREF SETMTRAC SETPMSG  SETDMSG",                 /* @L2 */
        "RACFTDAT",                                           /* @L3 */
        "ZLLGJOB1 ZLLGJOB2 ZLLGJOB3 ZLLGJOB4) PROFILE"

  If (SETMTRAC <> 'NO') then do
     Say "*"COPIES("-",70)"*"
     Say "*"Center("End Program = "REXXPGM,70)"*"
     Say "*"COPIES("-",70)"*"
  end
return

Fixup_dates:                                         /* @L3 */
    racfmdat = radmfdat                              /* EEJ */
    racftdat = radmtdat                              /* EEJ */
    IF radmfdat = '*' then                           /* @L3 */
         racfmdat = '*'                              /* @L3 */
    IF left(radmfdat,1) = '-' then                   /* @L3 */
    IF datatype(radmfdat) = 'NUM' then do            /* @L3 */
      dt = date('b') + radmfdat                      /* @L3 */
      racfmdat = date('u',dt,'b')                    /* @L3 */
    end                                              /* @L3 */
    IF left(radmtdat,1) = '-' then                   /* @L3 */
    IF datatype(radmtdat) = 'NUM' then do            /* @L3 */
      dt = date('b') + radmtdat                      /* @L3 */
      racftdat = date('u',dt,'b')                    /* @L3 */
    end                                              /* @L3 */
    IF radmfdat = '=' then                           /* @L3 */
    IF radmfdat = '='                                /* @L3 */
    then racfmdat = date('u')                        /* @L3 */
    else racfmdat = radmfdat                         /* @L3 */
    IF radmtdat = '=' then                           /* @L3 */
    IF radmtdat = '='                                /* @L3 */
    then racftdat = date('u')                        /* @L3 */
    else racftdat = radmtdat                         /* @L3 */
  return                                             /* @L3 */

/*--------------------------------------------------------------------*/
/*  Execution in batch mode                                           */
/*--------------------------------------------------------------------*/
BATCH:
  ADDRESS TSO "EXECIO * DISKR PARMS (STEM PARMS. FINIS"
  parse value '' with racfmdat racftdat racfftim racfttim
  DO J = 1 TO PARMS.0
     SELECT
        WHEN (POS("USERID=",PARMS.J)  > 0) THEN               /* @A9 */
             PARSE UPPER VAR PARMS.J . "USERID="RACFMID .     /* @A9 */
        WHEN (POS("LPAR=",PARMS.J)    > 0) THEN               /* @A9 */
             PARSE UPPER VAR PARMS.J . "LPAR="RACFMLPR .      /* @A9 */
        WHEN (POS("FROMDATE=",PARMS.J)    > 0) THEN           /* @L3 */
             PARSE UPPER VAR PARMS.J . "DATE="RADMFDAT .      /* @L3 */
        WHEN (POS("TODATE=",PARMS.J)    > 0) THEN             /* @L3 */
             PARSE UPPER VAR PARMS.J . "DATE="RADMTDAT .      /* @L3 */
        WHEN (POS("FROMTIME=",PARMS.J)    > 0) THEN           /* @L3 */
             PARSE UPPER VAR PARMS.J . "TIME="RACFFTIM .      /* @L3 */
        WHEN (POS("TOTIME=",PARMS.J)    > 0) THEN             /* @L3 */
             PARSE UPPER VAR PARMS.J . "DATE="RACFTTIM .      /* @L3 */
        WHEN (POS("USSONLY=",PARMS.J) > 0) THEN               /* @A9 */
             PARSE UPPER VAR PARMS.J . "USSONLY="RACFMUSS .   /* @A9 */
        WHEN (POS("TYPE=",PARMS.J)    > 0) THEN               /* @A9 */
             PARSE UPPER VAR PARMS.J . "TYPE="RACFMTYP .      /* @A9 */
        WHEN (POS("LOG=",PARMS.J)     > 0) THEN               /* @A9 */
             PARSE UPPER VAR PARMS.J . "LOG="SETLMSG .        /* @A9 */
        WHEN (POS("SCAN=",PARMS.J)    > 0) THEN               /* @A9 */
             PARSE UPPER VAR PARMS.J . "SCAN="RACFMSCN .      /* @A9 */
        WHEN (POS("PROGRAM=",PARMS.J) > 0) THEN               /* @A9 */
             PARSE UPPER VAR PARMS.J . "PROGRAM="SETPMSG .    /* @A9 */
        OTHERWISE
             NOP
     END /* Select */
  END J
  DROP PARMS.

     call Fixup_dates

  IF (RACFMID  = "")  THEN RACFMID  = "*"
  IF (RACFMLPR = "")  THEN RACFMLPR = "*"
  IF (RACFMUSS = "")  THEN RACFMUSS = "N"
  IF (RACFMTYP = "")  THEN RACFMTYP = "A"
  IF (RACFMSCN = "")  THEN RACFMSCN = "A"                     /* @A6 */
  if (RACFMDAT = "*") THEN                                    /* @AA */
     JDATE = "*"
  else do                                                     /* @AA */
say 'batch racfmdat:' racfmdat 'radmfdat:' radmfdat
     PARSE VAR racfmdat MM "/" DD "/" YY .
     YYYYMMDD = "20"YY""MM""DD
     DDD      = DATE("D",YYYYMMDD,"S")
     JDATE    = YY""RIGHT(DDD,3,'0')                          /* @A1 */
  END                                                         /* @AA */
  IF (RACFMSCN = "A") THEN DO                                 /* @A6 */
     SELECT                                                   /* @A6 */
        WHEN (SETPMSG = "EJES") THEN DO                       /* @A6 */
             IF (SETLMSG = "S") THEN
                EJESLOG = "SYSLOG"
             ELSE
                EJESLOG = "OPERLOG"
             CALL EJES_LOG EJESLOG RACFMLPR                   /* EEJ */
        END
        OTHERWISE                                             /* @A6 */
             CALL SDSF_LOG                                    /* @A6 */
     END                                                      /* @A6 */
  END                                                         /* @A6 */
  ELSE
     CALL DSN_LOG                                             /* @A6 */

  SAY "*"COPIES("-",70)"*"                                    /* @A7 */
  SAY "*"CENTER("RACFADM - Messages",70)"*"                   /* @A7 */
  SAY "*"COPIES("-",70)"*"                                    /* @A7 */
  SAY " "                                                     /* @A7 */
  SAY " Total:"                                               /* @A7 */
  SAY "   Messages = "TOTALMSGS                               /* @A7 */
  SAY " "                                                     /* @A7 */
  SAY "  Parameters:"                                         /* @L3 */
  SAY "   Userid     = "LEFT(RACFMID,8),                      /* @L3 */
      " ("USERID", *)"                                        /* @L3 */
  SAY "   Lpar       = "LEFT(racfmlpr,8),                     /* @L3 */
      " ("LPAR", *)"                                          /* @L3 */
  SAY "   From Date  = "LEFT(racfmdat,8),                     /* @L3 */
      " (mm/dd/yy, =, *, -n)"                                 /* @L3 */
  SAY "   To Date    = "LEFT(racftdat,8),                     /* @L3 */
      " (mm/dd/yy, =, *, -n)"                                 /* @L3 */
  SAY "   From Time  = "LEFT(racfftim,8),                     /* @L3 */
      " hh:mm "                                               /* @L3 */
  SAY "   To Time    = "LEFT(racfttim,8),                     /* @L3 */
      " hh:mm "                                               /* @L3 */
  SAY "   Type       = "LEFT(racfmtyp,8),                     /* @L3 */
      " (A=All, I=Insufficient, V=Violation)"                 /* @L3 */
  SAY "   USS        = "LEFT(racfmuss,8),                     /* @L3 */
      " (Y=Yes, N=No)"                                        /* @L3 */
  SAY "   Log        = "LEFT(SETLMSG,8),                      /* @L3 */
      " (O=Operlog, S=Syslog)"                                /* @L3 */
  SAY "   Scan       = "LEFT(RACFMSCN,8),                     /* @L3 */
      " (A=Active log, B=Backup log)"                         /* @L3 */
  SAY "   Program    = "LEFT(SETPMSG,8),                      /* @L3 */
      " (EJES, SDSF)"                                         /* @L3 */
  SAY " "                                                     /* @A7 */
  ADDRESS TSO "EXECIO * DISKW ERRORS (STEM LOGMSG. FINIS"
  EXECIORC = RC
  DROP LOGMSG.
  IF (EXECIORC > 0) THEN DO
     SAY "ERROR - Missing DD card ERRORS, unable to write",
         "the ICH408I messages."
     RETURN
  END
RETURN
/*--------------------------------------------------------------------*/
/*  Foreground, create batch JCL (Mode = B)                           */
/*--------------------------------------------------------------------*/
FOREGROUND_CREATE_JCL:
  PARSE VAR TMPDMSG2 . "(" W1 ")" .                           /* @AG */
  IF (W1 = "") THEN DO
     X = OUTTRAP("LC.")
     ADDRESS TSO "LISTCAT ENT('"TMPDMSG2"')"                  /* @AG */
     X = OUTTRAP("OFF")
     PARSE VAR LC.1 W1 W2 .
     DROP LC.                                                 /* @AG */
     IF (W1 = "GDG") & (W2 = "BASE") THEN DO
        CALL GDG_BASE_GET_GOVO                                /* @A6 */
        IF (TMPDMSG1 = "") THEN DO
           RACFSMSG = "Invalid Date"
           RACFLMSG = "There are no GDG genarations",
                      "with a date of "RACFMDAT"."
           "SETMSG MSG(RACF011)"
           RETURN
        END
     END
  END

  "FTOPEN TEMP"
  "VGET (ZTEMPF)"
  "FTINCL "SKELETON1
  "FTINCL "SKELETON2
  "FTCLOSE"

  IF (RACFMJCL = "Y") THEN
     "EDIT DATASET('"ztempf"')"
  ELSE DO
     ADDRESS TSO "SUBMIT '"ztempf"'"
     RACFSMSG = "Job Submitted"
     RACFLMSG = "Batch job was submitted.  Invoke SDSF",
                "to view output"
     "SETMSG MSG(RACF011)"
  END

RETURN
/*--------------------------------------------------------------------*/
/*  Foreground, process log (Mode = A)                                */
/*--------------------------------------------------------------------*/
FOREGROUND_LOG:
  LOGMSG.0 = 0

  IF (RACFMSCN = "A") THEN DO   /* Active OPERLOG? */         /* @A6 */
     SELECT                                                   /* @A6 */
        WHEN (SETPMSG = "EJES") THEN DO                       /* @A6 */
             IF (SETLMSG = "S") THEN                          /* @A6 */
                EJESLOG = "SYSLOG"                            /* @A6 */
             ELSE                                             /* @A6 */
                EJESLOG = "OPERLOG"                           /* @A6 */
             CALL EJES_LOG EJESLOG RACFMLPR                   /* EEJ */
        END                                                   /* @A6 */
        OTHERWISE                                             /* @A6 */
             CALL SDSF_LOG                                    /* @A6 */
     END                                                      /* @A6 */
  END                                                         /* @A6 */
  ELSE DO
     PARSE VAR TMPDMSG2 . "(" W1 ")" .                        /* @AG */
     IF (W1 = "") THEN DO
        X = OUTTRAP("LC.")
        ADDRESS TSO "LISTCAT ENT('"TMPDMSG2"')"               /* @AG */
        X = OUTTRAP("OFF")
        PARSE VAR LC.1 W1 W2 .
        DROP LC.                                              /* @AG */
        IF (W1 = "GDG") & (W2 = "BASE") THEN DO
           CALL GDG_BASE_GET_GOVO                             /* @A6 */
           IF (TMPDMSG1 = "") THEN DO                         /* @AG */
              RACFSMSG = "Invalid Date"
              RACFLMSG = "There are no GDG genarations",
                         "with a date of "RACFMDAT"."
              "SETMSG MSG(RACF011)"
              RETURN
           END
           TMPDSN = "'"TMPDMSG1"'"                            /* @AG */
        END
        ELSE
           TMPDSN = "'"TMPDMSG2"'"                            /* @AG */
     END
     ELSE
        TMPDSN = "'"TMPDMSG2"'"                               /* @AG */

     ADDRESS TSO "ALLOCATE FI(BKPLOG) DSN("TMPDSN")",         /* @AD */
                 "SHR REUSE BUFNO(30) LRECL(259)"
     CALL DSN_LOG                                             /* @A6 */
     ADDRESS TSO "FREE FI(BKPLOG)"
  END
  IF (LOGMSG.0 = 0) THEN DO
     RACFSMSG = "No Security Errors"
     RACFLMSG = "There are no ICH408I messages",
                "with the search criteria specified."
     "SETMSG MSG(RACF011)"
  END
  ELSE DO
     ADDRESS TSO "ALLOCATE FI(RACFERRS)",
         "NEW REUSE UNIT(VIO)",
         "LRECL(240) BLKSIZE(0) RECFM(V B)",
         "CYLINDERS SPACE(10 10)"
     ADDRESS TSO "EXECIO * DISKW RACFERRS (STEM LOGMSG. FINIS"
     DROP LOGMSG.
     RACFSMSG = TOTALMSGS" Total Errors"
     RACFLMSG = "There are "TOTALMSGS" total RACF",
               "errors displayed."
     "SETMSG MSG(RACF011)"
     "VGET (ZPF10 ZPF11)"
     SAVEPF10 = ZPF10
     SAVEPF11 = ZPF11
     ZPF10    = "LEFT 55"
     ZPF11    = "RIGHT 55"
     "VPUT (ZPF10 ZPF11)"
     "LMINIT DATAID(DATAID) DDNAME(RACFERRS)"
     "VIEW DATAID("DATAID") PANEL("PANEL02")"
     ADDRESS TSO "FREE FI(RACFERRS)"
     ZPF10    = SAVEPF10
     ZPF11    = SAVEPF11
     "VPUT (ZPF10 ZPF11)"
  END
RETURN
/*--------------------------------------------------------------------*/
/*  SDSF, scan the active log (Scan = A)                              */
/*--------------------------------------------------------------------*/
SDSF_LOG:                                                     /* @A6 */
  IF (JDATE <> "*") THEN DO                                   /* @AA */
     ISFLOGSTARTDATE = RACFMDAT
     ISFLOGSTARTTIME = RACFFTIM                               /* @L3 */
     ISFLOGSTOPDATE  = RACFTDAT  /* DATE - MM/DD/YY */        /* @L3 */
     ISFLOGSTOPTIME  = RACFTTIM                               /* @L3 */
  END                                                         /* @AA */
  else do
       parse value '' with isflogstarttime isflogstartdate ,
       isflogstopdate isflogstoptime
       end
  ISFLINELIM      = 0

  RC = ISFCALLS("ON")
  IF (RC <> 0) THEN DO
     IF (ENV = "FORE") THEN DO
        RACFLMSG = "SDSF is not active on this lpar."
        "SETMSG MSG(RACF011)"
     END
     ELSE
        SAY "ERROR - SDSF is not active on this lpar."
     RETURN
  END

  IF (SETLMSG = 'O') then                          /* @L1 */
     ADDRESS SDSF "ISFLOG READ TYPE(OPERLOG)"      /* @L1 */
  ELSE DO                                          /* @L1 */
     ISFSYSID = RACFMLPR                           /* @L1 */
     ADDRESS SDSF "ISFLOG READ TYPE(SYSLOG)"       /* @L1 */
  END                                              /* @L1 */

  RC=ISFCALLS("OFF")

  K = 0
  TOTALMSGS = 0
  CALL PROCESS_LOG_RECS                                       /* @A6 */
  LOGMSG.0 = K
RETURN
/*--------------------------------------------------------------------*/
/*  Scan the backup log dataset (Scan = B)                            */
/*--------------------------------------------------------------------*/
DSN_LOG:                                                      /* @A6 */
  K         = 0
  READRC    = 0
  TOTALMSGS = 0
  DO WHILE READRC = 0
     ADDRESS TSO "EXECIO 300000 DISKR BKPLOG (STEM ISFLINE."
     READRC = RC
     CALL PROCESS_LOG_RECS                                    /* @A6 */
  END
  ADDRESS TSO "EXECIO 0 DISKR BKPLOG (FINIS"
  LOGMSG.0 = K
RETURN
/*--------------------------------------------------------------------*/
/*  Proces log records, find ICH408I msgs that meet search criteria   */
/*--------------------------------------------------------------------*/
PROCESS_LOG_RECS:                                             /* @A6 */
  call bpxwunix "grep -A 9 'ICH408'",isfline.,isfline.,stderr. /* @L5 */
  DO J = 1 TO ISFLINE.0-1
     PARSE VAR ISFLINE.J W1 W2 W3 W4 W5 W6 W7 W8 W9 W10
     IF (W7 = "ICH408I") | (W8 = "ICH408I") THEN DO           /* @A4 */
        W4R = RIGHT(W4,5)                                     /* EEJ */
           IF (RACFMLPR = "*") | (RACFMLPR = W3) THEN DO
              MSGBEG = J
              MSGEND = J + 12
              DO M = MSGBEG TO MSGEND
                 PARSE VAR ISFLINE.M W1 .
                 IF (W1 = "E") THEN DO
                    MSGEND = M
                    LEAVE
                 END
              END M
              DO M = MSGBEG TO MSGEND
                 SELECT
                    WHEN (RACFMTYP = 'V') THEN
                         FOUND = POS("VIOLATION",ISFLINE.M)
                    WHEN (RACFMTYP = 'I') THEN
                         FOUND = POS("INSUFFICIENT",ISFLINE.M)
                    OTHERWISE DO                             /* @AH */
                         FOUND = POS("PASSWORD",ISFLINE.M)    /* @AH */
                         IF (FOUND > 0) THEN                  /* @AH */
                            FOUND = 00                        /* @AH */
                         ELSE                                 /* @AH */
                            FOUND = 99                        /* @AH */
                    END                                       /* @AH */
                 END                                          /* @AH */
                 IF (FOUND > 0) THEN DO
                    IF (RACFMID <> "*") THEN DO
                       DO N = MSGBEG TO MSGEND
                          FOUND = POS(RACFMID,ISFLINE.N)
                          IF (FOUND > 0) THEN LEAVE N
                       END N
                       IF (FOUND = 0) THEN LEAVE M
                    END
                    IF (RACFMUSS = "Y") THEN DO
                       DO N = MSGBEG TO MSGEND
                          FOUND = POS("EFFECTIVE",ISFLINE.N)
                          IF (FOUND > 0) THEN LEAVE N
                          FOUND = POS("OMVS",ISFLINE.N)       /* @AI */
                          IF (FOUND > 0) THEN LEAVE N         /* @AI */
                       END N
                       IF (FOUND = 0) THEN LEAVE M
                    END
                    TOTALMSGS = TOTALMSGS + 1
                    DO N = MSGBEG TO MSGEND
                       K = K + 1
                       LOGMSG.K = translate(isfline.n,' ','00'x) /* @L3 */
                    END N
                    LEAVE M                                   /* @AJ */
                 END /* If FOUND */
              END M
           END /* If RACFMLPR*/
     END /* If ICH408I */
  END J
  DROP ISFLINE.
RETURN
/*--------------------------------------------------------------------*/
/*  When the 'Backup log' dataset is a base GDG, obtain the           */
/*  the generation with a create date of minus 1, due to the          */
/*  backup was taken after midnight                                   */
/*--------------------------------------------------------------------*/
GDG_BASE_GET_GOVO:                                            /* @A6 */
  /*------------------------------------*/
  /*  Convert Cregorian to Julian date  */
  /*------------------------------------*/
  MM   = SUBSTR(RACFMDAT,1,2)
  DD   = SUBSTR(RACFMDAT,4,2)
  CC   = SUBSTR(DATE("S"),1,2)
  YY   = SUBSTR(RACFMDAT,7,2)
  IF (YY//4=0) & (YY<>0 | CC//4=0) THEN
     JULTAB=DD'3129313031303131303130'
  ELSE
     JULTAB=DD'3128313031303131303130'
  DAYS=0
  DO I=1 TO MM
     MDAYS=SUBSTR(JULTAB,I*2-1,2)
     DAYS=DAYS+MDAYS
  END
  DAYS = DAYS + 1
  YYYY = SUBSTR(DATE("S"),1,4)
  IF (YYYY//4 = 0) THEN   /* Leap year? */
     NOOFDAYS = 366
  ELSE
     NOOFDAYS = 365
  IF (DAYS = NOOFDAY) THEN DO
     DAYS = "001"
     YY   = YY + 1
  END
  JULIAN=CC||YY'.'RIGHT(DAYS,3,'0')

  X = OUTTRAP("IDCAMS.")
  ADDRESS TSO "LISTCAT ENT('"TMPDMSG2"') ALL"                 /* @AG */
  X        = OUTTRAP("OFF")
  K        = 0
  TMPDMSG1 = ""
  DO J = 1 TO IDCAMS.0
     PARSE VAR IDCAMS.J W1 W2 W3 .
     IF (W1 = "NONVSAM") THEN DO
        L = J + 3
        PARSE VAR IDCAMS.L AW1 "CREATION--------" AW2
        IF (AW2 = JULIAN) THEN DO
           TMPDMSG1 = W3
           LEAVE
        END
     END
  END
  DROP IDCAMS.
RETURN
/*--------------------------------------------------------------------*/
/*  Get CLIST/REXX dataset name, used in batch JCL to invoke REXX pgm */
/*--------------------------------------------------------------------*/
/*  1) The 'ALTLIB DISPLAY' statement, will look for                  */
/*     'Application-level' in the display in order to obtain          */
/*     the DDname of the ALTLIBed dataset                             */
/*       Current search order (by DDNAME) is:                         */
/*       Application-level CLIST DDNAME=SYS00529                      */
/*       System-level EXEC       DDNAME=SYSEXEC                       */
/*       System-level CLIST      DDNAME=SYSPROC                       */
/*  2) The 'LISTA STATUS' will display all the DDnames and datasets   */
/*     allocated, allowing the capability to obtain the dataset name  */
/*     allocated to the 'Application-level CLIST' ddname (SYS#####)   */
/*--------------------------------------------------------------------*/
CLIST_DSN:                                                    /* @A6 */
  X = OUTTRAP("RECALT.")
  ADDRESS TSO "ALTLIB DISPLAY"
  X = OUTTRAP("OFF")

  IF (SUBSTR(RECALT.2,1,3) = "IKJ") THEN
     PARSE VAR RECALT.2 . W1 W2 "DDNAME="DDALTLIB
  ELSE
     PARSE VAR RECALT.2 W1 W2 "DDNAME="DDALTLIB
  DROP RECALT.
  RC = 0
  IF (W1 <> "Application-level") THEN DO
     RC = 8
     return
  END

  X = OUTTRAP("RECLA.")
  ADDRESS TSO "LISTA STATUS"
  X = OUTTRAP("OFF")
  do J = 1 TO RECLA.0
     PARSE VAR RECLA.J W1 .
     IF (W1 = DDALTLIB) THEN DO
        K = J - 1
        DSNREXX = RECLA.K
        LEAVE
     END
  end
  DROP RECLA. W1 DDALTLIB
RETURN
/*--------------------------------------------------------------------*/
/*  (E)JES - Scan for IRR and ICH Messages                            */
/*--------------------------------------------------------------------*/
/*                                                                    */
/*  This REXX extracts IRR and ICH messages from OPERLOG, SYSLOG or   */
/*  DLOG using (E)JES.                                                */
/*                                                                    */
/*  1) Input:                                                         */
/*       There are three positional input parameters:                 */
/*         logdate = mm/dd/yy                                         */
/*         logtype = SYSLOG or OPERLOG                                */
/*         logsys  = system name                                      */
/*                                                                    */
/*       OPERLOG and DLOG can display IRR and ICH messages from       */
/*       all connected systems by specifying an asterisk (*)          */
/*       for logsys.                                                  */
/*                                                                    */
/*       JES2 SYSLOG is not a merged log and will display only        */
/*       one system at a time.  An asterisk is not valid for          */
/*       JES2 SYSLOG.                                                 */
/*                                                                    */
/*       Sample invocation extracting the IRR and ICH messages        */
/*       logged to SYSLOG on June 26, 2020 by system MVSA0.           */
/*          RACFSCAN 06/26/20 SYSLOG MVSA0                            */
/*                                                                    */
/*   1) SCAN:                                                         */
/*       The scan is a trivial operation for (E)JES OPERLOG.          */
/*       One can simply set date/time boundaries and filter           */
/*       on system name and messages that start with IRR and          */
/*       ICH. The OPERLOG browser processes Message Descrip-          */
/*       tor Blocks (MDBs) and fully understands multi-line           */
/*       messages, etc. This scan runs at machine speed.              */
/*                                                                    */
/*       For SYSLOG and DLOG, the scan task takes longer              */
/*       because some of the logic is implemented in REXX.            */
/*       (E)JES could (at machine speed) display messages             */
/*       that start with IRR and ICH but, because SYSLOG and          */
/*       DLOG are just simple text files and not a logical            */
/*       collection of MDBs like OPERLOG, the result would            */
/*       have been one line per message only. Many IRR and            */
/*       ICH messages are either multiline messages (MLWTOs)          */
/*       or single line WTOs continued on a second line when          */
/*       formatted by MVS. Therefore, this exec implements            */
/*       logic to examine the lines immediately following             */
/*       the located IRR or ICH message to see if any of              */
/*       them should be queued after the message line.                */
/*                                                                    */
/*       A single system search through the DLOG can be slow          */
/*       in a multisystem environment because DLOG is a               */
/*       JESplex-wide merged log and the exec must filter             */
/*       out all of the ICH and IRR messages issued by                */
/*       systems other than the requested one.                        */
/*                                                                    */
/*   3) OUTPUT:                                                       */
/*       The exec creates a stem variable called LOGMSG.              */
/*       A line of code near the logical end echos this stem          */
/*       using SAY statements:                                        */
/*                                                                    */
/*       do i = 1 to LOGMSG.0;say LOGMSG.i;end                        */
/*                                                                    */
/*       This is done for the batch job use case. You can             */
/*       replace this with any processing desired.                    */
/*                                                                    */
/* CHANGE-ACTIVITY =                                                  */
/*   2020/06/27 = Initial version authored by Ed Jaffe at             */
/*                Phoenix Software International, Inc.                */
/*--------------------------------------------------------------------*/
EJES_LOG:

  ADDRESS TSO                                                 /* EEJ */
  parse UPPER arg logtype logsys /* Get Parms */              /* EEJ */

  if RACFMDAT = "*" then                                      /* EEJ */
    fparm = ""                                                /* EEJ */
  else do                                                     /* EEJ */
    fparm = "000" || DATE("Days",RACFMDAT,"Usa")              /* EEJ */
    fparm = LEFT(DATE("Standard",RACFMDAT,"Usa"),4) ||,       /* EEJ */
           "." || RIGHT(fparm,3)                              /* EEJ */
    if RACFFTIM = "" then                                     /* EEJ */
      fparm = "00.00-"fparm                                   /* EEJ */
    else                                                      /* EEJ */
      fparm = RACFFTIM"-"fparm                                /* EEJ */
  end                                                         /* EEJ */
                                                              /* EEJ */
  if RACFTDAT = "*" then                                      /* EEJ */
    tparm = ""                                                /* EEJ */
  else do                                                     /* EEJ */
    tparm = "000" || DATE("Days",RACFTDAT,"Usa")              /* EEJ */
    tparm = LEFT(DATE("Standard",RACFTDAT,"Usa"),4) ||,       /* EEJ */
           "." || RIGHT(tparm,3)                              /* EEJ */
    if RACFTTIM = "" then                                     /* EEJ */
      tparm = "23.59-"tparm                                   /* EEJ */
    else                                                      /* EEJ */
      tparm = RACFTTIM"-"tparm                                /* EEJ */
  end                                                         /* EEJ */

  rc = EJESREXX("ON")

  select
    /******************/
    /* Handle OPERLOG */
    /******************/
    when logtype = "OPERLOG" then do
      QUEUE "MASKCHAR * %"
      QUEUE "DATEFMT YYYYDDD ."
      QUEUE "LOG" logtype
      QUEUE "XSELECT"
      QUEUE ":<"logsys"><><><><><><><><><><>"  ||,            /* EEJ */
            "<><><><><><IRR*><ICH*><><><><><>" ||,            /* EEJ */
            "<"fparm"><"tparm">"                              /* EEJ */
      QUEUE ""
      ADDRESS EJES "EXECAPI * (PRE log_ TERM"
      ISFLINE.0 = log_line.0                                  /* EEJ */
      do i = 1 to log_line.0                                  /* EEJ */
        ISFLINE.i = log_line.i                                /* EEJ */
      end                                                     /* EEJ */
      DROP log_line.                                          /* EEJ */
      end /* when */

    /**************************/
    /* Handle SYSLOG and DLOG */
    /**************************/
    when logtype = "SYSLOG" then do

      msgprfx.1="IRR";msgprfx.2="ICH";msgprfx.0=2
      IRRline.0 = 0;IRRtime.0 = 0
      ICHline.0 = 0;ICHtime.0 = 0

      do msgidx = 1 to msgprfx.0
        DELSTACK
        QUEUE "MASKCHAR * %"
        QUEUE "DATEFMT YYYYDDD ."
        if logsys <> "*" then                                 /* EEJ */
          QUEUE "logsys" logsys
        QUEUE "LOG" logtype
        if RACFMDAT = "*" then                                /* EEJ */
          QUEUE "TOP"                                         /* EEJ */
        else do                                               /* EEJ */
          QUEUE "LOCATE" fparm                                /* EEJ */
        end
        QUEUE "FIND P'" || msgprfx.msgidx || "###'"
        QUEUE ""
        ADDRESS EJES "EXECAPI 9 (PRE tmp_"                    /* EEJ */

        if tparm <> "" then do                                /* EEJ */
          ttime = LEFT(tparm,5)                               /* EEJ */
          tdate = SUBSTR(tparm,7,4) || RIGHT(tparm,3)         /* EEJ */
        end                                                   /* EEJ */
        do while rc = 0
          if tparm <> "" then do                              /* EEJ */
            if RIGHT(tmp_LogTime.1,7) > tdate then leave      /* EEJ */
            if RACFTTIM <> "" & ,                             /* EEJ */
               RIGHT(tmp_LogTime.1,7) = tdate & ,             /* EEJ */
               LEFT(tmp_LogTime.1,4) > RACFTTIM then leave    /* EEJ */
          end
          column = tmp_FindPos.1.1                            /* EEJ */
          /* Filter & Continuation Rules for JES2 SYSLOG */
          if EJES_EnvJES = 2 then do
            call EJES_addMSGline 1
            select
              when LEFT(tmp_line.1,1) = "N" then              /* EEJ */
                if LEFT(tmp_line.2,1) = "S" then              /* EEJ */
                   call EJES_addMSGline 2
              when LEFT(tmp_line.1,1) = "M" then              /* EEJ */
                do i = 2 to tmp_line.0                        /* EEJ */
                  call EJES_addMSGline i
                  if LEFT(tmp_line.i,1) = "E" then leave;     /* EEJ */
                end
              otherwise;
            end /* select */
          end
          /* Filter & Continuation Rules for JES3 DLOG */
          else do
            keylen = column - 30
            key = SUBSTR(tmp_line.1,30,keylen)                /* EEJ */
            if logsys = "*" | WORD(key,1) = logsys then do
              call EJES_addMSGline 1
              do i = 2 to tmp_line.0                          /* EEJ */
                if key <> SUBSTR(tmp_line.i,30,keylen) then   /* EEJ */
                   leave
                if SUBSTR(tmp_line.i,column,1) = "I" | ,      /* EEJ */
                   SUBSTR(tmp_line.i,column,1) = "$" then     /* EEJ */
                   leave
                call EJES_addMSGline i
                if SUBSTR(tmp_line.i,column,1) <> " " then    /* EEJ */
                   leave
              end
            end
          end
          DELSTACK
          QUEUE "UP" tmp_line.0                               /* EEJ */
          QUEUE "RFIND"
          QUEUE ""
          ADDRESS EJES "EXECAPI 9 (PRE tmp_"                  /* EEJ */
        end
      end /* msgidx = msgprfx.0 */

      /* Merge IRR and ICH Messages */
      rc = EJESREXX("TERMAPI")
      IRRnum = 1
      ICHnum = 1
      ISFLINE.0 = 0                                           /* EEJ */
      do forever
        select
          when IRRnum <= IRRline.0 then do
            if ICHnum > ICHline.0 then call EJES_logIRRline
            else do
              if IRRtime.IRRnum <= ICHtime.ICHnum then
                 call EJES_logIRRline
              else call EJES_Logichline
            end
            end /* when */
          when IRRnum > IRRline.0 then do
            if ICHnum > ICHline.0 then leave;
            call EJES_Logichline
            end /* when */
          otherwise;
        end
      end

      end /* when */
    otherwise do
      ISFLINE.0 = 0                                           /* EEJ */
      end /* otherwise */
  end /* select */
                                                              /* EEJ */
  K = 0                                                       /* EEJ */
  TOTALMSGS = 0                                               /* EEJ */
  CALL PROCESS_LOG_RECS                                       /* EEJ */
  LOGMSG.0 = K                                                /* EEJ */
  DROP ISFLINE.                                               /* EEJ */
RETURN
/*--------------------------------------------------------------------*/
/*  EJES - SYSLOG logic                                               */
/*--------------------------------------------------------------------*/
EJES_ADDMSGLINE:
  arg ix
  interpret "k =" msgprfx.msgidx || "line.0 + 1"
  interpret msgprfx.msgidx || "line.0 = k"
  interpret msgprfx.msgidx || "line.k = tmp_line.ix"          /* EEJ */
  interpret msgprfx.msgidx || "time.0 = k"
  interpret msgprfx.msgidx || "time.k = tmp_LogTime.ix"       /* EEJ */
  return
/*--------------------------------------------------------------------*/
/*  EJES - IRR messages                                               */
/*--------------------------------------------------------------------*/
EJES_LOGIRRLINE:
    i = ISFLINE.0 + 1                                         /* EEJ */
    ISFLINE.0 = i                                             /* EEJ */
    ISFLINE.i = IRRline.IRRnum                                /* EEJ */
    IRRnum = IRRnum + 1
RETURN
/*--------------------------------------------------------------------*/
/*  EJES - ICH messages                                               */
/*--------------------------------------------------------------------*/
EJES_LOGICHLINE:
  i = ISFLINE.0 + 1                                           /* EEJ */
  ISFLINE.0 = i                                               /* EEJ */
  ISFLINE.i = ICHline.ICHnum                                  /* EEJ */
  ICHnum = ICHnum + 1
RETURN
