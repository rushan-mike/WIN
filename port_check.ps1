
param (
    [switch]$port,
    [switch]$target,
    [switch]$remote,
    [switch]$run,
    [switch]$check
)

try 
{
    $i = 0
    $msg = "
Please specify a switch

-port
-target
-remote
-run
-check
-id
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
        Write-Host "> port_list = " -NoNewline
        Write-Host $env:port_list
        Write-Host "> target_list =" -NoNewline
        Write-Host $env:target_list
        Write-Host "> remote_list =" -NoNewline
        Write-Host $env:remote_list
        Write-Host "> cred_is_set =" -NoNewline
        Write-Host $env:remote_list
        $msg = ""
    }

    elseif($id){
        $domain = $null
        $domain = Read-Host "> domain : "
        $username = $null
        $username = Read-Host "> username : "
        $password = $null
        $password = Read-Host "> password : " -AsSecureString
        $securePassword = $null
        $securePassword = ConvertFrom-SecureString -SecureString $password
        $cred = $null
        $cred = New-Object System.Management.Automation.PSCredential -argumentlist "$domain\$username",$securePassword
    }


    elseif ($run) {
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

            foreach ($remote in $remote_list) {
                $session = $null
                $session = New-PSSession -ComputerName $remote -Credential $cred

                foreach ($target in $target_list) {
                    foreach ($port in $port_list) {
                        Invoke-Command -Session $session -ScriptBlock {
                            param($target,$port)
                            
                            # Test-NetConnection -ComputerName $target -port $port

                            try{
                                $target_ip = (Resolve-DnsName -Name $target -Type A).IPAddress
                                # fix to use first resolved IP

                                $tcpClient = New-Object System.Net.Sockets.TcpClient
                                $tcpClient.ReceiveTimeout = 5000  # 5 seconds
                                $tcpClient.SendTimeout = 5000  # 5 seconds

                                try {
                                    $tcpClient.Connect($target_ip, $port)
                                    Write-Host "$target : $target_ip : $port : open"
                                }
                                
                                catch {
                                    Write-Host "$target : $target_ip : $port : closed"
                                }
                                finally {
                                    $tcpClient.Close()
                                }
                            }
                            
                            catch [Microsoft.DnsClient.Commands.ResolveDnsNameException] {
                                Write-Host "Unable to resolve $target"
                            }
                        } -ArgumentList $target $port
                    }
                }

                remove-pssession -session $session
            }

            Write-Host "> " -NoNewline

        }
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
        $msg = "Saved"
    }

    elseif ($target) {
        $target_list_string = $null
        $target_list_string = $target_list -join ","
        Set-Item -Path Env:target_list -Value $null
        Set-Item -Path Env:target_list -Value $target_list_string
        $msg = "Saved"
    }

    elseif ($remote) {
        $remote_list_string = $null
        $remote_list_string = $remote_list -join ","
        Set-Item -Path Env:remote_list -Value $null
        Set-Item -Path Env:remote_list -Value $remote_list_string
        $msg = "Saved"
    }
    
    Write-Host $msg   
}

#Michaelzero