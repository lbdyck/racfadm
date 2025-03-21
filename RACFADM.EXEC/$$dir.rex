*---------------------------------------------------------------------*
*                       RACFADM - REXX Programs                       *
*---------------------------------------------------------------------*

  Member      Subject                   Description
 --------  -------------  --------------------------------------------
 $$DIR     Directory      Document members
 $STUB     Invocation     Can place rexx in site's REXX dataset
 LC        Edit Macro     RACDCERT LIST(LABEL('labelname')) ID(userid)
                          on User Profile CERTS/RINGS command output
 LR        Edit Macro     RACDCERT LISTRING(*) ID(userid)
                          on User Profile CERTS/RINGS command output
 OPERMIT   IBM TSO Cmd    Unix Access Control List, like PERMIT
 ORALTER   IBM TSO Cmd    Unix Security Attribute, like ALTER
 ORLIST    IBM TSO Cmd    Unix Dir/File Security, like RLIST
 RACFADM   Software       Dynamically allocate and invoke software
 RACFADMC  Software       Check RACFADM version with GitHub version
 RACFALTD  Dataset        Alter selected dataset segments
 RACFALTG  Group          Alter selected group segments
 RACFALTU  User           Alter selected user segments
 RACFDCON  Group          Sets the group connection display option
 RACFPWPH  PassType       Word or Phrase Report
 RACFCERT  CertAuth       Display Digital Certificates, menu opt CA
 RACFCHKP  User           Check the days until the password changes
 RACFCLOG  Documentation  Determine LOG type (rc=0 SYSLOG, rc=1 OPERLOG)
 RACFCLSA  Authorization  Display authorization on profile, menu opt 9
 RACFCLSG  Class          Extract generic class profiles
 RACFCLSR  Class          Display class profiles, menu option 4
 RACFCLSS  Class          Search and display classes
 RACFCMDS  Commands       Execute/save/display TSO RACF commands
 RACFCOPU  User           Clone a User Profile, (line cmd K)
 RACFDB    Database       Display RACF database info, menu option 8
 RACFDCER  User           Sets the Digital Certificate indicator
 RACFDSEP  User/Group     Sets the date separator character
 RACFDSL   DSList         Invoke DSLIST on ALTLIB/LIBDEF DSNs, opt D
 RACFDSN   Dataset        Display dataset profiles
 RACFEMAC  Edit Macro     View/edit, turn off highlighting
 RACFEMST  Edit Macro     View/edit, position to SETROPTS section
 RACFENQS  Enqueues       Display enqueues on ALTLIB/LIBDEF dsns, opt E
 RACFGEN   Generate       Generate profile source, menu option G
 RACFGRP   Group          Display group profiles, menu option 2
 RACFGTRE  Group Tree     Execute/display DSMON group tree rpt, opt 6
 RACFHELP  Help           Display TSO HELP on RACF commands
 RACFIBM   IBM's RACF     RACF Menu options: System, RRSF, Certificates
 RACFLOG   Documentation  Display changes/issues/isplog, opt C/I/L
 RACFMRUN  Edit Macro     Display MSG line about RACRUN
 RACFMVS   Showmvs        Execute/display Showmvs RACF data, menu opt 7
 RACFMSG   Messages       RACF messages, menu option M
 RACFMSGC  Message        Display 'Confirm Request' panel
 RACFMSGS  Message        Display error message
 RACFNOTE  Edit Macro     Display MSG and NOTE lines in menu option 1
                          CERTS and RINGS command output
 RACFOMVS  OMVS Commands  Exec RACF OMVS cmds (OPERMIT/ORALTER/ORLIST)
 RACFPRMS  Parameter      Display RACF parameters, menu option 7
 RACFPROF  Profile        Execute line cmd 'P', extract/display profile
 RACFPSWD  Password       Reset userid password (menu opt 5/linecmd PW)
 RACFPUTL  Commands       Called by RACFCMDS, display command at top
 RACFRING  User           Display Digital Rings
 RACFRPTS  Reports        RACF reports, menu option R
 RACFRVER  Version        Sets the version for this application
 RACFSETD  Settings       Set default settings (0) when RACFADM invoked
 RACFSETG  Settings       Customize settings, menu option 0
 RACFUSR   User           Display userid profiles, menu option 1
 RACFUSRT  User           Add, delete and change TSO userid
 RACFUSRX  User           Userid cross reference report (line cmd X)
 RACFUSRY  User           Userid dsn/rsrc access report (line cmd Y)
 RACRUN    Edit Macro     Run RACF commands in Edit buffer

 Notes
   - Class is 'General Resources'
