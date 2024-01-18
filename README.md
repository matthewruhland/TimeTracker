# Time Tracker App
Want to track when you can leave work, but don't want to remember when you got into the office or how long your lunch break was?  
Try out the automatic time tracker!  
All that needs to be done is set up a series of tasks in the windows Task Scheduler (examples in `/TaskSchedulerExports/`) to run the `logtime.cmd` script included.  
When the script runs it will save any Log in, Log out, Lock and Unlock times to a `userlog.csv` file.  
The PowerShell script included parses this csv and calculated the difference between now and the start of your day and the current time.  
It also calculates the time worked with lunch break removed from the total.  

### To do:  
- Create Powershell script to add tasks to task scheduler  
- Get `logtime.cmd` to create csv file and add headers automatically  


### References used:  
https://woshub.com/popup-notification-powershell/  
https://sumtips.com/how-to/windows-track-user-lock-unlock-login-logout-time/  
