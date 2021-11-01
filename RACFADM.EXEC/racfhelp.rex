/*%NOCOMMENT====================* REXX *==============================*/
/*  PURPOSE:  RACFADM - RACF Help Commands - Menu option H            */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @A3  200618  RACFA    Chged SYSDA to SYSALLDA                      */
/* @A2  200605  RACFA    Concatenate panel dsn to TSOHELP             */
/* @A1  200520  RACFA    Added RACF cmds: OPERMIT, ORALTER and ORLIST */
/* @A0  200328  RACFA    Modified color/title                         */
/*====================================================================*/
/* --------------------  REXX Program  ----------------------------- */
 ver = '3.10'
/* ------------------ DO NOT NUMBER IN ISPF ------------------------ *
 | Name:       zTSOHELP                                              |
 |                                                                   |
 | Function:   Present the user with a table of available            |
 |             TSO HELP pages from which the user may select         |
 |             to browse.                                            |
 |                                                                   |
 | Syntax:     %zTSOHELP help-command  /w  /t                        |
 |                                                                   |
 |             help-command is optional and will position the        |
 |             list at that command (or close to it)                 |
 |                                                                   |
 |             /t will include notelines for imbeds                  |
 |                                                                   |
 |             /w will generate a warning message for any            |
 |             help entries that do not exist and thus were          |
 |             not added to the table                                |
 |                                                                   |
 | Commands:   Locate cmd next                                       |
 |             Only string                                           |
 |             Refresh                                               |
 |             RL    (repeat locate)                                 |
 |             S command                                             |
 |             SEt                                                   |
 |             Sort column order                                     |
 |                                                                   |
 | Notes:      The Description field is scrollable when the cursor   |
 |             is in the field. This is to support descriptions      |
 |             greater than 53 characters if they exist.             |
 |                                                                   |
 | Command Table:  It is recommended that an ISPF Command Table      |
 |                 entry be created to make it faster to get to      |
 |                 this application. This is a sample:               |
 |                                                                   |
 |                 Verb    TSOH                                      |
 |                 Trunc:  0                                         |
 |                 Action: SELECT CMD(%ZTSOHELP &ZPARM) NEWAPPL(ISR) |
 |                 Desc:   TSO Help ISPF Application                 |
 |                                                                   |
 | Dependency: Optional the HELP Data member to be created           |
 |             using the sample data provided (find *custom*)        |
 |                                                                   |
 |             FSHelp (CBT Tape File 134) may be used (see *custom*) |
 |             - Get the July 2017 update which fixes an issue with  |
 |               )I records                                          |
 |                                                                   |
 | Customizations:  Find *custom* below for site customizations      |
 |                                                                   |
 | Author:     John P. Kalinich and Lionel B. Dyck                   |
 |                                                                   |
 | History:                                                          |
 |             05/23/20 - V3.10                                      |
 |                      - Correct )X Syntax display                  |
 |                      - Remove action bar from view panel          |
 |             02/11/20 - V3.9                                       |
 |                      - Add more help entries                      |
 |             12/20/19 - V3.8                                       |
 |                      - Highlight key sections                     |
 |             04/01/19 - V3.7                                       |
 |                      - Ignore ALL records before the )F statement |
 |             11/07/18 - V3.6                                       |
 |                      - Fix comments before >Start                 |
 |             07/24/18 - V3.5                                       |
 |                      - Add additional SHA members from CBT file   |
 |                        900                                        |
 |             02/28/18 - V3.4                                       |
 |                      - Change tbend to tbclose                    |
 |             10/30/17 - V3.3                                       |
 |                      - Change Include Help record to Noteline     |
 |                      - Add /t switch                              |
 |             10/27/17 - V3.2                                       |
 |                      - Correction to eliminate blank lines after  |
 |                        )) records                                 |
 |             10/19/17 - V3.1                                       |
 |                      - Correction to handle some help members     |
 |                        with nested includes                       |
 |             10/18/17 - V3.0                                       |
 |                      - Relocate messages to the end of the view   |
 |                      - Remove non-display characters that may be  |
 |                        within a Help member                       |
 |             09/14/17 - V2.9                                       |
 |                      - Added CADisk Help Commands                 |
 |                      - Allow the help list to be more free form   |
 |             08/28/17 - V2.8                                       |
 |                      - Correction if a )I is last record          |
 |                      - Remove help comments (* in col 2)          |
 |             08/24/17 - V2.7                                       |
 |                      - Support )F Function - text                 |
 |             08/18/17 - V2.6                                       |
 |                      - Add Script command (DCF)                   |
 |             08/14/17 - V2.5                                       |
 |                      - Fix typos in panels                        |
 |                      - Add MXI help                               |
 |             08/03/17 - V2.4                                       |
 |                      - Add more RACF Help (thx JK)                |
 |             07/28/17 - V2.3                                       |
 |                      - Correct the sequence number blank code     |
 |             07/26/17 - V2.2                                       |
 |                      - Added several additional help members      |
 |                      - Add LOCAL group of help entries            |
 |             07/20/17 - V2.1                                       |
 |                      - Minor Panel header chagnes for clarity     |
 |             07/20/17 - V2.0                                       |
 |                      - Several enhancements and expanded tutorial |
 |                      - Make the description field scrollable      |
 |             07/19/17 - V1.9                                       |
 |                      - Change tbdispl panel info                  |
 |                      - Colorize sorted column                     |
 |                      - Optional Reset of Tab to Point and Shoot   |
 |                        - find *custom* to change default          |
 |             07/18/17 - V1.8                                       |
 |                      - Additional point/shoot on table panel      |
 |             07/18/17 - V1.7                                       |
 |                      - Eliminate duplication due to code chagnes  |
 |             07/17/17 - V1.6                                       |
 |                      - Correction to handle missing includes )I   |
 |             07/17/17 - V1.5                                       |
 |                      - Correction to handle )INFORMATION in IPCS  |
 |                      - Change the table display panel:            |
 |                        - Remove selection option info             |
 |                        - Make column headers point/shoot          |
 |             07/14/17 - V1.4                                       |
 |                      - Use customized view panel with a custom    |
 |                        title to eliminate the temp dsname         |
 |             07/13/17 - V1.3                                       |
 |                      - Use temp pds to free up syshelp            |
 |                      - Add to the help data:                      |
 |                            BPXBATCH BPXMTEXT BPXTRACE ISH         |
 |                            MKNOD OBROWSE OSTEPLIB ZLSOF           |
 |                            RMM*                                   |
 |             07/12/17 - V1.2                                       |
 |                      - Clean up format by deleting all records    |
 |                        prior to the 1st ) record                  |
 |             07/11/17 - V1.1                                       |
 |                      - Set Caps Off for better readability        |
 |             07/11/17 - V1.0                                       |
 |                      - General availability                       |
 |             06/30/17 - Numerous changes (including name)          |
 |             06/22/17 - Creation                                   |
 | ----------------------------------------------------------------- |
 | Notes:  1. Additions to the list of TSO Help members is easy by   |
 |            just adding them to the table at the end of this       |
 |            code.                                                  |
 |         2. Use the /W switch when calling to see which TSO        |
 |            Help members in the list don't exist in your           |
 |            SYSHELP concatenation.                                 |
 |         3. FSHELP is a full screen TSO command processor          |
 |             - Not an ISPF application                             |
 |         4. If ISPF Settings have Tab to Point and Shoot enabled   |
 |            then the user can tab to the PNS fields and press      |
 |            Enter (or double click) to activate                    |
 | ----------------------------------------------------------------- |
 | Copyleft (c) All Wrongs Reserved                                  |
 * ----------------------------------------------------------------- */

 arg helpcmd


/* ----------------------------------------------- *
 | Check for APPLID of ISR and if not then recurse |
 * ----------------------------------------------- */
 Address ISPExec
 "Vget (Zapplid)"
 "Control Errors Return"
 if zapplid <> "ISR" then do
     "Select CMD(%"sysvar('sysicmd') helpcmd ") Newappl(ISR)" ,
         "Passlib"
    exit 0
    end

 /*-------------------------------------------------------*/  /* @A2 */
 /* Concatenate LIBDEFed RACFADM panel dataset to TSOHELP */  /* @A2 */
 /*-------------------------------------------------------*/  /* @A2 */
 "QLIBDEF ISPPLIB TYPE(DATASET) ID(DSNAME)"                   /* @A2 */
 QLIBRC = RC                                                  /* @A2 */
 IF (QLIBRC = 0) THEN DO                                      /* @A2 */
    Address TSO "alloc f(rachelp) da("dsname") shr reuse"     /* @A2 */
    call bpxwdyn "concat ddlist(syshelp,rachelp) msg(wtp)"    /* @A2 */
 END                                                          /* @A2 */

/* --------------------- *
 | Check for Warn switch |
 * --------------------- */
 if pos('/W',helpcmd) > 0 then do
    wp = pos('/W',helpcmd)
    helpcmd = strip(substr(helpcmd,1,wp-1))
    warn = 1
    end

/* --------------------- *
 | Check for test switch |
 * --------------------- */
 if pos('/T',helpcmd) > 0 then do
    wp = pos('/T',helpcmd)
    helpcmd = strip(substr(helpcmd,1,wp-1))
    ztsotest = 1
    end
 else ztsotest = 0
 Address ISPExec 'vput (ztsotest)'

/* --------------- *
 | define defaults |
 * --------------- */
  parse value '' with null load_info sortcol srchtsoh

/* ---------------------- *CUSTOM* -------------------------- *
 | The TSO Help member data may be inline or may be in        |
 | an external dataset.                                       |
 |                                                            |
 | If the helpds = * then it will be assumed to be            |
 | inline at the end of all the rexx records starting         |
 | with the >DATA record                                      |
 |                                                            |
 | If helpds is not * then it is assumed to be a              |
 | dataset.                                                   |
 |                                                            |
 | The format for this file is:                               |
 | ----+----1----+----2----+----3----+----4----+----5----+----|
 | COMPONENT: <--- Once per group (TSO:, RACF:, et al)        |
 | COMMAND    Description                                     |
 | . . .      . . .                                           |
 | LOCAL:                                                     |
 | JCL        JCL Standards for the installation              |
 | . . .      . . .                                           |
 | FREE:                                                      |
 | PDS        Swiss Army Knife of Utilities                   |
 | ABEND      TSO help member for abend codes                 |
 | . . .      . . .                                           |
 | TSO:                                                       |
 | ACCOUNT    Modify/add/delete user attributes in UADS       |
 | ALLOCATE   Allocate a data set with or without DCB parms   |
 | . . .      . . .                                           |
 * ---------------------------------------------------------- */
  /* Comment Start
  helpds = "'hlq.local.HELP(ZTSOTOC)'"
     Comment End */
  helpds = '*'

/* --------------------------------------------------- *
 | *custom*                                            |
 |                                                     |
 | Colorize the table columns                          |
 |                                                     |
 | clrs - color of sorted column                       |
 | clrn - color of non-sorted column                   |
 |                                                     |
 | Colors may be Blue, Turq, White, Green, Red, Yellow |
 * --------------------------------------------------- */
 clrn = 'green'                                               /* @A0 */
 clrs = 'turq'

/* ----------------------------------------------- *
 | *custom*  FSHELP or View                        |
 |                                                 |
 | SEt Toggles between ISPF View and FSHELP        |
 |                                                 |
 | 0 = ISPF View                                   |
 | 1 = FSHELP                                      |
 * ----------------------------------------------- */
 'vget (fshelp) profile'
 if datatype(fshelp) /= 'NUM' then
    fshelp = 0

/* ---------------------------------------------------- *
 |                         *Custom*                     |
 |                                                      |
 | Set notify to 0 to disable notifications for missing |
 |                 help members                         |
 |            to 1 to enable notifications for missing  |
 |                 help members                         |
 * ---------------------------------------------------- */
 notify = 0
 if warn = 1 then notify = 1

/* ---------------------------------------------------------- *
 | *custom*                                                   |
 |                                                            |
 | If zpns is 0 then the tab to point and shoot will NOT      |
 |    be turned off while the table is displayed              |
 | If zpns is 1 then the tab to point and shoot WILL BE       |
 |    turned off while the table is displayed                 |
 |                                                            |
 | NOTE: When the tab to point and shoot is turned off that   |
 |       it is turned off globally within ISPF.               |
 |                                                            |
 | WARNING: If ISPF (or TSO) crashes while the user in in     |
 |          table display with the tab turned off then that   |
 |          will be the default for the user until they       |
 |          manually reset it in the ISPF option 0 (SETTINGS) |
 |          dialog.                                           |
 * ---------------------------------------------------------- */
 zpns = 1    /* If tab to point and shoot is yes then turn off
                when the table display is active */
 zpns = 0    /* leave tab to point and shoot setting alone */

/* ------------------------- *
 | Read in the ZTSOHELP data |
 * ------------------------- */
  if helpds /= '*' then do
    Address TSO
    'Alloc f('helptab') shr reuse ds('helpds')'
    'Execio * diskr' helptab '(finis stem help.'
    'free f('helptab')'
    end
  else do
       lastrec = sourceline()
       hc = 0
       drop help.
       do i = 1 to lastrec
          line = sourceline(i)
          if translate(left(line,5)) = '>DATA' then leave
          end
       do ir = i to lastrec
          line = sourceline(ir)
          if pos('/*',line) > 0 then iterate
          if pos('*/',line) > 0 then iterate
          if pos('>DATA',line) > 0 then iterate
          if pos('>END',line) > 0 then leave
          hc = hc + 1
          help.hc = line
          end
          help.0 = hc
       end

/* ----------------------------------------- *
 | Build and Display the table of Help pages |
 * ----------------------------------------- */
  Address ISPExec
  'vget (ztps)'
  load_info = loadispf()
  call build_list
  ztdsels = 0
  src = 0
  rowcrp = 0
  crp = 1
  table_panel = 'zTSOHELP'
  do forever
    parse value null with zcmd zsel zerrsm zerrlm
    if helpcmd /= null then do
       tsocmd = helpcmd
       call do_it
       leave
       end
    if fshelp = 0 then viewfs = '(View)'
                  else viewfs = '(FSHelp)'
    if ztdsels > 0 then src = 4
    if zpns = 1 then
    if ztps = 'Y' then do
       ztpso = 'Y'
       /* ----------------------- *
        | Turn off TAB-PAS option |
        * ----------------------- */
        "select pgm(ispopt) parm(pstab(OFF))"
       end
    if src = 4 then "TBDispl" ztsohtbl
    else do
      "TBTOP" ztsohtbl
      "TBSKIP" ztsohtbl "NUMBER("crp")"
      if rowcrp = 0
      then "TBDISPL" ztsohtbl "PANEL("table_panel")"
      else "TBDISPL" ztsohtbl "PANEL("table_panel")",
        "CSRROW("rowcrp") AUTOSEL(NO)"
    end
    src = rc
    crp = ztdtop
    if zpns = 1 then
    if ztps = 'Y' then
       if ztpso = 'Y' then do
       /* ----------------------- *
        | Turn on  TAB-PAS option |
        * ----------------------- */
        "select pgm(ispopt) parm(pstab(ON))"
        end
    if src > 4 then do
       'tbclose' ztsohtbl
       leave
       end

    if datatype(row) /= 'NUM' then row = 0
    if row /= 0 then do
      ssel = zsel
      "TBTOP" ztsohtbl
      "TBSKIP" ztsohtbl "NUMBER("row")"
      zsel = ssel
      end
    if zcmd /= null then do
      Select
        When zcmd = 'RL' then do
             if srchtsoh = null then do
                smsg = 'Invalid'
                lmsg = 'Repeat Locate (RL) must follow' ,
                       'a Locate command.'
                'setmsg msg(ztso001)'
                end
             else call do_locate srchtsoh 'Next'
             end
        When abbrev('S',translate(word(zcmd,1)),1) = 1 then do
             parse value zcmd with x tsocmd
             if tsocmd = null then do
                smsg = 'Unknown'
                lmsg = 'Select requires a TSO Help member name.'
                'Setmsg msg(ztso001)'
                end
             else call do_it
             end
        When abbrev('LOCATE',translate(word(zcmd,1)),1) = 1 |,
          abbrev('FIND',translate(word(zcmd,1)),1) = 1 then
          call do_locate subword(zcmd,2)
        When abbrev('ONLY',translate(word(zcmd,1)),1) = 1 then do
          parse value zcmd with x string
          string = translate(string)
          'tbtop' ztsohtbl
          do forever
            'tbskip' ztsohtbl
            if rc > 0 then leave
            if pos(string,translate(tsocmd tsocomp tsodesc)) = 0
            then 'tbdelete' ztsohtbl
          end
          'tbtop' ztsohtbl
        end
        When abbrev('REFRESH',translate(word(zcmd,1)),1) = 1 then do
          'tbclose' ztsohtbl
          call build_list
          smsg = 'Refreshed'
          lmsg = 'Refresh completed and all TSO Help entries are' ,
                 'now displayed.'
          Address ISPExec 'Setmsg msg(ztso001)'
        end
        When abbrev('SET',translate(word(zcmd,1)),2) = 1 then do
          if fshelp = 0 then do
             fshelp = 1
             fshelps = 'On'
             'vput (fshelp) profile'
             end
          else do
               fshelp = 0
               fshelps = 'Off'
               'vput (fshelp) profile'
               end
          smsg = 'Set FSHELP' fshelps
          lmsg = 'Set of FSHELP to' fshelps
          Address ISPExec 'Setmsg msg(ztso001)'
        end
        When abbrev('SORT',translate(word(zcmd,1)),2) = 1 then do
          parse value zcmd with x cmd order
          cmds = null
          select
            when abbrev('COMMAND',cmd,4) = 1 then do
                 cmds = 'tsocmd'
                 pclrn = clrs
                 pclrc = clrn
                 pclrd = clrn
                 end
            when abbrev('COMPONENT',cmd,4) = 1 then do
                 cmds = 'tsocomp'
                 cmdc = 'tsocmd'
                 pclrn = clrn
                 pclrc = clrs
                 pclrd = clrn
                 end
            when abbrev('DESCRIPTION',cmd,2) = 1 then do
                 cmds = 'tsodesc'
                 cmdc = 'tsocmd'
                 pclrn = clrn
                 pclrc = clrn
                 pclrd = clrs
                 end
            otherwise do
                      smsg = 'Unknown'
                      lmsg = cmd 'is not a valid sort field. Use one' ,
                             'of the column headers.'
                      'setmsg msg(ztso001)'
                      end
          end
          if order = null then order = 'A'
          if pos(order,'AD') = 0 then order = 'A'
          'vput (pclrn pclrc pclrd)'
          if cmds /= null then
          if cmds = 'tsocomp'
             then 'tbsort' ztsohtbl 'fields('cmds',c,'order',tsocmd,c,a)'
             else 'tbsort' ztsohtbl 'fields('cmds',c,'order')'
          sortcol = cmds
          'tbtop' ztsohtbl
          crp = 1
        end
        Otherwise do
          smsg = 'Unknown'
          lmsg = word(zcmd,1) 'is an unknown command.'
          'Setmsg msg(ztso001)'
        end
      end
    end
    if zsel /= null then
    call do_it
  end

/* -------------------------- *
 | Done so clean up and leave |
 * -------------------------- */
  Address ISPEXEC
  do until length(load_info) = 0
    parse value load_info with dd libd load_info
    if left(libd,6) = "ALTLIB" then do
      if libd = "ALTLIBC"
      then lib = "CLIST"
      else lib = "EXEC"
      Address TSO,
        "Altlib Deact Application("lib")"
    end
    else "libdef" libd
    Address TSO "free f("dd")"
  end

 /* ----- *
  * Close *
  * ----- */
  "LMFree  Dataid("status")"

 /*----------------------------------------------------*/     /* @A2 */
 /* Remove LIBDEFed RACFADM panel dataset from TSOHELP */     /* @A2 */
 /*----------------------------------------------------*/     /* @A2 */
 IF (QLIBRC = 0) THEN DO                                      /* @A2 */
    call bpxwdyn "deconcat dd(syshelp) msg(wtp)"              /* @A2 */
    address tso "free f(rachelp)"                             /* @A2 */
 END                                                          /* @A2 */
  exit

/* -------------- *
 | Locate Routine |
 * -------------- */
Do_Locate:
  arg srchtsoh next
  if srchtsoh = null then do
    smsg = 'Invalid'
    lmsg = 'No TSO Help command provided'
    'Setmsg msg(ztso001)'
  end
  else do
    if next = null
       then 'tbtop' ztsohtbl
    else do
      'tbtop' ztsohtbl
      'tbskip' ztsohtbl 'Number('crp')'
       end
    rlhit = 0
    'tbvclear' ztsohtbl
    tsocmd = srchtsoh'*'
    if next /= null then next = 'NEXT'
    'tbsarg' ztsohtbl 'namecond(tsocmd,EQ)' next
    newcrp = 0
    'tbscan' ztsohtbl 'position(newcrp)'
    if rc > 0 then do
       if rlhit = 0 then do
          rlhit = 1
          'tbtop' ztsohtbl
          'tbvclear' ztsohtbl
          tsocmd = srchtsoh'*'
         'tbsarg' ztsohtbl 'namecond(tsocmd,EQ)'
          newcrp = 0
          'tbscan' ztsohtbl 'position(newcrp)'
          if rc = 0 then do
             crp = newcrp
             smsg = 'Wrapped'
             lmsg = srchtsoh 'found after wrapping the table.'
             'setmsg msg(ztso001)'
             end
          else do
               smsg = 'Not found'
               lmsg = srchtsoh 'not found.'
               'setmsg msg(ztso001)'
               end
          end
       else do
             smsg = 'Not found'
             lmsg = srchtsoh 'not found.'
             'setmsg msg(ztso001)'
             end
       end
    else do
         crp = newcrp
         smsg = 'Found'
         lmsg = srchtsoh 'found in row' crp
         'setmsg msg(ztso001)'
         end
    end
  Return

/* ---------------------------------------- *
 | Build the list of available Help pages   |
 * ---------------------------------------- */
build_list:
  Address ISPEXEC
  "LMInit Dataid(status) DDname(SYSHELP) ENQ(SHR)"
  ztsostat = status
  'Vput (ztsostat)'
  "LMOpen Dataid("status") Option(INPUT)"
  ztsohtbl = 'man'random(999)
  'tbcreate' ztsohtbl 'keys(tsocmd) names(tsocomp tsodesc)' ,
    'replace share nowrite'
  nohelp = null
  nofind = 0
  do i = 1 to help.0
    parse value help.i with tsocmd tsodesc
    tsocmd = strip(tsocmd)
    tsodesc = strip(tsodesc)
    if pos(':',tsocmd) > 0 then do
      colonm1 = pos(':',tsocmd) - 1
      tsocomp = substr(tsocmd,1,colonm1)
      iterate
    end
    'LMMFind Dataid('status') member('tsocmd')'
    if rc <> 0 then do
      nohelp = nohelp||left(tsocmd,9)
      nofind = nofind + 1
      iterate
    end
    'tbadd' ztsohtbl 'order'
  end
  if (nohelp <> null) & (helpcmd = null) & (notify = 1) then do
    smsg = nofind 'Members not found'
    lmsg = nohelp
    'Setmsg msg(ztso001)'
  end
  Address ISPExec
  'tbtop' ztsohtbl
  'tbsort' ztsohtbl 'fields(tsocmd,c,a)'
  sortcol = 'tsocmd'
  pclrn = clrs
  pclrc = clrn
  pclrd = clrn
  'vput (pclrn pclrc pclrd)'
  "LMClose Dataid("status")"
  return

/* ------------------------ *
 | Now display the Help page |
 * ------------------------ */
Do_It:
  Address ISPExec
  'Control Display Save'
  if fshelp = 0
     then do
          "LMOpen Dataid("status") Option(INPUT)"
          ztsostat = status
          'Vput (ztsostat)'
          'LMMFind Dataid('status') member('tsocmd')'
          if rc <> 0 then do
             smsg = 'Not found'
             lmsg = 'TSO Help member 'tsocmd' not found.'
             'Setmsg msg(ztso001)'
             end
          else call view_it
          end
     else 'Select CMD(fshelp 'tsocmd')'
  'Control Display Restore'
  return

View_it:
 thdd = 'zt'random(9999)
 Address TSO ,
 'Alloc f('thdd') new spa(5,5) tr dir(2) unit(SYSALLDA)' ,    /* @A3 */
       'recfm(f b) lrecl(80) blksize(0)'

 'lminit dataid(thd) ddname('thdd')'
 'lmcopy fromid('status') todataid('thd') frommem('tsocmd')'
 ztsohtit = 'TSO Help:' tsocmd
 'vput (ztsohtit)'
 'view dataid('thd') member('tsocmd') macro(ztsohm)' ,
    'panel(ztsohed) ChgWarn(no)'
 'lmfree dataid('thd')'
 Address TSO 'Free f('thdd')'
 "LMInit Dataid(status) DDname(SYSHELP) ENQ(SHR)"
 Return

/* --------------------  rexx procedure  -------------------- *
 * Name:      LoadISPF                                        *
 *                                                            *
 * Function:  Load ISPF elements that are inline in the       *
 *            REXX source code.                               *
 *                                                            *
 * Syntax:    rc = loadispf()                                 *
 *                                                            *
 *            The inline ISPF resources are limited to        *
 *            ISPF Messages, Panels, and Skeletons,           *
 *                 CLISTs and EXECs are also supported.       *
 *                                                            *
 *            The inline resources must start in column 1     *
 *            and use the following syntax:                   *
 *                                                            *
 *            >START    used to indicate the start of the     *
 *                      inline data                           *
 *                                                            *
 *            >END    - used to indicate the end of the       *
 *                      inline data                           *
 *                                                            *
 *            Each resource begins with a type record:        *
 *            >type name                                      *
 *               where type is CLIST, EXEC, MSG, PANEL, SKEL  *
 *                     name is the name of the element        *
 *                                                            *
 * Sample usage:                                              *
 *          -* rexx *-                                        *
 *          load_info = loadispf()                            *
 *          ... magic code happens here (your code) ...       *
 *          Address ISPEXEC                                   *
 *          do until length(load_info) = 0                    *
 *             parse value load_info with dd libd load_info   *
 *             if left(libd,6) = "ALTLIB" then do             *
 *                if libd = "ALTLIBC" then lib = "CLIST"      *
 *                                    else lib = "EXEC"       *
 *                Address TSO,                                *
 *                  "Altlib Deact Application("lib")"         *
 *                end                                         *
 *             else "libdef" libd                             *
 *             address tso "free f("dd")"                     *
 *             end                                            *
 *          exit                                              *
 *          >Start inline elements                            *
 *          >Panel panel1                                     *
 *          ...                                               *
 *          >Msg msg1                                         *
 *          ...                                               *
 *          >End of inline elements                           *
 *                                                            *
 * Returns:   the list of ddnames allocated for use along     *
 *            with the libdef's performed or altlib           *
 *                                                            *
 *            format is ddname libdef ddname libdef ...       *
 *                   libdef may be altlibc or altlibe         *
 *                   for altlib clist or altlib exec          *
 *                                                            *
 * Notes:     Entire routine must be included with REXX       *
 *            exec - inline with the code.                    *
 *                                                            *
 * Comments:  The entire rexx program is processed from the   *
 *            last record to the first to find the >START     *
 *            record at which point all records from that     *
 *            point on are processed until the >END           *
 *            statement or the end of the program is found.   *
 *                                                            *
 *            It is *strongly* suggested that the inline      *
 *            elements be at the very end of your code so     *
 *            that the search for them is faster.             *
 *                                                            *
 *            Inline ISPTLIB or ISPLLIB were not supported    *
 *            because the values for these would have to be   *
 *            in hex.                                         *
 *                                                            *
 * Author:    Lionel B. Dyck                                  *
 *                                                            *
 * History:                                                   *
 *            07/03/17 - Add code for inline help data        *
 *            05/10/16 - correction for clist and exec        *
 *            04/19/16 - bug correction                       *
 *            06/04/04 - Enhancements for speed               *
 *            08/05/02 - Creation                             *
 *                                                            *
 * ---------------------------------------------------------- *
 * Disclaimer: There is no warranty, either explicit or       *
 * implied with this code. Use it at your own risk as there   *
 * is no recourse from either the author or his employer.     *
 * ---------------------------------------------------------- */
 LoadISPF: Procedure expose help. helpds

 parse value "" with null kmsg kpanel kskel first returns ,
                     kclist kexec kdata
/* ------------------------------------------------------- *
 * Find the InLine ISPF Elements and load them into a stem *
 * variable.                                               *
 *                                                         *
 * Elements keyword syntax:                                *
 * >START - start of inline data                           *
 * >CLIST name                                             *
 * >EXEC name                                              *
 * >MSG name                                               *
 * >PANEL name                                             *
 * >SKEL name                                              *
 * >END   - end of all inline data (optional if last)      *
 * ------------------------------------------------------- */
 last_line = sourceline()
 do i = last_line to 1 by -1
    line = sourceline(i)
    if translate(left(line,6)) = ">START " then leave
    end
 rec = 0
/* --------------------------------------------------- *
 * Flag types of ISPF resources by testing each record *
 * then add each record to the data. stem variable.    *
 * --------------------------------------------------- */
 do j = i+1 to last_line
    line = sourceline(j)
    if translate(left(line,5)) = ">END "   then leave
    if translate(left(line,7)) = ">CLIST " then kclist = 1
    if translate(left(line,6)) = ">EXEC "  then kexec  = 1
    if translate(left(line,5)) = ">MSG "   then kmsg   = 1
    if translate(left(line,7)) = ">PANEL " then kpanel = 1
    if translate(left(line,6)) = ">SKEL "  then kskel  = 1
    rec  = rec + 1
    data.rec = line
    end

/* ----------------------------------------------------- *
 * Now create the Library and Load the Member(s)         *
 * ----------------------------------------------------- */
 Address ISPExec
/* ----------------------------- *
 * Assign dynamic random ddnames *
 * ----------------------------- */
 clistdd = "lc"random(999)
 execdd  = "le"random(999)
 msgdd   = "lm"random(999)
 paneldd = "lp"random(999)
 skeldd  = "ls"random(999)

/* ---------------------------------------- *
 *  LmInit and LmOpen each resource library *
 * ---------------------------------------- */
 if kclist <> null then do
    call alloc_dd clistdd
    "Lminit dataid(clist) ddname("clistdd")"
    "LmOpen dataid("clist") Option(Output)"
    returns = strip(returns clistdd 'ALTLIBC')
    end
 if kexec <> null then do
    call alloc_dd execdd
    "Lminit dataid(exec) ddname("execdd")"
    "LmOpen dataid("exec") Option(Output)"
    returns = strip(returns execdd 'ALTLIBE')
    end
 if kmsg <> null then do
    call alloc_dd msgdd
    "Lminit dataid(msg) ddname("msgdd")"
    "LmOpen dataid("msg") Option(Output)"
    returns = strip(returns msgdd 'ISPMLIB')
    end
 if kpanel <> null then do
    call alloc_dd paneldd
    "Lminit dataid(panel) ddname("paneldd")"
    "LmOpen dataid("panel") Option(Output)"
    returns = strip(returns paneldd 'ISPPLIB')
    end
 if kskel <> null then do
    call alloc_dd skeldd
    "Lminit dataid(skel) ddname("skeldd")"
    "LmOpen dataid("skel") Option(Output)"
    returns = strip(returns skeldd 'ISPSLIB')
    end

/* ----------------------------------------------- *
 * Process all records in the data. stem variable. *
 * ----------------------------------------------- */
 do i = 1 to rec
    record = data.i
    recordu = translate(record)
    if left(recordu,5) = ">END " then leave
    if left(recordu,7) = ">CLIST " then do
       if first = 1 then call add_it
       type = "Clist"
       first = 1
       parse value record with x name
       iterate
       end
    if left(recordu,6) = ">EXEC " then do
       if first = 1 then call add_it
       type = "Exec"
       first = 1
       parse value record with x name
       iterate
       end
    if left(recordu,5) = ">MSG " then do
       if first = 1 then call add_it
       type = "Msg"
       first = 1
       parse value record with x name
       iterate
       end
    if left(recordu,7) = ">PANEL " then do
       if first = 1 then call add_it
       type = "Panel"
       first = 1
       parse value record with x name
       iterate
       end
    if left(recordu,6) = ">SKEL " then do
       if first = 1 then call add_it
       type = "Skel"
       first = 1
       parse value record with x name
       iterate
       end

   /* --------------------------------------------*
    * Put the record into the appropriate library *
    * based on the record type.                   *
    * ------------------------------------------- */
    Select
      When type = "Clist" then
           "LmPut dataid("clist") MODE(INVAR)" ,
                 "DataLoc(record) DataLen(255)"
      When type = "Exec" then
           "LmPut dataid("exec") MODE(INVAR)" ,
                 "DataLoc(record) DataLen(255)"
      When type = "Msg" then
           "LmPut dataid("msg") MODE(INVAR)" ,
                 "DataLoc(record) DataLen(80)"
      When type = "Panel" then do
           phit = 0
           if left(record,2) = '/*' then phit = 1
           if left(record,2) = '*/' then phit = 1
           if phit = 0 then
           "LmPut dataid("panel") MODE(INVAR)" ,
                 "DataLoc(record) DataLen(80)"
           end
      When type = "Skel" then
           "LmPut dataid("skel") MODE(INVAR)" ,
                 "DataLoc(record) DataLen(80)"
      Otherwise nop
      end
    end

 if type <> null then call add_it
/* ---------------------------------------------------- *
 * Processing completed - now lmfree the allocation and *
 * Libdef the library.                                  *
 * ---------------------------------------------------- */
 if kclist <> null then do
    Address TSO,
    "Altlib Act Application(Clist) File("clistdd")"
    "LmFree dataid("clist")"
    end
 if kexec <> null then do
    Address TSO,
    "Altlib Act Application(Exec) File("execdd")"
    "LmFree dataid("exec")"
    end
 if kmsg <> null then do
    "LmFree dataid("msg")"
    "Libdef ISPMlib Library ID("msgdd") Stack"
    end
 if kpanel <> null then do
    "Libdef ISPPlib Library ID("paneldd") Stack"
    "LmFree dataid("panel")"
    end
 if kskel <> null then do
    "Libdef ISPSlib Library ID("skeldd") Stack"
    "LmFree dataid("skel")"
    end
 return returns

/* --------------------------- *
 * Add the Member using LmmAdd *
 * based upon type of resource *
 * --------------------------- */
 Add_It:
 Select
    When type = "Clist" then
         "LmmAdd dataid("clist") Member("name")"
    When type = "Exec" then
         "LmmAdd dataid("exec") Member("name")"
    When type = "Msg" then
         "LmmAdd dataid("msg") Member("name")"
    When type = "Panel" then
         "LmmAdd dataid("panel") Member("name")"
    When type = "Skel" then
         "LmmAdd dataid("skel") Member("name")"
    Otherwise nop
    end
 type = null
 return

/* ------------------------------ *
 * ALlocate the temp ispf library *
 * ------------------------------ */
 Alloc_DD:
 arg dd
 Address TSO
 if pos(left(dd,2),"lc le") > 0 then
 "Alloc f("dd") unit(SYSALLDA) spa(5,5) dir(1)",              /* @A3 */
    "recfm(v b) lrecl(255) blksize(32760)"
 else
 "Alloc f("dd") unit(SYSALLDA) spa(5,5) dir(1)",              /* @A3 */
    "recfm(f b) lrecl(80) blksize(23440)"
 return
/*
>START
>Panel zTSOHELP
)Attr Default(%+_)
   ! type( input) intens(high) caps(on ) just(left ) pad('_')
   ^ type(output) intens(low ) caps(off) just(asis ) pad(' ')
   01 type(output) intens(high) skip(on) color(&pclrn)
   02 type(output) intens(high) skip(on) color(&pclrc)
   03 type(output) intens(high) skip(on) color(&pclrd)
   ? type(output) intens(low ) caps(off) just(asis ) color(white)
   $ type(text) intens(high) hilite(reverse)
   % type(text) intens(high) skip(on)
   + type(text) intens(low) skip(on) color(green)             /* @A0 */
   # type(output) intens(high) caps(off) just(left)
     pas(on) skip(on) hilite(uscore)
   04 type(output) intens(high) caps(off) just(left)
     pas(on) skip(on) hilite(uscore) color(White)             /* @A0 */
   05 type(output) intens(high) caps(off) just(left)
     pas(on) skip(on) hilite(uscore) color(White)             /* @A0 */
   06 type(output) intens(high) caps(off) just(left)
     pas(on) skip(on) hilite(uscore) color(White)             /* @A0 */
)Body  Expand(\\) Width(&zscreenw)
%\-\ $RACF Help Commands?viewfs  $- &ver%\-\
%Command ===>_zcmd                                 \ \%Scroll ===>_amt +
%
+Command: %L cmd+- Locate #RL+- Repeat Locate %O str+- Only        #R+- Refresh
+         %S cmd+- Select #SE+- Set Viewer    %SOrt col A/D+- Sort
+Line:    %S+-Select+
+
%Sel+t1     + 	t2       +t3         +
)Model
!z+  z          z       z
)Init
  .ZVARS = '(zsel tsocmd tsocomp tsodesc)'
  if (&amt = &z)
      &amt = csr
 .cursor = zcmd
 .help = #ztsoh1
 &Refresh = 'Refresh'
 &RL      = 'RL'
 &R       = 'R'
 &SE      = 'SE'
 &t1      = 'Command'
 &t2      = 'Component'
 &T3      = 'Description'
 vget (pclrn pclrc pclrd)
)Proc
if (&zsel = _)
    &zsel = &z
ver (&zsel,list,S,'=')
if (&ztdsels = 0000)
   &row = .csrrow
   if (&row ^= 0)
       if (&zsel = &z)
           &zsel = 'S'
if (&ztdsels ^= 0000)
    &row = 0
if (&zsel ^= &z)
   if (&zsel = '=')
       &zsel = &osel
&osel = &zsel
if (&zcmd = 'name')
   if (&named = '')
      &zcmd = 'SORT COMM D'
      &named = 'd'
   else
      &zcmd = 'SORT COMM A'
      &named = ''
if (&zcmd = 'comp')
   if (&compd = '')
      &zcmd = 'SORT COMP A'
      &compd = 'a'
   else
      &zcmd = 'SORT COMP D'
      &compd = ''
if (&zcmd = 'desc')
   if (&descd = '')
      &zcmd = 'SORT DESC A'
      &descd = 'a'
   else
      &zcmd = 'SORT DESC D'
      &descd = ''
)Field
Field(tsodesc) len(80) scroll(zscrl)
)pnts
field(t1) var(zcmd) val(name)
field(t2) var(zcmd) val(comp)
field(t3) var(zcmd) val(desc)
field(r)  var(zcmd) val(Refresh)
field(rl) var(zcmd) val(RL)
field(se) var(zcmd) val(set)
*/
)End
>Panel #ztsoh1
)ATTR DEFAULT(%+_)
   %   TYPE(TEXT)  INTENS(HIGH) SKIP(ON)
   +   TYPE(TEXT)  INTENS(LOW)  SKIP(ON) COLOR(GREEN)         /* @A0 */
   !   TYPE(TEXT)  INTENS(LOW)  SKIP(ON) COLOR(RED)
   @   TYPE(TEXT)  INTENS(HIGH) SKIP(ON) HILITE(USCORE) COLOR(BLUE)
   _   TYPE(INPUT) INTENS(HIGH) CAPS(ON) JUST(LEFT) HILITE(USCORE)
)BODY EXPAND(\\)
%Tutorial+\-\(%RACHELP+)\-\%Tutorial
%Command ===>_ZCMD
+
+ This table lists some of the documented TSO commands.
+
+Commands:
   % Locate cmd next  +Locate the requested command in the table
   % Only string      +Remove all rows without string
   %*Refresh          +Refresh the table after using ONLY
   %*RL               +Repeat Locate
   % S cmd            +Select the command
   %*SEt              +Toggles between using ISPF View and FSHELP
   % SOrt column order+Sort the table using the column name
   +                   order is A or D (default is A)
+
+Line Selections: !(point-and-shoot field)+
%    S+               +Select a command to be browsed under View or FSHelp
+
%Note: +Column headers are point and shoot to sort. 1st use sort Ascending
+        and 2nd use sort Descending, etc.
+
+ \ \ (press%ENTER+to continue) \ \
)PROC
 &zcont = #ztsoh2
)End
>Panel #ztsoh2
)ATTR DEFAULT(%+_)
   %   TYPE(TEXT)  INTENS(HIGH) SKIP(ON)
   +   TYPE(TEXT)  INTENS(LOW)  SKIP(ON) COLOR(GREEN)         /* @A0 */
   !   TYPE(TEXT)  INTENS(LOW)  SKIP(ON) COLOR(RED)
   @   TYPE(TEXT)  INTENS(HIGH) SKIP(ON) HILITE(USCORE) COLOR(BLUE)
   _   TYPE(INPUT) INTENS(HIGH) CAPS(ON) JUST(LEFT) HILITE(USCORE)
)BODY EXPAND(\\)
%Tutorial+\-\(%RACHELP+)\-\%Tutorial
%Command ===>_ZCMD
+
%Notes:+To use Tab key to access Point and Shoot fields the Tab to Point
+       and Shoot must be selected in the ISPF Settings (ISPF Option 0).
+
+      +Use%Only+to limit the display to a specific string to more easily
+       find the command you need.
+
+       The description field is scrollable. Use Right and Left keys with
+       the cursor in a description field.
+
+     %*+Point and shoot commands. Set value saved in ISPF Profile.
+
 +The list was generated by: %"The Project to Document TSO Commands".
+
   +  William J. Smith, Editor-in-chief
   +  John Kalinich, Copy Editor and Programmer
   +  Lionel B. Dyck, Assistant Editor and Austin Bureau Chief
   +  Tom Conley,@Make ISPF Great Again+Campaign Manager
+
+ \ \ (press%ENTER+to continue) \ \
)PROC
 &zup = #ztsoh1
)END
>Panel ztsohed
/*
)PANEL KEYLIST(ISRSPEC,ISR)
)ATTR DEFAULT() FORMAT(MIX)            /* ISREDDE2 - ENGLISH - 7.1 */
 2A TYPE(ABSL) GE(ON)
 2B TYPE(PT)
 2F TYPE(FP)
 14 TYPE(NT)
 1B TYPE(NEF) PADC(USER)
 1C TYPE(VOI) PADC(USER)
 26 AREA(DYNAMIC) EXTEND(ON) SCROLL(ON) USERMOD('20')
 01 TYPE(DATAOUT) INTENS(LOW)
 02 TYPE(DATAOUT)
 03 TYPE(DATAOUT) SKIP(ON)
 04 TYPE(DATAIN) INTENS(LOW) CAPS(OFF) FORMAT(&MIXED)
 05 TYPE(DATAIN) CAPS(OFF) FORMAT(&MIXED)
 06 TYPE(DATAIN) INTENS(LOW) CAPS(IN) FORMAT(&MIXED)
 07 TYPE(DATAIN) CAPS(IN) FORMAT(&MIXED)
 08 TYPE(DATAIN) INTENS(LOW) FORMAT(DBCS) OUTLINE(L)
 09 TYPE(DATAIN) INTENS(LOW) FORMAT(EBCDIC) OUTLINE(L)
 0A TYPE(DATAIN) INTENS(LOW) FORMAT(&MIXED) OUTLINE(L)
 0B TYPE(DATAIN) INTENS(LOW) CAPS(IN) COLOR(&ZPLEXCLR) FORMAT(&MIXED)
 0C TYPE(DATAIN) INTENS(LOW) CAPS(OFF) COLOR(&ZPLEXCLR) FORMAT(&MIXED)
 0D TYPE(DATAIN) INTENS(LOW) CAPS(IN) COLOR(BLUE) FORMAT(&MIXED)
 13 TYPE(DATAOUT) SKIP(ON) HILITE(USCORE)
 16 TYPE(DATAIN) INTENS(LOW) CAPS(IN) HILITE(USCORE) FORMAT(&MIXED)
 17 TYPE(DATAIN) CAPS(IN) HILITE(USCORE) FORMAT(&MIXED)
 1D TYPE(DATAIN) INTENS(LOW) CAPS(IN) COLOR(BLUE) HILITE(USCORE)
      FORMAT(&MIXED)
 20 TYPE(DATAIN) INTENS(LOW) CAPS(IN) FORMAT(&MIXED)
 Z  TYPE(CHAR) COLOR(PINK) HILITE(REVERSE)
 R  TYPE(CHAR) COLOR(RED)
 G  TYPE(CHAR) COLOR(GREEN)
 B  TYPE(CHAR) COLOR(BLUE)
 W  TYPE(CHAR) COLOR(WHITE)
 P  TYPE(CHAR) COLOR(PINK)
 Y  TYPE(CHAR) COLOR(YELLOW)
 T  TYPE(CHAR) COLOR(TURQ)
 L  TYPE(CHAR) COLOR(RED)
 U  TYPE(CHAR) HILITE(USCORE)
 K  TYPE(CHAR) COLOR(&ZCK) HILITE(&ZHK)
 O  TYPE(CHAR) COLOR(&ZCO) HILITE(&ZHO)
 Q  TYPE(CHAR) COLOR(&ZCQ) HILITE(&ZHQ)
 C  TYPE(CHAR) COLOR(&ZCC) HILITE(&ZHC)
 V  TYPE(CHAR) COLOR(&ZCV) HILITE(&ZHV)
 D  TYPE(CHAR) COLOR(&ZCD) HILITE(&ZHD)
 F  TYPE(CHAR) COLOR(&ZCF) HILITE(&ZHF)
 S  TYPE(CHAR) COLOR(&ZCS) HILITE(&ZHS)
 Ü  TYPE(NEF) CAPS(ON) PADC(USER)
)BODY  EXPAND(//) WIDTH(&ZWIDTH)  CMD(ZCMD)
Z         Z/ /                                           ColumnsZ    Z    
Command ===>Z/ /                                            Scroll ===>ÜZ   
ZDATA,ZSHADOW/ /                                                              
/ /                                                                           
)INIT
.ZVARS = '(ZVMODET ZTITLE ZCL ZCR ZCMD ZSCED)'
&ZHIDEX = 'Y'
IF (&ZVMODET = 'VIEW') .HELP = ISR10000  /* DEFAULT TUTORIAL NAME */
ELSE                   .HELP = ISR20000  /* DEFAULT TUTORIAL NAME */
&zpm3 = 0
VGET (ZSCED) PROFILE        /* Fill Scroll Vars if       */
IF (&ZSCED = ' ') &ZSCED = 'PAGE'  /* Blank with page    */
&MIXED = TRANS(&ZPDMIX N,EBCDIC *,MIX) /* set mixed format */
VGET (ztsohtit)
&ztitle = &ztsohtit
*REXX(* zdata zshadow zwidth)
  colorr = left('R',zwidth,'R')
  colorb = left('B',zwidth,'B')
  colorw = left('W',zwidth,'W')
  colorq = left('Z',zwidth,'Z')
  blank = left(' ',zwidth,' ')
  if datatype(zhead) /= 'NUM' then
  parse value '0 0 0 ' with zhead zmiddle ztrail
  if length(zshadow) /= length(zdata) then
  zshadow = left(' ',length(zdata),' ')
  keys = 'FUNCTION: SYNTAX: OPERANDS: FORMAT: DESCRIPTION:' ,
         'MESSAGES: SUBCOMMANDS: SUBCOMMAND: USAGE RETURN EXAMPLES'
  do i = 1 to length(zshadow) by zwidth
    fw = translate(word(substr(zdata,i+8,30),1))
    if wordpos(fw,keys) > 0 then
    Select
      when pos('EXAMPLES',translate(substr(zdata,i,50))) > 0 then do
        p = pos('EXAMPLES',translate(substr(zdata,i,50)))
        if p < 14 then do
          zshadow = overlay(colorw,zshadow,i+p-1,8)
        end
      end
      when pos('USAGE NOTES',translate(substr(zdata,i,50))) > 0 then do
        p = pos('USAGE NOTES',translate(substr(zdata,i,50)))
        if p < 10 then do
          zshadow = overlay(colorw,zshadow,i+p-1,11)
        end
      end
      when pos('RETURN CODES',translate(substr(zdata,i,50))) > 0 then do
        p = pos('RETURN CODES',translate(substr(zdata,i,50)))
        if p < 10 then do
          zshadow = overlay(colorw,zshadow,i+p-1,12)
        end
      end
      otherwise do
        fwl = length(fw)
        zshadow = overlay(colorw,zshadow,i+8,fwl)
      end
    end
  end
*ENDREXX
)REINIT
REFRESH(*)
IF (&ZVMODET = 'VIEW') .HELP = ISR10000  /* DEFAULT TUTORIAL NAME */
ELSE                   .HELP = ISR20000  /* DEFAULT TUTORIAL NAME */
)PROC
REFRESH(*)
&ZCURSOR = .CURSOR
&ZCSROFF = .CSRPOS
VPUT (ZSCED) PROFILE
&ZLVLINE = LVLINE(ZDATA)
)FIELD
FIELD(ZTITLE)
FIELD(ZCMD) LEN(255)
*/
)END
/* 5650-ZOS     COPYRIGHT IBM CORP 1980, 2013 */
/* ISPDTLC Release: 7.1.  Level: PID                                  */
/* z/OS 02.01.00.  Created - Date: 19 Nov 2014, Time: 18:25           */
)END
>msg ztso00
ZTSO001 '&SMSG'
'&LMSG'
>EXEC ztsohm
  /* rexx */
  Address ISREdit
  'Macro (option)'
  '(last) = linenum .zlast'
  '(tsocmd) = member'
  'hilite off'
  if last = 0 then do
     smsg = 'Not Found'
     lmsg = tsocmd 'is not a valid TSO Help member.'
     Address ISPExec 'setmsg msg(ztso001)'
     'Cancel'
     Exit 1
     end
  "DEFINE ztsohme MACRO CMD"
  "DEFINE END ALIAS ztsohme"
  "exclude '*' 1 all"
  "delete x all"
  'caps off'
  "find ')F' first"
  '(ff) = cursor'
  if ff > 1 then
  'delete 1' ff-1 'all'
  '(num) = number'
  if num = 'ON' then 'UnNum'
  'ztsofhlp'
  header = center('TSO Help:' tsocmd,80)
  'line_before 1 = (header)'
  dash = center('-',80,'-')
  'line_after 1 = (dash)'
  blanks = ' '
  'line_after 2 = (blanks)'
  'recovery off nowarn'
  Address ISPExec 'vget (ztsotest)'
  if ztsotest /= 1 then
     'Reset'
  "Find 'TSO Help:" tsocmd"' first"
  Address ISPExec
  'vget (ztsostat)'
  'LMFree dataid('ztsostat')'
  Exit 1
>EXEC ztsohme
 /* rexx */
  Address ISREdit
  'Macro (option)'
  "DEFINE END    RESET"
  'Cancel'
>EXEC ztsohcut
/* ------------------------------------------------------- *
 | Cut all data to the ISPF clipboard                      |
 * ------------------------------------------------------- */
 Address ISREdit
 'Macro (option)'
 'Cut'
 'End'
>EXEC ztsofhlp
/* --------------------  rexx procedure  -------------------- *
 | Name:      ZTSOFHLP                                        |
 |                                                            |
 | Function:  ISPF Edit Macro to reformat a TSO Help member   |
 |                                                            |
 | Author:    Lionel B. Dyck                                  |
 |                                                            |
 | History:  (most recent on top)                             |
 |            10/19/17 - Improve performance for )I processing|
 |            10/18/17 - Remove non-display chars             |
 |                     - Move messages )M to the end          |
 |            07/10/17 - Incorporated into ZTSOHELP           |
 |            07/10/17 - Creation                             |
 * ---------------------------------------------------------- */
  Address ISREdit
  'Macro (options)'
  '(number) = num'
  if number /= 'OFF' then 'UNNUM'
  blank = ' '
  hit = 0
  '(last) = linenum .zlast'
/* ---------------------------------------------- *
 | Process all Inserts before doing anything else |
 * ---------------------------------------------- */
  do forever
     'Find ")I " 1 first'
     if rc > 0 then leave
     '(i) = cursor'
     '(data) = line' i
     call do_inserts
     end
/* -------------------------------- *
 | Now move all messages to the end |
 * -------------------------------- */
  call move_messages
/* ------------------------------- *
 | Begin processing of the records |
 * ------------------------------- */
  '(last) = linenum .zlast'
  i = 0
  do forever
    i = i + 1
    '(data) = line' i
    if hit = 0 then
       if left(data,1) /= ')' then call delete
    if left(data,1) = ')' then leave
    end
  i = i - 1
  do forever
    i = i + 1
    '(data) = line' i
    Select
      When left(data,1) = '*' then do
        call delete
      end
      When left(data,2) = '))' then do
        parse value data with '))' record 73 x
        record = ' ' record
        call update_nb
      end
      When left(data,1) = '=' then do
        parse value data with '=' record
        record = 'Subcommand:' ,
                 translate(record,' ','=')
        call update
      end
      When left(data,2) = ')F' then do
        parse value data with ')F' record more 73 x
        record = 'Function:'
        call update
        more = strip(more)
        if left(more,1) = '-' then do
           parse var more '-' record
           iu = iu + 1
           record = left(' ',2) record
           "Line_After" i '= (record)'
           end
      end
      When left(data,2) = ')M' then do
        parse value data with ')M' record 73 x
        record = 'Messages:'
        call update
      end
      When left(data,2) = ')O' then do
        parse value data with ')O' record 73 x
        record = 'Operands:'
        call update
      end
      When left(data,2) = ')P' then do
        parse value data with ')P' record 73 x
        call update
      end
      When left(data,2) = ')S' then do
        parse value data with ')S' record 73 x
        record = 'Subcommands:'
        call update
      end
      When left(data,2) = ')X' then do
        parse value data with ')X' record 73 x
        record = 'Syntax:'
        call update
      end
      Otherwise nop
    end
   '(last) = linenum .zlast'
    if i = last then leave
  end
/* ----------------------------------------------- *
 | Remove any sequence numbers                     |
 | and remove any comments - * in column 2 as they |
 | are not useful                                  |
 * ----------------------------------------------- */
  "change p'########' ' ' 73 80 all"
  "Exclude '*' 2 all"
  "Del x all"
/* --------------------------------------- *
 | Now remove any duplicated blank records |
 * --------------------------------------- */
  '(last) = linenum .zlast'
  "c p'.' ' ' all"
  i = 1
  do forever
  i = i + 1
  '(last) = linenum .zlast'
  if i > last then do
     'locate 0'
     exit 1
     end
 '(data) = line' i
 if strip(data) = '' then do
   j = i + 1
   if j > last then do
     'locate 0'
     exit 1
     end
   '(data) = line' j
   if strip(data) = '' then do
     'Label ' j '= .DEL'
     'Delete .del'
     '(last) = linenum .zlast'
     i = i - 1
     end
 end
  end
/* ------------------- *
 | Process all Inserts |
 * ------------------- */
 Do_Inserts:
    member = word(data,2)
    record = 'Include Help:' member
    'Label ' i '= .DEL'
    'Delete .DEL'
    i = i - 1
    "line_before" i "= noteline (record)"
    Address ISPExec
    'Vget (ztsostat)'
    'LMMFind Dataid('ztsostat') member('member')'
    if rc = 0  then do
      'View dataid('ztsostat') member('member') macro(ztsohcut)' ,
        'CHGWARN(NO)'
      Address ISREdit
      'Label ' i '= .PX'
      'Paste after .px'
      '(last) = linenum .zlast'
      end
 return
/* ---------------------------------------------- *
 | Move all messages to the end before processing |
 * ---------------------------------------------- */
 Move_Messages: Procedure
  '(last) = linenum .zlast'
  drop msgs.
  msgc = 1
  msgs.msgc = ' '
  msgf = 0
  do i = 1 to last
  if i > last then leave i
    '(data) = line' i
    if strip(data) = '' then iterate
    if left(data,3) = ')X ' then msgf = 0
    if left(data,3) = ')F ' then msgf = 0
    if left(data,3) = ')P ' then msgf = 0
    if left(data,3) = ')O ' then msgf = 0
    if left(data,3) = ')M ' then msgf = 1
    if msgf = 1 then do
       msgc = msgc + 1
       msgs.msgc = data
       'Label ' i '= .DEL'
       'Delete .DEL'
       '(last) = linenum .zlast'
       i = i - 1
       end
  end
  '(last) = linenum .zlast'
  do i = 1 to msgc
   data = msgs.i
   "Line_after" last " = (data)"
   last = last + 1
    end
 return

/* --------------- *
 | Delete a record |
 * --------------- */
Delete:
  'Label ' i '= .DEL'
  'Delete .del'
  i = i - 1
  last = last - 1
  return

/* -------------------------------------------- *
 | Insert a blank row above/below and change to |
 | a meaningful record.                         |
 * -------------------------------------------- */
Update:
  iu = 0
  record = strip(record,'T')
  "Line" i "= (record)"
  if i+1 < last then do
    '(data) = line' i +1
    if strip(data) /= '' then do
      iu = iu + 1
      "Line_after" i "= (blank)"
    end
  end
  if i > 1 then do
    '(data) = line' i -1
    if strip(data) /= '' then do
      iu = iu + 1
      "Line_before" i "= (blank)"
    end
  end
  i = i + iu
  last = last + iu
  return

/* -------------------------------------------- *
 | Remove the )) to make it a meaningful record |
 * -------------------------------------------- */
Update_nb:
  iu = 0
  record = strip(record,'T')
  "Line" i "= (record)"
  if i+1 < last then do
    '(data) = line' i +1
  end
  if i > 1 then do
    '(data) = line' i -1
    end
  i = i + iu
  last = last + iu
  return
>END
>DATA      Sample TSO Help Member directory information
/* keep the description to 53 characters to avoid truncation */
/* Group LOCAL is for local help members */
/* enclosed as a REXX comment to avoid REXX syntax errors
RACF:
ADDGROUP   Add group profile
ADDSD      Add data set profile
ADDUSER    Add user profile
ALTDSD     Alter data set profile
ALTGROUP   Alter group profile
ALTUSER    Alter user profile
CONNECT    Connect user to group
DELDSD     Delete data set profile
DELGROUP   Delete group profile
DELUSER    Delete user profile
LISTDSD    List data set profile
LISTGRP    List group profile
LISTUSER   List user profile
OPERMIT    Unix Access Control List Management, like PERMIT
ORALTER    Unix Security Attribute Management, like ALTER
ORLIST     Unix Directory/File Security Information, like RLIST
PASSWORD   Specify user password
PERMIT     Maintain resource access lists
RACDCERT   Manage RACF digital certificates
RACLINK    Administer user ID associations
RACMAP     Create, delete, list, or query an identity filter
RACPRIV    Set write-down privileges
RALTER     Alter general resource profile
RDEFINE    Define general resource profile
RDELETE    Delete general resource profile
REMOVE     Remove user from group
RLIST      List general resource profile
RVARY      Change status of RACF database
SEARCH     Search RACF database
SETROPTS   Set RACF options
RDADD      RACDCERT ADD (Add certificate)
RDADDRIN   RACDCERT ADDRING (Add key ring)
RDADDTOK   RACDCERT ADDTOKEN (Add token)
RDALTER    RACDCERT ALTER (Alter certificate)
RDALTMAP   RACDCERT ALTMAP (Alter mapping)
RDBIND     RACDCERT BIND (Bind certificate to token)
RDCHECKC   RACDCERT CHECKCERT (Check certificate or certificate chain)
RDCONNEC   RACDCERT CONNECT (Connect a certificate to key ring)
RDDELETE   RACDCERT DELETE (Delete certificate)
RDDELMAP   RACDCERT DELMAP (Delete mapping)
RDDELRIN   RACDCERT DELRING (Delete key ring)
RDDELTOK   RACDCERT DELTOKEN (Delete token)
RDEXPORT   RACDCERT EXPORT (Export certificate package)
RDGENCER   RACDCERT GENCERT (Generate certificate)
RDGENREQ   RACDCERT GENREQ (Generate request)
RDIMPORT   RACDCERT IMPORT (Import certificate)
RDLIST     RACDCERT LIST (List certificate)
RDLISTCH   RACDCERT LISTCHAIN (List certificate chain)
RDLISTMA   RACDCERT LISTMAP (List mapping)
RDLISTRI   RACDCERT LISTRING (List key ring)
RDLISTTO   RACDCERT LISTTOKEN (List token)
RDMAP      RACDCERT MAP (Create mapping)
RDREKEY    RACDCERT REKEY (Rekey certificate)
RDREMOVE   RACDCERT REMOVE (Remove certificate from key ring)
RDROLLOV   RACDCERT ROLLOVER (Rollover certificate)
RDUNBIND   RACDCERT UNBIND (Unbind certificate from token)
>END */
