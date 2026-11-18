>Compare RACFUSR 'CBT.RACFADM.EXEC')
1  ISRSUPC   -   MVS/PDF FILE/LINE/WORD/BYTE/SFOR COMPARE UTILITY- ISPF FOR z/OS
 NEW: CBT.RACFADM.EXEC(RACFUSR)                               OLD: AD.RACFADM.EX

                      LISTING OUTPUT SECTION (LINE COMPARE)

 ID       SOURCE LINES
     ----+----1----+----2----+----3----+----4----+----5----+----6----+----7----+

 I -           panel02 = 'RACFUS2B'                                /* @JK */
 D -           panel02 = 'RACFUS2C'  /* TSOPROC TEST */            /* @JK */

 I -      if (details.getd_count = 'NO TSO INFORMATION') then leave
 D -   /* if (details.getd_count = 'NO TSO INFORMATION') then leave */
 D -      if (details.getd_count = 'NO TSO INFORMATION') then tsoproc = ''

 I -                         "DATEPASS INTPASS DATEPHRS",          /* @FA */
 D -                         "DATEPASS INTPASS DATEPHRS TSOPROC",  /* @FA */

1  ISRSUPC   -   MVS/PDF FILE/LINE/WORD/BYTE/SFOR COMPARE UTILITY- ISPF FOR z/OS
 NEW: CBT.RACFADM.EXEC(RACFUSR)                               OLD: AD.RACFADM.EX

                        LINE COMPARE SUMMARY AND STATISTICS

     2230 NUMBER OF LINE MATCHES               4  TOTAL CHANGES (PAIRED+NONPAIRE
        0 REFORMATTED LINES                    3  PAIRED CHANGES (REFM+PAIRED IN
        3 NEW FILE LINE INSERTIONS             0  NON-PAIRED INSERTS
        4 OLD FILE LINE DELETIONS              1  NON-PAIRED DELETES
     2233 NEW FILE LINES PROCESSED
     2234 OLD FILE LINES PROCESSED

 LISTING-TYPE = DELTA      COMPARE-COLUMNS =    1:72        LONGEST-LINE = 80
 PROCESS OPTIONS USED: SEQ(DEFAULT)

