Creating usrpasswd Files from Class Lists
-----------------------------------------

This is placeholder for a real script.

In vim, the following works relatively well:

```
%s/\(^.\{-} \?\(\w\+\), \(\w\)\w\+ \?.\?\.\?.*\)\tA00\(\d\d\d\d\d\d\)/\L\3_\2\E:\4:::\1,,,,:\/home\/student\/\L\3_\2\E:/
%s/\(:::.*\)\@<=,\(.*,,,,:\)\@=//
```


TODO
----

- mimic functionality of the above
- check for duplicate user names in output
- check for existing/duplicate users on server
- enable secondary user name generation scheme (to handle duplicates)
- trim out weird characters for usernames
- take path and shell values are optional arguments
