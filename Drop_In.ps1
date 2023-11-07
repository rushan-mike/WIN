$wshell = New-Object -ComObject wscript.shell;
$wshell.AppActivate("LG-VPLP-DESK01 - VMware Workstation")
Sleep 1
#$wshell.SendKeys("a")
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait("a")


#Get-Process | Select MainWindowTitle,ProcessName,Id | where{$_.MainWindowTitle -ne ""}


# $wshell = New-Object -ComObject wscript.shell;
# $wshell.AppActivate("Untitled - Notepad")
# Sleep 1
# $wshell.SendKeys("a")

#@123qwe