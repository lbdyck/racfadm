/*%NOCOMMENT====================* REXX *==============================*/
/*     TYPE:  TSO Command                                             */
/*  PURPOSE:  RACF Unix Security Attribute Management (ALTER)         */
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

 Name:    ORALTER

 Version: 2

 Author: Bruce Wells - brwells@us.ibm.com

 Purpose: Provides UNIX security attribute management using
          a syntax similar to the RACF RALTER command

 Input:   An absolute path name

 NOTE!!! This exec is dependent upon the following "Syntax:" line and
         the "End-Syntax" line below in order to display the syntax
         when the exec is invoked without keyword parameters.

         Feel free to add/change examples to show things that are
         frequently done in your orgnization. But please preserve
         these surrounding lines.

 Beg-Syntax:
 Purpose:  Provides UNIX security attribute management using
           a syntax similar to the RACF RALTER command

 Syntax:   ORALTER absolute_path_name operands

 Operands: All keywords are optional
             FSSEC                (positional)
             absolute-path-name   (positional)
             APF | NOAPF
             AUDIT(access-attempt(audit-access-level))
             DEBUG
             GLOBALaudit(access-attempt(audit-access-level))
             GROUP(group-name)
             OUTFILE(path-or-dataset-name)
             OWNER(user-ID)
             PERMS(uuugggooo)
             PROGRAM | NOPROGRAM
             RECursive(ALL | CURRENT | FILESYS)
                             -------
             SECLABEL(seclabel-name)
             SETGID | NOSETGID
             SETUID | NOSETUID
             STICKY | NOSTICKY
             VERBOSE

 Examples:
   1) Change the owning file and group:
        ORALTER /u/brwells/myfile OWNER(APPUSR1) GROUP(APPGRP)

   2) Change the permission bits:
        ORALTER /u/brwells/myfile PERMS(rwxr-xr-x)

   3) Change the permission bits as above, in octal notation:
        ORALTER /u/brwells/myfile PERMS(755)

   4) Turn on the apf and program control extended attributes:
        ORALTER /u/brwells/myprogram APF PROGRAM

   5) Set the owner audit options to log all access:
        ORALTER /u/brwells/myfile AUDIT(ALL(rwx))

   6) Set the auditor audit options to log successful access:
        ORALTER /u/brwells/myfile GLOBALAUDIT(SUCCESS(rwx))

   7) To turn off all 'other' write bits in a directory:
        ORALTER /u/brwells PERMS(o-w) RECURSIVE

   8) To specify a path for the output script:
        ORALTER /u/brwells PERMS(o-w) OUTFILE(/u/jdayka/john.sh)

   9) To specify a PDS member for the output script:
        ORALTER /u/brwells PERMS(o-w) OUTFILE(//'JDAYKA.UNIX(CMDOUT1)')

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
/* noRun means that the security information is not changed.         */
/* This mode of operation is useful in verbose mode, so              */
/* you can see the equivalent shell commands. Also, it allows        */
/* you to first evaluate the contents of the generated script file   */
/* and only execute it as a shell script once you are satisfied      */
/* with the results of the command.                                  */
/*********************************************************************/
noRun = 1
/*********************************************************************/
/* verbose results in extra messages being issued during processing. */
/* - Change to 0 to eliminate these messages by default. You can     */
/*   still specify the VERBOSE keyword on individual commands to     */
/*   get the messages.                                               */
/* - Change to 11 to get these messages for sub-objects when you     */
/*   specify RECURSIVE. Warning: It could get noisy! There is no     */
/*   command keyword for this option.                                */
/*********************************************************************/
verboseVal = 1
/*********************************************************************/
/* outputFile is the name of the file in which the generated         */
/* output will be written.  By default, it is set to                 */
/* <exec-name>.script, where exec-name is the name you have saved    */
/* this exec as (ORALTER by default).                                */
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
/*                                                                   */
/* Warning!: When the output is written to a data set, it cannot     */
/*           be executed as a shell script. OPERMIT will issue a     */
/*           message if you are not in noRun mode.                   */
/*                                                                   */
/*********************************************************************/
outputFile = execname".script"

/*********************************************************************/
/* --------------   End of Configuration Variables ----------------- */
/*********************************************************************/

/*********************************************************************/
/* Define/initialize command keyword names and values.               */
/*********************************************************************/
VERBOSEkwd     = "VERBOSE"
OWNERkwd       = "OWNER"         ; ownerVal       = ''
GROUPkwd       = "GROUP"         ; groupVal       = ''
PERMSkwd       = "PERMS"         ; permsVal       = ''
STICKYkwd      = "STICKY"        ; stickyVal      = 0
NOSTICKYkwd    = "NOSTICKY"      ; noStickyVal    = 0
SETUIDkwd      = "SETUID"        ; setuidVal      = 0
NOSETUIDkwd    = "NOSETUID"      ; noSetuidVal    = 0
SETGIDkwd      = "SETGID"        ; setgidVal      = 0
NOSETGIDkwd    = "NOSETGID"      ; noSetgidVal    = 0
AUDITkwd       = "AUDIT"         ; auditVal       = ''
GLOBALAUDITkwd = "GLOBALAUDIT"   ; globalAuditVal = ''
GLOBALabbr     = 6          /* GLOBAL is shortest abbreviation       */
SECLABELkwd    = "SECLABEL"      ; seclabelVal    = ''
APFkwd         = "APF"           ; apfVal         = 0
NOAPFkwd       = "NOAPF"         ; noApfVal       = 0
PROGRAMkwd     = "PROGRAM"       ; programVal     = 0
NOPROGRAMkwd   = "NOPROGRAM"     ; noProgramVal   = 0
RECURSIVEkwd   = "RECURSIVE"     ; recursiveVal   = ''
RECabbr      = 3            /* REC is shortest allowed abbreviation  */
DEBUGkwd       = "DEBUG"         ; debugVal       = 0
OUTFILEkwd     = "OUTFILE"       ; outfileVal     = ''
OUTabbr      = 3            /* OUT is shortest allowed abbreviation  */

/*********************************************************************/
/* -----------------   Start of Mainline     ----------------------- */
/*********************************************************************/

call syscalls('ON')  /* Initialize UNIX environment */
address syscall

output. = ''         /* Initialize stem for shell commands */

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
/* this in case the user wants ORALTER to look just like the RALTER  */
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

/* Check for success.                                                */
If retval = -1 then Do
  Select /* errno */
    When errno = ENOENT Then
      say "The specified path does not exist."
    When errno = EACCES Then Do
      Say "You are not authorized to reach" path"."

      /***************************************************************/
      /* Now, for extra credit, we will check for search access to   */
      /* the directory components of the path name, since that is a  */
      /* common cause of error, and display the first such directory */
      /* to which the user is not authorized. (There is no sense in  */
      /* continuing beyond that point because they will all yield a  */
      /* failure even if search access is present.)                  */
      /***************************************************************/
      checkpath = ''    /* The path to check */
      workpath = path   /* A working copy of the input path */
      Do Forever
        idx = Pos('/',workpath)
        If idx = 0 Then  /* no more slashes means we are finished    */
          leave
        checkpath = checkpath || Substr(workpath,1,idx)
        workpath = Substr(workpath,idx+1) /* Lop off head */

        "access (checkpath)" X_OK

        if retval = -1 then do
          say "You do not have search access to" checkpath
          Leave
        End
      End
    End  /* EACCES */
    Otherwise Do
      say "Error locating target object.",
          " Stat() retval =" retval "errno =" ,
           errno "errnojr =" errnojr
    End
  End   /* Select errno*/
  Signal GETOUT
End /* retval = -1 */

/*********************************************************************/
/* Remove path from keyword string for subsequent processing.        */
/* Make a copy, since the act of parsing will destroy the string.    */
/*********************************************************************/
keywords = Subword(keywords,2)  /* Remove path from keyword string   */
saveKwds = keywords

/*********************************************************************/
/* Parse the keywords and values from the keyword string.            */
/*********************************************************************/
execRc = 0
execRc = parseKeywords()
If execRc /= 0 Then
  Signal GETOUT

/*********************************************************************/
/* Check keywords for consistency.                                   */
/*********************************************************************/
execRc = checkKeywords()
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
cmdStart = output.0 + 1  /* Save line number of first command        */

/*********************************************************************/
/* Process the keywords.                                             */
/*********************************************************************/
execRc = ProcessKeywords(path)
If execRc /= 0 Then
  Signal GETOUT

/*********************************************************************/
/* Process RECURSIVE keyword.                                        */
/*                                                                   */
/* This is only valid when the target object is a directory.         */
/*                                                                   */
/* We obtain a list of sub-objects. This will contain the target     */
/* itself, which we have already processed, so we skip the first     */
/* directory.                                                        */
/*                                                                   */
/*********************************************************************/
@stem = filelist.
If recursiveVal /= '' Then Do
  call readdirproc path,@stem,recursiveVal
  /* If DEBUG specified, display returned directory/file lists */
  If debugVal = 1 Then Do
    say 'Files:' filelist.0
    Do i = 1 to filelist.0
      say filelist.i
    End
    say ''
    say 'Directories:' dirlist.0
    Do i = 1 to dirlist.0
      say dirlist.i
    End
  End
  /*******************************************************************/
  /* Process directories.                                            */
  /*******************************************************************/
  Do objs = 2 to dirlist.0
    execRc = processKeywords(dirlist.objs)
    If execRc /= 0 Then
      Signal GETOUT
  End
  /*******************************************************************/
  /* Process files.                                                  */
  /*******************************************************************/
  Do objs = 1 to filelist.0
    execRc = processKeywords(filelist.objs)
    If execRc /= 0 Then
      Signal GETOUT
  End
End

GETOUT:

/*********************************************************************/
/* Display list of shell commands that this command might            */
/* have corresponded to, if we have any commands.                    */
/*********************************************************************/
If verboseVal > 0 Then
  If output.0 >= cmdStart Then Do
    say ' '
    say "This command would result in the following",
        "UNIX shell command(s):"
    Do cmds = cmdStart to output.0 /* Skip rexx header */
      say Substr(output.cmds,2,Length(output.cmds)-2)
    End
  End
  Else
    if (display <> 'yes') then                                /* @A1 */
    say 'The specified command resulted in no shell commands being',
        'generated.'

/*********************************************************************/
/* Write the script stem to the output script file, if we have any   */
/* commands.                                                         */
/*********************************************************************/
If output.0 >= cmdStart Then
  scriptOK = writeOutputFile()

Exit

/*********************************************************************/
/* -----------------     End of Mainline     ----------------------- */
/*********************************************************************/


processKeywords:
/*********************************************************************/
/* procedure: processKeywords                                        */
/*                                                                   */
/* input:  - The path name to modify                                 */
/*                                                                   */
/* output: - Returns a return code                                   */
/*                                                                   */
/* Notes:  - This is essentially just a continuation of mainline     */
/*           processing, put into a subroutine so that it can be     */
/*           called iteratively for sub-objects by the RECURSIVE     */
/*           keyword.                                                */
/*                                                                   */
/*           In that spirit, it might be annoying to see certain     */
/*           messages repeated (e.g. the UID/GID mapping message)    */
/*           or certain actions attempted (e.g. updating extended    */
/*           attributes for a directory) when the RECURSIVE option   */
/*           is used. The logic below is thus sensitive to the       */
/*           fact that it might be getting called for RECURSIVE.     */
/*                                                                   */
/*********************************************************************/
parse arg rpath

pkRc = 0  /* Return value */

/*********************************************************************/
/* Obtain information on passed path name.                           */
/*                                                                   */
/* Note we never expect the possibility of 'not-found', because      */
/* the mainline checked the path specified, and the RECURSIVE        */
/* keyword resulted in us already locating a list of sub-objects.    */
/* (Though there is, of course, a time-of-check to time-of-use       */
/* window.)                                                          */
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
/* Make a value of the path name that can be used in shell           */
/* commands.  For example, if the path contains a blank, the         */
/* entire path must be enclosed in quotes.                           */
/*********************************************************************/
cpath = munge(rpath)          /* cpath is for use in commands        */

/*********************************************************************/
/* Process file ownership keywords (OWNER and GROUP)                 */
/*********************************************************************/
pkRc = processOwnershipKwds()
If pkRc > 0 Then Signal kwdExit

/*********************************************************************/
/* Process file mode related keywords (PERMS, NO|STICKY, NO|SETUID,  */
/* and NO|SETGID)                                                    */
/*********************************************************************/
pkRc = processFilemodeKwds()

/*********************************************************************/
/* Process extended attribute keywords (NO|APF and NO|PROGRAM)       */
/*********************************************************************/
pkRc = processExtattrKwds()

/*********************************************************************/
/* Process AUDIT keyword                                             */
/*********************************************************************/
pkRc = processAuditKwd()

/*********************************************************************/
/* Process GLOBALAUDIT keyword                                       */
/*********************************************************************/
pkRc = processGlobalauditKwd()

/*********************************************************************/
/* Process SECLABEL keyword                                          */
/*********************************************************************/
pkRc = processSeclabelKwd()

kwdExit:
Return pkRc                     /* processKeywords                   */

/* ----------------------------------------------------------------- */

processOwnershipKwds:
owRc = 0 /* Return value */

/*********************************************************************/
/* Process OWNER keyword.                                            */
/*********************************************************************/
ownerUid = rstat.ST_UID

If ownerVal /= '' Then Do   /* OWNER specified */
  /***************************************************************/
  /* Map the specified value to a numeric UID.                   */
  /***************************************************************/
  'getpwnam' ownerVal 'pw.'
  If retval > 0 Then Do   /* Success */
    ownerUid = pw.PW_UID
  End
  Else Do
    say 'Unable to map' ownerVal 'into a UID.'
    say 'Processing terminated with no changes made.'
    owRc = 8
    Signal ownExit
  End

  /***********************************************/
  /* ++ Add shell command to script stem.        */
  /***********************************************/
  tmp = output.0 + 1
  output.tmp = "'chown" ownerVal cpath"'"
  output.0 = tmp
End

/*********************************************************************/
/* Process GROUP keyword.                                            */
/*********************************************************************/
ownerGid = rstat.ST_GID      /* GROUP specified */
If groupVal /= '' Then Do
  /***************************************************************/
  /* Map the specified value to a numeric GID.                   */
  /***************************************************************/
  'getgrnam' groupVal 'gr.'
  If retval > 0 Then Do     /* Success */
    ownerGid = gr.GR_GID
  End
  Else Do
    say 'Unable to map' groupVal 'into a GID.'
    say 'Processing terminated with no changes made.'
    owRc = 8
    Signal ownExit
  End

  /***********************************************/
  /* ++ Add shell command to script stem.        */
  /***********************************************/
  tmp = output.0 + 1
  output.tmp = "'chgrp" groupVal cpath"'"
  output.0 = tmp
End

/*********************************************************************/
/* Issue chown to set the UID and GID determined above.              */
/*********************************************************************/
If noRun = 1 Then Signal ownExit
If ownerVal /= '' | groupVal /= '' Then Do /* OWNER/GROUP specified  */
  "chown (rpath) (ownerUid) (ownerGid)"
  If retval /= 0 Then Do
    If errno = EPERM Then
      say "You are not authorized to change ownership of" rpath
    Else
      say "chown error:" retval errno errnojr "on" rpath
  End
  Else Do
    /*****************************************************************/
    /* Issue a hopefully helpful message indicating the result of    */
    /* the user->UID and/or group->GID mapping operation. But only   */
    /* for the specified path (i.e. not for each recursive path),    */
    /* and only if verbose mode is requested.                        */
    /*****************************************************************/
    If rpath = path & verboseVal > 0 |,
                      verboseVal = 11 Then Do
      If ownerVal /= '' Then
        say "Owner successfully changed to UID" ownerUid "for" rpath
      If groupVal /= '' Then
        say "Group successfully changed to GID" ownerGid "for" rpath
    End
  End
End
ownExit:

Return owRc /* processOwnershipKwds */

/* ----------------------------------------------------------------- */

processFilemodeKwds:
/*********************************************************************/
/* Process PERMS, NO|SETUID, NO|SETGID, and NO|STICKY keywords.      */
/*                                                                   */
/* All of these attributes exist in a 4-byte structure called the    */
/* file mode. We obtain the existing file mode, merge the specified  */
/* changes into it, and store the entire mode back using chmod().    */
/*                                                                   */
/*********************************************************************/

/*********************************************************************/
/* Process PERMS keyword                                             */
/*                                                                   */
/* The user may have specified the permissions in octal format,      */
/* full symbolic format (all nine positions specified), or operator  */
/* format, where individual permissions types are set, added, or     */
/* removed.                                                          */
/*********************************************************************/
fmRc = 0 /* Return value */

If permsVal /= '' Then Do   /* PERMS is specified                    */
  /*******************************************************************/
  /* When the permission format is octal, things are simple, since   */
  /* chmod() requires octal permissions. We simply copy the user's   */
  /* input into the variable we will pass to chmod().                */
  /*******************************************************************/
  If permsFormat = 'octal' Then Do /* User specified octal format    */
    chmodPerms = permsVal     /* Already in desired format for chmod */
  End
  /*******************************************************************/
  /* When the permission format is in full symbolic mode, we         */
  /* convert each rwx grouping into octal, concatenate the results,  */
  /* and send that into chmod().                                     */
  /*******************************************************************/
  Else if permsFormat = 'full' Then Do /* User specified full format */
    uperms = octalOf(Substr(permsVal,1,3))   /* Xlate 1st three bits */
    gperms = octalOf(Substr(permsVal,4,3))   /* Xlate 2nd three bits */
    operms = octalOf(Substr(permsVal,7,3))   /* Xlate 3rd three bits */
    chmodPerms = uperms||gperms||operms  /* Concatenate octal values */
  End
  /*******************************************************************/
  /* When the permission format is oper, we must first obtain the    */
  /* octal representation of the normalized symbolic 'rwx' perm-     */
  /* ission value. This must be applied to each of the subject       */
  /* permission types (u/g/o).  If a type isn't specified, we use    */
  /* the existing bits from stat().  These three sets are concat-    */
  /* enated together to form a working permission string.            */
  /* When the operator is:                                           */
  /*  - equal('='), we simply use the work string as the new mode.   */
  /*  - plus ('+'), we OR the work string with the existing mode     */
  /*    from the stat structure.                                     */
  /*  - minus('-'), we AND the 'complement' of the value with        */
  /*    the stat structure to turn the bits off.                     */
  /*******************************************************************/
  Else If permsFormat = 'oper' Then Do   /* Let the fun begin        */
    Parse Value permsVal With oSub oOp oBits /* Parse value string   */

    /* Get the normal octal, or octal 'complement' format of perms   */
    If oOp = '-' Then
      oBits = octalOf(oBits,"-")   /* Xlate perm bits negatively */
    Else
      oBits = octalOf(oBits)       /* Xlate perm bits normally   */

    /* For each subject value, copy or replace the relevant byte     */
    /* from the file mode in the stat() structure.                   */
    If Pos("U",oSub) > 0 Then
      uWorkPerms = oBits
    Else
      uworkPerms = Substr(rstat.ST_MODE,1,1)
    If Pos("G",oSub) > 0 Then
      gWorkPerms = oBits
    Else
      gworkPerms = Substr(rstat.ST_MODE,2,1)
    If Pos("O",oSub) > 0 Then
      oWorkPerms = oBits
    Else
      oworkPerms = Substr(rstat.ST_MODE,3,1)
    /* Concatenate each type to get the working octal permissions.   */
    workPerms = uworkPerms||gworkPerms||oworkPerms
    /* Depending on the operation, we will now either replace the    */
    /* existing perms with the work string ("="), OR in the work     */
    /* string ("+"), or AND off the bits in the 'negative' work      */
    /* string. What results is the octal string to set using chmod().*/
    Select
      When oOp = "=" Then Do
        chmodPerms = workPerms
      End
      When oOp = "+" Then Do
        chmodPerms = BITOR(rstat.ST_MODE,workPerms)
      End
      When oOp = "-" Then Do
        chmodPerms = BITAND(rstat.ST_MODE,workPerms)
      End
      Otherwise
    End /* Select */
  End

  /***********************************************/
  /* ++ Add shell command to script stem.        */
  /***********************************************/
  tmp = output.0 + 1
  output.tmp = "'chmod" chmodPerms cpath"'"
  output.0 = tmp
End
Else Do /* PERMS not specified. Use existing value. */
  chmodPerms = rstat.ST_MODE
End

/*********************************************************************/
/* Process NO|SETUID, NO|SETGID, and NO|STICKY keywords              */
/*                                                                   */
/* This consists of setting a variable to 1 or 0 depending on the    */
/* keyword specified, or to the path's current value if neither      */
/* keyword is specified.                                             */
/*                                                                   */
/*********************************************************************/
If setuidVal = 1 Then Do
  chmodSetuid = 1
  /***********************************************/
  /* ++ Add shell command to script stem.        */
  /***********************************************/
  tmp = output.0 + 1
  output.tmp = "'chmod u+s" cpath"'"
  output.0 = tmp
End
If nosetuidVal = 1 Then Do
  chmodSetuid = 0
  /***********************************************/
  /* ++ Add shell command to script stem.        */
  /***********************************************/
  tmp = output.0 + 1
  output.tmp = "'chmod u-s" cpath"'"
  output.0 = tmp
End
If setuidVal = 0 & nosetuidVal = 0 Then Do
  chmodSetuid = rstat.ST_SETUID
End

If setgidVal = 1 Then Do
  chmodSetgid = 1
  /***********************************************/
  /* ++ Add shell command to script stem.        */
  /***********************************************/
  tmp = output.0 + 1
  output.tmp = "'chmod g+s" cpath"'"
  output.0 = tmp
End
If nosetgidVal = 1 Then Do
  chmodSetgid = 0
  /***********************************************/
  /* ++ Add shell command to script stem.        */
  /***********************************************/
  tmp = output.0 + 1
  output.tmp = "'chmod g-s" cpath"'"
  output.0 = tmp
End
If setgidVal = 0 & nosetgidVal = 0 Then
  chmodSetgid = rstat.ST_SETGID

If stickyVal = 1 Then Do
  chmodSticky = 1
  /***********************************************/
  /* ++ Add shell command to script stem.        */
  /***********************************************/
  tmp = output.0 + 1
  output.tmp = "'chmod +t" cpath"'"
  output.0 = tmp
End
If nostickyVal = 1 Then Do
  chmodSticky = 0
  /***********************************************/
  /* ++ Add shell command to script stem.        */
  /***********************************************/
  tmp = output.0 + 1
  output.tmp = "'chmod -t" cpath"'"
  output.0 = tmp
End
If stickyVal = 0 & nostickyVal = 0 Then
  chmodSticky = rstat.ST_STICKY

/*********************************************************************/
/* If PERMS, NO|SETUID, NO|SETGID, or NO|STICKY keyword was          */
/* specified, then set the values determined above using the         */
/* chmod syscall.                                                    */
/*********************************************************************/
If noRun = 1 Then Signal NOCHMOD
If permsVal /= '' |,
   setuidVal+nosetuidVal+,
   setgidVal+nosetgidVal+,
   stickyVal+nostickyVal > 0 Then Do
  "chmod (rpath) (chmodPerms) (chmodSetuid) (chmodSetgid) (chmodSticky)"

  If retval /= 0 Then Do
    If errno = EPERM Then
      say "You are not authorized to change permissions of" rpath
    Else
      say "chmod error:" retval errno errnojr "on" rpath
  End
  Else
    If rpath = path & verboseVal > 0 |,
                      verboseVal = 11 Then Do
      If permsVal /= '' Then
        say "Permission bits successfully changed to" chmodPerms,
            "for" rpath
      If stickyVal /= 0 | noStickyVal /= 0 Then
        say "Sticky bit successfully changed for" rpath
      If setuidVal /= 0 | noSetuidVal /= 0 Then
        say "Set-user-ID bit successfully changed for" rpath
      If setgidVal /= 0 | noSetgidVal /= 0 Then
        say "Set-group-ID bit successfully changed for" rpath
    End
End /* Any mode keywords specified */
NOCHMOD:

Return fmRc /* processFilemodeKwds */

/* ----------------------------------------------------------------- */

processExtattrKwds:
/*********************************************************************/
/* Process NO|APF and NO|PROGRAM keywords                            */
/*                                                                   */
/* This consists of setting a variable to 1 or 0 depending on the    */
/* keyword specified, or to the path's current value if neither      */
/* keyword is specified.                                             */
/*                                                                   */
/* Authority to change the apf bit is separate from the authority    */
/* to change the program bit, and UNIX is kind enough not to flag    */
/* an error when the chattr syscall 'changes' a bit to its own       */
/* value.  However, if multiple bits are specified, and the user     */
/* is not authorized to one of them, we cannot determine which       */
/* one is not allowed.  This makes the issuance of a precise         */
/* error message impossible, but we do as best we can.               */
/*                                                                   */
/* To make the matter worse, failure might not be for lack of        */
/* BPX.FILEATTR.xxx authority, but for lack of write access to       */
/* the file. In the former case, we may as well stop trying any      */
/* more NOxxx updates when RECURSIVE is specified, but in the        */
/* latter case, subsequent updates could possibly work. The          */
/* errno makes no distinction between the two cases, however.        */
/*                                                                   */
/*********************************************************************/
eaRc = 0 /* Return value */

If apfVal+noApfVal+programVal+noProgramVal > 0 Then Do /* any bits?  */
  /*******************************************************************/
  /* Set up variable for the possibility of an error.                */
  /*******************************************************************/
  extAttr = ''
  Select
    When apfVal+noApfVal>0 & programVal+noProgramVal>0 Then
      extAttr = 'some'
    When apfVal+noApfVal>0 & programVal+noProgramVal=0 Then
      extAttr = 'the APF'
    When apfVal+noApfVal=0 & programVal+noProgramVal>0 Then
      extAttr = 'the PROGRAM'
    Otherwise
  End /* Select */

  /* Initialize variables */
  z1='00'x
  z3='000000'x
  gen_pc='02'x
  gen_apf='04'x
  val = z1 ; mask = z1

  /*******************************************************************/
  /* Only attempt extended attribute update for regular files.       */
  /* Only issue message if operation is explicitly attempted against */
  /* a directory (i.e. RECURSIVE not specified).                     */
  /*******************************************************************/
  If rstat.st_type <> S_ISREG Then Do
     If recursiveVal = '' Then Do
       say "Extended attributes only apply to regular files."
     End
  End
  Else Do                         /* It's a file                     */
    If apfVal = 1 Then Do         /* APF specified                   */
      mask = bitor(mask,gen_apf)  /* Set mask to specify APF bit     */
      val  = bitor(val,gen_apf)   /* Set value to APF on             */

      /***********************************************/
      /* ++ Add shell command to script stem.        */
      /***********************************************/
      tmp = output.0 + 1
      output.tmp = "'extattr +a" cpath"'"
      output.0 = tmp
    End

    If noApfVal = 1 Then Do       /* NOAPF specified                 */
      mask = bitor(mask,gen_apf)  /* Set mask to specify APF bit     */
                                  /* (Value bit is already off)      */
      /***********************************************/
      /* ++ Add shell command to script stem.        */
      /***********************************************/
      tmp = output.0 + 1
      output.tmp = "'extattr -a" cpath"'"
      output.0 = tmp
    End

    If programVal = 1 Then Do     /* PROGRAM specified               */
      mask = bitor(mask,gen_pc)   /* Set mask to specify PROGRAM bit */
      val  = bitor(val,gen_pc)    /* Set value to PROGRAM on         */

      /***********************************************/
      /* ++ Add shell command to script stem.        */
      /***********************************************/
      tmp = output.0 + 1
      output.tmp = "'extattr +p" cpath"'"
      output.0 = tmp
    End

    If noProgramVal = 1 Then Do   /* NOPROGRAM specified             */
      mask = bitor(mask,gen_pc)   /* Set mask to specify PROGRAM bit */
                                  /* (Value bit is already off)      */
      /***********************************************/
      /* ++ Add shell command to script stem.        */
      /***********************************************/
      tmp = output.0 + 1
      output.tmp = "'extattr -p" cpath"'"
      output.0 = tmp
    End

    mask=z3 || mask               /* Widen mask and value to 4 bytes */
    val=z3 || val

    If noRun = 0 Then Do
     "chattr (rpath)" ST_GENVALUE "(mask) (val)"

     If retval /= 0 Then Do
       If errno = EPERM Then Do
         say "You are not authorized to change" extAttr "extended",
             "attribute."
         If extAttr = 'some' Then
           say "Try modifying a single attribute at a time."
         If recursiveVal /= '' Then Do
           say "No more extended attribute changes will be attempted."
           /**********************************************************/
           /* Nullify the keyword variables so we don't try again.   */
           /* Note that we have already disallowed APF and PROGRAM   */
           /* with the RECURSIVE keyword, but the user might be      */
           /* specifying NOAPF or NOPROGRAM.                         */
           /**********************************************************/
           noApfVal = 0 ; noProgramVal = 0
         End
       End
       Else
         say "chattr error:" retval errno errnojr "on" rpath
     End
     Else
       If rpath = path & verboseVal > 0 |,
                         verboseVal = 11 Then Do
         If apfVal /= 0 | noApfVal /= 0 Then
           say "APF bit successfully changed for" rpath
         If programVal /= 0 | noprogramVal /= 0 Then
           say "Program-control bit successfully changed for" rpath
       End
    End /* noRun=0 */
  End  /* It's a file */
End    /* Extended attribute change requested */
Return eaRc /* processExtattrKwds */

/* ----------------------------------------------------------------- */

processAuditKwd:
/*********************************************************************/
/* Process AUDIT keyword                                             */
/*                                                                   */
/* The parseKeywords routine created two variables for us:           */
/*  - uAudString:  contains one of ALL, SUCCESS, FAILURES, or NONE   */
/*  - uPermstring: contains a 3-character maximum string consisting  */
/*                of R, W, or X in any order.                        */
/*********************************************************************/
auRc = 0 /* Return value */

If auditVal /= '' Then Do   /* AUDIT is specified                    */
  chauditVal = d2x(rstat.ST_UAUDIT,8) /* Get user audit bits      */
  ra = Substr(chauditVal,1,2)    /* Byte containing read bits    */
  wa = Substr(chauditVal,3,2)    /* Byte containing write bits   */
  xa = Substr(chauditVal,5,2)    /* Byte containing execute bits */
  rv = Substr(chauditVal,7,2)    /* Reserved byte                */

  audCmd = "'chaudit "

  Do j = 1 to Length(uPermString)
    tempAud = getAud(uAudString)
    Select
      When Substr(uPermString,j,1) = "R" Then Do
        ra = tempAud
        audCmd = audCmd||"r"
      End   /* When Read */
      When Substr(uPermString,j,1) = "W" Then Do
        wa = tempAud
        audCmd = audCmd||"w"
      End   /* When Write */
      When Substr(uPermString,j,1) = "X" Then Do
        xa = tempAud
        audCmd = audCmd||"x"
      End   /* When eXecute */
      Otherwise /* Unexpected because already checked */
        say "Invalid permission string:" uPermString
        Exit 4
    End /* Select on permission value */
  End /* For each specified permission */

  chauditVal = d2x(ra,2)||d2x(wa,2)||d2x(xa,2)||rv
  chauditVal = x2d(chauditVal)

  /***********************************************/
  /* ++ Add shell command to script stem.        */
  /***********************************************/
  Select
    When uAudString = "SUCCESS" Then Do
      audCmd = audCmd||"+s"
    End
    When uAudString = "FAILURES" Then Do
      audCmd = audCmd||"+f"
    End
    When uAudString = "ALL" Then Do
      audCmd = audCmd||"+sf"
    End
    When uAudString = "NONE" Then Do
      audCmd = audCmd||"-sf"
    End
    Otherwise
  End /* Select */
  tmp = output.0 + 1
  output.tmp = audCmd cpath"'"
  output.0 = tmp

  If noRun = 0 Then Do
   /* Issue chaudit syscall to update the user audit bits */
   "chaudit (rpath)" (chauditVal) 0

   If retval /= 0 Then Do
     If errno = EPERM Then
       say "You are not authorized to change audit settings of",
            rpath
     Else
       say "chaudit error:" retval errno errnojr
   End
   Else
     If rpath = path & verboseVal > 0 |,
                       verboseVal = 11 Then Do
       say "Owner audit bits successfully changed for" rpath
     End
  End /* noRun=0 */
End /* AUDIT is specified */

Return auRc  /* processAuditKwd */

/* ----------------------------------------------------------------- */

processGlobalauditKwd:
/*********************************************************************/
/* Process GLOBALAUDIT keyword                                       */
/*                                                                   */
/* This is done exactly as the AUDIT keyword, above, except that we  */
/* use a different field from the stat() output, and we provide a    */
/* different flag for auditor options on the chaudit() syscall.      */
/*********************************************************************/
gaRc = 0 /* Return value */

If globalAuditVal /= '' Then Do  /* GLOBALAUDIT is specified     */
  chauditVal = d2x(rstat.ST_AAUDIT,8) /* get Auditor audit bits   */
  ra = Substr(chauditVal,1,2)    /* Byte containing read bits    */
  wa = Substr(chauditVal,3,2)    /* Byte containing write bits   */
  xa = Substr(chauditVal,5,2)    /* Byte containing execute bits */
  rv = Substr(chauditVal,7,2)    /* Reserved byte                */

  audCmd = "'chaudit -a "

  Do j = 1 to Length(aPermString)
    tempAud = getAud(aAudString)
    Select
      When Substr(aPermString,j,1) = "R" Then Do
        ra = tempAud
        audCmd = audCmd||"r"
      End   /* When Read */
      When Substr(aPermString,j,1) = "W" Then Do
        wa = tempAud
        audCmd = audCmd||"w"
      End   /* When Write */
      When Substr(aPermString,j,1) = "X" Then Do
        xa = tempAud
        audCmd = audCmd||"x"
      End   /* When eXecute */
      Otherwise /* Unexpected because already checked */
        say "Invalid permission string:" aPermString
        Exit 4
    End /* Select on permission value */
  End /* For each specified permission */

  chauditVal = d2x(ra,2)||d2x(wa,2)||d2x(xa,2)||rv
  chauditVal = x2d(chauditVal)

  /***********************************************/
  /* ++ Add shell command to script stem.        */
  /***********************************************/
  Select
    When aAudString = "SUCCESS" Then Do
      audCmd = audCmd||"+s"
    End
    When aAudString = "FAILURES" Then Do
      audCmd = audCmd||"+f"
    End
    When aAudString = "ALL" Then Do
      audCmd = audCmd||"+sf"
    End
    When aAudString = "NONE" Then Do
      audCmd = audCmd||"-sf"
    End
    Otherwise
  End /* Select */
  tmp = output.0 + 1
  output.tmp = audCmd cpath"'"
  output.0 = tmp

  If noRun = 0 Then Do
   /* Issue chaudit syscall to update the auditor audit bits */
   "chaudit (rpath)" (chauditVal) 1

   If retval /= 0 Then Do
     If errno = EPERM Then
       say "You are not authorized to change auditor audit settings of",
            rpath
     Else
       say "chaudit error:" retval errno errnojr
   End
   Else
     If rpath = path & verboseVal > 0 |,
                       verboseVal = 11 Then Do
       say "Auditor audit bits successfully changed for" rpath
     End
  End /* noRun=0 */
End
Return gaRc  /* processGlobalauditKwd */

/* ----------------------------------------------------------------- */

processSeclabelKwd:
/*********************************************************************/
/* Process SECLABEL keyword                                          */
/*                                                                   */
/* There is no syscall service to update the SECLABEL, so we issue   */
/* the chlabel shell command using BPXWUNIX.                         */
/*                                                                   */
/* (You may now be asking: "Why not use bpxwunix and the relevant    */
/*  unix shell command to update *all* the security attributes       */
/*  supported by ORALTER?"  Answer: No reason at all. It was a       */
/*  fun learning experience to use the syscalls.)                    */
/*                                                                   */
/*********************************************************************/
slRc = 0 /* Return value */

If seclabelVal /= '' Then Do         /* SECLABEL is specified        */
  cmdString = "chlabel "||seclabelVal||" "||cpath

  /***********************************************/
  /* ++ Add shell command to script stem.        */
  /***********************************************/
  tmp = output.0 + 1
  output.tmp = "'"cmdString"'"
  output.0 = tmp

  If noRun = 0 Then Do
   call bpxwunix cmdString,,stdout.,stderr.

   If retval = 0 Then Do  /* bpxwunix worked. chlabel might have.    */
     If stderr.0 > 0 Then Do
       Do i = 1 to stderr.0
         say stderr.i
       End
     End
     Else
       If rpath = path & verboseVal > 0 | verboseVal = 11 Then
         say "Security label successfully changed for" rpath
   End
   Else Do
     say "Bpxwunix error" retval errno errnojr "when attempting",
         "to set seclabel for" rpath
   End
  End /* noRun=0 */
End   /* SECLABEL specified */
Return slRc  /* processSeclabelKwd */

/* ----------------------------------------------------------------- */

parseKeywords:
/*********************************************************************/
/* Examine input to identify keywords and values. We process the     */
/* keyword string as a set of words, taking into account that some   */
/* keywords might allow blank-separated values.                      */
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
  closeDoubleParen = Pos("))",keywords) /* Look for double close too */

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
  /*                                                                 */
  /* Note that this requires further tweaking for keywords with      */
  /* suboperands (e.g. GLOBAL|AUDIT), and that gets handled by       */
  /* specific keyword processing below.                              */
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
    When nextKwd = VERBOSEkwd Then
      Do
        verboseVal = 1
      End
    When nextKwd = OWNERkwd Then
      Do
        Upper nextVal
        ownerVal = nextVal
      End
    When nextKwd = GROUPkwd Then
      Do
        Upper nextVal
        groupVal = nextVal
      End
    When nextKwd = SECLABELkwd Then
      Do
        Upper nextVal
        seclabelVal = nextVal
      End
    When nextKwd = PERMSkwd Then
      Do
        Upper nextVal
        permsVal = nextVal
        /*************************************************************/
        /* Make sure the value is valid.           */
        /*************************************************************/
        permsFormat = verifyPermsFormat(permsVal)
        If permsFormat = "bad" Then Do
          say 'Incorrect PERMS value:' permsVal
          parseRc = 4
        End
      End
    When nextKwd = NOAPFkwd Then
      Do
        noApfVal = 1
      End
    When nextKwd = APFkwd Then
      Do
        apfVal = 1
      End
    When nextKwd = PROGRAMkwd Then
      Do
        programVal = 1
      End
    When nextKwd = NOPROGRAMkwd Then
      Do
        noProgramVal = 1
      End
    When nextKwd = STICKYkwd Then
      Do
        stickyVal = 1
      End
    When nextKwd = NOSTICKYkwd Then
      Do
        noStickyVal = 1
      End
    When nextKwd = SETUIDkwd Then
      Do
        setuidVal = 1
      End
    When nextKwd = NOSETUIDkwd Then
      Do
        noSetuidVal = 1
      End
    When nextKwd = SETGIDkwd Then
      Do
        setgidVal = 1
      End
    When nextKwd = NOSETGIDkwd Then
      Do
        noSetgidVal = 1
      End
    /*****************************************************************/
    /* For the AUDIT keyword, we expect the value to end with 2      */
    /* closing parens, but the code above which isolates values is   */
    /* common with 'normal' keywords, and so terminates prior to the */
    /* first closing paren, which actually makes our job easier.     */
    /*****************************************************************/
    When nextKwd = AUDITkwd Then
      Do
        auditVal = "YES"  /* Fake value indicating keyword specified */
        Upper nextVal

        Call parseAudit(nextKwd nextVal)

        /* Check that the keyword ends with 2 closing parens.        */
        If Substr(keywords,endKwd,1) /= ")" Then Do
          say "Missing ending parenthesis in" nextKwd "keyword."
          Exit 4
        End

        endKwd = endKwd + 1  /* Account for double closing paren     */
      End
    When Abbrev(GLOBALAUDITkwd,nextKwd,GLOBALabbr) = 1 Then
      Do
        globalAuditVal = "YES" /* Fake value indicating kwd spec'd   */
        Upper nextVal

        Call parseAudit(nextKwd nextVal)

        /* Check that the keyword ends with 2 closing parens.        */
        If Substr(keywords,endKwd,1) /= ")" Then Do
          say "Missing ending parenthesis in" nextKwd "keyword."
          Exit 4
        End

        endKwd = endKwd + 1  /* Account for double closing paren     */
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
  If parseRc= 0 Then
    If Substr(keywords,endKwd,1) <> " " Then Do
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

verifyPermsFormat: procedure expose permsVal
/*********************************************************************/
/* function: verifyPermsFormat                                       */
/*                                                                   */
/* input:  - The value of the specified permission string            */
/*                                                                   */
/* returns:  A string indicating the format of the input:            */
/*             - 'full'  : full symbolic form (uuugggooo)            */
/*             - 'octal' : octal format (e.g. 777, 750, etc)         */
/*             - 'oper'  : as an operator (e.g. o+r, ug-rw, etc.)    */
/*                         as supported by the chmod shell command   */
/*             - 'bad'   : none of the above                         */
/*                                                                   */
/*           When the format is 'oper' the value of permsVal,        */
/*           originally set to the value specified by the user       */
/*           for the PERMS keyword, is replaced by a normalized      */
/*           string representing the permission types, operation,    */
/*           and permission values.  See parseOperFormat.            */
/*                                                                   */
/*********************************************************************/
parse arg perms

If (Substr(perms,1,1) = "R" |,
    Substr(perms,1,1) = "-")    &,
   (Substr(perms,2,1) = "W" |,
    Substr(perms,2,1) = "-")    &,
   (Substr(perms,3,1) = "X" |,
    Substr(perms,3,1) = "-")    &,
   (Substr(perms,4,1) = "R" |,
    Substr(perms,4,1) = "-")    &,
   (Substr(perms,5,1) = "W" |,
    Substr(perms,5,1) = "-")    &,
   (Substr(perms,6,1) = "X" |,
    Substr(perms,6,1) = "-")    &,
   (Substr(perms,7,1) = "R" |,
    Substr(perms,7,1) = "-")    &,
   (Substr(perms,8,1) = "W" |,
    Substr(perms,8,1) = "-")    &,
   (Substr(perms,9,1) = "X" |,
    Substr(perms,9,1) = "-")    Then
  Do   /* Full symbolic format */
    permFormat = 'full'
  End  /* Full symbolic format */
Else
  If Verify(perms,'01234567') = 0 & Length(perms) = 3 Then Do
    permFormat = 'octal'
  End
  Else Do
    permFormat = parseOperFormat(perms)
    If permFormat /= 'bad' Then Do
      permsVal = permFormat /* Blank-separated oper string returned  */
      permFormat = 'oper'   /* Set format to oper                    */
    End
  End

Return permFormat   /* verifyPermsFormat */

/* ----------------------------------------------------------------- */

parseOperFormat: procedure
/*********************************************************************/
/* function: See if the PERMS value adheres to the operator format.  */
/*                                                                   */
/* input:  - The permission string                                   */
/*                                                                   */
/* returns:                                                          */
/*  success - Normalized, blank-separated string containing:         */
/*            - 1st word: permission types to change (U/G/O),        */
/*                        concatenated, in that order                */
/*            - 2nd word: operation (+, -, or =)                     */
/*            - 3rd word: permission values to turn on or off        */
/*                        (R/W/X), concatenated, in that order       */
/*  failure - The string "bad"                                       */
/*                                                                   */
/*********************************************************************/
parse arg perms

ops = "+-="                      /* Operator values                  */
oPos = Verify(ops,perms,Match)   /* Returns pos of 1st char found    */

If oPos /= 0 Then Do                   /* An operator was found      */
  oPos = Pos(Substr(ops,oPos,1),perms) /* Gets its position in perms */
  operator = Substr(perms,oPos,1)      /* Set variable to operator   */
  subject = Substr(perms,1,oPos-1)     /* Set var to subject type(s) */
  permissions = Substr(perms,oPos+1)   /* Set var to permissions     */

  /* Verify that only valid characters are specified in the subject. */
  If subject = '' Then Do
    say 'The permission type(s) must be specified.'
    permFormat= 'bad'            /* Must contain supported operator  */
  End
  sPos = Verify(subject,"AUGO")        /* all,user,group,other       */
  If sPos = 0 Then Do
    /* Don't let a(ll) be specified with other values. The chmod     */
    /* shell command tolerates this and uses 'all', but failing      */
    /* might be less astonishing for the security administrator.     */
    If Pos("A",subject) /=0 & Length(subject) > 1 Then Do
      say "'A'(ll) cannot be specified with other permission types."
      permFormat= 'bad'          /* Must contain supported operator  */
    End
  End
  Else Do
    badChar = Substr(subject,sPos,1)
    say badChar "is not a valid permission type."
    permFormat= 'bad'            /* Must contain supported operator  */
  End

  /* Fail if permissions are null. Chmod tolerates this as a no-op,  */
  /* but see above.                                                  */
  if permissions = '' Then Do
    say "No permission values were specified."
    permFormat= 'bad'            /* Must contain supported operator  */
  End
  /* Verify that only valid characters are specified in the perms.   */
  Else Do
    bPos = Verify(permissions,"RWX") /* Pos of 1st char found */
    If bPos /= 0 Then Do
      badChar = Substr(permissions,bPos,1)
      say badChar "is not a valid permission value."
      permFormat= 'bad'          /* Must contain supported operator  */
    End
  End

  /* Fail for subject and permissions > 3 chars. Chmod tolerates     */
  /* this, but see above.                                            */
  If Length(subject) > 3 Then Do
    say "Permission types can be no more than 3 characters."
    permFormat= 'bad'            /* Must contain supported operator  */
  End
  If Length(permissions) > 3 Then Do
    say "Permission values can be no more than 3 characters."
    permFormat= 'bad'            /* Must contain supported operator  */
  End
  /* Normalize by building new subject and permissions strings.      */
  tmpPerms=''
  valPerms=''
  If Pos("R",permissions) > 0 Then Do
    tmpPerms = tmpPerms||"R"
    valPerms = valPerms||"R"
  End
  Else
    tmpPerms = tmpPerms||"-"
  If Pos("W",permissions) > 0 Then Do
    tmpPerms = tmpPerms||"W"
    valPerms = valPerms||"W"
  End
  Else
    tmpPerms = tmpPerms||"-"
  If Pos("X",permissions) > 0 Then Do
    tmpPerms = tmpPerms||"X"
    valPerms = valPerms||"X"
  End
  Else
    tmpPerms = tmpPerms||"-"
  If subject = "A" Then
    subject = "UGO"
  tmpSubject = ''
  If Pos("U",subject) > 0 Then
    tmpSubject = tmpSubject||"U"
  If Pos("G",subject) > 0 Then
    tmpSubject = tmpSubject||"G"
  If Pos("O",subject) > 0 Then
    tmpSubject = tmpSubject||"O"
  /* If the specified perm types string is longer than the normal-   */
  /* ized string, then duplicate values must have been specified     */
  /* (e.g. "rrw"). Chmod tolerates this, but see above.              */
  If permFormat /= "bad" &,      /* Error not already flagged        */
     Length(tmpSubject) < Length(subject) Then Do
    say "Duplicate permission tyoes specified."
    permFormat= 'bad'            /* Must contain unique perms        */
  End
  If permFormat /= "bad" then
    permFormat = tmpSubject operator tmpPerms
End
Else
  permFormat= 'bad'              /* Must contain supported operator  */

Return permFormat                /* parseOperFormat                  */

/* ----------------------------------------------------------------- */

checkKeywords:
/*********************************************************************/
/* Check for consistency of keywords:                                */
/*  - Issue message and set return code when mutually exclusive      */
/*    keywords are specified.                                        */
/*  - Set defaults as appropriate.                                   */
/*********************************************************************/

execRc = 0

/*********************************************************************/
/* Check if both APF and NOAPF are specified.                        */
/*********************************************************************/
If apfVal = 1 & noApfVal = 1 Then Do
  say "You cannot specify both APF and NOAPF."
  execRc = 1
End

/*********************************************************************/
/* Check if both PROGRAM and NOPROGRAM are specified.                */
/*********************************************************************/
If programVal = 1 & noProgramVal = 1 Then Do
  say "You cannot specify both PROGRAM and NOPROGRAM."
  execRc = 1
End

/*********************************************************************/
/* Check if both STICKY and NOSTICKY are specified.                  */
/*********************************************************************/
If stickyVal = 1 & noStickyVal = 1 Then Do
  say "You cannot specify both STICKY and NOSTICKY."
  execRc = 1
End

/*********************************************************************/
/* Check if both SETUID and NOSETUID are specified.                  */
/*********************************************************************/
If setuidVal = 1 & noSetuidVal = 1 Then Do
  say "You cannot specify both SETUID and NOSETUID."
  execRc = 1
End

/*********************************************************************/
/* Check if both SETGID and NOSETGID are specified.                  */
/*********************************************************************/
If setgidVal = 1 & noSetgidVal = 1 Then Do
  say "You cannot specify both SETGID and NOSETGID."
  execRc = 1
End

/*********************************************************************/
/* Check if either APF or PROGRAM is specified with RECURSIVE.       */
/* That just seems dangerous.                                        */
/*********************************************************************/
If programVal = 1 & recursiveVal /= '' Then Do
  say "You cannot specify PROGRAM with the RECURSIVE keyword."
  execRc = 1
End

If apfVal = 1 & recursiveVal /= '' Then Do
  say "You cannot specify APF with the RECURSIVE keyword."
  execRc = 1
End

Return execRc /* checkKeywords */

/* ----------------------------------------------------------------- */

/*********************************************************************/
/* function: getAud                                                  */
/*                                                                   */
/* input:  - A string indicating the audit bits that should be set   */
/*           ('ALL', 'NONE', 'SUCCESS', or 'FAILURES')               */
/*                                                                   */
/* returns:  A numeric value corresponding to the bits that must     */
/*           be set (3, 0, 1, or 2, respective to the input)         */
/*                                                                   */
/*********************************************************************/
getAud: procedure
parse arg audString

Select
  When audString = "SUCCESS" Then Do
    audVal = 1
  End
  When audString = "FAILURES" Then Do
    audVal = 2
  End
  When audString = "ALL" Then Do
    audVal = 3
  End
  Otherwise /* NONE */
    audVal = 0
End /* Select */

Return audVal /* getAud */

/* ----------------------------------------------------------------- */

parseAudit: procedure expose uAudString uPermString,
                             aAudString aPermString,
                             AUDITkwd
/*********************************************************************/
/* function: parseAudit                                              */
/*                                                                   */
/* input:  - The keyword being processed (AUDIT or GLOBALAUDIT)      */
/*         - The value specified for the keyword                     */
/*                                                                   */
/* exposes:  uAudString  - ALL, NONE, SUCCESS, or FAILURES           */
/*           uPermString - The permissions specified (e.g. RWX)      */
/*           aAudString  - ALL, NONE, SUCCESS, or FAILURES           */
/*           aPermString - The permissions specified (e.g. RWX)      */
/*                                                                   */
/*           The "u" variables are for the AUDIT (user audit         */
/*             options) keyword                                      */
/*           The "a" variables are for the GLOBALAUDIT (auditor      */
/*             audit options) keyword                                */
/*                                                                   */
/*                                                                   */
/*********************************************************************/
parse arg keyword kwdValue

oparenIdx = Pos("(",kwdValue)
If oparenIdx = 0 Then Do
  say "Invalid" keyword "value:" kwdValue
  Exit 4
End

audString = Substr(kwdValue,1,oparenIdx-1)
permString = Substr(kwdValue,oparenIdx+1)

/* Validate that audString contains a valid value.                   */
If audString /= "ALL"     &,
  audString /= "FAILURES" &,
  audString /= "NONE"     &,
  audString /= "SUCCESS"  Then Do
  say "Invalid" keyword "access-intent value:" audString
  Exit 4
End

/* Validate that permString is 1 to 3 characters in length           */
If Length(permString) = 0 |,
   Length(permString) > 3 Then Do
  say "Invalid" keyword "permission string:" permString
  Exit 4
End
/* Validate that permString contains only R, W, and X                */
rCount = 0 ; wCount = 0 ; xCount = 0
Do j = 1 to Length(permString)
  Select
    When Substr(permString,j,1) = "R" Then
      rCount = rCount + 1
    When Substr(permString,j,1) = "W" Then
      wCount = wCount + 1
    When Substr(permString,j,1) = "X" Then
      xCount = xCount + 1
    Otherwise
      say "Invalid" keyword "permission string:" permString
      Exit 4
  End
End

/* Validate that permString does not contain duplicate               */
/* values (e.g. RRX)                                                 */
If rCount > 1 | wCount > 1 | xCount > 1 Then Do
  say "Invalid" keyword "permission string:" permString
  Exit 4
End

/* Copy working variables into the appropriate exposed variables,    */
/* depending on whether we are processing AUDIT or GLOBALAUDIT.      */
If keyword = AUDITkwd Then Do
  uAudString = audString
  uPermString = permString
End
Else Do
  aAudString = audString
  aPermString = permString
End

Return /* parseAudit */

/* ----------------------------------------------------------------- */

OctalOf: procedure
/*********************************************************************/
/* function: octalOf                                                 */
/*                                                                   */
/* input:  - A three-character permission string (e.g., 'RWX',       */
/*           '---', 'R-X', etc)                                      */
/*         - An optional operator. When this value is "-", we        */
/*           return the 'complement' of the normal output,           */
/*           suitable for masking OFF the input bits.                */
/*                                                                   */
/* returns:  The octal representation of the input bits, which is    */
/*           a single digit value from 0-7.                          */
/*                                                                   */
/*********************************************************************/
parse arg perms,op

oVal = 0

If Substr(perms,1,1) = "R" Then
  oVal = oVal + 4
If Substr(perms,2,1) = "W" Then
  oVal = oVal + 2
If Substr(perms,3,1) = "X" Then
  oVal = oVal + 1

If op = "-" Then
  oVal = 7 - oVal

Return oVal /* octalOf */

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

munge: procedure
/*********************************************************************/
/* function: munge                                                   */
/*                                                                   */
/* input:  - A path name                                             */
/*                                                                   */
/* returns:  A version of the path name suitable for use in a        */
/*           shell command                                           */
/*                                                                   */
/*********************************************************************/
parse arg iPath

oPath = iPath                        /* Echo the input by default    */
If Pos(" ",iPath) > 0 Then           /* If path contains a blank     */
  oPath = '"'iPath'"'                /*  enclose it in doublequotes  */

Return oPath                         /* munge                        */

/* ----------------------------------------------------------------- */

buildOutputHeader:
/*********************************************************************/
/* procedure: buildOutputHeader                                      */
/*                                                                   */
/* output: The following global variables are modified               */
/*         - output. stem is primed with the heading defined         */
/*           at the bottom of this file, and filled in with the      */
/*           user-specified keywords that will result in             */
/*           generated shell commands.                               */
/*                                                                   */
/* Notes:  We intentionally omit the path name to avoid awkward      */
/*         continuations if it is greater than the line length.      */
/*                                                                   */
/*********************************************************************/
output.0 = 0
/*********************************************************************/
/* Find start of template at the bottom of this file.                */
/*********************************************************************/
Do sl = sourceline() to 1 by -1 Until sourceline(sl) = 'Template:'
End
/*********************************************************************/
/* Set up some variables used while inserting variable lines.        */
/*********************************************************************/
lineStart = 4 ; lineEnd = 68
lineLen = lineEnd - lineStart

/*********************************************************************/
/* Prime the script stem with the template lines.                    */
/*********************************************************************/
Do sl = sl+1 to sourceline()-1
  line = '/* ' /* Reset line prefix */
  tmp = output.0 + 1

  If Pos("Created by",sourceline(sl)) /= 0 Then Do
    line = line'Created by    :' Userid() 'using the' execName 'exec'
    line = Left(line,lineEnd," ") '*/'
    output.tmp = line
  End
  Else If Pos("Creation date",sourceline(sl)) /= 0 Then Do
    line = line'Creation date :' Date() Time()
    line = Left(line,lineEnd," ") '*/'
    output.tmp = line
  End
  Else Do
    output.tmp = Substr(sourceline(sl),1,71)
  End

  output.0 = tmp
End

/*********************************************************************/
/* Process keywords by putting as many as will cleanly fit in a      */
/* given line.  Write each line to the stem as they fill up.         */
/*********************************************************************/
line = '/* '   /* Reset line prefix */
Do kNum = 1 to Words(saveKwds)
  token = Strip(Word(saveKwds,kNum),Both," ")
  /*******************************************************************/
  /* If the keyword fits, append it to the current line.  Else,      */
  /* write the line to the stem, and prime a new line for the next   */
  /* keyword iteration.                                              */
  /*******************************************************************/
  If Length(token) <= lineEnd-Length(line) Then Do
    line = line token
  End
  Else Do
    line = Left(line,lineEnd," ") '*/'
    tmp = output.0 + 1
    output.tmp = line
    output.0 = tmp
    line = '/* '  /* Reset for next line */
  End
End
/*********************************************************************/
/* Put remaining keywords in a final stem entry.                     */
/*********************************************************************/
If Length(line) > 0 Then Do  /* Write remainder */
  line = Left(line,lineEnd," ") '*/'
  tmp = output.0 + 1
  output.tmp = line
  output.0 = tmp
End

/*********************************************************************/
/* Add block comment closing two lines                               */
/*********************************************************************/
Do sl = Sourceline()-1 to Sourceline()
  tmp = output.0 + 1
  output.tmp = Substr(sourceline(sl),1,71)
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
/* Put "exit 0" at the end of the script to avoid exit status 255    */
/* when executing the script with OSHELL.                            */
/*********************************************************************/
tmp = output.0 + 1
output.tmp = "exit 0"
output.0 = tmp

/*********************************************************************/
/* Write the output stem to the output UNIX file.                    */
/*********************************************************************/
If Substr(outputFile,1,2) /= "//" Then Do  /* Unix file/path         */
  'writefile (outputFile) 700 output.'
  If retval = -1 Then Do
    fileCreated = 0
    say 'writefile error:' retval errno errnojr 'attempting to create',
        outputFile 'output file.'
    If noRun = 0 Then
      say 'No changes were made.'
  End
End
/*********************************************************************/
/* Write the output stem to the output data set.                     */
/*********************************************************************/
Else Do
  dsName = Substr(outputFile,3) /* Name starts after "//" */
  address TSO                           /* Establish TSO environment */
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

  address syscall    /* Restore syscall environment */
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
/* Rexx **************************************************************/
/*                                                                   */
/* Created by    :                                                   */
/* Creation date :                                                   */
/*                                                                   */
/* This script contains the UNIX shell commands generated            */
/* as a result of running the exec identified above with             */
/* the following keywords:                                           */
/*                                                                   */
/*********************************************************************/
