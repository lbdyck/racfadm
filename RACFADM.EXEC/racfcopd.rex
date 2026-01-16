/*%NOCOMMENT====================* REXX *==============================*/
/*PURPOSE:  RACFADM - Clone Dataset Profiles in table                 */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @A0  251202  Janko    Creation                                     */
/*====================================================================*/
EDITMACR    = "RACFMRUN"   /* Edit Macro, RACRUN MSG       */
DDNAME      = 'RACFA'RANDOM(0,999) /* Unique ddname        */
parse source . . REXXPGM .         /* Obtain REXX pgm name */
REXXPGM     = LEFT(REXXPGM,8)

Arg datasets

Address ISPEXEC
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

class = 'DATASET'
cmd. = ""
y = 0
dataset_cnt = words(datasets)

Do n = 1 to dataset_cnt
  parse var datasets dataset datasets

  Address TSO
  rxrc=IRRXUTIL("EXTRACT",class,dataset,"RACF","")
  if (word(rxrc,1) <> 0) then do
     /* Probably a discrete profile defined as generic
     say 'IRRXUTIL return code:'rxrc
     */
     iterate
     end

  profile = dataset
  type = ''
  if pos('*',profile) > 0 then
    type = 'GEN'

  do i=1 to RACF.0 /* get the segment names */
    segment=RACF.i
    if segment = 'BASE' then do
      y = y + 1
      cmd.y = " ADDSD "profile"" "-"
      y = y + 1
      cmd.y = "  LEVEL("racf.base.level.1")" "-"
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

    y = y + 1
    cmd.y = " "segment"(" "-"
    do j=1 to RACF.segment.0
      field=RACF.segment.j
      if racf.segment.field.1 = '' then
        iterate
      y = y + 1
      cmd.y = "  "field"("racf.segment.field.1")" "-"
      end
      if i = racf.0 then do
        y = y + 1
        cmd.y = " )"
        end
      else do
        y = y + 1
        cmd.y = " )" "-"
        end
      end

  if RACF.0 = 1 then
    cmd.y = strip(cmd.y,t,'-')

  if racf.base.aclcnt.repeatcount <> '' then do
    do a=1 to racf.base.aclcnt.repeatcount
      y = y + 1
      cmd.y = " PERMIT '"profile"' CLASS("class")",
          "ID("racf.base.aclid.a")",
          "ACC("racf.base.aclacs.a")" type
      end
    end
  if racf.base.acl2cnt.repeatcount <> '' then do
    do a=1 to racf.base.acl2cnt.repeatcount
      y = y + 1
      cmd.y = " PERMIT '"profile"' CLASS("class")",
          "ID("racf.base.acl2id.a")",
          "ACC("racf.base.acl2acs.a")" type "-"
      y = y + 1
      cmd.y = "   WHEN("racf.base.acl2cond.a"("racf.base.acl2ent.a"))"
      end
    end
    drop racf.
  end

    cmd.0 = y
    call Display_Commands
    Address ISPExec
    zerrsm = "RACFADM "REXXPGM" RC=0"
    zerrlm = "CLONE TABLE A DATASET PROFILES"
    'log msg(isrz003)'
  exit

/*--------------------------------------------------------------------*/
/*  Display RACF command and return code                              */
/*--------------------------------------------------------------------*/
SHOWCMD:
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
Display_Commands:
  Address TSO "alloc f("ddname") new reuse",
              "lrecl(80) blksize(0) recfm(f b)",
              "unit(vio) space(15 15) tracks release"
  Address TSO "execio * diskw "ddname" (stem cmd. finis"
  drop cmd.
  Address ISPExec
  "lminit dataid(cmddatid) ddname("ddname")"
  "edit dataid("cmddatid") macro("editmacr")"
  Address TSO "free fi("ddname")"
return
