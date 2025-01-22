/*%NOCOMMENT====================* REXX *==============================*/
/*PURPOSE:  RACFADM - Generate Profile Source, Option G               */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @A3  250120  TRIDJK   Display MSG about RACRUN macro               */
/* @A2  241129  TRIDJK   Add conditional access PERMITs               */
/* @L1  241124  LBDYCK   Add comments and sample JCL                  */
/* @A1  241122  TRIDJK   Set SRT flag correctly                       */
/* @A0  241122  Xephon   CBT File 836 (RGENR)                         */
/*====================================================================*/
PANEL01     = "RACFGEN1"   /* Set filter, menu option G    */
PANELD1     = "RACFDISP"   /* Display report with colors   */
EDITMACR    = "RACFMRUN"   /* Edit Macro, RACRUN MSG       */
DDNAME      = 'RACFA'RANDOM(0,999) /* Unique ddname        */
parse source . . REXXPGM .         /* Obtain REXX pgm name */
REXXPGM     = LEFT(REXXPGM,8)
NULL        = ''
K           = 0                                                         /*@L1*/

ADDRESS ISPEXEC
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

/* Produce list of profiles for filter */
DISPLAY_PANEL:
  DO WHILE DISP_RC < 8
  "DISPLAY PANEL("PANEL01")" /* get filter and class */
  disp_rc = rc
  if disp_rc = 8 then
    exit
  IF CLASS = ' ' THEN
     CLASS = 'DATASET'
  REC.0 = 0
  X = OUTTRAP('SER.')
  cmd = "SEARCH FILTER("FILTER") CLASS("CLASS")"
  ADDRESS TSO cmd
  cmd_rc = rc
  X = OUTTRAP('OFF')
  IF SETMSHOW <> 'NO' THEN
     CALL SHOWCMD
  if cmd_rc > 0 then do
    call racfmsgs 'ERR16'
    end
  else
    leave
  end
                                                                        /*@L1*/
  /* ----------------------------- *                                    /*@L1*/
   | Insert model JCL and comments |                                    /*@L1*/
   * ----------------------------- */                                   /*@L1*/
   call add_rec '//*** Sample JCL to invoke the generated RACF commands'/*@L1*/
   call add_rec '//*** Copy into a permanent dataset, Edit, then Submit'/*@L1*/
   call add_rec '//***                              '                   /*@L1*/
   call add_rec '//TMP      EXEC  PGM=IKJEFT01'                         /*@L1*/
   call add_rec '//SYSTSPRT DD  SYSOUT=*      '                         /*@L1*/
   call add_rec '//SYSTSIN  DD  *             '                         /*@L1*/
/* call add_rec '//REMOVE   DD  *     /* REMOVE BEFORE USE */' */        /*@L1*/
   call add_rec '  '                                                    /*@L1*/

LIST:
DO I = 1 TO SER.0
   PROF = STRIP(SER.I)
   LPROF = LENGTH(PROF)
   IF LPROF > 3 THEN
      IF SUBSTR(PROF,LPROF-3,4) = ' (G)' THEN
         DO
            PROF = SUBSTR(PROF,1,LPROF-4)
            GEN = 'GEN'
         END
      ELSE
         GEN = ' '
   X = OUTTRAP('CMDREC.')
   IF CLASS = 'DATASET' THEN
      cmd = "LISTDSD DA('"PROF"') AUTH"
   ELSE
      cmd = "RLIST "CLASS" "PROF" AUTH"
  ADDRESS TSO cmd
  cmd_rc = rc
  X = OUTTRAP('OFF')
  IF SETMSHOW <> 'NO' THEN
     CALL SHOWCMD
   SRT = 1                                                    /* @A1 */
   CALL DEFINE
   CALL INCREM
   REC.K = ' '
   CALL ACCESS
   CALL INCREM
   REC.K = ' '
END
K = REC.0 + 1
REC.K = '/*'
CALL EDIT_INFO
EXIT 0

/* Produce definitions for this profile */
DEFINE:
AUD = ' '; INS = ''; LEV = ' '; OWN = ' '; UAC = ' '; WAR = ' '
IF CLASS = 'DATASET' THEN
   WSB = 4
ELSE
   WSB = 5
DO J = 1 TO CMDREC.0
   IF SUBSTR(CMDREC.J,SRT,12) = 'LEVEL  OWNER' THEN
      DO
         K = J + 2
         LEV = SUBWORD(CMDREC.K,1,1)
         OWN = SUBWORD(CMDREC.K,2,1)
         UAC = SUBWORD(CMDREC.K,3,1)
         WAR = SUBWORD(CMDREC.K,WSB,1)
      END
   IF SUBSTR(CMDREC.J,SRT,8) = 'AUDITING' THEN
      DO
         K = J + 2
         AUD = SUBWORD(CMDREC.K,1,1)
      END
   IF SUBSTR(CMDREC.J,SRT,6) = 'NOTIFY' THEN
      DO
         K = J + 2
         NOT = SUBWORD(CMDREC.K,1,1)
         IF NOT = 'NO' THEN
            NOT = ''
         ELSE
            NOT = "NOTIFY("NOT")"
      END
   IF SUBSTR(CMDREC.J,SRT,17) = 'INSTALLATION DATA' THEN
      DO
         K = J + 2
         INS = STRIP(SUBSTR(CMDREC.K,SRT))
         K = J + 3
         INS = INS STRIP(SUBSTR(CMDREC.K,SRT))
         INS = STRIP(INS)
      END
END
CALL INCREM
IF CLASS = 'DATASET' THEN
   REC.K = "ADDSD '"PROF"' "GEN" -"
ELSE
   REC.K = "RDEFINE "CLASS" "PROF" -"
CALL INCREM
REC.K = " LEVEL("LEV") OWNER("OWN") "NOT" -"
CALL INCREM
REC.K = " UACC("UAC") AUDIT("AUD") -"
IF WAR = 'YES' THEN
   DO
      CALL INCREM
      REC.K = " WARNING -"
   END
CALL INCREM
REC.K = " DATA('"INS"')"
RETURN 0

/* Produce permit list for this profile */
ACCESS:
START = 0
DO J = 1 TO CMDREC.0
   IF START = 1 THEN
      IF SUBSTR(CMDREC.J,1,17) = '            ' THEN
         START = 0
   IF START = 1 THEN
      DO
         RID = SUBWORD(CMDREC.J,1,1)
         IF SUBSTR(RID,1,1) \= '-' & RID \= 'NO' THEN
            DO
               ACC = SUBWORD(CMDREC.J,2,1)
               CALL INCREM
               S = SUBSTR('        ',1,8-LENGTH(RID))
               IF CLASS = 'DATASET' THEN
                  REC.K = "PE '"PROF"' ID("RID")"S" ACC("ACC")" GEN
               ELSE
                  DO
                     CLS = 'CL('CLASS')'
                     REC.K = "PE "PROF" ID("RID")"S" ACC("ACC")" GEN CLS
                  END
            END
      END
   IF CLASS = 'DATASET' THEN
      IF SUBSTR(CMDREC.J,1,16) = '   ID     ACCESS' THEN
         START = 1
   IF CLASS \= 'DATASET' THEN
      IF SUBSTR(CMDREC.J,1,16) = 'USER      ACCESS' THEN
         START = 1
END
/* RETURN 0 */

/* Produce conditional permit list for this profile */        /* @A2 */
CACCESS:                                                      /* @A2 */
START = 0                                                     /* @A2 */
DO J = 1 TO CMDREC.0                                          /* @A2 */
   IF START = 1 THEN                                          /* @A2 */
      IF SUBSTR(CMDREC.J,1,17) = '            ' THEN          /* @A2 */
         START = 0                                            /* @A2 */
   IF START = 1 THEN                                          /* @A2 */
      DO                                                      /* @A2 */
         RID = SUBWORD(CMDREC.J,1,1)                          /* @A2 */
         IF SUBSTR(RID,1,1) \= '-' & RID \= 'NO' THEN         /* @A2 */
            DO                                                /* @A2 */
               IF CLASS = 'DATASET' THEN DO                   /* @A2 */
                  ACC = SUBWORD(CMDREC.J,2,1)                 /* @A2 */
                  CLS = SUBWORD(CMDREC.J,3,1)                 /* @A2 */
                  ENT = SUBWORD(CMDREC.J,4,1)                 /* @A2 */
                  END                                         /* @A2 */
               ELSE DO                                        /* @A2 */
                  ACC = SUBWORD(CMDREC.J,2,1)                 /* @A2 */
                 CCLS = SUBWORD(CMDREC.J,4,1)                 /* @A2 */
                  ENT = SUBWORD(CMDREC.J,5,1)                 /* @A2 */
                  END                                         /* @A2 */
               CALL INCREM                                    /* @A2 */
               S = SUBSTR('        ',1,8-LENGTH(RID))         /* @A2 */
               IF CLASS = 'DATASET' THEN DO                   /* @A2 */
                  REC.K = "PE '"PROF"' ID("RID")"S" ACC("ACC")" GEN "-"
                  CALL INCREM                                 /* @A2 */
                  REC.K = "    WHEN("CLS"("ENT"))"            /* @A2 */
                  END                                         /* @A2 */
               ELSE DO                                        /* @A2 */
                     CLS = 'CL('CLASS')'                      /* @A2 */
                     REC.K = "PE "PROF" ID("RID")"S" ACC("ACC")" GEN "-"
                     CALL INCREM                              /* @A2 */
                     REC.K = "   "CLS" WHEN("CCLS"("ENT"))"   /* @A2 */
                  END                                         /* @A2 */
            END                                               /* @A2 */
      END                                                     /* @A2 */
   IF CLASS = 'DATASET' THEN                                  /* @A2 */
      IF SUBSTR(CMDREC.J,1,15) = '   ID    ACCESS' THEN       /* @A2 */
         START = 1                                            /* @A2 */
   IF CLASS \= 'DATASET' THEN                                 /* @A2 */
      IF SUBSTR(CMDREC.J,1,16) = '   ID     ACCESS' THEN      /* @A2 */
         START = 1                                            /* @A2 */
END                                                           /* @A2 */
RETURN 0                                                      /* @A2 */

  /* --------------------------------- *                                /*@L1*/
   | Insert record and increment rec.0 |                                /*@L1*/
   * --------------------------------- */                               /*@L1*/
Add_Rec:                                                                /*@L1*/
  parse arg addrec                                                      /*@L1*/
  k = k + 1                                                             /*@L1*/
  rec.0 = k                                                             /*@L1*/
  rec.k = addrec                                                        /*@L1*/
  return                                                                /*@L1*/

/* Increment counter in output array */
INCREM:
REC.0 = REC.0 + 1
K = REC.0
RETURN 0
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
     'log msg(isrz003)'
  END
RETURN
/*--------------------------------------------------------------------*/
/*  Edit information                                                  */
/*--------------------------------------------------------------------*/
EDIT_INFO:
  ADDRESS TSO "ALLOC F("DDNAME") NEW REUSE",
              "LRECL(80) BLKSIZE(0) RECFM(F B)",
              "UNIT(VIO) SPACE(1 5) CYLINDERS"
  ADDRESS TSO "EXECIO * DISKW "DDNAME" (STEM REC. FINIS"
  DROP REC.
  ADDRESS ISPEXEC
  "LMINIT DATAID(CMDDATID) DDNAME("DDNAME")"
  "EDIT DATAID("CMDDATID")",
       "PANEL("PANELD1")",
       "MACRO("EDITMACR")"                                    /* @A3 */
  ADDRESS TSO "FREE FI("DDNAME")"
RETURN
