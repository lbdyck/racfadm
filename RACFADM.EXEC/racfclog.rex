  /* --------------------  rexx procedure  -------------------- *
  | Name:      RACFCLOG                                        |
  |                                                            |
  | Function:  Return 0 if SYSLOG and 1 if OPERLOG active      |
  |                                                            |
  | Syntax:    rc = racfclog(setpmsg)                          |
  |                                                            |
  | Usage Notes: called by RACFLOG and RACFMSG                 |
  |                                                            |
  | Dependencies:                                              |
  |                                                            |
  | Author:    Lionel B. Dyck                                  |
  |                                                            |
  | History:  (most recent on top)                             |
  |            2023/03/19 LBD - Add PARM                       |
  |            2023/03/17 EEJ - Update for (E)JES              |
  |            2023/03/17 LBD - Creation                       |
  |                                                            |
  * ---------------------------------------------------------- */

  arg setpmsg
  if setpmsg = '' then setpmsg = 'SDSF'

  /* ------------------------ *
  | Prime the command to use |
  * ------------------------ */
  cmd = 'D LOGGER'

  /* ------------------------- *
  | Process as SFSF or (E)JES |
  * ------------------------- */
  if setpmsg = 'SDSF' then do
    x = isfcalls('on')
    Address SDSF "ISFSLASH '"cmd"' (WAIT)"
    x = isfcalls('off')
    do i = 1 to isfulog.0
      if pos('---',isfulog.i) > 1 then leave
    end
    i = i + 1
    if pos('ACTIVE',isfulog.i) > 1
    then logtype = 1   /* Operlog Active */
    else logtype = 0   /* SYSLOG Active  */
  end
  else do   /* (E)JES */
    erc = ejesrexx("EXECAPI 0 '/"cmd"' (WAIT TERM")        /* EEJ */
    if erc > maxrc then maxrc = erc
    do i = 1 to ejes_ulog.0
      if pos('---',ejes_ulog.i) > 1 then leave
    end
    i = i + 1                                              /* EEJ */
    if pos('ACTIVE',ejes_ulog.i) > 1
    then logtype = 1   /* Operlog Active */
    else logtype = 0   /* SYSLOG Active  */
  end

  /* ---------------- *
  | Return to caller |
  * ---------------- */
  return logtype
