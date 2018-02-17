$projectRoot = Resolve-Path "$PSScriptRoot\.."
$script:ModuleName = 'AutotaskCLI'

Describe "Basic function unit tests" -Tags Build {

}

# Describe "Get-AutoTaskObject calls New-WebServiceProxy" -Tags Build {
#     It "return URL" {
#         $secpasswd = ConvertTo-SecureString -String 'TestPassword' -AsPlainText -Force
#         $Creds = New-Object System.Management.Automation.PSCredential ("\test@consto.com", $secpasswd)

#         Mock -CommandName New-WebServiceProxy -MockWith {
#             class Autotask {
#                 $AutotaskIntegrationsValue = $null
#                 $SoapVersion = "Default"
#                 $AllowAutoRedirect = $False
#                 $CookieContainer = $null
#                 $ClientCertificates = {}
#                 $EnableDecompression = $False
#                 $UserAgent = "Mozilla/4.0 (compatible; MSIE 6.0; MS Web Services Client Protocol 4.0.30319.42000)"
#                 $Proxy = $null
#                 $UnsafeAuthenticatedConnectionSharing = $False
#                 $Credentials = $Creds
#                 $UseDefaultCredentials = $False
#                 $ConnectionGroupName = $null
#                 $PreAuthenticate = $False
#                 $Url = "https://webservices.autotask.net/ATServices/1.5/atws.asmx"
#                 $RequestEncoding = $null
#                 $Timeout = 100000
#                 $Site = $null
#                 $Container = $null
#                 [PSCustomObject]getZoneInfo ([string]$Username) {
#                     return [PSCustomObject]@{
#                         URL       = "https://webservices5.autotask.net/ATServices/1.5/atws.asmx"
#                         ErrorCode = 0
#                         CI        = 9292
#                         WebUrl    = "https://ww5.autotask.net/"
#                     }
#                 }
#             }
#             return [Autotask]::new()
#         }
#         $Autotask = Get-AutoTaskObject -Credential $Credential
#         $Autotask.URL | Should -Be "https://webservices5.autotask.net/ATServices/1.5/atws.wsdl"
#     }
# }