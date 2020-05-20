
# This script takes Gen1 and Gen2 files object as Input
# It Checks Files availability between Gen1 and Gen2 Account and compares the file size as well
# Returns the Matched, unmatched result in CSV file

param(
    [System.Collections.ICollection] $gen1Files,
    [System.Collections.ICollection] $gen2Files,
    [string] $ValidationResultFilePath
)

try {

    Write-Host "`n"
    Write-Host "Started comparing Gen1 & Gen2 file details" -ForegroundColor Yellow

# Declare array variable to store match result

    $MatchResult = @()

# Check if Gen1 files are available in Gen2 Account 

    ForEach ($Gen1File in $Gen1Files) {

        $Gen2Match = $Gen2Files | Where-Object { $_.Path -eq $Gen1File.Path -and $_.Permission -eq $Gen1File.Permission} 
        If ($Gen2Match) {
            # Process the data
            if ($Gen1File.Length -eq $Gen2Match.Length) {
                $MatchResult += New-Object PsObject -Property @{Gen1FilePath = $Gen1File.Path; Gen2FilePath = $Gen2Match.Path; Gen1FileSize = $Gen1File.Length; Gen2FileSize = $Gen2Match.Length; Gen1Permission= $Gen1File.Permission; Gen2Permission= $Gen2Match.Permission; IsMatching = "Yes"
                }
            }

            else
            {
                $MatchResult += New-Object PsObject -Property @{Gen1FilePath = $Gen1File.Path; Gen2FilePath = $Gen2Match.Path; Gen1FileSize = $Gen1File.Length; Gen2FileSize = $Gen2Match.Length;  Gen1Permission= $Gen1File.Permission; Gen2Permission= $Gen2Match.Permission;  IsMatching = "No"
                }
            }

        }
        else {
            $MatchResult += New-Object PsObject -Property @{Gen1FilePath = $Gen1File.Path; Gen2FilePath = ""; Gen1FileSize = $Gen1File.Length; Gen2FileSize = ""; Gen1Permission= $Gen1File.Permission; Gen2Permission= ""; IsMatching = "No" 
            }
        }
    }

# Check if Gen2 files are available in Gen1 Account 

    ForEach ($Gen2File in $Gen2Files) {

        $Gen1Match = $Gen1Files | Where-Object { $_.Path -eq $Gen2File.Path } 
        
        If ($Gen1Match) {
            # Process the data
            if ($Gen2File.Length -eq $Gen1Match.Length) {
                $MatchResult += New-Object PsObject -Property @{Gen1FilePath = $Gen1Match.Path; Gen2FilePath = $Gen2File.Path; Gen1FileSize = $Gen1Match.Length;
                    Gen2FileSize = $Gen2File.Length; Gen1Permission= $Gen1Match.Permission; Gen2Permission= $Gen2File.Permission; IsMatching = "Yes"
                }
            }

            else
            {
                $MatchResult += New-Object PsObject -Property @{Gen1FilePath = $Gen1Match.Path; Gen2FilePath = $Gen2File.Path; Gen1FileSize = $Gen1Match.Length;
                    Gen2FileSize = $Gen2File.Length; Gen1Permission= $Gen1Match.Permission; Gen2Permission= $Gen2File.Permission; IsMatching = "No"
                }
            }

        }
        else {
            $MatchResult += New-Object PsObject -Property @{Gen1FilePath = ""; Gen2FilePath = $Gen2File.Path; Gen1FileSize = "";
                Gen2FileSize = $Gen2File.Length; Gen1Permission= ""; Gen2Permission= $Gen2File.Permission;IsMatching = "No"
            }
        }
    }

# Export the Match, unmatch result to CSV file

    $MatchResult | Select-Object Gen1Filepath, Gen2FilePath, Gen1FileSize, Gen2FileSize, Gen1Permission, Gen2Permission, IsMatching  -Unique | Export-Csv $ValidationResultFilePath -NoTypeInformation
  
    Write-Host "`n"
    Write-Host "Finished comparison. Please check the validation result at below path: " -ForegroundColor Green
    Write-Host "$($ValidationResultFilePath) `n`n" 
  
}
catch {

    throw $error[0].Exception;   
}
