/*%NOCOMMENT====================* REXX *==============================*/
/*PURPOSE:  RACFADM - Alter selected Resource Profile segments        */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @A0  250401  TRIDJK   Creation                                     */
/*====================================================================*/
PANELAL     = 'RACFCLS9'           /* Alter prompt popup panel */
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

Display_Panel:
Do Forever
Address ISPexec
'display panel('PANELAL')'
 disprc = RC
if (disprc > 0) then
  exit

cmd  = "SEARCH FILTER("profile") CLASS("rclass")"
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
rxrc=IRRXUTIL("EXTRACT",rclass,profile,"RACF","")
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
    cmd.y = " RALTER "rclass profile"" "-"
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

  if wordpos(segment,rsegs) = 0 then
    iterate

  y = y + 1
  cmd.y = " "segment"(" "-"
  do j=1 to RACF.segment.0
    field=RACF.segment.j
    if racf.segment.field.1 = '' then
      iterate
    arfld = field
    call Ralter_Fields
    if racf.segment.field.1 = 'TRUE' then
      racf.segment.field.1 = 'YES'
    if racf.segment.field.1 = 'FALSE' then
      racf.segment.field.1 = 'NO'
    y = y + 1
    cmd.y = "  "arfld"("strip(racf.segment.field.1)")" "-"
    end

    y = y + 1
    cmd.y = " )" "-"
  end

  if lastpos("-",cmd.y) > 0 then
    cmd.y = delstr(cmd.y,lastpos("-",cmd.y))

  cmd.0 = y
  call Display_Commands
  zerrsm = "RACFADM "REXXPGM" RC=0"
  zerrlm = "RALTER "rprofile rsegs
  Address ISPexec
  'log msg(isrz003)'

  end  /* Forever */
exit

/* Adjust operand names to RALTER conventions */
Ralter_Fields:
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
