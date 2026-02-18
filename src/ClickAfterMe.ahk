#Requires AutoHotkey v2.0

; Global variables
clickLocations := []
isRecording := false
isReplaying := false
clickDelay := 250  ; Default Delay between clicks in milliseconds
replayIndex := 0
replayTimer := 0
tooltipTimer := 0  ; Timer for clearing tooltips
tooltipTimeout := 10000  ; 10 seconds in milliseconds
ToolTip "CAM - Start"
ResetTooltipTimer()

; Display usage instructions on launch
MsgBox("Click After Me - Usage Guide`n`n"
    . "ALT+= : Toggle Recording`n"
    . "CTRL+] : Increase Click Delay`n"
    . "CTRL+[ : Decrease Click Delay`n"
    . "CTRL+ALT+[ : Reset Click Delay (250ms)`n"
    . "CTRL+= : Replay Recorded Clicks`n"
    . "CTRL+ALT+= : Clear Recordings, repeat to Exit`n`n"
    . "Default delay: 250ms", "Click After Me - Usage")

; Function to reset tooltip timeout
ResetTooltipTimer() {
    global tooltipTimer, tooltipTimeout
    if (tooltipTimer) {
        SetTimer(tooltipTimer, 0)
    }
    tooltipTimer := ObjBindMethod(ClearTooltip)
    SetTimer(tooltipTimer, tooltipTimeout)
}

; Function to clear tooltip
ClearTooltip() {
    ToolTip
}

; Increase delay hotkey: CTRL-]
^]:: {
    ; Use if/else chain for reliable relational checks
    if (clickDelay >= 60000)
        ChangeClickDelay(60000)
    else if (clickDelay >= 10000)
        ChangeClickDelay(10000)
    else if (clickDelay >= 1000)
        ChangeClickDelay(1000)
    else if (clickDelay >= 500)
        ChangeClickDelay(100)
    else if (clickDelay >= 250)
        ChangeClickDelay(50)
    else if (clickDelay >= 50)
        ChangeClickDelay(10)
    else if (clickDelay >= 20)
        ChangeClickDelay(5)
    else if (clickDelay >= 5)
        ChangeClickDelay(1)
    else
        ChangeClickDelay(0)
    ResetTooltipTimer()
}

; Decrease delay hotkey: CTRL-[
^[:: {
    ; Use if/else chain for reliable relational checks
    if (clickDelay <= 5)
        ChangeClickDelay(0)
    else if (clickDelay <= 20)
        ChangeClickDelay(-1)
    else if (clickDelay <= 50)
        ChangeClickDelay(-5)
    else if (clickDelay <= 250)
        ChangeClickDelay(-10)
    else if (clickDelay <= 500)
        ChangeClickDelay(-50)
    else if (clickDelay <= 1000)
        ChangeClickDelay(-100)
    else if (clickDelay <= 10000)
        ChangeClickDelay(-1000)
    else if (clickDelay <= 60000)
        ChangeClickDelay(-10000)
    else if (clickDelay <= 120000)
        ChangeClickDelay(-60000)
    else
        ChangeClickDelay(-60000)

    ResetTooltipTimer()
}

;Reset delay hotkey: CTRL-ALT-[
^![:: {
    ChangeClickDelay(-99)
    ResetTooltipTimer()
}

;Reset delay hotkey: CTRL-ALT-]
^!]:: {
    ChangeClickDelay(-99)
    ResetTooltipTimer()
}

; Terminate program hotkey: CTRL-ALT-=
^!=:: {
    global clickLocations
    
    if (clickLocations.Length > 0) {
        ; Reinitialize the array
        clickLocations := []
        ToolTip "Click locations cleared."
        ResetTooltipTimer()
    } else {
        ; Exit the app
        ExitApp
    }
}

; Toggle recording hotkey: ALT-=
!=:: {
    global isRecording, clickLocations
    
    if (isRecording) {
        ; Stop recording
        isRecording := false
        Tooltip "Recording stopped. " . clickLocations.Length . " clicks recorded."
        ResetTooltipTimer()
    } else {
        ; Start recording
        isRecording := true
        clickLocations := []
        ToolTip "Recording clicks... Press ALT+= to stop"
        ResetTooltipTimer()
    }
}

; Capture left mouse click while recording
~LButton:: {
    global isRecording, clickLocations
    if (isRecording) {
        ; Get current mouse position
        MouseGetPos(&xpos, &ypos)
        
        ; Add to array
        clickLocations.Push({x: xpos, y: ypos})
        
        ; Provide visual feedback
        ToolTip "Click " . clickLocations.Length
        ResetTooltipTimer()
    }
}

; Replay hotkey: CTRL-=
^=:: {
    global clickLocations, clickDelay, isReplaying, replayIndex, replayTimer
    
    if (isReplaying) {
        ; Stop replaying
        isReplaying := false
        if (replayTimer) {
            SetTimer(replayTimer, 0)
            replayTimer := 0
        }
        ToolTip
        return
    }
    
    if (clickLocations.Length = 0) {
        return
    }
    
    ; Start replaying loop
    isReplaying := true
    replayIndex := 0
    ToolTip "Replaying " . clickLocations.Length . " clicks... Press CTRL+= to stop"
    ResetTooltipTimer()
    
    ; Create timer for replay
    replayTimer := ObjBindMethod(DoReplay)
    SetTimer(replayTimer, clickDelay)
}

ChangeClickDelay(ClickDelayModifier) {
    global clickDelay
    
    if (ClickDelayModifier = -99) {
        ClickDelay := 250
        ToolTip "Click delay reset " . clickDelay . " ms"
    }
    else {
        clickDelay += ClickDelayModifier
        if (clickDelay < 5) {
            clickDelay := 5
        }
        If (clickDelay <= 1000) {
            delayNum := clickDelay . " ms"
        }
        else if (clickDelay < 60000) {
            delayNum := clickDelay / 1000 . " s"
        }
        else {
            delayNum := clickDelay / 60000 . " min"
       
            
        }
        ToolTip "Click delay " . delayNum
    }
    ResetTooltipTimer()
}

; Function to handle replay
DoReplay() {
    global clickLocations, clickDelay, isReplaying, replayIndex, replayTimer
    
    if (!isReplaying) {
        return
    }
    
    if (replayIndex >= clickLocations.Length) {
        replayIndex := 0  ; Loop back to start
    }
    
    clickPos := clickLocations[replayIndex + 1]
    MouseMove(clickPos.x, clickPos.y)
    Click
    ToolTip "Playing click " . (replayIndex + 1)
    ResetTooltipTimer()
    replayIndex++
}


