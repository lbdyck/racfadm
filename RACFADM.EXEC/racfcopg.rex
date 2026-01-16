/*%NOCOMMENT====================* REXX *==============================*/
/*PURPOSE:  RACFADM - Clone Group Profiles in table                   */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @A0  251201  TRIDJK   Creation                                     */
/*====================================================================*/
DDNAME      = 'RACFA'RANDOM(0,999) /* Unique ddname        */
EDITMACR    = "RACFMRUN"   /* Edit Macro, RACRUN MSG       */
parse source . . REXXPGM .         /* Obtain REXX pgm name */
REXXPGM     = LEFT(REXXPGM,8)

Arg groups

Address ISPexec
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

cmd. = ""
y = 0
group_cnt = words(groups)

Do n = 1 to group_cnt
  parse var groups group groups

Address TSO
rxrc=IRRXUTIL("EXTRACT","GROUP",group,"RACF","")
if (word(rxrc,1) <> 0) then do
   say 'IRRXUTIL return code:'rxrc
   exit
   end

do i=1 to RACF.0 /* get the segment names */
  segment=RACF.i
  if segment = 'BASE' then do
    y = y + 1
    cmd.y = " ADDGROUP "group" " "-"
    y = y + 1
    cmd.y = "  OWNER("racf.base.owner.1")" "-"
    y = y + 1
    cmd.y = "  SUPGROUP("racf.base.supgroup.1")" "-"
    if racf.base.universl.1 = 'TRUE' then do
      y = y + 1
      cmd.y = "  UNIVERSAL" "-"
      end
    y = y + 1
    cmd.y = "  DATA('"strip(left(racf.base.data.1,56))"')" "-"
    iterate
    end

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

  if racf.base.connects.repeatcount = '' then
    iterate

  do i = 1 to racf.base.connects.repeatcount
    y = y + 1
    cmd.y = " CONNECT" racf.base.guserid.i "GROUP("group")",
            "AUTH("racf.base.gauth.i")"
    end
  end

  cmd.0 = y
  call Display_Commands

  Address ISPExec
  zerrsm = "RACFADM "REXXPGM" RC=0"
  zerrlm = "CLONE TABLE A GROUP PROFILES"
  'log msg(isrz003)'
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

drop racf.
return
