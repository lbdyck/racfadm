/*%NOCOMMENT====================* REXX *==============================*/
/*PURPOSE:  RACFADM - Clone a Resource profile, line command K        */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @A0  240415  TRIDJK   Creation                                     */
/*====================================================================*/
PANELCL     = 'RACFCOPR'           /* Clone prompt popup panel */
DDNAME      = 'RACFA'RANDOM(0,999) /* Unique ddname        */
EDITMACR    = "RACFMRUN"   /* Edit Macro, RACRUN MSG       */
parse source . . REXXPGM .         /* Obtain REXX pgm name */
REXXPGM     = LEFT(REXXPGM,8)

Arg rclass profile

Address ISPexec
"CONTROL ERRORS RETURN"
"VGET (SETGSTA  SETGSTAP SETGDISP SETMADMN",
      "SETMIRRX SETMSHOW SETMTRAC SETTPSWD",
      "SETTPROF SETTUDSN SETMPHRA SETTCTLG) PROFILE"

clprof = profile
saveprof = profile

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
rxrc=IRRXUTIL("EXTRACT",rclass,profile,"RACF","")
if (word(rxrc,1) <> 0) then do
   say 'IRRXUTIL return code:'rxrc
   exit
   end

type = ''
if pos('*',profile) > 0 then
  type = 'GEN'

cmd. = ""
y = 0
do i=1 to RACF.0 /* get the segment names */
  segment=RACF.i
  if segment = 'BASE' then do
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
    cmd.y = " RDEFINE "rclass clprof"" "-"
    y = y + 1
    cmd.y = "  LEVEL("racf.base.level.1")" "-"
    y = y + 1
    cmd.y = "  OWNER("racf.base.owner.1")" "-"
    y = y + 1
    cmd.y = "  UACC("racf.base.uacc.1")" "-"
    y = y + 1
    cmd.y = "  AUDIT("racf.base.raudit.1")" "-"
    y = y + 1
    cmd.y = "  DATA('"strip(left(cldata,56))"')" "-"
    call Addmem
  iterate
  end

  y = y + 1
  cmd.y = " "segment"(" "-"
  do j=1 to RACF.segment.0
    field=RACF.segment.j
    if racf.segment.field.1 = '' then
      iterate
    arfld = field
    call Rdefine_Fields
    if racf.segment.field.1 = 'TRUE' then
      racf.segment.field.1 = 'YES'
    if racf.segment.field.1 = 'FALSE' then
      racf.segment.field.1 = 'NO'
    y = y + 1
    cmd.y = "  "arfld"("racf.segment.field.1")" "-"
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
    cmd.y = " PERMIT "clprof "CLASS("rclass") ID("racf.base.aclid.a")",
        "ACC("racf.base.aclacs.a")" type
    end
  end
  drop racf.

  cmd.0 = y
  call Display_Commands
  zerrsm = "RACFADM "REXXPGM" RC=0"
  zerrlm = "CLONE "clprof" FROM("saveprof")"
  'log msg(isrz003)'
exit

/* Adjust operand names to RDEFINE conventions */
Rdefine_Fields:
  select
    when field = 'PRIVLEGE' then arfld = 'PRIVILEGED'  /* STDATA   */
    when field = 'CHKADDRS' then arfld = 'CHECKADDRS'  /* KERB     */
    when field = 'MAPTIMEO' then arfld = 'MAPPINGTIMEOUT' /* ICTX  */
    when field = 'SIGREQD'  then arfld = 'SIGREQUIRED' /* SIGVER   */
    when field = 'KEYCRYPT' then arfld = 'KEYENCRYPT'  /* SSIGNON  */
    when field = 'CDTCASE'  then arfld = 'CASE'        /* CDTINFO  */
    when field = 'CDTDFTRC' then arfld = 'DEFAULTRC'   /* CDTINFO  */
    when field = 'CDTFIRST' then arfld = 'FIRST'       /* CDTINFO  */
    when field = 'CDTGEN'   then arfld = 'GENERIC'     /* CDTINFO  */
    when field = 'CDTGENL'  then arfld = 'GENLIST'     /* CDTINFO  */
    when field = 'CDTGROUP' then arfld = 'GROUP'       /* CDTINFO  */
    when field = 'CDTKEYQL' then arfld = 'KEYQUALIFIERS' /*     "  */
    when field = 'CDTMAC'   then arfld = 'MACPROCESSING' /*     "  */
    when field = 'CDTMAXLN' then arfld = 'MAXLENGTH'   /* CDTINFO  */
    when field = 'CDTMAXLX' then arfld = 'MAXLENX'     /* CDTINFO  */
    when field = 'CDTMEMBR' then arfld = 'MEMBER'      /* CDTINFO  */
    when field = 'CDTOPER'  then arfld = 'OPERATIONS'  /* CDTINFO  */
    when field = 'CDTOTHER' then arfld = 'OTHER'       /* CDTINFO  */
    when field = 'CDTPOSIT' then arfld = 'POSIT'       /* CDTINFO  */
    when field = 'CDTPRFAL' then arfld = 'PROFILESALLOWED' /*   "  */
    when field = 'CDTRACL'  then arfld = 'RACLIST'     /* CDTINFO  */
    when field = 'CDTSIGL'  then arfld = 'SIGNAL'      /* CDTINFO  */
    when field = 'CDTSLREQ' then arfld = 'SECLABELSREQUIRED' /* "  */
    when field = 'CDTUACC'  then arfld = 'DEFAULTUACC' /* CDTINFO  */
    when field = 'CFACEE'   then arfld = 'ACEE'           /* CFDEF */
    when field = 'CFDTYPE'  then arfld = 'TYPE'           /* CFDEF */
    when field = 'CFFIRST'  then arfld = 'FIRST'          /* CFDEF */
    when field = 'CFHELP'   then arfld = 'HELP'           /* CFDEF */
    when field = 'CFLIST'   then arfld = 'LISTHEAD'       /* CFDEF */
    when field = 'CFMIXED'  then arfld = 'MIXED'          /* CFDEF */
    when field = 'CFMNVAL'  then arfld = 'MINVALUE'       /* CFDEF */
    when field = 'CFMXLEN'  then arfld = 'MAXLENGTH'      /* CFDEF */
    when field = 'CFMXVAL'  then arfld = 'MAXVALUE'       /* CFDEF */
    when field = 'CFOTHER'  then arfld = 'OTHER'          /* CFDEF */
    when field = 'CFVALRX'  then arfld = 'VALREXX'        /* CFDEF */
    when field = 'CRTLBLS'  then arfld = 'SYMEXPORTCERTS' /* ICSF  */
    when field = 'EXPORT'   then arfld = 'SYMEXPORTABLE'  /* ICSF  */
    when field = 'KEYLBLS'  then arfld = 'SYMEXPORTKEYS'  /* ICSF  */
    when field = 'SCPWRAP'  then arfld = 'SYMCPACFWRAP'   /* ICSF  */
    when field = 'USAGE'    then arfld = 'ASYMUSAGE'      /* ICSF  */
    otherwise nop
    end
return
/* Adjust operand names to RDEFINE conventions */
Addmem:
if racf.base.memcnt.repeatcount <> '' then do
  do a=1 to racf.base.memcnt.repeatcount
    y = y + 1
    if a = 1 then
      cmd.y = "  ADDMEM ("racf.base.member.a "-"
    else
      cmd.y = "          "racf.base.member.a "-"
    end
  y = y + 1
  cmd.y = "         ) -"
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


