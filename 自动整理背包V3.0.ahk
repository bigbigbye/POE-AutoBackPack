#NoEnv
#Warn
#SingleInstance Ignore
SetWorkingDir %A_ScriptDir%
Coordmode, Mouse, Client
Coordmode, Pixel, Client

global inilist
global n2plist
global nlist := ["通货","地图","碎片","精髓","化石","卡片","暗金","其他","黄装"]
Global DefaultPos := [[55,330,1],[116,330,1],[230,330,1],[230,386,1],[334,526,1],[547,330,1],[428,470,1],[1273,591,2],[1902,849,2],[640,142,1],[700,142,1]]
;;蜕变，改造，机会，增幅，Item, Chaos,重铸，左上，右下，下拉，第一页
global FunctionPos := []
global name2page = []
global PageNow := 1
global whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
global row := 0
global step := 0

TrapName := "背包整理By白侠"
Menu, Tray, NoStandard
Menu, Tray, Click,1
Menu, Tray, Add, Open, OnClick
Menu, Tray, Add, Exit, OnEx
Menu, Tray, Default, Open
Menu, Tray,Tip,%TrapName%

Gui Add, GroupBox, x8 y8 w90 h260, 仓库页
Gui Add, Text, x17 y24 w24 h23 +0x200, 通货
Gui Add, Text, x17 y48 w24 h23 +0x200, 地图
Gui Add, Text, x17 y72 w24 h23 +0x200, 碎片
Gui Add, Text, x17 y96 w24 h23 +0x200, 精髓
Gui Add, Text, x17 y120 w24 h23 +0x200, 化石
Gui Add, Text, x17 y144 w24 h23 +0x200, 卡片
Gui Add, Text, x17 y168 w24 h23 +0x200, 暗金
Gui Add, Text, x17 y192 w24 h23 +0x200, 其他
Gui Add, Text, x17 y216 w60 h23 +0x200, 60-74换C
Gui Add, Text, x17 y240 w24 h23 +0x200, 黄装

Gui Add, Edit, x49 y24 w40 h21 limite2 Number disabled, Edit
Gui, Add, UpDown, vMyUpDown1 Range1-99 disabled, 1
Gui Add, Edit, x49 y48 w40 h21 limite2 Number disabled, Edit
Gui, Add, UpDown, vMyUpDown2 Range1-99 disabled, 2
Gui Add, Edit, x49 y72 w40 h21 limite2 Number, Edit
Gui, Add, UpDown, vMyUpDown3 Range1-99, 3
Gui Add, Edit, x49 y96 w40 h21 limite2 Number, Edit
Gui, Add, UpDown, vMyUpDown4 Range1-99, 4
Gui Add, Edit, x49 y120 w40 h21 limite2 Number, Edit
Gui, Add, UpDown, vMyUpDown5 Range1-99, 5
Gui Add, Edit, x49 y144 w40 h21 limite2 Number, Edit
Gui, Add, UpDown, vMyUpDown6 Range1-99, 6
Gui Add, Edit, x49 y168 w40 h21 limite2 Number, Edit
Gui, Add, UpDown, vMyUpDown7 Range1-99, 7
Gui Add, Edit, x49 y192 w40 h21 limite2 Number, Edit
Gui, Add, UpDown, vMyUpDown8 Range1-99, 8
Gui Add, Edit, x49 y240 w40 h21 limite2 Number, Edit
Gui, Add, UpDown, vMyUpDown9 Range1-99, 8


Gui Add, GroupBox, x104 y8 w130 h260, 对应列表
Gui Add, Edit,vlistboxx x111 y24 w115 h232, ListBox
Gui Add, Slider, x16 y370 w209 h22, 50
Gui Add, Text, x16 y346 w120 h23 +0x200, 当前游戏平均延迟
Gui Add, Text, x16 y394 w98 h23 +0x200, 背包整理快捷键：
Gui Add, Text, x16 y418 w98 h23 +0x200, 快速交易快捷键：
Gui Add, GroupBox, x8 y274 w224 h207, 设置
Gui Add, Text, x16 y290 w41 h23 +0x200, 屏蔽词
Gui Add, Edit, x16 y314 w100 h21, Edit
Gui Add, Edit, x120 y314 w100 h21, Edit
Gui Add, Hotkey, x120 y394 w101 h21
Gui Add, Hotkey, x120 y418 w101 h21
Gui Add, Button,gupdatedata x16 y442 w204 h31, 修改
Gui Show, w242 h492, Window
ReadIni()
Return


updatedata:
n2plist := {}
maxpage := 1
showlist := []
tt := 
init := 

GetClientSize(WinExist("ahk_exe PathOfExile_x64.exe"), ww, hh)
if hh = 0
{
	MsgBox,0x40000,错误,未打开游戏 或者 游戏目前最小化
	;return
}
FunctionPos := GetFunctionPos(ww,hh,DefaultPos)
row := []
loop,6 ;获取背包竖坐标
{
	step := Floor((FunctionPos[9][2] - FunctionPos[8][2] + 1)/ 5) + 1
	row.push([FunctionPos[8][1],Floor(Step* (A_index - 1 + 0.02) + FunctionPos[8][2])])
}
FileRead, name2page, name2page.json
name2page := JSON.load(name2page)
tt := "分辨率：`n" ww " * " hh "`n"

loop,9
{
	controlname := "MyUpDown" A_Index
	;msgbox % controlname
	GuiControlGet,controldata,,%controlname%
	;msgbox % controldata
	init .= controldata ","
	n2plist[A_index] := controldata
	maxpage := max(maxpage,controldata)
	if isobject(showlist[controldata]) = 0
		showlist[controldata] := []
	showlist[controldata].push(A_index)
}
loop % maxpage
{
	if isobject((tempp := showlist[A_index]))= 0
		continue
	tt.= A_index ":" "`n"
	loop % tempp.length()
		tt .= nlist[tempp[A_index]] "`n"
}
guicontrol,,listboxx, %tt%
init := Rtrim(init,",")
iniwrite, %init%, config.ini, pagelist, pagelist

GuiControl,, listtxt, "done"
return
	
GuiClose:
	Gui hide
return

GuiEscape:

    ExitApp

OnEx:
^space::
	Send {Shift up}
	ExitApp

OnClick:
	Gui Show
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
			gotopage(page,getaimpage(clipboard))
			SendInput ^{click}
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
	Sleep,100
	return
}

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
	
	
ReadIni() ;获取配置信息
{
	ifexist config.ini ;配置读取
	{
		IniRead, inilist ,config.ini, pagelist, pagelist
		inilist := strsplit(inilist, ",")
		loop % inilist.length()
		{
			;tooltip % inilist[A_index]
			controlnamee := "MyUpDown" A_Index
			GuiControl,,%controlnamee%,% inilist[A_index]
		}
		GuiControl,,MyUpDown1,1
		GuiControl,,MyUpDonw2,2
	}
	else
	{
		Msgbox, , 缺少文件, 缺少配置文件,请重新解压全部文件
		ExitApp
	}
}