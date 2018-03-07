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


function Get-ATEntityInfo ([Object]$atws) {
    # Build our own EntityInfo object.
    
    # This was intended to cache this info as to reduce the amount
    # of API calls.

    # This should probably be replace with something more robust.
    # The API provides these objects already
    $atws.getEntityInfo() | ForEach-Object {
        [PSCustomObject]@{
            Name                 = $_.Name
            CanUpdate            = $_.CanUpdate
            CanDelete            = $_.CanDelete
            CanCreate            = $_.CanCreate
            CanQuery             = $_.CanQuery
            HasUserDefinedFields = $_.HasUserDefinedFields
            Fields               = $atws.GetFieldInfo($_.Name) | ForEach-Object {
                [Autotask.Field]@{
                    Name           = $_.Name
                    Label          = $_.Label
                    Type           = $_.Type
                    Length         = $_.Length
                    IsRequired     = $_.IsRequired
                    IsReadOnly     = $_.IsReadOnly
                    IsPickList     = $_.IsPickList
                    PicklistValues = $_.PicklistValues
                    DefaultValue   = $_.DefaultValue
                }
            }
            LastUpdate           = Get-Date
        }
    }
}
function Get-EntityInfo ([Object]$atws, [int]$days) {
    # This needs work as it doesn't work as intended.
    
    # Create the cache folder if it doesn't exsist
    if (-not (Test-Path -Path "$env:TEMP\AutotaskCLI\")) {
        New-Item -Path $env:TEMP -Name AutotaskCLI -ItemType Directory
    }
    
    if (Test-Path -Path "$env:TEMP\AutotaskCLI\EntityInfo.clixml") {
        $EntityInfoData = Import-Clixml -Path "$env:TEMP\AutotaskCLI\EntityInfo.clixml"
        if ($EntityInfoData -and $EntityInfoData[0].LastUpdated -and $EntityInfoData[0].LastUpdated -lt (Get-Date).AddDays($days)) {
            Remove-Item -Path "$env:TEMP\AutotaskCLI\EntityInfo.clixml"
            $EntityInfoData = Get-ATEntityInfo -atws $atws
            $EntityInfoData | Export-Clixml -Path "$env:TEMP\AutotaskCLI\EntityInfo.clixml" -Force
        }
    }
    else {
        $EntityInfoData = Get-ATEntityInfo -atws $atws
        $EntityInfoData | Export-Clixml -Path "$env:TEMP\AutotaskCLI\EntityInfo.clixml" -Force
    }
    return $EntityInfoData
}