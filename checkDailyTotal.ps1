# Config -- Edit Here 
$lunch_hour_min = Get-Date '10:25' # This assumes you won't take lunch before 10:25 am
$lunch_hour_max = Get-Date '13:30' # This assumes you won't take lunch after 1:30 pm
$lunch_break_minimum = '20' # This assumes you won't take a lunch break shorter than 25 minutes
$from_door_to_desk = '0:5' # How long it takes to walk into work, sit down and unlock the computer.
                            # This is/should be considered company paid time. Set to 0:0 to disable.
$run_notification = [bool]1 # Setting this to 1 will send a windows notification, setting to 0 will print to the command line
# End Config

$path = ".\userlog.csv"
$debug_prints = [bool]0

$date = get-date -format "MM-dd-yyyy"
$current_time = get-date -format "HH:mm:ss"
$csv = Import-Csv -Header Date,User,Type,Time -path $path

$found_start_time = [bool]0
$found_lock_time = [bool]0
$found_lunch_break = [bool]0
foreach($line in $csv)
{ 
    if(((get-date $line.Date) -eq (get-date $date)) -and (!$found_start_time))
    {
        $elapsed_time = [datetime]$current_time - [datetime]$line.Time
        $into_office_time = [datetime]$line.Time
        $found_start_time = [bool]1
        # Only take the first instance of time (Start of the work day)
    }
    if(((get-date $line.Date) -eq (get-date $date)) -and ($line.Type -eq "Locked"))
    {
        $locked_time = [datetime]$line.Time
        $found_lock_time = [bool]1
    }
    if(((get-date $line.Date) -eq (get-date $date)) -and ($line.Type -eq "Unlocked" -or $line.Type -eq "Logged in") -and ($found_lock_time))
    {
        $unlocked_time = [datetime]$line.Time
        $break_time = $unlocked_time - $locked_time
        if($debug_prints) { Write-Output "Break found: $break_time.Minutes" }
        $found_lock_time = [bool]0
        if($locked_time -ge $lunch_hour_min -and $locked_time -le $lunch_hour_max )
        {
            if($break_time.TotalMinutes -ge $lunch_break_minimum)
            {
                $lunch_break_time = $break_time
                if($debug_prints) { Write-Host ("Possible Lunch Break Found",$lunch_break_time.Minutes) -Separator ":" -ForegroundColor Blue -BackgroundColor White }
                $found_lunch_break = [bool]1
            }
        }
    }
}

if($found_lunch_break)
{
    $working_time = $elapsed_time - $lunch_break_time + [timespan]$from_door_to_desk
    $end_time = $into_office_time.AddHours(8) + $lunch_break_time - [timespan]$from_door_to_desk
}
else{
    $working_time = $elapsed_time + [timespan]$from_door_to_desk
    $end_time = $into_office_time.AddHours(8) - [timespan]$from_door_to_desk
}
$working_time = $working_time
$formatted_working_time = $working_time.ToString('hh\:mm');
$formatted_office_time = $elapsed_time.ToString('hh\:mm');
$formatted_into_office_time = $into_office_time.ToString('hh\:mm tt');
$formatted_break_time = $lunch_break_time.ToString('h\:mm');
$formatted_leave_time = $end_time.ToString('h\:mm tt');

if($run_notification)
{
    Add-Type -AssemblyName System.Windows.Forms
    $global:balmsg = New-Object System.Windows.Forms.NotifyIcon
    $path = (Get-Process -id $pid).Path
    $balmsg.Icon = ".\images\clock.ico"
    # $balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
    # $balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
    if($found_lunch_break)
    {
        $balmsg.BalloonTipText = 
        "You got into the office at $formatted_into_office_time.`n"+
        "You've been working for $formatted_working_time, with a $formatted_break_time" + "m long break. " +
        "You've been in the office for $formatted_office_time.`n" +
        "You can go home at: $formatted_leave_time."
    }
    else{
        $balmsg.BalloonTipText = 
        "You got into the office at $formatted_into_office_time.`n"+
        "You've been working (with no breaks) for $formatted_office_time`n" +
        "You can go home at: $formatted_leave_time.`n"
    }
    $balmsg.BalloonTipTitle = "TimeTracker"
    $balmsg.Visible = $true
    $balmsg.ShowBalloonTip(20000)
}
else
{
    if($found_lunch_break)
    {
        Write-Host ("Time at the office",$elapsed_time.hours,$elapsed_time.Minutes ) -Separator ":" -ForegroundColor Blue -BackgroundColor White
        Write-Host ("Time actually working:", $formatted_working_time ) -Separator " " -ForegroundColor Red -BackgroundColor White
    }
    else{
        Write-Host ("Time working, (no breaks)",$elapsed_time.hours,$elapsed_time.Minutes ) -Separator ":" -ForegroundColor Blue -BackgroundColor White
    }
}
