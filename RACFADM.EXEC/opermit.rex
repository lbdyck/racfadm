/*%NOCOMMENT====================* REXX *==============================*/
/*     TYPE:  TSO Command                                             */
/*  PURPOSE:  RACF Unix Access Control List (ACL) Management (PERMIT) */
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
/* rexx */
/**********************************************************************
 Licensed Materials - Property of IBM
 5650-ZOS
 Copyright IBM Corp. 2020

 Name:    OPERMIT

 Version: 2

 Author: Bruce Wells - brwells@us.ibm.com

 Purpose: Provides UNIX access control list (acl) management using
          a syntax consistent with the RACF PERMIT command

 Input:   An absolute path name

 NOTE!!! This exec is dependent upon the following "Syntax:" line and
         the "End-Syntax" line below in order to display the syntax
         when the exec is invoked without keyword parameters.

         Feel free to add/change examples to show things that are
         frequently done in your orgnization. But please preserve
         these surrounding lines.

 Beg-Syntax:
 Purpose:  Provides UNIX access control list (acl) management using
           a syntax consistent with the RACF PERMIT command

 Syntax:   OPERMIT absolute-path-name operands

 Operands: All keywords are optional
             absolute-path-name     (positional)
             ACCess(access-authority) | DELETE
             ACL FMODEL DMODEL | ALL - type(s) of acl being modified.
             ---
             CLASS(FSSEC)
             DEBUG
             FROM(absolute-path-name)
             FTYPE(ACL|FMODEL|DMODEL)
                   ---
             ID(name ...)
             OUTFILE(path-or-dataset-name)
             RECursive(ALL | CURRENT | FILESYS)
                             -------
             RESET
             VERBOSE

 Examples:
   1) Permit user JOHND to an access ACL
        OPERMIT /u/brwells/myfile CLASS(FSSEC) ID(JOHND) ACCESS(r-x)
        or
        OPERMIT /u/brwells/myfile              ID(JOHND) ACCESS(r-x)

   2) Remove access of group SYSPROGS from an access ACL
        OPERMIT /u/brwells/myfile ID(SYSPROGS) DELETE

   3) Remove an entire access list
        OPERMIT /u/brwells/myfile RESET
        OPERMIT /u/brwells/myfile RESET FMODEL
        OPERMIT /u/brwells/myfile RESET DMODEL

   4) Merge the access ACL from one path into that of another
        OPERMIT /u/brwells/myfile FROM(/u/brwells/sourceFile)

   5) Add/change an entry in a file model ACL
        OPERMIT /u/brwells/myfile ID(JOHND) ACCESS(rw-) FMODEL

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
/* this exec as (OPERMIT by default).                                */
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
VERBOSEkwd   = "VERBOSE"
RESETkwd     = "RESET"      ; resetVal = 0
FROMkwd      = "FROM"       ; fromVal = ''
FTYPEkwd     = "FTYPE"      ; ftypeVal = ''
ACCESSkwd    = "ACCESS"     ; accessVal = ''
ACCabbr      = 3            /* ACC is shortest allowed abbreviation  */
IDkwd        = "ID"         ; idVal = ''
DELETEkwd    = "DELETE"     ; deleteVal = 0
CLASSkwd     = "CLASS"      ; classVal = ''
ALLkwd       = "ALL"        ; allVal = 0
ACLkwd       = "ACL"        ; aclVal = 0
FMODELkwd    = "FMODEL"     ; fmodelVal = 0
DMODELkwd    = "DMODEL"     ; dmodelVal = 0
RECURSIVEkwd = "RECURSIVE"  ; recursiveVal = ''
RECabbr      = 3            /* REC is shortest allowed abbreviation  */
DEBUGkwd     = "DEBUG"      ; debugVal = 0
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
/* If FROM is specified, make sure path name exists and user has     */
/* access.                                                           */
/*********************************************************************/
If fromVal /= '' Then Do    /* FROM is specified                     */
  execRc = validateFrom()   /* Validate and set up FROM object/acl   */
  Select
    When(execRc = 0) Then
      Do                    /* FROM object exists and has acl        */
      End
    When(execRc = 4) Then
      fromVal = ''          /* No acl, pretend FROM not specified    */
    Otherwise
      Signal GETOUT         /* Terminating error                     */
  End /* Select */
End  /* FROM specified */

/*********************************************************************/
/* For the values specified in ID(x ...), build the following stems: */
/*   - permName: The RACF user ID or group name in the ID operand    */
/*   - permType: indicates if the value is a user ID or group        */
/*   - permID  : the UNIX UID or GID to which the name maps          */
/*********************************************************************/
permName.0 = 0
permType.0 = 0
permID.0 = 0
If idVal /= '' Then Do
  execRc = buildIdStems()
  If execRc /= 0 Then
    Signal GETOUT
  If debugVal = 1 Then Do
    say ''
    say 'ID values: name uid/gid type (1=user, 2=group)'
    Do i = 1 to permID.0
      say permName.i permID.i permType.i
    End
    say ''
  End
End

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
  /* Nullify FMODEL and DMODEL, since they do not apply to files.    */
  /*******************************************************************/
  If ACLval = 1 Then Do
    fmodelVal = 0 ; dmodelVal = 0
  End

  /*******************************************************************/
  /* Process files if ACL keyword is specified or defaulted.         */
  /*******************************************************************/
  If ACLval = 1 Then Do
    Do objs = 1 to filelist.0
      execRc = processKeywords(filelist.objs)
      If execRc /= 0 Then
        Signal GETOUT
    End
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

/*********************************************************************/
/* Execute list of shell commands that this OPERMIT command          */
/* generated, if we have any commands.                               */
/*********************************************************************/
If noRun = 0 & scriptOK = 1 Then Do
  If Substr(outputFile,1,2) /= "//" Then Do /* Script in UNIX file   */

    call bpxwunix outputFile,,stdout.,stderr.

    If retval >= 0 Then Do  /* bpxwunix worked. setfacl might have.  */
      If stderr.0 > 0 Then Do
        Do i = 1 to stderr.0
          say stderr.i
        End
      End
    End
    Else Do
      say "Bpxwunix error" retval errno errnojr "when attempting",
          "to run the" outputFile "file."
    End
  End                                       /* Script in UNIX file   */
  Else Do                                   /* Script in data set    */
    say 'Unable to execute shell script because you have saved it',
        'into a data set.  See the value of the outputFile',
        'configuraton variable.'
    say 'No changes were made.'
  End
End   /* Not in noRun mode          */

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
/*         - There is a conscious ordering in which we process       */
/*           the keywords:                                           */
/*           1) RESET - This cleans the slate for subsequent         */
/*              keywords                                             */
/*           2) FROM  - This merges acl entries from the source      */
/*              acl to the target acl.                               */
/*           3) ID/ACCESS/DELETE - this modifies whatever acl        */
/*              entries may already exist or have been copied.       */
/*         - We use some UNIX syscall commands to retrieve acls      */
/*           and to manipulate acls in memory, but we always         */
/*           generate setfacl commands rather than update acls       */
/*           using the aclset syscall command. This is because       */
/*           aclset always replaces an existing acl. This means      */
/*           that the existing contents of an acl must be read,      */
/*           altered, and re-written. The resulting audit trail      */
/*           is brutal.  For example, if you have 100 existing       */
/*           acl entries, and you modify only one, you would see     */
/*           a "DELFACL" SMF record, followed by 100 "SETFACL"       */
/*           SMF records, all of which seem to be for new permits.   */
/*           In contrast, by issuing a setfacl command, you get a    */
/*           single "SETFACL" SMF record which contains the old,     */
/*           as well as the new, permissions.  This approach also    */
/*           eliminates timing/error windows which could leave       */
/*           your acl worse off than it started.                     */
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
/* Pre-process the ID, ACCESS, and DELETE keywords by setting up     */
/* parts of an acl entry into which an UID/GID can be set below      */
/* for each mappable ID value.                                       */
/*********************************************************************/
/*********************************************************************/
/* Iterate thrice: once for each acl type.                           */
/*********************************************************************/
Do j = 1 to 3                       /* Process each acl type         */
  Select
    When j = 1 Then Do
      If aclVal = 1 Then Do         /* Access acl requested?         */
        aclType = ACL_TYPE_ACCESS   /* Process access acl            */
        aclStatType = ST_ACCESSACL
        aTypeMsg = "access"
        aTypeCmd = "a"              /* Switch value for shell cmd    */
        aTypeEnt = ""               /* No type for setfacl entry     */
      End
      Else
        Iterate                     /* No, skip this iteration       */
    End
    When j = 2 Then Do
      If fmodelVal = 1 Then Do      /* File model acl requested?     */
        aclType = ACL_TYPE_FILEDEFAULT /* Process file model acl     */
        aclStatType = ST_FMODELACL
        aTypeMsg = "file model"
        aTypeCmd = "f"              /* Switch value for shell cmd    */
        aTypeEnt = "fdefault:"      /* fmod type for setfacl entry   */
      End
      Else
        Iterate                     /* No, skip this iteration       */
    End
    When j = 3 Then Do
      If dmodelVal = 1 Then Do      /* Directory model acl requested?*/
        aclType = ACL_TYPE_DIRDEFAULT    /* Process dir model acl    */
        aclStatType = ST_DMODELACL
        aTypeMsg = "directory model"
        aTypeCmd = "d"              /* Switch value for shell cmd    */
        aTypeEnt = "default:"       /* dmod type for setfacl entry   */
      End
      Else
        Iterate                     /* No, skip this iteration       */
    End
    Otherwise
  End /* Select */

  /*******************************************************************/
  /* Process RESET keyword.                                          */
  /*******************************************************************/
  If resetVal = 1 Then Do      /* RESET specified */

    /***********************************************/
    /* ++ Add shell command to script stem.        */
    /***********************************************/
    tmp = output.0 + 1
    output.tmp = "'setfacl -D"aTypeCmd cpath"'"
    output.0 = tmp
  End         /* RESET specified   */

  /*******************************************************************/
  /* Process FROM keyword.                                           */
  /*******************************************************************/
  If fromVal /= '' Then Do
    /*****************************************************************/
    /* Merge the FROM acl into the target object's access acl if     */
    /* requested.                                                    */
    /*****************************************************************/
    'aclinit tacl'                   /* init var to hold target acl  */
    'aclget tacl (rpath)' (aclType)  /* get the target acl           */

    'aclinit iacl'                   /* init var to hold temp acl    */
    iNames. = ''                     /* Stem of mapped iacl names    */
    iNames.0 = 0
    entryNum = mergeAcls()           /* Go sort them out             */

    If entryNum > 0 Then Do          /* If any entries to copy       */
      Do ents=1 by 1                 /* For each temp acl entry      */
        'aclgetentry iacl tempEnt.' ents
        If rc<0 | retval=-1 Then Leave  /* error, or no more entries */

        /***********************************************/
        /* ++ Add shell command to script stem.        */
        /***********************************************/
        If tempEnt.ACL_ENTRY_TYPE = ACL_ENTRY_USER Then
          sfType = "user"
        Else
          sfType = "group"

        If tempEnt.ACL_READ = 1 Then
          entPerms = "r"
        Else
          entPerms = "-"
        If tempEnt.ACL_WRITE = 1 Then
          entPerms = entPerms"w"
        Else
          entPerms = entPerms"-"
        If tempEnt.ACL_EXECUTE = 1 Then
          entPerms = entPerms"x"
        Else
          entPerms = entPerms"-"

        aEntry = aTypeEnt||sfType||":"iNames.ents":"entPerms
        tmp = output.0 + 1
        output.tmp = "'setfacl -m" aEntry cpath"'"
        output.0 = tmp
      End /* Loop on entries to copy */
    End /* entries to copy */
    Else Do
      If path = rpath & verboseVal = 1 | verboseVal = 11 Then
        say "No acl entries were copied from" fromVal 'to the',
            aTypeMsg 'acl of' rpath"."
    End
    'aclfree tacl' /* must free source acl buffer */
    'aclfree iacl' /* must free intermediate acl buffer */
  End                    /* Process FROM keyword          */

  /*******************************************************************/
  /* Process ID, ACCESS, and DELETE keywords                         */
  /*******************************************************************/
  If permName.0 > 0 Then Do /* Mappable ID values were specified     */
    /*****************************************************************/
    /* Loop through each value in our perm stem and build a          */
    /* separate setfacl command for each one.                        */
    /*****************************************************************/
    Do p = 1 to permName.0    /* For each mappable ID value          */
      /***********************************************/
      /* ++ Add shell command to script stem.        */
      /***********************************************/
      If permType.p = ACL_ENTRY_USER Then
        sfType = "user"
      Else
        sfType = "group"
      entPerms = Translate(accessVal,"rwx","RWX")
      aEntry = aTypeEnt||sfType||":"permName.p
      tmp = output.0 + 1

      /***************************************************************/
      /* If DELETE is specified, we use '-x' and don't append the    */
      /* permissions qualifier.                                      */
      /***************************************************************/
      If deleteVal = 1 Then
        output.tmp = "'setfacl -x" aEntry cpath"'"
      /***************************************************************/
      /* If DELETE is not specified, we use '-m' and append the      */
      /* permissions qualifier.                                      */
      /***************************************************************/
      Else
        output.tmp = "'setfacl -m" aEntry":"entPerms cpath"'"

      output.0 = tmp
    End                       /* For each ID value                   */
  End                         /* Process permit                      */
End                           /* Process each acl type loop          */

kwdExit:
Return pkRc                     /* processKeywords                   */

/* ----------------------------------------------------------------- */

parseKeywords:
/*********************************************************************/
/* Examine input to identify keywords and values. We process the     */
/* keyword string as a set of words, taking into account that        */
/* ID(x ...) can contains a list of blank-separated values.          */
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
  /*                                                                 */
  /* In the case of ID, the value may be a blank-separated list      */
  /* of users and groups, so we must take care to identify the       */
  /* end of the keyword by looking for the closing paren.            */
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
    When nextKwd = IDkwd Then
      Do
        Upper nextVal
        idVal = nextVal
      End
    When Abbrev(ACCESSkwd,nextKwd,ACCabbr) = 1 Then
      Do
        Upper nextVal
        accessVal = nextVal
        /*************************************************************/
        /* Make sure the value is valid.           */
        /*************************************************************/
        If Substr(accessVal,1,1) /= "R" &,
           Substr(accessVal,1,1) /= "-"        |,
           Substr(accessVal,2,1) /= "W" &,
           Substr(accessVal,2,1) /= "-"        |,
           Substr(accessVal,3,1) /= "X" &,
           Substr(accessVal,3,1) /= "-" Then
          Do
            say 'Incorrect ACCESS value:' accessVal
            parseRc = 4
          End
      End
    /*****************************************************************/
    /* The CLASS keyword is optional, but if specified, must have    */
    /* a value of "FSSEC".  CLASS is tolerated so that OPERMIT       */
    /* syntax can match PERMIT syntax as closely as possible.        */
    /*****************************************************************/
    When nextKwd = CLASSkwd Then   /* CLASS is pretty much a no-op   */
      Do
        Upper nextVal
        classVal = nextVal
        If classVal /= "FSSEC" Then Do
          say "Incorrect CLASS value:" classVal
          parseRc = 4
        End
      End
    When nextKwd = FROMkwd Then
      Do
        fromVal = nextVal
      End
    When nextKwd = FTYPEkwd Then
      Do
        Upper nextVal
        ftypeVal = nextVal
        Select
          When ftypeVal = 'ACL' Then Do
            ftypeMsg = 'access'
            ftypeCode = ACL_TYPE_ACCESS
          End
          When ftypeVal = 'FMODEL' Then Do
            ftypeMsg = 'file model'
            ftypeCode = ACL_TYPE_FILEDEFAULT
          End
          When ftypeVal = 'DMODEL' Then Do
            ftypeMsg = 'directory model'
            ftypeCode = ACL_TYPE_DIRDEFAULT
          End
          Otherwise Do
            say 'Invalid value specified for FTYPE keyword.'
            say 'Use one of ACL, DMODEL, or FMODEL, or omit',
                'the keyword for the default of ACL.'
            parseRc = 4
          End
        End /* Select */
      End
    When nextKwd = RESETkwd Then
      Do
        resetVal = 1
      End
    When nextKwd = DELETEkwd Then
      Do
        deleteVal = 1
      End
    When nextKwd = ALLkwd Then
      Do
        allVal = 1
        If stat.ST_TYPE /= S_ISDIR Then Do
          say "ALL can only be specified for a directory."
        End
      End
    When nextKwd = ACLkwd Then
      Do
        aclVal = 1
      End
    When nextKwd = FMODELkwd Then
      Do
        fmodelVal = 1
        If stat.ST_TYPE /= S_ISDIR Then Do
          say "FMODEL can only be specified for a directory."
          parseRc = 4
        End
      End
    When nextKwd = DMODELkwd Then
      Do
        dmodelVal = 1
        If stat.ST_TYPE /= S_ISDIR Then Do
          say "DMODEL can only be specified for a directory."
          parseRc = 4
        End
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

checkKeywords:
/*********************************************************************/
/* Check for consistency of keywords:                                */
/*  - Issue message and set return code when mutually exclusive      */
/*    keywords are specified.                                        */
/*  - Set defaults as appropriate.                                   */
/*********************************************************************/

execRc = 0

/*********************************************************************/
/* If ALL was specified, none of ACL, FMODEL, or DMODEL can be       */
/* specified.                                                        */
/*********************************************************************/
If allVal = 1 Then Do
  If aclVal = 1 | fmodelVal = 1 | dmodelVal = 1 Then Do
    say 'None of ACL, DMODEL, or FMODEL can be specified with ALL.'
    execRc = 4
  End
  Else Do         /* Set flags as if each ACL type was specified     */
    aclVal = 1
    dmodelVal = 1
    fmodelVal = 1
  End
End

/*********************************************************************/
/* If none of ACL, FMODEL, or DMODEL were specified, default to ACL  */
/* for subsequent processing.                                        */
/*********************************************************************/
If aclVal = 0 & fmodelVal = 0 & dmodelVal = 0 Then Do
  aclVal = 1
End

/*********************************************************************/
/* When ID is specified, one of ACCESS and DELETE must also be,      */
/* but not both.                                                     */
/*********************************************************************/
If idVal /= '' Then Do
  If accessVal = '' & deleteVal = 0 Then Do
    say 'ID specified without ACCESS or DELETE.',
        'Permissions are unchanged.'
    execRc = 4
  End

  If accessVal /= '' & deleteVal = 1 Then Do
    say 'ACCESS and DELETE cannot both be specified.',
        'Permissions are unchanged.'
    execRc = 4
    Signal CHECKOUT
  End
End

/*********************************************************************/
/* If RESET and DELETE are both specified, RESET is ignored.         */
/*********************************************************************/
If resetVal = 1 & deleteVal = 1 Then Do
  say 'RESET is ignored because DELETE is also specified.'
  resetVal = 0
End

/*********************************************************************/
/* If FTYPE is specified in the absence of FROM, FTYPE is ignored.   */
/*********************************************************************/
If ftypeVal /= '' & fromVal = '' Then Do
  say 'FTYPE is ignored because FROM is not also specified.'
  ftypeVal = 0
End

/*********************************************************************/
/* If FTYPE is not specified, set defaults for ACL.                  */
/*********************************************************************/
If ftypeVal = '' Then Do
  ftypeVal = 'ACL'
  ftypeMsg = 'access'
  ftypeCode = ACL_TYPE_ACCESS
End

CHECKOUT:
Return execRc    /* checkKeywords */

/* ----------------------------------------------------------------- */

mergeAcls:
/*********************************************************************/
/* Merge entries from a source acl into a target acl.  If an acl     */
/* entry for the same user or group exist in both the source and     */
/* target acl, the target entry is left unchanged.                   */
/*                                                                   */
/* Input:                                                            */
/*      - sacl: Global stem variable containing the source acl       */
/*      - tacl: Global stem variable containing the target acl       */
/*      - iacl: Global stem variable containing the intermediate     */
/*        (working) acl                                              */
/*                                                                   */
/* Output:                                                           */
/*      - iacl contains only those entries in the source acl         */
/*        whose id does not already exist in the target acl          */
/*      - iNames stem contains mapped user IDs/group names           */
/*        corresponding to iacl.                                     */
/*                                                                   */
/* Returns:                                                          */
/*      - number of entries in iacl                                  */
/*                                                                   */
/* Notes:                                                            */
/*      - This routine works on in-memory acl stem variables. It     */
/*        does not read or write any actual acl contents from/to     */
/*        files.                                                     */
/*                                                                   */
/*********************************************************************/
changes = 0                      /* Number of entries to apply       */
/*********************************************************************/
/* Loop through the source acl processing each entry in turn.        */
/*********************************************************************/
Do x=1 by 1                      /* For each source (FROM) acl entry */
  'aclgetentry sacl fromEnt.' x
  If rc<0 | retval=-1 Then Leave /* error, or no more entries */

  /*******************************************************************/
  /* Map the source entry's UID/GID to a user ID/group. If the xID   */
  /* is unmappable, we will issue a message and exclude it           */
  /* from the output stem. This probably indicates that a UNIX       */
  /* user or group was deleted from RACF, and orphan acl entries     */
  /* were not cleaned up.    There is no sense in propagating        */
  /* this condition.                                                 */
  /*******************************************************************/
  If fromEnt.acl_entry_type = ACL_ENTRY_USER Then Do
    msgType = "user"
    msgIdType = "UID"
    'getpwuid' fromEnt.acl_id 'pwnam.'
    If retval > 0 Then             /* Mapping successful             */
      msgName = Strip(pwnam.PW_NAME,Both," ")
    Else
      msgName = "*unmappable*"
  End
  Else Do
    msgType = "group"
    msgIdType = "GID"
    'getgrgid' fromEnt.acl_id 'grnam.'
    If retval > 0 Then             /* Mapping successful             */
      msgName = Strip(grnam.GR_NAME,Both," ")
    Else
      msgName = "*unmappable*"
  End
  /*******************************************************************/
  /* If the xID is unmappable, we will issue a message and           */
  /* exclude it from the output stem.    This probably               */
  /* indicates that a user or group was deleted from RACF,           */
  /* and orphan acl entries were not cleaned up.    There is no      */
  /* sense in propagating this condition.                            */
  /*******************************************************************/
  If msgName = "*unmappable*" Then Do
    say 'The UNIX' msgIdType 'value of' fromEnt.acl_id 'does not',
        'map to a RACF' msgType'. The entry is not copied to the',
        aTypeMsg 'acl of' rpath"."
    Iterate /* Process next source acl entry */
  End

  /*******************************************************************/
  /* Loop through each target acl entry looking for a match on the   */
  /* source. If found, issue a message.                              */
  /*******************************************************************/
  Do y = 1 By 1          /* For each target acl entry                */
    noCopy = 0           /* 0 = source acl entry should be copied    */
    'aclgetentry tacl toEnt.' y
    If rc<0 | retval=-1 Then Do    /* error, or no more entries */
      Leave
    End

    /*****************************************************************/
    /* Like the RACF PERMIT command, we issue a message when         */
    /* declining to copy a matching acl entry, but only if           */
    /* VERBOSE is specified.                                         */
    /*****************************************************************/
    If fromEnt.acl_entry_type = toEnt.acl_entry_type &,
       fromEnt.acl_id = toEnt.acl_id Then Do
      If verboseVal > 0 Then Do
        say 'The UNIX' msgIdType 'value of' fromEnt.acl_id            ,
            'mapped to RACF' msgType msgName 'already exists in the'  ,
            aTypeMsg 'acl of' rpath"."                                ,
            'Its access remains unchanged.'
      End
      noCopy = 1
      Leave
    End                            /* Entry already exists           */
  End                           /* For each target acl entry         */

  /*******************************************************************/
  /* If the xID from the source acl entry is mappable, and does      */
  /* not already have a target acl entry, then add the source acl    */
  /* entry to our intermediate acl.                                  */
  /*******************************************************************/
  If noCopy = 0 Then Do         /* Must copy source acl entry        */
    'aclupdateentry iacl fromEnt.'
    changes = changes + 1       /* Increment number of entries       */
    iNames.changes = msgName    /* Update corresponding names stem   */
    iNames.0 = changes          /* Save updated count in iNames stem */
  End                           /* Must copy source acl entry        */
End                             /* For each source (FROM) acl entry  */
Return changes                  /* Return number of entries to copy  */

/* ----------------------------------------------------------------- */

buildIdStems:
/*********************************************************************/
/* Build list(s) of information about the values specified on the    */
/* ID keyword.                                                       */
/*                                                                   */
/* Input:                                                            */
/*      - idVal: Global variable containing the value(s)             */
/*        specified by the user on the ID keyword.                   */
/*                                                                   */
/* Output:                                                           */
/*      - permName : stem of the actual values specified             */
/*      - permType : stem of the value types (user or group)         */
/*      - permID   : stem of the UID or GID value that permName      */
/*                   maps to                                         */
/* Notes:                                                            */
/*      - Only UNIX users and groups are returned. If an ID value    */
/*        does not have an OMVS segment with a UID/GID, a message    */
/*        is issued and it is omitted from the output stems.         */
/*                                                                   */
/*********************************************************************/
    /*****************************************************************/
    /* Loop through each value specified for ID and map the names    */
    /* to UIDs/GIDs.                                                 */
    /*****************************************************************/
    Do i = 1 to Words(idVal)  /* For each ID value                   */

      /***************************************************************/
      /* Determine if the ID value is a user or a group, and         */
      /* indicate that in the permType stem.  Place the mapped       */
      /* UID/GID into the corresponding position of the permID stem. */
      /* An unmappable name results in a message and it is simply    */
      /* omitted from the stems.                                     */
      /***************************************************************/
      'getpwnam' Word(idVal,i) 'pw.'
      If retval > 0 Then Do   /* Success */
        permName.i = Word(idVal,i)
        permType.i = ACL_ENTRY_USER
        permID.i   = pw.PW_UID
      End
      Else Do
        'getgrnam' Word(idVal,i) 'gr.'
        If retval > 0 Then Do   /* Success */
          permName.i = Word(idVal,i)
          permType.i = ACL_ENTRY_GROUP
          permID.i   = gr.GR_GID
        End
        Else Do
          say 'Unable to map' Word(idVal,i) 'into a UID or GID.',
              'The name is ignored.'
          Iterate           /* Continue processing ID values         */
        End
      End
      /***************************************************************/
      /* Increment the number of values in each stem.                */
      /***************************************************************/
      permName.0 = permName.0 + 1
      permType.0 = permType.0 + 1
      permID.0   = permID.0 + 1
    End

    /***************************************************************/
    /* If no values were mappable, set a failing return code.      */
    /***************************************************************/
    If permName.0 = 0 Then Do
      say 'None of the specified ID values could be mapped',
          'to a UNIX identity. Permissions are unchanged.'
      execRc = 4
    End
  Return execRc  /* buildIdStems */

/* ----------------------------------------------------------------- */

validateFrom:
/*********************************************************************/
/* procedure: validateFrom                                           */
/*                                                                   */
/* input:  The following global variables set by processKeywords     */
/*         - fromVal                                                 */
/*         - ftypeVal                                                */
/*         - ftypeMsg                                                */
/*         - ftypeCode                                               */
/*                                                                   */
/* output: - On success, the sacl variable contains the acl          */
/*           retrieved from the FROM path name. This acl must be     */
/*           freed before OPERMIT terminates.                        */
/*         - A return code:                                          */
/*           0: success                                              */
/*           4: FROM object does not contain acl type requested      */
/*           8: terminating error                                    */
/*                                                                   */
/* Notes:  - The inability to locate the target object, or the       */
/*           absence of the desired acl type on that object,         */
/*           are considered terminating errors.                      */
/*                                                                   */
/*********************************************************************/
  vfRc = 0

  /*******************************************************************/
  /* Issue stat() against source (FROM) object so we have            */
  /* information about it.                                           */
  /*******************************************************************/
  "stat (fromVal) fstat."
  /* Check for success.                                              */
  If retval = -1 then Do
    vfRc = 8  /* terminating error */
    Select /* errno */
      When errno = ENOENT Then
        say 'The specified FROM path does not exist'
      When errno = EACCES Then Do
        Say "You are not authorized to reach FROM path" fromVal"."

        /**************************************************************/
        /* Now, for extra credit, we will check for search access to  */
        /* the directory components of the path name, since that is a */
        /* common cause of error, and display the first such directory*/
        /* to which the user is not authorized. (There is no sense in */
        /* continuing beyond that point because they will all yield a */
        /* failure even if search access is present.)                 */
        /**************************************************************/
        checkpath = ''  /* The path to check */
        workpath = fromVal /* A working copy of the input path */
        Do Forever
          idx = Pos('/',workpath)
          If idx = 0 Then /* no more slashes means we are finished   */
            leave
          checkpath = checkpath || Substr(workpath,1,idx)
          workpath = Substr(workpath,idx+1) /* Lop off head */

          "access (checkpath)" X_OK

          if retval = -1 then do
            say "You do not have search access to" checkpath
            Leave
          End
        End
      End /* EACCES */
      Otherwise Do
        say "Error locating FROM object.",
            " Stat() retval =" retval "errno =" ,
             errno "errnojr =" errnojr
      End
    End /* Select errno*/
    say "Permissions are unchanged."
    Signal VFOUT
  End /* retval = -1 */

  /*******************************************************************/
  /* If the FROM path is not a directory, then flag use of FMODEL    */
  /* and DMODEL suboperands of FTYPE.                                */
  /*******************************************************************/
  If fstat.ST_TYPE /= S_ISDIR &,
     (ftypeVal = 'DMODEL' | ftypeVal = 'FMODEL') Then Do
    say 'An FTYPE value of DMODEL or FMODEL can only be specified',
        'when the FROM value is a directory.'
    vfRc = 8
    Signal VFOUT
  End

  /*******************************************************************/
  /* If the FROM path does not contain the acl type requested,       */
  /* issue a message, and let processing continue (vfRc=4).          */
  /*******************************************************************/
  If ftypeVal = 'ACL'    & fstat.ST_ACCESSACL = 0 |,
     ftypeVal = 'DMODEL' & fstat.ST_DMODELACL = 0 |,
     ftypeVal = 'FMODEL' & fstat.ST_FMODELACL = 0 Then Do
    say 'FROM object has no' ftypeMsg 'acl.'
    say 'Processing continues.'
    vfRc = 4
    Signal VFOUT
  End

  /*******************************************************************/
  /* Get the FROM acl.                                               */
  /*******************************************************************/
  'aclinit sacl'                    /* init var to hold source acl   */
  'aclget sacl (fromVal)' (ftypeCode)     /* get the access acl */

VFOUT:
Return vfRC                     /* validateFrom                      */

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
  Upper token
  /*******************************************************************/
  /* If the keyword is "FROM" and the path name is long enough that  */
  /* the keyword could never fit in a single line, then replace it   */
  /* with a smaller fake value and continue.                         */
  /*******************************************************************/
  If Substr(token,1,4) = "FROM" & Length(token) > lineLen Then
    token = "from(<path>)"                      /* Use placeholder   */
  Else
    token = Strip(Word(saveKwds,kNum),Both," ") /* Restore case      */
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
