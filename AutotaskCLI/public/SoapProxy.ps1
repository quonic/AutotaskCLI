function Get-AutoTaskObject {
    [CmdletBinding()]
    param (
        [pscredential]
        $Credential = (Get-Credential),
        # Days back to initiate refresh of ATEntityInfo cache
        [int]
        $Refresh = 1
    )
    
    begin {
        # if (-not $Credential) {
        #     $Creds = Get-Credential
        #     if (-not $Creds) {
        #         # Fallback on getting from console
        #         $username = Read-Host "Enter username "
        #         $secpasswd = Read-Host "Enter password " -AsSecureString
        #         $Creds = New-Object System.Management.Automation.PSCredential ("\$username", $secpasswd)
        #     }
        # }
        # else {
        #     $Creds = $Credential
        # }
    }
    
    process {
        try {
            # According to the API we need to find the correct "Zone" that the user belongs to
            $ZoneFinder = New-WebServiceProxy -Uri "https://webservices.Autotask.net/atservices/1.5/atws.wsdl" -Namespace "AutotaskZoneFinder"
            $ZoneInfo = $ZoneFinder.getZoneInfo($Credential.UserName)
            # No need to define the namespace as defining it will create problems
            # when a script tries to call it a second time. There isn't a way to
            # Dispose of a namespace. The only method of doing this is to restart
            # the session.
            #$Namespace = "Autotask"

            # Building the Splat
            $ProxyParams = @{
                Uri        = [Uri]::new($ZoneInfo.URL.replace('.asmx', '.wsdl')).AbsoluteUri
                Credential = $Credential
                #Namespace  = $Namespace
            }
            
        }
        catch {
            throw $_
        }
        try {
            $webProxy = New-WebServiceProxy @ProxyParams
        }
        catch {
            throw $_
        }
        return $webProxy
    }
    
    end {
    }
}