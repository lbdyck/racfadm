/*%NOCOMMENT====================* REXX *==============================*/
/*PURPOSE:  RACFADM - Generate Profile Source for all "active"        */
/*                    Resource Classes, Option GA                     */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @A1  251013  Janko    Skip classes per RDEFINE documentation       */
/* @A0  250707  Janko    IRRXUTIL verson                              */
/*====================================================================*/
EDITMACR    = "RACFMRUN"   /* Edit Macro, RACRUN MSG       */
DDNAME      = 'RACFA'RANDOM(0,999) /* Unique ddname        */
parse source . . REXXPGM .         /* Obtain REXX pgm name */
REXXPGM     = LEFT(REXXPGM,8)

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

cmd. = ""
y = 0
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

/* Get all active resource classes */
myrc=IRRXUTIL("EXTRACT","_SETROPTS","_SETROPTS","CLS")
if (word(myrc,1)<>0) then do
   say "MYRC="myrc
   say "An IRRXUTIL or R_admin error occurred"
end

/* Generate profile source for all active resource classes */
do t = 4 to CLS.BASE.CLASSACT.0     /* Skip DATASET, USER, GROUP */
  filter = "**"
  class = cls.base.classact.t
  skip_class = "DCEUUIDS",          /* Skip per RDEFINE */    /* @A1 */
               "DIGTCERT",          /* "    "   "       */    /* @A1 */
               "DIGTNMAP",          /* "    "   "       */    /* @A1 */
               "DIGTRING",          /* "    "   "       */    /* @A1 */
               "IDIDMAP ",          /* "    "   "       */    /* @A1 */
               "NDSLINK ",          /* "    "   "       */    /* @A1 */
               "NOTELINK",          /* "    "   "       */    /* @A1 */
               "ROLE    ",          /* "    "   "       */    /* @A1 */
               "UNIXMAP "           /* "    "   "       */    /* @A1 */
  if wordpos(class,skip_class) > 0 then
    iterate

  x = outtrap('ser.')
  cmd = "SEARCH FILTER("FILTER") CLASS("CLASS")"
  Address TSO cmd
  cmd_rc = rc
  x = outtrap('off')
  IF SETMSHOW <> 'NO' THEN
     CALL SHOWCMD

do s = 1 to ser.0
  profile = strip(ser.s)
  lprof = length(profile)
  if lprof > 3 then
    if substr(profile,lprof-3,4) = ' (G)' then
      profile = substr(profile,1,lprof-4)

  Address TSO
  rxrc=IRRXUTIL("EXTRACT",class,profile,"RACF","")
  if (word(rxrc,1) <> 0) then do
     iterate
     end

  type = ''
  if pos('*',profile) > 0 then
    type = 'GEN'

  do i=1 to RACF.0 /* get the segment names */
    segment=RACF.i
    if segment = 'BASE' then do
      y = y + 1
      cmd.y = " RDEFINE "class profile"" "-"
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
    cmd.y = strip(cmd.y,'T','-')

  if racf.base.aclcnt.repeatcount <> '' then do
    do a=1 to racf.base.aclcnt.repeatcount
      y = y + 1
      cmd.y = " PERMIT "profile" CLASS("class")",
          "ID("racf.base.aclid.a")",
          "ACC("racf.base.aclacs.a")" type
      end
    end
  if racf.base.acl2cnt.repeatcount <> '' then do
    do a=1 to racf.base.acl2cnt.repeatcount
      y = y + 1
      cmd.y = " PERMIT "profile" CLASS("class")",
          "ID("racf.base.acl2id.a")",
          "ACC("racf.base.acl2acs.a")" type "-"
      y = y + 1
      cmd.y = "   WHEN("racf.base.acl2cond.a"("racf.base.acl2ent.a"))"
      end
    end
    drop racf.
  end
  end
    cmd.0 = y
    call Display_Commands
    Address ISPExec
    zerrsm = "RACFADM "REXXPGM" RC=0"
    zerrlm = "GENERATE "filter class" CLASS PROFILES"
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
     Address ISPExec
     'log msg(isrz003)'
  END
RETURN
/*--------------------------------------------------------------------*/
/*  Edit information                                                  */
/*--------------------------------------------------------------------*/
Display_Commands:
  Address TSO "alloc f("ddname") new reuse",
              "lrecl(300) blksize(0) recfm(v b)",
              "unit(vio) space(5 15) cylinders release"
  Address TSO "execio * diskw "ddname" (stem cmd. finis"
  drop cmd.
  Address ISPExec
  "lminit dataid(cmddatid) ddname("ddname")"
  "edit dataid("cmddatid") macro("editmacr")"
  Address TSO "free fi("ddname")"
return
