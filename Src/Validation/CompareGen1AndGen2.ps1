param(
[System.Collections.ICollection] $gen1Files,
[System.Collections.ICollection] $gen2Files,
[string] $ValidationResultFilePath
)
try{

   Write-Host "`n"
   Write-Host "Started comparing Gen1 & Gen2 file details" -ForegroundColor Yellow
 

   $MatchResult = @()

    ForEach ($Gen1File in $Gen1Files)
    {

        $Gen2Match = $Gen2Files | where {$_.Path -eq $Gen1File.Path} # -and $_.Length -eq $Gen1File.Length}
        If($Gen2Match)
        {
            # Process the data
            if($Gen1File.Length -eq $Gen2Match.Length)
            {
            $MatchResult += New-Object PsObject -Property @{FileName =$Gen1File.Name;Gen1FilePath=$Gen1File.Path;Gen2FilePath=$Gen2Match.Path;Gen1FileSize=$Gen1File.Length;
            Gen2FileSize=$Gen2Match.Length;IsMatching = "Yes"}
            }

            else
            
            {
            $MatchResult += New-Object PsObject -Property @{FileName =$Gen1File.Name;Gen1FilePath=$Gen1File.Path;Gen2FilePath=$Gen2Match.Path;Gen1FileSize=$Gen1File.Length;
            Gen2FileSize=$Gen2Match.Length;IsMatching = "No"}
            }

        }
        else
        {
        $MatchResult += New-Object PsObject -Property @{FileName =$Gen1File.Name;Gen1FilePath=$Gen1File.Path;Gen2FilePath="";Gen1FileSize=$Gen1File.Length;
            Gen2FileSize="";IsMatching = "No"}
        }
    }

$MatchResult | Select FileName, Gen1Filepath,Gen2FilePath, Gen1FileSize,Gen2FileSize,IsMatching  | Export-Csv $ValidationResultFilePath
  
  
Write-Host "`n"
Write-Host "Finished comparison. Please check the validation result at: $($ValidationResultFilePath)" -ForegroundColor Green
  
}
catch
{

    throw $error[0].Exception;   
}


