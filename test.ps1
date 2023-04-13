$username = ".\michael"
$password = ConvertTo-SecureString "1234" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $password)

Test-WSMan -ComputerName 192.168.1.68 -Credential $credential -Authentication Negotiate


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

Set-Item -Path WSMan:\localhost\Service\Auth\CertificateThumbprint -Value <thumbprint>
