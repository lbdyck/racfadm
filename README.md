# racfadm

## Introduction

RACF Administration (RACFADM) makes many security tasks simple.  
It lists user, group, data set, and general resource profiles by means 
of a user-friendly, menu-driven interface; it provides interactive 
modification of most fields.

Among its features are: connecting groups to a user, adding permissions, 
user authorization searching across classes, and displaying the group 
from which an authorization is granted.

Written in customizable Rexx, RACFADM includes an exec to automate creation 
of aliases or data sets when creating a new TSO user and can browse 
all RACF system options from a single, scrollable display.

To begin using execute the RACFADM member found in the EXEC library.

## Installation

Details and usage are found in the ISPF Dialog Tutorials accessed using the F1 key.

The package consists of 4 datasets:

        RACFADM.EXEC      - REXX Execs that drive the dialog
        RACFADM.MSGS      - ISPF Messages
        RACFADM.PANELS    - ISPF Panels
        RACFADM.SKELS     - ISPF Skeletons

Then to use the application execute the hlq.RACFADM.EXEC member 
RACFADM which all LIBDEF and ALTLIB the required libraries and 
then start the application.

Installation Suggestions:

1. Tailor the $STUB REXX code and then copy it into a library in the SYSEXEC
(or SYSPROC) allcation with the name RACFADM. This is modelled after Tom Conley's 
Dynamic ISPF approach.

2. If you have PLP installed (see PLPISPF in file 312 at cbttape.org) then add a menu item with these values:

  Application Name      RACFADM  A unique application name 1-8 characters
  Description           Easy RACF Administration ISPF Dialog
  ISPF Message Dataset
  ISPF Panel Dataset
  REXX EXEC Library     'hlq.RACFADM.EXEC'
  REXX SKELS Library
  Application Start (select one):
     Command %RACFADM
     Program             Parm
     ISPF Panel          Panel option

## Contributors

               Name                     Website
       ----------------------    ---------------------------
       Nico Rizzuto (Creator)    http://www.rizzuto.it
       Bruce Koss
       Bill Smith
       John Kalinich             http://www.cbttape.org/
       Lionel B. Dyck            http://github.com/lbdyck
                                 http://www.cbttape.org/
       Giovanni Andreani
       Steve Beaver
       Sam Golob
       Ed Jaffe
       Henri Kuiper
       Hailey Pratt
       Jim Turneer
       Bruce Wells
