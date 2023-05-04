script_name('Solyanka of Functions')
script_author("C.Webb")
script_version("04.05.2023")
script_version_number(10)
local macros = "https://script.google.com/macros/s/AKfycbyO5cG_ROl_Ar2T2_q6FkYNFdCEKo82Jsr41tzBA5cD7uD05ka46GwxZ3oG1VnXSas/exec?do"
local req_index = 0
local script = { -- технические переменные скрипта
	checked = false, -- проведены ли все, необходимые для работы скрипта, проверки
	freereq = true, -- свободна ли функция req() для выполнения запроса
	complete = true, -- завершена ли загрузка
	update = false, 
	noaccess = false, 
	v = {date, num}, 
	url, 
	access = {}, 
	reload, 
	loaded, 
	unload, 
	upd = {
		changes = {}, 
		sort = {}
	}
}
local var = {needtocl = true}
-------------------------------------------------------------------------[Библиотеки/Зависимости]---------------------------------------------------------------------
local ev = require 'samp.events'
local imgui = require 'imgui'
imgui.ToggleButton = require('imgui_addons').ToggleButton
local vkeys = require 'vkeys'
local rkeys = require 'rkeys'
local regex = require 'rex_pcre'
local inicfg = require 'inicfg'
local dlstatus = require "moonloader".download_status
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
-------------------------------------------------------------------------[Конфиг скрипта]-----------------------------------------------------------------------------
local AdressConfig, AdressFolder, settings, solyanka_ini, server

local config = {
	bools = {
		sex = false,
		cl7 = false,
		autocl = false,
		mat = false,
		seedo
	},
	hotkey = {
		clist = '0',
		ration = '0',
		zdrav = '0',
		sos = '0',
		psiho = '0',
		accept = '0'
	},
	values = {
		tag = "",
		clist = 0
	}
}
-------------------------------------------------------------------------[Переменные и маcсивы]-----------------------------------------------------------------
local main_color = 0xFF006400
local prefix = "{006400}[solyanka] {FFFAFA}"
local updatingprefix = "{FF0000}[ОБНОВЛЕНИЕ] {FFFAFA}"
local antiflood = 0
local needtoreload = false

local menu = { -- imgui-меню
	main = imgui.ImBool(false),
	settings = imgui.ImBool(true),
	information = imgui.ImBool(false),
	commands = imgui.ImBool(false),
	target = imgui.ImBool(false),
	interaction = imgui.ImBool(false)
}
imgui.ShowCursor = false

local style = imgui.GetStyle()
local colors = style.Colors
local clr = imgui.Col
local suspendkeys = 2 -- 0 хоткеи включены, 1 -- хоткеи выключены -- 2 хоткеи необходимо включить
local ImVec4 = imgui.ImVec4
local imfonts = {mainFont = nil, smallmainFont = nil, memfont = nil}
local targetId, targetNick, targetRank, playerNick, playerRank
local offmembers = {}
local tag = ""
local a = ""
local currentNick
local alreadyUd = {}
local checkpoint = {}

local clists = {
	numbers = {
		[16777215] = 0,    [2852758528] = 1,  [2857893711] = 2,  [2857434774] = 3,  [2855182459] = 4, [2863589376] = 5, 
		[2854722334] = 6,  [2858002005] = 7,  [2868839942] = 8,  [2868810859] = 9,  [2868137984] = 10, 
		[2864613889] = 11, [2863857664] = 12, [2862896983] = 13, [2868880928] = 14, [2868784214] = 15, 
		[2868878774] = 16, [2853375487] = 17, [2853039615] = 18, [2853411820] = 19, [2855313575] = 20, 
		[2853260657] = 21, [2861962751] = 22, [2865042943] = 23, [2860620717] = 24, [2868895268] = 25, 
		[2868899466] = 26, [2868167680] = 27, [2868164608] = 28, [2864298240] = 29, [2863640495] = 30, 
		[2864232118] = 31, [2855811128] = 32, [2866272215] = 33,
		
		[-256] = 0, [161743018] = 1, [1476349866] = 2, [1358861994] = 3, [782269354] = 4, [-1360527190] = 5,
		[664477354] = 6, [1504073130] = 7, [-16382294] = 8, [-23827542] = 9,  [-196083542] = 10,
		[-1098251862] = 11, [-1291845462] = 12, [-1537779798] = 13, [-5889878] = 14, [-30648662] = 15,
		[-6441302] = 16, [319684522] = 17, [233701290] = 18, [328985770] = 19, [815835050] = 20,
		[290288042] = 21, [-1776943190] = 22, [-988414038] = 23, [-2120503894] = 24, [-2218838] = 25,
		[-1144150] = 26, [-188481366] = 27, [-189267798] = 28, [-1179058006] = 29, [-1347440726] = 30,
		[-1195985238] = 31, [943208618] = 32, [-673720406] = 33,
	},
	names = {
		"[0] Без цвета", "[1] Зелёный", "[2] Светло-зелёный", "[3] Ярко-зелёный",
		"[4] Бирюзовый", "[5] Жёлто-зелёный", "[6] Тёмно-зелёный", "[7] Серо-зелёный",
		"[8] Красный", "[9] Ярко-красный", "[10] Оранжевый", "[11] Коричневый",
		"[12] Тёмно-красный", "[13] Серо-красный", "[14] Жёлто-оранжевый", "[15] Малиновый",
		"[16] Розовый", "[17] Синий", "[18] Голубой", "[19] Синяя сталь", "[20] Cине-зелёный",
		"[21] Тёмно-синий", "[22] Фиолетовый", "[23] Индиго", "[24] Серо-синий", "[25] Жёлтый",
		"[26] Кукурузный", "[27] Золотой", "[28] Старое золото", "[29] Оливковый",
		"[30] Серый", "[31] Серебро", "[32] Чёрный", "[33] Белый"
	}
}

local zv = {
	"Рядовой", "Ефрейтор", "Младший сержант", "Сержант", "Старший сержант", 
	"Старшина", "Прапорщик", "Младший лейтенант", "Лейтенант", "Старший лейтенант", 
	"Капитан", "Майор", "Подполковник", "Полковник", "Генерал"
}

local zvskl = {
	"Рядового", "Ефрейтора", "Младшего сержанта", "Сержанта", "Старшего сержанта", 
	"Старшины", "Прапорщика", "Младшего лейтенанта", "Лейтенанта", "Старшего лейтенанта", 
	"Капитана", "Майора", "Подполковника", "Полковника", "Генерала"
}

local posts = {
	["КПП-1"] = {x1 = 124, y1 = 1923, x2 = 185, y2 = 1965},
	["КПП-2"] = {x1 = 83, y1 = 1911, x2 = 112, y2 = 1933},
}
-------------------------------------------------------------------------[MAIN]--------------------------------------------------------------------------------------------
function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(0) end
	
	script.sendMessage("Скрипт успешно загружен.")
	
	while sampGetCurrentServerName() == "SA-MP" do wait(0) end
	server = sampGetCurrentServerName():gsub('|', '')
	server = (server:find('02') and 'Two' or (server:find('Revo') and 'Revolution' or (server:find('Legacy') and 'Legacy' or (server:find('Classic') and 'Classic' or nil))))
    if server == nil then script.sendMessage('Данный сервер не поддерживается, выгружаюсь...') script.unload = true thisScript():unload() end
	currentNick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
	
	AdressConfig = string.format("%s\\config", thisScript().directory)
    AdressFolder = string.format("%s\\config\\solyanka\\%s\\%s", thisScript().directory, server, currentNick)
	settings = string.format("solyanka\\%s\\%s\\settings.ini", server, currentNick)
	
	if not doesDirectoryExist(AdressConfig) then createDirectory(AdressConfig) end
	if not doesDirectoryExist(AdressFolder) then createDirectory(AdressFolder) end
	
	if solyanka_ini == nil then -- загружаем конфиг
		solyanka_ini = inicfg.load(config, settings)
		inicfg.save(solyanka_ini, settings)
	end
	
	tag = solyanka_ini.values.tag ~= "" and solyanka_ini.values.tag .. " " or ""
	a = solyanka_ini.bools.sex and "а" or ""
	
	togglebools = {
		sex = solyanka_ini.bools.sex and imgui.ImBool(true) or imgui.ImBool(false),
		cl7 = solyanka_ini.bools.cl7 and imgui.ImBool(true) or imgui.ImBool(false),
		autocl = solyanka_ini.bools.autocl and imgui.ImBool(true) or imgui.ImBool(false),
		seedo = solyanka_ini.bools.seedo and imgui.ImBool(true) or imgui.ImBool(false),
		psihosbiv = solyanka_ini.bools.psihosbiv and imgui.ImBool(true) or imgui.ImBool(false)
	}
	buffer = {
		clist = imgui.ImInt(solyanka_ini.values.clist),
		tag = imgui.ImBuffer(u8(solyanka_ini.values.tag), 256)
	}
	
	sampRegisterChatCommand("solyanka", function()
		if not script.checked then script.sendMessage("Проверка ещё не пройдена!") return end
		for k, v in pairs(solyanka_ini.hotkey) do 
			local hk = makeHotKey(k) 
			if tonumber(hk[1]) ~= 0 then 
				rkeys.unRegisterHotKey(hk) 
			end 
		end
		suspendkeys = 1 
		menu.main.v = not menu.main.v
	end)
	
	sampRegisterChatCommand('zas', cmd_zas)
	sampRegisterChatCommand('zastupil', cmd_zas)
	sampRegisterChatCommand('pok', cmd_pok)
	sampRegisterChatCommand('pokinul', cmd_pok)
	sampRegisterChatCommand("viezd", cmd_viezd)
	sampRegisterChatCommand("cam", cmd_cam)
	
	script.loaded = true
	
	while sampGetGamestate() ~= 3 do wait(0) end
	while sampGetPlayerScore(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) <= 0 and not sampIsLocalPlayerSpawned() do wait(0) end
	
	script.sendMessage("Начинаю проверку доступа к скрипту...")
	checkaccess(currentNick)
	while not script.checked do wait(0) end
	script.sendMessage("Скрипт by " .. unpack(thisScript().authors) .. " запущен. Открыть главное меню - /solyanka")
	
	imgui.Process = true
	needtoreload = true
	chatManager.initQueue()
	lua_thread.create(chatManager.checkMessagesQueueThread)
	getoffmembers()
	while true do
		wait(0)
		
		if suspendkeys == 2 then
			rkeys.registerHotKey(makeHotKey('psiho'), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end sampSendChat("/grib heal") end)
			suspendkeys = 0
		end
		
		if not menu.main.v then 
			imgui.ShowCursor = false
			if suspendkeys == 1 then 
				suspendkeys = 2 
				sampSetChatDisplayMode(3) 
			end
		end
		
		if var.needtocl and isCharInArea2d(PLAYER_PED, -84, 1606, 464, 2148, false) then
			var.needtocl = false
			if solyanka_ini.bools.cl7 then
				local result1, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
				if result1 then
					local result2, sid = sampGetPlayerSkin(myid)
					if result2 then
						if sid ~= 287 and sid ~= 191 then
							sampProcessChatInput("/cl 7")
						end
					end
				end
			end
		end
		
		local res, targetHandle = getCharPlayerIsTargeting(playerHandle)
		if res then
			if getCurrentCharWeapon(PLAYER_PED) == 0 then
				_, targetId = sampGetPlayerIdByCharHandle(targetHandle)
				if _ then
					targetNick = sampGetPlayerNickname(targetId)
					menu.target.v = true
					else
					menu.target.v = false
				end
				else
				menu.target.v = false
			end
			else
			menu.target.v = false
		end
		
		if wasKeyPressed(vkeys.VK_O) then
			if not menu.interaction.v then
				if menu.target.v then
					if targetNick ~= nil and targetId ~= nil then
						offNick = u8:decode(targetNick)
						local temp = os.tmpname()
						local time = os.time()
						local found = false
						downloadUrlToFile("http://srp-addons.ru/om/fraction/Army%20LV", temp, function(_, status)
							if (status == 58) then
								local file = io.open(temp, "r")
								playerNick = u8:decode(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(PLAYER_PED))))
								for line in file:lines() do
									line = encoding.UTF8:decode(line)
									local offrank, offtm, offwm, offdate = line:match('%["' .. offNick .. '",(%d+),%[(%d+),(%d+)%],"(%d+/%d+/%d+ %d+%:%d+%:%d+)"%]')
									local myrank, mytm, mywm, mydate = line:match('%["' .. playerNick .. '",(%d+),%[(%d+),(%d+)%],"(%d+/%d+/%d+ %d+%:%d+%:%d+)"%]')
									if tonumber(myrank) ~= nil and tonumber(offrank) ~= nil then
										found = true
										targetRank = tonumber(offrank)
										playerRank = tonumber(myrank)
									end
								end
								if not found then script.sendMessage("Произошла ошибка. Не удалось получить ранг цели или ваш ранг!") end
								file:close()
								os.remove(temp)
								if found then
									menu.interaction.v = true
								end
								else
								if (os.time() - time > 10) then
									script.sendMessage("Превышено время загрузки файла, повторите попытку", 0xFFFFFFFF)
									return
								end
							end
						end)
						else
						script.sendMessage("Произошла ошибка, попробуйте ещё раз")
					end
				end
				else
				menu.interaction.v = false
			end
		end
		for nick, t in pairs(alreadyUd) do
			if (os.time() - t) >= 30 then alreadyUd[nick] = nil
				else
				if checkpoint[nick] ~= nil then
					local surname = nick:match(".*%_(.*)")
					f("В часть прибыл " .. checkpoint[nick] .. " " .. surname)
					chatManager.addMessageToQueue("Товарищ " .. checkpoint[nick] .. " " .. surname .. ", можете двигаться далее!")
					alreadyUd[nick] = nil
					checkpoint[nick] = nil
				end
			end
		end
	end
end
-------------------------------------------------------------------------[IMGUI]-------------------------------------------------------------------------------------------
function apply_custom_styles()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	
	imgui.GetStyle().WindowPadding = imgui.ImVec2(8, 8)
	imgui.GetStyle().WindowRounding = 16.0
	imgui.GetStyle().FramePadding = imgui.ImVec2(5, 3)
	imgui.GetStyle().ItemSpacing = imgui.ImVec2(4, 4)
	imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(5, 5)
	imgui.GetStyle().IndentSpacing = 9.0
	imgui.GetStyle().ScrollbarSize = 17.0
	imgui.GetStyle().ScrollbarRounding = 16.0
	imgui.GetStyle().GrabMinSize = 7.0
	imgui.GetStyle().GrabRounding = 6.0
	imgui.GetStyle().ChildWindowRounding = 6.0
	imgui.GetStyle().FrameRounding = 6.0
	
	colors[clr.Text] = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled] = ImVec4(0.73, 0.75, 0.74, 1.00)
	colors[clr.WindowBg] = ImVec4(0.42, 0.48, 0.16, 1.00)
	colors[clr.ChildWindowBg] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.FrameBg] = ImVec4(0.41, 0.49, 0.24, 0.54)
	colors[clr.FrameBgHovered] = ImVec4(0.26, 0.32, 0.13, 0.54)
	colors[clr.FrameBgActive] = ImVec4(0.33, 0.39, 0.20, 0.54)
	colors[clr.TitleBg] = ImVec4(0.42, 0.48, 0.16, 0.90)
	colors[clr.TitleBgActive] = ImVec4(0.42, 0.48, 0.16, 1.00)
	colors[clr.TitleBgCollapsed] = ImVec4(0.33, 0.44, 0.26, 0.67)
	colors[clr.MenuBarBg] = ImVec4(0.60, 0.67, 0.44, 0.54)
	colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.53)
	colors[clr.ScrollbarGrab] = ImVec4(0.42, 0.48, 0.16, 0.54)
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.85, 0.98, 0.26, 0.54)
	colors[clr.ScrollbarGrabActive] = ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.ComboBg] = colors[clr.PopupBg]
	colors[clr.CheckMark] = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.SliderGrab] = ImVec4(0.35, 0.43, 0.16, 0.84)
	colors[clr.SliderGrabActive] = ImVec4(0.53, 0.53, 0.53, 1.00)
	colors[clr.Button] = ImVec4(0.42, 0.48, 0.16, 0.54)
	colors[clr.ButtonHovered] = ImVec4(0.85, 0.98, 0.26, 0.54)
	colors[clr.ButtonActive] = ImVec4(0.62, 0.75, 0.32, 1.00)
	colors[clr.Header] = ImVec4(0.33, 0.42, 0.15, 0.54)
	colors[clr.HeaderHovered] = ImVec4(0.85, 0.98, 0.26, 0.54)
	colors[clr.HeaderActive] = ImVec4(0.84, 0.66, 0.66, 0.00)
	colors[clr.Separator] = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.SeparatorHovered] = ImVec4(0.43, 0.54, 0.18, 0.54)
	colors[clr.SeparatorActive] = ImVec4(0.52, 0.62, 0.28, 0.54)
	colors[clr.ResizeGrip] = ImVec4(0.66, 0.80, 0.35, 0.54)
	colors[clr.ResizeGripHovered] = ImVec4(0.44, 0.48, 0.34, 0.54)
	colors[clr.ResizeGripActive] = ImVec4(0.37, 0.37, 0.35, 0.54)
	colors[clr.CloseButton] = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.CloseButtonHovered] = ImVec4(0.52, 0.63, 0.26, 0.54)
	colors[clr.CloseButtonActive] = ImVec4(0.81, 1.00, 0.37, 0.54)
	colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered] = ImVec4(0.79, 1.00, 0.32, 0.54)
	colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
	colors[clr.TextSelectedBg] = ImVec4(0.26, 0.59, 0.98, 0.35)
	colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
	
	
	imgui.GetIO().Fonts:Clear()
	imfonts.mainFont = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\times.ttf', 20.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
	imfonts.smallmainFont = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\times.ttf', 16.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
	imfonts.memfont = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\times.ttf', 20.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
	
	imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\times.ttf', 14.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
	imgui.RebuildFonts()
end
apply_custom_styles()

function imgui.TextColoredRGB(text)
	local style = imgui.GetStyle()
	local colors = style.Colors
	local ImVec4 = imgui.ImVec4
	
	local explode_argb = function(argb)
		local a = bit.band(bit.rshift(argb, 24), 0xFF)
		local r = bit.band(bit.rshift(argb, 16), 0xFF)
		local g = bit.band(bit.rshift(argb, 8), 0xFF)
		local b = bit.band(argb, 0xFF)
		return a, r, g, b
	end
	
	local getcolor = function(color)
		if color:sub(1, 6):upper() == 'SSSSSS' then
			local r, g, b = colors[1].x, colors[1].y, colors[1].z
			local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
			return ImVec4(r, g, b, a / 255)
		end
		
		local color = type(color) == 'string' and tonumber(color, 16) or color
		if type(color) ~= 'number' then return end
		local r, g, b, a = explode_argb(color)
		return imgui.ImColor(r, g, b, a):GetVec4()
	end
	
	local render_text = function(text_)
		for w in text_:gmatch('[^\r\n]+') do
			local text, colors_, m = {}, {}, 1
			w = w:gsub('{(......)}', '{%1FF}')
			while w:find('{........}') do
				local n, k = w:find('{........}')
				local color = getcolor(w:sub(n + 1, k - 1))
				if color then
					text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
					colors_[#colors_ + 1] = color
					m = n
				end
				
				w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
			end
			
			if text[0] then
				for i = 0, #text do
					imgui.TextColored(colors_[i] or colors[1], text[i])
					if imgui.IsItemClicked() then	if SelectedRow == A_Index then ChoosenRow = SelectedRow	else	SelectedRow = A_Index	end	end
					imgui.SameLine(nil, 0)
				end
				
				imgui.NewLine()
				else
				imgui.Text(w)
				if imgui.IsItemClicked() then	if SelectedRow == A_Index then ChoosenRow = SelectedRow	else	SelectedRow = A_Index	end	end
			end
		end
	end
	render_text(text)
end

function imgui.OnDrawFrame()
	if menu.main.v and script.checked then -- меню скрипта
		imgui.SwitchContext()
		colors[clr.WindowBg] = ImVec4(0.06, 0.06, 0.06, 0.94)
		imgui.PushFont(imfonts.mainFont)
		imgui.ShowCursor = true
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(815, 600), imgui.Cond.FirstUseEver)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.Begin(thisScript().name ..' v' .. script.v.num .. ' от ' .. script.v.date, menu.main, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		local ww = imgui.GetWindowWidth()
		local wh = imgui.GetWindowHeight()
		
		if imgui.Button("Настройки", imgui.ImVec2(397.0, 35.0)) then menu.settings.v = true menu.information.v = false menu.commands.v = false end
		imgui.SameLine()
		if imgui.Button("Информация", imgui.ImVec2(397.0, 35.0)) then menu.settings.v = false menu.information.v = true menu.commands.v = false end
		
		if menu.settings.v and not menu.information.v then
			imgui.BeginChild('settings', imgui.ImVec2(800, 429), true)
			
			imgui.PushFont(imfonts.smallmainFont)
			imgui.Hotkey("hotkey", "clist", 100) 
			imgui.SameLine() 
			imgui.Text("Сменить клист\n(если надет не нулевой клист, то будет введён /clist 0)") 
			imgui.SameLine(800 - imgui.CalcTextSize('(если надет не нулевой клист, то будет введён /clist 0)').x) 
			imgui.PushItemWidth(200)
			if imgui.Combo("##Combo", buffer.clist, clists.names) then 
				solyanka_ini.values.clist = tostring(u8:decode(buffer.clist.v)) 
				inicfg.save(solyanka_ini, settings) 
			end
			imgui.Hotkey("hotkey1", "ration", 100) 
			imgui.SameLine() 
			imgui.Text("Написать в рацию\n(Будет открыта строка чата с /f [Tag])")
			imgui.Hotkey("hotkey2", "zdrav", 100) 
			imgui.SameLine() 
			imgui.Text("Поприветствовать солдата в рацию\n(Если он напишет 'Здравия желаю часть' и.т.д)") 
			imgui.Hotkey("hotkey3", "sos", 100) 
			imgui.SameLine() 
			imgui.Text("Отправить сигнал SOS в рацию\n(Если будете находится возле военного объекта, то напишет объект)") 
			imgui.Hotkey("hotkey4", "psiho", 100) 
			imgui.SameLine()
			imgui.Text("Употребить психохил\n(/grib heal)") 
			imgui.Hotkey("hotkey5", "accept", 100) 
			imgui.SameLine() 
			imgui.Text("/f Принято\n(Нахуя?)") 
			imgui.PopItemWidth()
			imgui.PopFont()
			
			imgui.Text("Введите ваш тэг в рацию")
			imgui.SameLine() 
			imgui.PushItemWidth(120)
			if imgui.InputText('##tag', buffer.tag) then 
				solyanka_ini.values.tag = tostring(u8:decode(buffer.tag.v))
				tag = solyanka_ini.values.tag ~= "" and solyanka_ini.values.tag .. " " or ""
				inicfg.save(solyanka_ini, settings) 
			end 
			imgui.PopItemWidth() 
			
			if imgui.ToggleButton("sex", togglebools.sex) then 
				solyanka_ini.bools.sex = togglebools.sex.v
				a = solyanka_ini.bools.sex and "а" or ""
				inicfg.save(solyanka_ini, settings)
			end
			imgui.SameLine() 
			imgui.Text("Женский пол")
			
			if imgui.ToggleButton("cl7", togglebools.cl7) then 
				solyanka_ini.bools.cl7 = togglebools.cl7.v
				inicfg.save(solyanka_ini, settings)
			end
			imgui.SameLine() 
			imgui.Text("Автоматически вводить /clist 7 на базе после захода в игру")
			
			if imgui.ToggleButton("autocl", togglebools.autocl) then 
				solyanka_ini.bools.autocl = togglebools.autocl.v
				inicfg.save(solyanka_ini, settings)
			end
			imgui.SameLine() 
			imgui.Text("'Автоклист' - автомаитчески вводить клист после: нач.раб.дня, завершения раб.дня, смерти")
			
			imgui.SameLine() 
			imgui.Text("Автоматически вводить /carm для загрузки/разгрузки")
			
			if imgui.ToggleButton("seedo", togglebools.seedo) then 
				solyanka_ini.bools.seedo = togglebools.seedo.v
				inicfg.save(solyanka_ini, settings)
			end
			imgui.SameLine() 
			imgui.Text("Отправлять /seedo при определённых событиях")
			
			if imgui.ToggleButton("psihosbiv", togglebools.psihosbiv) then 
				solyanka_ini.bools.psihosbiv = togglebools.psihosbiv.v
				inicfg.save(solyanka_ini, settings)
			end
			imgui.SameLine() 
			imgui.Text("Сбивать анимацию приёма психохила")
			
			imgui.EndChild()
		end
		
		if not menu.settings.v and menu.information.v then
			imgui.Text("Данный скрипт является кучей всякого говна")
			imgui.Text("Автор: Cody_Webb | Telegram: @Imykhailovich")
			imgui.SameLine()
			imgui.PushFont(imfonts.smallmainFont)
			if imgui.Button("Написать разработчику", imgui.ImVec2(180.0, 23.0)) then os.execute('explorer "https://t.me/Imykhailovich"') end
			imgui.PopFont()
			imgui.NewLine()
			imgui.Text("Все настройки автоматически сохраняются в файл:\nmoonloader//config//solyanka//Server//Nick_Name")
			imgui.NewLine()
			imgui.Text("Информация о последних обновлениях:")
			imgui.BeginChild('information', imgui.ImVec2(800, 265), true)
			for k in ipairs(script.upd.sort) do
				if script.upd.changes[tostring(k)] ~= nil then
					imgui.Text(k .. ') ' .. script.upd.changes[tostring(k)])
					imgui.NewLine()
				end
			end
			imgui.EndChild()
		end
		
		if menu.commands.v then
			local cmds = {
				"/solyanka - открыть главное меню скрипта",
				"/solyankaup - обновить скрипт",
				"/viezd - доложить о выезде колонны ВМО",
				"/cam on/off - включить/отключить/отыграть камеру"
			}
			for k, v in ipairs(cmds) do
				w = v + 50
			end
			imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.SetNextWindowSize(imgui.ImVec2(w, 300), imgui.Cond.FirstUseEver, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
			imgui.Begin("Все команды скрипта", menu.commands, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
			imgui.Text("Данные команды являются системными, их нельзя изменить:")
			imgui.BeginChild('commands', imgui.ImVec2(w - 15, 235), true)
			for k, v in ipairs(cmds) do imgui.Text(v) end
			imgui.EndChild()
			imgui.End()
		end
		
		imgui.SetCursorPos(imgui.ImVec2(25, wh/2 + 250))
		local found = false
		for i = 0, 1000 do
			if sampIsPlayerConnected(i) and sampGetPlayerScore(i) ~= 0 then
				if sampGetPlayerNickname(i) == "Cody_Webb" then
					local ownernick = sampGetPlayerNickname(i)
					if imgui.Button(ownernick .. "[" .. i .. "] сейчас в сети", imgui.ImVec2(260.0, 30.0)) then
						chatManager.addMessageToQueue("/sms " .. i .. " Я пользуюсь solyanka.lua, большое спасибо")
					end
					found = true
				end
			end
		end
		if not found then
			if imgui.Button("Cody Webb сейчас не в сети", imgui.ImVec2(260.0, 30.0)) then
				script.sendMessage("Cody Webb играет на Revolution (сейчас не онлайн)")
			end
		end
		
		imgui.PushFont(imfonts.smallmainFont)
		imgui.SetCursorPos(imgui.ImVec2(25, wh/2 + 215))
		if imgui.Button("Все команды скрипта", imgui.ImVec2(170.0, 23.0)) then menu.commands.v = true end
		imgui.PopFont()
		
		imgui.End()
		imgui.PopFont()
	end
	
	if menu.interaction.v then
		imgui.SwitchContext()
		colors[clr.WindowBg] = ImVec4(0.06, 0.06, 0.06, 0.94)
		imgui.PushFont(imfonts.mainFont)
		imgui.ShowCursor = true
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(1000, 250), imgui.Cond.FirstUseEver, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.Begin("Меню взаимодействия с военнослужащим: " .. zv[targetRank] .. " " .. targetNick:gsub("_", " "), menu.interaction, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
		imgui.BeginChild('interaction', imgui.ImVec2(985, 195), true)
		local strings = {
			[1] = "Здравия желаю, товарищ " .. zv[targetRank] .. " " .. targetNick:match(".*%_(.*)") .. "!",
			[2] = "Товарищ " .. zv[targetRank] .. " " .. targetNick:match(".*%_(.*)"),
			[3] = "Товарищ " .. zv[targetRank] .. " " .. targetNick:match(".*%_(.*)") .. " разрешите обратится? Товарищ " .. zv[playerRank] .. " " .. playerNick:match(".*%_(.*)"),
			[4] = "Товарищ " .. zv[targetRank] .. " " .. targetNick:match(".*%_(.*)") .. " разрешите встать в строй?",
			[5] = "Товарищ " .. zv[targetRank] .. " " .. targetNick:match(".*%_(.*)") .. ", товарищ " .. zv[playerRank] .. " " .. playerNick:match(".*%_(.*)") .. " по вашему приказу прибыл!"
		}
		for k, v in ipairs(strings) do
			imgui.PushID(k)
			if imgui.Button(v, imgui.ImVec2(970, 25.0)) then
				chatManager.addMessageToQueue(v)
				menu.interaction.v = false
			end
			imgui.PopID()
		end
		imgui.EndChild()
		imgui.End()
		imgui.PopFont()
	end
	
	imgui.SwitchContext() -- Overlay
	colors[clr.WindowBg] = ImVec4(0, 0, 0, 0)
	local SetModeCond = SetMode and 0 or 4
	
	if menu.target.v then
		if not SetMode then imgui.SetNextWindowPos(imgui.ImVec2(500, 500)) else if SetModeFirstShow then imgui.SetNextWindowPos(imgui.ImVec2(500, 500)) end end -- таргет-меню
		imgui.Begin('#empty_field', menu.target, 1 + 32 + 2 + SetModeCond + 64)
		imgui.PushFont(imfonts.mainFont)
		if targetId ~= nil and targetNick ~= nil then
			local targetClist = "{" .. ("%06x"):format(bit.band(sampGetPlayerColor(targetId), 0xFFFFFF)) .. "}"
			imgui.TextColoredRGB('Текущая цель: ' .. (targetClist ~= nil and targetClist or '') .. targetNick .. '[' .. targetId .. ']')
			imgui.TextColoredRGB('O' .. ' - меню взаимодействия')
		end
		imgui.PopFont()
		imgui.End()
	end
	
end
-------------------------------------------------------------------------[ФУНКЦИИ]-----------------------------------------------------------------------------------------
function getoffmembers()
	local temp = os.tmpname()
	local time = os.time()
	local found = false
	downloadUrlToFile("http://srp-addons.ru/om/fraction/Army%20LV", temp, function(_, status)
		if (status == 58) then
			local file = io.open(temp, "r")
			if file ~= nil then
				local filetext = file:read("*a")
				text = encoding.UTF8:decode(filetext)
				local members = text:match("data%: (.*)columns%: %["):match("%[(.*)%]%,")
				for offnick, offrank, offtm, offwm, offdate in string.gmatch(members, '%[%"(%a+%_%a+)%"%,(%d+)%,%[(%d+),(%d+)%],"(%d+/%d+/%d+ %d+%:%d+%:%d+)"%]') do
					if offnick ~= nil and tonumber(offrank) ~= nil and tonumber(offtm) ~= nil and tonumber(offwm) ~= nil and offdate ~= nil then
						offrank = tonumber(offrank)
						offtm = tonumber(offtm)
						offwm = tonumber(offwm)
						offmembers[offnick] = {rank = offrank, zv = zv[offrank], zvskl = zvskl[offrank], tm = offtm, wm = offwm, date = offdate}
					end
				end
				file:close()
				os.remove(temp)
				else
				if (os.time() - time > 10) then
					script.sendMessage("Превышено время загрузки файла, повторите попытку")
					return
				end
			end
		end
	end)
end

function ev.onServerMessage(col, text)
	if script.loaded then
		if waitforchangeclist and col == -1 and text:match(u8:decode"Цвет выбран") ~= nil then waitforchangeclist = false end
		if col == -356056833 and text:match(u8:decode"^ Для восстановления доступа нажмите клавишу %'F6%' и введите %'%/restoreAccess%'") then var.needtocl = true if needtoreload then script.reload = true thisScript():reload() end end
		if solyanka_ini.bools.autocl and col == 1790050303 then
			if text:match(u8:decode"^ Рабочий день окончен") then
				sampProcessChatInput("/cl 7")
				elseif text:match(u8:decode"^ Рабочий день начат") then
				if tostring(solyanka_ini.values.clist) ~= nil then
					sampProcessChatInput("/cl " .. tostring(solyanka_ini.values.clist))
				end
			end
		end
		if solyanka_ini.bools.seedo and col == -65281 then
			local smstxt, smsnick, smsid = text:match(u8:decode"^ SMS%: (.*)%. Отправитель%: (.*)%[(%d+)%]$") 
			if smstxt ~= nil and smsnick ~= nil and smsid ~= nil then
				local checkid = sampGetPlayerIdByNickname(smsnick)
				if checkid == tonumber(smsid) and sampIsPlayerConnected(checkid) then
					chatManager.addMessageToQueue("/seedo Поступило сообщение " .. (offmembers[smsnick] ~= nil and "от " .. offmembers[smsnick].zvskl or "на телефон") .. "")
				end
			end
		end
		if solyanka_ini.bools.psihosbiv and col == -1 then
			if text:match(u8:decode"^ Здоровье %d+%/%d+%. Сытость %d+%/%d+%. У вас осталось %d+%/%d+% психохила$") or text:match(u8:decode"^ Вы истощены%. Здоровье снижено до %d+%/%d+%. У вас осталось %d+%/%d+% психохила$") then
				lua_thread.create(function()
					wait(400)
					sampSendChat(" ")
				end)
			end
		end
		local sqnick, sqtext = text:match(u8:decode"%[.*%] %{FFFFFF%}(.*)%[%d+%]%: (.*)")
		if sqnick ~= nil and sqtext ~= nil and col == -1144065 then
			-- if sqtext:match(u8:decode"[Оо][Тт][Мм][Ее][Тт][Кк]") then
			-- local temp = os.tmpname()
			-- local time = os.time()
			-- local found = false
			-- downloadUrlToFile("http://srp-addons.ru/om/fraction/Army%20LV", temp, function(_, status)
			-- if (status == 58) then
			-- local file = io.open(temp, "r")
			-- for line in file:lines() do
			-- line = encoding.UTF8:decode(line)
			-- local offrank, offtm, offwm, offdate = line:match('%["' .. sqnick .. '",(%d+),%[(%d+),(%d+)%],"(%d+/%d+/%d+ %d+%:%d+%:%d+)"%]')
			-- if tonumber(offrank) ~= nil and tonumber(offtm) ~= nil and tonumber(offwm) ~= nil and offdate ~= nil then
			-- found = true
			-- chatManager.addMessageToQueue("/fs " .. sqnick .. " > Сегодня: " .. u8(offtm) .. " / За неделю: " .. u8(offwm) .. " часов")
			-- end
			-- end
			-- if not found then script.sendMessage("Отметки " .. sqnick .. " не найдены в базе данных!") return end
			-- file:close()
			-- os.remove(temp)
			-- else
			-- if (os.time() - time > 10) then
			-- chatManager.addMessageToQueue("/fs Превышено время загрузки файла, повторите попытку")
			-- return
			-- end
			-- end
			-- end)
			-- end
			-- if sqtext:match(u8:decode"[МмMm][ОоOo][НнNn][ИиIi][ТтTtКкKk][ОоOo]?[РрRr]?") then
			-- delivery[6] = true
			-- cmd_mon()
			-- end
		end
		if text:match(u8:decode"[Уу]дост") then
			local udnick = text:match(u8:decode"(%a+%_%a+)")
			if udnick ~= nil then alreadyUd[udnick] = os.time() end
		end
		local passorg, passrank = text:match(u8:decode" Организация%: (.*)%s+Должность%: (.*)")
		if passorg ~= nil and passrank ~= nil and col == -169954305 then
			local currentPost
			local x, y, z = getCharCoordinates(PLAYER_PED)
			for i, v in pairs(posts) do
				if (x >= v.x1) and (y >= v.y1) and (x <= v.x2) and (y <= v.y2) then
					passrank = u8(passrank)
					if not passrank:match("Майор") and not passrank:match("[Пп]олковник") and not passrank:match("Генерал") then
						local ranksnesokr = {["Ст.сержант"] = "Старший сержант", ["Мл.сержант"] = "Младший сержант", ["Ст.Лейтенант"] = "Старший лейтенант", ["Мл.Лейтенант"] = "Младший лейтенант"}
						passrank = ranksnesokr[passrank] ~= nil and ranksnesokr[passrank] or passrank
						lua_thread.create(function()
							local A_Index = 0
							while true do
								if A_Index == 5 then break end
								local str = sampGetChatString(99 - A_Index)
								local passnick = str:match(u8:decode"Имя%: (.*)")
								if passnick ~= nil then
									local surname = passnick:match(".*%_(.*)")
									if passnick ~= sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) then
										local passid = sampGetPlayerIdByNickname(passnick)
										if passid ~= nil then
											local result, passskin = sampGetPlayerSkin(passid)
											if result then
												if passskin ~= 287 and passskin ~= 191 then
													if passorg:match("Army LV") then
														local passclist = clists.numbers[sampGetPlayerColor(passid)]
														if passclist ~= 7 then chatManager.addMessageToQueue("Наденьте пожалуйста повязку №7") chatManager.addMessageToQueue("/b /clist 7") end
														local res, passHandle = sampGetCharHandleBySampPlayerId(passid)
														if res then
															if isCharInAnyCar(passHandle) then
																local fcarHandle = storeCarCharIsInNoSave(passHandle)
																if getDriverOfCar(fcarHandle) == passHandle and (alreadyUd[passnick] == nil or (os.time() - alreadyUd[passnick]) >= 60) then
																	checkpoint[passnick] = passrank
																	math.randomseed(os.time())
																	local var = math.random(1, 7)
																	local msg = ""
																	if var == 1 then msg = "Покажите удостоверение"
																		elseif var == 2 then msg = "Предъявите удостоверение"
																		elseif var == 3 then msg = "А теперь удостоверение"
																		elseif var == 4 then msg = "Отлично, удостоверение"
																		elseif var == 5 then msg = "Теперь нужно удостоверение"
																		elseif var == 6 then msg = "Далее нужно удостоверение"
																		elseif var == 7 then msg = "Для проезда потребуется удостоверение"
																	end
																	chatManager.addMessageToQueue(msg)
																	return
																end
															end
															f("В часть прибыл " .. passrank .. " " .. surname)
															chatManager.addMessageToQueue("Товарищ " .. passrank .. " " .. surname .. ", можете двигаться далее!")
															return
														end
													end
												end
											end
										end
									end
								end
								A_Index = A_Index + 1
							end
						end)
						else
						chatManager.addMessageToQueue("Товарищ " .. passrank .. ", можете проезжать!")
						return
					end
				end
			end
		end
		local s, sk = text:match(u8:decode"^ На складе (.*)%: (%d+)%/%d+$")
		if s ~= nil and s ~= u8:decode"Army LV" and col == -65281 then
			if solyanka_ini.bools.autocl then
				local res, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
				local myclist = clists.numbers[sampGetPlayerColor(myid)]
				if myclist == 0 then
					if tonumber(solyanka_ini.values.clist) ~= 0 then sampProcessChatInput("/cl " .. solyanka_ini.values.clist .. "") end
				end
			end
		end
		local myid = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
		local myn, myf = sampGetPlayerNickname(myid):match("(.*)%_(.*)")
		--local re1 = regex.new(u8:decode"\\{\\{ Солдат ([A-Za-z]+)\\_([A-Za-z]+)\\: ((.*)дравия(.*)аза|(.*)дравия(.*)елаю(.*)аза|(.*)дравия(.*)варищи(.*)|(.*)дравия(.*)елаю(.*)варищи(.*)|(.*)дравия(.*)елаю(.*)рмия(.*)|(.*)дравия(.*)рмия(.*)|(.*)дравия(.*)тал(.*)|(.*)дравия(.*)елаю(.*)тал(.*)|(.*)дравия(.*)це(.*)|(.*)дравия(.*)ойцы(.*)|(.*)дравия(.*)елаю(.*)ойцы(.*)|(.*)дравия(.*)елаю(.*)це(.*)|(.*)дравия(.*)елаю(.*)сть(.*)|(.*)дравия(.*)сть(.*)) \\}\\}")
		--local re2 = regex.new(u8:decode" ([A-Za-z]+)\\_([A-Za-z]+) крикнула?\\: ((.*)дравия(.*)аза|(.*)дравия(.*)елаю(.*)аза|(.*)дравия(.*)варищи(.*)|(.*)дравия(.*)елаю(.*)варищи(.*)|(.*)дравия(.*)елаю(.*)рмия(.*)|(.*)дравия(.*)рмия(.*)|(.*)дравия(.*)це(.*)|(.*)дравия(.*)елаю(.*)це(.*)|(.*)дравия(.*)тал(.*)|(.*)дравия(.*)елаю(.*)тал(.*)|(.*)дравия(.*)ойцы(.*)|(.*)дравия(.*)елаю(.*)ойцы(.*)|(.*)дравия(.*)елаю(.*)сть(.*)|(.*)дравия(.*)сть(.*))")
		-- if re1:match(text) ~= nil then
		-- local name, surname = re1:match(text)
		-- if myn ~= name and myf ~= surname then
		-- local offnick = u8:decode("" .. name .. "_" .. surname .. "")
		-- local temp = os.tmpname()
		-- local time = os.time()
		-- local found = false
		-- downloadUrlToFile("http://srp-addons.ru/om/fraction/Army%20LV", temp, function(_, status)
		-- if (status == 58) then
		-- local file = io.open(temp, "r")
		-- local currentRank
		-- for line in file:lines() do
		-- line = encoding.UTF8:decode(line)
		-- local offrank, offtm, offwm, offdate = line:match('%["' .. offnick .. '",(%d+),%[(%d+),(%d+)%],"(%d+/%d+/%d+ %d+%:%d+%:%d+)"%]')
		-- if tonumber(offrank) ~= nil and tonumber(offtm) ~= nil and tonumber(offwm) ~= nil and offdate ~= nil then
		-- found = true
		-- currentRank = tonumber(offrank)
		-- end
		-- end
		-- if not found then script.sendMessage("Ранг " .. offnick .. " не найден!") end
		-- file:close()
		-- os.remove(temp)
		-- if found then
		-- chatManager.addMessageToQueue("/s Здравия желаю, товарищ " .. zv[currentRank] .. " " .. offnick:match(".*%_(.*)") )
		-- end
		-- else
		-- if (os.time() - time > 10) then
		-- script.sendMessage("Превышено время загрузки файла, повторите попытку", 0xFFFFFFFF)
		-- return
		-- end
		-- end
		-- end)
		-- end
		-- end
		-- if re2:match(text) ~= nil then
			-- local name, surname = re2:match(text)
			-- if myn ~= name and myf ~= surname then
				-- local offnick = u8:decode("" .. name .. "_" .. surname .. "")
				-- local temp = os.tmpname()
				-- local time = os.time()
				-- local found = false
				-- downloadUrlToFile("http://srp-addons.ru/om/fraction/Army%20LV", temp, function(_, status)
					-- if (status == 58) then
						-- local file = io.open(temp, "r")
						-- local currentRank
						-- for line in file:lines() do
							-- line = encoding.UTF8:decode(line)
							-- local offrank, offtm, offwm, offdate = line:match('%["' .. offnick .. '",(%d+),%[(%d+),(%d+)%],"(%d+/%d+/%d+ %d+%:%d+%:%d+)"%]')
							-- if tonumber(offrank) ~= nil and tonumber(offtm) ~= nil and tonumber(offwm) ~= nil and offdate ~= nil then
								-- found = true
								-- currentRank = tonumber(offrank)
							-- end
						-- end
						-- if not found then script.sendMessage("Ранг " .. offnick .. " не найден!") end
						-- file:close()
						-- os.remove(temp)
						-- if found then
							-- chatManager.addMessageToQueue("/s Здравия желаю, товарищ " .. zv[currentRank] .. " " .. offnick:match(".*%_(.*)"))
						-- end
						-- else
						-- if (os.time() - time > 10) then
							-- script.sendMessage("Превышено время загрузки файла, повторите попытку", 0xFFFFFFFF)
							-- return
						-- end
					-- end
				-- end)
			-- end
		-- end
	end
end

function ev.onSendDeathNotification(reason, id)
	if solyanka_ini.bools.autocl then
		local result, sid = sampGetPlayerSkin(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
		if sid == 287 or sid == 191 then
			if tostring(solyanka_ini.values.clist) ~= nil then
				lua_thread.create(function()
					repeat wait(0) until getActiveInterior() ~= 0
					sampProcessChatInput("/cl " .. tostring(solyanka_ini.values.clist))
				end)
			end
		end
	end
end

function ev.onSendChat(message)
	chatManager.lastMessage = message
	chatManager.updateAntifloodClock()
end

function ev.onSendCommand(message)
	chatManager.lastMessage = message
	chatManager.updateAntifloodClock()
end

function ev.onSendEnterVehicle(vehid, pass)
	if pass then
		local id = getAmmoInCharWeapon(PLAYER_PED, 31) > 0 and 31 or getAmmoInCharWeapon(PLAYER_PED, 30) > 0 and 30 or 0 
		if id ~= 0 then 
			setCurrentCharWeapon(PLAYER_PED, id) 
		end
	end	
	
	local res, car = sampGetCarHandleBySampVehicleId(vehid)
	local door = getCarDoorLockStatus(car)
	if res and door == 2 then script.sendMessage("Вы пытаетесь сесть в закрытую машину. Действие отменено!") taskToggleDuck(PLAYER_PED, false) return false end
end

function sampGetPlayerIdByNickname(name)
	local name = tostring(name)
	local _, localId = sampGetPlayerIdByCharHandle(PLAYER_PED)
	for i = 0, 1000 do
		if (sampIsPlayerConnected(i) or localId == i) and sampGetPlayerNickname(i) == name then
			return i
		end
	end
end
-------------------------------------------[ChatManager -> взято из donatik.lua]------------------------------------------
chatManager = {}
chatManager.messagesQueue = {}
chatManager.messagesQueueSize = 1000
chatManager.antifloodClock = os.clock()
chatManager.lastMessage = ""
chatManager.antifloodDelay = 0.8

function chatManager.initQueue() -- очистить всю очередь сообщений
	for messageIndex = 1, chatManager.messagesQueueSize do
		chatManager.messagesQueue[messageIndex] = {
			message = "",
		}
	end
end

function chatManager.addMessageToQueue(string, _nonRepeat) -- добавить сообщение в очередь
	local isRepeat = false
	local nonRepeat = _nonRepeat or false
	
	if nonRepeat then
		for messageIndex = 1, chatManager.messagesQueueSize do
			if string == chatManager.messagesQueue[messageIndex].message then
				isRepeat = true
			end
		end
	end
	
	if not isRepeat then
		for messageIndex = 1, chatManager.messagesQueueSize - 1 do
			chatManager.messagesQueue[messageIndex].message = chatManager.messagesQueue[messageIndex + 1].message
		end
		chatManager.messagesQueue[chatManager.messagesQueueSize].message = string
	end
end

function chatManager.checkMessagesQueueThread() -- проверить поток очереди сообщений
	while true do
		wait(0)
		for messageIndex = 1, chatManager.messagesQueueSize do
			local message = chatManager.messagesQueue[messageIndex]
			if message.message ~= "" then
				if string.sub(chatManager.lastMessage, 1, 1) ~= "/" and string.sub(message.message, 1, 1) ~= "/" then
					chatManager.antifloodDelay = chatManager.antifloodDelay + 0.5
				end
				if os.clock() - chatManager.antifloodClock > chatManager.antifloodDelay then
					
					local sendMessage = true
					
					local command = string.match(message.message, "^(/[^ ]*).*")
					
					if sendMessage then
						chatManager.lastMessage = u8:decode(message.message)
						sampSendChat(u8:decode(message.message))
					end
					
					message.message = ""
				end
				chatManager.antifloodDelay = 0.8
			end
		end
	end
end

function chatManager.updateAntifloodClock() -- обновить задержку из-за определённых сообщений
	chatManager.antifloodClock = os.clock()
	if string.sub(chatManager.lastMessage, 1, 5) == "/sms " or string.sub(chatManager.lastMessage, 1, 3) == "/t " then
		chatManager.antifloodClock = chatManager.antifloodClock + 0.5
	end
end

function f(t)
	if t ~= nil then
		chatManager.addMessageToQueue("/f " .. u8(tag) .. t)
	end
end
--------------------------------------------------------------------------------------------------------------------------
function cmd_viezd(s)
	lua_thread.create(function()
		if s == "" then script.sendMessage("Ошибка! Введите /viezd [число грузовиков] [пункт назначения]") return end
		local p = {}
		for v in string.gmatch(s, "[^%s]+") do table.insert(p, v) end
		local k = {[1] = "один", [2] = "два", [3] = "три", [4] = "четыре", [5] = "пять", [6] = "шесть", [7] = "семь"}
		if tonumber(p[1]) == nil or k[tonumber(p[1])] == nil then script.sendMessage("Неверное число грузовиков!") return end
		local kol = tonumber(p[1])
		local arr = {
			["ls"] = "Police LS", ["lspd"] = "Police LS", ["лс"] = "Police LS", ["лспд"] = "Police LS",
			["sfpd"] = "Police SF", ["сфпд"] = "Police SF",
			["lv"] = "Police LV", ["lvpd"] = "Police LV", ["лв"] = "Police LV", ["лвпд"] = "Police LV",
			["fbi"] = "FBI", ["фбр"] = "FBI",
			["sfa"] = "Army SF", ["сфа"] = "Army SF",
			["sf"] = "г. San-Fierro", ["сф"] = "г. San-Fierro"
		}
		if arr[u8(p[2])] == nil then script.sendMessage("Неверно указан пункт назначения!") return end
		f("Выезжаем в " .. arr[u8(p[2])] .. ", " .. k[kol] .. " грузовика")
	end)
end

function cmd_cam(action)
	if action:match("on") then
		chatManager.addMessageToQueue("/seeme нажал на кнопку включения видеокамеры на бронежилете")
		chatManager.addMessageToQueue("/seedo Камера фиксирует всё происходящее на удаленный сервер Army LV.")
		elseif action:match("off") then
		chatManager.addMessageToQueue("/seeme нажал на кнопку выключения записи")
		chatManager.addMessageToQueue("/seedo Запись сохранена на удаленный сервер.")
		else
		chatManager.addMessageToQueue("/seedo На бронежилете закреплена видеокамера.")
		chatManager.addMessageToQueue("/seedo Камера включена и записывает всё происходящее на удаленный сервер.")
	end
end

function script.sendMessage(t)
	sampAddChatMessage(prefix .. u8:decode(t), main_color)
end

function makeHotKey(numkey)
	local rett = {}
	for _, v in ipairs(string.split(solyanka_ini.hotkey[numkey], ", ")) do
		if tonumber(v) ~= 0 then table.insert(rett, tonumber(v)) end
	end
	return rett
end

function string.split(str, delim, plain) -- bh FYP
	local tokens, pos, plain = {}, 1, not (plain == false) --[[ delimiter is plain text by default ]]
	repeat
		local npos, epos = string.find(str, delim, pos, plain)
		table.insert(tokens, string.sub(str, pos, npos and npos - 1))
		pos = epos and epos + 1
	until not pos
	return tokens
end

function imgui.Hotkey(name, numkey, width)
	imgui.BeginChild(name, imgui.ImVec2(width, 32), true)
	imgui.PushItemWidth(width)
	
	local hstr = ""
	for _, v in ipairs(string.split(solyanka_ini.hotkey[numkey], ", ")) do
		if v ~= "0" then
			hstr = hstr == "" and tostring(vkeys.id_to_name(tonumber(v))) or "" .. hstr .. " + " .. tostring(vkeys.id_to_name(tonumber(v))) .. ""
		end
	end
	hstr = (hstr == "" or hstr == "nil") and "Нет клавиши" or hstr
	
	imgui.Text(hstr)
	imgui.PopItemWidth()
	imgui.EndChild()
	if imgui.IsItemClicked() then
		lua_thread.create(
			function()
				local curkeys = ""
				local tbool = false
				while true do
					wait(0)
					if not tbool then
						for k, v in pairs(vkeys) do
							sv = tostring(v)
							if isKeyDown(v) and (v == vkeys.VK_MENU or v == vkeys.VK_CONTROL or v == vkeys.VK_SHIFT or v == vkeys.VK_LMENU or v == vkeys.VK_RMENU or v == vkeys.VK_RCONTROL or v == vkeys.VK_LCONTROL or v == vkeys.VK_LSHIFT or v == vkeys.VK_RSHIFT) then
								if v ~= vkeys.VK_MENU and v ~= vkeys.VK_CONTROL and v ~= vkeys.VK_SHIFT then
									if not curkeys:find(sv) then
										curkeys = tostring(curkeys):len() == 0 and sv or curkeys .. " " .. sv
									end
								end
							end
						end
						
						for k, v in pairs(vkeys) do
							sv = tostring(v)
							if isKeyDown(v) and (v ~= vkeys.VK_MENU and v ~= vkeys.VK_CONTROL and v ~= vkeys.VK_SHIFT and v ~= vkeys.VK_LMENU and v ~= vkeys.VK_RMENU and v ~= vkeys.VK_RCONTROL and v ~= vkeys.VK_LCONTROL and v ~= vkeys.VK_LSHIFT and v ~=vkeys. VK_RSHIFT) then
								if not curkeys:find(sv) then
									curkeys = tostring(curkeys):len() == 0 and sv or curkeys .. " " .. sv
									tbool = true
								end
							end
						end
						else
						tbool2 = false
						for k, v in pairs(vkeys) do
							sv = tostring(v)
							if isKeyDown(v) and (v ~= vkeys.VK_MENU and v ~= vkeys.VK_CONTROL and v ~= vkeys.VK_SHIFT and v ~= vkeys.VK_LMENU and v ~= vkeys.VK_RMENU and v ~= vkeys.VK_RCONTROL and v ~= vkeys.VK_LCONTROL and v ~= vkeys.VK_LSHIFT and v ~=vkeys. VK_RSHIFT) then
								tbool2 = true
								if not curkeys:find(sv) then
									curkeys = tostring(curkeys):len() == 0 and sv or curkeys .. " " .. sv
								end
							end
						end
						
						if not tbool2 then break end
					end
				end
				
				local keys = ""
				if tonumber(curkeys) == vkeys.VK_BACK then
					solyanka_ini.hotkey[numkey] = "0"
					else
					local tNames = string.split(curkeys, " ")
					for _, v in ipairs(tNames) do
						local val = (tonumber(v) == 162 or tonumber(v) == 163) and 17 or (tonumber(v) == 160 or tonumber(v) == 161) and 16 or (tonumber(v) == 164 or tonumber(v) == 165) and 18 or tonumber(v)
						keys = keys == "" and val or "" .. keys .. ", " .. val .. ""
					end
				end
				
				solyanka_ini.hotkey[numkey] = keys
				inicfg.save(solyanka_ini, settings)
			end
		)
	end
end

function sampGetPlayerSkin(id)
	if not id or not sampIsPlayerConnected(tonumber(id)) and not tonumber(id) == select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) then return false end -- проверяем параметр
	local isLocalPlayer = tonumber(id) == select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) -- проверяем, является ли цель локальным игроком
	local result, handle = sampGetCharHandleBySampPlayerId(tonumber(id)) -- получаем CharHandle по SAMP-ID
	local result, handle = sampGetCharHandleBySampPlayerId(tonumber(id)) -- получаем CharHandle по SAMP-ID
	if not result and not isLocalPlayer then return false end -- проверяем, валиден ли наш CharHandle
	local skinid = getCharModel(isLocalPlayer and PLAYER_PED or handle) -- получаем скин нашего CharHandle
	if skinid < 0 or skinid > 311 then return false end -- проверяем валидность нашего скина, сверяя ID существующих скинов SAMP
	return true, skinid -- возвращаем статус и ID скина
end

function checkaccess(nick)
	lua_thread.create(function()
		local json = req(macros .. "=login&nick=" .. currentNick)
		if json ~= nil then
			if json:match("No access") then 
				script.sendMessage(nick .. " - нет доступа блять.")
				script.unload = true 
				thisScript():unload()
				return 
			end
			local info = decodeJson(json)
			if info ~= nil then
				script.sendMessage(nick .. " - успешная авторизация.")
				script.v.num = info.
				script.v.date = info.date
				script.url = info.url
				script.upd.changes = info.upd
				if script.upd.changes then
					for k in pairs(script.upd.changes) do
						table.insert(script.upd.sort, k)
					end
					table.sort(script.upd.sort, function(a, b) return a > b end)
				end
				script.checked = true
				if info.version > thisScript()['version_num'] then
					script.sendMessage(updatingprefix .. "Обнаружена новая версия скрипта от " .. info.date .. ", обновление начинается прямо сейчас")
					script.sendMessage(updatingprefix .. "Изменения в новой версии:")
					if script.upd.sort ~= {} then
						for k in ipairs(script.upd.sort) do
							if script.upd.changes[tostring(k)] ~= nil then
								script.sendMessage(updatingprefix .. k .. ') ' .. script.upd.changes[tostring(k)])
							end
						end
					end
					updateScript()
					return
				end
				else
				script.sendMessage("Не удалось получить информацию, перезапустите скрипт")
			end
			else
			script.sendMessage("Не удалось получить информацию, перезапустите скрипт")
			thisScript():unload()
		end
	end)
end

function req(u)
	while not script.freereq do wait(0) end
	script.freereq = false
	req_index = req_index + 1
	local url = u
	local file_path = os.tmpname()
	while true do
		script.complete = false
		download_id = downloadUrlToFile(url, file_path, download_handler)
		while not script.complete do wait(0) end
		wait(1000)
		local responsefile = io.open(file_path, "r")
		if responsefile ~= nil then
			local responsetext = responsefile:read("*a")
			io.close(responsefile)
			os.remove(file_path)
			script.freereq = true
			return u8:decode(responsetext)
		end
		os.remove(file_path)
		script.sendMessage("Неудача при выполнении запроса №" .. req_index .. ", повторяю попытку...", 0xFF006400)
	end
	return ""
end

function download_handler(id, status, p1, p2)
	if stop_downloading then
		stop_downloading = false
		download_id = nil
		return false -- прервать загрузку
	end
	
	if status == dlstatus.STATUS_ENDDOWNLOADDATA then
		script.complete = true
	end
end

function updateScript()
	script.update = true
	downloadUrlToFile(script.url, thisScript().path, function(_, status, _, _)
		if status == 6 then
			script.sendMessage(updatingprefix .. "Скрипт был обновлён!")
			if script.find("ML-AutoReboot") == nil then
				thisScript():reload()
			end
		end
	end)
end

function onScriptTerminate(s, bool)
	if s == thisScript() and not bool then
		imgui.Process = false
		if not script.noaccess then
			if not script.reload then
				if not script.update then
					if not script.unload then
						script.sendMessage("Скрипт крашнулся: отправьте moonloader.log разработчику")
						else
						script.sendMessage("Скрипт был выгружен")
					end
					else
					script.sendMessage(updatingprefix .. "Старый скрипт был выгружен, загружаю обновлённую версию...")
				end
				else
				script.sendMessage("Перезагружаюсь...")
			end
			else
			return
		end
	end			
end
