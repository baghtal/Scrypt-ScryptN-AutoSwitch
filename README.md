Scrypt-ScryptN-AutoSwitch
=========================

An Autohotkey scrypt to watch an API and switch between profiles for your miner between Scrypt and Scrypt-N functions. Built for use with CGwatcher, but i plan to extend it to include functions for your own .bat files as well.

Thanks to: 
  -https://github.com/neurocis/coinvert for some ideas relating to the API
  -clubbby for the insipration
  -Paulbjl2 for some common sense checks and good ideas
  -http://www.clker.com/ for the free clipart :D
  
  This version works with CGMiner / SGMiner / etc... or with CUDA Miner. Nothing has been build for CGWatcher yet...

-Outline of work to do:
1. JSON parse to check the API
  -Need Var input for API key
  -Need #Include & Credit due to JSON parser

2. Output which coin is more profitable Scrypt or Scrypt N
  -Need .ini file or other record of which is more profitable and timestamp
  -need loop -- check multiple times, don't switch for x minutes
  -need variable, how many positive checks before making the switch?
  -Delay between checks

3. Variable to select CGWatcher, or .bat file select
  -Store .exe location and create .bat file On the fly with given options?
  -Load the profiles & Orders, and allow selection for reordering preferences. Then restart CGWatcher? Is there a way to restart the miner and have CGWatcher load profiels again without a restart?

4. GUI
  -GUI to make this all pretty

5. .exe compile


When i'm out of Alpha I'll provide compiled versions in the mean time you can use AHK's AHK to EXE compiler -- http://www.autohotkey.com/docs/Scripts.htm#ahk2exe
