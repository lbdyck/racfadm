/*%NOCOMMENT====================* REXX *==============================*/
/*PURPOSE:  RACFADM - Alter selected User Profile segments            */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @A1  250208  TRIDJK   Return to panel display after processing     */
/* @A0  250205  TRIDJK   Creation                                     */
/*====================================================================*/
TRACE
PANELAL     = 'RACFUS5A'           /* Alter prompt popup panel */
DDNAME      = 'RACFA'RANDOM(0,999) /* Unique ddname        */
EDITMACR    = "RACFMRUN"   /* Edit Macro, RACRUN MSG       */
parse source . . REXXPGM .         /* Obtain REXX pgm name */
REXXPGM     = LEFT(REXXPGM,8)

Arg user

Address ISPexec
"CONTROL ERRORS RETURN"
"VGET (SETGSTA  SETGSTAP SETGDISP SETMADMN",
      "SETMIRRX SETMSHOW SETMTRAC SETTPSWD",
      "SETTPROF SETTUDSN SETMPHRA SETTCTLG) PROFILE"

Display_Panel:
Do Forever                                                    /* @A1 */
Address ISPexec
'display panel('PANELAL')'
 disprc = RC
if (disprc > 0) then
  exit

cmd  = 'SEARCH USER('user')'
x    = outtrap('search.')
Address TSO cmd
x    = outtrap('off')

if pos('NOT DEFINED TO RACF',search.1) > 1 then do
  racfsmsg = 'Not defined'
  racflmsg = 'User 'user' not defined to RACF'
  'setmsg msg(RACF011)'
  iterate                                                     /* @A1 */
  end

If (SETMTRAC <> 'NO') then do
   Say "*"COPIES("-",70)"*"
   Say "*"Center("Begin Program = "REXXPGM,70)"*"
   Say "*"COPIES("-",70)"*"
   if (SETMTRAC <> 'PROGRAMS') THEN
      interpret "Trace "SUBSTR(SETMTRAC,1,1)
   end

Address TSO
rxrc=IRRXUTIL("EXTRACT","USER",user,"RACF","")
if (word(rxrc,1) <> 0) then do
   say 'IRRXUTIL return code:'rxrc
   exit
   end

cmd. = ""
y = 0
do i=1 to RACF.0 /* get the segment names */
  segment=RACF.i
  if segment = 'BASE' then do
    uattr = ''
    if racf.base.special.1 = 'TRUE' then uattr = uattr || 'SPECIAL '
    if racf.base.oper.1    = 'TRUE' then uattr = uattr || 'OPERATIONS '
    if racf.base.grpacc.1  = 'TRUE' then uattr = uattr || 'GRPACC '
    if racf.base.auditor.1 = 'TRUE' then uattr = uattr || 'AUDITOR '
    if racf.base.roaudit.1 = 'TRUE' then uattr = uattr || 'ROAUDIT '
    if racf.base.rest.1    = 'TRUE' then uattr = uattr || 'RESTRICTED '
    if racf.base.adsp.1    = 'TRUE' then uattr = uattr || 'ADSP '

    y = y + 1
    cmd.y = " ALTUSER " user "NAME('"racf.base.name.1"')" "-"
    y = y + 1
    cmd.y = "  "uattr "-"
    y = y + 1
    cmd.y = "  OWNER("racf.base.owner.1")" "-"
    y = y + 1
    cmd.y = "  DFLTGRP("racf.base.dfltgrp.1")" "-"
    y = y + 1
    cmd.y = "  DATA('"strip(left(racf.base.data.1,56))"')" "-"
    iterate
    end

  if wordpos(segment,usegs) = 0 then
    iterate

  y = y + 1
  cmd.y = " "segment"(" "-"
  do j=1 to RACF.segment.0
    field=RACF.segment.j

    /* ALTUSER edits */
    if racf.segment.field.1 = '' then
      iterate
    if field = 'UID' then do
      y = y + 1
      cmd.y = "  AUTOUID" "-"
      iterate
      end
    if field = 'AUTOLOG' then
      racf.segment.field.1 = 'YES'
    if pos(" ",racf.segment.field.1) > 0 then
      racf.segment.field.1 = "'"||racf.segment.field.1||"'"

    aufld = field
    call Altuser_Fields
    if racf.segment.field.1 = 'TRUE' then
      racf.segment.field.1 = 'YES'
    if racf.segment.field.1 = 'FALSE' then
      racf.segment.field.1 = 'NO'
    y = y + 1
    cmd.y = "  "aufld"("racf.segment.field.1")" "-"
    end

    y = y + 1
    cmd.y = " )" "-"
  end

  if lastpos("-",cmd.y) > 0 then
    cmd.y = delstr(cmd.y,lastpos("-",cmd.y))

  cmd.0 = y
  call Display_Commands
  zerrsm = "RACFADM "REXXPGM" RC=0"
  zerrlm = "ALTUSER "user usegs
  Address ISPexec
  'log msg(isrz003)'

  end  /* Forever */                                          /* @A1 */
exit

/* Adjust operand names to ALTUSER conventions */
Altuser_Fields:
  select
    when field = 'AUTOLOG'  then aufld = 'AUTOLOGIN'   /* DCE      */
    when field = 'MAXTKTLF' then aufld = 'MAXTKTLFE'   /* KERB     */
    when field = 'SECOND'   then aufld = 'SECONDARY'   /* LANGUAGE */
    when field = 'ASSIZE'   then aufld = 'ASSIZEMAX'   /* OMVS     */
    when field = 'CPUTIME'  then aufld = 'CPUTIMEMAX'  /* OMVS     */
    when field = 'FILEPROC' then aufld = 'FILEPROCMAX' /* OMVS     */
    when field = 'MMAPAREA' then aufld = 'MMAPAREAMAX' /* OMVS     */
    when field = 'PROCUSER' then aufld = 'PROCUSERMAX' /* OMVS     */
    when field = 'THREADS'  then aufld = 'THREADSMAX'  /* OMVS     */
    when field = 'LOGCMD'   then aufld = 'LOGCMDRESP'  /* OPERPARM */
    when field = 'OPERAUTH' then aufld = 'AUTH'        /* OPERPARM */
    when field = 'VHOME'    then aufld = 'HOME'        /* OVM      */
    when field = 'VPROGRAM' then aufld = 'PROGRAM'     /* OVM      */
    when field = 'VUID'     then aufld = 'UID'         /* OVM      */
    when field = 'HLDCLASS' then aufld = 'HOLDCLASS'   /* TSO      */
    otherwise nop
    end
return
/*--------------------------------------------------------------------*/
/*  Edit information                                                  */
/*--------------------------------------------------------------------*/
Display_Commands:
  Address TSO "alloc f("ddname") new reuse",
              "lrecl(80) blksize(0) recfm(f b)",
              "unit(vio) space(1 5) cylinders"
  Address TSO "execio * diskw "ddname" (stem cmd. finis"
  drop cmd.

  Address ISPexec
  "lminit dataid(cmddatid) ddname("ddname")"
  "edit dataid("cmddatid") macro("editmacr")"
  Address TSO "free fi("ddname")"
return

drop racf.
return
