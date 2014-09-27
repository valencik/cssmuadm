A Failed Moodle Upgrade
=======================

> September 26th 2014

##Mistakes
Not making backups.  
Not making a snapshot of the VM.  
Seriously...  

##The install
Moodle 2.7.1 was installed on Ubuntu 14.04 via the [00-Install-Moodle.sh](00-Install-Moodle.sh) script.  
(Namely, /var/www/moodle was produced by a shallow git clone from `MOODLE_27_STABLE`)  
No 3rd party plugins were installed, and no really exotic configurations were made.  

##The upgrade
To upgrade the moodle code I simply did the following:  
```
cd /var/www/moodle
git fetch
git pull
```
Then I browsed to the web interface at http://moodle.cs.smu.ca and followed the instructions.  
From what I recall, things seems to run smoothly.    
The database was converted, and two plugins along with the main site were updated successfully.  
Then, after clicking continue, the page would load the following error:  
**Coding error detected, it must be fixed by a programmer: File store path does not exist and can not be created.**

##Searching
Unfortunately, my googlefu returns very little on this error.  
I created a forum post on moodle.org:
https://moodle.org/mod/forum/discuss.php?d=270902

Thankfully the error message was unique in the codebase.
```bash
root@moodle:/var/www/moodle# grep -inr "File store path does not exist and can not be created." *
cache/stores/file/lib.php:642:                throw new coding_exception('File store path does not exist and can not be created.');
```
I now had the [exact line of code that threw the error](https://github.com/moodle/moodle/blob/master/cache/stores/file/lib.php#L642).
Time to work backwards.

So, `make_writable_directory()` is failing, after `is_writable()` fails, when something calls `ensure_path_exists()`.  
Admittedly, I did a decent amount of poking around and reading the source before fixing the issue.  
I can't state enough how useful grepping for function calls and declarations is.  
And thankfully, the moodle code is actually well commented.

##Solution
My PHP skills are non existent. 
So to do what I wanted to do, I actually had to look up a PHP hello world.  
And then finally the [`Print()`](http://php.net/manual/en/function.print.php) function.  

I simply added a `print` statement above the `coding_exception()` line so I could see the path causing the issue.
```php
if (!make_writable_directory($this->path, false)) {
                $andrewsPath = $this->path;
                print "andrewsPath is $andrewsPath";
                throw new coding_exception('File store path does not exist and can not be created. andrewsPath: $andrewsPath');
            }
```
Then upon refreshing the moodle page I got a message stating the path that was failing the writable checks.
`srv/moodledata/cache/cachestore_file/default_application/core_config/`

A simple `chown -R www-data /srv/moodledata` fixed everything.

I had previously checked `/srv/moodledata` and several further down directories to find the permissions were as expected, readable and writable by www-data.  
However I missed three files in `srv/moodledata/cache/cachestore_file/default_application/core_config/` which had changed to root:root with timestamps suggesting it happened during the upgrade.

##Lesson
Make backups, you idiot.  
Take snapshots, you idiot.
