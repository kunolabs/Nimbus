' Displays a simple message after a successful Repair to inform the user
' that no reboot is required.

Function ShowRepairComplete()
    Dim msg
    msg = "Nimbus repair completed successfully. No reboot is required."
    MsgBox msg, vbInformation + vbOKOnly, "Nimbus Repair"
    ShowRepairComplete = 0
End Function

