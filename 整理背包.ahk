FileEncoding, UTF-8
#NoEnv
#Warn
#SingleInstance ignore
#include JSON.ahk

SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Client
CoordMode, Pixel, client
SetDefaultMouseSpeed, 0
;SetMouseDelay, -1
;SetBatchLines, -1


Global DefaultPos := [[55,330,1],[116,330,1],[230,330,1],[230,386,1],[334,526,1],[547,330,1],[428,470,1],[1273,591,2],[1902,849,2],[640,142,1],[700,142,1]]
;Global DefaultPos := [[55,330,1],[116,330,1],[230,330,1],[230,386,1],[334,526,1],[547,330,1],[428,470,1],[1273,591,2],[1902,849,2],[640,142,1],[700,142,1]]
;;蜕变，改造，机会，增幅，Item, Chaos,重铸，左上，右下，下拉，第一页
global FunctionPos := []
global PageNow := 1
global whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
global row := 0
global step := 0
global name2page := []


TrapName := "背包整理By白侠"
Menu, Tray, NoStandard
Menu, Tray, Click,1
Menu, Tray, Add, Exit, OnEx
Menu, Tray, Default, Exit
Menu, Tray,Tip,%TrapName%

Gui Add, Button,gApply x16 y72 w239 h23, 应用
Gui Add, GroupBox, x8 y8 w256 h97, 设置框
Gui Add, CheckBox,vtonghuo x16 y24 w43 h23 Disabled Group Checked, 通货
Gui Add, CheckBox,vditu x64 y24 w43 h23 Checked, 地图
Gui Add, CheckBox,vjinsui x112 y24 w43 h23, 精髓
Gui Add, CheckBox,vsuipian x160 y24 w43 h23, 碎片
Gui Add, CheckBox,vhuashi x208 y24 w43 h23, 化石
Gui Add, CheckBox,vcapian x16 y48 w43 h23, 卡片
Gui Add, CheckBox,vbanzuan x64 y48 w130 h23 Disabled, 搬砖(60-74装备一套)
Gui Add, GroupBox, x8 y104 w256 h186, 设置信息
Gui Add, ListBox,vlisttxt x16 y120 w240 h160, !!!!!!!!!!!开始前请先应用!!!!!!!!!!!
Gui Add, Text, x8 y296 w120 h46 +0x200, 整理背包快捷键: F3 `n 交易放货快捷键: F4
Gui Add, Text, x8 y343 w120 h23 +0x200, 搬砖交易快捷键: F5
Gui Show, w272 h381, Window
return

Apply:
	GuiControlGet, vtonghuo
	GuiControlGet, vditu
	GuiControlGet, vjinsui
	GuiControlGet, vsuipian
	GuiControlGet, vhuashi
	GuiControlGet, vcapian
	GuiControlGet, vbanzhuan

	GetClientSize(WinExist("ahk_exe PathOfExile_x64.exe"), ww, hh)
	if hh = 0
	{
		MsgBox,0x40000,错误,未打开游戏 或者 游戏目前最小化
		return
	}
	FunctionPos := GetFunctionPos(ww,hh,DefaultPos)
	row := []
	loop,6 ;获取背包竖坐标
	{
		step := Floor((FunctionPos[9][2] - FunctionPos[8][2] + 1)/ 5) + 1
		row.push([FunctionPos[8][1],Floor(Step* (A_index - 1 )*(1.02) + FunctionPos[8][2])])
	}
	FileRead, name2page, name2page.json
	name2page := JSON.load(name2page)
	GuiControl,, listtxt, "done"
return

~F8::
	IfWinExist, Path of Exile ahk_exe PathOfExile_x64.exe
	{
		WinActivate, Path of Exile ahk_exe PathOfExile_x64.exe
		if FunctionPos.length() = 0
		{
			WinActivate, 装备制作 ahk_exe 装备制作By白侠.exe
			MsgBox,0x40000,设置错误,设置未应用
			return
		}
		gotopos(FunctionPos[10])
		sleep,200
		Click
		gotopos(FunctionPos[11])
		sleep,500
		click
		PageNow := 1
		packsearch(pagenow)
		packsearch(pagenow)
		PageNow := 1
	}
tooltip,完成
settimer,Tipgone,2000
return

tipgone:
settimer,Tipgone, Off
ToolTip
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
packsearch(byref page)
{
	gotopos([FunctionPos[8][1],FunctionPos[8][2] -100])
	sleep, 100
	loop,5
	{
		hang := row[A_index][2]
		hangnext := Floor(row[A_index + 1][2]- step * 0.2)
		colorpos := colorsearch([FunctionPos[8][1] - 20,hang],[FunctionPos[9][1],hangnext])
		while colorpos[1] != 0
		{
			gotopos(colorpos)
			if ClipandCheck()
				continue
			aimp := getaimpage(clipboard)
			if aimp > 0
			{
				gotopage(page,aimp)
				SendInput ^{click}
			}
			colorpos := colorsearch([colorpos[1],hang],[FunctionPos[9][1],hangnext])
		}
	}
	return
}


GotoPos(Ary)
{
	x := Ary[1]
	y := Ary[2]
	MouseMove,%x%,%y%
	return
}

ClipandCheck() ;确保复制成功
{
	Clipboard := ""
	loop ,4
	{
		Sendinput ^{c}
		ClipWait,0.200,1
	}until !ErrorLevel
	return false
}


GetFunctionPos(w,h,DefPos) ;获取对应坐标组，客户区坐标轴下
{
	PosLength := DefPos.Length()
	PosNow := []
	loop % PosLength
		PosNow.Push(PosChange(DefPos[A_index][1],DefPos[A_index][2],w,h,DefPos[A_index][3]))
	return PosNow
}

GetClientSize(hWnd, ByRef w  := "", ByRef h := "") ;客户区分辨率
{
	VarSetCapacity(rect, 16, 0)
	DllCall("GetClientRect", "ptr", hWnd, "ptr", &rect)
	w := NumGet(rect, 8,"int")
	h := NumGet(rect, 12, "int")
}

WebGet(obj,url) ;网络请求
{
	obj.open("GET",url,true)
	try
	{
		obj.Send()
		obj.WaitForResponse()
		message := obj.ResponseText
		if InStr(message, "Not Found")
		{
			MsgBox, 0x40000, 远程验证出错, 验证出错 ,联系作者 `n QQ: 906599772
			ExitApp
		}
	}
	catch
	{
		MsgBox, 0x40000, 网络错误, 检查网络重新启动
		ExitApp
	}
	return message
}


Aimx(x)
{
	Xnum := Floor((x - 1269)/53) + 1
	return Xnum
}


colorsearch(startpos,endpos) ;横线搜索
{
	PixelSearch, rx1, ry1, startpos[1], startpos[2], endpos[1], endpos[2],0x1D0405, 0, Fast
	if ErrorLevel
	{
		rx1 := 0
		ry1 := 0
	}
	PixelSearch, rx2, ry2, startpos[1], startpos[2], endpos[1], endpos[2],0x04042B, 0, Fast
	if ErrorLevel
	{
		rx2 := 0
		ry2 := 0
	}

	if rx1 * rx2 = 0
		return [rx1 + rx2,ry1 + ry2]
	if (rx1 - rx2 < 0)
		return [rx1,ry1]
	return [rx2,ry2]
}


gotopage(ByRef PageNow,AimPage)
{
	step1 := AimPage - PageNow
	if step1 = 0
		return
	absstep := Abs(step1)
	loop % absstep
	{
		if step1 > 0
			SendInput {Right}
		else
			SendInput {left}
	}
	PageNow := AimPage
	Sleep,150
	return
}

;~ getaimpage(str)
;~ {
	;~ if clipboard = ""
		;~ return 0
	;~ StrArray :=  StrSplit(str, "`n", "`r")
	;~ if InStr(StrArray[1],"通货")>0
		;~ return 1
	;~ if InStr(StrArray[1],"命运卡")>0
	;~ return 0
	;~ if InStr(Str,"地图集区域:")>0
		;~ return 2
	;~ return 3
;~ }


getaimpage(str)
{
	if clipboard = ""
		return 0
	StrArray := StrSplit(str, "`n", "`r")
	if InStr(Str,"地图集区域:")>0
		return 2
	if InStr(StrArray[1], "传奇") or InStr(StrArray[1], "Unique") or InStr(StrArray[1], "魔法") or InStr(StrArray[1], "Magic")
		return 7
	if InStr(StrArray[1], "命运卡")
		return 6
	nam := substr(StrArray[2],(sp := InStr(StrArray[2],"(") )+ 1,Instr(StrArray[2],")") - sp - 1)
	pa := name2page[nam]
	;tooltip % nam "`n" pa
	;sleep,1000
	if strlen(pa) = 0
		return 0
	return pa - 0
}

PosChange(x,y,w,h,postype) ;相对客户区坐标随分辨率转换，x,y:1080P横纵坐标，w,h:客户区分辨率，Postype: 1 仓库位置，2 背包位置
{
	ProPortion := h/1080

	y := Format("{:d}",(y + 1) * ProPortion) - 1
	if postype = 1
		x := Format("{:d}",(x + 1) * ProPortion) - 1
	if Postype = 2
		x := w - Format("{:d}",(1921 - x  )* ProPortion) + 1
	return  [x,y]
}



OnEx:
^space::
	Send {Shift up}
	ExitApp
	
	
