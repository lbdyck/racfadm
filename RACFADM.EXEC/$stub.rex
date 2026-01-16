  /* --------------------  rexx procedure  -------------------- *
  | Name:      RACFADM Stub                                    |
  |                                                            |
  | Function:  Allocate the RACFADM Libraries and then         |
  |            invoke the RACFADM application.                 |
  |                                                            |
  | Syntax:    %racfadm option                                 |
  |                                                            |
  |            option is any menu option (e.g. 1)              |
  |                                                            |
  | Usage Notes: 1. Copy into a library in the standard        |
  |                 SYSEXEC (or SYSPROC) allocations for the   |
  |                 intended users.                            |
  |              2. Tailor the HLQ variable for the RACFADM    |
  |                 high-level-qualifier.                      |
  |                                                            |
  * ---------------------------------------------------------- */
  arg opt

 if opt = ''
    then opt = 'NA'
  hlq = 'cbt'   /* <=== Change this variable */

  Address TSO
  "Altlib Act App(Exec) Dataset('"hlq".racfadm.exec')"
  Address ISPExec
  "Libdef ISPLLIB Dataset ID('"hlq".racfadm.loadlib') stack"
  "Libdef ISPMLIB Dataset ID('"hlq".racfadm.msgs') stack"
  "Libdef ISPPLIB Dataset ID('"hlq".racfadm.panels') stack"
  "Libdef ISPSLIB Dataset ID('"hlq".racfadm.skels') stack"
  "Select Cmd(%RacfADM" opt") NewAppl(RADM) Passlib"
  "Libdef ISPLLIB"
  "Libdef ISPMLIB"
  "Libdef ISPPLIB"
  "Libdef ISPSLIB"
  Address TSO
  "Altlib DeAct App(Exec)"
