param(
	[Parameter()] $ProjectName,
	[Parameter()] $ConfigurationName,
	[Parameter()] $TargetDir
)

Copy 'AutotaskCLI.dll' '.\AutotaskCLI' -Force -Verbose
