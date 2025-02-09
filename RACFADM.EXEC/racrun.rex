/*%NOCOMMENT====================* REXX *==============================*/
/*PURPOSE:  RACFADM - Edit macro to run RACF commands in Edit buffer  */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @A2  250207  TRIDJK   If no command output, then no Edit           */
/* @A1  250116  TRIDJK   Modified for RACFADM                         */
/* @A0  161028  LBDYCK   RUNTSOC exec (inspired by Bill Smith)        */
/*====================================================================*/
/* ---------------------------------------------------------- *
 | Usage Notes: 1. Select records with RACF commands using    |
 |                 line tags, C, C#, or CC and CC.            |
 |              2. Data lines starting with * or that are     |
 |                 all blank will be ignored.                 |
 |              3. Command continuation lines (with -) will   |
 |                 be concatenated to following lines.        |
 * ---------------------------------------------------------- */
Address ISREdit
'Macro (options) NOPROCESS'
/* ---------------------------------------------------- *
 | Check for processing options                         |
 |                                                      |
 | 1.  HELP to display a short help text                |
 * ---------------------------------------------------- */
options = translate(options)
if options = 'HELP' then call help
if options = '?'    then call help

PANELD1     = "RACFDISP"   /* Display report with colors   */
DDNAME      = 'RACFA'RANDOM(0,999) /* Unique DDNAME        */
parse source . . rexxpgm .         /* Obtain REXX pgm name */
rexxpgm     = left(rexxpgm,8)

Address ISPexec
"CONTROL ERRORS RETURN"
"VGET (SETGSTA  SETGSTAP SETGDISP SETMADMN",
      "SETMIRRX SETMSHOW SETMTRAC SETTPSWD",
      "SETTPROF SETTUDSN SETMPHRA) PROFILE"
If (SETMTRAC <> 'NO') then do
  Say "*"COPIES("-",70)"*"
  Say "*"Center("Begin Program = "REXXPGM,70)"*"
  Say "*"COPIES("-",70)"*"
  if (SETMTRAC <> 'PROGRAMS') THEN
     interpret "Trace "SUBSTR(SETMTRAC,1,1)
  end
/* ------------------------------------------------------- *
 | Get the range of records to process as                  |
 | RACF commands.                                          |
 |                                                         |
 | The range is specified using the C, C# or CC line tags. |
 * ------------------------------------------------------- */
 Address ISRedit
 'Process Range C'
 If rc > 0 Then Do
   zedsmsg = 'Enter "Cn" line cmd'
   zedlmsg = 'You must specify the RACF command lines',
             'to be executed, using "Cn" or "CC"'
   Address ISPEXEC "SETMSG MSG(ISRZ001)"
   Exit 12
   End
 "(cmd) = range_cmd"
 "(start) = linenum .zfrange"
 "(stop)  = linenum .zlrange"
/* --------------------------------------------------- *
 | Process the selected records:                       |
 |                                                     |
 | 1. Blank records are ignored                        |
 | 2. Records starting with * are ignored              |
 | 3. All other records are assumed to be RACF Commands|
 |    and are executed as such                         |
 * --------------------------------------------------- */
Address TSO
call outtrap 'rec.'
prev_cmd = ''
do l = start to stop
  Address ISRedit
  '(cmd) = line' l
  if left(cmd,1) = '*' then iterate
  if strip(cmd)  = '' then iterate
  cmd = strip(cmd)
  /* Concatenate continuations */
  if right(cmd,1) = '-' then do
    prev_cmd = prev_cmd || substr(cmd,1,pos('-',cmd) -1)
    iterate
    end
  if prev_cmd <> '' then do
    prev_cmd = prev_cmd || cmd
    cmd = prev_cmd
    prev_cmd = ''
    end
  Address TSO cmd
  cmd_rc = rc
  IF SETMSHOW <> 'NO' THEN
     CALL SHOWCMD
  end
Call Outtrap 'OFF'
zerrlm = cmd 'return code is 'cmd_rc
zerrsm = 'RC:'cmd_rc
zerralrm = 'NO'
Address ISPExec
'setmsg msg(isrz002)'
if rec.0 = 0 then do                                          /* @A2 */
  exit                                                        /* @A2 */
  end                                                         /* @A2 */
Call Edit_Info
Exit
/*--------------------------------------------------------------------*/
/*  Display RACF command and return code                              */
/*--------------------------------------------------------------------*/
SHOWCMD:
  Address ISPexec
  IF (SETMSHOW = "BOTH") | (SETMSHOW = "DISPLAY") THEN DO
     PARSE VAR CMD MSG1 60 MSG2 121 MSG3
     MSG4 = "Return code = "cmd_rc
     "ADDPOP ROW(6) COLUMN(4)"
     "DISPLAY PANEL("PANELM2")"
     "REMPOP"
  END
  IF (SETMSHOW = "BOTH") | (SETMSHOW = "LOG") THEN DO
     zerrsm = "RACFADM "REXXPGM" RC="cmd_rc
     zerrlm = cmd
     'log msg(isrz003)'
  END
RETURN
/*--------------------------------------------------------------------*/
/*  Edit information                                                  */
/*--------------------------------------------------------------------*/
EDIT_INFO:
  ADDRESS TSO "ALLOC F("DDNAME") NEW REUSE",
              "LRECL(80) BLKSIZE(0) RECFM(F B)",
              "UNIT(VIO) SPACE(1 5) CYLINDERS"
  ADDRESS TSO "EXECIO * DISKW "DDNAME" (STEM REC. FINIS"
  DROP REC.
  ADDRESS ISPEXEC
  "LMINIT DATAID(CMDDATID) DDNAME("DDNAME")"
  "EDIT DATAID("CMDDATID")"
  ADDRESS TSO "FREE FI("DDNAME")"
RETURN
/*--------------------------------------------------------------------*/
/*  Help information                                                  */
/*--------------------------------------------------------------------*/
HELP:
ADDRESS ISPEXEC "SELECT PGM(ISPTUTOR) PARM(#RACRUN)"
EXIT
