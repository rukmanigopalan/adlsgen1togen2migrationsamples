##################################################################################################################################
# A script to compare all gen2 files for existance and file size.
# 
# Prerequisite:
#  1. need to have the azure subscription
#  2. ReourceGroup
#  3. Azure Storage account and Azure storage container and Azure datalake gen1 account
#  4. Service principal that has permission on the subscription
#  5. All Azure login information such as tenantId, service principal need to store in Azure keyvault. 
# Steps the operation does:
#  1. executing getgen1files and gen2files scripts
#  2. set gen1 and gen2 files in hashtable
#  3. Check if gen2 files are exist in gen1
#  4. if exist, then check if gen2 files sizes are same
#    Sample Usage:
#
#$diff = C:\Users\v-wiya\Documents\CompareGen1AndGen2.ps1 -Gen1Files $gen1FileDetails -Gen2Files $gen2FileDetails -outputPath "C:\Users\v-wiya\Documents\diff.csv"
#
# 

param(
[System.Collections.ICollection] $gen1Files,
[System.Collections.ICollection] $gen2Files
)
try{

    #set up a datatable to store difference
    $filediff=New-Object System.Data.DataTable;
    $filediff.Columns.Add((New-Object System.Data.DataColumn 'gen1Files', ([string])));
    $filediff.Columns.Add((New-Object System.Data.DataColumn 'gen2Files', ([string])));
    $filediff.Columns.Add((New-Object System.Data.DataColumn 'difference', ([string])));

    #set up hastable for gen1 files
    $gen1Dict = New-Object 'system.collections.generic.dictionary[string,int]'
    foreach ($eachRow in $gen1Files)
    {
        if ($eachRow.Path -ne $null)
        {
        $gen1Dict.Add($eachRow.Path, $eachRow.length);
        }
    }

      #set up hastable for gen2 files
    $gen2Dict = New-Object 'system.collections.generic.dictionary[string,int]'
    foreach ($eachRow in $gen2Files)
    {
        if ($eachRow.Path -ne $null)
        {
        $gen2Dict.Add($eachRow.Path, $eachRow.length);
        }
    }

    foreach ($eachRow in $gen1Dict)
    {
        if ($eachRow.key -ne $null)
        {
            #check if gen2 files exist in gen1
            if ($gen2Dict.ContainsKey($eachRow.key))
            {
                if ($gen1Dict[$eachRow.key] -ne $gen2Dict[$eachRow.key])
                {
                #check if gen2 files have same size as in gen2
                    $filediff.Rows.Add($eachRow.key,$eachRow.key, 'length not same');
                }
            }
            else
            {
                $filediff.Rows.Add($eachRow.key,' ', 'Gen2 Missing files');
            }
        }
    }
    
}
catch
{

    throw $error[0].Exception;   
}

return $filediff;
