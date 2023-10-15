/*%NOCOMMENT====================* REXX *==============================*/
/*  PURPOSE:  RACFADM - User Profile - Opt 1, User Acc Rpt (cmd Y/Z)  */
/*--------------------------------------------------------------------*/
/*  NOTES:    1) The user line command Z, User Access Report,         */
/*               is not displayed as a line command                   */
/*                                                                    */
/*            2) To access/use this command, turn on the Settings     */
/*               (Option 0):                                          */
/*                 Administrator ..... Y                              */
/*                                                                    */
/*            4) Requires DFSORT                                      */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @L2  241014  LBDYCK   Check popup RC                               */
/* @A2  231013  TRIDJK   Add pop-up for mode (Foreground/Background)  */
/* @A1  231007  TRIDJK   Created REXX program                         */
/* @A0  020201  XEPHON   Created SHOWACC, Joao Bentes De Jesus        */
/*====================================================================*/
PANELAC     = "RACFACC"    /* Access mode prompt           */ /* @A2 */
SKELETON1   = "RACFACC"    /* Cross reference JCL          */
parse source . . REXXPGM .         /* Obtain REXX pgm name */
REXXPGM     = LEFT(REXXPGM,8)
Address ISPExec
  "VGET (SETDRPTU ZLLGJOB1 ZLLGJOB2 ZLLGJOB3 ZLLGJOB4) PROFILE"

Address ISPExec
  "VGET (SETGDISP SETMTRAC) PROFILE"
  If (SETMTRAC <> 'NO') then do
     Say "*"COPIES("-",70)"*"
     Say "*"Center("Begin Program = "REXXPGM,70)"*"
     Say "*"COPIES("-",70)"*"
     if (SETMTRAC <> 'PROGRAMS') THEN
        interpret "Trace "SUBSTR(SETMTRAC,1,1)
  end

Parse Arg user parm

'ADDPOP'                                                      /* @A2 */
'DISPLAY PANEL('panelac')'                                    /* @A2 */
prc = rc                                                      /* @L1 */
'REMPOP'                                                      /* @A2 */

if prc > 0 then exit                                          /* @L1 */

if RACFMMOD = 'B' then do
  call get_backup_dsn
  RACFDTMP = racf_dsn
  call create_jcl
  call goodbye
  exit
end

Address TSO
  x = outtrap('delete.','*')
  'delete RACF.DBUNLOAD'
  'delete RACF.T0404'
  'delete RACF.T0505'
  x=outtrap("OFF")

  /*--------------------------------------------*/
  /*  Unload RACF backup dsn                    */
  /*--------------------------------------------*/
  call get_backup_dsn
  'alloc f(sysprint) new reuse unit(sysallda)',
         'space(1,1) tracks'
  "alloc f(indd1)    shr reuse  dsn('"racf_dsn"') bufno(200)"
  'alloc f(outdd)    new reuse unit(sysallda)',
         'lrecl(4096) blksize(0) recfm(v b) bufno(200)',
         'dsn(racf.dbunload) new catalog',
         'space(75,75) tracks'
  "call *(irrdbu00) 'NOLOCKINPUT'"

  /*--------------------------------------------*/
  /*  Sort resource and dataset access reports  */
  /*--------------------------------------------*/
  'alloc f(sortin) da(racf.dbunload)'
  'alloc f(t0404)    new reuse unit(sysallda)',
         'lrecl(264) blksize(0) recfm(f b)',
         'dsn(racf.t0404) catalog',
         'space(1,1) tracks'
  'alloc f(t0505)    new reuse unit(sysallda)',
         'lrecl(264) blksize(0) recfm(f b)',
         'dsn(racf.t0505) catalog',
         'space(1,1) tracks'
  'alloc f(sysin)    new reuse unit(sysallda)',
         'lrecl(80) blksize(0) recfm(f b)',
         'space(1,1) tracks'
  'alloc f(sysout)   new reuse unit(sysallda)',
         'space(1,1) tracks'
  'newstack'
  queue" SORT FIELDS=COPY"
  queue" OPTION VLSHRT"
  queue" OUTFIL FNAMES=T0404,CONVERT,"
  queue" INCLUDE=(5,4,BI,EQ,C'0404',&,62,9,BI,EQ,C'"user"'),"
  queue" OUTREC=(1:C'DATASET ',10:71,9,19:10,52,194X)"
  queue" OUTFIL FNAMES=T0505,CONVERT,"
  queue" INCLUDE=(5,4,BI,EQ,C'0505',&,266,9,BI,EQ,C'"user"'),"
  queue" OUTREC=(1:257,9,10:275,9,19:10,246)"
  queue" END"
  queue
  'Execio * diskw sysin (finis'
  "call *(sort) 'SIZE=MAX'"

  /*--------------------------------------------*/
  /*  Join resource and dataset access reports  */
  /*--------------------------------------------*/
  'alloc f(sysprint) new reuse unit(sysallda)',
         'space(1,1) tracks'
  'alloc f(sysut1)   shr reuse  delete dsn(racf.t0404 racf.t0505)'
  'alloc f(sysut2)   new reuse unit(sysallda)',
         'lrecl(264) blksize(0) recfm(f b)',
         'space(1,1) tracks'
  'alloc f(sysin)    reuse  dummy'
  "call *(iebgener)"

/*---------------------*/
/*  Browse the report  */
/*---------------------*/
Address ISPExec
  'lminit dataid(id) ddname(sysut2)'
  if (rc ^= 0) then do
     racfsmsg = 'Allocation error'
     racflmsg = 'LMINIT failed for SYSUT2'
     'setmsg msg(racf001)'
     call Goodbye
  end
  Select
     When (SETGDISP = "VIEW") THEN
          "VIEW DATAID("id")"
     When (SETGDISP = "EDIT") THEN
          "EDIT DATAID("id")"
     Otherwise
          "browse dataid("id")"
  end
  'lmfree dataid('id')'

Address TSO
  'delstack'
  'free  f(sysprint indd1 outdd sysout sortin sysin)'
  'free  f(t0404 t0505 sysut1 sysut2)'
  'alloc f(sysin) ds(*) reuse'
  call Goodbye
exit
/*--------------------------------------------------------------------*/
/*  Create Batch job                                                  */
/*--------------------------------------------------------------------*/
CREATE_JCL:
ADDRESS ISPEXEC
  /*-----------------------------------------------*/
  /* If IBM's ISPF JOB card variable is:           */
  /*   ZLLGJOB1 =                                  */
  /* or                                            */
  /*   ZLLGJOB1 = //USERID   JOB (ACCOUNT),'NAME'  */
  /* or                                            */
  /*   ZLLGJOB1 = //@??##### JOB (??T),'NAME',etc. */
  /* or                                            */
  /*   ZLLGJOB1 = //JOB-NAME JOB (???),'NAME',etc. */
  /*-----------------------------------------------*/
  PARSE UPPER VAR ZLLGJOB1 W1 .
  IF (ZLLGJOB1 = "") | (W1 = "//USERID") then do
     ZLLGJOB1 = "//job-name JOB (acct),'first-last-name',"
     ZLLGJOB2 = "//         MSGCLASS=?,CLASS=?,"||,
                "REGION=0M,NOTIFY=&SYSUID"
     "VPUT (ZLLGJOB1 ZLLGJOB2)"
  END
  TMPDRPTU = STRIP(SETDRPTU,,"'")
  "FTOPEN TEMP"
  "VGET (ZTEMPF)"
  "FTINCL "SKELETON1
  "FTCLOSE"
  "EDIT DATASET('"ztempf"')"
RETURN
get_backup_dsn:
/*--------------------------------------------*/
/*  Get RACF backup dsn                       */
/*--------------------------------------------*/
Address TSO
  x=outtrap(info.)
  "RVARY"
  x=outtrap("OFF")
  if rc=0 then
  racf_dsn=""
  do a=1 to info.0
     if word(info.a,1)="YES" &,
       word(info.a,2)="BACK" then
     do
        racf_dsn=word(info.a,words(info.a))
        leave a
     end
  end
  return
/*--------------------------------------------------------------------*/
/*  If tracing is on, display flower box                              */
/*--------------------------------------------------------------------*/
Goodbye:
  If (SETMTRAC <> 'NO') then do
     Say "*"COPIES("-",70)"*"
     Say "*"Center("End Program = "REXXPGM,70)"*"
     Say "*"COPIES("-",70)"*"
  end
return
