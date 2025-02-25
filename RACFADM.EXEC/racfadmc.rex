/*%NOCOMMENT====================* REXX *==============================*/
/*PURPOSE:  RACFADM - Check RACFADM version with GitHub version       */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @A0  250217  LBDYCK   Creation                                     */
/*====================================================================*/
  /* -------------------------------------------------- *
   | This is a work in progress - 7 day check needs fix |
   * -------------------------------------------------- */
  arg opt
  parse value '' with null
  /* -------------------------------------- *
   | if opt is null then check every 7 days |
   * -------------------------------------- */
  if opt = null then do
    Address ISPExec 'vget (lastupdt) profile'
    if lastupdt /= null then do
      parse value lastupdt with cky'-'ckm'-'ckd rver
      ckdate = cky''ckm''ckd
      if date('s') - ckdate < 7 then return 0
    end
  end

  Address ISPExec
  racflmsg = "Checking GitHub version.."
  "control display lock"
  "display msg(RACF011)"

  user = userid()
  address syscall ,
    'getpwnam (user) pw.'
  env.1 = 'HOME='pw.4
  env.0 = 1
  cmd = 'curl -s' ,
    'https://raw.githubusercontent.com/lbdyck/racfadm/master/' ,
    || 'RACFADM.EXEC/racfrver.rex' ,
    '| grep " return "'
  x = bpxwunix(cmd,,s.,e.,env.,1)
  if e.0 > 0 then call error_display
  l = s.0
  parse value s.l with . "'" rver "'"
  cmd = 'curl -s' ,
    'https://api.github.com/repos/lbdyck/racfadm/branches/master | grep "date"'
  x = bpxwunix(cmd,,s.,e.,env.,1)
  if e.0 > 0 then call error_display
  l = s.0
  parse value s.l with '"date": "'ldate'T'.
  lastupdt = ldate rver
  act_ver = racfrver()
  Address ISPExec
  'vput (lastupdt) profile'
  parse value act_ver with 'V'v'R'r
  parse value rver with 'V'vr'R'rr
  av = v''r
  rv = vr''rr
  if av >= rv then m = 'You are current with RACFADM.'
  else m = 'You are behind RACFADM releases.'
  racfsmsg = null
  racflmsg = ,
  left('The latest release of RACFADM is' rver 'released on' ldate,74) m
  'setmsg msg(racf011)'
  exit
error_display:
  do x = 1 to e.0
    say e.x
    end
