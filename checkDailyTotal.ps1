# Config -- Edit Here 
$lunch_hour_min = Get-Date '10:25' # This assumes you won't take lunch before 10:25 am
$lunch_hour_max = Get-Date '13:30' # This assumes you won't take lunch after 1:30 pm
$lunch_break_minimum = '25' # This assumes you won't take a lunch break shorter than 25 minutes
$run_notification = [bool]1 # Setting this to 1 will send a windows notification, setting to 0 will print to the command line
# End Config

$path = ".\userlog.csv"
$debug_prints = [bool]0

$date = get-date -format "MM-dd-yyyy"
$current_time = get-date -format "HH:mm:ss"
$csv = Import-Csv -Header Date,User,Type,Time -path $path

$found_start_time = [bool]0
$found_lock_time = [bool]0
foreach($line in $csv)
{ 
    if(($line.Date -eq $date) -and (!$found_start_time))
    {
        $elapsed_time = [datetime]$current_time - [datetime]$line.Time
        $found_start_time = [bool]1
        # Only take the first instance of time (Start of the work day)
    }
    if(($line.Date -eq $date) -and ($line.Type -eq "Locked"))
    {
        $locked_time = [datetime]$line.Time
        $found_lock_time = [bool]1
    }
    if(($line.Date -eq $date) -and ($line.Type -eq "Unlocked") -and ($found_lock_time))
    {
        $unlocked_time = [datetime]$line.Time
        $break_time = $unlocked_time - $locked_time
        if($debug_prints) { Write-Output "Break found: $break_time.Minutes" }
        $found_lock_time = [bool]0
        if($locked_time -ge $lunch_hour_min -and $locked_time -le $lunch_hour_max )
        {
            if($break_time.Minutes -ge $lunch_break_minimum)
            {
                $lunch_break_time = $break_time
                if($debug_prints) { Write-Host ("Possible Lunch Break Found",$lunch_break_time.Minutes) -Separator ":" -ForegroundColor Blue -BackgroundColor White }
            }
        }
    }
}
if($run_notification)
{
    Add-Type -AssemblyName System.Windows.Forms
    $global:balmsg = New-Object System.Windows.Forms.NotifyIcon
    $path = (Get-Process -id $pid).Path
    $balmsg.Icon = ".\clock.ico"
    # $balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
    # $balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
    $balmsg.BalloonTipText = "You've been working for $formatted_working_time, You've been in the office for $formatted_office_time"
    $balmsg.BalloonTipTitle = "TimeTracker"
    $balmsg.Visible = $true
    $balmsg.ShowBalloonTip(20000)
}
else
{
    Write-Host ("Time at the office",$elapsed_time.hours,$elapsed_time.Minutes ) -Separator ":" -ForegroundColor Blue -BackgroundColor White
    $working_time = $elapsed_time - $lunch_break_time
    $formatted_working_time = $working_time.ToString('hh\:mm');
    $formatted_office_time = $elapsed_time.ToString('hh\:mm');
    Write-Host ("Time actually working:", $formatted_working_time ) -Separator " " -ForegroundColor Red -BackgroundColor White
}
