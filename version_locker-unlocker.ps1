Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
function Hide-Console
{
    $consolePtr = [Console.Window]::GetConsoleWindow()
    #0 hide
    [Console.Window]::ShowWindow($consolePtr, 0)
}
Hide-Console
{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName 'Microsoft.VisualBasic, Version=10.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a'
Add-Type -AssemblyName PresentationCore,PresentationFramework

[System.Windows.Forms.Application]::EnableVisualStyles()

$acl = Get-Acl $PSScriptRoot\version.ini

#Removing all rights from users and admins
$Purge = New-Object System.Security.Principal.Ntaccount ("users")
$PurgeAdmin = New-Object System.Security.Principal.Ntaccount ("administrators")

#Allowing permissions
$Allow = New-Object System.Security.AccessControl.FileSystemAccessRule("users","FullControl","Allow")
$AllowAdmin = New-Object System.Security.AccessControl.FileSystemAccessRule("administrators","FullControl","Allow")

#Denying permissions
$AllowRead = New-Object System.Security.AccessControl.FileSystemAccessRule("users","Read","Allow")
$AllowReadAdmin = New-Object System.Security.AccessControl.FileSystemAccessRule("administrators","Read","Allow")
$Deny = New-Object System.Security.AccessControl.FileSystemAccessRule("users","Write","Deny")
$DenyAdmin = New-Object System.Security.AccessControl.FileSystemAccessRule("administrators","Write","Deny")

$locker_unlocker              = New-Object system.Windows.Forms.Form
$locker_unlocker.ClientSize   = '525,245'
$locker_unlocker.text         = "Version.ini locker/unlocker"
$locker_unlocker.TopMost      = $false

$btn_lock                        = New-Object system.Windows.Forms.Button
$btn_lock.text                   = "LOCK"
$btn_lock.width                  = 104
$btn_lock.height                 = 31
$btn_lock.location               = New-Object System.Drawing.Point(258,199)
$btn_lock.Font                   = 'Microsoft Sans Serif,10,style=Bold'

$btn_unlock                      = New-Object system.Windows.Forms.Button
$btn_unlock.text                 = "UNLOCK"
$btn_unlock.width                = 104
$btn_unlock.height               = 31
$btn_unlock.location             = New-Object System.Drawing.Point(84,199)
$btn_unlock.Font                 = 'Microsoft Sans Serif,10,style=Bold'

$info_1                          = New-Object system.Windows.Forms.Label
$info_1.text                     = "The LOCK button will remove write rights from the version.ini file, locking it."
$info_1.AutoSize                 = $true
$info_1.width                    = 25
$info_1.height                   = 10
$info_1.location                 = New-Object System.Drawing.Point(12,30)
$info_1.Font                     = 'Microsoft Sans Serif,10'

$info_2                          = New-Object system.Windows.Forms.Label
$info_2.text                     = "The UNLOCK button will give write rights to the version.ini file, unlocking it for editing."
$info_2.AutoSize                 = $true
$info_2.width                    = 25
$info_2.height                   = 10
$info_2.location                 = New-Object System.Drawing.Point(12,55)
$info_2.Font                     = 'Microsoft Sans Serif,10'

$info_3                          = New-Object system.Windows.Forms.Label
$info_3.text                     = "Step 1) Press UNLOCK"
$info_3.AutoSize                 = $true
$info_3.width                    = 25
$info_3.height                   = 10
$info_3.location                 = New-Object System.Drawing.Point(12,105)
$info_3.Font                     = 'Microsoft Sans Serif,10'

$info_4                          = New-Object system.Windows.Forms.Label
$info_4.text                     = "Step 2) Edit your version.ini file and save it"
$info_4.AutoSize                 = $true
$info_4.width                    = 25
$info_4.height                   = 10
$info_4.location                 = New-Object System.Drawing.Point(12,130)
$info_4.Font                     = 'Microsoft Sans Serif,10'

$info_5                          = New-Object system.Windows.Forms.Label
$info_5.text                     = "Step 3) Press LOCK and play"
$info_5.AutoSize                 = $true
$info_5.width                    = 25
$info_5.height                   = 10
$info_5.location                 = New-Object System.Drawing.Point(12,155)
$info_5.Font                     = 'Microsoft Sans Serif,10'

$cr                              = New-Object system.Windows.Forms.Label
$cr.text                         = "Made by andy."
$cr.AutoSize                     = $true
$cr.width                        = 25
$cr.height                       = 10
$cr.location                     = New-Object System.Drawing.Point(452,216)
$cr.Font                         = 'Microsoft Sans Serif,7'

$locker_unlocker.controls.AddRange(@($btn_lock,$btn_unlock,$info_1,$info_2,$info_3,$info_4,$info_5,$cr))

$btn_unlock.Add_Click({ unlock_event })
$btn_lock.Add_Click({ lock_event })


function lock_event {
    $acl.PurgeAccessRules($Purge)
    $acl.PurgeAccessRules($PurgeAdmin)
    $acl.SetAccessRule($AllowRead)
    $acl.SetAccessRule($AllowReadAdmin)
    $acl.SetAccessRule($Deny)
    $acl.SetAccessRule($DenyAdmin)
	$acl | Set-Acl $PSScriptRoot\version.ini
}
function unlock_event {
    $acl.PurgeAccessRules($Purge)
    $acl.PurgeAccessRules($PurgeAdmin)
    $acl.SetAccessRule($Allow)
    $acl.SetAccessRule($AllowAdmin)
	$acl | Set-Acl $PSScriptRoot\version.ini
}

[void]$locker_unlocker.ShowDialog()
