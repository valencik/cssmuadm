from IPython.lib import passwd
import sys, string, os

myPass = str(sys.argv[1]) 
myHash = passwd(myPass)
print(myHash)
