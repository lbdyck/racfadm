/*%NOCOMMENT====================* REXX *==============================*/
/*PURPOSE:  RACFADM - Clone a Userid, line command K                  */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @A3  250122  TRIDJK   Add OWNER to CONNECT                         */
/* @A2  250120  TRIDJK   Display MSG about RACRUN macro               */
/* @A1  241223  TRIDJK   Process base attributes correctly            */
/* @A0  241208  TRIDJK   Creation                                     */
/*====================================================================*/
PANELCL     = 'RACFCOPU'           /* Clone prompt popup panel */
DDNAME      = 'RACFA'RANDOM(0,999) /* Unique ddname        */
EDITMACR    = "RACFMRUN"   /* Edit Macro, RACRUN MSG       */
parse source . . REXXPGM .         /* Obtain REXX pgm name */
REXXPGM     = LEFT(REXXPGM,8)

Arg user name

Address ISPexec
"CONTROL ERRORS RETURN"
"VGET (SETGSTA  SETGSTAP SETGDISP SETMADMN",
      "SETMIRRX SETMSHOW SETMTRAC SETTPSWD",
      "SETTPROF SETTUDSN SETMPHRA SETTCTLG) PROFILE"

cluser = user
clname = name
clucat = settctlg
'vput (cluser clname clucat)'

'addpop'
'display panel('PANELCL')'
 disprc = RC
'rempop'
if (disprc > 0) then do
   exit
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
   cmd.y 'IRRXUTIL return code:'rxrc
   exit
end

cmd. = ""
y = 0
do i=1 to RACF.0 /* get the segment names */
  segment=RACF.i
  if segment = 'BASE' then do                                 /* @A1 */
    clat = ''
    if racf.base.special.1 = 'TRUE' then clat = clat || 'SPECIAL '
    if racf.base.oper.1    = 'TRUE' then clat = clat || 'OPERATIONS '
    if racf.base.grpacc.1  = 'TRUE' then clat = clat || 'GRPACC '
    if racf.base.auditor.1 = 'TRUE' then clat = clat || 'AUDITOR '
    if racf.base.roaudit.1 = 'TRUE' then clat = clat || 'ROAUDIT '
    if racf.base.rest.1    = 'TRUE' then clat = clat || 'RESTRICTED '
    if racf.base.adsp.1    = 'TRUE' then clat = clat || 'ADSP '

    Address ISPexec
    'vget (zllgjob1 zllgjob2 zllgjob3 zllgjob4) profile'
    y = y + 1
    cmd.y = zllgjob1
    if zllgjob2 <> '' then do
      y = y + 1
      cmd.y = zllgjob2
      end
    if zllgjob3 <> '' then do
      y = y + 1
      cmd.y = zllgjob3
      end
    if zllgjob4 <> '' then do
      y = y + 1
      cmd.y = zllgjob4
      end
    y = y + 1
    cmd.y = "//TSO      EXEC  PGM=IKJEFT01"
    y = y + 1
    cmd.y = "//SYSTSPRT DD  SYSOUT=*"
    y = y + 1
    cmd.y = "//SYSTSIN  DD  *"
    y = y + 1
    cmd.y = " ADDUSER " cluser "NAME('"clname"')" "-"
    y = y + 1
    cmd.y = "  PASSWORD("clpswd")" "-"
    y = y + 1
    cmd.y = "  "clat "-"
    y = y + 1
    cmd.y = "  OWNER("racf.base.owner.1")" "-"
    y = y + 1
    cmd.y = "  DFLTGRP("racf.base.dfltgrp.1")" "-"
    if cldata <> '' then do
      y = y + 1
      cmd.y = "  DATA('"cldata"')" "-"
      end
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
      cmd.y = "  AUTOUID" "-"
      iterate
      end
    if field = 'AUTOLOG' then
      racf.segment.field.1 = 'YES'
    if pos(" ",racf.segment.field.1) > 0 then
      racf.segment.field.1 = "'"||racf.segment.field.1||"'"

    aufld = field
    call Adduser_Fields
    y = y + 1
    cmd.y = "  "aufld"("racf.segment.field.1")" "-"
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
    y = y + 1
    cmd.y = " CONNECT" cluser "GROUP("racf.base.cgroup.i")",
            "OWNER("racf.base.cowner.1")"                     /* @A3 */
    end

  y = y + 1
  cmd.y = " ADDSD ('"cluser".**') UACC(READ) OWNER("||,
    racf.base.dfltgrp.1")"

  y = y + 1
  cmd.y = " DEFINE ALIAS (NAME('"cluser"') RELATE('"clucat"'))"

  if clperm = 'Y' then
    call Datasets

  cmd.0 = y
  call Display_Commands
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
  Address TSO "alloc f("ddname") new reuse",
              "lrecl(80) blksize(0) recfm(f b)",
              "unit(vio) space(1 5) cylinders"
  Address TSO "execio * diskw "ddname" (stem cmd. finis"
  drop cmd.

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
      cmd.y = " PERMIT '"profile"' ID("cluser")",
          "ACC("racf.base.aclacs.a")" type
      end
    end
  end
if racf.base.acl2cnt.repeatcount <> '' then do
  do a=1 to racf.base.acl2cnt.repeatcount
    if user = racf.base.acl2id.a then do
      y = y + 1
      cmd.y = " PERMIT '"profile"' ID("cluser")",
          "ACC("racf.base.acl2acs.a")",
          "WHEN("racf.base.acl2cond.a"("racf.base.acl2ent.a"))",
           type
      end
    end
  end
drop racf.
return
