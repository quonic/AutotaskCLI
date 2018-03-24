function Get-APIUsage {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [Object]
        $atws
    )
    
    begin {
        $TAUI = $atws.getThresholdAndUsageInfo()
        $Message = $TAUI.EntityReturnInfoResults.Message -Split ';'
        $Threshold = [PSCustomObject]@{
            ThresholdOfExternalRequest = ($Message[0] -Split ': ')[1]
            TimeframeOfLimitation      = ($Message[1] -Split ': ')[1]
            numberOfExternalRequest    = ($Message[2] -Split ': ')[1]
            Percentage                 = ($numberOfExternalRequest / $ThresholdOfExternalRequest) * 100
        }
    }
    
    process {
    }
    
    end {
        $Threshold
    }
}

