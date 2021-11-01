/*%NOCOMMENT====================* REXX *==============================*/
/*     TYPE:  TSO Command                                             */
/*  PURPOSE:  RACF Unix Security Information for a Dir/File (RLIST)   */
/*--------------------------------------------------------------------*/
/*    NOTES:  Obtained utility and documentation from:                */
/*            ftp://public.dhe.ibm.com/s390/zos/racf/RacfUnixCommands */
/*--------------------------------------------------------------------*/
/* FLG  YYMMDD  USERID   DESCRIPTION                                  */
/* ---  ------  -------  -------------------------------------------- */
/* @A2  200701  RACFA    Updated doc, added dataset to OUTFILE()      */
/* @A1  200605  RACFA    Changed 'Syntax...End-Syntax' comments       */
/* @A0  200605  RACFA    Obtained REXX from IBM                       */
/*====================================================================*/
/**********************************************************************
 Licensed Materials - Property of IBM
 5650-ZOS
 Copyright IBM Corp. 2020

 Name:    ORLIST

 Version: 2

 Author: Bruce Wells - brwells@us.ibm.com

 Purpose: Display security information for a Unix file or directory
          using a syntax and output format similar to the RACF
          RLIST command

 Input:   An absolute path name

 NOTE!!! This exec is dependent upon the following "Syntax:" line and
         the "End-Syntax" line below in order to display the syntax
         when the exec is invoked without keyword parameters.

         Feel free to add/change examples to show things that are
         frequently done in your orgnization. But please preserve
         these surrounding lines.

 Beg-Syntax:
 Purpose:  Display security information for a Unix directory or
           file using a syntax and output format similar to the
           RACF RLIST command

 Syntax:   ORLIST absolute_path_name operands

 Operands: All keywords are optional
             FSSEC                (positional)
             absolute-path-name   (positional and required)
             AUTH
             DEBUG
             NODISplay
             OUTFILE(path-or-dataset-name)
             RECursive(ALL | CURRENT | FILESYS)
                             -------
 Examples:
   1) Display all security information
        ORLIST FSSEC /u/brwells/myfile

   2) Display all security information omitting the optional class name
        ORLIST /u/brwells/myfile

   3) Display only the attributes used in a POSIX access decision
        ORLIST /u/brwells/myfile AUTH

   4) Write information for an entire directory to an output file
      without diplaying it on the terminal
        ORLIST /u/brwells/myfile RECURSIVE NODISPLAY

 End-Syntax

**********************************************************************/
/*******************************************************************/
/*                                                                 */
/* This program contains code made available by IBM Corporation    */
/* on an AS IS basis. Any one receiving this program is            */
/* considered to be licensed under IBM copyrights to use the       */
/* IBM-provided source code in any way he or she deems fit,        */
/* including copying it, compiling it, modifying it, and           */
/* redistributing it, with or without modifications, except that   */
/* it may be neither sold nor incorporated within a product that   */
/* is sold.  No license under any IBM patents or patent            */
/* applications is to be implied from this copyright license.      */
/*                                                                 */
/* The software is provided "as-is", and IBM disclaims all         */
/* warranties, express or implied, including but not limited to    */
/* implied warranties of merchantibility or fitness for a          */
/* particular purpose.  IBM shall not be liable for any direct,    */
/* indirect, incidental, special or consequential damages arising  */
/* out of this agreement or the use or operation of the software.  */
/*                                                                 */
/* A user of this program should understand that IBM cannot        */
/* provide technical support for the program and will not be       */
/* responsible for any consequences of use of the program.         */
/*                                                                 */
/*******************************************************************/
parse arg keywords                        /* Input keywords/values   */
parse source . . execName .               /* Info about this exec    */

/*********************************************************************/
/* The following configuration variables affect the operation of     */
/* this exec.                                                        */
/*********************************************************************/
/*********************************************************************/
/* --------------   Start of Configuration Variables --------------- */
/*********************************************************************/

/*********************************************************************/
/* doIrrxutil controls whether or not RACF's IRRXUTIL function is    */
/* used to check for the existence of FSACCESS and FSEXEC profiles   */
/* that cover the file system data set containing the object being   */
/* listed. Change the value to 1 to get this extra information,      */
/* after confirming that you have at least READ authority to         */
/* IRR.RADMIN.RLIST in the FACILITY class.                           */
/*********************************************************************/
doIrrxutil = 0

/*********************************************************************/
/* outputFile is the name of the file in which the generated         */
/* output will be written.  By default, it is set to                 */
/* <exec-name>.output, where exec-name is the name you have saved    */
/* this exec as (ORLIST by default).                                 */
/*                                                                   */
/* You can change this to any path name you want, relative or        */
/* absolute.                                                         */
/*                                                                   */
/* You can also specify a pre-allocated, cataloged data set.  It     */
/* can be a sequential data set or a PDS member. To specify a data   */
/* set use the shell convention for a data set, which is to start    */
/* it with "//" and enclose it within single quotes. For example:    */
/*  outputFile = "//'HLQ.SEQUENTL.DATASET'"                          */
/*   or                                                              */
/*  outputFile = "//'HLQ.PDS(MEMBER)'"                               */
/*********************************************************************/
outputFile = execname".output"

/*********************************************************************/
/* --------------   End of Configuration Variables ----------------- */
/*********************************************************************/

/*********************************************************************/
/* Define/initialize command keyword names and values.               */
/*********************************************************************/
AUTHkwd        = "AUTH"          ; authVal        = 0
DEBUGkwd       = "DEBUG"         ; debugVal       = 0
NODISPLAYkwd   = "NODISPLAY"     ; noDisplayVal   = 0
NODISabbr      = 5          /* NODIS is shortest allowed abbrev.     */
RECURSIVEkwd   = "RECURSIVE"     ; recursiveVal   = ''
RECabbr        = 3          /* REC is shortest allowed abbreviation  */
OUTFILEkwd     = "OUTFILE"       ; outfileVal     = ''
OUTabbr      = 3            /* OUT is shortest allowed abbreviation  */

/*********************************************************************/
/* -----------------   Start of Mainline     ----------------------- */
/*********************************************************************/

call syscalls('ON')  /* Initialize UNIX environment */
address syscall

output. = ''                     /* Initialize stem for output lines */
output.0 = 0

/*********************************************************************/
/* Display syntax if no arguments are supplied.                      */
/*********************************************************************/
If Length(keywords) = 0 Then Do
  Display = "no"
  If sourceline() > 0 Then Do
    Do i = 1 to sourceline()
     If Word(sourceline(i),1) = "Beg-Syntax:" Then do         /* @A1 */
       Display = "yes"
       iterate                                                /* @A1 */
     end                                                      /* @A1 */
     If Word(sourceline(i),1) = "End-Syntax" Then
       Leave
     If Display = "yes" Then
       say Substr(sourceline(i),1,72)
    End
  End
  Signal GETOUT
End

/*********************************************************************/
/* Inspect the first positional argument.  If it is 'FSSEC', we      */
/* remove it from the command image and ignore it.  We tolerate      */
/* this in case the user wants ORLIST to look just like the RLIST    */
/* command, in which the 1st positional keyword is the class name.   */
/*********************************************************************/
temp = Word(keywords,1)          /* Get 1st keyword                  */
Upper temp
If temp = 'FSSEC' Then
  keywords = Subword(keywords,2) /* Remove class from keyword string */

/*********************************************************************/
/* Get positional path name argument.                                */
/*********************************************************************/
path = Word(keywords,1)          /* 1st keyword is the path name     */

/*********************************************************************/
/* Obtain information on passed path name.                           */
/*********************************************************************/
"stat (path) stat."

/* Check for success.                                               */
If retval = -1 then Do
 Select /* errno */
  When errno = ENOENT Then
    say "The specified path does not exist."
  When errno = EACCES Then Do
    Say "You are not authorized to reach" path"."

    /*****************************************************************/
    /* Now, for extra credit, we will check for search access to     */
    /* the directory components of the path name, since that is a    */
    /* common cause of error, and display the first such directory   */
    /* to which the user is not authorized. (There is no sense in    */
    /* continuing beyond that point because they will all yield a    */
    /* failure even if search access is present.)                    */
    /*****************************************************************/
    checkpath = ''      /* The path to check */
    workpath = path     /* A working copy of the input path */
    Do Forever
      idx = Pos('/',workpath)
      If idx = 0 Then    /* no more slashes means we are finished    */
        leave
      checkpath = checkpath || Substr(workpath,1,idx)
      workpath = Substr(workpath,idx+1) /* Lop off head */

      "access (checkpath)" X_OK

      if retval = -1 then do
        say "You do not have search access to" checkpath
        Leave
      End
    End
  End    /* EACCES */
  Otherwise Do
    say "Error locating target object.",
        " Stat() retval =" retval "errno =" ,
         errno "errnojr =" errnojr
  End
 End     /* Select errno*/
 Signal GETOUT
End /* retval = -1 */

/*********************************************************************/
/* Remove path from keyword string for subsequent processing.        */
/*********************************************************************/
keywords = Subword(keywords,2)  /* Remove path from keyword string   */

/*********************************************************************/
/* Parse the keywords and values from the keyword string.            */
/*********************************************************************/
execRc = 0
execRc = parseKeywords()
If execRc /= 0 Then
  Signal GETOUT

/*********************************************************************/
/* If OUTFILE was specified, override the value of the outputFile    */
/* configuration variable.                                           */
/*********************************************************************/
If outfileVal /= '' Then
  outputFile = outfileVal

/*********************************************************************/
/* Build output file header.                                         */
/*********************************************************************/
Call buildOutputHeader
Call sey ' '

/*********************************************************************/
/* Pre-process RECURSIVE keyword.                                    */
/*                                                                   */
/* This is only valid when the target object is a directory.         */
/*                                                                   */
/* We obtain a list of sub-objects. This will contain the target     */
/* itself.                                                           */
/*                                                                   */
/* We obtain the lists now so that they can be placed in the         */
/* output file prior to generating the command output. This          */
/* allows for an up-front list of the objects that are displayed,    */
/* in the order in which they are subsequently displayed.            */
/*                                                                   */
/*********************************************************************/
@stem = filelist.
If recursiveVal /= '' Then Do
  call readdirproc path,@stem,recursiveVal

  /*******************************************************************/
  /* If debug is on, display the lists directly (don't write them    */
  /* to the output stem), and exit without performing normal         */
  /* listing operations.                                             */
  /*******************************************************************/
  If debugVal > 0 Then Do
    say 'Directories:' dirlist.0
    Do i = 1 to dirlist.0
      say dirlist.i
    End

    say ''

    say 'Files:' filelist.0
    Do i = 1 to filelist.0
      say filelist.i
    End
    Signal GETOUT
  End
  /*******************************************************************/
  /* If debug is not specified, use the 'sey' procedure to write     */
  /* both to the display and to the output file. Then let the        */
  /* ORLIST command proceed as normal.                               */
  /*******************************************************************/
  Else Do
    Call sey 'Directories:' dirlist.0
    Do i = 1 to dirlist.0
      Call sey dirlist.i
    End

    Call sey ' '

    Call sey 'Files:' filelist.0
    Do i = 1 to filelist.0
      Call sey filelist.i
    End
    Call sey ' '
  End
End

/*********************************************************************/
/* Display the specified object if RECURSIVE not specified.          */
/*********************************************************************/
If recursiveVal = '' Then Do
  execRc = ProcessOutput(path)
  If execRc /= 0 Then
    Signal GETOUT
End

/*********************************************************************/
/* Process RECURSIVE keyword.                                        */
/*                                                                   */
/* This is only valid when the target object is a directory.         */
/*                                                                   */
/* Process the list of sub-objects already gathered above. This      */
/* will contain the target itself.                                   */
/*                                                                   */
/*********************************************************************/
If recursiveVal /= '' Then Do
  /*******************************************************************/
  /* Process directories.                                            */
  /*******************************************************************/
  Do objs = 1 to dirlist.0
    Call sey ' '
    sep =,
'!-------------------------- Next Directory -------------------------!'
    Call sey sep
    Call sey ' '
    execRc = processOutput(dirlist.objs)
    If execRc /= 0 Then
      Signal GETOUT
  End

  /*******************************************************************/
  /* Process files.                                                  */
  /*******************************************************************/
  Do objs = 1 to filelist.0
    Call sey ' '
    sep =,
'!---------------------------- Next File ----------------------------!'
    Call sey sep
    Call sey ' '
    execRc = processOutput(filelist.objs)
    If execRc /= 0 Then
      Signal GETOUT
  End
End


GETOUT:

/*********************************************************************/
/* Write the output stem to the output file.                         */
/*********************************************************************/
If output.0 > 0 Then
  scriptOK = writeOutputFile()

Exit

/*********************************************************************/
/* -----------------     End of Mainline     ----------------------- */
/*********************************************************************/


processOutput:
/*********************************************************************/
/* procedure: processOutput                                          */
/*                                                                   */
/* input:  - The path name to display                                */
/*                                                                   */
/* output: - Returns a return code                                   */
/*                                                                   */
/* Notes:  - This is essentially just a continuation of mainline     */
/*           processing, put into a subroutine so that it can be     */
/*           called iteratively for sub-objects by the RECURSIVE     */
/*           keyword.                                                */
/*                                                                   */
/*********************************************************************/
parse arg rpath

poRc = 0  /* Return value */

/*********************************************************************/
/* Obtain information on passed path name.                           */
/*                                                                   */
/* Note we only expect the possibility of 'not-found' when called    */
/* for the path specified on the command.  For the RECURSIVE         */
/* option, the subobjects have already been located.                 */
/*                                                                   */
/*********************************************************************/
"stat (rpath) rstat."
If retval < 0 Then Do
  If errno = ENOENT Then
    say "Target object does not exist:" rpath
  Else If errno = EACCES Then
    say 'Not authorized to read' rpath'.'
  Else
    say "Error locating" rpath". Retval =" retval "errno =" ,
         errno "errnojr =" errnojr
  pkRc = 8
  Signal kwdExit
End

/*********************************************************************/
/* Echo the 'class' and path name, as RLIST does for profiles.       */
/*********************************************************************/
Call sey "CLASS      NAME"
Call sey "-----      ----"
msg = Left('FSSEC',10) rpath
Call sey msg
Call sey " "

If authVal = 0 Then Do           /* Display if AUTH not specified    */
  /*******************************************************************/
  /* We have file information.  Now get mount entry information      */
  /* by calling getmntent with the device number just returned by    */
  /* stat().                                                         */
  /*******************************************************************/
  "getmntent mnt." x2d(rstat.ST_DEV)
  Call sey "FILE SYSTEM CONTAINER ATTRIBUTES"
  Call sey "--------------------------------"
  fsn = Strip(mnt.MNTE_FSNAME.1)
  Call sey Left("NAME =" fsn,44) "TYPE =" mnt.MNTE_FSTYPE.1
  Call sey "MOUNT POINT =" mnt.MNTE_PATH.1

  /*******************************************************************/
  /* Display various mount mode options.                             */
  /* I haven't tested nosecurity/setuid    TBD                       */
  /*******************************************************************/
  mntmode = d2x(mnt.MNTE_MODE.1,8)
  mntmode=substr(mntmode,8)

  nosecurity = 0
  mode = ""
  modebit = bitand(mntmode,'01'x)='01'x
  If modebit = 1 then
    mode = mode || "READ-ONLY "
  Else
    mode = mode || "READ/WRITE "

  modebit = bitand(mntmode,'08'x)='08'x
  If modebit = 1 then Do
    mode = mode || "NOSECURITY "
    nosecurity = 1
  End

  modebit = bitand(mntmode,'02'x)='02'x
  If modebit = 1 then
    mode = mode || "NOSETUID "

  Call sey "Mount mode =" mode

  /*******************************************************************/
  /* Obtain the devno of the root directory for use in the           */
  /* FSACCESS processing below.  Since we have already passed the    */
  /* checking on the stat for the specified path, we assume it       */
  /* will work for the root.                                         */
  /*******************************************************************/
  "stat / rstem."

  /*******************************************************************/
  /* Indicate if containing file system is covered by an FSACCESS    */
  /* profile.                                                        */
  /* - FSACCESS is supported only for zFS                            */
  /*   - but not for the root or when mounted with NOSECURITY        */
  /*******************************************************************/
  If doIrrxutil = 1                             &,
     mnt.MNTE_FSTYPE.1 = 'ZFS' & nosecurity = 0 &,
     rstat.ST_DEV /= rstem.ST_DEV Then Do
    myrc = IRRXUTIL("EXTRACT","FSACCESS",fsn,"RES",,"TRUE")
    Select
      When myrc = "0 0 0 0 0" Then
        Call sey "Covered in FSACCESS class by" RES.PROFILE
      When myrc = "12 12 4 4 4" Then
        Call sey "Not protected by an FSACCESS class profile"
      When myrc = "12 12 4 4 16" Then
        Call sey "Not protected by an FSACCESS class profile"
      When myrc = "12 12 8 8 24" Then
        Call sey "Unable to report on FSACCESS coverage due to lack",
                 "of R_admin authorization"
      Otherwise
        Call sey "Unable to report on FSACCESS coverage due to",
                 "IRRXUTIL error" myrc
    End /* Select */
  End

  /*******************************************************************/
  /* Indicate if containing file system is covered by an FSEXEC      */
  /* profile.                                                        */
  /* - FSEXEC is supported only for zFS and TFS                      */
  /*******************************************************************/
  /* We cannot tell for sure if a file is an executable, but we will */
  /* only make the check for a regular file with at least one        */
  /* execute bit on (ignoring the acl).                              */
  /*******************************************************************/
  up = getperms(Substr(rstat.ST_MODE,1,1))
  gp = getperms(Substr(rstat.ST_MODE,2,1))
  op = getperms(Substr(rstat.ST_MODE,3,1))

  If doIrrxutil = 1                           &,
     (mnt.MNTE_FSTYPE.1 = 'ZFS' | mnt.MNTE_FSTYPE.1 = 'TFS') &,
     nosecurity = 0 & rstat.ST_TYPE = S_ISREG &,
     (Substr(up,3,1)='x' | Substr(gp,3,1)='x' | Substr(op,3,1)='x'),
  Then Do
    myrc = IRRXUTIL("EXTRACT","FSEXEC",fsn,"RES",,"TRUE")
    Select
      When myrc = "0 0 0 0 0" Then
        Call sey "Covered in FSEXEC class by" RES.PROFILE
      When myrc = "12 12 4 4 4" Then
        Call sey "Not protected by an FSEXEC class profile"
      When myrc = "12 12 4 4 16" Then
        Call sey "Not protected by an FSEXEC class profile"
      When myrc = "12 12 8 8 24" Then
        Call sey "Unable to report on FSEXEC coverage due to lack",
                 "of R_admin authorization"
      Otherwise
        Call sey "Unable to report on FSEXEC coverage due to",
                 "IRRXUTIL error" myrc
    End /* Select */
  End
  Call sey " "

  /*******************************************************************/
  /* Display file information                                        */
  /*******************************************************************/

  /*******************************************************************/
  /* Display file type                                               */
  /*******************************************************************/
  Call sey "FILE TYPE"
  Call sey "----------------------"
  Select
    When rstat.ST_TYPE = S_ISREG Then
      type = "Regular file"
    When rstat.ST_TYPE = S_ISDIR Then
      type = "Directory"
    When rstat.ST_TYPE = S_ISCHR Then
      type = "Character special file"
    When rstat.ST_TYPE = S_ISFIFO Then
      type = "FIFO special file"
    /* Apparently, this will never return S_ISSYM because it will    */
    /* follow the link instead. I'd have to incorporate lstat.       */
    When rstat.ST_TYPE = S_ISSYM Then
      type = "Symbolic link"
    Otherwise
      type = "Unknown"
  End
  Call sey type
  Call sey " "
End                              /* Don't display if AUTH specified  */

  /*******************************************************************/
  /* Map the returned UID to a user ID.  If that fails, we will      */
  /* just display the UID.                                           */
  /*******************************************************************/
  "getpwuid (rstat.ST_UID) pw."
  If retval <= 0 Then
    user = rstat.ST_UID
  Else
    user = pw.PW_NAME

  /*******************************************************************/
  /* Map the returned GID to a group.  If that fails, we will        */
  /* just display the GID.                                           */
  /*******************************************************************/
  "getgrgid (rstat.ST_GID) gr."
  If retval <= 0 Then
    group = rstat.ST_GID
  Else
    group = gr.GR_NAME

  /*******************************************************************/
  /* Display owning user and group, the 'other' bits as UACC, and    */
  /* 'YOUR ACCESS'.                                                  */
  /*******************************************************************/
  op = getperms(Substr(rstat.ST_MODE,3,1)) /* Get 'other' bits       */

  "access (rpath)" R_OK
  If retval = -1 Then
    uacc = "-"
  Else
    uacc = "r"
  "access (rpath)" W_OK
  If retval = -1 Then
    uacc = uacc||"-"
  Else
    uacc = uacc||"w"
  "access (rpath)" X_OK
  If retval = -1 Then
    uacc = uacc||"-"
  Else
    uacc = uacc||"x"

  Call sey "OWNER        GROUP OWNER  UNIVERSAL ACCESS  YOUR ACCESS"
  Call sey "----------   -----------  ----------------  -----------"
  Call sey Left(user,12) Left(group,12) Left(op,17) uacc
  Call sey " "

If authVal = 0 Then Do           /* Display if AUTH not specified    */
  /*******************************************************************/
  /* Display the security label                                      */
  /*******************************************************************/
  Call sey "SECLABEL"
  Call sey "--------"
  If Length(rstat.ST_SECLABEL) = 0 Then
    secl = "NO SECLABEL"
  Else
    secl = rstat.ST_SECLABEL
  Call sey secl
  Call sey " "

  /*******************************************************************/
  /* Display owner audit options                                     */
  /*******************************************************************/
  Call sey "AUDITING"
  Call sey "--------"
  ra = Substr(d2x(rstat.ST_UAUDIT,8),1,2)
  Select
    When ra = 0 Then
      rat = "NONE(READ)"
    When ra = 1 Then
      rat = "SUCCESSES(READ)"
    When ra = 2 Then
      rat = "FAILURES(READ)"
    When ra = 3 Then
      rat = "ALL(READ)"
    Otherwise
  End
  wa = Substr(d2x(rstat.ST_UAUDIT,8),3,2)
  Select
    When wa = 0 Then
      wat = "NONE(UPDATE)"
    When wa = 1 Then
      wat = "SUCCESSES(UPDATE)"
    When wa = 2 Then
      wat = "FAILURES(UPDATE)"
    When wa = 3 Then
      wat = "ALL(UPDATE)"
    Otherwise
  End
  xa = Substr(d2x(rstat.ST_UAUDIT,8),5,2)
  Select
    When xa = 0 Then
      xat = "NONE(EXECUTE)"
    When xa = 1 Then
      xat = "SUCCESSES(EXECUTE)"
    When xa = 2 Then
      xat = "FAILURES(EXECUTE)"
    When xa = 3 Then
      xat = "ALL(EXECUTE)"
    Otherwise
  End
  Call sey rat","wat","xat
  Call sey " "

  /*******************************************************************/
  /* Display auditor audit options.                                  */
  /*                                                                 */
  /* Note that the 'ls -W' shell command does not suppress the       */
  /* AUDITOR audit options for non-RO/AUDITOR users, as the RACF     */
  /* RLIST command does for the corresponding GLOBALAUDIT field.     */
  /* Thus, we do not suppress them here, either. We *could* with     */
  /* a simple IRRXUTIL call (or storage reference to the ACEE) to    */
  /* determine the issuer's status.  Feel free to try it, or         */
  /* submit a requirement to the author via the racf-l mailing       */
  /* list.                                                           */
  /*******************************************************************/

  Call sey "GLOBALAUDIT"
  Call sey "-----------"
  ra = Substr(d2x(rstat.ST_AAUDIT,8),1,2)
  Select
    When ra = 0 Then
      rat = "NONE(READ)"
    When ra = 1 Then
      rat = "SUCCESSES(READ)"
    When ra = 2 Then
      rat = "FAILURES(READ)"
    When ra = 3 Then
      rat = "ALL(READ)"
    Otherwise
  End
  wa = Substr(d2x(rstat.ST_AAUDIT,8),3,2)
  Select
    When wa = 0 Then
      wat = "NONE(UPDATE)"
    When wa = 1 Then
      wat = "SUCCESSES(UPDATE)"
    When wa = 2 Then
      wat = "FAILURES(UPDATE)"
    When wa = 3 Then
      wat = "ALL(UPDATE)"
    Otherwise
  End
  xa = Substr(d2x(rstat.ST_AAUDIT,8),5,2)
  Select
    When xa = 0 Then
      xat = "NONE(EXECUTE)"
    When xa = 1 Then
      xat = "SUCCESSES(EXECUTE)"
    When xa = 2 Then
      xat = "FAILURES(EXECUTE)"
    When xa = 3 Then
      xat = "ALL(EXECUTE)"
    Otherwise
  End
  Call sey rat","wat","xat
  Call sey " "

  /*******************************************************************/
  /* Mimic the following RLIST output:                               */
  /*                                                                 */
  /* CREATION DATE  LAST REFERENCE DATE  LAST CHANGE DATE            */
  /*  (DAY) (YEAR)       (DAY) (YEAR)      (DAY) (YEAR)              */
  /* -------------  -------------------  ----------------            */
  /*   133    19          133    19         133    19                */
  /*                                                                 */
  /* using:                                                          */
  /* ST_CRTIME File creation time                                    */
  /* ST_ATIME  Time of last access                                   */
  /* ST_CTIME  Time of last file status change                       */
  /*                                                                 */
  /* Other time values available in stat():                          */
  /* ST_MTIME Time of last data modification                         */
  /* ST_RTIME File backup time stamp (reference time)                */
  /*******************************************************************/
  m = "CREATION DATE  LAST REFERENCE DATE  LAST STATUS CHANGE DATE"
  Call sey m
  m = "-------------  -------------------  -----------------------"
  Call sey m
  m = Left(gtime(rstat.ST_CRTIME),14),
                      Left(gtime(rstat.ST_ATIME),20),
                                         Left(gtime(rstat.ST_CTIME),15)
  Call sey m
  Call sey " "

  /*******************************************************************/
  /* Display extended attributes.  Only applicable to regular files. */
  /*                                                                 */
  /* See the BPXYSTAT macro for a layout of the Genvalue bits.       */
  /*******************************************************************/

  if rstat.ST_TYPE = S_ISREG Then Do
    Call sey "EXTENDED ATTRIBUTES"
    Call sey "-------------------"
    genval=substr(rstat.ST_GENVALUE,4)

    extattra= bitand(genval,'04'x)='04'x
    If extattra = 1 then
      Call sey "APF authorized"

    extattrp= bitand(genval,'02'x)='02'x
    If extattrp = 1 then
      Call sey "Program controlled"

    extattrs= bitand(genval,'08'x)='00'x /* reverse bit */
    If extattrs = 1 then
      Call sey "SHAREAS"

    extattrl= bitand(genval,'10'x)='10'x
    If extattrl = 1 then
      Call sey "Loaded from the shared library region"
    Call sey " "
  end

  /*******************************************************************/
  /* Display the non-permission file mode bits.                      */
  /*******************************************************************/
  Call sey "FILE MODE BITS"
  Call sey "--------------"
  Call sey "Sticky  bit is:" rstat.ST_STICKY
  Call sey "Set-uid bit is:" rstat.ST_SETUID
  Call sey "Set-gid bit is:" rstat.ST_SETGID
  Call sey " "
End                              /* Don't display if AUTH specified  */

  /*******************************************************************/
  /* Display the permission bits always (AUTH specified or not)      */
  /*******************************************************************/
  Call sey "FILE PERMISSIONS"
  Call sey "----------------"
  Call sey " "
  Call sey " OWNER GROUP OTHER"
  Call sey " ----- ----- -----"
  octalPerms = Substr(rstat.ST_MODE,1,1)Substr(rstat.ST_MODE,2,1)||,
               Substr(rstat.ST_MODE,3,1)
  up = getperms(Substr(rstat.ST_MODE,1,1))
  gp = getperms(Substr(rstat.ST_MODE,2,1))
  op = getperms(Substr(rstat.ST_MODE,3,1))
  m = " "up"   "gp"   "op"           ("octalPerms "in octal notation)"
  Call sey m
  Call sey " "

  /*******************************************************************/
  /* Display the extended access control list (acl) if one exists.   */
  /*******************************************************************/

  If rstat.ST_ACCESSACL = 1 Then Do
    call getacl(ACL_TYPE_ACCESS rpath)
  End
  Else
    Call sey "NO ACCESS LIST"
  Call sey " "

If authVal = 0 Then Do           /* Display if AUTH not specified    */
  /*******************************************************************/
  /* If the path name is a directory, look for model ACLs.           */
  /*******************************************************************/
  If rstat.ST_TYPE = S_ISDIR Then Do

    /*****************************************************************/
    /* Display the directory model acl if one exists.                */
    /*****************************************************************/

    If rstat.ST_DMODELACL = 1 Then Do
      Call sey "A directory model ACL exists:"
      Call sey " "
      call getacl(ACL_TYPE_DIRDEFAULT rpath)
    End
    Else
      Call sey "There is no directory model acl."
    Call sey " "

    /*****************************************************************/
    /* Display the file model acl if one exists.                     */
    /*****************************************************************/

    If rstat.ST_FMODELACL = 1 Then Do
      Call sey "A file model ACL exists:"
      Call sey " "
      call getacl(ACL_TYPE_FILEDEFAULT rpath)
    End
    Else
      Call sey "There is no file model acl."

  End  /* Path is a directory  */
End                              /* Don't display if AUTH specified  */

kwdExit:
Return poRc                      /* processOutput                    */

/* ----------------------------------------------------------------- */

getacl:
/*********************************************************************/
/* function: getacl                                                  */
/*                                                                   */
/* input:  - The type of acl requested (access, file model, or       */
/*           directory model)                                        */
/*         - The path of the file/directory to process (Note: it     */
/*           is important that this be the last argument, in case    */
/*           the path contains a blank.)                             */
/*                                                                   */
/* returns:  Nothing. But displays the acl contents (or a message    */
/*           indicating that an acl does not exist)                  */
/*                                                                   */
/* notes:                                                            */
/* - Use the aclget syscall. I found an example in the USS Rexx pub. */
/*                                                                   */
/*********************************************************************/
  parse arg acltype apath

  call syscalls('ON')    /* Need to re-establish predefined vars     */
    Call sey "ID          TYPE   ACCESS"
    Call sey "--          ----   ------"
    'aclinit acl'                   /* init variable ACL to hold acl */
    'aclget acl (apath)' acltype        /* get the acl               */
    Do i=1 by 1                         /* get each acl entry        */
      'aclgetentry acl acl.' i
      if rc < 0 | retval = -1 then
        leave                           /* error, assume no more     */
      parse value '- - -' with pr pw px
      if acl.acl_read=1 then
        pr='R'                          /* set rwx permissions       */
      if acl.acl_write=1 then
        pw='W'
      if acl.acl_execute=1 then
        px='X'
      perms = pr||pw||px

      aclid=acl.acl_id                  /* get uid or gid            */

      /* determine acl entry type */
      if acl.acl_entry_type=acl_entry_user then Do
        type='USER'
        "getpwuid (aclid) pw."
        If retval > 0 Then
          aclid = pw.PW_NAME
      End
      else
        if acl.acl_entry_type=acl_entry_group then Do
          type='GROUP'
          "getgrgid (aclid) gr."
          If retval > 0 Then
            aclid = gr.GR_NAME
        End
        else
          type ="???"

      Call sey Left(aclid,11) Left(type,6) Left(perms,5)
    End
  'aclfree acl'                         /* must free acl buffer      */
Return                                  /* getacl                    */

/* ----------------------------------------------------------------- */

getperms: procedure
/*********************************************************************/
/* function: getperms                                                */
/*                                                                   */
/* input:    an octal number represeting a set of permissions        */
/*                                                                   */
/* returns:  a string representing the permissions                   */
/*                                                                   */
/*           E.G. rwx, r-x, ---, etc                                 */
/*                                                                   */
/*********************************************************************/
  arg octal
  Select
    When octal=7 Then
      perms = 'rwx'
    When octal=6 Then
      perms = 'rw-'
    When octal=5 Then
      perms = 'r-x'
    When octal=4 Then
      perms = 'r--'
    When octal=3 Then
      perms = '-wx'
    When octal=2 Then
      perms = '-w-'
    When octal=1 Then
      perms = '--x'
    When octal=0 Then
      perms = '---'
    Otherwise
  End
return perms

/* ----------------------------------------------------------------- */

gtime:
/**********************************************************************/
/* Name:    gtime                                                     */
/* Purpose: get gm time from epoch time                               */
/**********************************************************************/
  arg tm
  numeric digits 10
  if tm=0 | datatype(tm,'W')<>1 then
     return ''
  if tm=-1 then return ''    /* @DHA */
  numeric digits
  "gmtime (tm) tm."
  if retval=-1 then return ''
  return right(tm.tm_year,4,0)'-' ||,
         right(tm.tm_mon,2,0)'-'right(tm.tm_mday,2,0)

/* ----------------------------------------------------------------- */

parseKeywords:
/*********************************************************************/
/* Examine input to identify keywords and values. We process the     */
/* keyword string as a set of words.                                 */
/*********************************************************************/
parseRc = 0
Do i = 1 to Words(keywords) Until Length(keywords)=0 /* Parse kwds   */

  nextWord = Word(keywords,1)    /* Get next word                    */

  /*******************************************************************/
  /* Isolate the next keyword and its value.                         */
  /*******************************************************************/
  openParen = Pos("(",nextWord)  /* Expect "(" to be part of word    */
  closeParen = Pos(")",keywords) /* But must look for ")" in the
                                     entire cmd remainder            */

  /*******************************************************************/
  /* If there is no open paren in the word, then this is a keyword   */
  /* without a value.                                                */
  /*******************************************************************/
  If openParen = 0 Then
    Do
      nextKwd = nextWord
      nextVal = ''
      endKwd = Length(nextWord)+1
    End
  /*******************************************************************/
  /* If there is an open paren in the word, then this is a keyword   */
  /* with a value.                                                   */
  /*******************************************************************/
  Else
    Do
      nextKwd = Substr(nextWord,1,openParen-1)
      valLength = closeParen - openParen - 1
      nextVal = Strip(Substr(keywords,openParen+1,valLength),Both," ")
      endKwd = Pos(")",keywords)+1
    End
  Upper nextKwd

  /*******************************************************************/
  /* Uncomment the following to help debug command parsing.          */
  /*******************************************************************/
  /*
  say "Command image remainder is" keywords
  say "Keyword is" nextKwd
  say "Value is" nextVal "of length" Length(nextVal)
  /* The following will be not quite accurate for "))" keywords.     */
  say "First position after current keyword/value is" endKwd
  say ''
  */

  /*******************************************************************/
  /* Set the value for each specified keyword.                       */
  /*******************************************************************/
  Select                        /* Identify keyword                  */
    /*****************************************************************/
    /* For the OUTFILE keyword, some additional processing is        */
    /* required to support a PDS member, due to the additional       */
    /* parentheses. We must look for an additional closing paren     */
    /* and redo the keyword-with-value code above to isolate the     */
    /* value.                                                        */
    /*                                                               */
    /* Note that, when OUTFILE is not specified, we make no effort   */
    /* to validate the value of the outputFile configuration value.  */
    /* We just let it rip and let the file I/O fail at the end.      */
    /* But this parsing forces our hand a bit. We assume the value   */
    /* is specified correctly, but do just enough checking to avoid  */
    /* a REXX error. If something is unexpected, we let the value    */
    /* stand as parsed above and send it downstream for failure.     */
    /*****************************************************************/
    When Abbrev(OUTFILEkwd,nextKwd,OUTabbr) = 1 Then
      Do
        outfileVal = nextVal                /* Save output var       */

        If Substr(outfileVal,1,2) = "//" &, /* If data set path      */
           Pos("(",nextval) > 0 Then Do     /* contains open paren   */

          /* Find next closing paren, which should be true close     */
          closeParen = closeParen +,
                       Pos(")",Substr(keywords,closeParen+1))

          /* Redo parse code to get correct parsing values           */
          If closeParen > 0 Then Do         /* If ")" found          */
            valLength = closeParen - openParen - 1
            nextVal = Strip(,
                       Substr(keywords,openParen+1,valLength),Both," ")
            endKwd = closeParen + 1
            outfileVal = nextVal            /* Reload output var     */
          End
        End
      End
    /*****************************************************************/
    /* If the RECURSIVE keyword is specified without a value, then   */
    /* we use the default of CURRENT.                                */
    /*****************************************************************/
    When Abbrev(RECURSIVEkwd,nextKwd,RECabbr) = 1 Then
      Do
        If stat.ST_TYPE /= S_ISDIR Then Do
          say 'RECURSIVE can only be specified for a directory.'
          parseRc = 4
        End
        Else Do
          If nextVal = '' Then Do
            recursiveVal = 'CURRENT'
          End
          Else Do
            Upper nextVal
            recursiveVal = nextVal
            If recursiveVal /= 'CURRENT' &,
               recursiveVal /= 'FILESYS' &,
               recursiveVal /= 'ALL' Then Do
              say 'Invalid value specified for RECURSIVE keyword.'
              say 'Use one of CURRENT, FILESYS, or ALL, or omit',
                  'parentheses and value for the default of CURRENT'
              parseRc = 4
            End
          End
        End
      End
    When nextKwd = DEBUGkwd Then
      Do
        debugVal = 1
      End
    When nextKwd = AUTHkwd Then
      Do
        authVal = 1
      End
    When Abbrev(NODISPLAYkwd,nextKwd,NODISabbr) = 1 Then
      Do
        noDisplayVal = 1
      End
    Otherwise
      If Length(nextKwd) /= 0 Then Do
        say "Invalid keyword:" nextKwd
        parseRc = 4
      End
  End                           /* Identify keyword                  */

  /*******************************************************************/
  /* Make sure the next keyword is blank-separated from current.     */
  /*******************************************************************/
  if Substr(keywords,endKwd,1) <> " " Then Do
    say "Missing blank after" nextKwd "keyword."
    Exit 4
  End

  /*******************************************************************/
  /* Remove this keyword from the input string, for the next         */
  /* iteration.                                                      */
  /*******************************************************************/
  keywords = Substr(keywords,endKwd)     /* Remove processed keyword */
  keywords = Strip(keywords,Leading," ")

End                             /* Parse keywords loop               */

Return parseRc                  /* parseKeywords                     */

/* ----------------------------------------------------------------- */

sey:
/*********************************************************************/
/* Name:    sey                                                      */
/*                                                                   */
/* Purpose: Display or save output line                              */
/*                                                                   */
/* Input:   - line to be processed                                   */
/*                                                                   */
/* Output:  - global veriable output. updated                        */
/*                                                                   */
/*********************************************************************/
  parse arg msg

  /*******************************************************************/
  /* Display output line unless display is being suppressed.         */
  /*******************************************************************/
  If NoDisplayVal = 0 Then
    say msg

  /*******************************************************************/
  /* Add output line to the output stem.                             */
  /*******************************************************************/
  tmp = output.0 + 1
  output.tmp = msg
  output.0 = tmp

Return    /* sey */

/* ----------------------------------------------------------------- */

readdirproc: procedure expose (syscall_constants) (@stem) dirlist. ,
                                                          debugVal
/*********************************************************************/
/* Return list of subobjects of a directory                          */
/*                                                                   */
/* Input:                                                            */
/*      - The path name of the user-specified directory              */
/*      - The name of a stem to contain the list of subordinate      */
/*        files.                                                     */
/*      - A value indicating the scope of the operation:             */
/*        - CURRENT - apply changes to objects within the specified  */
/*          directory                                                */
/*        - FILESYS - apply changes to objects within the containing */
/*          zFS data set (i.e. mount points are not crossed)         */
/*        - ALL - apply changes all the way down the mounted file    */
/*          system structure, in and below the specified directory.  */
/*                                                                   */
/* Output:                                                           */
/*      - The input stem is filled with the list of files            */
/*      - the hard-coded 'dirlist.' stem contains a list of          */
/*        subdirectories.                                            */
/*                                                                   */
/*********************************************************************/
  parse arg path,stem,scope

  /*******************************************************************/
  /* Obtain the devno ('device number') of the file system in which  */
  /* the input directory path exists. Comparing this to the devno    */
  /* of sub-objects helps to determine when we have crossed a mount  */
  /* point into a different zFS data set.                            */
  /*******************************************************************/
  at.=''
  address syscall 'lstat (path) at.'
  devno=at.st_dev

  /*******************************************************************/
  /* Initialize the directory stem and count, and the file count.    */
  /*******************************************************************/
  call value @stem,''
  dirlist.=''
  dirlist.1=path
  dirlist=1
  dirs=1
  files=0

  /*******************************************************************/
  /* Loop on all directories. Initially, this only contains the      */
  /* input directory, but in each iteration, the contents of the     */
  /* directory will be read, and subdirectories will be placed       */
  /* into the dirlist stem. Thus, subsequent iterations will         */
  /* operate on these subdirectories as the list is built up.        */
  /*******************************************************************/
  Do dirx=1 By 1 While length(dirlist.dirx)>0
    address syscall 'readdir (dirlist.dirx) names. attrs.'
    If retval=-1 Then Leave
    /*****************************************************************/
    /* Loop on the contents of the directory being processed         */
    /* in this iteration of the outer loop.                          */
    /*****************************************************************/
    Do d=1 to names.0
      /***************************************************************/
      /* Skip the special directories of "." and ".."                */
      /***************************************************************/
      If substr(names.d,1,1)='.' & attrs.d.st_type=s_isdir Then
        iterate
      /***************************************************************/
      /* Add files to the input stem as absolute path names.         */
      /***************************************************************/
      If attrs.d.st_type=s_isreg Then
        Do
          files=files+1
          call value stem||files,dirlist.dirx'/'names.d

          Do i=1 to attrs.d.0
            call value stem||files'.!attrs.'i,attrs.d.i
          End
        End
      /***************************************************************/
      /* Add directories to the dirlist stem as absolute path        */
      /* names, excluding mount point directories if FILESYS         */
      /* is specified.                                               */
      /***************************************************************/
      Else If attrs.d.st_type=s_isdir Then
        Do
          If (scope = 'CURRENT') |,
             (scope = 'ALL')     |,
             (scope = 'FILESYS' & attrs.d.st_dev=devno) Then Do
            dirs = dirs + 1
            dirlist = dirlist+1
            dirlist.dirlist=dirlist.dirx'/'names.d
          End
          Else If attrs.d.st_dev/=devno & debugVal = 1 Then Do
            say 'Excluding' dirlist.dirx'/'names.d,
                'of type' attrs.d.st_type 'due to different devno'
          End
        End
      Else
        Do
          If debugVal = 1 Then Do
            say 'Excluding' dirlist.dirx'/'names.d,
                'of type' attrs.d.st_type
          End
        End
    End
    /*****************************************************************/
    /* If CURRENT is specified, we leave the outer loop after        */
    /* having processed only the first directory (i.e. the one       */
    /* specified by the user).                                       */
    /*****************************************************************/
    If scope = 'CURRENT' Then
      Leave
  End
  /*******************************************************************/
  /* Set the file count into the input file stem.                    */
  /*******************************************************************/
  call value stem'0',files
  /*******************************************************************/
  /* Set the directory count into the hard-coded directory stem.     */
  /*******************************************************************/
  dirlist.0=dirs
return /* readdirproc */

/* ----------------------------------------------------------------- */

buildOutputHeader:
/*********************************************************************/
/* procedure: buildOutputHeader                                      */
/*                                                                   */
/* output: The following global variables are modified               */
/*         - output. stem is primed with the heading defined         */
/*           at the bottom of this file, and filled in with the      */
/*           header information.                                     */
/*                                                                   */
/*********************************************************************/
lineEnd = 68
/*********************************************************************/
/* Find start of template at the bottom of this file.                */
/*********************************************************************/
Do sl = sourceline() to 1 by -1 Until sourceline(sl) = 'Template:'
End
/*********************************************************************/
/* Prime the script stem with the template lines.                    */
/*********************************************************************/
Do sl = sl+1 to sourceline()              /* For each template line  */
  tmp = output.0 + 1

  /* Replace date/time placeholder with script and date/time         */
  If Pos("DATE/TIME",sourceline(sl)) > 0 Then Do /* Fill in datetime */
    line = '/* Created on' Date() Time() 'by the' execName 'exec.'
    line = Left(line,lineEnd," ") '*/'
    output.tmp = line
  End                                            /* Fill in datetime */
  /* If start of recursive-only lines, finish up for non-recursive   */
  Else If Pos("TemplateRecursive:",sourceline(sl)) > 0 Then Do
    If recursiveVal = '' Then Do          /* Not RECURSIVE           */
      output.tmp = Substr( ,              /* Close the comment with  */
        sourceline(sourceline()),1,71)    /*  last line in file      */
      output.0 = tmp                      /* Increment num of lines  */
      Leave                               /* Bail out of loop        */
    End
    Else
      Iterate                             /* Skip this line, Cont.   */
  End                                     /* Recursive template lbl  */
  /* Include a normal template line.                                 */
  Else Do
    output.tmp = Substr(sourceline(sl),1,71) /* Write normal line    */
  End

  output.0 = tmp                          /* Increment num of lines  */
End                                       /* For each template line  */

Return  /* buildOutputHeader */

/* ----------------------------------------------------------------- */

writeOutputFile:
/*********************************************************************/
/* function: writeOutputFile                                         */
/*                                                                   */
/* input: The following global variables:                            */
/*        - outputFile: Name of file, path, or data set into which   */
/*                      to write the output                          */
/*        - output.   : The stem variable containing the lines to    */
/*                      write to the output file                     */
/*                                                                   */
/* output: The output is written                                     */
/*                                                                   */
/* returns: 1 - output successfully created                          */
/*          0 - output not successfully created                      */
/*                                                                   */
/* Notes:  A data set starts with "//" by convention                 */
/*                                                                   */
/*********************************************************************/
fileCreated = 1
/*********************************************************************/
/* Write the output stem to the output UNIX file.                    */
/*********************************************************************/
If Substr(outputFile,1,2) /= "//" Then Do  /* Unix file/path         */
  'writefile (outputFile) 700 output.'
  If retval = -1 Then Do
    fileCreated = 0
    say 'writefile error:' retval errno errnojr 'attempting to create',
        outputFile 'output file.'
  End
End
/*********************************************************************/
/* Write the output stem to the output data set.                     */
/*********************************************************************/
Else Do
  dsName = Substr(outputFile,3) /* Name starts after "//" */

  address TSO      /* Establish TSO environment */
  "ALLOC DA("dsName") F(myoutdd) SHR REUSE"
  If rc /= 0 Then Do
    say 'Error' rc 'allocating output data set' dsName'.'
    fileCreated = 0
  End
  Else Do
    "EXECIO 0 DISKW myoutdd (OPEN"
    If rc /= 0 Then Do
      say 'Error' rc 'opening output data set' dsName'.'
      fileCreated = 0
    End
    Else Do
      "EXECIO * DISKW myoutdd (STEM output."
      If rc /= 0 Then Do
        say 'Error' rc 'writing to output data set' dsName'.'
        fileCreated = 0
      End
      Else Do
        "EXECIO 0 DISKW myoutdd (FINIS"
        If rc /= 0 Then Do
          say 'Error' rc 'closing output data set' dsName'.'
          fileCreated = 0
        End
      End
    End

    "FREE F(myoutdd)"
  End

  address syscall  /* Restore syscall environment */
End

Return fileCreated /* writeOutputFile */

/* ----------------------------------------------------------------- */

/*********************************************************************/
/* ATTENTION!!!!!                                                    */
/* The following label and lines are used in the construction of     */
/* the output file and *MUST* remain at the very bottom              */
/* of this exec!!!!                                                  */
/*********************************************************************/
Template:
/*********************************************************************/
/*                                                                   */
/* DATE/TIME                                                         */
/*                                                                   */
TemplateRecursive:  /* More information when RECURSIVE specified */
/* This file contains the security information of the UNIX           */
/* objects requested. The list of objects is displayed immediately   */
/* below, followed by the information for each individual object,    */
/* in the order indicated by the list.                               */
/*                                                                   */
/* To advance quickly through individual objects, search for the     */
/* "!--" string.                                                     */
/*                                                                   */
/*********************************************************************/
