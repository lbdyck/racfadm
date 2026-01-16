/*%NOCOMMENT====================* REXX *==============================*/
/*PURPOSE:  RACFADM - Clone all Userids in Table A, command CLONE     */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @A0  251129  TRIDJK   Creation                                     */
/*====================================================================*/
DDNAME      = 'RACFA'RANDOM(0,999) /* Unique ddname        */
EDITMACR    = "RACFMRUN"   /* Edit Macro, RACRUN MSG       */
parse source . . REXXPGM .         /* Obtain REXX pgm name */
REXXPGM     = LEFT(REXXPGM,8)

Arg users

Address ISPexec
"CONTROL ERRORS RETURN"
"VGET (SETGSTA  SETGSTAP SETGDISP SETMADMN",
      "SETMIRRX SETMSHOW SETMTRAC SETTPSWD",
      "SETTPROF SETTUDSN SETMPHRA SETTCTLG) PROFILE"
"vget (radmclon) shared"

If (SETMTRAC <> 'NO') then do
   Say "*"COPIES("-",70)"*"
   Say "*"Center("Begin Program = "REXXPGM,70)"*"
   Say "*"COPIES("-",70)"*"
   if (SETMTRAC <> 'PROGRAMS') THEN
      interpret "Trace "SUBSTR(SETMTRAC,1,1)
   end

cmd. = ""
y = 0
ucat = settctlg

user_cnt = words(users)

Do n = 1 to user_cnt
  parse var users user users
  user = strip(user)
  racf_ids = 'IRRCERTA IRRMULTI IRRSITEC'
  if wordpos(user,racf_ids) > 0 then
    iterate

Address TSO
rxrc=IRRXUTIL("EXTRACT","USER",user,"RACF","")
if (word(rxrc,1) <> 0) then do
   say 'IRRXUTIL return code:'rxrc
   exit
end

tsoseg  = 'N'
do i=1 to RACF.0 /* get the segment names */
  segment=RACF.i
  if segment = 'TSO' then tsoseg = 'Y'
  if segment = 'BASE' then do
    clat = ''
    if racf.base.special.1 = 'TRUE' then clat = clat || 'SPECIAL '
    if racf.base.oper.1    = 'TRUE' then clat = clat || 'OPERATIONS '
    if racf.base.grpacc.1  = 'TRUE' then clat = clat || 'GRPACC '
    if racf.base.auditor.1 = 'TRUE' then clat = clat || 'AUDITOR '
    if racf.base.roaudit.1 = 'TRUE' then clat = clat || 'ROAUDIT '
    if racf.base.rest.1    = 'TRUE' then clat = clat || 'RESTRICTED '
    if racf.base.adsp.1    = 'TRUE' then clat = clat || 'ADSP '

    y = y + 1
    cmd.y = " ADDUSER " user "NAME('"racf.base.name.1"')" "-"
    y = y + 1
    cmd.y = "    PASSWORD("SETTPSWD")" "-"
/*  cmd.y = "    PHRASE("SETTPSWD")" "-" */
    y = y + 1
    cmd.y = "    "clat "-"
    y = y + 1
    cmd.y = "    OWNER("racf.base.owner.1")" "-"
    y = y + 1
    cmd.y = "    DFLTGRP("racf.base.dfltgrp.1")" "-"
    y = y + 1
    cmd.y = "  DATA('"strip(left(racf.base.data.1,56))"')" "-"
    iterate
    end

  y = y + 1
  cmd.y = " "segment"(" "-"
  do j=1 to RACF.segment.0
    field=RACF.segment.j

    /* ADDUSER edits */
    if racf.segment.field.1 = '' then
      iterate
    if field = 'UID' then do
      y = y + 1
      cmd.y = "    AUTOUID" "-"
      iterate
      end
    if field = 'HOME' then do
      homeuser = translate(user,"abcdefghijklmnopqrstuvwxyz", ,
                                  "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
      lslash = lastpos('/',racf.segment.field.1)
      homedir = substr(racf.segment.field.1,1,lslash)||homeuser
      y = y + 1
      cmd.y = "    "field"("homedir")" "-"
      iterate
      end
    if field = 'AUTOLOG' then
      racf.segment.field.1 = 'YES'
    if pos(" ",racf.segment.field.1) > 0 then
      racf.segment.field.1 = "'"||racf.segment.field.1||"'"

    aufld = field
    call Adduser_Fields
    if racf.segment.field.1 = 'TRUE' then
      racf.segment.field.1 = 'YES'
    if racf.segment.field.1 = 'FALSE' then
      racf.segment.field.1 = 'NO'
    y = y + 1
    cmd.y = "    "aufld"("racf.segment.field.1")" "-"
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

  do i = 1 to racf.base.connects.repeatcount
    cnat = ''
    if racf.base.cspecial.i = 'TRUE' then cnat = cnat || 'SPECIAL '
    if racf.base.coper.i    = 'TRUE' then cnat = cnat || 'OPERATIONS '
    if racf.base.cauditor.i = 'TRUE' then cnat = cnat || 'AUDITOR '
    y = y + 1
    cmd.y = " CONNECT" user "GROUP("racf.base.cgroup.i") -"
    y = y + 1
    cmd.y = "  OWNER("racf.base.cowner.i")" cnat
    end

  y = y + 1
  cmd.y = " ADDSD ('"user".**') UACC(READ) OWNER("||,
    racf.base.dfltgrp.1")"

  y = y + 1
  cmd.y = " DEFINE ALIAS (NAME('"user"') RELATE('"ucat"'))"

  if tsoseg = 'Y' then do
    /* Allocate ISPF profile */
    if settprof = "" then                                     /* @JK */
      settprof = "ISPF.ISPPROF"                               /* @JK */
    y = y + 1
    cmd.y = " ALLOC FI(PROF) DA('"user"."SETTPROF"') -"
    y = y + 1
    cmd.y = "     NEW SPACE(5,5) CYLINDERS -"
    y = y + 1
    cmd.y = "     BLKSIZE(0) LRECL(80) RECFM(F B) -"
    y = y + 1
    cmd.y = "     CATALOG DIR(250) REUSE"
    end

    if radmclon = 'KLONE' then
      call Datasets       /* Generate PERMITs */
End

cmd.0 = y
call Display_Commands

Address ISPExec
zerrsm = "RACFADM "REXXPGM" RC=0"
zerrlm = "CLONE TABLE A USER PROFILES"
'log msg(isrz003)'
exit

/* Adjust operand names to ADDUSER conventions */
Adduser_Fields:
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
  if cmd.0 = 0 then
    return
  Address TSO "alloc f("ddname") new reuse",
              "lrecl(80) blksize(0) recfm(f b)",
              "unit(vio) space(1 5) cylinders"
  Address TSO "execio * diskw "ddname" (stem cmd. finis"
  drop cmd.

  Address ISPExec
  "lminit dataid(cmddatid) ddname("ddname")"
  "edit dataid("cmddatid") macro("editmacr")"
  Address TSO "free fi("ddname")"
return

Datasets:
x = outtrap("dsn.")
Address TSO 'search filter(**)'
x = outtrap("off")
do i = 1 to dsn.0
  type = ''
  profile = dsn.i
  if pos('(G)',profile) > 0 then do
    profile = strip(substr(profile,1,pos('(G)',profile)-1))
    type = 'GEN'
    end
  call Get_Profile
  end
return

Get_Profile:
myrc=IRRXUTIL("EXTRACT","DATASET",profile,"RACF","")
if (word(myrc,1)<>0) then do
   return
   end
if racf.base.aclcnt.repeatcount <> '' then do
  do a=1 to racf.base.aclcnt.repeatcount
    if user = racf.base.aclid.a then do
      y = y + 1
      cmd.y = " PERMIT '"profile"' ID("user")",
          "ACC("racf.base.aclacs.a")" type
      end
    end
  end
if racf.base.acl2cnt.repeatcount <> '' then do
  do a=1 to racf.base.acl2cnt.repeatcount
    if user = racf.base.acl2id.a then do
      y = y + 1
      cmd.y = " PERMIT '"profile"' ID("user")",
          "ACC("racf.base.acl2acs.a")",
          "WHEN("racf.base.acl2cond.a"("racf.base.acl2ent.a"))",
           type
      end
    end
    drop racf.
  end
return
