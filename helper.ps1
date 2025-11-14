Add-Type -AssemblyName PresentationFramework

###############################################################
#  Load or request recipient address (saved locally)
###############################################################

$ConfigFile = ".\recipient.cfg"
$RecipientAddress = ""

if (Test-Path $ConfigFile) {
    $RecipientAddress = Get-Content $ConfigFile -Raw
}
else {
    $RecipientWindow = New-Object System.Windows.Window
    $RecipientWindow.Title = "Set Recipient Address"
    $RecipientWindow.Width = 450
    $RecipientWindow.Height = 180
    $RecipientWindow.WindowStartupLocation = "CenterScreen"

    $RGrid = New-Object System.Windows.Controls.Grid
    $RGrid.Margin = "10"
    $RecipientWindow.Content = $RGrid

    for ($i=0; $i -lt 3; $i++) {
        $row = New-Object System.Windows.Controls.RowDefinition
        $row.Height = "Auto"
        $RGrid.RowDefinitions.Add($row)
    }

    $lbl = New-Object System.Windows.Controls.Label
    $lbl.Content = "Enter your recipient address:"
    $lbl.Margin = "5"
    $RGrid.AddChild($lbl)
    [System.Windows.Controls.Grid]::SetRow($lbl,0)

    $txt = New-Object System.Windows.Controls.TextBox
    $txt.Margin = "5"
    $txt.Height = 28
    $RGrid.AddChild($txt)
    [System.Windows.Controls.Grid]::SetRow($txt,1)

    $btn = New-Object System.Windows.Controls.Button
    $btn.Content = "Save"
    $btn.Margin = "5"
    $btn.Width = 80
    $btn.HorizontalAlignment = "Right"
    $RGrid.AddChild($btn)
    [System.Windows.Controls.Grid]::SetRow($btn,2)

    $btn.Add_Click({
        $script:RecipientAddress = $txt.Text.Trim()
        if ($script:RecipientAddress -ne "") {
            $script:RecipientAddress | Set-Content -Path $ConfigFile
        }
        $RecipientWindow.Close()
    })

    $null = $RecipientWindow.ShowDialog()
}

###############################################################
#                       MAIN WINDOW
###############################################################

$window = New-Object System.Windows.Window
$window.Title = "Midnight Scavenger Consolidation Tool"
$window.Width = 700
$window.Height = 720
$window.WindowStartupLocation = "CenterScreen"

$grid = New-Object System.Windows.Controls.Grid
$grid.Margin = "10"
$window.Content = $grid

for ($i = 0; $i -lt 14; $i++) {
    $row = New-Object System.Windows.Controls.RowDefinition
    $row.Height = "Auto"
    $grid.RowDefinitions.Add($row)
}

###############################################################
# Donor Address
###############################################################

$lblDonor = New-Object System.Windows.Controls.Label
$lblDonor.Content = "Donor Address:"
$lblDonor.Margin = "5"
$grid.AddChild($lblDonor)
[System.Windows.Controls.Grid]::SetRow($lblDonor, 0)

$txtDonor = New-Object System.Windows.Controls.TextBox
$txtDonor.Margin = "5"
$txtDonor.Height = 28
$grid.AddChild($txtDonor)
[System.Windows.Controls.Grid]::SetRow($txtDonor, 1)

###############################################################
# Recipient Address (stored)
###############################################################

$lblRec = New-Object System.Windows.Controls.Label
$lblRec.Content = "Recipient Address (stored):"
$lblRec.Margin = "5"
$grid.AddChild($lblRec)
[System.Windows.Controls.Grid]::SetRow($lblRec, 2)

$txtRec = New-Object System.Windows.Controls.TextBox
$txtRec.Margin = "5"
$txtRec.Height = 28
$txtRec.Text = $RecipientAddress
$grid.AddChild($txtRec)
[System.Windows.Controls.Grid]::SetRow($txtRec, 3)

###############################################################
# Copy Signing Message Button
###############################################################

$copyBtn = New-Object System.Windows.Controls.Button
$copyBtn.Content = "Copy Signing Message"
$copyBtn.Margin = "5"
$copyBtn.Width = 200
$copyBtn.HorizontalAlignment = "Left"
$grid.AddChild($copyBtn)
[System.Windows.Controls.Grid]::SetRow($copyBtn, 4)

$copyBtn.Add_Click({
    $msg = "Assign accumulated Scavenger rights to: $($txtRec.Text)"
    Set-Clipboard -Value $msg
})

###############################################################
# Signature field
###############################################################

$lblSig = New-Object System.Windows.Controls.Label
$lblSig.Content = "Signed Message:"
$lblSig.Margin = "5"
$grid.AddChild($lblSig)
[System.Windows.Controls.Grid]::SetRow($lblSig, 5)

$txtSig = New-Object System.Windows.Controls.TextBox
$txtSig.Margin = "5"
$txtSig.Height = 120
$txtSig.AcceptsReturn = $true
$grid.AddChild($txtSig)
[System.Windows.Controls.Grid]::SetRow($txtSig, 6)

###############################################################
# Submit Button
###############################################################

$submitBtn = New-Object System.Windows.Controls.Button
$submitBtn.Content = "Submit Consolidation"
$submitBtn.Height = 40
$submitBtn.Margin = "10"
$submitBtn.Width = 250
$submitBtn.HorizontalAlignment = "Center"
$grid.AddChild($submitBtn)
[System.Windows.Controls.Grid]::SetRow($submitBtn, 7)

###############################################################
# Result Output
###############################################################

$result = New-Object System.Windows.Controls.TextBlock
$result.Margin = "5"
$result.TextWrapping = "Wrap"
$result.Height = 320
$grid.AddChild($result)
[System.Windows.Controls.Grid]::SetRow($result, 8)

###############################################################
#    API CALL: donate_to → returns JSON
###############################################################

$submitBtn.Add_Click({

    $Donor     = $txtDonor.Text.Trim()
    $Recipient = $txtRec.Text.Trim()
    $Signature = $txtSig.Text.Trim()

    if ($Donor -eq "" -or $Recipient -eq "" -or $Signature -eq "") {
        $result.Text = "❌ Please fill in all fields."
        $result.Foreground = "Red"
        return
    }

    # IMPORTANT: URL must NOT wrap into next line
    $Url = "https://scavenger.prod.gd.midnighttge.io/donate_to/$Recipient/$Donor/$Signature"

    try {
        $response = Invoke-RestMethod `
            -Uri $Url `
            -Method POST `
            -Body "{}" `
            -ContentType "application/json" `
            -ErrorAction Stop

        $json = $response | ConvertTo-Json -Depth 10

        $result.Text = "✅ Success! Full API Response:`n`n$json"
        $result.Foreground = "Green"

        Add-Content -Path ".\midnight_consolidation_log.txt" -Value "`n--- SUCCESS ---`n$json`n"
    }
    catch {
        $err = $_.Exception.Message
        $result.Text = "❌ Error:`n$err"
        $result.Foreground = "Red"

        Add-Content -Path ".\midnight_consolidation_log.txt" -Value "`n--- ERROR ---`n$err`n"
    }

})

###############################################################
# Show window
###############################################################

$null = $window.ShowDialog()
