/*%NOCOMMENT====================* REXX *==============================*/
/*PURPOSE:  RACFADM - Run VUECERTP program (Charles Mills)            */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @JK  251117  TRIDJK   Support INDEX and USERS report outputs       */
/* @L2  251115  LBD      Add popup to prompt for option               */
/* @L1  251114  LBD      Use Select PGM instead of LINKMVS            */
/* @A0  251108  TRIDJK   Creation                                     */
/*====================================================================*/
TRACE
DDNAME      = 'RACFA'RANDOM(0,999) /* Unique ddname          */
parse source . . REXXPGM .         /* Obtain REXX pgm name   */
REXXPGM     = LEFT(REXXPGM,8)

Parse upper arg parm
If parm = 'VERB' then
  parm = '{"VERBOSE":TRUE}'
Address ISPexec

if parm = '' then do                                        /* @L2 */
   'AddPop Row(4) Column(20)'                               /* @L2 */
   'DISPLAY PANEL(racfvuec)'                                /* @L2 */
   disprc = RC                                              /* @L2 */
   'REMPOP'                                                 /* @L2 */
   if disprc > 0 then return 4                              /* @L2 */
   parm = vopt                                              /* @L2 */
   end                                                      /* @L2 */

"CONTROL ERRORS RETURN"
"VGET (SETGSTA  SETGSTAP SETGDISP SETMADMN",
      "SETMIRRX SETMSHOW SETMTRAC SETTPSWD",
      "SETTPROF SETTUDSN SETMPHRA SETTCTLG) PROFILE"
If (SETMTRAC <> 'NO') then do
   Say "*"COPIES("-",70)"*"
   Say "*"Center("Begin Program = "REXXPGM,70)"*"
   Say "*"COPIES("-",70)"*"
   if (SETMTRAC <> 'PROGRAMS') THEN
      interpret "Trace "SUBSTR(SETMTRAC,1,1)
   end

Address TSO
"ALLOC F(SYSPRINT) UNIT(VIO) NEW REUSE SPACE(15,15) TRACKS",
  "LRECL(200) RECFM(F B)"
Select
  When parm = 'CMDS' then
    "ALLOC F(COMMANDS) UNIT(VIO) NEW REUSE SPACE(1,1) TRACKS",
      "LRECL(80) RECFM(F B)"
  When parm = 'USERS' then
    "ALLOC F(USERIDS) UNIT(VIO) NEW REUSE SPACE(1,1) TRACKS",
      "LRECL(80) RECFM(F B)"
  When parm = 'INDEX' then
    "ALLOC F(INDEX) UNIT(VIO) NEW REUSE SPACE(1,1) TRACKS",
      "LRECL(256) RECFM(F B)"
  Otherwise NOP
End

Address ISPEXEC
'Select pgm(vuecertp) parm('parm')'                          /* @L1 */
if rc = 20 then do
  RACFSMSG = "VUE not found"
  RACFLMSG = "VUECERTP program not found"
  "SETMSG MSG(RACF011)"
  Call FREE
  RETURN
  end

zerrsm = "RACFADM "REXXPGM" RC=0"
zerrlm = "VUECERTP" parm
Address ISPexec
'log msg(isrz003)'

Select
  When parm = 'CMDS' then
    "ISPEXEC LMINIT DATAID(ID) DDNAME(COMMANDS) ENQ(EXCLU)"
  When parm = 'INDEX' then
    "ISPEXEC LMINIT DATAID(ID) DDNAME(INDEX) ENQ(EXCLU)"
  When parm = 'USERS' then
    "ISPEXEC LMINIT DATAID(ID) DDNAME(USERIDS) ENQ(EXCLU)"
  Otherwise
    "ISPEXEC LMINIT DATAID(ID) DDNAME(SYSPRINT) ENQ(EXCLU)"
End
If rc ^= 0 Then
  Do
    Say LMINIT failed
    Exit 12
  End

if parm = "RINGS" then
  "ISPEXEC VIEW DATAID("id") macro(racfvmac)"
else
  "ISPEXEC VIEW DATAID("id")"

"ISPEXEC LMFREE DATAID("id")"

Free:
Address TSO
"ALLOC F(SYSPRINT) DA(*) SHR REUSE"
Select
  When parm = 'CMDS' then
    "FREE  F(COMMANDS)"
  When parm = 'INDEX' then
    "FREE  F(INDEX)"
  When parm = 'USERS' then
    "FREE  F(USERIDS)"
  Otherwise NOP
End
RETURN
