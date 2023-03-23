#Requires -version 7.0
#Requires -RunAsAdministrator
Param(
    [Parameter(Mandatory)]
    [string]
    $CommonName,
    [Parameter(Mandatory=$false)]
    [string]
    $Path = "./",
    [Parameter(Mandatory=$false)]
    [ScriptBlock]
    $IterationRule =
    {
        Param([int]$Count)
        [string[]]$result = @();
        for($i = 0; $i -le $Count; $i++)
        {
            $result += '(' + $i + ')';
        }
        return $result;
    },
    [Parameter(Mandatory=$false)]
    [string[]]
    $Include = @(),
    [Parameter(Mandatory=$false)]
    [string[]]
    $Exclude = @()
)

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Write-Debug "Execution started. [$($stopwatch.ElapsedMilliseconds)ms]"

Write-Debug "`$CommonName=$CommonName"
Write-Debug "`$Path=$Path"
Write-Debug "`$IterationRule=$IterationRule"
Write-Debug "`$AcceptExt=$AcceptExt"


## 运行前短路判定
if (-not [System.IO.Directory]::Exists($Path)) {
    Write-Warning "`'$Path`' does not exist, please check"
    return;
}

## 初始化变量
$parms1 = @{}
$parms1.Path = $Path
if ($Include.Length -gt 0) {
    Write-Debug "Added Include"
    $parms1.Add("Include", $Include);
}
if ($Exclude.Length -gt 0) {
    Write-Debug "Added Exclude"
    $parms1.Add("Exclude", $Exclude);
}
$parms1.File = $true;
$parmsJson = ConvertTo-Json -InputObject $parms1 -Compress
Write-Debug $parmsJson
[string[]]$FileNames = Get-ChildItem @parms1

[int]$count = $FileNames.Length
if ($count -eq 0) {
    Write-Warning "There are no files to rename"
    return;
}

## 确定文件列表不为空，获得绝对路径
[string]$workDir = [System.IO.Path]::GetDirectoryName($FileNames[0])


## 试图初始化命名变量部分
[string[]] $tails = Invoke-Command $IterationRule -ArgumentList $count
[string[]] $uniqueTails = @()
for ($i = 0; $i -lt $tails.Count; $i++) {
    if (-not $uniqueTails.Contains($tails[$i])) {
        $uniqueTails += $tails[$i]
    }
}

if ($uniqueTails.Count -lt $count) {
    Write-Warning "The IterationRule:`r`n$IterationRule`r`n...did not generate enough unique varying text."
    Write-Warning "Required:$($uniqueTails.Count),Actual:$count."
    return;
}

## 准备就绪，提示重命名任务

class PromptItem {
    [string]$Before
    [string]$toBe = "->"
    [string]$After
    PromptItem([string]$before, [string]$after) {
        $this.Before = $before
        $this.After = $after
    }
}

[PromptItem[]]$prompt = @()
for ($i = 0; $i -lt $count; $i++) {
    [string]$ext = [System.IO.Path]::GetExtension($FileNames[$i])
    [string]$NewName = [string]::Concat($CommonName, $uniqueTails[$i], $ext)
    [string]$OldName = [System.IO.Path]::GetFileName($FileNames[$i])
    $prompt += [PromptItem]::new($OldName, $NewName);
}

Write-Host "Working Directory:"
Write-Host $workDir

$prompt | Select-Object -Property `
    @{l="Before"; e={$_.Before}}, `
    @{l="->"; e={$_.toBe}},
    @{l="After"; e={$_.After}} | Out-Host

Write-Host " Please review the above list: $count file(s) " `
    -ForegroundColor Black -BackgroundColor Red -NoNewline
Write-Host " "
Write-Host "Warning: You cannot redo this action."

"" | Out-Host

$Ans = Read-Host -Prompt "Continue? [Y]es/[N]o"
if (-not ($Ans -imatch '(Y)|(YES)')) {
    return;
}

## 确认执行
[int]$success = 0
for ($i = 0; $i -lt $count; $i++) {
    $success++;
    [int]$completed = ($i/$count)*100

    Write-Progress -Activity "Renaming Files" -Status "($i/$count)" -PercentComplete $completed
    Start-Sleep -Milliseconds 50
    try {
        $parms2 = @{
            Path = [System.IO.Path]::Join($workDir, $prompt[$i].Before)
            NewName = [System.IO.Path]::Join($workDir, $prompt[$i].After)
            ErrorAction = 'Stop'
        }
        Rename-Item @parms2
    }
    catch {
        $success--;
    }
}

Write-Host " Completed renaming files...($success/$count) " -ForegroundColor Green -NoNewline
Write-Host "";


Write-Debug "Execution Ended. [$($stopwatch.ElapsedMilliseconds)ms]"









