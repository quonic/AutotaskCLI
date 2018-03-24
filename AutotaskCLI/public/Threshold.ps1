function Get-APIUsage {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [Object]
        $Autotask
    )

    process {
        $TAUI = $atws.getThresholdAndUsageInfo()
        $Message = $TAUI.EntityReturnInfoResults.Message -Split ';'
        $ThresholdOfExternalRequest = ($Message[0] -Split ': ')[1]
        $TimeframeOfLimitation = ($Message[1] -Split ': ')[1]
        $numberOfExternalRequest = ($Message[2] -Split ': ')[1]

        [PSCustomObject]@{
            ThresholdOfExternalRequest = $ThresholdOfExternalRequest
            TimeframeOfLimitation      = $TimeframeOfLimitation
            numberOfExternalRequest    = $numberOfExternalRequest
            Percentage                 = ($numberOfExternalRequest / $ThresholdOfExternalRequest) * 100
        }
    }
}

