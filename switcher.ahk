;******************************************************************************
;******************        LAST UPDATE 2014/3/3 - 12:30 AM         ************* 
;******************                VERSION 0.01                   *************
;******************************************************************************
;******************************************************************************
;******************************************************************************
;*****                            TO DO LIST                              *****
;*****     X-GUI for data entry                                            ****
;*****      -API integrated shutdown command With always kill option       ****
;*****     X-CUDAminer / CGWatcher / CGMiner selection ddl                 ****
;*****     X-allow closing when runonce is going on                        ****
;*****     X-boxes around stop and config                                  ****
;*****      -allow scrolling in config screen 2                            ****
;*****     X-allow open config screen again when cancelled                 ****
;*****     X-save JSON to a var so it can be used                          ****
;*****      -Add pause button                                              ****
;*****      -Add Switch Now Button                                         ****
;*****                                                                     ****
;*****                                                                     ****
;*****                                                                     ****
;******************************************************************************
;******************************************************************************


;******************************************************************************
;***********************  Establish Universal Settings  ***********************
;******************************************************************************
#NoEnv  							;Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  								;Enable warnings to assist with detecting common errors.
#SingleInstance force				;Ensures only one copy of this can run at a time
SendMode Input  					;Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  		;Ensures a consistent starting directory.
SetTitleMatchMode, 2				;Title matching uses any part of the title, not just the beginning
DetectHiddenWindows, on				;Will allow checking for miner windows when hidden by CGWatcher
SetBatchLines 20ms					;ensures the program cannot use too much CPU time... it will pause for 10ms every 20ms of running
SetControlDelay 1					;sends a very short delay after every command, again ensuring no over-utilization of CPU time
SetKeyDelay 1, 1					;probably not used in this script, but time of "send" commands... delay, press duration
SetWinDelay 20						;sends a delay after each "ifwinactive" type command -- gives windows time to respond before the script continues


;******************************************************************************
;***********************  Establish specific Variables  ***********************
;******************************************************************************


inifile=switcher.ini				;path to our INI file
guiy=20								;y height to add to gui windows
xpos=10								;Set starting point of X for GUI Windows
ypos=10								;Set starting point of Y for GUI Windows
configscreen=0						;set that we are not in the config screen
howmany=2							;how many algorithms are in use
temp=								;store an empty variable
cancel=0							;we don't want to start with cancelling things
status=Not Running					;Start off without running the program
fail=0								;nothing has failed yet

;******************************************************************************
;**************************  Start the Program ********************************
;******************************************************************************

main:
gosub, restorexy
ypos = % ypos + 10
xpos = % xpos + 20

gui, 2:add, pic, x%xpos% y%ypos%, images\robot-small.png
xpos = % xpos + 90
ypos = % ypos + 15
gui, 2:font, s36 w700, Comic Sans
gui, 2:add, Text,x%xpos% y%ypos%,Scrypt Profitability Switcher.
gui, 2:font, s12 w500, norm
ypos = % ypos + 100
xpos = % xpos - 100
Gui, 2:add, groupbox, vstatusheader x%xpos% y%ypos% h130 w715, %status%

;Add status info here
xpos = % xpos + 5
ypos = % ypos + 45
gui, 2:add, pic, x%xpos% y%ypos% h40 w-1 vscrypticon, images\green-up-small.png
xpos = % xpos + 20
ypos = % ypos - 15
gui, 2:add, text, x%xpos% y%ypos% vscrypttext, Scrypt Score %scryptscore%
xpos = % xpos - 25
ypos = % ypos + 70
gui, 2:add, pic, x%xpos% y%ypos% h40 w-1 vnscrypticon, images\red-down-small.png
xpos = % xpos + 20
ypos = % ypos - 15
gui, 2:add, text, x%xpos% y%ypos% vnscrypttext, nscrypt Score %nscryptscore%


xpos = % xpos + 75
ypos = % ypos + 50
gui, 2:add, groupbox,x%xpos% y%ypos% vstartbox h120 w110,
xpos = % xpos + 5
ypos = % ypos + 15
gui, 2:add, pic, x%xpos% y%ypos% gstart vstarticon, images\green-check-small.png
xpos = % xpos + 30
ypos = % ypos + 105
gui, 2:add, text, x%xpos% y%ypos% gstart, Start
xpos = % xpos + 165
ypos = % ypos - 125
gui, 2:add, groupbox, x%xpos% y%ypos% h120 w110 vstopbox,
xpos = % xpos + 5
ypos = % ypos + 15
gui, 2:add, pic, x%xpos% y%ypos% gstop, images\red-x-small.png
xpos = % xpos + 30
ypos = % ypos + 110
gui, 2:add, text, x%xpos% y%ypos% gstop, &Stop
ypos = % ypos - 125
xpos = % xpos + 165
gui, 2:add, groupbox,x%xpos% y%ypos% h120 w110 vchangeconfigbox,
xpos = % xpos + 5
ypos = % ypos + 15
gui, 2:add, pic, x%xpos% y%ypos% gchangeconfig vchangeconfigicon, images\config-small.png
xpos = % xpos + 30
ypos = % ypos + 110
gui, 2:add, text, x%xpos% y%ypos%, Config


gui, 2:show, h425 w750, Scrypt Switcher


ifnotexist %inifile%							;Create initial INI file if it doesn't exist
{
	tooltip, creating INI
		gosub, cleartooltip
	gosub createini
}

	tooltip, Reading INI						;Read the INI file to get ready to run
		gosub, cleartooltip
gosub iniread

if minertype=runonce								;Launch config screen if it was just created 
{
		tooltip, RunOnce Activated
			settimer, cleartooltip, 1500
	gosub changeconfig

return
}
	

winwaitclose, Scrypt Switcher
	gosub exitroutine
	
exitroutine:
2GuiClose:
{
	if cancel <> 1
	{
		gui, 1:Destroy
		gui, 2:Destroy
		ExitApp
	}
return
}


;******************************************************************************
;************************************  Start  *********************************
;******************************************************************************
start:
{
	Status=Starting Up
		gosub, updatestatusheader
	gosub, jsonread
	gosub, pulljson
	status=Starting the Miner
		gosub, updatestatusheader
	gosub, startminer
	status=Mining
		gosub, updatestatusheader
		

return
}

;******************************************************************************
;************************************  Stop   *********************************
;******************************************************************************
stop:
{
	status=Shutting Down
		gosub, updatestatusheader
	run %comspec% /c taskkill.exe /f /im cgminer.exe
	run %comspec% /c taskkill.exe /f /im cudaminer.exe
	run %comspec% /c taskkill.exe /f /im cgwatcher.exe
	settimer, pulljson, OFF
	status=Not Running
		gosub, updatestatusheader

return
}



;******************************************************************************
;************************************  Pause   *********************************
;******************************************************************************
pause:
{
	status=Mining but not switching algorithms
		gosub, updatestatusheader
	settimer, pulljson, OFF

return
}




;******************************************************************************
;***************************  Start the Miner     *****************************
;******************************************************************************
startminer:
{
	settimer, pulljson, %algo_normalchecktime%
	settimer, statusrefresh, 1000

	if algo_current = scrypt
		algo=1
	if algo_current = nscrypt
		algo=2


	if minertype=cgminer
	{
		run %comspec% /c taskkill.exe /f /im cgminer.exe
		sleep 100
		splitpath, confpath_%algo%,,,temp,,
		if temp = conf
			run % comspec . " /c " . minerpath_1 . " --config " . confpath_%algo%
		else
			run %comspec% /c %minerpath_1%
		
	}
	
	if minertype=cudaminer
	{
		run %comspec% /c taskkill.exe /f /im cudaminer.exe
		sleep 100
		run % comspec . " /c " . minerpath_%algo%
	}

	if minertype=cgwatcher
		msgbox this isn't built yet... sorry
		
return
}


;******************************************************************************
;**************************  keep status box up to date  **********************
;******************************************************************************
statusrefresh:
{
	status=Mining %algo_current% with %minertype%
		gosub, updatestatusheader
	;guicontrol, sub-command, variableID, param3
	;variables for display are  scrypticon, scrypttext, nscrypticon, nscrypttext
	;use green=scrypt or green=nscrypt for the icon
	
	guicontrol, text, scrypttext, %scryptscore%
	guicontrol, text, nscrypttext, %nscryptscore%
	if green=scrypt
	{
		guicontrol,, scrypticon, w40 h-1 images\green-up-small.png
		guicontrol,, nscrypticon, w40 h-1 images\red-down-small.png
	}
	else
	{
		guicontrol,, scrypticon, w40 h-1 images\red-down-small.png
		guicontrol,, nscrypticon, w40 h-1 images\green-up-small.png
	}
	
return
}

;******************************************************************************
;***************************  Make JSON Request     ***************************
;******************************************************************************
pulljson:
{
	Status=Requesting Update
		gosub, updatestatusheader
	urldownloadtofile, %apialgourl%%apikey%, temp.txt
	Status=Reading downloaded file
		gosub, updatestatusheader
	fileread, js, temp.txt
	Status=Parsing File
		gosub, updatestatusheader
	loop, parse, js, }
	{
	algo%A_Index% = % json(A_LoopField,"algo")
	score%A_Index% = % json(A_LoopField,"score")
	}
	Status=Parsed - Loading Variables
		gosub, updatestatusheader
	Status=Deciding Which Algo has priority and checking threshold
		gosub, updatestatusheader
	best=%algo1%
	by = % score1 - score2
	if by >= %algo_threshold%
		thresholdreach=1
	else
		thresholdreach=0
	Status=Writing new values to INI
		gosub, updatestatusheader

	gosub jsoniniupdate
	gosub checkchange
return
}

;******************************************************************************
;***************************  see if we need to switch coins ******************
;******************************************************************************
checkchange:
{
	if best <> %algo_current%
	{
		iniwrite, 1, %inifile%, algo, changed
		algo_changedcheck=1
		loop %algo_changedcheckmax%
		{
			iniread, temp, %inifile%, pull%A_Index%, best					;number of times the algorithm has been checked and been different
			if temp=%best%
				algo_chagnedcheck++
			msgbox,Line282 this needs work`n`n`n best%A_Index% is %temp%`n best current is %best%`n`nThis has been for %algo_changedcheck% rounds
		}
		iniwrite, %algo_changedcheck%, %inifile%, algo, changedcheck				;write new changed check value back to ini

		if (algo_changedcheck > %algo_chngedcheckmax% and thresholdreach = 1)
		{
			iniwrite, %best%, %inifile%, algo, current
			msgbox, Everything is aligned, we need to restart the miner
			gosub start
		}
	}	

return
}	

;******************************************************************************
;***************************  Write new JSON to ini ***************************
;******************************************************************************
jsoniniupdate:
{
	iniwrite, %best%, %inifile%, pull0, best
	if best<>%algo_best%
	{
		iniwrite, %best%, %inifile%, algo, algo_best
		iniwrite, 1, %inifile%, algo, algo_changed
	}
	iniwrite, %thresholdreach%, %inifile% , pull0, thresholdreach
	loop, %howmany%
	{
		iniwrite, % algo%A_Index%, %inifile%, pull0, algo%A_Index%		
		iniwrite, % score%A_Index%, %inifile%, pull0, score%A_Index%
	}
	
	if algo1=scrypt														;put stuff in variables for status updates
	{
		green=scrypt
		scryptscore=score1
		nscryptscore=score2
	}
	if algo1=nscrypt
	{
		green=nscrypt
		nscryptscore=score1
		scryptscore=score2
	}

	i=%algo_changedcheckmax%
	i2=%algo_changedcheckmax%
	pull_loop = 0
	loop, %algo_changedcheckmax%
	{
		temp = % howmany + 1
		loop, %temp%
		{
			iniread, tempalgo%pull_loop%_%A_Index%, %inifile%, pull%pull_loop%, algo%A_Index%
			iniread, tempscore%pull_loop%_%A_Index%, %inifile%, pull%pull_loop%, score%A_Index%
		}
		iniread, best%pull_loop%, %inifile%, pull%pull_loop%, best
		iniread, thresholdreach%pull_loop%, %inifile%, pull%pull_loop%, thresholdreach
		pull_loop++
	}
	i=%algo_changedcheckmax%
	i2=%algo_changedcheckmax%
	loop, %algo_changedcheckmax%
	{
		pull_loop=%A_Index%
		i--
		loop, %howmany%
		{
			iniwrite, % tempalgo%i%_%A_Index%, %inifile%, pull%i2%, algo%A_Index%
			iniwrite, % tempscore%i%_%A_Index%, %inifile%, pull%i2%, score%A_Index%
		}
		iniwrite, % best%i%, %inifile%, pull%i2%, best
		iniwrite, % thresholdreach%i%, %inifile% , pull%i2%, thresholdreach
		i2--
	}	
return
}

;******************************************************************************
;***************************  Change INI if needed  ***************************
;******************************************************************************
changeconfig:
{
	prevstatus=%status%
	Status=Editing Config
		gosub updatestatusheader
	
	
	;First window -- Choose algo's & type of miner
	configscreen=1
	gosub, restorexy
	
	gui, 1:add, groupbox, x%xpos% y%ypos% w185 h120, Algorithms Selection
	xpos = % xpos + 5
	ypos = % ypos + guiy
	
	gui, 1:add, text, x%xpos% y%ypos%, How Many Algorithms are you using?
	ypos = % ypos + guiy
	gui, 1:add, edit, disabled w50 x%xpos% y%ypos%,
	gui, 1:add, updown, vhowmany range2-10, 2
	ypos = % ypos + guiy + 10

	gui, 1:add, text, x%xpos% y%ypos%, Threshold to exeed before switching?
	ypos = % ypos + guiy
	gui, 1:add, edit, w50 x%xpos% y%ypos%,
	gui, 1:add, updown, valgo_threshold range0-100, 10
	ypos = % ypos + guiy

	xpos = % xpos + 25
	ypos = % ypos + guiy
	xpos = % xpos - 5
	gui, 1:add, groupbox, x%xpos% y%ypos% w130 h50, Miner Type
	xpos = % xpos + 5
	ypos = % ypos + guiy
	gui, 1:add, DropDownList, x%xpos% y%ypos% vminertype, CGWatcher|CGMiner||CUDAMiner
	xpos = % xpos - 60

	gosub, restorexy
	xpos = % xpos + 200
	
	xpos = % xpos - 5
	gui, 1:add, groupbox, x%xpos% y%ypos% w185 h170, Timer Settings
	xpos = % xpos + 5
	ypos = % ypos + guiy
	gui, 1:add, text, x%xpos% y%ypos%, How often to check profitablity?
	ypos = % ypos + guiy
	gui, 1:add, edit, x%xpos% y%ypos%,
	gui, 1:add, updown, valgo_normalchecktime range60-900, 120
	ypos = % ypos + guiy + 5
	gui, 1:add, text, x%xpos% y%ypos%, How often to check when`nthere is a change?
	ypos = % ypos + guiy + 10
	gui, 1:add, edit,  x%xpos% y%ypos%,
	gui, 1:add, updown, valgo_changedchecktime range30-300, 60
	ypos = % ypos + guiy + 5
	gui, 1:add, text, x%xpos% y%ypos%, Number of checks before switching?
	ypos = % ypos + guiy
	gui, 1:add, edit, x%xpos% y%ypos%,
	gui, 1:add, updown, valgo_changedcheckmax range1-30,5
	ypos = % ypos + guiy


	gosub, configbuttons
	
	gui, 1:Show, h410 w465, Update Screen 1
	winwaitclose, Update Screen 1

	;Second Config window -- Choose Miner Paths and Config Paths
	configscreen=2
	gosub, restorexy
	gosub, iniread

	if cancel = 0
	{

	if minertype=CGMiner
	{
		loop %howmany%
		{
			gui, 1:add, groupbox, x%xpos% y%ypos% w420 h100, Information for Algorithm %A_Index%
			xpos = % xpos + 5
			ypos = % ypos + guiy
			temp=% name_%A_Index%
			gui, 1:add, edit, x%xpos% y%ypos% w120 vname%A_Index% r1 disabled, %temp%
			ypos = % ypos + guiy + 10
			splitpath, minerpath_%A_Index%,,,temp,,
			if (temp = "exe" or temp = "bat")
				gui, 1:add, edit, w380 r1 x%xpos% y%ypos% vminerpath_%A_Index% -wantreturn -wanttab -wrap, % minerpath_%A_Index%
			else
				gui, 1:add, edit, w380 r1 x%xpos% y%ypos% vminerpath_%A_Index% -wantreturn -wanttab -wrap, Path to Miner
			xpos = % xpos + 385
			gui, 1:add, button, x%xpos% y%ypos% gselectpath%A_Index%, ...
			ypos = % ypos + guiy + 5
			xpos = % xpos - 385
			
			splitpath, confpath_%A_Index%,,,temp,,
			if temp<>conf
				gui, 1:add, edit, w380 r1 x%xpos% y%ypos% vconfpath_%A_Index% -wantreturn -wanttab -wrap, Path to Conf File
			else
				gui, 1:add, edit, w380 r1 x%xpos% y%ypos% vconfpath_%A_Index% -wantreturn -wanttab -wrap, % confpath_%A_Index%
			xpos = % xpos + 385
			loopnum=%A_Index%
			gui, 1:add, button, x%xpos% y%ypos% gselectconf%A_Index%, ...
			ypos = % ypos + guiy + 20
			xpos = % xpos - 390
		}
	}

	if minertype=CUDAMiner
	{
		loop %howmany%
		{
			gui, 1:add, groupbox, x%xpos% y%ypos% w420 h80, Information for Algorithm %A_Index%
			xpos = % xpos + 5
			ypos = % ypos + guiy
			temp=% name_%A_Index%
			gui, 1:add, edit, x%xpos% y%ypos% w120 vname%A_Index% r1 disabled, %temp%
			ypos = % ypos + guiy + 5
			splitpath, minerpath_%A_Index%,,,temp,,
			if temp = "bat"
				gui, 1:add, edit, w380 r1 x%xpos% y%ypos% vminerpath_%A_Index% -wantreturn -wanttab -wrap, % minerpath_%A_Index%
			else
				gui, 1:add, edit, w380 r1 x%xpos% y%ypos% vminerpath_%A_Index% -wantreturn -wanttab -wrap, Path to Miner - USE A BAT FILE
			xpos = % xpos + 385
			gui, 1:add, button, x%xpos% y%ypos% gselectpath%A_Index%, ...
			ypos = % ypos + guiy + 25
			xpos = % xpos - 390
		}



		
	}
	gosub, configbuttons
	gui, 1:Show, h410 w465, Update Screen 2
	winwaitclose, Update Screen 2
	}
	
	if cancel=0
	{
	;Third Config window -- Setup API login and information
	configscreen=3
	gosub, restorexy
	gosub, iniread

	gui, 1:add, groupbox, x%xpos% y%ypos% w430 h190, API Information
	xpos = % xpos + 5
	ypos = % ypos + guiy
	gui, 1:add, text, x%xpos% y%ypos%, Curretly we only support the API from 
	gui, 1:font, underline
	xpos = % xpos + 175
	gui, 1:add, text, x%xpos% y%ypos% cBlue glaunchtmb,TradeMyBit.com
	gui, 1:font, norm
	
	ypos = % ypos + guiy
	xpos = % xpos - 175
	gui, 1:add, text, x%xpos% y%ypos%, API Key:
	ypos = % ypos + guiy
	if apikey=
		gui, 1:add, edit,w400 r1 x%xpos% y%ypos% vapikey -wantreturn -wanttab -wrap,Enter your API key
	else
		gui, 1:add, edit,w400 r1 x%xpos% y%ypos% vapikey -wantreturn -wanttab -wrap,%apikey%
	ypos = % ypos + guiy + 10
	gui, 1:add, text, x%xpos% y%ypos%, Change Best Algo URL (Unsupported):
	ypos = % ypos + guiy
	gui, 1:add, edit,w270 r1 x%xpos% y%ypos% vapialgourl -wantreturn -wanttab -wrap,%apialgourl%

	ypos = % ypos + guiy + 5
	gui, 1:add, text, x%xpos% y%ypos%, Change Hash Info URL (Unsupported):
	ypos = % ypos + guiy
	gui, 1:add, edit,w270 r1 x%xpos% y%ypos% vapihashurl -wantreturn -wanttab -wrap,%apihashurl%


	gosub, configbuttons
		
	gui, 1:Show, h410 w465, Update Screen 3
	winwaitclose, Update Screen 3

	}

	if fail=1
	{
		fail=0
		gosub changeconfig
	}
	
	status=%prevstatus%
	gosub, updatestatusheader
	if status <> Not Running
		gosub start
	cancel=0
return
	
Cancel:
guiclose:
guiescape:
{
	cancel=1
	gui, 1:destroy
	status=%prevstatus%
	gosub, updatestatusheader
	gosub, exitroutine
return
}
	
Next:
done:
	gosub iniwrite
return

gosub, restorexy
return

configbuttons:
{
	gosub restorexy
	ypos = % ypos + 220
	xpos = % xpos + 15
	gui, 1:add, groupbox, x%xpos% y%ypos% h120 w415,
	ypos = % ypos + 10
	xpos = % xpos + 10
	gui, 1:add, pic, x%xpos% y%ypos%, images\config-small.png
	xpos = % xpos + 280
	gui, 1:add, pic, h105 w105 x%xpos% y%ypos%, images\BTC-Donations.png
	xpos = % xpos - 275
	ypos = % ypos + guiy + 10
	xpos = % xpos + 140
	if configscreen <> 3
		gui, 1:add, button, x%xpos% y%ypos% default giniwrite, &Next
	else
		gui, 1:add, button, x%xpos% y%ypos% default giniwrite, &Done
	xpos = % xpos + 50
	gui, 1:add, button, x%xpos% y%ypos% gcancel, &Cancel
	
	xpos = % xpos - 70
	ypos = % ypos + 55
	
	gui, 1:add, text, x%xpos% y%ypos%, Donations Very Appreciated!
	xpos = % xpos - 40
	ypos = % ypos + 33
	gui, 1:add, text, x%xpos% y%ypos%, BTC:
	xpos = % xpos + 25
	ypos = % ypos - 3
	gui, 1:add, edit, x%xpos% y%ypos% r1 w225, 1F3Ujp9ZoWyYA4iNPQtPbmJcrbJeMckCZW
	xpos = % xpos - 25
	ypos = % ypos + 28
	gui, 1:add, text, x%xpos% y%ypos%, LTC:
	ypos = % ypos - 3
	xpos = % xpos + 25
	gui, 1:add, edit, x%xpos% y%ypos% r1 w225, LT3unGLnK9NvLSQzMCeqz5Z2oirauqSx8y
	
return
}

selectpath:
{
	FileSelectFile, minerpath_%loopnum%, s3, ::{20d04fe0-3aea-1069-a2d8-08002b30309d},Select the Miner Executable (or .Bat file),*.exe;*.bat
	guicontrol,,minerpath_%loopnum%, % minerpath_%loopnum%
return
}

selectconf:
{
	FileSelectFile, confpath_%loopnum%, s3, ::{20d04fe0-3aea-1069-a2d8-08002b30309d},Select the conf file if in use,*.conf
	guicontrol,,confpath_%loopnum%, % confpath_%loopnum%
return
}


#include includes\selects.ahk

return
}


;******************************************************************************
;*******************  Store variables in .ini file       **********************
;******************************************************************************
iniwrite:
{
	gui, submit

	if configscreen=1
	{
		iniwrite, %minertype%, %inifile%, minertype, type							;which type of miner are we using 
		iniwrite, %howmany%, %inifile%, name, howmany								;how many algorithms to use
		iniwrite, %algo_changedcheckmax%, %inifile%, algo, changedcheckmax			;number of times to check before switching coins
		iniwrite, %algo_threshold%, %inifile%, algo, threshold						;threshold to exeed before switching
		temp = % algo_normalchecktime * 1000
		iniwrite, %temp%, %inifile%, algo, normalchecktime							;time between normal checks
		temp = % algo_changedchecktime * 1000
		iniwrite, %temp%, %inifile%, algo, changedchecktime							;time between checks when we're not mining the most profitable coin
	}	

	if configscreen=2
	{
		loop %howmany%
		{
			fail=1
			splitpath, minerpath_%A_Index%,,,temp,,
			if (minertype = "cgminer" and (temp = "exe" or temp = "bat"))
			{
				iniwrite, % minerpath_%A_Index%, %inifile% ,path, %A_Index%			;paths to miners files
				fail=0
			}
			if (minertype = "cudaminer" and temp = "bat")
			{
				iniwrite, % minerpath_%A_Index%, %inifile% ,path, %A_Index%			;paths to miners files
				fail=0
			}
			
			if % confpath_%A_Index%=Path to Conf File
			{
				iniwrite, -1, %inifile% ,confpath, %A_Index%						;paths to miners .conf files
				iniwrite, % name_%A_Index%, %inifile%, name, %A_Index%				;write name to the INI file
			}
			else
			{
				iniwrite, % confpath_%A_Index%, %inifile% ,confpath, %A_Index%		;paths to miners .conf files
				iniwrite, % name_%A_Index%, %inifile%, name, %A_Index%				;write name to the INI file
			}
		}
		if fail=1
			msgbox, You must select a valid .exe or .bat for your miner

	}

	if configscreen=3
	{
		iniwrite, %apikey%, %inifile%, api, key										;API Key to store
		iniwrite, %apialgourl%, %inifile%, api, algourl								;URL for best algo API
		iniwrite, %apihashurl%, %inifile%, api, hashurl								;URL for hash info API
	}
	
gosub, restorexy
gui, 1:destroy
return
}




;******************************************************************************
;*******************  Populate variables from .ini file  **********************
;******************************************************************************
iniread:
{
	iniread, howmany, %inifile%, name, howmany									;load how many algo's are in use
	iniread, minertype, %inifile%, minertype, type								;What type of miner we're using

	loop %howmany%
	{
		iniread, use_%a_index%, %inifile%, use, %a_index%						;which algorithms to use
		iniread, confpath_%a_index%, %inifile%, confpath, %a_index%				;paths to miners .conf files
		iniread, minerpath_%a_index%, %inifile% ,path, %a_index%				;paths to miners files
		iniread, priority_%a_index%, %inifile% ,priority, %a_index%				;priority for which time of algorithm
		iniread, name_%a_index%, %inifile%, name, %A_Index%						;Load the name of this algo
	}

	iniread, algo_current, %inifile%, algo, current								;which algorithm we are currently using
	iniread, algo_best, %inifile%, algo, best									;which algorithm is most profitable
	iniread, algo_changed, %inifile%, algo, changed								;record if the more profitable algorithm is different than last check
	iniread, algo_changedcheck, %inifile%, algo, changedcheck					;number of times the algorithm has been checked and been different
	iniread, algo_changedcheckmax, %inifile%, algo, changedcheckmax				;number of times to check before switching coins
	iniread, algo_normalchecktime, %inifile%, algo, normalchecktime				;time between normal checks
	iniread, algo_changedchecktime, %inifile%, algo, changedchecktime			;time between checks when we're not mining the most profitable coin
	iniread, algo_threshold, %inifile%, algo, threshold							;threshold to exeed before switching

	iniread, apikey, %inifile%, api, key										;Load the API Key
	iniread, apialgourl, %inifile%, api, algourl								;load the Best Algo api url
	iniread, apihashurl, %inifile%, api, hashurl								;load the Hash Speed api url
	
return
}


;******************************************************************************
;**************  Launch TradeMyBit Website         ****************************
;******************************************************************************

launchtmb:
{
	run http://www.trademybit.com
return
}


;******************************************************************************
;**************  Update Status Header bar          ****************************
;******************************************************************************

updatestatusheader:
{
	guicontrol,text,statusheader, %status%
return
}

;******************************************************************************
;**************  Popup box stating the function isn't ready yet  **************
;******************************************************************************

notavailable:
{
	msgbox, That function is not yet available
return
}


;******************************************************************************
;****************    Clear Tooltips, mostly used in debugging    **************
;******************************************************************************

cleartooltip:
{
	;sleep 1000
	tooltip, 
return
}


;******************************************************************************
;****************    Resets X&Y default locations for GUIs       **************
;******************************************************************************

restorexy:
{
	xpos=10
	ypos=10
return
}



;******************************************************************************
;***************************  Create INI if needed  ***************************
;******************************************************************************

createini:
{
	iniwrite, Runonce, %inifile%, minertype, type					;which type of miner are we using 
	
	iniwrite, efb360c8d7edd5f36c32a02795b702de42427070ccdcfe4cddea0912fb3a090f, %inifile%, api, key
	iniwrite, https://pool.trademybit.com/api/bestalgo?key=, %inifile%, api, algourl
	iniwrite, https://pool.trademybit.com/api/hashinfo?key=, %inifile%, api, hashurl
	
	iniwrite, 2, %inifile%, name, howmany
	iniwrite, scrypt, %inifile%, name, 1							;Name of the Scrypt Algorithms
	iniwrite, nscrypt, %inifile%, name, 2	
	
	loop 2
	{
	iniwrite, 1, %inifile%, use, %A_Index%					;which algorithms to use
	iniwrite, -1, %inifile% ,confpath, %A_Index%				;paths to miners .conf files
	iniwrite, -1, %inifile% ,path, %A_Index%					;paths to miners files
	}
	
	iniwrite, scrypt, %inifile%, algo, current							;which algorithm we are currently using
	iniwrite, scrypt, %inifile%, algo, best								;which algorithm is most profitable
	iniwrite, 0, %inifile%, algo, changed							;record if the more profitable algorithm is different than last check
	iniwrite, 0, %inifile%, algo, changedcheck						;number of times the algorithm has been checked and been different
	iniwrite, 5, %inifile%, algo, changedcheckmax					;number of times to check before switching coins
	iniwrite, 120000, %inifile%, algo, normalchecktime				;time between normal checks
	iniwrite, 60000, %inifile%, algo, changedchecktime				;time between checks when we're not mining the most profitable coin
	iniwrite, 15, %inifile%, algo, threshold						;More profitable coin must exeed this score to initiate switch
	
return
}


;******************************************************************************
;***************************  JSON READER           ***************************
;******************************************************************************

jsonread:
{
	#include includes\json_parse.ahk
return
}
