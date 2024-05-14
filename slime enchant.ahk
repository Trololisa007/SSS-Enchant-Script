#Requires AutoHotkey v2.0
SendMode("Input")

RarityIndex := ["0xd00e1e", "0xa18714", "0x755bf6", "0x1034e1", "0x1caa16", "0x828ea0"]

!q::
{
    ExitApp()
}

!s::
{
    CoordMode("Mouse", "Screen")
    CoordMode("Pixel", "Screen")
    MouseGetPos(&x, &y)
    ; MouseClick("WheelDown", x, y)
    MsgBox(x " " y)
}

!r::
{
    window := Gui()
    window.AddText(, "Slime Slaying Simulator Macro GUI")
    window.com := window.AddCheckbox("vCommon", "Common")
    window.unc := window.AddCheckbox("vUncommon", "Uncommon")
    window.rar := window.AddCheckbox("vRare Checked", "Rare")
    window.fab := window.AddCheckbox("vFabled Checked", "Fabled")
    window.leg := window.AddCheckbox("vLegendary Checked", "Ledgendary")
    window.myt := window.AddCheckbox("vMythic Checked", "Mythic")
    window.com.OnEvent("Click", Update)
    window.unc.OnEvent("Click", Update)
    window.rar.OnEvent("Click", Update)
    window.fab.OnEvent("Click", Update)
    window.leg.OnEvent("Click", Update)
    window.myt.OnEvent("Click", Update)


    ; value location
    window.AddText(, "Value Location")
    window.valpos := window.AddText("xs yp+18 w80", "952, 479")
    window.AddButton("x+20 w40 yp-17", "Pick Location").OnEvent("Click", getmouse.Bind(window.valpos))

    ; button location
    window.AddText("xs", "Button Location")
    window.interactpos := window.AddText("xs yp+18 w80", "945, 764")
    window.AddButton("x+20 w40 yp-17", "Pick Location").OnEvent("Click", getmouse.Bind(window.interactpos))

    ; mass enchant location
    window.AddText("xs", "Square Location")
    window.InvBox := window.AddText("xs yp+18 w80", "560, 422")
    window.AddButton("x+20 w40 yp-17", "Pick Location").OnEvent("Click", getmouse.Bind(window.InvBox))

    ; inv button location
    window.AddText("xs", "Inv Button Location")
    window.InvLoc := window.AddText("xs yp+18 w80", "957, 395")
    window.AddButton("x+20 w40 yp-17", "Pick Location").OnEvent("Click", getmouse.Bind(window.InvLoc))

    ; equip button location
    window.AddText("xs", "Equipment Button Location")
    window.Equip := window.AddText("xs yp+18 w80", "1843, 307")
    window.AddButton("x+20 w40 yp-17", "Pick Location").OnEvent("Click", getmouse.Bind(window.Equip))

    ; debug
    window.AddText("xs", "debug")
    window.debug := window.AddText("xs yp+18 w80", "957, 395")
    window.AddButton("x+20 w40 yp-17", "debug").OnEvent("Click", debug.Bind(window.debug))

    window.AddButton("xm w120", "Start").OnEvent("Click", start,)
    window.AddButton("xm w120", "Mass").OnEvent("Click", InventoryManager,)
    window.Show("x1500")

    pausekey := "F7"
    UpdateList := InitArray(RarityIndex.Length)
    Update()
    return

    debug(*) {
        Sleep(1500)
        MsgBox(getInvScaling(&upper, &lower, "0x00ff00"))
    }

    InitArray(n, Char := 0) {
        local String := Format("{:0" n "}", "")
        return Char = 0 ? StrSplit(String) : StrSplit(StrReplace(String, 0, Char))
    }

    Update(*) {
        UpdateList := [window.myt.value, window.leg.value, window.fab.value, window.rar.value, window.unc.value, window.com.value]

    }

    getmouse(WinCont, *) {
        window.Hide()
        KeyWait("LButton", "D")
        MouseGetPos &mousex, &mousey
        str := mousex ", " mousey
        WinCont.value := str
        window.Show()
    }


    ; begins auto-enchanting
    start(*) {
        CoordMode("Mouse", "Screen")
        CoordMode("Pixel", "Screen")

        ; hook := InputHook()
        ; hook.KeyOpt(pausekey, "N")
        ; keypress := 1
        ; hook.OnKeyDown("") := ((*) => (keypress := 0))

        value := StrSplit(window.valpos.value, ", ")
        button := StrSplit(window.interactpos.value, ", ")

        ;get global coordinates of roblox app
        WinGetPos(&Robx, &Roby, &Robw, &Robh, "Roblox")


        while (true) {
            Click(button[1] + Robx " " button[2] + Roby)
            Click()
            Sleep(3500)
            while (A_Index <= RarityIndex.Length) {
                Px := 0
                Py := 0
                result := PixelSearch(&Px, &Py, value[1] - 50 + Robx, value[2] - 50 + Roby, value[1] + 50 + Robx, value[2] + 50 + Roby, RarityIndex[A_Index], 20)
                if (result AND UpdateList[A_Index]) {
                    break 2
                }
            }


        }
        window.Flash()

    }

    ; enchants entire inventory
    InventoryManager(*) {
        Sleep(500)
        CoordMode("Mouse", "Screen")
        CoordMode("Pixel", "Screen")
        ; CHANGE LATER

        InvBox := StrSplit(window.InvBox.value, ", ")
        InvLoc := StrSplit(window.InvLoc.value, ", ")
        EquipLoc := StrSplit(window.Equip.value, ", ")
        override := 12
        endScroll := 1
        overscroll := 0
        NumLines := 3
        WinGetPos(&Robx, &Roby, &Robw, &Robh, "Roblox")
        MondoList := []
        InvBox[1] := InvBox[1] + Robx
        InvBox[2] := InvBox[2] + Roby

        SetDefaultMouseSpeed(50)
        MouseClick("Left", EquipLoc[1] + Robx, EquipLoc[2] + Roby, 2)
        Sleep(1000)

        MouseMove(InvBox[1], InvBox[2], "50")
        boxDimention := getInvScaling(&upper, &lower, "0x00ff00")
        ; MsgBox("got scale")
        BoxScaleY := boxDimention * 0.965517

        ; add initial 7 items to list
        MondoList.Push([InvBox[1] + 2 * boxDimention, InvBox[2], 0])
        MondoList.Push([InvBox[1], InvBox[2] + BoxScaleY, 0])
        MondoList.Push([InvBox[1] + boxDimention, InvBox[2] + BoxScaleY, 0])
        MondoList.Push([InvBox[1] + 2 * boxDimention, InvBox[2] + BoxScaleY, 0])
        MondoList.Push([InvBox[1], InvBox[2] + 2 * BoxScaleY, 0])
        MondoList.Push([InvBox[1] + boxDimention, InvBox[2] + 2 * BoxScaleY, 0])
        MondoList.Push([InvBox[1] + 2 * boxDimention, InvBox[2] + 2 * BoxScaleY, 0])

        ; MsgBox(MondoList.Length)

        ; MouseClick("WheelDown", InvBox[1], InvBox[2])
        ; Sleep(500)
        ; getInvScaling(&upper2, &lower2)
        ; MouseClick("WheelUp", InvBox[1], InvBox[2])

        ; MouseClick("Left", InvBox[1], InvBox[2])


        ; if after scrolling one tick the second upper value is less
        ; than the previous one, it means a line was skipped, and we
        ; need to account for that in our coordinate calculations
        ; if (upper2 < upper) {
        ;     overscroll := 1
        ;     NumLines += 3
        ; } else {
        ;     NumLines++
        ; }

        ; repeatColor := "0xffffff"
        ; while (endScroll) {
        ;     MouseClick("WheelDown", InvBox[1], InvBox[2])
        ;     Sleep(500)
        ;     if (repeatColor == getMousePixelColor())
        ;         MsgBox("first grey")
        ;     break

        ;     #Warn Unreachable, Off
        ;     if (tollerance("0x1a1715", getMousePixelColor(), 5)) { ; should be no issues here if you play at good aspect ratio
        ;         MouseClick("WheelDown", InvBox[1], InvBox[2])
        ;         Sleep(500)
        ;         if (tollerance("0x1a1715", getMousePixelColor(), 5)) {
        ;             endScroll := 0
        ;             break
        ;         }
        ;         NumLines += 2
        ;     }
        ;     ; failsafe in case pointer gets too close to edge of item
        ;     getInvScaling(&upper, &lower)
        ;     if (InvBox[2] - lower < 10 || upper - InvBox[2] < 10) {
        ;         InvBox[2] := ((upper + lower) / 2)
        ;     }

        ;     NumLines++
        ;     MondoList.Push([InvBox[1] - 2 * boxDimention, InvBox[2], NumLines])
        ;     MondoList.Push([InvBox[1] - 1 * boxDimention, InvBox[2], NumLines])
        ;     MondoList.Push([InvBox[1], InvBox[2], NumLines])
        ;     repeatColor := getMousePixelColor()
        ; }
        ; if (tollerance("0x1a1715", PixelGetColor(InvBox[1] - 2 * boxDimention, InvBox[2], NumLines), 5)) {
        ;     MondoList.Push([InvBox[1] - 2 * boxDimention, InvBox[2], NumLines])s
        ; }w
        ; if (tollerance("0x1a1715", PixelGetColor(InvBox[1] - 1 * boxDimention, InvBox[2], NumLines), 5)) {
        ;     MondoList.Push([InvBox[1] - 2 * boxDimention, InvBox[2], NumLines])
        ; }
        ; if (tollerance("0x1a1715", PixelGetColor(InvBox[1], InvBox[2], NumLines), 5)) {
        ;     MondoList.Push([InvBox[1], InvBox[2], NumLines])
        ; }w

        ; MouseClick("Left", InvBox[1] - 2 * boxDimention, InvBox[2])
        ; Sleep(100)

        inv2 := StrSplit(window.InvBox.value, ", ")
        ; MsgBox('exit window')
        MouseMove(EquipLoc[1] + Robx, EquipLoc[2] + Roby, 100)
        Sleep(200)
        MouseClick("Left", EquipLoc[1] + Robx, EquipLoc[2] + Roby, 1)
        Sleep(500)
        Send("{S Down}")
        Sleep(150)
        Send("{S Up}")
        Send("{W Down}")
        Sleep(150)
        Send("{W Up}")
        MsgBox("wait")
        Sleep(2000)
        MouseMove(InvLoc[1] + Robx, InvLoc[2] + Roby, 100)
            MouseClick("Left", InvLoc[1] + Robx, InvLoc[2] + Roby)

        
        ; MsgBox("now going throug list")
        for lst in MondoList {
            ; MouseClick("Left", InvLoc[1] + Robx, InvLoc[2] + Roby)
            MouseMove(InvLoc[1] + Robx, InvLoc[2] + Roby, 100)
            MouseClick("Left", InvLoc[1] + Robx, InvLoc[2] + Roby)
            Sleep(300)
            loop lst[3] {
                MouseClick("WheelDown", inv2[1] + Robx, inv2[2] + Roby)
                Sleep(300)
            }
            MouseMove(lst[1], lst[2], 50)
            Sleep(500)
            MouseClick("Left", lst[1], lst[2])
            start()
            Sleep(300)
        }


    }


    getMousePixelColor() {
        MouseGetPos(&x, &y)
        return PixelGetColor(x, y)
    }

    ; gets upper and lower margin distances from the cursor location, returns height of box in pixels
    getInvScaling(&upper, &lower, hexval := "0x1a1715") {
        CoordMode("Mouse", "Screen")
        CoordMode("Pixel", "Screen")
        ;send 1 pixel probe out from box up and down to find box pixel size
        ;return the results
        MouseGetPos(&x, &y)
        offset := 1
        while (tollerance(PixelGetColor(x - offset, y - 20,), hexval, 20)) {
            offset++
        }
        upper := y - offset
        offset := 0
        while (tollerance(PixelGetColor(x + offset, y - 20,), hexval, 20)) {
            offset++
        }
        lower := y + offset
        return lower - upper
    }

    ; returns true if colors are within similarity margin
    tollerance(color1, color2, delta) {
        H1 := InStr(color1, "0x") ? color1 : (InStr(color1, "#") ? "0x" SubStr(color1, 2) : "0x" color1)
        H2 := InStr(color2, "0x") ? color2 : (InStr(color2, "#") ? "0x" SubStr(color2, 2) : "0x" color2)
        sqr11 := (H1 & 0xFF0000) >> 16
        sqr12 := (H2 & 0xFF0000) >> 16
        sqr21 := (H1 & 0xFF00) >> 8
        sqr22 := (H2 & 0xFF00) >> 8
        sqr31 := (H1 & 0xFF)
        sqr32 := (H2 & 0xFF)

        spaceval := Sqrt((sqr11 + sqr12) ^ 2 + (sqr21 + sqr22) ^ 2 + (sqr31 + sqr32) ^ 2)
        return spaceval <= delta
    }

    Arr2Str(Array) {
        Str := ""
        For Index, Value In Array
            Str := "|" . Value
        Str := LTrim(Str, "|") ; Remove leading pipes (|)
        MsgBox(Str)
    }


}