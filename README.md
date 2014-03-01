Scrypt-ScryptN-AutoSwitch
=========================

An Autohotkey scrypt to watch the API of TradeMyBit.com and switch between profiles for your miner between Scrypt and Scrypt-N functions. Built for use with CGwatcher, but i plan to extend it to include functions for your own .bat files as well.

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
