/*%NOCOMMENT====================* REXX *==============================*/
/*  PURPOSE:  RACFADM - OMVS RACF Commands - Menu option O            */
/*--------------------------------------------------------------------*/
/*  NOTES:    1) Allows executing the IBM REXX programs:              */
/*                 OPERMIT ... Unix Access Control List, like PERMIT  */
/*                 ORALTER ... Unix Security Attribute, like ALTER    */
/*                 ORLIST .... Unix Dir/File Security, like RLIST     */
/*            2) And one internal command                             */
/*                 FLIST...... Unix ZFS/HFS File Usage/Attribute Info */
/*                 GLIST...... Unix Group Identifier (GID) List       */
/*                 SLIST...... Showmvs UNIX System Services           */
/*                 ULIST...... Unix User/Group Identifier (UID/GID)   */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @AQ  200616  RACFA    Chg panel name RACFRPTS to RACFDISP          */
/* @AP  200611  RACFA    Fix, duplicate entries, was MODE||RESULT     */
/* @AO  200611  RACFA    Expanded dashes                              */
/* @AN  200611  RACFA    Added SLIST, display Showmvs Unix info.      */
/* @AM  200608  RACFA    F/G/ULIST, trans parm keywords to uppercase  */
/* @AL  200608  RACFA    GLIST, changed parm 'Name' to 'Group'        */
/* @AK  200608  RACFA    FLIST path, was disp 'no met srch criteria'  */
/* @AJ  200608  RACFA    Move translating abbreviation to panel       */
/* @AI  200608  TRIDJK   PERMIT/RALTER/RLIST, del TMPCMD, use OMVSCMD */
/* @AH  200608  RACFA    Fix init var OMVSCMDS due to a abbreviation  */
/* @AG  200608  RACFA    Upd F, upd verify parms, reduce code         */
/* @AF  200608  RACFA    Upd F/G/U, fix abbreviating commands         */
/* @AE  200608  RACFA    Upd F/G/U, move 'Numeric Digits' to top pgm  */
/* @AD  200608  RACFA    Upd F/G/U, move CHKPRM to init subroutine    */
/* @AC  200608  RACFA    Removed unnecessary 'TRACE O' left in code   */
/* @AB  200608  RACFA    Fix F/G/U, display error msg, for no entries */
/* @AA  200607  RACFA    If no recs found, display message            */
/* @A9  200607  RACFA    GLIST cmd, add verification of GID           */
/* @A8  200607  RACFA    UID/GID limit is 0 to 2,147,483,647          */
/* @A7  200607  RACFA    Added GLIST command                          */
/* @A6  200607  RACFA    Clean up code, reduce no. of subroutines     */
/* @A5  200606  RACFA    Enhanced ULIST to allow passing more parms   */
/* @A4  200606  RACFA    Enhanced FLIST to resolve/display path       */
/* @A3  200606  RACFA    Display report headers in color              */
/* @A2  200606  RACFA    Added FLIST command                          */
/* @A1  200606  RACFA    Added ULIST command                          */
/* @A0  200605  TRIDJK   Created REXX                                 */
/*====================================================================*/
PANEL01     = "RACFOMVS"    /* Obtain cmd, path and options*/
PANEL02     = "RACFDISP"    /* Display report with colors  */ /* @AQ */
EDITMACR    = "RACFEMAC"    /* Edit Macro, turn HILITE off */
UIDGIDLIMIT = 2417483647    /* Limit = 0 - 2,147,483,647   */ /* @A8 */
parse source . . REXXPGM .         /* Obtain REXX pgm name */
REXXPGM     = LEFT(REXXPGM,8)
numeric digits 12                                             /* @A2 */

ADDRESS ISPEXEC
  PARSE ARG MEMBER
  "VGET (SETGDISP SETGMVS SETMTRAC) PROFILE"                  /* @AN */
  If (SETGMVS = "YES") THEN DO                                /* @AN */
     OMVSCMDS = "¨(Flist, Glist, Permit, RAlter,",            /* @AN */
                "RList, Slist or Ulist)"                      /* @AN */
     OMVSDES1 = "ÝSList¨   Unix System Services (USS)",       /* @AN */
                "Information (Showmvs)"                       /* @AN */
     OMVSDES2 = "ÝUlist¨   Unix User/Group Identifier",       /* @AN */
                "(UID/GID) Information"                       /* @AN */
  END                                                         /* @AN */
  Else DO                                                     /* @AN */
     OMVSCMDS = "¨(Flist, Glist, Permit, RAlter,",            /* @AN */
                "RList or Ulist)"                             /* @AN */
     OMVSDES1 = "ÝUlist¨   Unix User/Group Identifier",       /* @AN */
                "(UID/GID) Information"                       /* @AN */
     OMVSDES2 = ""                                            /* @AN */
  END                                                         /* @AN */

  If (SETMTRAC <> 'NO') then do
     Say "*"COPIES("-",70)"*"
     Say "*"Center("Begin Program = "REXXPGM,70)"*"
     Say "*"COPIES("-",70)"*"
     if (SETMTRAC <> 'PROGRAMS') THEN
        interpret "Trace "SUBSTR(SETMTRAC,1,1)
  end

  Do Forever
     "DISPLAY PANEL("PANEL01")" /* get utility cmd options*/
     If (rc = 8) then exit
     CMDREC.  = ""                                            /* @A6 */
     CMDREC.0 = 0; NO = 0                                     /* @A6 */
     IF (OMVSCMD = "FLIST"),                                  /* @AJ */
      | (OMVSCMD = "GLIST"),                                  /* @AJ */
      | (OMVSCMD = "SLIST"),                                  /* @AN */
      | (OMVSCMD = "ULIST") THEN                              /* @AJ */
        CALL FLIST_GLIST_ULIST_INIT                           /* @A6 */
     IF (CMDREC.0 = 0) THEN DO                                /* @A6 */
        SELECT                                                /* @A1 */
           WHEN (OMVSCMD = "FLIST") THEN                      /* @AJ */
                call flist                                    /* @A2 */
           WHEN (OMVSCMD = "GLIST") THEN                      /* @AJ */
                call glist                                    /* @AH */
           WHEN (OMVSCMD = "SLIST") THEN DO                   /* @AN */
                IF (CHKPRM = "USERS") THEN                    /* @AN */
                   MVSPRM = "USS"                             /* @AN */
                ELSE                                          /* @AN */
                   MVSPRM = "UNIX"                            /* @AN */
                call RACFMVS MVSPRM                           /* @AN */
                ITERATE                                       /* @AN */
           END                                                /* @AN */
           WHEN (OMVSCMD = "ULIST") THEN                      /* @AJ */
                call ulist                                    /* @A1 */
           WHEN (OMVSCMD = "PERMIT") THEN DO                  /* @AJ */
                X = OUTTRAP("CMDREC.")                        /* @A1 */
                Address TSO "O"OMVSCMD OMVSPATH OMVSOPTS      /* @AJ */
                X = OUTTRAP("OFF")                            /* @A1 */
           end                                                /* @A1 */
           OTHERWISE DO                                       /* @A1 */
                X = OUTTRAP("CMDREC.")                        /* @A1 */
                parse var OMVSOPTS w1 w2
                if (w1 = "FSSEC") | (w1 = "fssec") then
                   Address TSO "O"OMVSCMD w1 OMVSPATH w2      /* @AI */
                else
                   Address TSO "O"OMVSCMD OMVSPATH OMVSOPTS   /* @AI */
                X = OUTTRAP("OFF")                            /* @A1 */
           END /* Select */                                   /* @A1 */
        END /* If CMDREC */                                   /* @A6 */
     end /*Do Forever */

     IF (CMDREC.0 = 0) THEN DO                                /* @AA */
        CMDREC.1 = "No records met the search criteria."      /* @AA */
        CMDREC.0 = 1                                          /* @AA */
     END                                                      /* @AA */

     ADDRESS TSO "ALLOC F("DDNAME") NEW REUSE",
                 "LRECL(132) BLKSIZE(0) RECFM(F B)",
                 "UNIT(VIO) SPACE(1 5) CYLINDERS"
     ADDRESS TSO "EXECIO * DISKW "DDNAME,
                 "(STEM CMDREC. FINIS"
     DROP CMDREC.

     "LMINIT DATAID(CMDDATID) DDNAME("DDNAME")"
     SELECT
        WHEN (SETGDISP = "VIEW") THEN DO                      /* @A3 */
             IF (OMVSCMD = "FLIST"),                          /* @A3 */
              | (OMVSCMD = "ULIST") THEN                      /* @A3 */
                "VIEW DATAID("CMDDATID")",                    /* @A3 */
                             "MACRO("EDITMACR")",             /* @A3 */
                             "PANEL("PANEL02")"               /* @A3 */
             ELSE                                             /* @A3 */
                "VIEW DATAID("CMDDATID")",                    /* @A3 */
                             "MACRO("EDITMACR")"              /* @A3 */
        END                                                   /* @A3 */
        WHEN (SETGDISP = "EDIT") THEN DO                      /* @A3 */
             IF (OMVSCMD = "FLIST"),                          /* @A3 */
              | (OMVSCMD = "ULIST") THEN                      /* @A3 */
                "EDIT DATAID("CMDDATID")",                    /* @A3 */
                             "MACRO("EDITMACR")",             /* @A3 */
                             "PANEL("PANEL02")"               /* @A3 */
             ELSE                                             /* @A3 */
                "EDIT DATAID("CMDDATID")",                    /* @A3 */
                             "MACRO("EDITMACR")"              /* @A3 */
        END                                                   /* @A3 */
        OTHERWISE
             "BROWSE DATAID("CMDDATID")"
     END /* Select */
     ADDRESS TSO "FREE FI("DDNAME")"
  End /* Do Forever */

  If (SETMTRAC <> 'NO') then do
     Say "*"COPIES("-",70)"*"
     Say "*"Center("End Program = "REXXPGM,70)"*"
     Say "*"COPIES("-",70)"*"
  end
EXIT
/*--------------------------------------------------------------------*/
/*  ULIST - Unix User/Group Identifier (UID/GID)                 @A6  */
/*--------------------------------------------------------------------*/
ULIST:                                                        /* @A1 */
  PARSE VAR CHKPRM "UID("UID")" .                             /* @A5 */
  PARSE VAR CHKPRM "GID("GID")" .                             /* @A5 */
  PARSE VAR CHKPRM "SHELL("SHELL")" .                         /* @A5 */
  PARSE VAR CHKPRM "HOME("HOME")" .                           /* @A5 */
  PARSE UPPER VAR CHKPRM W1 .                                 /* @A5 */
  IF (POS("(",W1) = 0) THEN                                   /* @A5 */
     ID = W1                                                  /* @A5 */
  ELSE                                                        /* @A5 */
     ID = ""                                                  /* @A5 */
                                                              /* @A5 */
  IF (ID <> "") THEN                                          /* @A5 */
     IF (LENGTH(ID) > 8) THEN DO                              /* @A1 */
        CMDREC.1 = 'The userid ('id') is larger than 8',      /* @A1 */
                   'characters in length.'                    /* @A1 */
        CMDREC.0 = 1                                          /* @A1 */
        return                                                /* @A1 */
     END                                                      /* @A1 */
  IF (UID <> "") THEN                                         /* @A5 */
     IF (DATATYPE(UID) <> "NUM"),                             /* @A8 */
      | (UID > UIDGIDLIMIT) THEN DO                           /* @A8 */
        CMDREC.1 = "The UID ("uid") is either not numeric",   /* @A8 */
                   "or greater than "UIDGIDLIMIT              /* @A8 */
        CMDREC.0 = 1                                          /* @A1 */
        return                                                /* @A1 */
     END                                                      /* @A1 */
  IF (GID <> "") THEN                                         /* @A5 */
     IF (DATATYPE(GID) <> "NUM"),                             /* @A8 */
      | (GID > UIDGIDLIMIT) THEN DO                           /* @A8 */
        CMDREC.1 = "The GID ("gid") is either not numeric",   /* @A8 */
                   "or greater than "UIDGIDLIMIT              /* @A8 */
        CMDREC.0 = 1                                          /* @A1 */
        return                                                /* @A1 */
     END                                                      /* @A1 */
                                                              /* @A1 */
  cmdrec.1 = " Userid     UID       GID    Shell   ",         /* @A1 */
             "Home-Directory"                                 /* @A1 */
  cmdrec.2 = "-------- ---------- ------- --------",          /* @A1 */
             "----------------"                               /* @A1 */
  NO = 2                                                      /* @A1 */
                                                              /* @A1 */
  address syscall "getpwent pw."                              /* @A1 */
  firstid = pw.1                                              /* @A1 */
  do forever                                                  /* @A1 */
     if (pw.1 <> previd) then do                              /* @A1 */
        IF (CHKPRM = "") THEN do                              /* @A1 */
           NO = NO + 1                                        /* @A1 */
           cmdrec.NO = pw.1 left(pw.2,10) left(pw.3,7),       /* @A1 */
                            left(pw.5,8)  left(pw.4,50)       /* @A1 */
        end                                                   /* @A1 */
        ELSE DO                                               /* @A1 */
           IF ((ID    <> "") & (ID    = PW.1)),               /* @A6 */
            | ((UID   <> "") & (UID   = PW.2)),               /* @A6 */
            | ((GID   <> "") & (GID   = PW.3)),               /* @A6 */
            | ((SHELL <> "") & (SHELL = PW.5)),               /* @A6 */
            | ((HOME  <> "") & (HOME  = PW.4)) THEN DO        /* @A6 */
              NO = NO + 1                                     /* @A1 */
              cmdrec.NO = pw.1 left(pw.2,10) left(pw.3,7),    /* @A1 */
                               left(pw.5,8)  left(pw.4,50)    /* @A1 */
           END                                                /* @A1 */
        end /* If CHKPRM */                                   /* @A1 */
     end /* If pw.1 */                                        /* @A1 */
     previd = pw.1                                            /* @A1 */
     address syscall "getpwent pw."                           /* @A1 */
     if (retval = -1) then                                    /* @A1 */
        leave                                                 /* @A1 */
     if (pw.1 = firstid) then                                 /* @A1 */
        leave                                                 /* @A1 */
  end /* Do Forever */                                        /* @A1 */
                                                              /* @AB */
  cmdrec.0 = NO                                               /* @A1 */
  IF (NO = 2) THEN DO   /* Just rpt hdr? */                   /* @AB */
     CMDREC.  = ""                                            /* @AB */
     CMDREC.0 = 0                                             /* @AB */
  END                                                         /* @AB */
RETURN                                                        /* @A1 */
/*--------------------------------------------------------------------*/
/*  FLIST - Unix ZFS/HFS File Usage/Attribute Information        @A6  */
/*--------------------------------------------------------------------*/
FLIST:                                                        /* @A2 */
  fsm.    = ''                                                /* @A2 */
  fsm.0.0 = ''                                                /* @A2 */
  fsm.0.1 = 'SECACL'                                          /* @A2 */
  fsm.1.0 = ''                                                /* @A2 */
  fsm.1.1 = 'UNMOUNT'                                         /* @A2 */
  fsm.2.0 = ''                                                /* @A2 */
  fsm.2.1 = 'CLIENT'                                          /* @A2 */
  fsm.3.0 = ''                                                /* @A2 */
  fsm.3.1 = 'NOAUTOMOVE'                                      /* @A2 */
  fsm.4.0 = ''                                                /* @A2 */
  fsm.4.1 = 'NOSEC'                                           /* @A2 */
  fsm.5.0 = ''                                                /* @A2 */
  fsm.5.1 = 'DFS-EXPORTED'                                    /* @A2 */
  fsm.6.0 = ''                                                /* @A2 */
  fsm.6.1 = 'NOSETUID'                                        /* @A2 */
  fsm.7.0 = 'RDWR'                                            /* @A2 */
  fsm.7.1 = 'READ'                                            /* @A2 */
  percent = -1                                                /* @A2 */
  string  = ''                                                /* @A2 */
                                                              /* @A2 */
  parse var CHKPRM "PERC("percent")" .                        /* @A2 */
  parse upper var CHKPRM "TEXT("string")" .                   /* @A2 */
  if (percent = '') & (string = '') & (CHKPRM <> '') THEN do  /* @A4 */
     call flist_resolve_path_name                             /* @A4 */
     return                                                   /* @A4 */
  end                                                         /* @A4 */
                                                              /* @A2 */
  if (percent <> '') & (datatype(percent) <> 'NUM') then do   /* @AG */
     CMDREC.1 = "The percentage must be numeric,",            /* @AG */
                "PERC("percent")."                            /* @AG */
     CMDREC.0 = 1                                             /* @AG */
     RETURN                                                   /* @A2 */
  end                                                         /* @A2 */
                                                              /* @A2 */
  address syscall "getmntent m."                              /* @A2 */
                                                              /* @A2 */
  CMDREC.1 = '%InUse Owner Filesystem / Mountpoint /',        /* @A2 */
             '(Mount-attributes)'                             /* @A2 */
  CMDREC.2 = '------ -----' copies('-',100)                   /* @AO */
  NO = 2                                                      /* @A2 */
                                                              /* @A2 */
  l  = 0                                                      /* @A2 */
  do i = 1 to m.0                                             /* @A2 */
     sysname = strip(m.mnte_sysname.i)                        /* @A2 */
     upper sysname                                            /* @A2 */
     fsname  = strip(m.mnte_fsname.i)                         /* @A2 */
     upper fsname                                             /* @A2 */
     path = strip(m.mnte_path.i)                              /* @A2 */
     upper path                                               /* @A2 */
     parm = strip(m.mnte_parm.i)                              /* @A2 */
     mode = ''                                                /* @A2 */
     if (m.mnte_mode.i > 255) then                            /* @A2 */
        m.mnte_mode.i = m.mnte_mode.i - 256                   /* @A2 */
     Call FLIST_Translate_Mode_Settings m.mnte_mode.i         /* @A2 */
     mode = result                                            /* @AP */
     if (string <> '') then do                                /* @A2 */
        if (substr(string,1,1) = '^'),                        /* @A2 */
         & (length(string) > 1) then do                       /* @A2 */
            stringx = substr(string,2)                        /* @A2 */
            if (pos(stringx,sysname) = 0),                    /* @A2 */
             & (pos(stringx,fsname)  = 0),                    /* @A2 */
             & (pos(stringx,path)    = 0),                    /* @A2 */
             & (pos(stringx,mode)    = 0),                    /* @A2 */
             & (pos(stringx,parm)    = 0) then                /* @A2 */
               call FLIST_get_usage                           /* @A2 */
        end                                                   /* @A2 */
        else do                                               /* @A2 */
           if (pos(string,sysname) > 0),                      /* @A2 */
            | (pos(string,fsname)  > 0),                      /* @A2 */
            | (pos(string,path)    > 0),                      /* @A2 */
            | (pos(string,mode)    > 0),                      /* @A2 */
            | (pos(string,parm)    > 0) then                  /* @A2 */
              call FLIST_get_usage                            /* @A2 */
        end                                                   /* @A2 */
     end /* If String */                                      /* @A2 */
     else                                                     /* @A2 */
        Call FLIST_Get_Usage                                  /* @A2 */
  end /* Do Forever */                                        /* @A2 */
                                                              /* @AB */
  IF (NO = 2) THEN DO   /* Just rpt hdr? */                   /* @AB */
     CMDREC.  = ""                                            /* @AB */
     CMDREC.0 = 0                                             /* @AB */
  END                                                         /* @AB */
  ELSE DO                                                     /* @AB */
     NO = NO + 1                                              /* @A2 */
     CMDREC.NO = COPIES("-",72)                               /* @A2 */
     NO = NO + 1                                              /* @A2 */
     CMDREC.NO = 'Total Filesystems Mounted =' m.0            /* @A2 */
     NO = NO + 1                                              /* @A2 */
     CMDREC.NO = 'Total Filesystems Listed  =' l              /* @A2 */
     CMDREC.0  = NO                                           /* @A2 */
  END                                                         /* @AB */
RETURN                                                        /* @A2 */
/*--------------------------------------------------------------------*/
/*  FLIST - Get usage                                            @A2  */
/*--------------------------------------------------------------------*/
FLIST_GET_USAGE:                                              /* @A2 */
  address syscall 'statfs' m.mnte_fsname.i s.                 /* @A2 */
  if (DATATYPE(S.STFS_BLOCKSIZE) = "NUM") THEN DO             /* @A2 */
     j = s.stfs_total * s.stfs_blocksize                      /* @A2 */
     k = s.stfs_inuse * s.stfs_blocksize                      /* @A2 */
     p = trunc(k/j*100,2)                                     /* @A2 */
  END                                                         /* @A2 */
                                                              /* @A2 */
  if (p > percent) then do                                    /* @A2 */
     l  = l + 1                                               /* @A2 */
     NO = NO + 1                                              /* @A2 */
     CMDREC.NO = right(p,6) left(m.mnte_sysname.i,5),         /* @A2 */
                 left(m.mnte_fsname.i,44)                     /* @A2 */
     NO = NO + 1                                              /* @A2 */
     CMDREC.NO = copies(' ',12) left(m.mnte_path.i,64)        /* @A2 */
     NO = NO + 1                                              /* @A2 */
     CMDREC.NO = copies(' ',12) '('strip(mode)')'             /* @A2 */
     if (parm <> '') then do                                  /* @A2 */
        NO = NO + 1                                           /* @A2 */
        CMDREC.NO = copies(' ',12) 'PARM('strip(parm)')'      /* @A2 */
     end                                                      /* @A2 */
  end                                                         /* @A2 */
RETURN                                                        /* @A2 */
/*--------------------------------------------------------------------*/
/*  FLIST - Translate Mount Table Hex Mode Settings to Words     @A2  */
/*--------------------------------------------------------------------*/
FLIST_TRANSLATE_MODE_SETTINGS:                                /* @A6 */
  arg mode                                                    /* @A2 */
  mode_in_hex = d2c(mode)                                     /* @A2 */
  mode = ''                                                   /* @A2 */
  do bit = 7 to 0 by -1                                       /* @A2 */
     and_value  = d2c(2**(7-bit))                             /* @A2 */
     bit_status = bitand(mode_in_hex,and_value) > '00'x       /* @A2 */
     fsm.bit    = fsm.bit.bit_status                          /* @A2 */
     if (fsm.bit <> '') then mode = mode||fsm.bit' '          /* @A2 */
  end                                                         /* @A2 */
RETURN MODE                                                   /* @A2 */
/*--------------------------------------------------------------------*/
/*  FLIST - Resolve path name                                    @A6  */
/*--------------------------------------------------------------------*/
FLIST_RESOLVE_PATH_NAME:                                      /* @A4 */
  ID = CHKPRM                                                 /* @A4 */
  address syscall 'stat (id) st.'                             /* @A4 */
  if (rc <> 0) & (retval = -1) then do                        /* @A6 */
     cmdrec.1 = 'Unable to find path' id                      /* @A4 */
     cmdrec.0 = 1                                             /* @A4 */
     return                                                   /* @A6 */
  end                                                         /* @A6 */
                                                              /* @A6 */
  address syscall "getmntent a."                              /* @A4 */
  address syscall 'realpath (id) path'                        /* @A4 */
  if (rc <> 0) | (retval = -1) then do                        /* @A4 */
     cmdrec.1 = 'Unable to resolve path for' id               /* @A4 */
     cmdrec.0 = 1                                             /* @A4 */
     return                                                   /* @A4 */
  end                                                         /* @A4 */
                                                              /* @A6 */
  cmdrec.1 = 'Specified path:' id                             /* @A4 */
  cmdrec.2 = 'Resolved  path:' path                           /* @A4 */
  cmdrec.3 = ' '                                              /* @A4 */
  cmdrec.4 = 'Resolved path dissection:'                      /* @A4 */
  cmdrec.5 = 'UGO Owning-User(Uid)   Owning-Group(Gid) ',     /* @A4 */
             'Path node'                                      /* @A4 */
  cmdrec.6 = '--- ------------------ ------------------',     /* @A4 */
             '--------->'                                     /* @A4 */
  no = 6                                                      /* @A4 */
                                                              /* @A4 */
  pp = ''                                                     /* @A4 */
  do while path <> ''                                         /* @A4 */
     parse var path p '/' path                                /* @A4 */
     pp = pp || '/' || p                                      /* @A4 */
     address syscall 'stat (pp) st.'                          /* @A4 */
     pw.pw_name = '-undef-'                                   /* @A4 */
     address syscall 'getpwuid (st.st_uid) pw.'               /* @A4 */
     uid = strip(pw.pw_name)'('st.st_uid')'                   /* @A4 */
     gr.gr_name = '-undef-'                                   /* @A4 */
     address syscall 'getgrgid (st.st_gid) gr.'               /* @A4 */
     gid=strip(gr.gr_name)'('st.st_gid')'                     /* @A4 */
     NO = NO + 1                                              /* @A4 */
     CMDREC.NO = st.st_mode left(uid,18) left(gid,18) pp      /* @A4 */
     call flist_chkmntpt                                      /* @A4 */
     if (result = 4) then do                                  /* @A4 */
        if (a.MNTE_MODE.i > 255) then                         /* @A4 */
           a.MNTE_MODE.i = a.MNTE_MODE.i - 256                /* @A4 */
        Call FLIST_Translate_Mode_Settings a.MNTE_MODE.i      /* @A4 */
        mode = result                                         /* @A4 */
        NO   = NO + 1                                         /* @A4 */
        CMDREC.NO = '    FileSys='a.MNTE_FSNAME.i             /* @A4 */
        NO   = NO + 1                                         /* @A4 */
        CMDREC.NO = '    Owner='left(a.MNTE_SYSNAME.i,5),     /* @A4 */
                    ' Mode=('strip(mode)')'                   /* @A4 */
     end                                                      /* @A4 */
     if (pp = '/') then pp = ''                               /* @A4 */
  end /* Do While */                                          /* @A4 */
                                                              /* @AB */
  cmdrec.0 = NO                                               /* @AK */
  IF (NO = 6) THEN DO   /* Just rpt hdr? */                   /* @AB */
     CMDREC.  = ""                                            /* @AB */
     CMDREC.0 = 0                                             /* @AB */
  END                                                         /* @AB */
RETURN                                                        /* @A4 */
/*--------------------------------------------------------------------*/
/*  FLIST - Check mount point                                    @A6  */
/*--------------------------------------------------------------------*/
FLIST_CHKMNTPT:                                               /* @A4 */
  do i = a.0 to 1 by -1                                       /* @A4 */
     if (a.MNTE_PATH.i = pp) then                             /* @A4 */
        return 4                                              /* @A4 */
  end                                                         /* @A4 */
RETURN 0                                                      /* @A4 */
/*--------------------------------------------------------------------*/
/*  GLIST - Group Identifier (GID) List                          @A7  */
/*--------------------------------------------------------------------*/
GLIST:                                                        /* @A7 */
  PARSE VAR CHKPRM "GROUP("GROUP")" .                         /* @AL */
  PARSE VAR CHKPRM "GID("TMPGID")" .                          /* @A7 */
                                                              /* @A7 */
  IF (TMPGID <> "") THEN                                      /* @A9 */
     IF (DATATYPE(TMPGID) <> "NUM"),                          /* @A9 */
      | (TMPGID > UIDGIDLIMIT) THEN DO                        /* @A9 */
        CMDREC.1 = "The GID ("tmpgid") is either not",        /* @A9 */
                   "numeric or greater than "UIDGIDLIMIT      /* @A9 */
        CMDREC.0 = 1                                          /* @A9 */
        return                                                /* @A9 */
     END                                                      /* @A9 */
                                                              /* @A9 */
  do forever                                                  /* @A7 */
     address syscall "getgrent gr."                           /* @A7 */
     if (retval = 0) | (retval = -1) then                     /* @A7 */
        leave                                                 /* @A7 */
     gid = left(gr.2,8)                                       /* @A7 */
     if (CHKPRM <> "") THEN                                   /* @A7 */
        SELECT                                                /* @AL */
           WHEN ((GROUP <> "") & (GROUP = gr.1)) THEN         /* @AL */
                NOP                                           /* @AL */
           WHEN ((GID <> "") & (TMPGID = gid)) THEN           /* @A7 */
                NOP                                           /* @A7 */
           OTHERWISE                                          /* @AL */
                ITERATE                                       /* @AL */
        END                                                   /* @AL */
     NO  = NO + 1                                             /* @A7 */
     CMDREC.NO = "Group-Name="gr.1 "GID="gid "#members="gr.3  /* @A7 */
     #m = gr.3                                                /* @A7 */
     do i = 4 to #m+3 by 7                                    /* @A7 */
        do j = i to i+6                                       /* @A7 */
           if (j > #m+3) then gr.j = ''                       /* @A7 */
        end                                                   /* @A7 */
        l = i + 1; m = i + 2; n = i + 3                       /* @A7 */
        o = i + 4; p = i + 5; q = i + 6                       /* @A7 */
        NO = NO + 1                                           /* @A7 */
        CMDREC.NO = "    "gr.i gr.l gr.m gr.n gr.o gr.p gr.q  /* @A7 */
     end /* Do I */                                           /* @A7 */
  end /* Do Forever */                                        /* @A7 */
                                                              /* @AL */
  CMDREC.0 = NO                                               /* @AL */
RETURN                                                        /* @A7 */
/*--------------------------------------------------------------------*/
/*  F/G/ULIST - Verify environment and display 'Patients' msg    @A6  */
/*--------------------------------------------------------------------*/
FLIST_GLIST_ULIST_INIT:                                       /* @A6 */
  NO     = 0                                                  /* @A6 */
  CHKPRM = STRIP(OMVSPATH)STRIP(OMVSOPTS)                     /* @AD */
                                                              /* @AM */
  UPPPRM = TRANSLATE(CHKPRM)            /* Translate parms */ /* @AM */
  colpos = pos('GID(',UPPPRM)           /* to uppercase    */ /* @AM */
  If (colpos > 0) then                                        /* @AM */
     CHKPRM = overlay('GID',CHKPRM,colpos,3)                  /* @AM */
  colpos = pos('GROUP(',UPPPRM)                               /* @AM */
  If (colpos > 0) then                                        /* @AM */
     CHKPRM = overlay('GROUP',CHKPRM,colpos,5)                /* @AM */
  colpos = pos('HOME(',UPPPRM)                                /* @AM */
  If (colpos > 0) then                                        /* @AM */
     CHKPRM = overlay('HOME',CHKPRM,colpos,4)                 /* @AM */
  colpos = pos('PATH(',UPPPRM)                                /* @AM */
  If (colpos > 0) then                                        /* @AM */
     CHKPRM = overlay('PATH',CHKPRM,colpos,4)                 /* @AM */
  colpos = pos('PERC(',UPPPRM)                                /* @AM */
  If (colpos > 0) then                                        /* @AM */
     CHKPRM = overlay('PERC',CHKPRM,colpos,4)                 /* @AM */
  colpos = pos('SHELL(',UPPPRM)                               /* @AM */
  If (colpos > 0) then                                        /* @AM */
     CHKPRM = overlay('SHELL',CHKPRM,colpos,4)                /* @AM */
  colpos = pos('TEXT(',UPPPRM)                                /* @AM */
  If (colpos > 0) then                                        /* @AM */
     CHKPRM = overlay('TEXT',CHKPRM,colpos,4)                 /* @AM */
  colpos = pos('UID(',UPPPRM)                                 /* @AM */
  If (colpos > 0) then                                        /* @AM */
     CHKPRM = overlay('UID',CHKPRM,colpos,3)                  /* @AM */
  colpos = pos('USERS',UPPPRM)                                /* @AN */
  If (colpos > 0) then                                        /* @AN */
     CHKPRM = overlay('USERS',CHKPRM,colpos,5)                /* @AN */
                                                              /* @A6 */
  if (OMVSCMD <> "SLIST") & (syscalls('ON') > 3) then do      /* @AN */
     CMDREC.1 = 'Unable to establish the SYSCALL',            /* @A1 */
                'environment.'                                /* @A1 */
     CMDREC.0 = 1                                             /* @A1 */
     return                                                   /* @A1 */
  end                                                         /* @A1 */
                                                              /* @A6 */
  racflmsg = "Retrieving data - Please be patient"            /* @A1 */
  "control display lock"                                      /* @A1 */
  "display msg(RACF011)"                                      /* @A1 */
RETURN                                                        /* @A6 */
