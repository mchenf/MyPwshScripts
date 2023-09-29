[char]$done = [char]0x2501
[char]$tobe = [char]0x254D

$sum = 32;
$d = 0;
[string]$outputString = [string]::Concat([string]::new($tobe, $sum - $d), "`r")
Write-Host $outputString -NoNewLine

[int]$progress = 0;
[System.Random]$rnd = [System.Random]::new();
[int]$r = $rnd.Next(50, 377);
while ($d -lt $sum) {

    Start-Sleep -Milliseconds $r
    
    $output = [string]::Concat( `
        [string]::new($done, ++$d), `
        [string]::new($tobe, $sum - $d), `
        "`r")
    [int]$r = $rnd.Next(50, 377);

    Write-Host $output -NoNewLine

}

