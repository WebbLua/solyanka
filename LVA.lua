script_name('Las-Venturas Army')
script_author("Lavrentiy_Beria | Telegram: @Imykhailovich")
script_version("18.02.2023")
script_version_number(7)
local script = {checked = false, available = false, update = false, noaccess = false, v = {date, num}, url, access = {}, reload, loaded, unload, upd = {changes = {}, sort = {}}, label = {}}
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
local AdressConfig, AdressFolder, settings, lva_ini, server

local config = {
	bools = {
		sex = false,
		cl7 = false,
		bp = false,
		tp = false,
		elevator = false,
		autocl = false,
		fcol = false,
		mat = false
	},
	hotkey = {
		clist = '0',
		ration = '0',
		zdrav = '0',
		sos = '0'
	},
	values = {
		tag = "",
		clist = 0
	}
}
-------------------------------------------------------------------------[Переменные и маcсивы]-----------------------------------------------------------------
local main_color = 0xFF59A655
local prefix = "{59A655}[Army LV] {FFFAFA}"
local updatingprefix = "{FF0000}[ОБНОВЛЕНИЕ] {FFFAFA}"
local antiflood = 0
local needtoreload = false
local needtocl7 = true

local menu = { -- imgui-меню
	main = imgui.ImBool(false),
	settings = imgui.ImBool(true),
	information = imgui.ImBool(false),
	commands = imgui.ImBool(false),
	target = imgui.ImBool(false)
}
imgui.ShowCursor = false

local style = imgui.GetStyle()
local colors = style.Colors
local clr = imgui.Col
local suspendkeys = 2 -- 0 хоткеи включены, 1 -- хоткеи выключены -- 2 хоткеи необходимо включить
local ImVec4 = imgui.ImVec4
local imfonts = {mainFont = nil, smallmainFont = nil, memfont = nil}
local targetId, targetNick

local tag = ""
local a = ""
local fuelTextDraw = 0
local currentNick
local currentFuel, currentPickup = 0, 0
local wasInTruck = false
local lastPost
local isarmtaken = false
local partimer = 0
local postarray = {}
local alreadyUd = {}

local waffenlieferungen = {
	[1] = false, -- был ли ответ на /carm (для пропуска следующего диалога)
	[2] = 0, -- количество материалов в грузовике
	[3] = false, -- был ли вызван /carm ради мониторинга
	[4] = { -- мониторинг фракций
		["LSPD"] = 0, 
		["SFPD"] = 0,
		["LVPD"] = 0, 
		["FBI"] = 0, 
		["SFA"] = 0
	},
	[5] = { -- массив для автоматического /carm
		[1] = false, -- был ли вызван /carm скриптом (если вручную то скипа нет)
		[2] = false, -- заехал ли грузовик в область автоматической активации
		[3] = {[1] = {["x1"] = 322, ["y1"] = 1918, ["x2"] = 344, ["y2"] = 1979}, [2] = {["x1"] = 2211, ["y1"] = 2444, ["x2"] = 2250, ["y2"] = 2506}, [3] = {["x1"] = 1515, ["y1"] = -1667, ["x2"] = 1535, ["y2"] = -1586}, [4] = {["x1"] = -1722, ["y1"] = 672, ["x2"] = -1696, ["y2"] = 723}, [5] = {["x1"] = -1491, ["y1"] = 325, ["x2"] = -1543, ["y2"] = 386}, [6] = {["x1"] = -2467, ["y1"] = 457, ["x2"] = -2389, ["y2"] = 528}},
		-- 1 LVA 2 LVPD 3 LSPD 4 SFPD 5 SFA 6 FBI
		-- координаты областей автоматической активации
		[4] = {}, -- временный массив
	},
	[6] = false, -- отправка в сквад, заместь рации
	[7] = 0, -- время разгрузки в UNIX
	[8] = nil, -- последний склад разгрузки
	[9] = 0, -- кол-во разгруж. матов
	[10] = false -- запрос моника из рации
}

local clists = {
	numbers = {
		[16777215] = 0,    [2852758528] = 1,  [2857893711] = 2,  [2857434774] = 3,  [2855182459] = 4, [2863589376] = 5,
		[2854722334] = 6,  [2858002005] = 7,  [2868839942] = 8,  [2868810859] = 9,  [2868137984] = 10,
		[2864613889] = 11, [2863857664] = 12, [2862896983] = 13, [2868880928] = 14, [2868784214] = 15,
		[2868878774] = 16, [2853375487] = 17, [2853039615] = 18, [2853411820] = 19, [2855313575] = 20,
		[2853260657] = 21, [2861962751] = 22, [2865042943] = 23, [2860620717] = 24, [2868895268] = 25,
		[2868899466] = 26, [2868167680] = 27, [2868164608] = 28, [2864298240] = 29, [2863640495] = 30,
		[2864232118] = 31, [2855811128] = 32, [2866272215] = 33
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

local posts = {
	{"КПП-1", 124, 1923, 185, 1965},
	{"КПП-2", 83, 1911, 112, 1933},
	{"ШП", 131, 1830, 157, 1861},
	{"МС", 140, 1801, 271, 1829},
	{"Переход", 272, 1776, 303, 1837},
	{"Сетка", 324, 1776, 361, 1835},
	{"ГС", 317, 1916, 387, 2005},
	{"Ангары", 262, 1927, 295, 2041}
}

function calculateNamedZone(x, y)
	local streets = {
		{"КПП-1", 124, 1923, 185, 1965},
		{"КПП-2", 83, 1911, 112, 1933},
		{"ШП", 131, 1830, 157, 1861},
		{"МС", 140, 1801, 271, 1829},
		{"переход", 272, 1776, 303, 1837},
		{"сетка", 324, 1776, 361, 1835},
		{"ГС", 317, 1916, 387, 2005},
		{"штаб", 120, 1859, 169, 1909},
		{"АПГС", 314.72204589844, 1976.8389892578, 361.05847167969, 1997.9039306641},
		{"ПВО у ГС", 320.33129882813, 2000.4631347656, 389.52633666992, 2080.7666015625},
		{"истребители", 295.23022460938, 2039.4656982422, 342.81295776367, 2080.78515625},
		{"полигон", 232.20492553711, 2043.1343994141, 296.06756591797, 2080.6027832031},
		{"ВПВО", 167.20301818848, 2048.6098632813, 210.35835266113, 2096.4182128906},
		{"за ангарами", 190.67858886719, 1942.5600585938, 262.72842407227, 2042.2639160156},
		{"1-й ангар", 265.51791381836, 1929.8996582031, 295.75692749023, 1972.7664794922},
		{"2-й ангар", 265.43209838867, 1972.6845703125, 297.45654296875, 2006.7365722656},
		{"3-й ангар", 264.81323242188, 2006.5007324219, 301.76574707031, 2039.2580566406},
		{"Апачи", 286.65985107422, 1863.5485839844, 310.69515991211, 1913.8908691406},
		{"тир у ГС", 339.08380126953, 1884.8133544922, 389.3662109375, 1920.5795898438},
		{"за ГС", 365.86309814453, 1914.4924316406, 389.50433349609, 1995.4713134766},
		{"парковка", 142.83898925781, 1941.9774169922, 181.14910888672, 1961.2012939453},
		{"ВП", 181.36192321777, 1915.5819091797, 230.00909423828, 1940.7563476563},
		{"бункер", 190.58190917969, 1853.5491943359, 243.44374084473, 1908.6638183594},
		{"яма", 254.46928405762, 1855.6944580078, 283.2751159668, 1897.3565673828},
		{"за истребителями", 230.97929382324, 2092.1794433594, 391.40338134766, 2174.4379882813},
		{"за ГС", 391.09713745117, 1885.0858154297, 450.3313293457, 2088.3425292969},
		{"балкон", 466.75439453125, 1898.4833984375, 550.46246337891, 2099.1572265625},
		{"холмы", 319.2917175293, 1570.2087402344, 519.72833251953, 1778.1770019531},
	}
	
	for i, v in ipairs(streets) do
		if (x >= v[2]) and (y >= v[3]) and (x <= v[4]) and (y <= v[5]) then
			return v[1]
		end
	end
	
	return nil
end

function kvadrat()
    local KV = {
        [1] = "А",
        [2] = "Б",
        [3] = "В",
        [4] = "Г",
        [5] = "Д",
        [6] = "Ж",
        [7] = "З",
        [8] = "И",
        [9] = "К",
        [10] = "Л",
        [11] = "М",
        [12] = "Н",
        [13] = "О",
        [14] = "П",
        [15] = "Р",
        [16] = "С",
        [17] = "Т",
        [18] = "У",
        [19] = "Ф",
        [20] = "Х",
        [21] = "Ц",
        [22] = "Ч",
        [23] = "Ш",
        [24] = "Я",
	}
    local X, Y, Z = getCharCoordinates(playerPed)
    X = math.ceil((X + 3000) / 250)
    Y = math.ceil((Y * - 1 + 3000) / 250)
    Y = KV[Y]
    local KVX = (Y.."-"..X)
    return KVX
end
-------------------------------------------------------------------------[MAIN]--------------------------------------------------------------------------------------------
function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(0) end
	
	while sampGetCurrentServerName() == "SA-MP" do wait(0) end
	server = sampGetCurrentServerName():gsub('|', '')
	server = (server:find('02') and 'Two' or (server:find('Revo') and 'Revolution' or (server:find('Legacy') and 'Legacy' or (server:find('Classic') and 'Classic' or nil))))
    if server == nil then script.sendMessage('Данный сервер не поддерживается, выгружаюсь...') script.unload = true thisScript():unload() end
	currentNick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
	
	AdressConfig = string.format("%s\\config", thisScript().directory)
    AdressFolder = string.format("%s\\config\\Army LV by Webb\\%s\\%s", thisScript().directory, server, currentNick)
	settings = string.format("Army LV by Webb\\%s\\%s\\settings.ini", server, currentNick)
	
	if not doesDirectoryExist(AdressConfig) then createDirectory(AdressConfig) end
	if not doesDirectoryExist(AdressFolder) then createDirectory(AdressFolder) end
	
	if lva_ini == nil then -- загружаем конфиг
		lva_ini = inicfg.load(config, settings)
		inicfg.save(lva_ini, settings)
	end
	
	tag = lva_ini.values.tag ~= "" and lva_ini.values.tag .. " " or ""
	a = lva_ini.bools.sex and "а" or ""
	
	togglebools = {
		sex = lva_ini.bools.sex and imgui.ImBool(true) or imgui.ImBool(false),
		cl7 = lva_ini.bools.cl7 and imgui.ImBool(true) or imgui.ImBool(false),
		bp = lva_ini.bools.bp and imgui.ImBool(true) or imgui.ImBool(false),
		tp = lva_ini.bools.tp and imgui.ImBool(true) or imgui.ImBool(false),
		elevator = lva_ini.bools.elevator and imgui.ImBool(true) or imgui.ImBool(false),
		autocl = lva_ini.bools.autocl and imgui.ImBool(true) or imgui.ImBool(false),
		fcol = lva_ini.bools.fcol and imgui.ImBool(true) or imgui.ImBool(false),
		mat = lva_ini.bools.mat and imgui.ImBool(true) or imgui.ImBool(false)
	}
	buffer = {
		clist = imgui.ImInt(lva_ini.values.clist),
		tag = imgui.ImBuffer(u8(lva_ini.values.tag), 256)
	}
	
	sampRegisterChatCommand("lva", function() 
		for k, v in pairs(lva_ini.hotkey) do 
			local hk = makeHotKey(k) 
			if tonumber(hk[1]) ~= 0 then 
				rkeys.unRegisterHotKey(hk) 
			end 
		end
		suspendkeys = 1 
		menu.main.v = not menu.main.v
	end)
	
	sampRegisterChatCommand('armyup', updateScript)
	sampRegisterChatCommand('vzyal', cmd_vzyal)
	sampRegisterChatCommand('vern', cmd_vern)
	sampRegisterChatCommand('vernul', cmd_vern)
	sampRegisterChatCommand('razg', cmd_razg)
	sampRegisterChatCommand('razgruzka', cmd_razg)
	sampRegisterChatCommand('zas', cmd_zas)
	sampRegisterChatCommand('zastupil', cmd_zas)
	sampRegisterChatCommand('pok', cmd_pok)
	sampRegisterChatCommand('pokinul', cmd_pok)
	sampRegisterChatCommand("viezd", cmd_viezd)
	sampRegisterChatCommand("port", cmd_port)
	sampRegisterChatCommand("prib", cmd_prib)
	sampRegisterChatCommand("pribil", cmd_prib)
	sampRegisterChatCommand("mon", cmd_mon)
	
	script.loaded = true
	while sampGetGamestate() ~= 3 do wait(0) end
	while sampGetPlayerScore(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) <= 0 and not sampIsLocalPlayerSpawned() do wait(0) end
	checkUpdates()
	script.sendMessage("Скрипт запущен. Открыть главное меню - /lva")
	imgui.Process = true
	needtoreload = true
	
	chatManager.initQueue()
	lua_thread.create(chatManager.checkMessagesQueueThread)
	lua_thread.create(function() f_matovoz() end)
	while true do
		wait(0)
		
		if suspendkeys == 2 then
			rkeys.registerHotKey(makeHotKey('clist'), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end setclist() end)
			rkeys.registerHotKey(makeHotKey('ration'), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end sampSetChatInputEnabled(true) sampSetChatInputText("/f " .. tag) end)
			rkeys.registerHotKey(makeHotKey('zdrav'), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end hello() end)
			rkeys.registerHotKey(makeHotKey('sos'), true, function() if sampIsChatInputActive() or sampIsDialogActive(-1) or isSampfuncsConsoleActive() then return end sos() end)
			suspendkeys = 0
		end
		
		if not menu.main.v then 
			imgui.ShowCursor = false
			if suspendkeys == 1 then 
				suspendkeys = 2 
				sampSetChatDisplayMode(3) 
			end
		end
		
		textLabelOverPlayerNickname()
		
		if needtocl7 and isCharInArea2d(PLAYER_PED, -84, 1606, 464, 2148, false) then
			needtocl7 = false
			if lva_ini.bools.cl7 then
				local result1, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
				if result1 then
					local result2, sid = sampGetPlayerSkin(myid)
					if result2 then
						if sid ~= 287 and sid ~= 191 then
							script.sendMessage("Вы заехали на базу, надеваю клист...")
							chatManager.addMessageToQueue("/clist 7")
						end
					end
				end
			end
		end
		
		if (os.time() - waffenlieferungen[7])/60 >= 5 then waffenlieferungen[7] = 0 end
		
		local x, y, z = getCharCoordinates(PLAYER_PED)
		for i, v in ipairs(posts) do
			if (x >= v[2]) and (y >= v[3]) and (x <= v[4]) and (y <= v[5]) then
				lastPost = v[1]
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
		
		if menu.target.v then
			if wasKeyPressed(vkeys.VK_O) then
				if targetNick ~= nil and targetId ~= nil then
					offNick = u8:decode(targetNick)
					local temp = os.tmpname()
					local time = os.time()
					local found = false
					downloadUrlToFile("http://srp-addons.ru/om/fraction/Army%20LV", temp, function(_, status)
						if (status == 58) then
							local file = io.open(temp, "r")
							local currentRank
							for line in file:lines() do
								line = encoding.UTF8:decode(line)
								local offrank, offtm, offwm, offdate = line:match('%["' .. offNick .. '",(%d+),%[(%d+),(%d+)%],"(%d+/%d+/%d+ %d+%:%d+%:%d+)"%]')
								if tonumber(offrank) ~= nil and tonumber(offtm) ~= nil and tonumber(offwm) ~= nil and offdate ~= nil then
									found = true
									currentRank = tonumber(offrank)
								end
							end
							if not found then script.sendMessage("Ранг " .. offNick .. " не найден!") end
							file:close()
							os.remove(temp)
							if found then
								chatManager.addMessageToQueue("Здравия желаю, товарищ " .. zv[currentRank] .. " " .. offNick:match(".*%_(.*)") .. "!")
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
			if wasKeyPressed(vkeys.VK_J) then
				if targetNick ~= nil and targetId ~= nil then
					offNick = u8:decode(targetNick)
					local temp = os.tmpname()
					local time = os.time()
					local found = false
					downloadUrlToFile("http://srp-addons.ru/om/fraction/Army%20LV", temp, function(_, status)
						if (status == 58) then
							local file = io.open(temp, "r")
							local currentRank, myRank
							local mynick = u8:decode(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(PLAYER_PED))))
							for line in file:lines() do
								line = encoding.UTF8:decode(line)
								local offrank, offtm, offwm, offdate = line:match('%["' .. offNick .. '",(%d+),%[(%d+),(%d+)%],"(%d+/%d+/%d+ %d+%:%d+%:%d+)"%]')
								local myrank, mytm, mywm, mydate = line:match('%["' .. mynick .. '",(%d+),%[(%d+),(%d+)%],"(%d+/%d+/%d+ %d+%:%d+%:%d+)"%]')
								if tonumber(offrank) ~= nil and tonumber(offtm) ~= nil and tonumber(offwm) ~= nil and offdate ~= nil then
									found = true
									currentRank = tonumber(offrank)
								end
								if tonumber(myrank) ~= nil and tonumber(mytm) ~= nil and tonumber(mywm) ~= nil and mydate ~= nil then
									myRank = tonumber(myrank)
								end
							end
							if not found then script.sendMessage("Ранг " .. offNick .. " не найден!") end
							file:close()
							os.remove(temp)
							if found then
								chatManager.addMessageToQueue("Товарищ " .. zv[currentRank] .. " " .. offNick:match(".*%_(.*)") .. ", товарищ " .. (zv[myRank] ~= nil and zv[myRank] or "") .. " " .. mynick:match(".*%_(.*)") .. " по вашему приказу прибыл!")
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
		imgui.Begin(thisScript().name .. (script.available and ' [Доступно обновление: v' .. script.v.num .. ' от ' .. script.v.date .. ']' or ' v' .. script.v.num .. ' от ' .. script.v.date), menu.main, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
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
				lva_ini.values.clist = tostring(u8:decode(buffer.clist.v)) 
				inicfg.save(lva_ini, settings) 
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
			imgui.PopItemWidth()
			imgui.PopFont()
			
			imgui.Text("Введите ваш тэг в рацию")
			imgui.SameLine() 
			imgui.PushItemWidth(120)
			if imgui.InputText('##tag', buffer.tag) then 
				lva_ini.values.tag = tostring(u8:decode(buffer.tag.v))
				tag = lva_ini.values.tag ~= "" and lva_ini.values.tag .. " " or ""
				inicfg.save(lva_ini, settings) 
			end 
			imgui.PopItemWidth() 
			
			if imgui.ToggleButton("sex", togglebools.sex) then 
				lva_ini.bools.sex = togglebools.sex.v
				a = lva_ini.bools.sex and "а" or ""
				inicfg.save(lva_ini, settings)
			end
			imgui.SameLine() 
			imgui.Text("Женский пол")
			
			if imgui.ToggleButton("cl7", togglebools.cl7) then 
				lva_ini.bools.cl7 = togglebools.cl7.v
				inicfg.save(lva_ini, settings)
			end
			imgui.SameLine() 
			imgui.Text("Автоматически вводить /clist 7 на базе после захода в игру")
			
			if imgui.ToggleButton("bp", togglebools.bp) then 
				lva_ini.bools.bp = togglebools.bp.v
				inicfg.save(lva_ini, settings)
			end
			imgui.SameLine() 
			imgui.Text("Автоматически брать БП на складе")
			
			if imgui.ToggleButton("tp", togglebools.tp) then 
				lva_ini.bools.tp = togglebools.tp.v
				inicfg.save(lva_ini, settings)
			end
			imgui.SameLine() 
			imgui.Text("Автоматически брать пикап выхода после взятия БП на 1 этаже штаба")
			
			if imgui.ToggleButton("elevator", togglebools.elevator) then 
				lva_ini.bools.elevator = togglebools.elevator.v
				inicfg.save(lva_ini, settings)
			end
			imgui.SameLine() 
			imgui.Text("'Лифт' - пропускать диалоги в штабе / Если хотите попасть на 3 этаж, зажмите ALT")
			
			if imgui.ToggleButton("autocl", togglebools.autocl) then 
				lva_ini.bools.autocl = togglebools.autocl.v
				inicfg.save(lva_ini, settings)
			end
			imgui.SameLine() 
			imgui.Text("'Автоклист' - автомаитчески вводить клист после: нач.раб.дня, завершения раб.дня, смерти")
			
			if imgui.ToggleButton("fcol", togglebools.fcol) then 
				lva_ini.bools.fcol = togglebools.fcol.v
				inicfg.save(lva_ini, settings)
			end
			imgui.SameLine() 
			imgui.Text("Окрашивать ник и ID в чате фракции в цвет клиста")
			if imgui.IsItemHovered() then 
				imgui.BeginTooltip() 
				imgui.TextUnformatted("Если есть другие скрипты с этой функцией, НАСТОЯТЕЛЬНО рекомендую отключить в них её! Что бы потом не было вопросов") 
				imgui.EndTooltip() 
			end
			
			if imgui.ToggleButton("mat", togglebools.mat) then 
				lva_ini.bools.mat = togglebools.mat.v
				inicfg.save(lva_ini, settings)
			end
			imgui.SameLine() 
			imgui.Text("Автоматически вводить /carm для загрузки/разгрузки")
			
			imgui.EndChild()
		end
		
		if not menu.settings.v and menu.information.v then
			imgui.Text("Данный скрипт является хелпером для LVA")
			imgui.Text("Автор: Lavrentiy_Beria | Telegram: @Imykhailovich")
			imgui.SameLine()
			imgui.PushFont(imfonts.smallmainFont)
			if imgui.Button("Написать разработчику", imgui.ImVec2(180.0, 23.0)) then os.execute('explorer "https://t.me/Imykhailovich"') end
			imgui.PopFont()
			imgui.NewLine()
			imgui.Text("Все настройки автоматически сохраняются в файл:\nmoonloader//config//Army LV by Webb//Server//Nick_Name")
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
				"/lva - открыть главное меню скрипта",
				"/armyup - обновить скрипт",
				"/vzyal - взять грузовик",
				"/vern (/vernul) - вернуть грузовик",
				"/razg (/razgruzka) - доклад о разгрузке",
				"/zas [состав] - заступить на пост (нужно находится на посту)",
				"/pok [состав] [причина] - покинуть пост (последний пост)",
				"/viezd - доложить о выезде колонны ВМО",
				"/port - доложить о выезде в порт",
				"/prib (/pribil) - доложить о прибытии бойца",
				"/mon - отправить мониторинг в рацию"
			}
			local w = 0
			local sortcmds = {}
			for k, v in ipairs(cmds) do table.insert(sortcmds, imgui.CalcTextSize(v).x) end
			table.sort(sortcmds, function(a, b) return a < b end)
			for k, v in ipairs(sortcmds) do
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
				if sampGetPlayerNickname(i) == "Lavrentiy_Beria" or sampGetPlayerNickname(i) == "Cody_Webb" then
					local ownernick = sampGetPlayerNickname(i)
					if imgui.Button(ownernick .. "[" .. i .. "] сейчас в сети", imgui.ImVec2(260.0, 30.0)) then
						chatManager.addMessageToQueue("/sms " .. i .. " Я пользуюсь LVA.lua, большое спасибо")
					end
					found = true
				end
			end
		end
		if not found then
			if imgui.Button("Lavrentiy Beria сейчас не в сети", imgui.ImVec2(260.0, 30.0)) then
				script.sendMessage("Lavrentiy Beria играет на Revolution (сейчас не онлайн)")
			end
		end
		
		imgui.PushFont(imfonts.smallmainFont)
		imgui.SetCursorPos(imgui.ImVec2(25, wh/2 + 215))
		if imgui.Button("Все команды скрипта", imgui.ImVec2(170.0, 23.0)) then menu.commands.v = true end
		imgui.PopFont()
		
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
			imgui.TextColoredRGB('O' .. ' - Здравия желаю')
			imgui.TextColoredRGB('J' .. ' - По вашему приказу прибыл')
		end
		imgui.PopFont()
		imgui.End()
	end
	
end
-------------------------------------------------------------------------[ФУНКЦИИ]-----------------------------------------------------------------------------------------
function ev.onServerMessage(col, text)
	if script.loaded then
		if col == -356056833 and text:match(u8:decode"^ Для восстановления доступа нажмите клавишу %'F6%' и введите %'%/restoreAccess%'") then needtocl7 = true if needtoreload then script.reload = true thisScript():reload() end end
		if lva_ini.bools.autocl and col == 1790050303 then
			if text:match(u8:decode"^ Рабочий день окончен") then
				chatManager.addMessageToQueue("/clist 7")
				elseif text:match(u8:decode"^ Рабочий день начат") then
				if tostring(lva_ini.values.clist) ~= nil then
					chatManager.addMessageToQueue("/clist " .. tostring(lva_ini.values.clist))
				end
			end
		end
		if lva_ini.bools.fcol then -- окраска ников в чате фракции
			local frank, fnick, fid, ftxt = text:match(u8:decode"^ (.*)  (.*)%[(%d+)%]%: (.*)")
			if fid ~= nil and col == -1920073729 then
				if ftxt:match(u8:decode"[МмMm][ОоOo][НнNn][ИиIi][ТтTtКкKk][ОоOo]?[РрRr]?") then
					waffenlieferungen[10] = true
					cmd_mon()
				end
				
				local color = "{" .. bit.tohex(bit.rshift(col, 8), 6) .. "}"
				local clist = "{" .. ("%06x"):format(bit.band(sampGetPlayerColor(fid), 0xFFFFFF)) .. "}"
				text = " " .. color .. frank .. " " .. clist .. fnick .. "[" .. fid .. "]" .. color .. ": " .. ftxt .. ""
				return {col, text}
			end
		end
		local sqnick, sqtext = text:match(u8:decode"%[.*%] %{FFFFFF%}(.*)%[%d+%]%: (.*)")
		if sqnick ~= nil and sqtext ~= nil and col == -1144065 then
			if sqtext:match(u8:decode"[Мм][Оо][Ии] [Оо][Тт][Мм][Ее]?[Тт]?[Кк]?[Ии]?") then
				local temp = os.tmpname()
				local time = os.time()
				local found = false
				downloadUrlToFile("http://srp-addons.ru/om/fraction/Army%20LV", temp, function(_, status)
					if (status == 58) then
						local file = io.open(temp, "r")
						for line in file:lines() do
							line = encoding.UTF8:decode(line)
							local offrank, offtm, offwm, offdate = line:match('%["' .. sqnick .. '",(%d+),%[(%d+),(%d+)%],"(%d+/%d+/%d+ %d+%:%d+%:%d+)"%]')
							if tonumber(offrank) ~= nil and tonumber(offtm) ~= nil and tonumber(offwm) ~= nil and offdate ~= nil then
								found = true
								chatManager.addMessageToQueue("/fs " .. sqnick .. " > Сегодня: " .. u8(offtm) .. " / За неделю: " .. u8(offwm) .. " часов")
							end
						end
						if not found then chatManager.addMessageToQueue("/fs Отметки " .. sqnick .. " не найдены в базе данных!") end
						file:close()
						os.remove(temp)
						else
						if (os.time() - time > 10) then
							chatManager.addMessageToQueue("/fs Превышено время загрузки файла, повторите попытку")
							return
						end
					end
				end)
			end
			if sqtext:match(u8:decode"[МмMm][ОоOo][НнNn][ИиIi][ТтTtКкKk][ОоOo]?[РрRr]?") then
				waffenlieferungen[6] = true
				cmd_mon()
			end
		end
		if text:match(u8:decode"[Уу]дост") then
			local udnick = text:match("(%a+_%a+)")
			alreadyUd[udnick] = os.time()
		end
		local passorg, passrank = text:match(u8:decode" Организация%: (.*)%s+Должность%: (.*)")
		if passorg ~= nil and passrank ~= nil and col == -169954305 then
			local currentPost
			local x, y, z = getCharCoordinates(PLAYER_PED)
			for i, v in ipairs(posts) do
				if (x >= v[2]) and (y >= v[3]) and (x <= v[4]) and (y <= v[5]) then
					if v[1]:match("КПП") then
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
										if passnick ~= sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) then
											local passid = sampGetPlayerIdByNickname(passnick)
											if passid ~= nil then
												local result, passskin = sampGetPlayerSkin(passid)
												if result then
													if passskin ~= 287 and passskin ~= 191 then
														if passorg:match("Army LV") then
															local passclist = clists.numbers[sampGetPlayerColor(passid)]
															if passclist ~= 7 then chatManager.addMessageToQueue("Наденьте повязку №7") chatManager.addMessageToQueue("/b /clist 7") end
															local res, passHandle = sampGetCharHandleBySampPlayerId(passid)
															if res then
																if isCharInAnyCar(passHandle) then
																	local fcarHandle = storeCarCharIsInNoSave(passHandle)
																	if getDriverOfCar(fcarHandle) == passHandle and (alreadyUd[passnick] == nil or (os.time() - alreadyUd[passnick]) >= 60) then
																		math.randomseed(os.time())
																		local var = math.random(1, 5)
																		local msg = ""
																		if var == 1 then msg = "Покажите"
																			elseif var == 2 then msg = "Предъявите"
																			elseif var == 3 then msg = "А теперь"
																			elseif var == 4 then msg = "Отлично,"
																			elseif var == 5 then msg = "Теперь нужно"
																		end
																		chatManager.addMessageToQueue(msg .. " удостоверение")
																	end
																end
																alreadyUd[passnick] = nil
																postarray[passnick] = passrank
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
							chatManager.addMessageToQueue("Товарищ " .. passrank .. " проезжайте!")
							return
						end
					end
				end
			end
		end
		if waffenlieferungen[3] and text:match(u8:decode"^ Гл%.склад %d+%/%d+$") and col == -65281 then return false end
		local s, sk = text:match(u8:decode"^ На складе (.*)%: (%d+)%/%d+$")
		if s ~= nil and s ~= u8:decode"Army LV" and col == -65281 then
			waffenlieferungen[7] = os.time()
			waffenlieferungen[8] = u8(s)
			waffenlieferungen[9] = math.floor(tonumber(sk)/1000)
		end
		local m = text:match(u8:decode"Материалов: (%d+)/10000")
		if m ~= nil then waffenlieferungen[2] = tonumber(m) wasInTruck = true return end
		if waffenlieferungen[3] then -- /mon
			local re0 = regex.new(u8:decode"(ЛСПД|ЛВПД|СФПД|ФБР|Армии СФ) ([0-9]+)/[0-9]+") --
			local fr, sk = re0:match(text)
			if fr ~= nil then
				local tarr = {["ЛСПД"] = "LSPD", ["ЛВПД"] = "LVPD", ["СФПД"] = "SFPD", ["ФБР"] = "FBI", ["Армии СФ"] = "SFA",}
				waffenlieferungen[4][tarr[u8(fr)]] = math.floor(tonumber(sk)/1000)
				if tarr[u8(fr)] ~= "SFA" then return false end
				if waffenlieferungen[6] then
					chatManager.addMessageToQueue("/fs ЛСПД - " .. waffenlieferungen[4].LSPD .. " | СФПД - " .. waffenlieferungen[4].SFPD .. " | ЛВПД - " .. waffenlieferungen[4].LVPD .. " | ФБР - " .. waffenlieferungen[4].FBI .. " | СФа - " .. waffenlieferungen[4].SFA .. "")
					else
					f("ЛСПД - " .. waffenlieferungen[4].LSPD .. " | СФПД - " .. waffenlieferungen[4].SFPD .. " | ЛВПД - " .. waffenlieferungen[4].LVPD .. " | ФБР - " .. waffenlieferungen[4].FBI .. " | СФа - " .. waffenlieferungen[4].SFA .. "")
				end
				waffenlieferungen[3] = false
				waffenlieferungen[6] = false
				waffenlieferungen[10] = false
				return false
			end
		end
	end
end

function ev.onShowTextDraw(id, data)
	if data.text == "kmh" then
		fuelTextDraw = id + 2
	end
	if data.text:match("FUEL ~w~(%d+)") ~= nil then
		fuelTextDraw = id
	end
	if id == fuelTextDraw then
		local f = data.text:match("(%d+)")
		if f ~= nil then
			currentFuel = f
		end
	end
end

function ev.onTextDrawSetString(id, text)
	if id == fuelTextDraw then           
		local f = text:match("(%d+)")
		if f ~= nil then
			currentFuel = f
		end
	end
end

function ev.onShowDialog(dialogid, style, title, button1, button2, text)
	if script.loaded then
		if lva_ini.bools.bp and dialogid == 245 and title == u8:decode"Склад оружия" then
			istakesomeone = false
			
			local deagle = getAmmoInCharWeapon(PLAYER_PED, 24) -- deagle
			if deagle <= 61 then sampSendDialogResponse(dialogid, 1, 0, "") istakesomeone = true return false end
			
			local shotgun = getAmmoInCharWeapon(PLAYER_PED, 25) -- shotgun
			if shotgun <= 28 then sampSendDialogResponse(dialogid, 1, 1, "") istakesomeone = true return false end
			
			-- local smg = getAmmoInCharWeapon(PLAYER_PED, 29) -- smg
			-- if smg <= 178 then sampSendDialogResponse(dialogid, 1, 2, "") istakesomeone = true return false end
			
			local m4a1 = getAmmoInCharWeapon(PLAYER_PED, 31) -- m4a1
			if m4a1 <= 290 then sampSendDialogResponse(dialogid, 1, 3, "") istakesomeone = true return false end
			
			local rifle = getAmmoInCharWeapon(PLAYER_PED, 33) -- rifle
			if rifle <= 28 then sampSendDialogResponse(dialogid, 1, 4, "") istakesomeone = true return false end
			
			if os.time() > partimer then
				local par = getAmmoInCharWeapon(PLAYER_PED, 46) -- parachute
				if par ~= 1 then sampSendDialogResponse(dialogid, 1, 6, "") istakesomeone = true partimer = os.time() + 60 return false end
			end
			
			if not isarmtaken then sampSendDialogResponse(dialogid, 1, 5, "") istakesomeone = true isarmtaken = true return false end -- armour
			
			if not istakesomeone then
				sampSendDialogResponse(dialogid, 0, 5, "")
				sampCloseCurrentDialogWithButton(0)
				isarmtaken, istakesomeone = false, false
				if lva_ini.bools.tp then
					local mindist = 9999
					for i = 0, 4096 do
						local handle = sampGetPickupHandleBySampId(i) 
						if doesPickupExist(handle) then
							local mx, my, mz = getCharCoordinates(PLAYER_PED)
							local x, y, z = getPickupCoordinates(handle)
							local dist = getDistanceBetweenCoords3d(mx, my, mz, x, y, z)
							if (dist > 1.0 and dist < 4.0) then
								sampSendPickedUpPickup(i)
							end
						end
					end
					return false
				end
			end
		end
		if lva_ini.bools.elevator then
			if dialogid == 288 and text:match(u8:decode"1 Этаж: Холл") then
				local a_index = 0
				local myX, myY, myZ = getCharCoordinates(PLAYER_PED) -- получаем свои координаты
				
				for i, v in ipairs(getAllPickups()) do -- определяем количество меток вокруг
					local cX, cY, cZ = getPickupCoordinates(v)
					local distance = math.ceil(math.sqrt( ((myX-cX)^2) + ((myY-cY)^2) + ((myZ-cZ)^2)))
					if distance <= 50 then a_index = a_index + 1 end
				end
				
				if a_index == 5 then -- 1 этаж
					if not isKeyDown(vkeys.VK_MENU) then
						sampSendDialogResponse(dialogid, 1, 1, "")
						else
						sampSendDialogResponse(dialogid, 1, 2, "")
					end
					sampCloseCurrentDialogWithButton(0)
					return false
					elseif a_index == 2 then -- 2 этаж
					if not isKeyDown(vkeys.VK_MENU) then
						sampSendDialogResponse(dialogid, 1, 0, "")
						else
						sampSendDialogResponse(dialogid, 1, 2, "")
					end
					sampCloseCurrentDialogWithButton(0)
					return false
					elseif a_index == 1 then -- 3 этаж
					sampSendDialogResponse(dialogid, 1, 0, "")
					sampCloseCurrentDialogWithButton(0)
					return false
				end		
			end
			if dialogid == 184 and style == 0 and title == u8:decode"Раздевалка" and button1 == u8:decode"Да" and button2 == u8:decode"Нет" and text == u8:decode"Вы хотите начать рабочий день?" then sampSendDialogResponse(dialogid, 1, 0, "") sampCloseCurrentDialogWithButton(0) return false end
			if dialogid == 185 and style == 2 and title == u8:decode"Раздевалка" and button1 == u8:decode"Далее" and button2 == u8:decode"Отмена" and text:match(u8:decode"Завершить рабочий день") then local result, sid = sampGetPlayerSkin(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) local k = (sid == 252 or sid == 140) and 1 or 0 sampSendDialogResponse(dialogid, 1, k, "") sampCloseCurrentDialogWithButton(0) return false end
		end
		if dialogid == 42 and style == 2 and title == u8:decode"Развозка материалов" and button1 == u8:decode"Выбрать" and button2 == u8:decode"Выйти" and (waffenlieferungen[1] or waffenlieferungen[5][1]) then
			waffenlieferungen[5][1] = false
			if waffenlieferungen[1] then sampCloseCurrentDialogWithButton(0) waffenlieferungen[1] = false return false end
			if waffenlieferungen[3] then sampSendDialogResponse(42, 1, 7) waffenlieferungen[1] = true return false end
			if lva_ini.bools.mat then
				local LVax, LVay, SFPDx, SFPDy, LVPDx, LVPDy, LSPDx, LSPDy, FBIx, FBIy, SFax, SFay = 328, 1945, -1605, 680, 2230, 2470, 1530, -1683, -2420, 500, -1300, 475
				local CoordX, CoordY = getCharCoordinates(PLAYER_PED)
				local tarr = {[1] = ((LVax - CoordX)^2+(LVay-CoordY)^2)^0.5, [2] = ((LSPDx - CoordX)^2+(LSPDy-CoordY)^2)^0.5, [3] = ((SFPDx - CoordX)^2+(SFPDy-CoordY)^2)^0.5, [4] = ((LVPDx - CoordX)^2+(LVPDy-CoordY)^2)^0.5, [5] = ((FBIx - CoordX)^2+(FBIy-CoordY)^2)^0.5, [6] = ((SFax - CoordX)^2+(SFay-CoordY)^2)^0.5}
				local FractionBase = indexof(math.min(tarr[1], tarr[2], tarr[3], tarr[4], tarr[5], tarr[6]), tarr)
				local i = FractionBase ~= 1 and FractionBase or waffenlieferungen[2] ~= 10000 and 0 or 1
				sampSendDialogResponse(dialogid, 1, i, "")
				return false
			end
		end
	end
end

function f_matovoz()
	while true do
		wait(0)
		if isCharInAnyCar(PLAYER_PED) then
			if lva_ini.bools.mat and getCarModel(storeCarCharIsInNoSave(PLAYER_PED)) == 433 then
				if not waffenlieferungen[5][2] then
					for k, v in ipairs(waffenlieferungen[5][3]) do
						wait(0)
						if isCharInArea2d(PLAYER_PED, v.x1, v.y1, v.x2, v.y2, false) then
							if k == 1 then if waffenlieferungen[2] ~= 10000 then script.sendMessage("Грузовик будет загружен") else script.sendMessage("Грузовик будет РАЗГРУЖЕН") end end
							if waffenlieferungen[2] == 0 and k ~= 1 then 
								script.sendMessage("/carm не будет введён, так как грузовик пустой")
								waffenlieferungen[5][4] = v
								waffenlieferungen[5][2] = true
								break		
							end
							chatManager.addMessageToQueue("/carm")
							waffenlieferungen[5][1] = true
							waffenlieferungen[5][4] = v
							waffenlieferungen[5][2] = true
							break								
						end
					end
					else
					while isCharInArea2d(PLAYER_PED, waffenlieferungen[5][4].x1, waffenlieferungen[5][4].y1, waffenlieferungen[5][4].x2, waffenlieferungen[5][4].y2, false) do wait(0) end
					waffenlieferungen[5][2] = false
					waffenlieferungen[5][4] = {}
				end
			end
		end
	end
end

function ev.onSendPickedUpPickup(id)
	currentPickup = id
end

function ev.onSendDeathNotification(reason, id)
	if lva_ini.bools.autocl then 
		local result, sid = sampGetPlayerSkin(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
		if sid == 287 or sid == 191 then
			if tostring(lva_ini.values.clist) ~= nil then
				lua_thread.create(function()
					repeat wait(0) until getActiveInterior() ~= 0
					chatManager.addMessageToQueue("/clist " .. tostring(lva_ini.values.clist))
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
function cmd_vzyal()
	local car = isCharInAnyCar(PLAYER_PED) and storeCarCharIsInNoSave(PLAYER_PED) or -1
	local idc = car ~= -1 and getCarModel(car) or -1
	local x, y, z = getCharCoordinates(PLAYER_PED)
	if idc == 433 then	
		if getDriverOfCar(car) == PLAYER_PED then
			if x >= 266 and x <= 287 and y >= 1940 and y <= 2004 and z > 16 and z < 30 then
				f("Взял" .. a .. " грузовик, литраж " .. currentFuel .. ", загружаюсь на ГС")
			end
			else
			script.sendMessage("Вы не водитель грузовика")
		end
		else
		script.sendMessage("Необходимо быть в грузовике")
	end
end

function cmd_vern()
	if wasInTruck then
		f("Вернул" .. a .. " грузовик в ангар, литраж " .. currentFuel)
		wasInTruck = false
		else
		script.sendMessage("Доклад уже был сделан или литраж грузовика не получен")
	end
end

function cmd_razg()
	if waffenlieferungen[7] ~= 0 then
		f("Разгрузились на складе " .. waffenlieferungen[8] .. ", " .. waffenlieferungen[9] .. " тонн.")
		waffenlieferungen[7] = 0
		else
		script.sendMessage("Нет информация про разгрузку")
	end
end

function setclist()
	lua_thread.create(function()
		local res, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		if not res then script.sendMessage("Не удалось узнать свой ID") return end
		local myclist = clists.numbers[sampGetPlayerColor(myid)]
		if myclist == nil then script.sendMessage("Не удалось узнать номер своего цвета") return end
		if myclist == 0 then
			if tonumber(lva_ini.values.clist) == 0 then script.sendMessage("На вас уже нету клиста!") return end
			chatManager.addMessageToQueue("/clist " .. lva_ini.values.clist .. "")
			wait(1300)
			local newmyclist = clists.numbers[sampGetPlayerColor(myid)]
			if newmyclist == nil then script.sendMessage("Не удалось узнать номер своего цвета") return end
			if newmyclist ~= tonumber(lva_ini.values.clist) then script.sendMessage("Клист не был надет") return end
			else
			chatManager.addMessageToQueue("/clist 0")
			wait(1300)
			local newmyclist = clists.numbers[sampGetPlayerColor(myid)]
			if newmyclist == nil then script.sendMessage("Не удалось узнать номер своего цвета") return end
			if newmyclist ~= 0 then script.sendMessage("Клист не был снят") return end
		end
	end)
end

function hello()
	lua_thread.create(function()
		wait(0)
		local A_Index = 0
		while true do
			if A_Index == 30 then break end
			local str = sampGetChatString(99 - A_Index)
			local re1 = regex.new(u8:decode" \\{.*\\}(.*) \\{.*\\}(.*)\\_(.*)\\[(.*)\\]\\{.*\\}:  (.*)((.*)дравия(.*)аза|(.*)дравия(.*)елаю(.*)аза|(.*)дравия(.*)варищи(.*)|(.*)дравия(.*)елаю(.*)варищи(.*)|(.*)дравия(.*)елаю(.*)рмия(.*)|(.*)дравия(.*)рмия(.*)|(.*)дравия(.*)елаю(.*)сть(.*)|(.*)дравия(.*)сть(.*))")
			local re2 = regex.new(u8:decode" (.*)  (.*)\\_(.*)\\[(.*)\\]:  (.*)((.*)дравия(.*)аза|(.*)дравия(.*)елаю(.*)аза|(.*)дравия(.*)варищи(.*)|(.*)дравия(.*)елаю(.*)варищи(.*)|(.*)дравия(.*)елаю(.*)рмия(.*)|(.*)дравия(.*)рмия(.*)|(.*)дравия(.*)елаю(.*)сть(.*)|(.*)дравия(.*)сть(.*))")
			local zvanie, _, surname
			
			if lva_ini.bools.fcol then
				zvanie, _, surname = re1:match(str)
				else
				zvanie, _, surname = re2:match(str)
			end
			
			if zvanie ~= nil then
				local ranksnesokr = {["Ст.сержант"] = "Старший сержант", ["Мл.сержант"] = "Младший сержант", ["Ст.Лейтенант"] = "Старший лейтенант", ["Мл.Лейтенант"] = "Младший лейтенант"}
				local pRank = ranksnesokr[u8(zvanie)] ~= nil and ranksnesokr[u8(zvanie)] or u8(zvanie)
				f("Здравия желаю, товарищ " .. pRank .. " " .. surname .. "!")
				return
			end
			A_Index = A_Index + 1
		end
		
		script.sendMessage("Никто не здоровался в рацию!")
	end)
end

function sos()
	local x, y, z = getCharCoordinates(PLAYER_PED)
	local zone = calculateNamedZone(x, y)
	if zone ~= nil then
		f("SОS " .. zone .. "")
		return
	end
	
	local kv = kvadrat()
	if kv ~= nil then chatManager.addMessageToQueue("/" .. (needtocl7 and "u" or "f") .. " " .. u8(tag) .. "SОS " .. kv .. "") end
end

function cmd_zas(s)
	if tonumber(s) == nil then script.sendMessage("Ошибка! Введите /zas [кол-во состава]") return end
	s = tonumber(s)
	local k = {
		[1] = 'Один боец', 
		[2] = 'Два бойца', 
		[3] = 'Три бойца', 
		[4] = 'Четыре бойца', 
		[5] = 'Пять бойцов', 
		[6] = 'Шесть бойцов', 
		[7] = 'Семеро бойцов', 
		[8] = 'Восьмеро бойцов', 
		[9] = 'Девять бойцов', 
		[10] = 'Десять бойцов'
	}
	local x, y, z = getCharCoordinates(PLAYER_PED)
	local currentPost
	for i, v in ipairs(posts) do
		if (x >= v[2]) and (y >= v[3]) and (x <= v[4]) and (y <= v[5]) then
			currentPost = v[1]
		end
	end
	if currentPost == nil then script.sendMessage("Вы не на одном из постов!") return end
	f("Заступил на пост: " .. currentPost .. " | Состав: " .. (k[s] ~= nil and k[s] or s))
end

function cmd_pok(s)
	local p = {}
	for v in string.gmatch(s, "[^%s]+") do table.insert(p, v) end
	if tonumber(p[1]) == nil or p[2] == nil then script.sendMessage("Ошибка! Введите /pok [кол-во состава] [причина]") return end
	p[1] = tonumber(p[1])
	local reason = u8:decode""
	for i, j in ipairs(p) do
		if i >= 2 then
			reason = reason ~= "" and reason .. u8:decode" " .. j or j
		end
	end
	local k = {
		[1] = 'Один боец', 
		[2] = 'Два бойца', 
		[3] = 'Три бойца', 
		[4] = 'Четыре бойца', 
		[5] = 'Пять бойцов', 
		[6] = 'Шесть бойцов', 
		[7] = 'Семеро бойцов', 
		[8] = 'Восьмеро бойцов', 
		[9] = 'Девять бойцов', 
		[10] = 'Десять бойцов'
	}
	if lastPost == nil then script.sendMessage("Последний пост не найден!") return end
	f("Покинул пост: " .. lastPost .. " | Состав: " .. (k[p[1]] ~= nil and k[p[1]] or p[1]) .. " | Причина: " .. u8(reason))
end

function cmd_prib(sid)
	if tonumber(sid) ~= nil then
		local id = sid
		local nick = sampGetPlayerNickname(id)
		if postarray[nick] ~= nil then
			local rank = postarray[nick]
			local surname = nick:match(".*%_(.*)")
			f("В часть прибыл " .. rank .. " " .. surname)
			chatManager.addMessageToQueue("Товарищ " .. rank .. " " .. surname .. " можете двигатся далее!")
			postarray[nick] = nil
			else
			script.sendMessage("Игрок, показавший вам паспорт, не обнаружен!")
		end
		else
		script.sendMessage("Ошибка! Пропишите /prib [ID]")
	end
end

function cmd_viezd(s)
	lua_thread.create(function()
		if s == "" then script.sendMessage("Ошибка! Введите /viezd [число грузовиков] [пункт назначения]") return end
		local p = {}
		for v in string.gmatch(s, "[^%s]+") do table.insert(p, v) end
		local k = {[1] = "одного грузовика", [2] = "двух грузовиков", [3] = "трёх грузовиков", [4] = "четырёх грузовиков", [5] = "пяти грузовиков", [6] = "шести грузовиков", [7] = "семи грузовиков"}
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
		f("Колонна в составе " .. k[kol] .. " выехала в " .. arr[u8(p[2])] .. "")
		wait(600)
		f("Сетка, открывай! Выезжает ВМО")
	end)
end

function cmd_port()
	local AllChars = getAllChars()
	local Data = {}
	local carhandle
	if isCharInAnyCar(PLAYER_PED) then
		carhandle = storeCarCharIsInNoSave(PLAYER_PED)
		for _, v in ipairs(AllChars) do
			if v ~= PLAYER_PED then
				if isCharInAnyCar(v) then
					local carhandle2 = storeCarCharIsInNoSave(v)
					if carhandle==carhandle2 then
						local result, id = sampGetPlayerIdByCharHandle(v)			
						if result then
							local result2, sid = sampGetPlayerSkin(id)
							if result2 then
								if sid == 287 or sid == 191 then
									table.insert(Data, tostring(sampGetPlayerNickname(id):gsub('(.*_)', '')))
									nickincar = table.concat(Data, ", ")
								end
							end
						end
					end
				end
			end
		end
		if nickincar ~= nil then 
			f("Выехали в порт LS. Напарники: " .. nickincar)
			else
			f("Выехал в порт LS")
		end
		nickincar = nil 
		else 
		script.sendMessage("Вы не в транспорте")
	end
end

function cmd_mon()
	if not isCharInAnyCar(PLAYER_PED) then if not waffenlieferungen[6] or not waffenlieferungen[10] then script.sendMessage("Необходимо быть в грузовике") else waffenlieferungen[6] = false waffenlieferungen[10] = false end return end
	local idc = getCarModel(storeCarCharIsInNoSave(PLAYER_PED))
	if idc ~= 433 then if not waffenlieferungen[6] or not waffenlieferungen[10] then script.sendMessage("Необходимо быть в грузовике") else waffenlieferungen[6] = false waffenlieferungen[10] = false end return end
	
	waffenlieferungen[3] = true
	waffenlieferungen[5][1] = true
	chatManager.addMessageToQueue("/carm")
end

textlabel = {}
function textLabelOverPlayerNickname()
	for i = 0, 1000 do
		if textlabel[i] ~= nil then
			sampDestroy3dText(textlabel[i])
			textlabel[i] = nil
		end
	end
	for i = 0, 1000 do 
		if sampIsPlayerConnected(i) and sampGetPlayerScore(i) ~= 0 then
			local nick = sampGetPlayerNickname(i)
			if script.label[nick] ~= nil then
				if textlabel[i] == nil then
					textlabel[i] = sampCreate3dText(u8:decode(script.label[nick].text), tonumber(script.label[nick].color), 0.0, 0.0, 0.8, 21.5, false, i, -1)
				end
			end
			else
			if textlabel[i] ~= nil then
				sampDestroy3dText(textlabel[i])
				textlabel[i] = nil
			end
		end
	end
end

function script.sendMessage(t)
	sampAddChatMessage(prefix .. u8:decode(t), main_color)
end

function makeHotKey(numkey)
	local rett = {}
	for _, v in ipairs(string.split(lva_ini.hotkey[numkey], ", ")) do
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
	for _, v in ipairs(string.split(lva_ini.hotkey[numkey], ", ")) do
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
					lva_ini.hotkey[numkey] = "0"
					else
					local tNames = string.split(curkeys, " ")
					for _, v in ipairs(tNames) do
						local val = (tonumber(v) == 162 or tonumber(v) == 163) and 17 or (tonumber(v) == 160 or tonumber(v) == 161) and 16 or (tonumber(v) == 164 or tonumber(v) == 165) and 18 or tonumber(v)
						keys = keys == "" and val or "" .. keys .. ", " .. val .. ""
					end
				end
				
				lva_ini.hotkey[numkey] = keys
				inicfg.save(lva_ini, settings)
			end
		)
	end
end

function indexof(var, arr)
	for k, v in ipairs(arr) do if v == var then return k end end return false
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

function getAllPickups() -- https://www.blast.hk/threads/13380/page-8#post-361600
	local pu = {}
	pPu = sampGetPickupPoolPtr() + 16388
	for i = 0, 4095 do
		local id = readMemory(pPu + 4 * i, 4)
		if id ~= -1 then
			table.insert(pu, sampGetPickupHandleBySampId(i))
		end
	end
	return pu
end

function checkUpdates() -- проверка обновлений
	local fpath = getWorkingDirectory() .. '/LVA.dat'
	downloadUrlToFile("https://raw.githubusercontent.com/WebbLua/LVA/main/version.json", fpath, function(_, status, _, _)
		if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			if doesFileExist(fpath) then
				local file = io.open(fpath, 'r')
				if file then
					local info = decodeJson(file:read('*a'))
					file:close()
					os.remove(fpath)
					script.v.num = info.version_num
					script.v.date = info.version_date
					script.url = info.version_url
					script.access = info.version_access
					if script.access ~= {} then
						if script.access[currentNick] ~= nil then
							if not script.access[currentNick] then
								os.remove("Moonloader\\LVA.lua")
								script.sendMessage("Вы в blacklist'e, скрипт удалён")
								script.noaccess = true
								thisScript():unload()
								return
							end
							else
							script.sendMessage("Нет доступа")
							script.noaccess = true
							thisScript():unload()
							return
						end
						else
						script.sendMessage("Произошла ошибка, попробуйте позже")
						thisScript():unload()
						return
					end
					script.label = info.version_label
					script.upd.changes = info.version_upd
					if script.upd.changes then
						for k in pairs(script.upd.changes) do
							table.insert(script.upd.sort, k)
						end
						table.sort(script.upd.sort, function(a, b) return a > b end)
					end
					script.checked = true
					if info['version_num'] > thisScript()['version_num'] then
						script.available = true
						if script.update then updateScript() return end
						script.sendMessage(updatingprefix .. "Обнаружена новая версия скрипта от " .. info['version_date'] .. ", пропишите /armyup для обновления")
						script.sendMessage(updatingprefix .. "Изменения в новой версии:")
						if script.upd.sort ~= {} then
							for k in ipairs(script.upd.sort) do
								if script.upd.changes[tostring(k)] ~= nil then
									script.sendMessage(updatingprefix .. k .. ') ' .. script.upd.changes[tostring(k)])
								end
							end
						end
						return true
						else
						if script.update then script.sendMessage("Обновлений не обнаружено, вы используете самую актуальную версию: v" .. script.v.num .. " за " .. script.v.date) script.update = false return end
					end
					else
					script.sendMessage("Не удалось получить информацию про обновления(")
					thisScript():unload()
				end
				else
				script.sendMessage("Не удалось получить информацию про обновления(")
				thisScript():unload()
			end
		end
	end)
end

function updateScript()
	script.update = true
	if script.available then
		downloadUrlToFile(script.url, thisScript().path, function(_, status, _, _)
			if status == 6 then
				script.sendMessage(updatingprefix .. "Скрипт был обновлён!")
				if script.find("ML-AutoReboot") == nil then
					thisScript():reload()
				end
			end
		end)
		else
		checkUpdates()
	end
end

function onScriptTerminate(s, bool)
	if s == thisScript() and not bool then
		imgui.Process = false
		for i = 0, 1000 do
			if textlabel[i] ~= nil then
				sampDestroy3dText(textlabel[i])
				textlabel[i] = nil
			end
		end
		if not script.noaccess then
			if not script.reload then
				if not script.update then
					if not script.unload then
						script.sendMessage("Скрипт крашнулся: отправьте moonloader.log разработчику tg: @Imykhailovich")
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







