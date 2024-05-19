
    <#
    .SYNOPSIS
        Searches content for patterns 

    .DESCRIPTION
        Script searches all files and files in all subdirectories of a directory tree.
        One may need to modify the script to filter out for specific types of files

    .EXAMPLES
    .\SearchAllFilesforPatterns.ps1 -p_SourceSearchDirectory "D:\Backups\20201019-Backups-Documents" -p_ScriptDirectory "C:\Users\TedmondFromRedmond\OneDrive - StartOS.com LLC (1)\Documents\SearchAllFilesforPatterns" -p_OutputFileName "OutputPatternsFound.csv" -p_PatternFile "C:\Users\TedmondFromRedmond\OneDrive - StartOS.com LLC (1)\Documents\SearchAllFilesforPatterns\cmdletmaps.txt"
    
    .INPUTS
        - Patterns to search for in p_PatternFile ()
   
    .OUTPUTS
        - CSV file with multiple columns such as folder and filename
   
        
    #----------------------
    # Revision History
    #----------------------
    # 20230426 - TFR; Author https://www.github.com/TedmondFromRedmond
    # 20230601 - Chefat; modified fn_ListLineNumberMatches return
    # 20231030 - Gene -  Removed user input, tested and re-released for pipeline
    # 20240504 - TFR Created PowerShell Specific version
    
    #>
   

#--------------------------------------------------------------
param (
    [Parameter(Mandatory = $false)] [string]$p_SourceSearchDirectory,
    [Parameter(Mandatory = $false)] [string]$p_ScriptDirectory,
    [Parameter(Mandatory = $false)] [string]$p_OutputFileName,
    [Parameter(Mandatory = $false)] [string]$p_PatternFile
)

#------------------------------------------------------------------------
# Begin of functions
#------------------------------------------------------------------------

function fn_ListLineNumberMatches {
    <#
    .SYNOPSIS
        Searches content and returns line numbers for each line containing the specified pattern.
   
    .DESCRIPTION
        This function iterates through the content of a specified file object and searches for the given pattern.
        If found, it returns the line numbers where the pattern occurs, separated by semicolons.
        If not found, returns an empty string.
   
    .EXAMPLES
    # $p_fnLLNM=get-content "c:\temp\stuff.txt"
    # $p_SearchText = "get-azureaduser"

    # Usage:
    # fn_ListLineNumberMatches -p_fnLLNM $p_fnLLNM -p_SearchText "get-azureaduser"
    # fn_ListLineNumberMatches -p_fnLLNM (Get-Content -Path "example.txt") -p_SearchText "get-azureaduser"
   
    .PARAMETER p_fnLLNM
        The object containing the file content to search through.
   
    .PARAMETER p_SearchText
        The pattern to search for in the file content.
   
    .INPUTS
        - File object
        - Pattern to search for
  
   
    .RETURNS
        - Line numbers of pattern occurrences separated by semicolons or blank string.
    #>
   
        param (
            [Parameter(Mandatory = $true)]
            [System.Object]$p_fnLLNM,
   
            [Parameter(Mandatory = $true)]
            [string]$p_SearchText
        )
   
        $fn_lineNumber = 0
        $fn_ReturnValue = ""

        # Scan each line for the pattern, if found add to the line number 
        foreach ($fn_line in $p_fnLLNM) {
            $fn_lineNumber++
            if ($fn_line -match $p_SearchText) {
                $fn_ReturnValue = "$fn_lineNumber;$fn_ReturnValue"
            }
        } # end of foreach fn_line in p_fnLLNM
   
        # Output the result
        # $out_msg = $fn_ReturnValue
        # Write-Host $out_msg
        # Write-Host
   
        return $fn_ReturnValue

    }    # write-host "End of fn_ListLineNumberMatches"
 

#--------------------------------------------------------------


#------------------------------------------------------------------------
# End of functions
#------------------------------------------------------------------------

################################################################################################################
# MAIN EXECUTION
################################################################################################################
# Clear screen so as not to clutter console
CLS

# Initialize variables 
$fileCounter = 0
$MatchCount=0

# Map Parms to script vars
# Variables Definition - Not generated by AI ;)
# PatternFileInput - Patterns you want to search for. Each file is searched line by line for each pattern
# SourceSearchDirectory - is the source code directory you want the script to search in
# ScriptDirectory - Top level directory of files to search. The script will recurse through every subdirectory without limits to depth
# OutputFileName - Output file name without directory. 
# FinalFileName - Note: Not necessary to modify. This is the concatenation of the ScriptDirectory & the OutputFileName

$SourceSearchDirectory = $p_SourceSearchDirectory
$ScriptDirectory = $p_ScriptDirectory
$OutputFileName = $p_OutputFileName
$PatternFileInput = $p_PatternFile

#########################
#------------------
# Overrides for testing
#------------------

<#
$PatternFileInput = "C:\Users\TedmondFromRedmond\OneDrive - StartOS.com LLC (1)\Documents\SearchAllFilesforPatterns\Patterns.txt"
# Dir. with source code. can contain 1 or many files; code searches all directories and subdirectories
$SourceSearchDirectory = "D:\Backups\20201019-Backups-Documents"
# Directory with the files to search thru
$ScriptDirectory = "C:\Users\TedmondFromRedmond\OneDrive - StartOS.com LLC (1)\Documents\SearchAllFilesforPatterns"
# Output file in CSV format. Only the filename without directory. The filename is concatenated later with the ScriptDirectory to create $FinalFilename
$OutputFileName = "GraphReport.csv"
#>

#------------------
# End of Overrides
#-----------------
#########################

# Generate a timestamp to prefix the FinalFilename
# Each time the operator executes the script there is not a chance to overwrite the previous results
$timestamp = Get-Date -Format "yyyyMMddss"

# Create the final filename by prefixing the base filename with the timestamp
$finalFileName = $ScriptDirectory + "\" + $timestamp + $OutputFileName

# Display processing variables to console before processing
write-host
write-host "Pattern Input File $PatternFileInput"
# Directory with source code - powershell files; can contain 1 or many files; code searches all directories and subdirectories
write-host "Directory with source code $SourceSearchDirectory"
# Directory with the files to search thru
write-host "Directory with the files to search thru $ScriptDirectory"
# Output file in CSV format.
write-host "CSV Output File $finalFileName"
write-host 

# pause to press any key to continue
# Write-host "Press ctrl+C to cancel processing"
# Write-Host -NoNewLine 'Press any key to continue...';
# $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');


# Retrieve all files in the specified directory and all subdirectories
# $files = Get-ChildItem -Path $SourceSearchDirectory -Recurse -File
#
# Retrieve PowerShell script files (.ps1, .psm1, .psd1)
# Example of filtering
$myFiles1 = Get-ChildItem -Path $SourceSearchDirectory -Recurse -File -Filter *.tar
$zipFiles = Get-ChildItem -Path $SourceSearchDirectory -Recurse -File -Filter *.zip

# Combine all the files captured in the GCI into one variable to read thru in the main loop
$files = $myFiles1 + $zipFiles
$totalFiles = $files.Count

# Read search patterns from file
$SearchPatterns = Get-Content $PatternFileInput

# Loop through each file and loop through each pattern
# If a pattern is found, then the line numbers are determined via a function call
# Record is added to output file
# Main Loop
#-------
foreach ($file in $files) {
    $fileCounter++
    Write-Progress -Activity "Processing Files" -Status "Processing $($file.Name)" -PercentComplete (($fileCounter / $totalFiles) * 100)

    # if FullName length is zero continue and advance to next record in for each
    # ck for empty lines in the pattern match file
    # Skip line if empty, process line if value in file
    if ($file.FullName.Length -eq 0) {
        # Skip empty search patterns
        Continue
    } #
   
    # Store the contents of each file in object
    $content = Get-Content $file.FullName -ErrorAction SilentlyContinue

    # Main-sub Loop
    foreach ($Spattern in $SearchPatterns) {
        if ($Spattern.Length -eq 0) {
            # Skip empty search patterns
            Continue
        } # end of if $Spattern.Length eq 0

        # If there is a match, increment the MatchCount counter,
        # call the function to find all the line numbers and return line numbers/occurences in object format
        # 
        
        if ($content -match $Spattern) {
            # Since a match is found, add 1 to the matchcount
            $MatchCount++

            # Match found, create a custom object
            $rc_LineNumbers=fn_ListLineNumberMatches -p_fnLLNM $content -p_SearchText $Spattern
            
            # Custom object for CSV output
            $fileObj = [PSCustomObject]@{
                FolderandFileName     = $file.DirectoryName + "\" + $file.Name
                SearchPattern     = $Spattern
                LastWriteTime  = $file.LastWriteTime.ToString("dddd, MMMM dd, yyyy hh:mm:ss tt")
                FileSize         = $file.Length
                PatternLocations = $rc_lineNumbers
            } # end of fileobj
          
            # Export object to csv with append does not require an existing file; if DNE, the file is created
            $fileObj | Export-Csv -Path $finalFileName -NoTypeInformation -Append
            
            # Dispose of object for memory constraints
            $fileobj=$null
            
            # Write-Host

        } # End of if content match spattern
    } # End of foreach spattern in searchpatterns

} # end of foreach pattern in patterns

write-host
write-host "Total number of files processed: $totalFiles"
write-host
write-host "Total number of patterns matched: $matchcount"
Write-Host

if($matchcount -ne 0){
    Write-Host "Output is stored in filename: $finalFileName"
} else {
    $out_msg=".........No matches were found......."
    write-host $out_msg
    $out_msg|out-file $FinalFileName -Append
    # FinalFileName
    $out_msg="PatternFileInput: $PatternFileInput"
    $out_msg|out-file $FinalFileName -Append
 
    $out_msg="ScriptDirectory: $ScriptDirectory"
    $out_msg|out-file $FinalFileName -Append

    $out_msg="SourceSearchDirectory: $SourceSearchDirectory"
    $out_msg|out-file $FinalFileName -Append

    $out_msg="FinalFilename: $FinalFileName"
    $out_msg|out-file $FinalFileName -Append

    Write-Host "Messages are stored in: $finalFileName"

} # if matchcount -ne 0

Write-Host "End of Pattern Discovery"


