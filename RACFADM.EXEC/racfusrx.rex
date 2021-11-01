/*%NOCOMMENT====================* REXX *==============================*/
/*  PURPOSE:  RACFADM - User Profile - Opt 1, Cross Ref. Rpt (cmd XR) */
/*--------------------------------------------------------------------*/
/*  NOTES:    1) This user line command XR, Cross Reference Report,   */
/*               is not displayed as a line command                   */
/*                                                                    */
/*            2) Reason for this is sites with a large RACF database, */
/*               the time for IRRUT100 to read/obtain the data is     */
/*               significant                                          */
/*                                                                    */
/*            3) To access/use this command, turn on the Settings     */
/*               (Option 0):                                          */
/*                 Administrator ..... Y                              */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @AC  201201  TRIDJK   Allow user to change/define JOB card         */
/* @AB  201130  TRIDJK   Added code to submit batch job               */
/* @AA  200429  RACFA    Re-arranged variables (General, Mgmt, TSO)   */
/* @A9  200423  RACFA    Move PARSE REXXPGM name up above IF SETMTRAC */
/* @A8  200423  RACFA    Ensure REXX program name is 8 chars long     */
/* @A7  200422  TRIDJK   Added capability to browse/edit/view file    */
/* @A6  200417  RACFA    Removed 'enq(exclu)', not needed             */
/* @A5  200413  RACFA    Chg TRACEing to only display banner (P=Pgms) */
/* @A4  200412  RACFA    Chg TRACE to allow 'L'abels or 'R'esults     */
/* @A3  200301  RACFA    Standardize messaging                        */
/* @A2  200221  RACFA    Make 'ADDRESS ISPEXEC' defualt, reduce code  */
/* @A1  200220  RACFA    Added SETMTRAC=YES, then TRACE R             */
/* @A0  200123  TRIDJK   Created REXX program                         */
/*====================================================================*/
PANEL99     = "RACFRPTJ"   /* Define JOB card/JCL parms    */ /* @AC */
SKELETON1   = "RACFXREF"   /* Cross reference JCL          */ /* @AC */
EDITMACR    = "RACFEMAC"   /* Edit Macro, turn HILITE off  */ /* @A7 */
parse source . . REXXPGM .         /* Obtain REXX pgm name */ /* @A9 */
REXXPGM     = LEFT(REXXPGM,8)                                 /* @A9 */

ADDRESS ISPEXEC                                               /* @A2 */
  "VGET (SETGDISP SETMTRAC) PROFILE"                          /* @AA */
  If (SETMTRAC <> 'NO') then do                               /* @A4 */
     Say "*"COPIES("-",70)"*"                                 /* @A4 */
     Say "*"Center("Begin Program = "REXXPGM,70)"*"           /* @A4 */
     Say "*"COPIES("-",70)"*"                                 /* @A4 */
     if (SETMTRAC <> 'PROGRAMS') THEN                         /* @A5 */
        interpret "Trace "SUBSTR(SETMTRAC,1,1)                /* @A4 */
  end                                                         /* @A4 */
  /*--------------------------------------------*/
  /*  Call IRRUT100 for cross reference report  */
  /*--------------------------------------------*/
Parse Arg user parm                                           /* @AB */

if parm = 'JCC' then do                                       /* @AB */
  call create_jcl                                             /* @AB */
  call goodbye                                                /* @AB */
end                                                           /* @AB */

Address TSO
  x = outtrap('delete.','*')
  'delete irrut100.'result
  x = outtrap('off')
  'alloc f(sysprint) new reuse unit(sysallda)',
         'space(1,1) tracks'
  'alloc f(sysut1)   new reuse unit(sysallda)',
         'space(1,1) tracks'
  'alloc f(sysin)    new reuse unit(sysallda)',
         'lrecl(80) blksize(0) recfm(f b)',
         'space(1,1) tracks'
  'newstack'
  queue user
  queue
  'Execio * diskw sysin (finis'
  "call *(irrut100)"
  'Execio * diskr sysprint (finis stem sysp.'

  /*---------------------*/
  /*  Browse the report  */
  /*---------------------*/
Address ISPExec
  'lminit dataid(id) ddname(sysprint)'                        /* @A6 */
  if (rc ^= 0) then do
     racfsmsg = 'Allocation error'                            /* @A3 */
     racflmsg = 'LMINIT failed for SYSPRINT'                  /* @A3 */
     'setmsg msg(racf001)'                                    /* @A3 */
     call Goodbye                                             /* @DK */
  end
  Select                                                      /* @A7 */
     When (SETGDISP = "VIEW") THEN                            /* @A7 */
          "VIEW DATAID("id") MACRO("EDITMACR")"               /* @A7 */
     When (SETGDISP = "EDIT") THEN                            /* @A7 */
          "EDIT DATAID("id") MACRO("EDITMACR")"               /* @A7 */
     Otherwise                                                /* @A7 */
          'browse dataid('id')'                               /* @A7 */
  end                                                         /* @A7 */
  'lmfree dataid('id')'

Address TSO
  'delstack'
  'free  f(sysut1 sysprint sysin)'
  'alloc f(sysin) ds(*) reuse'

  call Goodbye
EXIT
/*--------------------------------------------------------------------*/
/*  Create Batch job                                             @AC  */
/*--------------------------------------------------------------------*/
CREATE_JCL:                                                   /* @AC */
ADDRESS ISPEXEC                                               /* @AC */
  /*-----------------------------------------------*/         /* @AC */
  /* If IBM's ISPF JOB card variable is:           */         /* @AC */
  /*   ZLLGJOB1 =                                  */         /* @AC */
  /* or                                            */         /* @AC */
  /*   ZLLGJOB1 = //USERID   JOB (ACCOUNT),'NAME'  */         /* @AC */
  /* or                                            */         /* @AC */
  /*   ZLLGJOB1 = //@??##### JOB (??T),'NAME',etc. */         /* @AC */
  /* or                                            */         /* @AC */
  /*   ZLLGJOB1 = //JOB-NAME JOB (???),'NAME',etc. */         /* @AC */
  /*-----------------------------------------------*/         /* @AC */
  PARSE UPPER VAR ZLLGJOB1 W1 .                               /* @AC */
  IF (ZLLGJOB1 = "") | (W1 = "//USERID"),                     /* @AC */
   | (W1 = "//@??#####") | (W1 = "//JOB-NAME") THEN DO        /* @AC */
     TMPZCMD = ZCMD                                           /* @AC */
     CALL DEFINE_JOB_CARD                                     /* @AC */
     ZCMD    = TMPZCMD                                        /* @AC */
  END                                                         /* @AC */
  "FTOPEN TEMP"                                               /* @AC */
  "VGET (ZTEMPF)"                                             /* @AC */
  "FTINCL "SKELETON1                                          /* @AC */
  "FTCLOSE"                                                   /* @AC */
  "EDIT DATASET('"ztempf"')"                                  /* @AC */
RETURN                                                        /* @AC */
/*--------------------------------------------------------------------*/
/*  Define JOB card and JCL parameters                           @AC  */
/*--------------------------------------------------------------------*/
DEFINE_JOB_CARD:                                              /* @AC */
  /*-----------------------------------------------*/         /* @AC */
  /* If IBM's ISPF JOB card variable is:           */         /* @AC */
  /*   ZLLGJOB1 =                                  */         /* @AC */
  /* or                                            */         /* @AC */
  /*   ZLLGJOB1 = //USERID   JOB (ACCOUNT),'NAME'  */         /* @AC */
  /* or                                            */         /* @AC */
  /*   ZLLGJOB1 = //@??##### JOB (??T),'NAME',etc. */         /* @AC */
  /*-----------------------------------------------*/         /* @AC */
  PARSE UPPER VAR ZLLGJOB1 W1 .                               /* @AC */
  IF (ZLLGJOB1 = "") | (W1 = "//USERID") then do              /* @AC */
     ZLLGJOB1 = "//job-name JOB (acct),'first-last-name',"    /* @AC */
     ZLLGJOB2 = "//         MSGCLASS=?,CLASS=?,"||,           /* @AC */
                "REGION=0M,NOTIFY=&SYSUID"                    /* @AC */
     "VPUT (ZLLGJOB1 ZLLGJOB2)"                               /* @AC */
  END                                                         /* @AC */
                                                              /* @AC */
  'control display save'                                      /* @AC */
  "ADDPOP"                                                    /* @AC */
  DO FOREVER                                                  /* @AC */
     "DISPLAY PANEL("PANEL99")"                               /* @AC */
     IF (RC = 8) THEN LEAVE                                   /* @AC */
  END                                                         /* @AC */
  "REMPOP"                                                    /* @AC */
  'control display restore'                                   /* @AC */
  "VPUT (ZLLGJOB1 ZLLGJOB2 ZLLGJOB3 ZLLGJOB4) PROFILE"        /* @AC */
RETURN                                                        /* @AC */
/*--------------------------------------------------------------------*/
/*  If tracing is on, display flower box                         @A1  */
/*--------------------------------------------------------------------*/
GOODBYE:                                                      /* @A1 */
  If (SETMTRAC <> 'NO') then do                               /* @A1 */
     Say "*"COPIES("-",70)"*"                                 /* @A1 */
     Say "*"Center("End Program = "REXXPGM,70)"*"             /* @A1 */
     Say "*"COPIES("-",70)"*"                                 /* @A1 */
  end                                                         /* @A1 */
EXIT                                                          /* @AC */
