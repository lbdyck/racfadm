/*%NOCOMMENT====================* REXX *==============================*/
/*PURPOSE:  RACFADM - Clone a Userid, line command K                  */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @A7  250304  TRIDJK   Allocate ISPF Profile if TSO segment exists  */
/* @A6  250217  TRIDJK   Change OMVS HOME user to clone userid        */
/* @A5  250213  TRIDJK   Support PHRASE operand                       */
/* @A4  250201  TRIDJK   Log Clone message                            */
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
saveuser = user                                               /* @A4 */

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
   say 'IRRXUTIL return code:'rxrc
   exit
end

tso  = 'N'                                                    /* @A7 */
cmd. = ""
y = 0
do i=1 to RACF.0 /* get the segment names */
  segment=RACF.i
  if segment = 'TSO' then tso = 'Y'                           /* @A7 */
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
    if length(clpswd) < 9 then
      cmd.y = "  PASSWORD("clpswd")" "-"                      /* @A5 */
    else                                                      /* @A5 */
      cmd.y = "  PHRASE("clpswd")" "-"                        /* @A5 */
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
    if field = 'HOME' then do                                 /* @A6 */
      homeuser = translate(cluser,"abcdefghijklmnopqrstuvwxyz", ,
                                  "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
      lslash = lastpos('/',racf.segment.field.1)
      homedir = substr(racf.segment.field.1,1,lslash)||homeuser
      y = y + 1
      cmd.y = "  "field"("homedir")" "-"
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
            "OWNER("racf.base.cowner.i")"                     /* @A3 */
    end

  y = y + 1
  cmd.y = " ADDSD ('"cluser".**') UACC(READ) OWNER("||,
    racf.base.dfltgrp.1")"

  y = y + 1
  cmd.y = " DEFINE ALIAS (NAME('"cluser"') RELATE('"clucat"'))"

  if tso = 'Y' then do                                        /* @A7 */
    /* Allocate ISPF profile */                               /* @A7 */
    y = y + 1                                                 /* @A7 */
    cmd.y = " ALLOC FI(PROF) DA('"cluser"."SETTPROF"') -"     /* @A7 */
    y = y + 1                                                 /* @A7 */
    cmd.y = "   NEW SPACE(5,5) CYLINDERS -"                   /* @A7 */
    y = y + 1                                                 /* @A7 */
    cmd.y = "   BLKSIZE(0) LRECL(80) RECFM(F B) -"            /* @A7 */
    y = y + 1                                                 /* @A7 */
    cmd.y = "   CATALOG DIR(250) REUSE"                       /* @A7 */
    end                                                       /* @A7 */

  if clperm = 'Y' then
    call Datasets

  cmd.0 = y
  call Display_Commands
  zerrsm = "RACFADM "REXXPGM" RC=0"                           /* @A4 */
  zerrlm = "CLONE "cluser" FROM("saveuser")"                  /* @A4 */
  'log msg(isrz003)'                                          /* @A4 */
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
