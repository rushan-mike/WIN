Start-Process powershell -Verb runAs

$username = "michael"
$password = ConvertTo-SecureString "1234" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($username,$password)

Test-WSMan -ComputerName 192.168.1.68 -Credential $credential -Authentication Negotiate



$session = New-PSSession -ComputerName 192.168.1.68

Get-PSSession -ComputerName 192.168.1.68

Remove-PSsession -session $session


Invoke-Command -Session $session -ScriptBlock {} -ArgumentList

Invoke-Command -Session $session -ScriptBlock {Test-NetConnection -ComputerName 192.168.1.1 -port 80}

Invoke-Command -Session $session -ScriptBlock {param($target_value,$port_value) Test-NetConnection -ComputerName $target_value -port $port_value} -ArgumentList 192.168.1.1 80




Get-Item -Path WSMan:\localhost\Client\TrustedHosts

Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value "192.168.1.68"




Enable-WSManCredSSP -Role Client -DelegateComputer *

Enable-WSManCredSSP -Role Server




winrm s winrm/config/client '@{TrustedHosts="192.168.1.64,192.168.1.68"}'

winrm g winrm/config/client




Get-Item WSMan:\localhost\Service\AllowRemoteAccess

Get-Item WSMan:\localhost\Service\Auth\CredSSP




Get-ChildItem -Path Cert:\CurrentUser\My

Get-ChildItem -Path WSMan:\localhost\Service\Auth\

Set-Item -Path WSMan:\localhost\Service\Auth\CertificateThumbprint -Value "thumbprint"




Get-Item WSMan:\localhost\Service\AllowUnencrypted

Set-Item WSMan:\localhost\Service\AllowUnencrypted $true

Restart-Service WinRM




New-SelfSignedCertificate -DnsName "<hostname>" -CertStoreLocation Cert:\LocalMachine\My

Get-ChildItem -Path Cert:\LocalMachine\My

winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname="<hostname>";CertificateThumbprint="<thumbprint>"}
