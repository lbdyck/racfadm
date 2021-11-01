/*%NOCOMMENT====================* REXX *==============================*/
/*  PURPOSE:  RACFADM - Group Tree Report - Menu option 6             */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @AJ  200616  RACFA    Chg panel name RACFRPTS to RACFDISP          */
/* @AI  200506  LBD      Add ISPF Variable for report                 */
/* @AH  200506  RACFA    Fix spaces from text between paranthesis (.) */
/* @AG  200506  LBD      Disp rpt header and bar lines in diff. color */
/* @AF  200503  RACFA    Add 'Please be patient' message              */
/* @AE  200429  RACFA    Re-arranged variables (General, Mgmt, TSO)   */
/* @AD  200423  RACFA    Move PARSE REXXPGM name up above IF SETMTRAC */
/* @AC  200423  RACFA    Removed blank in column 1 of report          */
/* @AB  200423  RACFA    Do not chk for titles when looping thru rpt  */
/* @AA  200423  RACFA    Ensure REXX program name is 8 chars long     */
/* @A9  200423  RACFA    Fix placing ')' at end of rpt title          */
/* @A8  200422  RACFA    Remove leading space in front of ')'         */
/* @A7  200417  RACFA    Free file when done using                    */
/* @A5  200417  RACFA    Chg edit macro, add code to del blank rows   */
/* @A4  200417  TRIDJK   When EDIT/VIEW, remove blank rows/lines      */
/* @A3  200417  RACFA    Removed 'enq(exclu)', not needed             */
/* @A2  200416  RACFA    Honor users setting on displaying of file    */
/* @A1  200416  RACFA    Increased size of SYSPRINT                   */
/* @A0  200416  TRIDJK   Created REXX program                         */
/*====================================================================*/
PANEL01     = "RACFDISP"   /* Display report with colors   */ /* @AJ */
EDITMACR    = "RACFEMAC"   /* Edit Macro, turn hilite off  */ /* @A5 */
DDNAME      = "RACFA"RANDOM(0,999) /* Unique ddname        */ /* @A5 */
parse source . . REXXPGM .         /* Obtain REXX pgm name */ /* @AD */
REXXPGM     = LEFT(REXXPGM,8)                                 /* @AD */

ADDRESS ISPEXEC
  "VGET (SETGDISP SETMTRAC) PROFILE"                          /* @AE */
  If (SETMTRAC <> 'NO') then do
     Say "*"COPIES("-",70)"*"
     Say "*"Center("Begin Program = "REXXPGM,70)"*"
     Say "*"COPIES("-",70)"*"
     if (SETMTRAC <> 'PROGRAMS') THEN
        interpret "Trace "SUBSTR(SETMTRAC,1,1)
  end
  racflmsg = "Retrieving data - Please be patient"            /* @AF */
  "control display lock"                                      /* @AF */
  "display msg(RACF011)"                                      /* @AF */

Address TSO
  /*--------------------------------------------*/
  /*  Call ICHDSM00 for group tree report       */
  /*--------------------------------------------*/
  'alloc f(sysprint) new reuse unit(sysallda)',
         'space(1,1) tracks'
  'alloc f(sysut2)   new reuse unit(sysallda)',
         'space(20,50) cylinders',                            /* @A1 */
         'recfm(F B A) lrecl(133) blksize(0)'                 /* @A1 */
  'alloc f(sysin)    new reuse unit(sysallda)',
         'lrecl(80) blksize(0) recfm(f b)',
         'space(1,1) tracks'
  'newstack'
  queue 'LINECOUNT 0'
  queue 'FUNCTION RACGRP'
  queue
  'Execio * diskw sysin (finis'

  "call *(ichdsm00)"

  /*--------------------------------------------*/
  /*  Remove empty rows/lines and format report */
  /*--------------------------------------------*/
  'execio * diskr sysut2 (stem sysut2. finis'                 /* @A5 */
  'free  f(sysprint sysut2 sysin)'
  'delstack'

  rec.1 = substr(sysut2.1,2)                                  /* @AC */
  rec.2 = strip(substr(sysut2.2,2))                           /* @AC */
  K = 2                                                       /* @A5 */
  do J = 3 To sysut2.0                                        /* @A5 */
     sysut2.J = Substr(sysut2.J,2)                            /* @AC */
     parse var sysut2.j W1 W2 .                               /* @A5 */
     Select                                                   /* @A5 */
        when (W1 = '|') then iterate                          /* @A5 */
        when (W1 = ' ') then iterate                          /* @A5 */
        otherwise                                             /* @A5 */
             nop                                              /* @A5 */
     end                                                      /* @A5 */
     PARSE VAR SYSUT2.J W1 "(" W2 ")" W3                      /* @AH */
     K = K + 1                                                /* @A5 */
     SELECT                                                   /* @AH */
        WHEN (W2 = "") THEN                                   /* @AH */
             REC.K = W1                                       /* @AH */
        OTHERWISE                                             /* @AH */
             REC.K = W1"("STRIP(W2)")"W3                      /* @AH */
     END                                                      /* @AH */
  end                                                         /* @A5 */
  rec.0 = K                                                   /* @A5 */
  drop sysut2.                                                /* @A5 */
                                                              /* @A5 */
  'alloc f('DDNAME')  new reuse unit(sysallda)',              /* @A5 */
         'space(20,50) cylinders',                            /* @A5 */
         'recfm(F B A) lrecl(133) blksize(0)'                 /* @A5 */
  'execio * diskw 'DDNAME' (stem rec. finis'                  /* @A5 */
  drop rec.                                                   /* @A5 */

Address ISPExec
  /*---------------------*/
  /*  Browse the report  */
  /*---------------------*/
  'lminit dataid(id) ddname('DDNAME')'                        /* @A5 */
  if (rc ^= 0) then do
     racfsmsg = 'Allocation error'
     racflmsg = 'LMINIT failed for 'DDNAME                    /* @A5 */
     'setmsg msg(racf001)'
     call Goodbye
  end
  vtype = 'TREE'                                              /* @AI */
  'vput (vtype) shared'                                       /* @AI */
  SELECT                                                      /* @A2 */
     WHEN (SETGDISP = "VIEW") THEN                            /* @A2 */
          "VIEW DATAID("ID") MACRO("EDITMACR")",              /* @A2 */
               "PANEL("PANEL01")"                             /* @AG */
     WHEN (SETGDISP = "EDIT") THEN                            /* @A2 */
          "EDIT DATAID("ID") MACRO("EDITMACR")",              /* @A2 */
               "PANEL("PANEL01")"                             /* @AG */
     OTHERWISE                                                /* @A2 */
          "BROWSE DATAID("ID")"                               /* @A2 */
  END                                                         /* @A2 */
  vtype = ''                                                  /* @AI */
  'vput (vtype) shared'                                       /* @AI */
  'lmfree dataid('id')'
  Address TSO 'Free fi('DDNAME')'                             /* @A7 */
  call Goodbye
EXIT
/*--------------------------------------------------------------------*/
/*  If tracing is on, display flower box                              */
/*--------------------------------------------------------------------*/
GOODBYE:
  If (SETMTRAC <> 'NO') then do
     Say "*"COPIES("-",70)"*"
     Say "*"Center("End Program = "REXXPGM,70)"*"
     Say "*"COPIES("-",70)"*"
  end
EXIT
