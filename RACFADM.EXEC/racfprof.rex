/*%NOCOMMENT====================* REXX *==============================*/
/*  PURPOSE:  RACFADM - User/Group Profiles - Line cmd 'P' in opt 1/2 */
/*--------------------------------------------------------------------*/
/*  SYNTAX:   CALL RACFPROF 'USER/GROUP' userid/group                 */
/*--------------------------------------------------------------------*/
/*  NOTES:    1) Executes RACF administration API (IRRXUTIL)          */
/*                                                                    */
/*            2) Must have Settings (Opt 0) 'Administrator=Y' in      */
/*               order to display/use the line command 'P-Profile'    */
/*                                                                    */
/*            3) The user must have READ access to                    */
/*               'IRR.RADMIN.LIST_/RLIST' in FACILITY, plus           */
/*               authority to list the profile                        */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @AZ  200923  TRIDJK   PARSE ARG ...  (lower case for DIGTCERT/RING)*/
/* @AY  200423  RACFA    Move PARSE REXXPGM name up above IF SETMTRAC */
/* @AX  200422  RACFA    Fixed IRRXUTIL RC when displaying RACF cmds  */
/* @AW  200422  RACFA    Ensure the REXX program name is 8 chars      */
/* @AV  200422  RACFA    Use variable REXXPGM in log msg              */
/* @AU  200417  RACFA    Removed 'enq(exclu)', not needed             */
/* @AT  200413  RACFA    Chg TRACEing to only display banner (P=Pgms) */
/* @AS  200412  RACFA    Chg TRACE to allow 'L'abels or 'R'esults     */
/* @AR  200410  RACFA    Chk for 'None', display message              */
/* @AQ  200407  RACFA    Remove unnecessary spaces in group/profile   */
/* @AP  200403  RACFA    Fix IRRXUTIL, needed single quotes on parms  */
/* @AO  200403  RACFA    Chged 'cmd' var to text, so SHOWCMD works    */
/* @AN  200402  RACFA    No sec. access to IRRXUTIL, display err msg  */
/* @AM  200402  RACFA    Display RACF cmd, when profile has * or _    */
/* @AL  200401  RACFA    Chged edit macro RACFLOGE to RACFEMAC        */
/* @AK  200401  RACFA    VIEW/EDIT use edit macro, to turn off HILITE */
/* @AJ  200331  TRIDJK   Chg LEFT(RACF.PROFILE,8) to RACF.PROFILE     */
/* @AI  200324  TRIDJK   Chg loop var K to seg, due to conflict       */
/* @AH  200324  RACFA    Allow both display/logging of RACF commands  */
/* @AG  200324  RACFA    Allow logging RACF commands to ISPF Log file */
/* @AF  200316  RACFA    Fix profile=*, no go, display msg            */
/* @AE  200316  TRIDJK   No cmd trace if profile has special chars    */
/* @AD  200316  RACFA    Added spacing after semi-colon               */
/* @AC  200316  RACFA    Break up DATA field into multi-line msg      */
/* @AB  200316  RACFA    Added a space after semi-colon               */
/* @AA  200316  RACFA    Added SETMTRAC=YES, then TRACE R             */
/* @A9  200316  RACFA    Display RACF cmd (IRXXUTIL) after execution  */
/* @A8  200315  RACFA    If RC>0, then chg class variable (USER/GROUP)*/
/* @A7  200315  RACFA    Del/add space in front of data               */
/* @A6  200315  RACFA    Chged comments above                         */
/* @A5  200313  RACFA    Standardized REXX program                    */
/* @A4  200313  RACFA    Chg to allow editing/browsing the data       */
/* @A3  200313  TRIDJK   Display profile using R_admin extract vars   */
/* @A2  100101  WELLS    Created REXX   (brwells@us.ibm.com)          */
/* @A1  091201  ONGHENA  Created REXX   (onghena@us.ibm.com)          */
/* @A0  060101  WELLS    Created HLASM  (brwells@us.ibm.com)          */
/*====================================================================*/
PANELM2     = "RACFMSG2"   /* Display RACF command and RC  */ /* @A9 */
EDITMACR    = "RACFEMAC"   /* Edit Macro, turn HILITE off  */ /* @AL */
DDNAME      = 'RACFA'RANDOM(0,999) /* Unique ddname        */
parse source . . REXXPGM .         /* Obtain REXX pgm name */ /* @AY */
REXXPGM     = LEFT(REXXPGM,8)                                 /* @AY */

Parse arg class profile                                       /* @AZ */
Select                                                        /* @AR */
   When (profile = "*") then do                               /* @AF */
      call RACFMSGS ERR17                                     /* @AF */
      return                                                  /* @AF */
   end                                                        /* @AF */
   When (profile = "NO") then do                              /* @AR */
      call RACFMSGS ERR21                                     /* @AR */
      return                                                  /* @AR */
   end                                                        /* @AR */
   When (profile = "NONE") then do                            /* @AR */
      call RACFMSGS ERR21                                     /* @AR */
      return                                                  /* @AR */
   end                                                        /* @AR */
   otherwise                                                  /* @AR */
      nop                                                     /* @AR */
end                                                           /* @AR */

/* Initialize VIEW output stem */                             /* @A3 */
irrxout. = ''
irrx     = 0

ADDRESS ISPEXEC
  "VGET (SETGDISP SETMSHOW SETMTRAC) PROFILE"                 /* @A9 */
  If (SETMTRAC <> 'NO') then do                               /* @AS */
     Say "*"COPIES("-",70)"*"                                 /* @AS */
     Say "*"Center("Begin Program = "REXXPGM,70)"*"           /* @AS */
     Say "*"COPIES("-",70)"*"                                 /* @AS */
     if (SETMTRAC <> 'PROGRAMS') THEN                         /* @AT */
        interpret "Trace "SUBSTR(SETMTRAC,1,1)                /* @AS */
  end                                                         /* @AS */

  /* Call IRRXUTIL to extract the desired profile        */
  call exccmd                                                 /* @A9 */

  /* Check return code and exit if problem is discovered */
  if (word(cmd_rc,1) <> 0) then do                            /* @A9 */
     select                                                   /* @A8 */
        when (class = "USER") THEN class="GROUP"              /* @A8 */
        otherwise class="USER"                                /* @A8 */
     end                                                      /* @A8 */
     call exccmd                                              /* @A9 */
     if (word(cmd_rc,1) <> 0) then do                         /* @A9 */
        call sez "Error calling IRRXUTIL: "cmd_rc             /* @A9 */
        if (word(cmd_rc,1) = 12) then                         /* @A9 */
           call sez "R_admin failure"
        irrxout.0 = irrx
        call do_view_stem irrxout
        call Goodbye                                          /* @AS */
     end
  end

  /* Print header */
  call sez "Profile: "RACF.PROFILE,                           /* @AJ */
           " Segments: "||,                                   /* @AD */
           right(RACF.0,2,"0")

  /* Run through all segments */
  do seg = 1 to RACF.0                                        /* @AI */
     segname = RACF.seg      /* Get next segment name */      /* @AI */
     call sez "Segment: "left(segname,8)"  Fields:   "||,     /* @AD */
                    right(RACF.segname.0,2,"0")
     /* Run through the fields in this segment */
     do l = 1 to RACF.segname.0
        fieldName = RACF.segname.l /* Get next field name */

        /* If repeat header, handle the repeat group.     */
        /* Tricky part, to keep the repeat group together */
        if (RACF.segname.fieldname.repeatcount > 0) then do
           /* Get dimension (number of fields in a group)
              and cardinality (number of groups) */
           dimension = RACF.segname.fieldname.subfield.0
           repeats   = RACF.segname.fieldname.repeatcount
           call sez "Repeat field: "left(fieldname,8),        /* @AB */
                    "  Subfields: "right(dimension,2,"0")||,  /* @AD */
                    "  Occurrences: "right(repeats,4,"0")     /* @AD */

            /* For each repeat group */
           do rpt = 1 to repeats
                 /* Run thru each of the fields */
              do dim = 1 to dimension
                 /* Get repeat group field name */
                 subfld = RACF.segname.fieldname.SUBFIELD.dim
                 /* Get repeat group value */
                 call sez "  "left(subfld,8)": "||,           /* @AB */
                          RACF.segname.subfld.rpt
              end /* dim */
              call sez "  "COPIES("-",44)
           end /* repeats */
        end /* repeat header */
        else if (RACF.segname.fieldname.REPEATING = "TRUE") then do
           /* Skip repeating fields because */
           /* they were already handled     */
           /* in the logic above when the   */
           /* repeatheader was processed    */
        end
        else do /* not repeating */
           /* Display value for this field  */
           if (fieldname = "DATA") THEN                       /* @AC */
              call linegt55                                   /* @AC */
           else
              call sez "  "left(fieldname,8)||,               /* @A7 */
                       ": "RACF.segname.fieldname.1
        end /* not repeating */
     end /* fields */
  end /* segments */

  /* --------------------------------- */                     /* @A3 */
  /* Display connect groups for user   */                     /* @A3 */
  /* --------------------------------- */                     /* @A3 */
  if (class = 'USER') then do
     gcnt = racf.base.connects.repeatcount
     call sez 'Connect Groups:  ' 'Fields:'right(gcnt,2,"0")
     do i = 1 to gcnt
        call sez '  'racf.base.cgroup.i                       /* @A7 */
     end
  end

  /* --------------------------------- */                     /* @A3 */
  /* View IRRXUTIL output              */                     /* @A3 */
  /* --------------------------------- */                     /* @A3 */
  irrxout.0 = irrx
  call do_view_stem irrxout
  call Goodbye                                                /* @AS */
EXIT
/*--------------------------------------------------------------------*/
/*  If tracing is on, display flower box                         @AS  */
/*--------------------------------------------------------------------*/
GOODBYE:                                                      /* @AS */
  If (SETMTRAC <> 'NO') then do                               /* @AS */
     Say "*"COPIES("-",70)"*"                                 /* @AS */
     Say "*"Center("End Program = "REXXPGM,70)"*"             /* @AS */
     Say "*"COPIES("-",70)"*"                                 /* @AS */
  end                                                         /* @AS */
EXIT                                                          /* @AS */
/*--------------------------------------------------------------------*/
/*  Break up the line of data since it is larger than 50 chrs    @AC  */
/*--------------------------------------------------------------------*/
LINEGT55:                                                     /* @AC */
  FIELDLEN = LENGTH(RACF.segname.fieldname.1)                 /* @AC */
  FIELDREM = FIELDLEN//55                                     /* @AC */
  FIELDINT = FIELDLEN%55                                      /* @AC */
  if (FIELDREM > 0) THEN                                      /* @AC */
     FIELDINT = FIELDINT + 1                                  /* @AC */
  STRCOL = 1                                                  /* @AC */
  do J = 1 to FIELDINT                                        /* @AC */
     TMPFIELD = SUBSTR(RACF.segname.fieldname.1,STRCOL,55)    /* @AC */
     NOWORDS  = WORDS(TMPFIELD)                               /* @AC */
     WORDS    = ""                                            /* @AC */
     do K = 1 to NOWORDS                                      /* @AC */
        WORDS = WORDS" "WORD(TMPFIELD,K)                      /* @AC */
     end                                                      /* @AC */
     TMPFIELD = STRIP(WORDS)                                  /* @AC */
     if (J = 1) THEN                                          /* @AC */
        call sez "  "left(fieldname,8)||,                     /* @AC */
                 ": "tmpfield                                 /* @AC */
     else                                                     /* @AC */
        call sez "  "left(' ',8)||,                           /* @AC */
                 ": "tmpfield                                 /* @AC */
     STRCOL   = STRCOL + 55                                   /* @AC */
  end                                                         /* @AC */
RETURN                                                        /* @AC */
/*--------------------------------------------------------------------*/
/*  Add to stem                                                  @A3  */
/*--------------------------------------------------------------------*/
SEZ:
  parse arg text
  irrx = irrx + 1
  irrxout.irrx = text
RETURN
/*--------------------------------------------------------------------*/
/*  ISPF View Stem routine                                       @A3  */
/*--------------------------------------------------------------------*/
DO_VIEW_STEM:
  parse arg stem

Address TSO
  'alloc f('ddname') unit(vio) new reuse space(1,1) tracks',
        'lrecl(255) recfm(f b) blksize(0) dsorg(ps)'          /* @AZ */
  'execio * diskw' ddname '(finis stem' stem'.'

Address ISPExec
  'lminit dataid(id) ddname('ddname')'                        /* @AU */
  if (rc ^= 0) then do
     zedsmsg = 'Error'
     zedlmsg = 'Error.  LMINIT failed for VIO output file'
    'setmsg msg(isrz001)'
    call Goodbye                                              /* @AS */
  end
  Select                                                      /* @A4 */
     When (SETGDISP = "VIEW") THEN                            /* @A4 */
          "VIEW DATAID("id") MACRO("EDITMACR")"               /* @AK */
     When (SETGDISP = "EDIT") THEN                            /* @A4 */
          "EDIT DATAID("id") MACRO("EDITMACR")"               /* @AK */
     Otherwise                                                /* @A4 */
          'browse dataid('id')'                               /* @A4 */
  end                                                         /* @A4 */
  'lmfree dataid('id')'
  Address TSO 'free f('ddname')'
RETURN
/*--------------------------------------------------------------------*/
/*  Execute IRRUXTIL command                                     @A9  */
/*--------------------------------------------------------------------*/
EXCCMD:                                                       /* @A9 */
  class   = STRIP(class)                                      /* @AQ */
  profile = STRIP(profile)                                    /* @AQ */
  cmd = "IRRXUTIL('EXTRACT','"class"','"profile"','RACF',)"   /* @AP */
  interpret 'cmd_rc = 'cmd                                    /* @A9 */
  cmd_rc = WORD(cmd_rc,1)                                     /* @AX */
  if (SETMSHOW <> 'NO') then                                  /* @AG */
     call SHOWCMD                                             /* @A9 */
  if (WORD(cmd_rc,1) = 12) then                               /* @AN */
     call racfmsgs ERR20                                      /* @AN */
RETURN                                                        /* @A9 */
/*--------------------------------------------------------------------*/
/*  Display RACF command and return code                         @A9  */
/*--------------------------------------------------------------------*/
SHOWCMD:                                                      /* @A9 */
  IF (SETMSHOW = "BOTH") | (SETMSHOW = "DISPLAY") THEN DO     /* @AH */
     PARSE VAR CMD MSG1 60 MSG2 121 MSG3                      /* @A9 */
     MSG4 = "Return code = "cmd_rc                            /* @A9 */
     "ADDPOP ROW(6) COLUMN(4)"                                /* @A9 */
     "DISPLAY PANEL("PANELM2")"                               /* @A9 */
     "REMPOP"                                                 /* @A9 */
  END                                                         /* @AG */
  IF (SETMSHOW = "BOTH") | (SETMSHOW = "LOG") THEN DO         /* @AH */
     zerrsm = "RACFADM "REXXPGM" RC="WORD(cmd_rc,1)           /* @AV */
     zerrlm = cmd                                             /* @AG */
     'log msg(isrz003)'                                       /* @AG */
  END                                                         /* @AG */
RETURN                                                        /* @A9 */
