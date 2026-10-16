/*                                                                       rexx
 RACFADM - List and control system options
 Part of the RACFADM utility package.

 History
   2026-09-30  WJENSEN  Initial
   2026-10-05  TRIDJK   Initialize $.1 variable
   2026-10-05  TRIDJK   Correct shadow variable for Primary cmds

 Author
  Willy Jensen
   mail  willy@harders-jensen.com
   web   http://harders-jensen.com

 Disclaimer
  >  The product is totally freeware and can be distributed and
     modified as you like, though the author would like to know of
     enhancements made, so that they might be incooporated into the
     product.
  >  The author accepts no responsibility for any damage caused by the
     product not behaving as expected or even as documented. It is
     after all free.
  >  Questions and comments should be sent to the email address,
     enhancement requests are especially welcome.
  >  If you experience problems then check the website for an updated
     version.
*/
 Signal on novalue name ErrNoVal
 Signal on syntax  name ErrSyntax
 Address ispexec "control errors return"

 parse value '1 OFF' with ?mreload $trace. linestat.
 panel  ='RACFSOPP'
 pdahelp='#RACFSOH'
 $globalv='$globalv pdaattr pdamaxd pdamaxw pdascrw panel $trace. $ny.',
          'pdashadc pdahelp @sv1c @sv1h  @sv2c @sv2h @lc @tc ?mreload',
          '$sim $simtxt'
 $ny. ='Y'                                       /* No/Yes                   */
 $ny.0='N'
 Call SetSim(0)                                  /* init simulate toggle     */
 Call PdaInit                                    /* get panel attr chars     */
 @lc = @tt                                       /* label color - turq       */
 @tc = @tg                                       /* text color - green       */
 pdaselc  = '=S H'                               /* line command(s)          */
 parse value 'turq  uscore'  with @ui1c @ui1h .
 pdavars = ''

 /* Main */
 pdahdr = center('('$simtxt'RACFADM - System options)',78,'-')
 Call MkHelp 'MAIN',pdahdr                       /* load help data           */
 Do $main=1 to 999999
   pdahdr = center('('$simtxt'RACFADM - System options)',78,'-')
   if ?mreload then Call MainBase
   if ?scrbuild then call ScrlBuild
   /* make panel */
   Call PdaReinit
   call pdaline @tg'Primary cmds ' ||,
     @tt'CLasses  Find c d  Openall  RESet  Where c',,
        '{{       {         {        {{{    {      ','CLa'
   call pdaline @tg'Line cmds    ' ||,
     @tt'Select/hide toggle (point-and-shoot)',,
        '{','Sel'
   call pdaline ''
   call pdaline ''
   call pdaline @tw'S  Text'
   pdafixn=pdalines                              /* # fixed lines            */
   do n=pdapos to scrl.0 for pdamaxd             /* add scrollables          */
     parse var scrl.n t '!'.
     call Pdaline t
   end
   zcmd=''
   Address Ispexec "Display panel("panel")"
   if rc>8 then exit ispmsg('Bad rc from panel:' rc zerrlm)+8
   if rc>0 then leave                            /* End or Return command    */
   do while pdalcmdl<>''                         /* handle select fields     */
     parse var pdalcmdl cpos','cval','pdalcmdl
     Interpret 'Call MainLC'cval cpos
   end
   if zcmd<>'' then do
     parse var zcmd cverb cdata
     select                       /* handle primary commands  */
       when abbrev('FIND',cverb,1)  then Call PcFind cdata
       when abbrev('WHERE',cverb,1) then Call PcWhere cdata
       when abbrev('CLASSES',cverb,2) then Call Classes
       when abbrev('OPENALL',zcmd,1) then do
         drop scrs. linestat.
         scrs.=1                                 /* all lines a visible      */
         linestat.='S'                           /* all lines are selected   */
         Call ScrlBuild
       end
       when abbrev('RESET',zcmd,3) then do
         do n=1 to base.0
           if left(base.n,1)<>@sf & left(base.n,1)<>@lc,
           & left(base.n,1)<>@ty then scrs.n=0
         end
         Call ScrlBuild
         drop linestat.
         linestat.=''
         pdapos=1
       end
       when abbrev('SIMULATE',zcmd,3) then call SetSim
       otherwise Call ispmsg '*Invalid command' zcmd
     end
   end
 end
 call quit

Quit:
 if arg(1)<>'' then say arg(1)
 exit 0

ErrNoVal:
 say '*Novalue raised for line' sigl '-'
 say strip(sourceline(sigl),'t')
 return 12

ErrSyntax:
 signal off syntax
 say '*Syntax' rc 'in line' sigl':' Errortext(rc)
 say Sourceline(sigl)
 return 12

/*============================================================================
                     Line command handlers
============================================================================*/
MainLcS:                                         /* Show/Expand              */
 trace ($trace.0lcmds)
 parse var scrl.cpos . '!' #                     /* get base line nr         */
 if linestat.#='S' then return MainLch(arg(1))
 linestat.#='S'
 do n=#+1 to base.0 while left(base.n,1)=@tc
   scrs.n=1
 end
 return LcmdlAdj(-1)+ScrlBuild()

MainLcH:                                         /* hide line                */
 trace ($trace.0lcmdh)
 parse var scrl.cpos . '!' #                     /* get base line nr         */
 linestat.#=''
 do i=#+1 to base.0 while left(base.i,1)<>@sf & left(base.i,1)<>@ty
   i=i
   scrs.i=0
 end
 call ScrlBuild
 pdapos=min(scrl.0,pdapos)
 return LcmdlAdj(-1)

LcmdlAdj: Procedure expose pdalcmdl              /* adjust line cmd list     */
 arg a                                           /* 1 or -1                  */
 c=''                                            /* adjust                   */
 do while pdalcmdl<>''                           /*   lcmd lnrs              */
   parse var pdalcmdl p','l','pdalcmdl
   c=c || p+a','l','
 end
 pdalcmdl=space(c)
 return 0

/*============================================================================
                      Primary command handlers
============================================================================*/
PcFind:  /* find string in list */
 if cdata='' & symbol('findsave')='VAR' then cdata=findsave
 if cdata='' then return ispmsg('Missing argument')
 parse value words(cdata) word(cdata,1) word(cdata,words(cdata)),
   wordindex(cdata,words(cdata))  with wc w1 wl wlp
 select                                          /* get directives           */
   when wordpos(w1,'FIRST LAST PREV NEXT')>0 then,
     parse var cdata dir cdata
   when wordpos(wl,'FIRST LAST PREV NEXT')>0 then ,
     parse var cdata cdata =(wlp) dir
   otherwise dir='NEXT'
 end
 cdata=strip(cdata)
 if cdata='*' then cdata=findsave
 findsave=cdata
 select                                          /* set options for scan     */
   when dir='FIRST' then parse value 1 0+scrl.0 1 with ff ft fb
   when dir='LAST'  then parse value 0+scrl.0 1 '-1' with ff ft fb
   when dir='PREV'  then parse value pdapos-1 1 '-1' with ff ft fb
   otherwise        parse value pdapos+1 0+scrl.0 1 with ff ft fb /* next */
 end
 do #=ff to ft by fb until ?
   ?=pos(cdata,scrl.#)>0
 end
 if \? then return ispmsg(cdata 'not found')
 pdapos=#
 drop cd cn fd fl fp fb ft
 return 0

PcWhere:  /* show only where text match */
 arg cdata
 cdata=strip(cdata)
 c=0
 if left(cdata,1)='\' then,                            /* handle NOT match   */
   parse value 1 substr(cdata,2) with c cdata
 p=(Verify(cdata,'*%','m')>0)
 a=translate(arg(2))='ALL'
 do #=1 to base.0
   if \scrs.# then iterate
   if \a &(left(base.#,1)=@lc | left(base.#,1)=@sf,
    | left(base.#,1)=@ty) then iterate
   if scrs.# & p then scrs.#=(Pattern(substr(base.#,5),cdata)<>c)
   else if scrs.# then scrs.#=((pos(cdata,base.#)=0)=c)
 end
 pdapos=1
 Call ScrlBuild
 if scrl.0=0 then call ispmsg 'Filter left no records'
 return 0

Mkhelp: procedure expose hlparea hlphdr hlpscrw pdaattr
 trace off
 interpret pdaattr
 parse value 0 0 with o k
 arg q .
 hlphdr =arg(2)
 hlparea=''
 hlpscrw=80
 do n=1 to sourceline()
   select
     when sourceline(n)='/*'q'HELP' then k=1
     when sourceline(n)=q'HELP*/' then leave
     when k then do
       r=translate(sourceline(n),@tb||@tg||@tt||@tw,'{}[]')
       hlparea=hlparea||strip(r,'t') || @nl
     end
     otherwise nop
   end
 end
 return 0

 /* make main base */
MainBase:
 if \$sim then Call GetOpts
 /* make base records */
 drop base. scrs.
 scrs.=0
 b#=0
 Call BaseAdd @ty'   Classes',1
 wl=clslist
 do while wl<>''
   parse var wl l wl
   if cls.l='NONE' then n=0
   else n=words(cls.l)
   Call BaseAdd @sf'  '@lc||Upcase1(l) @tb'('n')',1
   Call BaseSplit(cls.l)
 end
 Call BaseAdd @ty'   Logoptions',1
 wl=loglist
 if wl='' then Call BaseAdd @tb'  '@lc'None',1
 do while wl<>''
   parse var wl l wl
   if log.l='NONE' then n=0
   else n=words(log.l)
   Call BaseAdd @sf'  '@lc||Upcase1(l) @tb'('n')',1
   Call BaseSplit(log.l)
 end
 Call BaseAdd @ty'   Other options',1
 Call BaseAdd @sf'  '@lc'Options' @tb'('oth.0')',1
 do n=1 to oth.0
   Call BaseAdd @tc'   'oth.n
 end
 pdapos=1
 base.0=b#
 ?mreload=0
 return ScrlBuild()
 call rexxvars 'view var(base.#)'

BaseAdd:
 trace off
 b#=b#+1
 base.b#=arg(1)
 if arg(2)=1 then scrs.b#=1                      /* 'show' flag              */
 return 0

BaseJoin:  /* combine records in block to one record */
 trace off
 j=strip(r.rn)
 do n=rn+1 to r.0
   if left(r.n,2)<>'  ' then leave
   j=j space(r.n)
 end
 rn=n-1
 return j

BaseSplit: /* split long record to multiple lines    */
 ll=pdascrw-10
 parse arg bsr
 do while bsr<>''
   p=lastpos(' ',bsr' ',ll)
   if p=0 then p=pos(' ',bsr' ')                 /* will trim line           */
   parse var bsr f =(p) bsr
   call BaseAdd @tc'   'strip(f)
 end
 return 0

ScrlBuild:
 drop scrl.
 o=0
 do i=1 to base.0
   i=i
   if \scrs.i then iterate
   o=o+1
   scrl.o=base.i '!'i
 end
 scrl.0=o
 ?scrbuild=0
 pdamax=scrl.0
 return 0
 call rexxvars 'list var(scrl.#)'

GetOpts:
 cc=TsoCmd('SETROPTS LIST','r.')
 /* split */
 parse value 0 with o# cls. clslist log. loglist oth.
 do rn=1 to r.0
   select
     when word(r.rn,1)='LOGOPTIONS' then do
       parse value BaseJoin() with l '=' r
       l=word(translate(l,' ','"'),2)            /* keep name               */
       log.l=strip(r)
       loglist=loglist l
     end
     when pos('CLASSES =',r.rn)>0   then do
       parse value BaseJoin() with l '=' r
       l=delword(l,words(l))    /* drop trailing 'CLASSES' */
       l=space(l,0)
       cls.l=strip(r)
       clslist=clslist l
     end
     otherwise do
       o#=o#+1
       oth.o#=r.rn
     end
   end
 end
 oth.0=o#
 clslist=space(clslist)
 loglist=space(loglist)
 return 0
 if loglist='' then loglist='NONE'

/*============================================================================
                          Class handlers
============================================================================*/
Classes: Procedure expose ($globalv) cls. racfdefcl.
 Interpret pdaattr
 /* make list of defined classes */
 if $sim & symbol('racfdefcl.0')<>'VAR',
   & userid()='WJ' & mvsvar('sysname')='VS01' then ,
     call RexxGblv 'impload var(racfdefcl.) ds(WJ.RACFSOPT.STORE)'
 if symbol('racfdefcl.0')<>'VAR' then do
   racfsopc=''
   address ispexec "vget RACFSOPC shared"
   if rc=0 & racfsopc<>'' then do
     racfdefcl.0 = words(racfsopc)
     do n=1 to racfdefcl.0
       parse var racfsopc racfdefcl.n racfsopc
     end
   end
 end
 if symbol('racfdefcl.0')<>'VAR' then do
   address ispexec "Control display lock"
   Call PdaPrompt 'RACF class activation',
     ,,'>'@ty||'Building class list, please be patient....'
   cc=bpxwdyn('alloc dd(showmvs) new delete reuse',
              'tracks space(30,30) unit(vio)')
   if cc<>0 then exit tsomsg('alloc rc' cc)
   Address LinkMvs "showzos"
   'Execio *    diskr showmvs (finis)'
   cc=BpxWdyn('Free dd(showmvs)')
   /* look for
     " >RACF Data:
     "   Class      ID  RC Ref
   */
   qn=queued()
   if qn=0 then return IspMsg('Load of defined classes failed!!')+99
   do qn until substr(r,2,5)='>RACF';parse pull r;end
   qn=queued()
   do qn until substr(r,4,5)='Class';parse pull r;end
   qn=queued()
   racfsopc=''
   do n=1 to qn until d=''
     parse pull =2 d .
     racfdefcl.n=d
     racfdefcl.d=n
     racfsopc=racfsopc d
   end
   racfdefcl.0=n-1
   address ispexec "vput RACFSOPC shared"
   "delstack"
   if $sim & userid()='WJ' & mvsvar('sysname')='VS01' then ,
     call RexxGblv 'saveexp var(racfdefcl.) ds(WJ.RACFSOPT.STORE)'
 end
 /* end defined classes */

 pdavars = ''
 pdahdr  = center('('$simtxt'RACFADM - List' racfdefcl.0 'classes)',78,'-')
 Call MkHelp 'CLASS',pdahdr                      /* load help data           */
 pdaselc = 'A D R'
 pdahelp='#RACFSOH'
 ?creload=1
 Do $clases=1 to 999999
   if ?creload then Call ClassBase
   if ?scrbuild then call ScrlBuild
   /* make panel */
   pdahdr  = center('('$simtxt'RACFADM - List' racfdefcl.0 'classes)',78,'-')
   Call PdaReinit
   call pdaline @tg'Primary cmds ' ||,
     @tt'Find c d  RELoad  RESet  Where c',,
        '{         {{{     {{{    {      ','Find'
   call pdaline @tg'Line cmds    ' ||,
     @tt'Activate Deactivate Refresh',,
        '{        {          {','Act'
   call pdaline ''
   listhdr='Active Audit Gen-prof Gen-cmd Genlist Globalck Raclist'
   call pdaline @tw'S  Name    '||listhdr
   pdafixn=pdalines                              /* # fixed lines            */
   do n=pdapos to scrl.0 for pdamaxd             /* add scrollables          */
     parse var scrl.n t '!'.
     call Pdaline t
   end
   zcmd=''
   Address Ispexec "Display panel("panel")"
   if rc>8 then exit ispmsg('Bad rc from panel:' rc zerrlm)+8
   if rc>0 then return 0                         /* End or Return command    */
   do while pdalcmdl<>''                         /* handle select fields     */
     parse var pdalcmdl cpos','cval','pdalcmdl
     Interpret 'Call ClassLC'cval cpos
   end
   if zcmd<>'' then do
     parse var zcmd cverb cdata
     select                       /* handle primary commands  */
       when abbrev('FIND',cverb,1)  then Call PcFind cdata
       when abbrev('WHERE',cverb,1) then Call ClassWhere cdata
       when abbrev('RESET',cverb,3) then do
         drop scrs.
         scrs.=1
         ?scrbuild=1
       end
       when abbrev('RELOAD',cverb,3) then ?creload=1
       when abbrev('SIMULATE',zcmd,3) then call SetSim
       otherwise Call ispmsg '*Invalid command' zcmd
     end
   end
 end
 return 0

ClassWhere:
 arg p
 c='Y'
 if left(p,1)='\' then parse var p c +1 p              /* handle NOT match   */
 if words(p)<>1 then return PcWhere(arg(1))
 if wordpos(p,translate(listhdr))=0 then return PcWhere(arg(1),'ALL')
 drop scrs.
 scrs.=0
 p=wordpos(p,translate(listhdr))+3
 if c='\' then c='N'
 do n=1 to base.0
   if word(base.n,p)=c then scrs.n=1
 end
 return ScrlBuild()

ClassLcA:                                         /* Activate class          */
 trace off
 drop active
 parse var scrl.cpos (@tg) name . (@tt)
 if pos(name,cls.ACTIVE)>0,
   then return ispmsg(name 'is already active')
 if \PdaPrompt('RACF class activation',
     ,,'>'@ty||'Activate class' name) then return 0
 list.0=0
 cc=AddToList('SETROPTS CLASSACT('name')')
 if \$sim then cc=TsoCmd('SETROPTS CLASSACT('name')',,'tolist')
 if cc=0 then do
   parse value 1 1 with ?creload ?mreload
   if $sim then cls.ACTIVE=cls.ACTIVE name
   $.1 = ''  /* Janko K */
   if $sim & name='ACEECHK' then $.1='! WARNING! You must RACLIST !'
   if pos('WARNING! You must RACLIST',$.1)=0 then,
     call AddToList $simtxt'Done'
   else do
     c ='SETROPTS CLASSACT('name') RACLIST('name')'
     cc=AddToList(c)
     if \$sim then cc=TsoCmd(c,,'tolist')
     if cc=0 then call AddToList $simtxt'Done'
   end
 end
 Call PdaList $simtxt'(RACFADM - Class activation messages)'
 if $sim then cls.SETRRACLIST=cls.SETRRACLIST name
 return 0

ClassLcD:                                         /* Deactivate class        */
 trace off
 drop active
 parse var scrl.cpos (@tg) name . (@tt)
 if pos(name,cls.ACTIVE)=0,
   then return ispmsg(name 'is not active')
 if \PdaPrompt('RACF class deactivation',
     ,,'>'@ty||'Deactivate class' name) then return 0
 p=''
 if wordpos(name,cls.SETRRACLIST)>0 then p='NORACLIST('name')'
 list.0=0
 cc=AddToList('SETROPTS NOCLASSACT('name')' p)
 if \$sim then cc=TsoCmd('SETROPTS NOCLASSACT('name')' p,,'tolist')
 if cc=0 then parse value 1 1 with ?creload ?mreload
 if cc=0 then call AddToList $simtxt'Done'
 Call PdaList $simtxt'RACFADM Class deactivation messsages'
 if \$sim then return 0
 p=wordpos(name,cls.ACTIVE)
 cls.ACTIVE=delword(cls.ACTIVE,p,1)
 return 0

ClassLcR:                                         /* Refresh class           */
 trace off
 drop active
 parse var scrl.cpos (@tg) name . (@tt)
 if pos(name,cls.ACTIVE)=0,
   then return ispmsg(name 'is not active')
 p=''
 /*if pos(name,cls.GENERICCOMMAND)>0 then p=p 'GENCMD'
   if pos(name,cls.GENERICPROFILE)>0 then p=p 'GENERIC'
   if pos(name,cls.GLOBALCHECKING)>0 then p=p 'GLOBAL' */
 if pos(name,cls.SETRRACLIST)>0    then p=p 'RACLIST'
 p=strip(p)
 if p<>'' then o='Options' p
 o=''
 if \PdaPrompt('RACF class refresh',
     ,,'>'@ty||'Refresh class' name,
     ,,'>'@tb||o) then return 0
 c=''
 /*if pos(name,cls.GENERICCOMMAND)>0 then c=c 'GENCMD('name')'
   if pos(name,cls.GENERICPROFILE)>0 then c=c 'GENERIC('name')'
   if pos(name,cls.GLOBALCHECKING)>0 then c=c 'GLOBAL('name')' */
 list.0=0
 if pos(name,cls.SETRRACLIST)>0      then c=c 'RACLIST('name')'
 c='SETROPTS CLASSACT('name')' c 'REFRESH'
 cc=AddToList(c)
 if \$sim then cc=TsoCmd(c,,'tolist')
 if cc=0 then call AddToList $simtxt'Done'
 return PdaList('RACFADM - refresh')+cc

ClassBase:
 drop scrs.
 if \$sim then Call GetOpts
 parse value copies('0 ',20) with b# scrs. .
 do n=1 to racfdefcl.0
   r=@sf'  '@tg||left(racfdefcl.n,8) || @tt ||,
     center(value('$NY.'wordpos(racfdefcl.n,cls.ACTIVE)),6),
     center(value('$NY.'wordpos(racfdefcl.n,cls.AUDIT)),5),
     center(value('$NY.'wordpos(racfdefcl.n,cls.GENERICPROFILE)),7),
     center(value('$NY.'wordpos(racfdefcl.n,cls.GENERICCOMMAND)),7),
     center(value('$NY.'wordpos(racfdefcl.n,cls.GENLIST)),7),
     center(value('$NY.'wordpos(racfdefcl.n,cls.GLOBALCHECKING)),8),
     center(value('$NY.'wordpos(racfdefcl.n,cls.SETRRACLIST)),7),
     ''
   Call BaseAdd r,1
 end
 base.0=b#
 Call ScrlBuild
 ?creload=0
 return 0

/*============================================================================
                          PDA routines
============================================================================*/
Pdaline:                                         /* add screen buffer line   */
 pdaarea=pdaarea   || strip(arg(1),'t') || @nl   /* add to area with newln   */
 if arg(3)<>'' then pdashadv=pdashadv,           /* add to shadow att 'p3'   */
      || copies(' ',pos(arg(3),arg(1))-1),
      || strip(arg(2),'t') || @nl
 else pdashadv=pdashadv || strip(arg(2),'t')||@nl/* add to shadow with newln */
 pdalines=pdalines+1
 return 0

PdaInit:                                         /* get panel attr chars     */
 Address Ispexec "vget (zscrmaxd zscrmaxw)"
 pdascrw=80                                      /* reqd for 1st call        */
 Address Ispexec "Control nondispl enter"
 Address Ispexec "Display panel("panel")"
 Interpret pdaattr
 /* shadow var definitions (1-4). Hilite may be REVERSE or USCORE            */
 pdashadc = '{}'                                 /* shadow var char(s)       */
 parse value 'White'  with @sv1c @sv1h           /* 1 - color and hilite     */
 parse value 'Yellow reverse' with @sv2c @sv2h   /* 2 - color and hilite     */
 Return 0

PdaReinit:                                       /* reset some vars          */
 parse value 0 0 with pdalines pdafixn pdaarea pdashadv
 if symbol('PDAPOS')<>'VAR' then pdapos=1
 else if pdapos<1 then pdapos=1
 return 0

PdaList: Procedure expose ($globalv) list.       /* display stem list.       */
 trace off
 Interpret pdaattr
 parse arg pdahdr
 zerrlm=''
 pdamax=list.0
 do forever
   Call PdaReinit
   call PdaLine @tb
   do #=2 to arg()
     if left(arg(#),1)<'20'x then call PdaLine arg(#)
     else call PdaLine @tg||arg(#)
   end
   if arg()>1 then call PdaLine @tb
   pdafixn =pdalines                             /* number of fixed lines    */
   if pdapos<1 then pdapos=1
   do n=pdapos to list.0 for pdamaxd             /* add scrollables          */
     if left(list.n,1)<'20'x then call PdaLine list.n
     else call PdaLine @tt || list.n
   end
   call PdaLine @tb
   Address Ispexec "Display panel("panel")"
   if rc>8 then return Ispmsg('Bad rc from list panel:' rc zerrlm)+0
   if rc>0 then return 0
 end
 return 0   /* really shouldnt arrive here */

/* Prompt
 Parameters
   1          Header
   2-n        Display lines
 Returns
   0 (false)  cancelled
   1 (true)   ok
*/
PdaPrompt: Procedure expose ($globalv)
 trace off
 Interpret pdaattr
 Call PdaReinit
 pdahdr  =arg(1)
 do n = 2 to arg()     /* build screen */
   s=arg(n)
   ?c=0
   if left(s,1)='>' then parse value 1 substr(s,2) with ?c s
   if left(s,1)>' ' then s=@tb || s
   if ?c then s=center(s,pdascrw-10)
   call PdaLine s
 end
 call PdaLine @tb
 p=copies(' ',12)
 call PdaLine p @tt'Press' || @tw || 'ENTER' || @tt,
      || 'to accept or'@tw || 'END' || @tt || 'to terminate'
 pdafixn =pdalines                               /* number of fixed lines    */
 pdamax  =pdalines                               /* number of fixed lines    */
 zerrlm=''
 do forever
   Address Ispexec "AddPop"
   Address Ispexec "Display panel("panel")"
   cc=rc
   Address Ispexec "RemPop"
   if cc>8 then return Ispmsg('Bad rc from panel:' cc)+0
   if cc=0 & pdaverb='ENTER' then return 1          /* ok    */
   if cc>0 & zcmd='' then return 0          /* abort */
   if abbrev('CANCEL',zcmd,3) then return 0  /* abort */
   call ispmsg 'Bad commmand or key' space(zcmd pdaverb)
 end
 return 0   /* really shouldnt arrive here */

/*============================================================================
                        Various services
============================================================================*/
TsoMsg: trace off; say arg(1); return 0
TsoCmd:                           /* silent command        */
 trace off;
 zz=outtrap(word(arg(2) '$.',1))
 address tso arg(1)
 zz=outtrap('off')
 tsocmdrc=rc
 if translate(arg(3))='TOLIST' then return AddToList('$.')+rc
 return tsocmdrc
TsoCmdList: do #=1 to $.0;say $.#;end
IspMsg:
 parse arg zedlmsg
 address ispexec "setmsg msg(isrz000)"
 return 0
Requote: if arg(1)='' then return '';else return "'"Unquote(arg(1))"'"
Unquote: return strip(space(translate(arg(1)," ","'")))
Upcase1: return bitor(translate(arg(1),xrange('a','z'),xrange('A','Z')),'40'x)
AddToList:
 if symbol('list.0')<>'VAR' then list.0=0
 arg _s
 if right(_s,1)<>'.' | words(_s)>1 then do
   parse value 1+list.0 1+list.0 arg(1) with _ list.0 list._
   return 0
 end
 _l=list.0
 do _i=1 to Value(_s'0')
   _l=_l+1
   list._l=Value(_s||_i)
 end
 list.0=_l
 return 0
SetSim:
 if arg(1)<>'' then arg $sim
 else $sim=($sim=0)                              /* flip value 0<->1         */
 $simtxt=''
 if $sim then $simtxt='<SIM> '
 return 0

/*
 PATTERN function
 Parameters  string,mask[,maskchrs]
 Returns     0 (false)=not matched or missing parm, or 1 (true)=match
*/
Pattern: Procedure
 trace off
 if arg()<2 then return 0
 parse arg str,msk,mchr
 parse value word(mchr '*%',1) with mchr 1 mcm +1 mco  /* split mask chrs    */
 parse value 1 1 length(msk) length(str) with mp sp ml sl .
 do while mp<=ml & sp<=sl
   select
     when substr(msk,mp,1)=mco then,                   /* mask starts with % */
       parse value mp+1 sp+1 with mp sp                /* bump ptrs          */
     when substr(msk,mp)=mcm then return 1             /* match on rest      */
     when substr(msk,mp,2)=mchr then do                /* both mask chrs     */
       mp=mp+1
       msp=verify(msk,mco,'n',mp+1)                    /* mak sub-str pos    */
       if msp=0 then return (ml-mp)=(sl-sp)            /* rest mask is %s    */
       p=verify(msk,mchr,'m',msp)
       if p>0 then msl=p-msp
       else msl=ml+1-msp
       ms=substr(msk,msp,msl)                          /* mask substring     */
       mpl=msp-mp                                      /* mask chrs len      */
       p=pos(ms,str,sp+mpl)
       if p=0 then return 0
       sp=p-mpl
     end
     when substr(msk,mp,2)=mcm||mcm then mp=mp+1       /* double '*'         */
     when substr(msk,mp,1)=mcm then do                 /* '*'                */
       mp=mp+1                                         /* bump mask          */
       p=verify(msk,mchr,'m',mp)                       /* -> end mask chr    */
       if p=0 then return substr(msk,mp)=right(str,ml-mp+1) /* no more maskc */
       ms=substr(msk,mp,p-mp)                          /* mask substr        */
       msl=length(ms)
       mp=p
       p=pos(ms,str,sp)                                /* locate in string   */
       if p=0 then return 0                            /* not found          */
       sp=p+msl
     end
     when substr(str,sp,1)<>substr(msk,mp,1) then return 0 /* not matched    */
     otherwise do
       p=verify(msk,mchr,'m',mp)                       /* locate msk chr     */
       if p=0 then return substr(msk,mp)=substr(str,sp)/* no more mask chrs  */
       l=p-mp
       if substr(msk,mp,l)<>substr(str,sp,l) then return 0
       mp=mp+l
       sp=sp+l
     end
   end
 end
 return (mp>ml & sp>sl ) | (mp=ml & substr(msk,mp)='*') /* both exhausted ?   */

 /*====================================================================
                           Documentation
 ====================================================================*/
/*MAINHELP
]RACF Administration - List RACF system options
{
]Primary commands
[ CLasses  }Open the CLASS control sub-menu.
[ Find c d }Find text 'c' using direction 'd' and reposition the
{          }panel with the matching line at top. 'd' can be NEXT,
{          }PREV, FIRST or LAST. The default is NEXT. FIND without
{          }parameter will reuse the latest 'c' value with direction
{          }NEXT. If c = '*' then the latest c value will be reused,
{          }this allows you to use the latest value with a direction.
[ Openall  }Open all subsections to provide a full list.
[ RESet    }Reset to initial display, closes an OPENALL expansion.
[ SIMulate }Display generated commands, do not execute.
[ Where c  }Filter the displayed list, leaving only records where 'c'
{          }is found. If c is specified as \c, then only records not
{          }containing 'c' are kept. Labels are always kept.
{
]Line commands
[ S        }Show or hide details, acts a a toggle to show or hide
{          }detail. 'S' is a point-and-shoot command.
MAINHELP*/
/*CLASSHELP
]RACF Administration - List and control RACF classes
{
]Primary commands
[ Find c d }Find text 'c' using direction 'd' and reposition the
[          }panel with the matching line at top. 'd' can be NEXT,
{          }PREV, FIRST or LAST. The default is NEXT. FIND without
{          }parameter will reuse the latest 'c' value with direction
{          }NEXT. If c = '*' then the latest c value will be reused,
{          }this allows you to use the latest value with a direction.
[ RESet    }Reset to initial display.
[ SIMulate }Display generated commands, do not execute.
[ Where c  }Filter the list, leaving only records where 'c' is found.
{          }If c is specified as \c, then only records not containing
{          }'c' are kept. Labels are always kept. If c is a column heading
{          }then records with that column having a 'Y' are selected.
{
]Line commands
[ A        }Activate class. Will prompt before actual activation is done.
[ D        }Deactivate class. Will prompt before actual deactivation is done.
[ R        }Refresh class. Will prompt before actual refresh is done.
CLASSHELP*/
