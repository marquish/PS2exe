<#
.Synopsis
	Generates SFX executable with archive.
.DESCRIPTION
	Provided Parameters are 
	Source : use root folder path to archive, default is current directory
	ExcludeFileTypes: use extension type of files to exclude, default is null
	ExcludeFile: use file need to be excluded from included folder
	ExcludeFolder : use folder need to be excluded from included folder
	IncludeFolders: use additional folders to include in archive
	IncludeFiles: use additional files with path to include in archive
	Destination: use destination to set path of sfx archive
	rarfile: use WinRAR.exe file with full path
	UseFile: Use xml file to feed all contents
.EXAMPLE
	./PS2exe
.EXAMPLE
	./PS2exe source="c:\patchFolder" 
		ExcludeFileTypes=".exe" 
		ExcludeFile="somefile" 
		ExcludeFolder="somefolder"
		IncludeFolders="somefolder"
		IncludeFiles="somefiles"
		Destination="path\to\patch.sfx"
		rarfile="c:\Program files\WinRAR\WinRAR.exe"
#>
param(
	[string]$Source = $PSScriptRoot,
    $ExcludeFileTypes = $null,
	$ExcludeFile=$null,
	$ExcludeFolder=$null,
	$IncludeFolders =$null,
	$InlcudeFiles=$null,
	[string] $Destination = "Patch2.exe",
    $srarfile = ".\rar.exe",
	$winrar = 'C:\Program Files\WinRAR\WinRAR.exe',
	$UseFile=".\config.xml"
    #$params =""	
)
process{
	$app = 'PS2exe.exe'
	$excludes = $app #'PS2exe.exe'
	# if nothing done, but xml file exists
	[xml]$xmlSettings = Get-Content $UseFile
	# set source
	if(-not ($xmlSettings.FileList.Source -eq ".")){
		# as source is provided in config file, override the defined
		$Source = $xmlSettings.FileList.Source
	}
	# set target
	if(-not ($xmlSettings.FileList.Target -eq $app)){ # previous PS2exe.exe
		$Destination = $xmlSettings.FileList.Target
	}
	# set exclude file types
	if(-not ($xmlSettings.FileList.Excludes.ExcludeFileTypes -eq "null")){
		$ExcludeFileTypes = $xmlSettings.FileList.Excludes.ExcludeFileTypes
	}
	# set exclude file
	if(-not ($xmlSettings.FileList.Excludes.ExcludeFiles -eq "null")){
		$ExcludeFile = $xmlSettings.FileList.Excludes.ExcludeFiles
	}
	# set exclude folder
	if(-not ($xmlSettings.FileList.Excludes.ExcludeFolders -eq "null")){
		$ExcludeFile = $xmlSettings.FileList.Excludes.ExcludeFolders
	}
	# include folders
	if(-not ($xmlSettings.FileList.Includes.IncludeFolders -eq "null")){
		$ExcludeFile = $xmlSettings.FileList.Includes.IncludeFolders
	}
	#include files
	if(-not ($xmlSettings.FileList.Includes.IncludeFiles -eq "null")){
		$ExcludeFile = $xmlSettings.FileList.Includes.IncludeFiles
	}
	# process 
	
	if($ExcludeFileTypes) {		
		$excludes = $ExcludeFileTypes | ForEach-Object -Process { if(-not $_ -in $excludes){ $excludes + $_ }}}
	if($ExcludeFile) {
		$excludes = $ExcludeFile| ForEach-Object -Process { if(-not $_ -in $excludes){ $excludes + $_}}}
	if($ExcludeFolder) {
		$excludes =	Get-ChildItem $ExcludeFolder -recurse | ForEach-Object -Process { if(-not $_ -in $excludes){ $excludes + $_}}}
	## $excludes = @($ExcludeFileTypes, $ExcludeFile, $ExcludeFolder)
	if($IncludeFiles) {
		$includes = $IncludeFiles | ForEach-Object -Process {if(-not $_ -in $includes) { $includes + $_}} }
	if($IncludeFolders) {
		Get-ChildItem $IncludeFolders -recurse | ForEach-Object -Process { if(-not $_ -in $includes){ $includes + $_}} }

	## $includes = @($IncludeFiles, $IncludeFolders)
	# Write-Verbose "Welcome ! Patch your enterprise application"    
    $Writeables = Get-ChildItem $Source -recurse -exclude $excludes -include $includes | Resolve-Path -Relative
							#|  ForEach-Object {$_} | 
                            #    Compress-Archive -DestinationPath $Destination
	& $winrar a -sfx -o+ -rr -t $Destination $Writeables    
	 #convert $destination zip to sfx

}
