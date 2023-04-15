
param (
    [switch]$port,
    [switch]$target,
    [switch]$remote,
    [switch]$run,
    [switch]$check,
    [switch]$id,
    [switch]$clear,
    [switch]$runlocal
)

try 
{
    $i = 0
    $msg = "
-->> Please specify a switch <<--

-port
-target
-remote
-id
-check
-run
-clear
-runlocal
"
    if ($port) {
        $port_list = @()
        while ($i -eq 0)
        {
            Write-Host "> " -NoNewline

            $port_list += Read-Host
        }
    }

    elseif ($target) {
        $target_list = @()
        while ($i -eq 0)
        {
            Write-Host "> " -NoNewline

            $target_list += Read-Host
        }
    }

    elseif ($remote) {
        $remote_list = @()
        while ($i -eq 0)
        {
            Write-Host "> " -NoNewline

            $remote_list += Read-Host
        }
    }

    elseif ($check) {
        Write-Host ""
        Write-Host "> port list     ->>   " -NoNewline
        Write-Host $env:port_list
        Write-Host "> target list   ->>   " -NoNewline
        Write-Host $env:target_list
        Write-Host "> remote list   ->>   " -NoNewline
        Write-Host $env:remote_list
        Write-Host "> domain        ->>   " -NoNewline
        Write-Host $env:remote_domain
        Write-Host "> username      ->>   " -NoNewline
        Write-Host $env:remote_username
        Write-Host "> password      ->>   " -NoNewline
        Write-Host $env:remote_password
        $msg = ""
    }

    elseif ($clear) {
        
        if ($env:port_list) {Remove-Item -Path Env:port_list}
        if ($env:target_list) {Remove-Item -Path Env:target_list}
        if ($env:remote_list) {Remove-Item -Path Env:remote_list}
        if ($env:remote_domain) {Remove-Item -Path Env:remote_domain}
        if ($env:remote_username) {Remove-Item -Path Env:remote_username}
        if ($env:remote_password) {Remove-Item -Path Env:remote_password}
        $msg = "`nDone`n"
    }

    elseif ($id) {
        Write-Host ""
        $remote_domain = $null
        $remote_domain = Read-Host "> domain "
        $remote_username = $null
        $remote_username = Read-Host "> username "
        $remote_password = $null
        $remote_password = Read-Host "> password "
    }

    elseif ($run) {
        Write-Host ""
        $port_list = @()
        $target_list = @()
        $remote_list = @()
        while ($i -eq 0)
        {
            $port_list_string = $null
            $port_list_string = $env:port_list
            $port_list = $port_list_string.Split(",")

            $target_list_string = $null
            $target_list_string = $env:target_list
            $target_list = $target_list_string.Split(",")

            $remote_list_string = $null
            $remote_list_string = $env:remote_list
            $remote_list = $remote_list_string.Split(",")

            $remote_domain = $null
            $remote_domain = $env:remote_domain

            $remote_username = $null
            $remote_username = $env:remote_username

            $remote_password = $null
            $remote_password = $env:remote_password

            $remote_securePassword = $null
            $remote_securePassword = ConvertTo-SecureString  $remote_password -AsPlainText -Force

            $cred = $null
            $cred = New-Object System.Management.Automation.PSCredential ($remote_username,$remote_securePassword)

            foreach ($remote_value in $remote_list) {
                $session = $null
                $session = New-PSSession -ComputerName $remote_value -Credential $cred

                foreach ($target_value in $target_list) {
                    foreach ($port_value in $port_list) {
                        Invoke-Command -Session $session -ScriptBlock {
                            param($target_value,$port_value)
                            
                            # Test-NetConnection -ComputerName $target -port $port

                            try{

                                if ($target_value -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}") {
                                    $target_ip = $target_value
                                    $target_value = "N/A"
                                } else {
                                    $target_ip = (Resolve-DnsName -Name $target_value -Type A).IPAddress
                                }
                                
                                $target_ip_array = $null
                                $target_ip_array = @()
                                $target_ip_array += $target_ip

                                foreach ($target_ip in $target_ip_array){

                                    $tcpClient = New-Object System.Net.Sockets.TcpClient
                                    $tcpClient.ReceiveTimeout = 5000  # 5 seconds
                                    $tcpClient.SendTimeout = 5000  # 5 seconds

                                    try {
                                        $tcpClient.Connect($target_ip, $port_value)
                                        Write-Host "$target_value -->> $target_ip -->> $port_value -->> Open"
                                    }
                                    
                                    catch {
                                        Write-Host "$target_value -->> $target_ip -->> $port_value -->> Closed"
                                    }
                                    finally {
                                        $tcpClient.Close()
                                    }
                                }
                            }
                            
                            catch [Microsoft.DnsClient.Commands.ResolveDnsNameException] {
                                Write-Host "Unable to resolve $target"
                            }
                        } -ArgumentList $target_value $port_value
                    }
                }

                remove-pssession -session $session
            }

            Write-Host "> " -NoNewline

        }
    }

    elseif ($runlocal){
        Write-Host ""
        $port_list = @()
        $target_list = @()

        $port_list_string = $null
        $port_list_string = $env:port_list
        $port_list = $port_list_string.Split(",")

        $target_list_string = $null
        $target_list_string = $env:target_list
        $target_list = $target_list_string.Split(",")

        foreach ($target_value in $target_list) {
            foreach ($port_value in $port_list) {
                try{
                    if ($target_value -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}") {
                        $target_ip = $target_value
                        $target_value = "N/A"
                    } else {
                        $target_ip = (Resolve-DnsName -Name $target_value -Type A).IPAddress
                    } 
                    
                    $target_ip_array = $null
                    $target_ip_array = @()
                    $target_ip_array += $target_ip

                    foreach ($target_ip in $target_ip_array){

                        $tcpClient = New-Object System.Net.Sockets.TcpClient
                        $tcpClient.ReceiveTimeout = 5000  # 5 seconds
                        $tcpClient.SendTimeout = 5000  # 5 seconds

                        try {
                            $tcpClient.Connect($target_ip, $port_value)
                            Write-Host "$target_value -->> $target_ip -->> $port_value -->> Open"
                        }
                        
                        catch {
                            Write-Host "$target_value -->> $target_ip -->> $port_value -->> Closed"
                        }
                        finally {
                            $tcpClient.Close()
                        }
                    }
                }
                
                catch [Microsoft.DnsClient.Commands.ResolveDnsNameException] {
                    Write-Host "Unable to resolve $target"
                }
            }
        }
        $msg = ""
    }

}

catch [Management.Automation.MethodInvocationException] {
    if ($_.Exception.InnerException.GetType().Name -eq 'OperationCanceledException') 
    {
        exit 0
    }
}

finally 
{
    if ($port) {
        $port_list_string = $null
        $port_list_string = $port_list -join ","
        Set-Item -Path Env:port_list -Value $null
        Set-Item -Path Env:port_list -Value $port_list_string
        $msg = "`n`nSaved`n"
    }

    elseif ($target) {
        $target_list_string = $null
        $target_list_string = $target_list -join ","
        Set-Item -Path Env:target_list -Value $null
        Set-Item -Path Env:target_list -Value $target_list_string
        $msg = "`n`nSaved`n"
    }

    elseif ($remote) {
        $remote_list_string = $null
        $remote_list_string = $remote_list -join ","
        Set-Item -Path Env:remote_list -Value $null
        Set-Item -Path Env:remote_list -Value $remote_list_string
        $msg = "`n`nSaved`n"
    }

    elseif($id){
        Set-Item -Path Env:remote_domain -Value $null
        Set-Item -Path Env:remote_domain -Value $remote_domain
        Set-Item -Path Env:remote_username -Value $null
        Set-Item -Path Env:remote_username -Value $remote_username
        Set-Item -Path Env:remote_password -Value $null
        Set-Item -Path Env:remote_password -Value $remote_password
        $msg = "`nDone`n"
    }
    
    Write-Host $msg   
}

#Michaelzero