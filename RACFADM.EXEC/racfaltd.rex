/*%NOCOMMENT====================* REXX *==============================*/
/*PURPOSE:  RACFADM - Alter selected Dataset Profile segments         */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @A0  250314  TRIDJK   Creation                                     */
/*====================================================================*/
PANELAL     = 'RACFDSN8'           /* Alter prompt popup panel */
DDNAME      = 'RACFA'RANDOM(0,999) /* Unique ddname        */
EDITMACR    = "RACFMRUN"   /* Edit Macro, RACRUN MSG       */
parse source . . REXXPGM .         /* Obtain REXX pgm name */
REXXPGM     = LEFT(REXXPGM,8)

Arg dsn

Address ISPexec
"CONTROL ERRORS RETURN"
"VGET (SETGSTA  SETGSTAP SETGDISP SETMADMN",
      "SETMIRRX SETMSHOW SETMTRAC SETTPSWD",
      "SETTPROF SETTUDSN SETMPHRA SETTCTLG) PROFILE"

Display_Panel:
Do Forever
Address ISPexec
'display panel('PANELAL')'
 disprc = RC
if (disprc > 0) then
  exit

cmd  = 'SEARCH CLASS('dsn')'
x    = outtrap('search.')
Address TSO cmd
x    = outtrap('off')

if pos('NOT DEFINED TO RACF',search.1) > 1 then do
  racfsmsg = 'Not defined'
  racflmsg = 'Dataset 'dsn' not defined to RACF'
  'setmsg msg(RACF011)'
  iterate
  end

If (SETMTRAC <> 'NO') then do
   Say "*"COPIES("-",70)"*"
   Say "*"Center("Begin Program = "REXXPGM,70)"*"
   Say "*"COPIES("-",70)"*"
   if (SETMTRAC <> 'PROGRAMS') THEN
      interpret "Trace "SUBSTR(SETMTRAC,1,1)
   end

Address TSO
rxrc=IRRXUTIL("EXTRACT","DATASET",dsn,"RACF","")
if (word(rxrc,1) <> 0) then do
   say 'IRRXUTIL return code:'rxrc
   exit
   end

cmd. = ""
y = 0
do i=1 to RACF.0 /* get the segment names */
  segment=RACF.i
  if segment = 'BASE' then do
    y = y + 1
    cmd.y = " ALTDSD '"dsn"'" "-"
    y = y + 1
    cmd.y = "  OWNER("racf.base.owner.1")" "-"
    y = y + 1
    cmd.y = "  UACC("racf.base.uacc.1")" "-"
    y = y + 1
    cmd.y = "  AUDIT("racf.base.raudit.1")" "-"
    y = y + 1
    cmd.y = "  DATA('"strip(left(racf.base.data.1,56))"')" "-"
    iterate
    end

  if wordpos(segment,dsegs) = 0 then
    iterate

  y = y + 1
  cmd.y = " "segment"(" "-"
  do j=1 to RACF.segment.0
    field=RACF.segment.j
    if racf.segment.field.1 = '' then
      iterate
    y = y + 1
    cmd.y = "  "field"("strip(racf.segment.field.1)")" "-"
    end

    y = y + 1
    cmd.y = " )" "-"
  end

  if lastpos("-",cmd.y) > 0 then
    cmd.y = delstr(cmd.y,lastpos("-",cmd.y))

  cmd.0 = y
  call Display_Commands
  zerrsm = "RACFADM "REXXPGM" RC=0"
  zerrlm = "ALTDSD "dsn dsegs
  Address ISPexec
  'log msg(isrz003)'

  end  /* Forever */
exit

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
