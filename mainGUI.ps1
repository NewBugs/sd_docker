<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    testDemo
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$TestDemoForm                    = New-Object system.Windows.Forms.Form
$TestDemoForm.ClientSize         = '450,400'
$TestDemoForm.text               = "Inspection System Controls"
$TestDemoForm.BackColor          = "#323131"
$TestDemoForm.TopMost            = $false

$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "M A I N - M E N U"
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(125,36)
$Label1.Font                     = 'Microsoft Sans Serif,14,style=Bold,Underline'
$Label1.ForeColor                = "#ffffff"

$Label2                          = New-Object system.Windows.Forms.Label
$Label2.text                     = "Transfer New Inspection Data"
$Label2.AutoSize                 = $true
$Label2.width                    = 25
$Label2.height                   = 10
$Label2.location                 = New-Object System.Drawing.Point(27,87)
$Label2.Font                     = 'Arial,12'
$Label2.ForeColor                = "#ffffff"

$Button1                         = New-Object system.Windows.Forms.Button
$Button1.BackColor               = "#36d321"
$Button1.text                    = "Launch"
$Button1.width                   = 75
$Button1.height                  = 30
$Button1.location                = New-Object System.Drawing.Point(285,81)
$Button1.Font                    = 'Microsoft Sans Serif,11,style=Italic'

$Button2                         = New-Object system.Windows.Forms.Button
$Button2.BackColor               = "#36d321"
$Button2.text                    = "Launch"
$Button2.width                   = 75
$Button2.height                  = 30
$Button2.location                = New-Object System.Drawing.Point(285,141)
$Button2.Font                    = 'Microsoft Sans Serif,11,style=Italic'

$Button3                         = New-Object system.Windows.Forms.Button
$Button3.BackColor               = "#36d321"
$Button3.text                    = "Launch"
$Button3.width                   = 75
$Button3.height                  = 30
$Button3.location                = New-Object System.Drawing.Point(285,201)
$Button3.Font                    = 'Microsoft Sans Serif,11,style=Italic'

$ShutdownIVA                         = New-Object system.Windows.Forms.Button
$ShutdownIVA.BackColor               = "#d32124"
$ShutdownIVA.text                    = "Stop"
$ShutdownIVA.width                   = 60
$ShutdownIVA.height                  = 30
$ShutdownIVA.location                = New-Object System.Drawing.Point(370,201)
$ShutdownIVA.Font                    = 'Microsoft Sans Serif,11,style=Italic'


$Button4                         = New-Object system.Windows.Forms.Button
$Button4.BackColor               = "#36d321"
$Button4.text                    = "Launch"
$Button4.width                   = 75
$Button4.height                  = 30
$Button4.location                = New-Object System.Drawing.Point(285,261)
$Button4.Font                    = 'Microsoft Sans Serif,11,style=Italic'

$Label3                          = New-Object system.Windows.Forms.Label
$Label3.text                     = " Process New Data"
$Label3.AutoSize                 = $true
$Label3.width                    = 25
$Label3.height                   = 10
$Label3.location                 = New-Object System.Drawing.Point(64,146)
$Label3.Font                     = 'Arial,12'
$Label3.ForeColor                = "#ffffff"

$Label4                          = New-Object system.Windows.Forms.Label
$Label4.text                     = "Inspection Viewer Application"
$Label4.AutoSize                 = $true
$Label4.width                    = 25
$Label4.height                   = 10
$Label4.location                 = New-Object System.Drawing.Point(34,208)
$Label4.Font                     = 'Arial,12'
$Label4.ForeColor                = "#ffffff"

$Label5                          = New-Object system.Windows.Forms.Label
$Label5.text                     = "Create Backup of Data"
$Label5.AutoSize                 = $true
$Label5.width                    = 25
$Label5.height                   = 10
$Label5.location                 = New-Object System.Drawing.Point(52,268)
$Label5.Font                     = 'Arial,12'
$Label5.ForeColor                = "#ffffff"

$ProgressBar1                    = New-Object system.Windows.Forms.ProgressBar
$ProgressBar1.BackColor          = "#ffffff"
$ProgressBar1.width              = 300
$ProgressBar1.height             = 30
$ProgressBar1.location           = New-Object System.Drawing.Point(73,322)
$ProgressBar1.Value              = 0
$ProgressBar1.Style              = "Continuous"

$FileName                        = New-Object system.Windows.Forms.Label
$FileName.text                   = "Please have Docker Desktop Launched `n`n"
$FileName.AutoSize               = $false
$FileName.TextAlign              = 'BottomCenter'
$FileName.dock                   = 'Fill'
$FileName.Padding                = 10
$FileName.Visible                = $true
$FileName.width                  = 25
$FileName.height                 = 10
$FileName.Font                   = 'Arial,10'
$FileName.ForeColor              = "#ffffff"

$TestDemoForm.controls.AddRange(@($Label1,$Label2,$Button1,$Button2,$Button3,$Button4,$ShutdownIVA,$Label3,$Label4,$Label5,$ProgressBar1,$FileName))

$Button1.Add_Click({ btnTransfer_Click })
$Button2.Add_Click({ btnProcess_Click })
$Button3.Add_Click({ btnInspection_Click })
$Button4.Add_Click({ btnBackup_Click })
$ShutdownIVA.Add_Click({ btnInspectionShutdown_Click })
$ShutdownIVA.Enabled = $false

function btnTransfer_Click { 
    $Button1.Enabled = $false

    # Progress Bar Setup
    $ProgressBar1.Visible = $true;
    $ProgressBar1.Minimum = 0;
    $ProgressBar1.Maximum = 16;
    $ProgressBar1.Value = 0;
    $ProgressBar1.Step = 1;
    $FileName.Visible = $true;

    # Find Drive Letter of External Drive
    $driveLetter = Get-WmiObject win32_diskdrive | Where-Object{$_.interfacetype -eq "USB"} | ForEach-Object{Get-WmiObject -Query "ASSOCIATORS OF {Win32_DiskDrive.DeviceID=`"$($_.DeviceID.replace('\','\\'))`"} WHERE AssocClass = Win32_DiskDriveToDiskPartition"} |  ForEach-Object{Get-WmiObject -Query "ASSOCIATORS OF {Win32_DiskPartition.DeviceID=`"$($_.DeviceID)`"} WHERE AssocClass = Win32_LogicalDiskToPartition"} | ForEach-Object{$_.deviceid}

    $extDrivePath = $driveLetter + '/images';

    # ASK USER TO CONFIRM MOVE 

    $wshell = New-Object -ComObject Wscript.Shell

    # Copy Drive Data to Docker folder
    if ((Test-Path -path $extDrivePath)) {
            
            
            For($i = 1; $i -le 4; $i++){
                For($j = 0; $j -le 3; $j++){
                    $ProgressBar1.PerformStep();
                    $FileName.text = "Moving Cable " + $i + " - Camera " + $j +" Data`n`n"
                    $FileName.Refresh();

                    $dataInPath = $extDrivePath + '/cable' + $i + '/cam' + $j;
                    $dataOutPath = $PSScriptRoot.toString() + '\views\data\unprocessed\images\cable' + $i + '\cam' + $j;

                    $moveJob = Start-Job -ScriptBlock {
                        param(
                        $dataInPath,
                        $dataOutPath
                        )
                    Move-Item -Path $dataInPath -Destination $dataOutPath -Force | Out-Null
                    New-Item -Path $dataInPath -ItemType Directory
                    # Write-Host $dataOutPath
                    } -ArgumentList $dataInPath,$dataOutPath
                    Wait-Job $moveJob 
                    Receive-Job $moveJob -OutVariable otest
                    Remove-Job $moveJob
                }
                $dataInPath = $extDrivePath + '/cable' + $i + '/diameter' + $i +'.txt';
                $dataOutPath = $PSScriptRoot.toString() + '\views\data\unprocessed\images\cable' + $i + '\diameter' + $i + '.txt';
                Move-Item -Path $dataInPath -Destination $dataOutPath -Force | Out-Null
            }

        # Remove-Item $extDrivePath + '/cable1'
        # Remove-Item $extDrivePath + '/cable2'
        # Remove-Item $extDrivePath + '/cable3'
        # Remove-Item $extDrivePath + '/cable4'
        # Remove-Item $extDrivePath
        # Alert the user the copy has finished

        $FileName.text = "Finished Transfer`n`n"
        $FileName.Refresh();
        $wshell.Popup("Transfer Complete",0,"Done",0x1)
    } else{

        $wshell.Popup("External Drive Missing Files",0,"Error",0x1)
    }
    # $FileName.Visible = $true;
    # Write-Host $PSScriptRoot.toString()
}


function btnProcess_Click { 
    #include test-path for error handling

    $Button2.Enabled = $false

    # Object Array for all data
    $jsonObject = @()

    $dataDate = $(Get-Date -format 'D')
    $date = Get-Date -Format MM-dd-yyyy
    $folderDate = $date.ToString()

    # Progress Bar Visible
    $ProgressBar1.Visible = $true;

    # Create organized folder for processed data
    $dataOutPath = 'views/data/'+ $folderDate +'/images';
    New-Item -Path $dataOutPath -ItemType Directory

    $txtContent1 = Get-Content -Path "views/data/unprocessed/images/cable1/diameter1.txt"

    if($null -ne $txtContent1 -and $txtContent1.count -ne 0){
        # Get images from each cam
        $cam0 = Get-ChildItem -Path 'views/data/unprocessed/images/cable1/cam0/' -Recurse
            Where-Object { $_.Extension -ne '.jpg' }

        $cam1 = Get-ChildItem -Path 'views/data/unprocessed/images/cable1/cam1/' -Recurse
            Where-Object { $_.Extension -ne '.jpg' }
        
        $cam2 = Get-ChildItem -Path 'views/data/unprocessed/images/cable1/cam2/' -Recurse
            Where-Object { $_.Extension -ne '.jpg' }
        
        $cam3 = Get-ChildItem -Path 'views/data/unprocessed/images/cable1/cam3/' -Recurse
            Where-Object { $_.Extension -ne '.jpg' }

        # Count how many files are in the cable folder 
        $ProgressBar1.Minimum = 0;
        $ProgressBar1.Maximum = $txtContent1.count;
        $ProgressBar1.Value = 0;
        $ProgressBar1.Step = 1;
        $ProgressBar1.Refresh();

        $FileName.text = "Running Defect Detection on Cable 1`n`n";
        $FileName.Refresh();

        # DEFECT DETECTION Files
        Move-Item -Path .\openCV_docker\DefectDetection.py -Destination .\views\data\unprocessed\images\cable1 -Force | Out-Null
        Move-Item -Path .\openCV_docker\Dockerfile -Destination .\views\data\unprocessed\images\cable1 -Force | Out-Null

        # Move directory to launch docker container
        Set-Location -Path .\views\data\unprocessed\images\cable1

        $job = Start-Job { 
            # Add cam folders to container
            docker build --tag opencv . | Out-Null
            
            # Run container
            docker run --name opencv opencv

            $OutputVariable = docker inspect -f '{{.State.Running}}' opencv | Out-String
            $OutputVariable = $OutputVariable -replace '[\W]', ''

            # Wait for container to finish 
            while ($OutputVariable -eq 'true'){
                Start-Sleep 1
                $OutputVariable = docker inspect -f '{{.State.Running}}' opencv | Out-String
                $OutputVariable = $OutputVariable -replace '[\W]', ''
            }
            
        }
        Wait-Job $job
        Receive-Job $job 
        Remove-Job $job

        # Copy defect.txt file from container to cable folder
        docker cp opencv:defects.txt defects1.txt

        # Remove opencv container
        docker rm opencv

        # Reset Defect programs
        Set-Location -Path ../../../../..
        Move-Item -Path .\views\data\unprocessed\images\cable1\DefectDetection.py -Destination .\openCV_docker -Force | Out-Null
        Move-Item -Path .\views\data\unprocessed\images\cable1\Dockerfile -Destination .\openCV_docker -Force | Out-Null

        # Read the defect file
        $defectContent1 = Get-Content -Path "views/data/unprocessed/images/cable1/defects1.txt"

        # Synchronizer
        $i = 0;
        $sid = 0;
        For($i = 0; $i -lt $txtContent1.count; $i++) {

            # Create variables for the JSON payload
            $line = [string]$txtContent1[$i]
            $sn, $diameter = $line.split(' ');
            $img0 = "data/"+ $folderDate +"/images/cable1/cam0/"+ [string]$cam0[$i];
            $img1 = "data/"+ $folderDate +"/images/cable1/cam1/" + [string]$cam1[$i];
            $img2 = "data/"+ $folderDate +"/images/cable1/cam2/" + [string]$cam2[$i];
            $img3 = "data/"+ $folderDate +"/images/cable1/cam3/" + [string]$cam3[$i];

            # Get flags from defects txt
            $dline = [string]$defectContent1[$i]
            $ignore, $flagReason = $dline.split(' ');
            
            $flagReason = [string]$flagReason
            if ($flagReason -eq "none"){
                $flag = "false"
            }
            else {
                $flag = "true"
            }
            
            # Individual object
            $obj = New-Object pscustomobject
            # Properties 
            $obj | Add-Member NoteProperty "inspection_date" $dataDate
            $obj | Add-Member NoteProperty "cable_section_id" $sid
            $obj | Add-Member NoteProperty "cable_number" '1'
            $obj | Add-Member NoteProperty "section_number" $sn
            $obj | Add-Member NoteProperty "original_image1_path" $img0
            $obj | Add-Member NoteProperty "original_image2_path" $img1
            $obj | Add-Member NoteProperty "original_image3_path" $img2
            $obj | Add-Member NoteProperty "original_image4_path" $img3
            $obj | Add-Member NoteProperty "flagged" $flag
            $obj | Add-Member NoteProperty "flag_reason" $flagReason
            $obj | Add-Member NoteProperty "diameter" $diameter

            $jsonObject += $obj

            # Write-Host $jsonObject
            $ProgressBar1.PerformStep();
            $FileName.text = "Moving Cable 1 Processed Data`n`n";
            $FileName.Refresh();

            # Update section id
            $sid++;
        }
    }
    $dataInPath = 'views/data/unprocessed/images/cable1/';
    Move-Item -Path $dataInPath -Destination $dataOutPath -Force | Out-Null

    # GET CABLE 2
    $txtContent2 = Get-Content -Path "views/data/unprocessed/images/cable2/diameter2.txt"

    if($null -ne $txtContent2 -and $txtContent2.count -ne 0){
        # Get images from each cam
        $cam0 = Get-ChildItem -Path 'views/data/unprocessed/images/cable2/cam0/' -Recurse
            Where-Object { $_.Extension -ne '.jpg' }

        $cam1 = Get-ChildItem -Path 'views/data/unprocessed/images/cable2/cam1/' -Recurse
            Where-Object { $_.Extension -ne '.jpg' }
        
        $cam2 = Get-ChildItem -Path 'views/data/unprocessed/images/cable2/cam2/' -Recurse
            Where-Object { $_.Extension -ne '.jpg' }
        
        $cam3 = Get-ChildItem -Path 'views/data/unprocessed/images/cable2/cam3/' -Recurse
            Where-Object { $_.Extension -ne '.jpg' }

        # Count how many files are in the cable folder 
        $ProgressBar1.Minimum = 0;
        $ProgressBar1.Maximum = $txtContent2.count;
        $ProgressBar1.Value = 0;
        $ProgressBar1.Step = 1;
        $ProgressBar1.Refresh();

        $FileName.text = "Running Defect Detection on Cable 2`n`n";
        $FileName.Refresh();

        # DEFECT DETECTION Files
        Move-Item -Path .\openCV_docker\DefectDetection.py -Destination .\views\data\unprocessed\images\cable2 -Force | Out-Null
        Move-Item -Path .\openCV_docker\Dockerfile -Destination .\views\data\unprocessed\images\cable2 -Force | Out-Null

        # Move directory to launch docker container
        Set-Location -Path .\views\data\unprocessed\images\cable2

        $job = Start-Job { 
            # Add cam folders to container
            docker build --tag opencv . | Out-Null
            
            # Run container
            docker run --name opencv opencv

            $OutputVariable = docker inspect -f '{{.State.Running}}' opencv | Out-String
            $OutputVariable = $OutputVariable -replace '[\W]', ''

            # Wait for container to finish 
            while ($OutputVariable -eq 'true'){
                Start-Sleep 1
                $OutputVariable = docker inspect -f '{{.State.Running}}' opencv | Out-String
                $OutputVariable = $OutputVariable -replace '[\W]', ''
            }
            
        }
        Wait-Job $job
        Receive-Job $job 
        Remove-Job $job

        # Copy defect.txt file from container to cable folder
        docker cp opencv:defects.txt defects2.txt

        # Remove opencv container
        docker rm opencv

        # Reset Defect programs
        Set-Location -Path ../../../../..
        Move-Item -Path .\views\data\unprocessed\images\cable2\DefectDetection.py -Destination .\openCV_docker -Force | Out-Null
        Move-Item -Path .\views\data\unprocessed\images\cable2\Dockerfile -Destination .\openCV_docker -Force | Out-Null

        # Read the defect file
        $defectContent2 = Get-Content -Path "views/data/unprocessed/images/cable2/defects2.txt"


        For($i = 0; $i -lt $txtContent2.count; $i++) {

            # Create variables for the JSON payload
            $line = [string]$txtContent2[$i]
            $sn, $diameter = $line.split(' ');
            $img0 = "data/"+ $folderDate +"/images/cable2/cam0/"+ [string]$cam0[$i];
            $img1 = "data/"+ $folderDate +"/images/cable2/cam1/" + [string]$cam1[$i];
            $img2 = "data/"+ $folderDate +"/images/cable2/cam2/" + [string]$cam2[$i];
            $img3 = "data/"+ $folderDate +"/images/cable2/cam3/" + [string]$cam3[$i];

            # Get flags from defects txt
            $dline = [string]$defectContent2[$i]
            $ignore, $flagReason = $dline.split(' ');
            
            $flagReason = [string]$flagReason
            if ($flagReason -eq "none"){
                $flag = "false"
            }
            else {
                $flag = "true"
            }
            
            # Individual object
            $obj = New-Object pscustomobject
            # Properties 
            $obj | Add-Member NoteProperty "inspection_date" $dataDate
            $obj | Add-Member NoteProperty "cable_section_id" $sid
            $obj | Add-Member NoteProperty "cable_number" '2'
            $obj | Add-Member NoteProperty "section_number" $sn
            $obj | Add-Member NoteProperty "original_image1_path" $img0
            $obj | Add-Member NoteProperty "original_image2_path" $img1
            $obj | Add-Member NoteProperty "original_image3_path" $img2
            $obj | Add-Member NoteProperty "original_image4_path" $img3
            $obj | Add-Member NoteProperty "flagged" $flag
            $obj | Add-Member NoteProperty "flag_reason" $flagReason
            $obj | Add-Member NoteProperty "diameter" $diameter

            $jsonObject += $obj
            
            # Write-Host $jsonObject
            $ProgressBar1.PerformStep();
            $FileName.text = "Moving Cable 2 Processed Data`n`n";
            $FileName.Refresh();

            # Update section id
            $sid++;
        }
    }
    $dataInPath = 'views/data/unprocessed/images/cable2/';
    Move-Item -Path $dataInPath -Destination $dataOutPath -Force | Out-Null

    # GET CABLE 3
    $txtContent3 = Get-Content -Path "views/data/unprocessed/images/cable3/diameter3.txt"

    if($null -ne $txtContent3 -and $txtContent3.count -ne 0){
        # Get images from each cam
        $cam0 = Get-ChildItem -Path 'views/data/unprocessed/images/cable3/cam0/' -Recurse
            Where-Object { $_.Extension -ne '.jpg' }

        $cam1 = Get-ChildItem -Path 'views/data/unprocessed/images/cable3/cam1/' -Recurse
            Where-Object { $_.Extension -ne '.jpg' }
        
        $cam2 = Get-ChildItem -Path 'views/data/unprocessed/images/cable3/cam2/' -Recurse
            Where-Object { $_.Extension -ne '.jpg' }
        
        $cam3 = Get-ChildItem -Path 'views/data/unprocessed/images/cable3/cam3/' -Recurse
            Where-Object { $_.Extension -ne '.jpg' }

        # Count how many files are in the cable folder 
        $ProgressBar1.Minimum = 0;
        $ProgressBar1.Maximum = $txtContent3.count;
        $ProgressBar1.Value = 0;
        $ProgressBar1.Step = 1;
        $ProgressBar1.Refresh();

        $FileName.text = "Running Defect Detection on Cable 3`n`n";
        $FileName.Refresh();

        # DEFECT DETECTION Files
        Move-Item -Path .\openCV_docker\DefectDetection.py -Destination .\views\data\unprocessed\images\cable3 -Force | Out-Null
        Move-Item -Path .\openCV_docker\Dockerfile -Destination .\views\data\unprocessed\images\cable3 -Force | Out-Null

        # Move directory to launch docker container
        Set-Location -Path .\views\data\unprocessed\images\cable3

        $job = Start-Job { 
            # Add cam folders to container
            docker build --tag opencv . | Out-Null
            
            # Run container
            docker run --name opencv opencv

            $OutputVariable = docker inspect -f '{{.State.Running}}' opencv | Out-String
            $OutputVariable = $OutputVariable -replace '[\W]', ''

            # Wait for container to finish 
            while ($OutputVariable -eq 'true'){
                Start-Sleep 1
                $OutputVariable = docker inspect -f '{{.State.Running}}' opencv | Out-String
                $OutputVariable = $OutputVariable -replace '[\W]', ''
            }
            
        }
        Wait-Job $job
        Receive-Job $job 
        Remove-Job $job

        # Copy defect.txt file from container to cable folder
        docker cp opencv:defects.txt defects3.txt

        # Remove opencv container
        docker rm opencv

        # Reset Defect programs
        Set-Location -Path ../../../../..
        Move-Item -Path .\views\data\unprocessed\images\cable3\DefectDetection.py -Destination .\openCV_docker -Force | Out-Null
        Move-Item -Path .\views\data\unprocessed\images\cable3\Dockerfile -Destination .\openCV_docker -Force | Out-Null

        # Read the defect file
        $defectContent3 = Get-Content -Path "views/data/unprocessed/images/cable3/defects3.txt"


        For($i = 0; $i -lt $txtContent3.count; $i++) {

            # Create variables for the JSON payload
            $line = [string]$txtContent3[$i]
            $sn, $diameter = $line.split(' ');
            $img0 = "data/"+ $folderDate +"/images/cable3/cam0/"+ [string]$cam0[$i];
            $img1 = "data/"+ $folderDate +"/images/cable3/cam1/" + [string]$cam1[$i];
            $img2 = "data/"+ $folderDate +"/images/cable3/cam2/" + [string]$cam2[$i];
            $img3 = "data/"+ $folderDate +"/images/cable3/cam3/" + [string]$cam3[$i];

            # Get flags from defects txt
            $dline = [string]$defectContent3[$i]
            $ignore, $flagReason = $dline.split(' ');
            
            $flagReason = [string]$flagReason
            if ($flagReason -eq "none"){
                $flag = "false"
            }
            else {
                $flag = "true"
            }
            
            # Individual object
            $obj = New-Object pscustomobject
            # Properties 
            $obj | Add-Member NoteProperty "inspection_date" $dataDate
            $obj | Add-Member NoteProperty "cable_section_id" $sid
            $obj | Add-Member NoteProperty "cable_number" '3'
            $obj | Add-Member NoteProperty "section_number" $sn
            $obj | Add-Member NoteProperty "original_image1_path" $img0
            $obj | Add-Member NoteProperty "original_image2_path" $img1
            $obj | Add-Member NoteProperty "original_image3_path" $img2
            $obj | Add-Member NoteProperty "original_image4_path" $img3
            $obj | Add-Member NoteProperty "flagged" $flag
            $obj | Add-Member NoteProperty "flag_reason" $flagReason
            $obj | Add-Member NoteProperty "diameter" $diameter

            $jsonObject += $obj
            # Write-Host $jsonObject
            $ProgressBar1.PerformStep();
            $FileName.text = "Moving Cable 3 Processed Data`n`n";
            $FileName.Refresh();

            # Update section id
            $sid++;
        }
    }
    $dataInPath = 'views/data/unprocessed/images/cable3';
    Move-Item -Path $dataInPath -Destination $dataOutPath -Force | Out-Null

    # GET CABLE 4
    $txtContent4 = Get-Content -Path "views/data/unprocessed/images/cable4/diameter4.txt"

    if($null -ne $txtContent4 -and $txtContent4.count -ne 0){
        # Get images from each cam
        $cam0 = Get-ChildItem -Path 'views/data/unprocessed/images/cable4/cam0/' -Recurse
            Where-Object { $_.Extension -ne '.jpg' }

        $cam1 = Get-ChildItem -Path 'views/data/unprocessed/images/cable4/cam1/' -Recurse
            Where-Object { $_.Extension -ne '.jpg' }
        
        $cam2 = Get-ChildItem -Path 'views/data/unprocessed/images/cable4/cam2/' -Recurse
            Where-Object { $_.Extension -ne '.jpg' }
        
        $cam3 = Get-ChildItem -Path 'views/data/unprocessed/images/cable4/cam3/' -Recurse
            Where-Object { $_.Extension -ne '.jpg' }

        # Count how many files are in the cable folder 
        $ProgressBar1.Minimum = 0;
        $ProgressBar1.Maximum = $txtContent4.count;
        $ProgressBar1.Value = 0;
        $ProgressBar1.Step = 1;
        $ProgressBar1.Refresh();

        $FileName.text = "Running Defect Detection on Cable 4`n`n";
        $FileName.Refresh();

        # DEFECT DETECTION Files
        Move-Item -Path .\openCV_docker\DefectDetection.py -Destination .\views\data\unprocessed\images\cable4 -Force | Out-Null
        Move-Item -Path .\openCV_docker\Dockerfile -Destination .\views\data\unprocessed\images\cable4 -Force | Out-Null

        # Move directory to launch docker container
        Set-Location -Path .\views\data\unprocessed\images\cable4

        $job = Start-Job { 
            # Add cam folders to container
            docker build --tag opencv . | Out-Null
            
            # Run container
            docker run --name opencv opencv

            $OutputVariable = docker inspect -f '{{.State.Running}}' opencv | Out-String
            $OutputVariable = $OutputVariable -replace '[\W]', ''

            # Wait for container to finish 
            while ($OutputVariable -eq 'true'){
                Start-Sleep 1
                $OutputVariable = docker inspect -f '{{.State.Running}}' opencv | Out-String
                $OutputVariable = $OutputVariable -replace '[\W]', ''
            }
            
        }
        Wait-Job $job
        Receive-Job $job 
        Remove-Job $job

        # Copy defect.txt file from container to cable folder
        docker cp opencv:defects.txt defects4.txt

        # Remove opencv container
        docker rm opencv

        # Reset Defect programs
        Set-Location -Path ../../../../..
        Move-Item -Path .\views\data\unprocessed\images\cable4\DefectDetection.py -Destination .\openCV_docker -Force | Out-Null
        Move-Item -Path .\views\data\unprocessed\images\cable4\Dockerfile -Destination .\openCV_docker -Force | Out-Null

        # Read the defect file
        $defectContent4 = Get-Content -Path "views/data/unprocessed/images/cable4/defects4.txt"


        For($i = 0; $i -lt $txtContent4.count; $i++) {

            # Create variables for the JSON payload
            $line = [string]$txtContent4[$i]
            $sn, $diameter = $line.split(' ');
            $img0 = "data/"+ $folderDate +"/images/cable4/cam0/"+ [string]$cam0[$i];
            $img1 = "data/"+ $folderDate +"/images/cable4/cam1/" + [string]$cam1[$i];
            $img2 = "data/"+ $folderDate +"/images/cable4/cam2/" + [string]$cam2[$i];
            $img3 = "data/"+ $folderDate +"/images/cable4/cam3/" + [string]$cam3[$i];

            # Get flags from defects txt
            $dline = [string]$defectContent4[$i]
            $ignore, $flagReason = $dline.split(' ');
            
            $flagReason = [string]$flagReason
            if ($flagReason -eq "none"){
                $flag = "false"
            }
            else {
                $flag = "true"
            }
            
            # Individual object
            $obj = New-Object pscustomobject
            # Properties 
            $obj | Add-Member NoteProperty "inspection_date" $dataDate
            $obj | Add-Member NoteProperty "cable_section_id" $sid
            $obj | Add-Member NoteProperty "cable_number" '4'
            $obj | Add-Member NoteProperty "section_number" $sn
            $obj | Add-Member NoteProperty "original_image1_path" $img0
            $obj | Add-Member NoteProperty "original_image2_path" $img1
            $obj | Add-Member NoteProperty "original_image3_path" $img2
            $obj | Add-Member NoteProperty "original_image4_path" $img3
            $obj | Add-Member NoteProperty "flagged" $flag
            $obj | Add-Member NoteProperty "flag_reason" $flagReason
            $obj | Add-Member NoteProperty "diameter" $diameter

            $jsonObject += $obj

            # Write-Host $jsonObject
            $ProgressBar1.PerformStep();
            $ProgressBar1.Refresh();
            $FileName.text = "Moving Cable 4 Processed Data`n`n";
            $FileName.Refresh();

            # Update section id
            $sid++;
        }
    }   
    $dataInPath = 'views/data/unprocessed/images/cable4';
    Move-Item -Path $dataInPath -Destination $dataOutPath -Force | Out-Null

    # Convert Object Array to Json Payload
    $jsonObject | ConvertTo-Json -depth 100 | Set-Content "newData.json"

    # Alert the user the processing has finished and been synchronized
    $wshell = New-Object -ComObject Wscript.Shell

    $FileName.text = "Processing Completed`n`n";
    $FileName.Refresh();
    $wshell.Popup("Launch Inspection Viewer Application to view the results.",0,"Processing Completed",0x1)
}

function btnInspection_Click { 
    # Count how many files are in the cable folder 
    $ProgressBar1.Visible = $false;
    $FileName.text = "Web Application is Running`n`n";
    $FileName.Refresh();

    # Launch Web Application
    Write-Output "docker-compose up"
    docker-compose up -d 

    # Wait for Application to Laucnh
    $Button3.Enabled = $false
    Start-Sleep 4
    Start-Process -FilePath http://localhost

    # Button to shutdown web application
    $ShutdownIVA.Enabled = $true
    
    
}

function btnInspectionShutdown_Click { 
    Write-Output "docker-compose stop"
    docker-compose stop 

    # Disable shutdown and enable launch buttons
    $ShutdownIVA.Enabled = $false
    $Button3.Enabled = $true
    $FileName.text = "Web Application has Shutdown`n`n";
    $FileName.Refresh();
}

function btnBackup_Click { 
    $Button4.Enabled = $false

    $originPath = "views/data/images";

    # Copy Drive Data to Docker folder
    if ((Test-Path -path "views/data")) {

        # Find all folder names in data with images
        $names = Get-ChildItem $originPath -Recurse | Select-Object FullName
        # Write-Host $names[0].FullName

        #Progress Bar Setup
        $ProgressBar1.Visible = $true;
        $ProgressBar1.Minimum = 0;
        $ProgressBar1.Maximum = 4 * $names.count;
        $ProgressBar1.Value = 0;
        $ProgressBar1.Step = 1;
        $FileName.Visible = $true;

        # ASK USER TO CONFIRM MOVE 

        $wshell = New-Object -ComObject Wscript.Shell
        For($a = 0; $a -lt $names.count; $a++){
            $folderNameIndex = $names[$a].FullName.IndexOf("data\") + 5;

            if ([string]$names[$a].FullName -like "*unprocessed*"){
                $ProgressBar1.Value += 4;
                # $ProgressBar1.PerformStep();
                # $ProgressBar1.PerformStep();
                # $ProgressBar1.PerformStep();
                # $ProgressBar1.PerformStep();
                continue;

            } else {
            
                For($i = 1; $i -le 4; $i++){
                    
                    $ProgressBar1.PerformStep();
                    $FileName.text = "Copying Inspection Data " + $a + " out of " + $names.count + "`n`n";
                    $FileName.Refresh();

                    $dataInPath = $names[$a].FullName + '\cable' + $i;
                    $dataOutPath = $env:USERPROFILE + '\Desktop\backupData\' + $names[$a].FullName.substring($folderNameIndex, 17) + '\cable' + $i + '\';
                    Copy-Item -Path $dataInPath -Destination $dataOutPath -Recurse | Out-Null
                    # Write-Host $dataInPath

                }
            }


        }

        # Remove-Item $extDrivePath + '/cable1'
        # Remove-Item $extDrivePath + '/cable2'
        # Remove-Item $extDrivePath + '/cable3'
        # Remove-Item $extDrivePath + '/cable4'
        # Remove-Item $extDrivePath
        # Alert the user the copy has finished
        $FileName.text = "Finished Transfer`n`n"
        $FileName.Refresh();
        $wshell.Popup("Transfer Complete",0,"Done",0x1)
    } else{

        $wshell.Popup("External Drive Missing Files",0,"Error",0x1)
    }

}


#Write your logic code here

[void]$TestDemoForm.ShowDialog()