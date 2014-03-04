;******************************************************************************
;******************        LAST UPDATE 2014/3/4 - 4:15 PM         ************* 
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
;*****      -fix refresh timer display updates                             ****
;*****      -Add hotkeys to start/stop/etc...                              ****
;*****                                                                     ****
;******************************************************************************
;******************************************************************************


;******************************************************************************
;***********************  Establish Universal Settings  ***********************
;******************************************************************************
#NoEnv  							;Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  							;Enable warnings to assist with detecting common errors.
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
statusrefreshupdate=5				;how often to update the status display box
statusrefreshcountdowntime=5		;how often to update the status display box
statusrefreshcountdownupdate=1000	;how often to update the timer on the countdown of the status box


;******************************************************************************
;**************************  Start the Program ********************************
;******************************************************************************

ifnotexist %inifile%							;Create initial INI file if it doesn't exist
{
	tooltip, creating INI
		gosub, cleartooltip
	gosub createini
}

	tooltip, Reading INI							;Read the INI file to get ready to run
		gosub, cleartooltip
gosub iniread

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
xpos = % xpos + 5
ypos = % ypos + 25

;Add status info here
gui, 2:add, pic, x%xpos% y%ypos% h40 w-1 vscrypticon, images\green-up-small.png
xpos = % xpos + 25
ypos = % ypos + 10

statusxpos= % xpos
statusypos= % ypos
gui, 2:add, text, x%xpos% y%ypos% w350 vstatusrefreshtext, %algo1% %score1%`n`n`n%algo2% %score2%


xpos = % xpos + 450
ypos = % ypos - 35
statusrefreshxpos = % xpos
statusrefreshypos = % ypos
gui, 2:add, text, x%xpos% y%ypos% w130 vgarble, Refreshing in %statusrefreshcountdowntime%

xpos = % xpos - 450
ypos = % ypos + 40



xpos = % xpos - 25
ypos = % ypos + 40
gui, 2:add, pic, x%xpos% y%ypos% h40 w-1 vnscrypticon, images\red-down-small.png



xpos = % xpos + 105
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


if minertype=runonce								;Launch config screen if it was just created 
	gosub changeconfig
	

winwaitclose, Scrypt Switcher
	gosub exitroutine
	
exitroutine:
2GuiClose:
{
	if cancel <> 1
	{
		gui, 1:Destroy
		gui, 2:Destroy
		gosub killminers
		ExitApp
	}
return
}


onexit:
{
	msgbox,,,Shutting down,3
	gosub killminers
	
return
}

;******************************************************************************
;************************************  Start  *********************************
;******************************************************************************
start:
{
	if statusflag<>running
	{
		statusflag=running
		Status=Starting Up
			gosub, updatestatusheader
		gosub, jsonread
		gosub, pulljson
		status=Starting the Miner
			gosub, updatestatusheader
		gosub, startminer
		settimer, pulljson, %algo_checktime%
	}
	else
		msgbox,,,Already Running,5

return
}

;******************************************************************************
;************************************  Stop   *********************************
;******************************************************************************
stop:
{
	if statusflag<>stop
	{
		statusflag=stop
		status=Shutting Down
			gosub, updatestatusheader
			
		gosub, killminers
	
		settimer, pulljson, OFF
		settimer, statusrefresh, OFF
		settimer, statusrefreshcountdown, off
		status=Not Running
			gosub, updatestatusheader
	}
	else
		msgbox,,,Not Running,5

return
}


;******************************************************************************
;************************************  Pause  *********************************
;******************************************************************************
paused:
{
	if statusflag=running
	{
		statusflag=paused
		status=Mining but not switching algorithms
			gosub, updatestatusheader
		settimer, pulljson, OFF

	}
	else
		msgbox,,,Not Running,5

return
}

;******************************************************************************
;********************************  Swap Now   *********************************
;******************************************************************************
swapnow:
{
	if statusflag=running
		gosub swapalgo
	else
		msgbox,,,Not Running,5

return
}



;******************************************************************************
;***************************  Start the Miner     *****************************
;******************************************************************************
startminer:
{
	gosub, statusrefresh
	settimer, statusrefreshcountdown, OFF
	settimer, statusrefreshcountdown, %statusrefreshcountdownupdate%
	gosub killminers
	statusflag=running
	
	sleep 250

	if algo_current = scrypt
		algo=1
	if algo_current = nscrypt
		algo=2

	loop %howmany%																;setup paths for calling the miner
	{
		splitpath, minerpath_%A_Index%, filename_ext%A_Index%,filedir%A_Index%,fileext%A_Index%,filedrive%A_Index%
		splitpath, confpath_%A_Index%, confname_ext%A_Index%, confdir%A_Index%,confext%A_Index%,confdrive%A_Index%
	}

	SetWorkingDir filedir%algo%
	
	;msgbox,,, % "filepath is " . minerpath_%algo% . "`nconf path is " . confpath_%algo% . "`nconf extension is " . confext%algo%,25
	
	if minertype=cgminer
	{
		if confext%algo% = conf
		{
			temp = % minerpath_%algo%
			temp2 = % confpath_%algo%
			run "%temp%" --config "%temp2%"
			clipboard = "%temp%" --config "%temp2%"
			
			;msgbox,,, % "running with conf file `" . minerpath_%algo% . "` --config `" . confpath_%algo% . "`", 25
			;run % "`"" . minerpath_%algo% . "`" --config `"" . confpath_%algo% . "`""
			
		}
		else
		{
			;msgbox,,, % "running without conf file " . minerpath_%algo%, 25
			run % minerpath_%algo%		
		}
	}
	
	if minertype=cudaminer
	{
		sleep 100
		run % minerpath_%algo%
	}

	if minertype=cgwatcher
		msgbox this is not built yet... sorry
		
	SetWorkingDir %A_ScriptDir%
	
return
}



;******************************************************************************
;***************************  Kill running miners  ****************************
;******************************************************************************
killminers:
{
	loop %howmany%														;Kill previously running miners
	{
		splitpath, minerpath_%A_Index%, filename_ext%A_Index%,filedir%A_Index%,fileext%A_Index%,filedrive%A_Index%
		run % comspec . " /c taskkill.exe /f /im " . filename_ext%A_Index%
	}

return
}



;******************************************************************************
;**************************  keep status box up to date  **********************
;******************************************************************************
statusrefresh:
{
	gosub, iniread
	status=Mining %algo_current% with %minertype%
		gosub, updatestatusheader
	guicontrol,, statusrefreshtext,  %algo1% - %score1%`n`n`n%algo2% - %score2%
	
return
}

;******************************************************************************
;****************  Countdown till refresh in status box  **********************
;******************************************************************************
statusrefreshcountdown:
{
	statusrefreshcountdowntime--
	guicontrol, text, garble, Refresh in %statusrefreshcountdowntime%

	if statusrefreshcountdowntime <= 0
	{
		statusrefreshcountdowntime = %statusrefreshupdate%
		gosub statusrefresh
	}
																				;statusrefresh = routine to update full status box
																				;statusrefreshcountdown = routine to update status countdown
																				;statusrefreshtext = variable name for the body of the text in the status box
																				;statusrefreshcountdowntext = variable name for the text of the timer being counted down
																				;statusrefreshcountdowntime = variable containing the time until next full status refresh
																				;statusrefreshupdate = variable containing the time between full status refreshes
																				;statusrefreshcountdownupdate = time before countdown ticks (1000 ms)

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
		algo_thresholdreach=1
	else
		algo_thresholdreach=0
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
	gosub, iniread															;Load current Variables
	sleep 500
																			;Make sure that the current best has been best for the previous n checks and it's not flip-flopping
;	msgbox,,,Checked the JSON`nCurrent algo is %algo_current% - Best algo is %best%,2
	if best <> %algo_current%
	{
;		msgbox,,,We are not on the best algo,2
		algo_changedcheck = 0														;Set to zero so we can recount the value
;		msgbox,,, algo_changedcheck is %algo_changedcheck% (This should be 0),2
		loop %algo_changedcheckmax%
		{
			iniread, temp, %inifile%, pull%A_Index%, best					
			if temp=%best%
				{
;					msgbox,,,temp and best matched from loop%a_Index%`n`nadding one to algo_changedcheck (%algo_changedcheck%),2
					algo_changedcheck++
;					msgbox,,,algo_changedcheck is now %algo_changedcheck%,2
				}
;			msgbox,,, % "pull" . a_index . " = " . temp . "`, best = " best . "`n" . best . " has been best " . algo_changedcheck . " times`nwe're on loop " . a_index . " of " . algo_changedcheckmax,2
		}
;		iniwrite, %algo_changedcheck%, %inifile%, algo, changedcheck				;write new changed check value back to ini

;		msgbox,,,last check was that %algo_changedcheck% of the %algo_changedcheckmax% checks had been met, 2
		
		if algo_changedcheck >= %algo_changedcheckmax%
		{
			if algo_thresholdreach = 1
				gosub swapalgo
		}
	}	


return
}	



;******************************************************************************
;***************************  Logic to swap algo's  ***************************
;******************************************************************************
swapalgo:
{
	if statusflag<>paused
	{
		tooltip, Swapping algorithms. Miner will be back up in a moment
			settimer, cleartooltip, -5000
		iniwrite, %best%, %inifile%, algo, current
		gosub startminer
	}
return
}




;******************************************************************************
;***************************  Write new JSON to ini ***************************
;******************************************************************************
jsoniniupdate:
{
sleeptimer=250
;
;														tooltip, In JSON INI Update
;															sleep %sleeptimer%
;															gosub cleartooltip
;	
	iniwrite, %best%, %inifile%, pull0, best
	iniwrite, %A_Now%, %inifile%, pull0, time
;														tooltip, writing %best% to pull0, best
;															sleep %sleeptimer%
;															gosub cleartooltip
;	
	if best<>%algo_best%
	{
;														tooltip, Best is not the same as current best`n%best% <> %algo_best%`n`nnext two steps are in this check
;															sleep %sleeptimer%
;															gosub cleartooltip
;
;	
;														tooltip, writing %best% to INI file to store for Algo_Best
;															sleep %sleeptimer%
;															gosub cleartooltip
;
		iniwrite, %best%, %inifile%, algo, best
;		
;														tooltip, writing 1 to algo_changed because it has
;															sleep %sleeptimer%
;															gosub cleartooltip
;
		iniwrite, 1, %inifile%, algo, algo_changed
;
	}
;														tooltip, done with or skipped Best <> algo_Best
;															sleep %sleeptimer%
;															gosub cleartooltip
;
;														tooltip, writing if we reached the threshold %algo_thresholdreach%
;															sleep %sleeptimer%
;															gosub cleartooltip
;	
	iniwrite, %algo_thresholdreach%, %inifile% , pull0, thresholdreach
;
;														tooltip, Entering loop to store algo's to pull0 files
;															sleep %sleeptimer%
;															gosub cleartooltip
;
	loop, %howmany%
	{
;														tooltip, % "writing " . algo%A_Index% . " to pull0's algo " . algo%A_Index%
;															sleep %sleeptimer%
;															gosub cleartooltip
;
		iniwrite, % algo%A_Index%, %inifile%, pull0, algo%A_Index%		
;
;														tooltip, % "writing " . score%A_Index% . " to pull0 score " . score%A_Index%
;															sleep %sleeptimer%
;															gosub cleartooltip
;
		iniwrite, % score%A_Index%, %inifile%, pull0, score%A_Index%
	}
;	
;														tooltip, % "finished with pull0 loop"
;															sleep %sleeptimer%
;															gosub cleartooltip
;	
;	
	pull_loop = 0
;	
;														tooltip, % "Entering the Read Loop"
;															sleep %sleeptimer%
;															gosub cleartooltip
;
;	
	loop, %algo_changedcheckmax%
	{
		iniread, best%pull_loop%, %inifile%, pull%pull_loop%, best
		iniread, time%pull_loop%, %inifile%, pull%pull_loop%, time
		iniread, thresholdreach%pull_loop%, %inifile%, pull%pull_loop%, thresholdreach
;														tooltip, % "loaded variable best" . pull_loop . " with " . best%pull_loop% . "%`nloaded variable thresholdreach" . pull_loop . " with " . thresholdreach%pull_loop% . "`n`nNext loading algo&score loop"
;															sleep %sleeptimer%
;															gosub cleartooltip
;
;
		loop, %howmany%
		{
			iniread, tempalgo%pull_loop%_%A_Index%, %inifile%, pull%pull_loop%, algo%A_Index%
			iniread, tempscore%pull_loop%_%A_Index%, %inifile%, pull%pull_loop%, score%A_Index%
;														tooltip, % "loaded variable tempalgo" . pull_loop . "_" . a_index . " with " . tempalgo%pull_loop%_%a_index% . "%`nloaded variable tempscore" . pull_loop . "_" . a_index . " with " . tempscore%pull_loop%_%a_index%
;															sleep %sleeptimer%
;															gosub cleartooltip
		}
		pull_loop++
;		fileappend, Algo_changedcheckmax is %algo_changedcheckmax%`nBest%pull_loop% is %best0% or %best1% or %best2% or %best3% or %best4%, test.txt
	}
	
;	fileappend, `n`n`nDone with Read Loop`n`n`n
	i = 0
;														tooltip, % "entering write loop"
;															sleep %sleeptimer%
;															gosub cleartooltip
;
;
	loop, %algo_changedcheckmax%
	{
		pull_loop=%A_Index%
		iniwrite, % best%i%, %inifile%, pull%pull_loop%, best
		iniwrite, % time%i%, %inifile%, pull%pull_loop%, time
		iniwrite, % thresholdreach%i%, %inifile% , pull%pull_loop%, thresholdreach
;														tooltip, % "pull" . pull_loop . "`nbest was populated with " . best%i% . "`nThresholdreach was populated with " . thresholdreach%i%
;															sleep %sleeptimer%
;															gosub cleartooltip
;
		loop, %howmany%
		{
			iniwrite, % tempalgo%i%_%A_Index%, %inifile%, pull%pull_loop%, algo%A_Index%
			iniwrite, % tempscore%i%_%A_Index%, %inifile%, pull%pull_loop%, score%A_Index%
;														tooltip, % "variable tempalgo" . i . "_" . a_index . " set as " . tempalgo%i%_%a_index% . "stored in pull" . %pull_loop% . "`nvariable tempscore" . i . "_" . a_index . " set as " . tempscore%i%_%a_index% . "stored in pull" . %pull_loop%
;															sleep %sleeptimer%
;															gosub cleartooltip
;
;
		}
		i++
;
;		fileappend, Best%pull_loop% is %best0% or %best1% or %best2% or %best3% or %best4%, test.txt
	}	
		
return
}

;******************************************************************************
;***************************  Change INI from config **************************
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
	gui, 1:add, updown, valgo_checktime range60-900, 120
	ypos = % ypos + guiy
	gui, 1:add, text, x%xpos% y%ypos%, Number of checks before switching?
	ypos = % ypos + guiy
	gui, 1:add, edit, x%xpos% y%ypos%,
	gui, 1:add, updown, valgo_changedcheckmax range1-30,5
	ypos = % ypos + guiy + 20


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
		iniwrite, %minertype%, %inifile%, algo, minertype								;which type of miner are we using 
		iniwrite, %howmany%, %inifile%, algo, howmany									;how many algorithms to use
		iniwrite, %algo_changedcheckmax%, %inifile%, algo, changedcheckmax				;number of times to check before switching coins
		iniwrite, %algo_threshold%, %inifile%, algo, threshold							;threshold to exceed before switching
		iniwrite, % algo_checktime * 1000, %inifile%, algo, checktime					;time between normal checks
	}	

	if configscreen=2
	{
		loop %howmany%
		{
			fail=1
			splitpath, minerpath_%A_Index%,,,temp,,
			if (minertype = "cgminer" and (temp = "exe" or temp = "bat"))
			{
				iniwrite, % minerpath_%A_Index%, %inifile%, algo%A_Index%, minerpath	;paths to miners files
				fail=0
			}
			if (minertype = "cudaminer" and temp = "bat")
			{
				iniwrite, % minerpath_%A_Index%, %inifile%, algo%A_Index%, minerpath	;paths to miners files
				fail=0
			}
			
			if % confpath_%A_Index%=Path to Conf File
			{
				iniwrite, -1, %inifile%, algo%A_Index%, confpath						;paths to miners .conf files
				iniwrite, % name_%A_Index%, %inifile%, algo%A_Index%, name				;write name to the INI file
			}
			else
			{
				iniwrite, % confpath_%A_Index%, %inifile%, algo%A_Index%, confpath		;paths to miners .conf files
				iniwrite, % name_%A_Index%, %inifile%, algo%A_Index%, name		;write name to the INI file
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
;*******************  Populate variables from .ini file  **********************
;******************************************************************************
iniread:
{

	loop %howmany%
	{
		iniread, use_%a_index%, %inifile%, algo%A_Index%, use					;which algorithms to use
		iniread, confpath_%a_index%, %inifile%, algo%A_Index%, confpath			;paths to miners .conf files
		iniread, minerpath_%a_index%, %inifile%, algo%A_Index%, minerpath		;paths to miners files
		iniread, priority_%a_index%, %inifile%, algo%A_Index%, priority			;priority for which time of algorithm
		iniread, name_%a_index%, %inifile%, algo%A_Index%, name					;Load the name of this algo
	}

	iniread, howmany, %inifile%, algo, howmany									;load how many algo's are in use
	iniread, minertype, %inifile%, algo, minertype								;What type of miner we're using
	iniread, algo_current, %inifile%, algo, current								;which algorithm we are currently using
	iniread, algo_best, %inifile%, algo, best									;which algorithm is most profitable
	iniread, algo_changed, %inifile%, algo, changed								;record if the more profitable algorithm is different than last check
;	iniread, algo_changedcheck, %inifile%, algo, changedcheck					;number of times the algorithm has been checked and been different
	iniread, algo_changedcheckmax, %inifile%, algo, changedcheckmax				;Number of times to exceed value before switching.
	iniread, algo_checktime, %inifile%, algo, checktime							;time between normal checks
	iniread, algo_threshold, %inifile%, algo, threshold							;threshold to exceed before switching

	iniread, apikey, %inifile%, api, key										;Load the API Key
	iniread, apialgourl, %inifile%, api, algourl								;load the Best Algo api url
	iniread, apihashurl, %inifile%, api, hashurl								;load the Hash Speed api url
	
	loop %changedcheckmax%
	{
		iniread, best%A_Index%, %inifile%, pull%A_Index%, best
		iniread, thresholdreache%A_Index%, %inifile%, pull%A_Index%, thresholdreach
		temp=%A_Index%
		loop %howmany%
		{
			iniread, algo%A_Index%, %inifile%, pull%temp%, algo%A_Index%
			iniread, score%A_Index%, %inifile%, pull%temp%, score%A_Index%
		}
	}
	
return
}


;******************************************************************************
;***************************  Create INI if needed  ***************************
;******************************************************************************

createini:
{
	iniwrite, efb360c8d7edd5f36c32a02795b702de42427070ccdcfe4cddea0912fb3a090f, %inifile%, api, key
	iniwrite, https://pool.trademybit.com/api/bestalgo?key=, %inifile%, api, algourl
	iniwrite, https://pool.trademybit.com/api/hashinfo?key=, %inifile%, api, hashurl
	
	

	loop 2
	{
	iniwrite, 1, %inifile%, algo%A_Index%, use						;If this algorithm should be used or not
	iniwrite, -1, %inifile%,algo%A_Index%, confpath					;paths to miners .conf files
	iniwrite, -1, %inifile%,algo%A_Index%, minerpath				;paths to miners files
	iniwrite, %A_Index%, %inifile%, algo%A_Index%, priority			;Set priority for Algorithms
	}
	
	iniwrite, scrypt, %inifile%, algo1, name						;Name of the 1st Algo (scrypt)
	iniwrite, nscrypt, %inifile%, algo2, name						;Name of the 2nd Algo (nscrypt)

	iniwrite, Runonce, %inifile%, algo, minertype					;which type of miner are we using 
	iniwrite, 2, %inifile%, algo, howmany							;How many algorithms are in use
	iniwrite, scrypt, %inifile%, algo, current						;which algorithm we are currently using
	iniwrite, scrypt, %inifile%, algo, best							;which algorithm is most profitable
	iniwrite, 0, %inifile%, algo, changed							;record if the more profitable algorithm is different than last check
	iniwrite, 0, %inifile%, algo, changedcheck						;number of times the algorithm has been checked and been different
	iniwrite, 5, %inifile%, algo, changedcheckmax					;number of times to check before switching coins
	iniwrite, 120000, %inifile%, algo, checktime					;time between checks
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
