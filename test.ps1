$username = ".\michael"
$password = ConvertTo-SecureString "1234" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $password)

Test-WSMan -ComputerName 192.168.1.68 -Credential $credential -Authentication Negotiate

Get-Item -Path WSMan:\localhost\Client\TrustedHosts

Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value "192.168.1.68"