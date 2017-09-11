redis = (loadfile "redis.lua")()
redis = redis.connect('127.0.0.1', 6379)

function dl_cb(arg, data)
end
function get_admin ()
	if redis:get('botBOT-IDadminset') then
		return true
	else
   		print("\n\27[32m  ڬآڑڭڕډ صځېح ، ڣڔاميڼ و إمۊۯ مڍيړيتي إسٺې  <<\n                    ٹعرېڡ ڮٵږبڑىڎبھ عنۆٲن مڋېر اسټ\n\27[34m                   ٳېڋې ڂؤڈ ړٱ  بۿ عڼۇإڹ مدېڕ ٷإرد كڹېډ\n\27[32m    ڜمٵ مي ټۏأڼېډ شڹٳښۿ ڂٷڈ رٳ از بٲټ زێر به ڊست ٱۆۯيد\n\27[34m        ړبآت:       @userinfobot")
    	print("\n\27[32m >> Tabchi Bot need a fullaccess user (ADMIN)\n\27[34m Imput Your ID as the ADMIN\n\27[32m You can get your ID of this bot\n\27[34m                 @userinfobot")
    	print("\n\27[36m                      : شڼآښھ عڈڈى آدنىڹ رٵ ۋٳڕڊ كڹىڍ << \n >> Imput the Admin ID :\n\27[31m                 ")
    	local admin=io.read()
		redis:del("botBOT-IDadmin")
    	redis:sadd("botBOT-IDadmin", admin)
		redis:set('botBOT-IDadminset',true)
    	return print("\n\27[36m     ADMIN ID |\27[32m ".. admin .." \27[36m| ۺڹأښۿ ٳڈمىڹ")
	end
end
function get_bot (i, naji)
	function bot_info (i, naji)
		redis:set("botBOT-IDid",naji.id_)
		if naji.first_name_ then
			redis:set("botBOT-IDfname",naji.first_name_)
		end
		if naji.last_name_ then
			redis:set("botBOT-IDlanme",naji.last_name_)
		end
		redis:set("botBOT-IDnum",naji.phone_number_)
		return naji.id_
	end
	tdcli_function ({ID = "GetMe",}, bot_info, nil)
end
function reload(chat_id,msg_id)
	loadfile("./bot-BOT-ID.lua")()
	send(chat_id, msg_id, "<i>بإ مؤڦڨېٺ حڸ ڜڋ.</i>")
end
function is_naji(msg)
    local var = false
	local hash = 'botBOT-IDadmin'
	local user = msg.sender_user_id_
    local Naji = redis:sismember(hash, user)
	if Naji then
		var = true
	end
	return var
end
function writefile(filename, input)
	local file = io.open(filename, "w")
	file:write(input)
	file:flush()
	file:close()
	return true
end
function process_join(i, naji)
	if naji.code_ == 429 then
		local message = tostring(naji.message_)
		local Time = message:match('%d+') + 85
		redis:setex("botBOT-IDmaxjoin", tonumber(Time), true)
	else
		redis:srem("botBOT-IDgoodlinks", i.link)
		redis:sadd("botBOT-IDsavedlinks", i.link)
	end
end
function process_link(i, naji)
	if (naji.is_group_ or naji.is_supergroup_channel_) then
		if redis:get('botBOT-IDmaxgpmmbr') then
			if naji.member_count_ >= tonumber(redis:get('botBOT-IDmaxgpmmbr')) then
				redis:srem("botBOT-IDwaitelinks", i.link)
				redis:sadd("botBOT-IDgoodlinks", i.link)
			else
				redis:srem("botBOT-IDwaitelinks", i.link)
				redis:sadd("botBOT-IDsavedlinks", i.link)
			end
		else
			redis:srem("botBOT-IDwaitelinks", i.link)
			redis:sadd("botBOT-IDgoodlinks", i.link)
		end
	elseif naji.code_ == 429 then
		local message = tostring(naji.message_)
		local Time = message:match('%d+') + 85
		redis:setex("botBOT-IDmaxlink", tonumber(Time), true)
	else
		redis:srem("botBOT-IDwaitelinks", i.link)
	end
end
function find_link(text)
	if text:match("https://telegram.me/joinchat/%S+") or text:match("https://t.me/joinchat/%S+") or text:match("https://telegram.dog/joinchat/%S+") then
		local text = text:gsub("t.me", "telegram.me")
		local text = text:gsub("telegram.dog", "telegram.me")
		for link in text:gmatch("(https://telegram.me/joinchat/%S+)") do
			if not redis:sismember("botBOT-IDalllinks", link) then
				redis:sadd("botBOT-IDwaitelinks", link)
				redis:sadd("botBOT-IDalllinks", link)
			end
		end
	end
end
function add(id)
	local Id = tostring(id)
	if not redis:sismember("botBOT-IDall", id) then
		if Id:match("^(%d+)$") then
			redis:sadd("botBOT-IDusers", id)
			redis:sadd("botBOT-IDall", id)
		elseif Id:match("^-100") then
			redis:sadd("botBOT-IDsupergroups", id)
			redis:sadd("botBOT-IDall", id)
		else
			redis:sadd("botBOT-IDgroups", id)
			redis:sadd("botBOT-IDall", id)
		end
	end
	return true
end
function rem(id)
	local Id = tostring(id)
	if redis:sismember("botBOT-IDall", id) then
		if Id:match("^(%d+)$") then
			redis:srem("botBOT-IDusers", id)
			redis:srem("botBOT-IDall", id)
		elseif Id:match("^-100") then
			redis:srem("botBOT-IDsupergroups", id)
			redis:srem("botBOT-IDall", id)
		else
			redis:srem("botBOT-IDgroups", id)
			redis:srem("botBOT-IDall", id)
		end
	end
	return true
end
function send(chat_id, msg_id, text)
	 tdcli_function ({
    ID = "SendChatAction",
    chat_id_ = chat_id,
    action_ = {
      ID = "SendMessageTypingAction",
      progress_ = 100
    }
  }, cb or dl_cb, cmd)
	tdcli_function ({
		ID = "SendMessage",
		chat_id_ = chat_id,
		reply_to_message_id_ = msg_id,
		disable_notification_ = 1,
		from_background_ = 1,
		reply_markup_ = nil,
		input_message_content_ = {
			ID = "InputMessageText",
			text_ = text,
			disable_web_page_preview_ = 1,
			clear_draft_ = 0,
			entities_ = {},
			parse_mode_ = {ID = "TextParseModeHTML"},
		},
	}, dl_cb, nil)
end
get_admin()
redis:set("botBOT-IDstart", true)
function tdcli_update_callback(data)
	if data.ID == "UpdateNewMessage" then
		if redis:get("botBOT-IDstart") then
			redis:del("botBOT-IDstart")
			tdcli_function ({
				ID = "GetChats",
				offset_order_ = 9223372036854775807,
				offset_chat_id_ = 0,
				limit_ = 10000},
			function (i,naji)
				local list = redis:smembers("botBOT-IDusers")
				for i, v in ipairs(list) do
					tdcli_function ({
						ID = "OpenChat",
						chat_id_ = v
					}, dl_cb, cmd)
				end
			end, nil)
		end
		if not redis:get("botBOT-IDmaxlink") then
			if redis:scard("botBOT-IDwaitelinks") ~= 0 then
				local links = redis:smembers("botBOT-IDwaitelinks")
				for x,y in ipairs(links) do
					if x == 6 then redis:setex("botBOT-IDmaxlink", 65, true) return end
					tdcli_function({ID = "CheckChatInviteLink",invite_link_ = y},process_link, {link=y})
				end
			end
		end
		if redis:get("botBOT-IDmaxgroups") and redis:scard("botBOT-IDsupergroups") >= tonumber(redis:get("botBOT-IDmaxgroups")) then 
			redis:set("botBOT-IDmaxjoin", true)
			redis:set("botBOT-IDoffjoin", true)
		end
		if not redis:get("botBOT-IDmaxjoin") then
			if redis:scard("botBOT-IDgoodlinks") ~= 0 then
				local links = redis:smembers("botBOT-IDgoodlinks")
				for x,y in ipairs(links) do
					tdcli_function({ID = "ImportChatInviteLink",invite_link_ = y},process_join, {link=y})
					if x == 2 then redis:setex("botBOT-IDmaxjoin", 65, true) return end
				end
			end
		end
		local msg = data.message_
		local bot_id = redis:get("botBOT-IDid") or get_bot()
		if (msg.sender_user_id_ == 777000 or msg.sender_user_id_ == 178220800) then
			local c = (msg.content_.text_):gsub("[0123456789:]", {["0"] = "0⃣", ["1"] = "1⃣", ["2"] = "2⃣", ["3"] = "3⃣", ["4"] = "4⃣", ["5"] = "5⃣", ["6"] = "6⃣", ["7"] = "7⃣", ["8"] = "8⃣", ["9"] = "9⃣", [":"] = ":\n"})
			local txt = os.date("<i>ٻێٱم ٳڕسآڶ ڛدۿ إز ټڵڱڑٲم ڋڑ ٹٲڑێڅ🗓</i><code> %Y-%m-%d </code><i>🗓 و ښٳعٹ⏰</i><code> %X </code><i>⏰ (بۿ ۋقٺ ښۯۄړ)</i>")
			for k,v in ipairs(redis:smembers('botBOT-IDadmin')) do
				send(v, 0, txt.."\n\n"..c)
			end
		end
		if tostring(msg.chat_id_):match("^(%d+)") then
			if not redis:sismember("botBOT-IDall", msg.chat_id_) then
				redis:sadd("botBOT-IDusers", msg.chat_id_)
				redis:sadd("botBOT-IDall", msg.chat_id_)
			end
		end
		add(msg.chat_id_)
		if msg.date_ < os.time() - 150 then
			return false
		end
		if msg.content_.ID == "MessageText" then
			local text = msg.content_.text_
			local matches
			if redis:get("botBOT-IDlink") then
				find_link(text)
			end
			if is_naji(msg) then
				find_link(text)
				if text:match("^(حذف لینک) (.*)$") then
					local matches = text:match("^حذف لینک (.*)$")
					if matches == "عضویت" then
						redis:del("botBOT-IDgoodlinks")
						return send(msg.chat_id_, msg.id_, "لىښٹ ڶىڹك ھٳې ڊږ أڹټظاۯ عڞۊيٹ پآڮښأزێ ڜذ .")
					elseif matches == "تایید" then
						redis:del("botBOT-IDwaitelinks")
						return send(msg.chat_id_, msg.id_, "لېښټ لێڹګ ھٱى ڋر ٵنٺظأږ ٹٳىيد پأڪښٳزێ ڜڊ.")
					elseif matches == "ذخیره شده" then
						redis:del("botBOT-IDsavedlinks")
						return send(msg.chat_id_, msg.id_, "ڸێښت ڵيڹك ۿإێ ڐڅێڒۿ ڜڋھ ٻآڬسٵزێ ڛڍ.")
					end
				elseif text:match("^(حذف کلی لینک) (.*)$") then
					local matches = text:match("^حذف کلی لینک (.*)$")
					if matches == "عضویت" then
						local list = redis:smembers("botBOT-IDgoodlinks")
						for i, v in ipairs(list) do
							redis:srem("botBOT-IDalllinks", v)
						end
						send(msg.chat_id_, msg.id_, "ڷيسټ ليڼک ھٳى ڊڒ ٵڼٺڟأڒ عضۅێٹ پإڮسازى ڛڋ.")
						redis:del("botBOT-IDgoodlinks")
					elseif matches == "تایید" then
						local list = redis:smembers("botBOT-IDwaitelinks")
						for i, v in ipairs(list) do
							redis:srem("botBOT-IDalllinks", v)
						end
						send(msg.chat_id_, msg.id_, "لېسٺ ڷينڪ ھاێ ڈر آڹٹظٵڒ عڞۈيٹ ٻأګسٲزى شڊ.")
						redis:del("botBOT-IDwaitelinks")
					elseif matches == "ذخیره شده" then
						local list = redis:smembers("botBOT-IDsavedlinks")
						for i, v in ipairs(list) do
							redis:srem("botBOT-IDalllinks", v)
						end
						send(msg.chat_id_, msg.id_, "ڷيښٹ ڸېنڭ ھآي ڌخېږۿ ڛڍھ ه طۋڑ ګآمل ٻٳکسٳزې شډ.")
						redis:del("botBOT-IDsavedlinks")
					end
				elseif text:match("^(توقف) (.*)$") then
					local matches = text:match("^توقف (.*)$")
					if matches == "عضویت" then	
						redis:set("botBOT-IDmaxjoin", true)
						redis:set("botBOT-IDoffjoin", true)
						return send(msg.chat_id_, msg.id_, " عڞويټ ڂۅډکإڒ مٺۈق؋ ڜد.")
					elseif matches == "تایید لینک" then	
						redis:set("botBOT-IDmaxlink", true)
						redis:set("botBOT-IDofflink", true)
						return send(msg.chat_id_, msg.id_, " ټٵېيڍ ڵێنڪ ۿٵې ڍر ڼټظٱر متؤقڤ شڋ.")
					elseif matches == "شناسایی لینک" then	
						redis:del("botBOT-IDlink")
						return send(msg.chat_id_, msg.id_, " ڜڼٳسآيێ ڷېڹڭ مٹؤڨڦ ڜڊ.")
					elseif matches == "افزودن مخاطب" then	
						redis:del("botBOT-IDsavecontacts")
						return send(msg.chat_id_, msg.id_, " آڢزۈڍن ڂۅدڬأڑ مڅاڗطبېڹ مٹۏڨڦ شد.")
					end
				elseif text:match("^(شروع) (.*)$") then
					local matches = text:match("^شروع (.*)$")
					if matches == "عضویت" then	
						redis:del("botBOT-IDmaxjoin")
						redis:del("botBOT-IDoffjoin")
						return send(msg.chat_id_, msg.id_, " عضۇێٺ ڂۆډكٱڒ ڣعال ڛډ.")
					elseif matches == "تایید لینک" then	
						redis:del("botBOT-IDmaxlink")
						redis:del("botBOT-IDofflink")
						return send(msg.chat_id_, msg.id_, " ٺاييڋ ليڼڪ ۿٵې در اڼټظٲڕ ٹٲيېڋ ڤعإڷ ڛڎ.")
					elseif matches == "شناسایی لینک" then	
						redis:set("botBOT-IDlink", true)
						return send(msg.chat_id_, msg.id_, " شڼأسٵىى لېنڪ ڥعٳڷ ۺڋ.")
					elseif matches == "افزودن مخاطبین" then	
						redis:set("botBOT-IDsavecontacts", true)
						return send(msg.chat_id_, msg.id_, " ٱ؋زۇدڼ مڂآبېڼ ڡعٳڷ ڛڋ.")
					end
				elseif text:match("^(حداکثر گروه) (%d+)$") then
					local matches = text:match("%d+")
					redis:set('botBOT-IDmaxgroups', tonumber(matches))
					return send(msg.chat_id_, msg.id_, "<i> حداکثر گروه : </i><b> "..matches.." </b>")
				elseif text:match("^(حداقل اعضا) (%d+)$") then
					local matches = text:match("%d+")
					redis:set('botBOT-IDmaxgpmmbr', tonumber(matches))
					return send(msg.chat_id_, msg.id_, "<i>عۻۅىټ ډڒ ڲۯۋه ھٳى ځڈٳقل </i><b> "..matches.." </b> عضٶ ٺڹظيم ۺد.")
				elseif text:match("^(حذف حداکثر گروه)$") then
					redis:del('botBOT-IDmaxgroups')
					return send(msg.chat_id_, msg.id_, "ټعېىن ځڈ مڄٳز ڲڔؤۿ ڼادێډه گڑڤته شڋ.")
				elseif text:match("^(حذف حداقل اعضا)$") then
					redis:del('botBOT-IDmaxgpmmbr')
					return send(msg.chat_id_, msg.id_, "تعیین ځډ مجآز ٳعضاي گږۇه ڼٳډىڈۿ گړڥٺھ شډ.")
				elseif text:match("^(افزودن مدیر) (%d+)$") then
					local matches = text:match("%d+")
					if redis:sismember('botBOT-IDadmin', matches) then
						return send(msg.chat_id_, msg.id_, "<i>ڬآږبږ مۈۯڊ نطڕ ٲڵآن مڈىڒع.</i>")
					elseif redis:sismember('botBOT-IDmod', msg.sender_user_id_) then
						return send(msg.chat_id_, msg.id_, "ۺمآ ڈښتۯښي ڼڈأړێڍ.")
					else
						redis:sadd('botBOT-IDadmin', matches)
						redis:sadd('botBOT-IDmod', matches)
						return send(msg.chat_id_, msg.id_, "<i>کاږبڑ مدىر شڈ ھ</i>")
					end
				elseif text:match("^(افزودن مدیرکل) (%d+)$") then
					local matches = text:match("%d+")
					if redis:sismember('botBOT-IDmod',msg.sender_user_id_) then
						return send(msg.chat_id_, msg.id_, "ۺمٲ ڹمىتوڼين .")
					end
					if redis:sismember('botBOT-IDmod', matches) then
						redis:srem("botBOT-IDmod",matches)
						redis:sadd('botBOT-IDadmin'..tostring(matches),msg.sender_user_id_)
						return send(msg.chat_id_, msg.id_, "مڨآم مڈېر كڵ ۺڈ ڬٵڒبر مۅڕڊ نڟر .")
					elseif redis:sismember('botBOT-IDadmin',matches) then
						return send(msg.chat_id_, msg.id_, 'ڊر ځٱڷ ځإظر مديړع.')
					else
						redis:sadd('botBOT-IDadmin', matches)
						redis:sadd('botBOT-IDadmin'..tostring(matches),msg.sender_user_id_)
						return send(msg.chat_id_, msg.id_, "کٳږبڒ به مقأم کڶ مڹڝۉب ڜڍ.")
					end
				elseif text:match("^(حذف مدیر) (%d+)$") then
					local matches = text:match("%d+")
					if redis:sismember('botBOT-IDmod', msg.sender_user_id_) then
						if tonumber(matches) == msg.sender_user_id_ then
								redis:srem('botBOT-IDadmin', msg.sender_user_id_)
								redis:srem('botBOT-IDmod', msg.sender_user_id_)
							return send(msg.chat_id_, msg.id_, "شمإ ڈىگڑ مڋىڔ مڼيستېد.")
						end
						return send(msg.chat_id_, msg.id_, "ۺمآ ڈسټۯښي ڼدٱرىڼ.")
					end
					if redis:sismember('botBOT-IDadmin', matches) then
						if  redis:sismember('botBOT-IDadmin'..msg.sender_user_id_ ,matches) then
							return send(msg.chat_id_, msg.id_, "ڜمٳ نمېتۄنىډ مډىڔي ڮه مقام دٵڋۿ ڒأ حڌڦ ڪڹيډ.")
						end
						redis:srem('botBOT-IDadmin', matches)
						redis:srem('botBOT-IDmod', matches)
						return send(msg.chat_id_, msg.id_, "كٳڒبړ أز مقأم مڍيۯێت ڂز ڜڊ.")
					end
					return send(msg.chat_id_, msg.id_, "ڮٳڔبۯ مٷڕڊ نظړ مډێۯ ڹمێبأڜڋ.")
				elseif text:match("^(تازه سازی ربات)$") then
					get_bot()
					return send(msg.chat_id_, msg.id_, "<i>مشخصٳت ڦرڈې بھ ړۅز ۺد.</i>")
				elseif text:match("ریپورت") then
					tdcli_function ({
						ID = "SendBotStartMessage",
						bot_user_id_ = 178220800,
						chat_id_ = 178220800,
						parameter_ = 'start'
					}, dl_cb, nil)
				elseif text:match("^(/reload)$") then
					return reload(msg.chat_id_,msg.id_)
				elseif text:match("^(لیست) (.*)$") then
					local matches = text:match("^لیست (.*)$")
					local naji
					if matches == "مخاطبین" then
						return tdcli_function({
							ID = "SearchContacts",
							query_ = nil,
							limit_ = 999999999
						},
						function (I, Naji)
							local count = Naji.total_count_
							local text = "مخاطبین : \n"
							for i =0 , tonumber(count) - 1 do
								local user = Naji.users_[i]
								local firstname = user.first_name_ or ""
								local lastname = user.last_name_ or ""
								local fullname = firstname .. " " .. lastname
								text = tostring(text) .. tostring(i) .. ". " .. tostring(fullname) .. " [" .. tostring(user.id_) .. "] = " .. tostring(user.phone_number_) .. "  \n"
							end
							writefile("botBOT-ID_contacts.txt", text)
							tdcli_function ({
								ID = "SendMessage",
								chat_id_ = I.chat_id,
								reply_to_message_id_ = 0,
								disable_notification_ = 0,
								from_background_ = 1,
								reply_markup_ = nil,
								input_message_content_ = {ID = "InputMessageDocument",
								document_ = {ID = "InputFileLocal",
								path_ = "botBOT-ID_contacts.txt"},
								caption_ = "مڅٳطبێڼ ٵښې شمأۯھ BOT-ID"}
							}, dl_cb, nil)
							return io.popen("rm -rf botBOT-ID_contacts.txt"):read("*all")
						end, {chat_id = msg.chat_id_})
					elseif matches == "پاسخ های خودکار" then
						local text = "<i>ڵېښٹ پٳسڅ ھٵێ څۆڊکإر :</i>\n\n"
						local answers = redis:smembers("botBOT-IDanswerslist")
						for k,v in pairs(answers) do
							text = tostring(text) .. "<i>l" .. tostring(k) .. "l</i>  " .. tostring(v) .. " : " .. tostring(redis:hget("botBOT-IDanswers", v)) .. "\n"
						end
						if redis:scard('botBOT-IDanswerslist') == 0  then text = "<code>       EMPTY</code>" end
						return send(msg.chat_id_, msg.id_, text)
					elseif matches == "مسدود" then
						naji = "botBOT-IDblockedusers"
					elseif matches == "شخصی" then
						naji = "botBOT-IDusers"
					elseif matches == "گروه" then
						naji = "botBOT-IDgroups"
					elseif matches == "سوپرگروه" then
						naji = "botBOT-IDsupergroups"
					elseif matches == "لینک" then
						naji = "botBOT-IDsavedlinks"
					elseif matches == "مدیر" then
						naji = "botBOT-IDadmin"
					else
						return true
					end
					local list =  redis:smembers(naji)
					local text = tostring(matches).." : \n"
					for i, v in pairs(list) do
						text = tostring(text) .. tostring(i) .. "-  " .. tostring(v).."\n"
					end
					writefile(tostring(naji)..".txt", text)
					tdcli_function ({
						ID = "SendMessage",
						chat_id_ = msg.chat_id_,
						reply_to_message_id_ = 0,
						disable_notification_ = 0,
						from_background_ = 1,
						reply_markup_ = nil,
						input_message_content_ = {ID = "InputMessageDocument",
							document_ = {ID = "InputFileLocal",
							path_ = tostring(naji)..".txt"},
						caption_ = "ڵېښٺ "..tostring(matches).." هإې ٲښى ۺمٳڑۿ BOT-ID"}
					}, dl_cb, nil)
					return io.popen("rm -rf "..tostring(naji)..".txt"):read("*all")
				elseif text:match("^(وضعیت مشاهده) (.*)$") then
					local matches = text:match("^وضعیت مشاهده (.*)$")
					if matches == "ان" then
						redis:set("botBOT-IDmarkread", true)
						return send(msg.chat_id_, msg.id_, "<i>ۉضعىٺ ڀىام  >>  خۆاڹڍۿ ڜده ✔️✔️\n</i><code>(ٹىڪ دۇم)</code>")
					elseif matches == "اف" then
						redis:del("botBOT-IDmarkread")
						return send(msg.chat_id_, msg.id_, "<i>ٷۻعېٹ پىآم  >>  ڂوٳڹډ ڹڜڊۿ ✔️\n</i><code>(تێګ ٳۇڵ)</code>")
					end 
				elseif text:match("^(افزودن با پیام) (.*)$") then
					local matches = text:match("^افزودن با پیام (.*)$")
					if matches == "ان" then
						redis:set("botBOT-IDaddmsg", true)
						return send(msg.chat_id_, msg.id_, "<i>ٻيإم أۻآڢه ۺڋڼ مڂٱطبېڹ ڥعٲڵ ڜڋ</i>")
					elseif matches == "اف" then
						redis:del("botBOT-IDaddmsg")
						return send(msg.chat_id_, msg.id_, "<i>پېٱم إڍ ڜڋڼ مخٲطب ۼيږ ڥعاڵ ڜډ</i>")
					end
				elseif text:match("^(افزودن با شماره) (.*)$") then
					local matches = text:match("^افزودن با شماره (.*)$")
					if matches == "ان" then
						redis:set("botBOT-IDaddcontact", true)
						return send(msg.chat_id_, msg.id_, "<i>إڔسأل ڜمإرۿ بڑٳى اډ ڭڔڍڼ ڤعٱل ڜډ</i>")
					elseif matches == "اف" then
						redis:del("botBOT-IDaddcontact")
						return send(msg.chat_id_, msg.id_, "<i>ٲڑسأڸ ڜمٲرۿ بڑآى ٲډ ڪڕڋڹ ڠېۯ ؋عٵڸ ڜډ</i>")
					end
				elseif text:match("^(تنظیم پیام افزودن مخاطب) (.*)") then
					local matches = text:match("^تنظیم پیام افزودن مخاطب (.*)")
					redis:set("botBOT-IDaddmsgtext", matches)
					return send(msg.chat_id_, msg.id_, "<i>ٻێٱم ٳڨزوڈن مڂاطب ځڷ ڜڍ </i>:\n🔹 "..matches.." 🔹")
				elseif text:match('^(تنظیم جواب) "(.*)" (.*)') then
					local txt, answer = text:match('^تنظیم جواب "(.*)" (.*)')
					redis:hset("botBOT-IDanswers", txt, answer)
					redis:sadd("botBOT-IDanswerslist", txt)
					return send(msg.chat_id_, msg.id_, "<i>ڄؤاب بڕٱي | </i>" .. tostring(txt) .. "<i> | ٺڼظىم ۺڍ بھ :</i>\n" .. tostring(answer))
				elseif text:match("^(حذف جواب) (.*)") then
					local matches = text:match("^حذف جواب (.*)")
					redis:hdel("botBOT-IDanswers", matches)
					redis:srem("botBOT-IDanswerslist", matches)
					return send(msg.chat_id_, msg.id_, "<i>ڄۏٲب بۯٱې | </i>" .. tostring(matches) .. "<i> | إز ڵېسټ څٷډڬاړ پٵڪ ڛڋ.</i>")
				elseif text:match("^(پاسخگوی خودکار) (.*)$") then
					local matches = text:match("^پاسخگوی خودکار (.*)$")
					if matches == "ان" then
						redis:set("botBOT-IDautoanswer", true)
						return send(msg.chat_id_, 0, "<i>پاښخگويي څٷډڪإۯ ڦعأڶ ۺڊ</i>")
					elseif matches == "اف" then
						redis:del("botBOT-IDautoanswer")
						return send(msg.chat_id_, 0, "<i>حالت ڀاښڅۅىي څٷڈڮٳږ ېر ڢعإڵ ۺد.</i>")
					end
				elseif text:match("^(بارگیری)$")then
					local list = {redis:smembers("botBOT-IDsupergroups"),redis:smembers("botBOT-IDgroups")}
					tdcli_function({
						ID = "SearchContacts",
						query_ = nil,
						limit_ = 999999999
					}, function (i, naji)
						redis:set("botBOT-IDcontacts", naji.total_count_)
					end, nil)
					for i, v in ipairs(list) do
							for a, b in ipairs(v) do 
								tdcli_function ({
									ID = "GetChatMember",
									chat_id_ = b,
									user_id_ = bot_id
								}, function (i,naji)
									if  naji.ID == "Error" then rem(i.id) 
									end
								end, {id=b})
							end
					end
					return send(msg.chat_id_,msg.id_,"<i>بإږڴيۯي ٳمٳر أښټې ڜمآرھ </i><code> BOT-ID </code> بٵمۏڢقېٺ أنڄٳم ڜډ.")
				elseif text:match("^(وضعیت)$") then
					local s =  redis:get("botBOT-IDoffjoin") and 0 or redis:get("botBOT-IDmaxjoin") and redis:ttl("botBOT-IDmaxjoin") or 0
					local ss = redis:get("botBOT-IDofflink") and 0 or redis:get("botBOT-IDmaxlink") and redis:ttl("botBOT-IDmaxlink") or 0
					local msgadd = redis:get("botBOT-IDaddmsg") and "🔓️" or "🔒️"
					local numadd = redis:get("botBOT-IDaddcontact") and "🔓️" or "🔒️"
					local txtadd = redis:get("botBOT-IDaddmsgtext") or  "ٲډڍى ڳڸم ڂڝۇڝێ ېٳم بڊۿ"
					local autoanswer = redis:get("botBOT-IDautoanswer") and "🔓️" or "🔒️"
					local wlinks = redis:scard("botBOT-IDwaitelinks")
					local glinks = redis:scard("botBOT-IDgoodlinks")
					local links = redis:scard("botBOT-IDsavedlinks")
					local offjoin = redis:get("botBOT-IDoffjoin") and "🔒️" or "🔓️"
					local offlink = redis:get("botBOT-IDofflink") and "🔒️" or "🔓️"
					local gp = redis:get("botBOT-IDmaxgroups") or "ټعېېڹ ڹڜڍھ"
					local mmbrs = redis:get("botBOT-IDmaxgpmmbr") or "ټعيێڹ ڼۺڍۿ"
					local nlink = redis:get("botBOT-IDlink") and "🔓️" or "🔒️"
					local contacts = redis:get("botBOT-IDsavecontacts") and "🔓" or "🔒"
					local fwd =  redis:get("botBOT-IDfwdtime") and "🔓️" or "🔒️" 
					local txt = "⚙️  <i>ۋۻعيت ٳڃرٳىى آسٺې</i><code> BOT-ID</code>  ⛓\n\n"..tostring(offjoin).."<code> عضؤيټ څۄڍڮآړ </code>🚀\n"..tostring(offlink).."<code> تاېېڊ لینک خودکار </code>🚦\n"..tostring(nlink).."<code> تڛڅيڝ ڵێنڪ هٵى عضۄېٺ </code>🎯\n"..tostring(fwd).."<code> زمأڹبڼڋي ڋړ ٱۯسأل </code>🏁\n"..tostring(contacts).."<code> آفزۆڊڼ څۇڋګأڕ مخاطبین </code>➕\n" .. tostring(autoanswer) .."<code> ځٱڷٹ ٻأسخگۏېې څۈڋګٵڑ  🗣 </code>\n" .. tostring(numadd) .. "<code> ٱڡزٷڈڹ ڂٱطب أ ڜمٲرۿ 📶</code>\n" .. tostring(msgadd) .. "<code> إڢزۈډن مھٵطب بأ ٻىإم 🗞</code>\n〰〰〰ا〰〰〰\n📄<code> ڀېٵم ٱڣزۄدن مخٵطب :</code>\n📍 " .. tostring(txtadd) .. " 📍\n〰〰〰ا〰〰〰\n\n⏫<code> ښڨ؋ ښۏپړ ڲپ ۿآ  : </code><i>"..tostring(gp).."</i>\n⏬<code> ګمٹۯێڼ تعڈأڈ ٱعڞإى گڕۏۿ : </code><i>"..tostring(mmbrs).."</i>\n\n<code> 📒ڵىڹك هإى ڏڅێڑۿ ۺڈۿ : </code><b>" .. tostring(links) .. "</b>\n<code>⏲	ڵىنڪ ۿٲې ڈر ٳڹټڟٵږ عضۏېٹ : </code><b>" .. tostring(glinks) .. "</b>\n🕖   <b>" .. tostring(s) .. " </b><code>ثانیه تا عضویت مجدد</code>\n<code>❄️ ڶېنڮ هأې ڈڕ ٲڹظأر ټآىېد : </code><b>" .. tostring(wlinks) .. "</b>\n🕑️   <b>" .. tostring(ss) .. " </b><code>ثانیه تا تایید لینک مجدد</code>\n\n 😎 سٲزنڋھ : @Astae_bot"
					return send(msg.chat_id_, 0, txt)
				elseif text:match("^(امار)$") or text:match("^(آمار)$") or text:match("^(stats)$") or text:match("^(panel)$") then
					local gps = redis:scard("botBOT-IDgroups")
					local sgps = redis:scard("botBOT-IDsupergroups")
					local usrs = redis:scard("botBOT-IDusers")
					local links = redis:scard("botBOT-IDsavedlinks")
					local glinks = redis:scard("botBOT-IDgoodlinks")
					local wlinks = redis:scard("botBOT-IDwaitelinks")
					tdcli_function({
						ID = "SearchContacts",
						query_ = nil,
						limit_ = 999999999
					}, function (i, naji)
					redis:set("botBOT-IDcontacts", naji.total_count_)
					end, nil)
					local contacts = redis:get("botBOT-IDcontacts")
					local text = [[
<i>🎉امآر ٲسٹي 🎁</i>
          
<code>ــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــ♣👤 پېۈې : </code>
<b>]] .. tostring(usrs) .. [[</b>
<code>
ـــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــ₱ 👥 ڴپۿآ : </code>
<b>]] .. tostring(gps) .. [[</b>
<code>
ــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــ💦🎮ښۄٻړ گٻها : </code>
<b>]] .. tostring(sgps) .. [[</b>
<code>
ــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــ🎭🎬 مڂٳطبېڹ : </code>
<b>]] .. tostring(contacts)..[[</b>
<code>
ــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــــ🎧👻 لێڹګۿٲ : </code>
<b>]] .. tostring(links)..[[</b>
 ـ.ــ.ـ.ــ.ـ.ــ.ـ.ــ.ـ.ــ.ـ.ــ.ـ.ــ.ــ.ـ.ــ.ـ.ــ.ـ.ــ.ـ.ــ.ـ.ــ.ـ.ــ.ـ.ــ.ــ.ـ..ــ.ـ.ـ.ــ.ـ.ــ
😎📷سإزڼډھ : @Astae_bot
چنل : @sshteam]]
					return send(msg.chat_id_, 0, text)
				elseif (text:match("^(ارسال به) (.*)$") and msg.reply_to_message_id_ ~= 0) then
					local matches = text:match("^ارسال به (.*)$")
					local naji
					if matches:match("^(خصوصی)") then
						naji = "botBOT-IDusers"
					elseif matches:match("^(گروه)$") then
						naji = "botBOT-IDgroups"
					elseif matches:match("^(سوپرگروه)$") then
						naji = "botBOT-IDsupergroups"
					else
						return true
					end
					local list = redis:smembers(naji)
					local id = msg.reply_to_message_id_
					if redis:get("botBOT-IDfwdtime") then
						for i, v in pairs(list) do
							tdcli_function({
								ID = "ForwardMessages",
								chat_id_ = v,
								from_chat_id_ = msg.chat_id_,
								message_ids_ = {[0] = id},
								disable_notification_ = 1,
								from_background_ = 1
							}, dl_cb, nil)
							if i % 4 == 0 then
								os.execute("sleep 3")
							end
						end
					else
						for i, v in pairs(list) do
							tdcli_function({
								ID = "ForwardMessages",
								chat_id_ = v,
								from_chat_id_ = msg.chat_id_,
								message_ids_ = {[0] = id},
								disable_notification_ = 1,
								from_background_ = 1
							}, dl_cb, nil)
						end
					end
						return send(msg.chat_id_, msg.id_, "<i>حڸھ ؋رستإدۿ ڜڋ</i>")
				elseif text:match("^(ارسال زمانی) (.*)$") then
					local matches = text:match("^ارسال زمانی (.*)$")
					if matches == "ان" then
						redis:set("botBOT-IDfwdtime", true)
						return send(msg.chat_id_,msg.id_,"<i>زمٳنبڹڋێ ارښٱل ڡعإل ۺڋ.</i>")
					elseif matches == "اف" then
						redis:del("botBOT-IDfwdtime")
						return send(msg.chat_id_,msg.id_,"<i>زمٳڼ بڼڈێ إڒسإڵ  ۼێږ فعآل ۺڐ.</i>")
					end
				elseif text:match("^(ارسال به سوپرگروه) (.*)") then
					local matches = text:match("^ارسال به سوپرگروه (.*)")
					local dir = redis:smembers("botBOT-IDsupergroups")
					for i, v in pairs(dir) do
						tdcli_function ({
							ID = "SendMessage",
							chat_id_ = v,
							reply_to_message_id_ = 0,
							disable_notification_ = 0,
							from_background_ = 1,
							reply_markup_ = nil,
							input_message_content_ = {
								ID = "InputMessageText",
								text_ = matches,
								disable_web_page_preview_ = 1,
								clear_draft_ = 0,
								entities_ = {},
							parse_mode_ = nil
							},
						}, dl_cb, nil)
					end
                    return send(msg.chat_id_, msg.id_, "<i>بآ مۉفقيت ڢزستٵډھ شڍ</i>")
				elseif text:match("^(مسدودیت) (%d+)$") then
					local matches = text:match("%d+")
					rem(tonumber(matches))
					redis:sadd("botBOT-IDblockedusers",matches)
					tdcli_function ({
						ID = "BlockUser",
						user_id_ = tonumber(matches)
					}, dl_cb, nil)
					return send(msg.chat_id_, msg.id_, "<i>ڭآڒبڒ مۉړڋ ظڔ مښڈۉڊ ڜڋ</i>")
				elseif text:match("^(رفع مسدودیت) (%d+)$") then
					local matches = text:match("%d+")
					add(tonumber(matches))
					redis:srem("botBOT-IDblockedusers",matches)
					tdcli_function ({
						ID = "UnblockUser",
						user_id_ = tonumber(matches)
					}, dl_cb, nil)
					return send(msg.chat_id_, msg.id_, "<i>مښڋۊڋې ڮاربڑ حڌڢ ڜڍ.</i>")	
				elseif text:match('^(تنظیم نام) "(.*)" (.*)') then
					local fname, lname = text:match('^تنظیم نام "(.*)" (.*)')
					tdcli_function ({
						ID = "ChangeName",
						first_name_ = fname,
						last_name_ = lname
					}, dl_cb, nil)
					return send(msg.chat_id_, msg.id_, "<i>ڼٱم جڈىڋ آ مٷفقېټ ښت شڍ.</i>")
				elseif text:match("^(تنظیم نام کاربری) (.*)") then
					local matches = text:match("^تنظیم نام کاربری (.*)")
						tdcli_function ({
						ID = "ChangeUsername",
						username_ = tostring(matches)
						}, dl_cb, nil)
					return send(msg.chat_id_, 0, '<i>تڷٵڜ بڔآێ ٹڹظێم ڹٱم كٳربړې...</i>')
				elseif text:match("^(حذف نام کاربری)$") then
					tdcli_function ({
						ID = "ChangeUsername",
						username_ = ""
					}, dl_cb, nil)
					return send(msg.chat_id_, 0, '<i>ڼام ڬآڑبړێ بٵ مۏڥڨېٹ پٳڭ ۺد.</i>')
				elseif text:match('^(ارسال کن) "(.*)" (.*)') then
					local id, txt = text:match('^ارسال کن "(.*)" (.*)')
					send(id, 0, txt)
					return send(msg.chat_id_, msg.id_, "<i>ٵڑښٳل ڛڋ</i>")
				elseif text:match("^(بگو) (.*)") then
					local matches = text:match("^بگو (.*)")
					return send(msg.chat_id_, 0, matches)
				elseif text:match("^(شناسه)$") then
					return send(msg.chat_id_, msg.id_, "<i>" .. msg.sender_user_id_ .."</i>")
				elseif text:match("^(خارج شو) (.*)$") then
					local matches = text:match("^خارج شو (.*)$") 	
					send(msg.chat_id_, msg.id_, 'ٳښي ٲز ڰڒۄۿ مٷۯڈ ڹظڔ څٳۯڃ ڜڋ')
					tdcli_function ({
						ID = "ChangeChatMemberStatus",
						chat_id_ = matches,
						user_id_ = bot_id,
						status_ = {ID = "ChatMemberStatusLeft"},
					}, dl_cb, nil)
					return rem(matches)
				elseif text:match("^(اد ال) (%d+)$") then
					local matches = text:match("%d+")
					local list = {redis:smembers("botBOT-IDgroups"),redis:smembers("botBOT-IDsupergroups")}
					for a, b in pairs(list) do
						for i, v in pairs(b) do 
							tdcli_function ({
								ID = "AddChatMember",
								chat_id_ = v,
								user_id_ = matches,
								forward_limit_ =  50
							}, dl_cb, nil)
						end	
					end
					return send(msg.chat_id_, msg.id_, "<i>ڮٵربڒ اڋ ۺڋ بھ ڲپٳم😉 </i>")
				elseif (text:match("^(استی)$") and not msg.forward_info_)then
					return tdcli_function({
						ID = "ForwardMessages",
						chat_id_ = msg.chat_id_,
						from_chat_id_ = msg.chat_id_,
						message_ids_ = {[0] = msg.id_},
						disable_notification_ = 0,
						from_background_ = 1
					}, dl_cb, nil)
				elseif text:match("^(کمک)$") then
					local txt = '🔞 ګمڬ ڊښٹوڕٳت ٲښتې💠\n\n🔸استی\n<i>اعلام وضعیت تبلیغ‌گر ✔️</i>\n<code>❤️ حتی اگر تبلیغ‌گر شما دچار محدودیت ارسال پیام شده باشد بایستی به این پیام پاسخ دهد❤️</code>\n\n🔸افزودن مدیر شناسه\n<i>افزودن مدیر جدید با شناسه عددی داده شده 🛂</i>\n\n🔸افزودن مدیرکل شناسه\n<i>افزودن مدیرکل جدید با شناسه عددی داده شده 🛂</i>\n\n<code>(⚠️ تفاوت مدیر و مدیر‌کل دسترسی به اعطا و یا گرفتن مقام مدیریت است⚠️)</code>\n\n🔸حذف مدیر شناسه\n<i>حذف مدیر یا مدیرکل با شناسه عددی داده شده ✖️</i>\n\n🔸خارج شو\n<i>خارج شدن از گروه و حذف آن از اطلاعات گروه ها 🏃</i>\n\n🔸اد ال مخاطبین\n<i>افزودن حداکثر مخاطبین و افراد در گفت و گوهای شخصی به گروه ➕</i>\n\n🔸شناسه \n<i>دریافت شناسه خود 🆔</i>\n\n🔸بگو متن\n<i>دریافت متن 🗣</i>\n\n🔸ارسال کن "شناسه" متن\n<i>ارسال متن به شناسه گروه یا کاربر داده شده 📤</i>\n\n🔸تنظیم نام "نام" فامیل\n<i>تنظیم نام ربات ✏️</i>\n\n🔸تازه سازی ربات\n<i>تازه‌سازی اطلاعات فردی ربات😌</i>\n<code>(مورد استفاده در مواردی همچون پس از تنظیم نا🅱جهت بروزکردن نام مخاطب اشتراکی تبلیغ‌گر🅰)</code>\n\n🔸تنظیم نام کاربری اسم\n<i>جایگزینی اسم با نام کاربری فعلی(محدود در بازه زمانی کوتاه) 🔄</i>\n\n🔸حذف نام کاربری\n<i>حذف کردن نام کاربری ✘</i>\n\nتوقف عضویت|تایید لینک|شناسایی لینک|افزودن مخاطب\n<i>غیر‌فعال کردن فرایند خواسته شده</i> ◼️\n\n🔸شروع عضویت|تایید لینک|شناسایی لینک|افزودن مخاطب\n<i>فعال‌سازی فرایند خواسته شده</i> ◻️\n\n🔸حداکثر گروه عدد\n<i>تنظیم حداکثر سوپرگروه‌هایی که تبلیغ‌گر عضو می‌شود،با عدد دلخواه</i> ⬆️\n\n🔸حداقل اعضا عدد\n<i>تنظیم شرط حدقلی اعضای گروه برای عضویت,با عدد دلخواه</i> ⬇️\n\n🔸حذف حداکثر گروه\n<i>نادیده گرفتن حدمجاز تعداد گروه</i> ➰\n\n🔸حذف حداقل اعضا\n<i>نادیده گرفتن شرط حداقل اعضای گروه</i> ⚜️\n\n🔸ارسال زمانی ان|اف\n<i>زمان بندی در فروارد و استفاده در دستور ارسال</i> ⏲\n<code>🕐 بعد از فعال‌سازی ,ارسال به 400 مورد حدودا 4 دقیقه زمان می‌برد و  تبلیغ‌گر طی این زمان پاسخگو نخواهد بود 🕐</code>\n\n🔸افزودن با شماره ان|اف\n<i>تغییر وضعیت اشتراک شماره تبلیغ‌گر در جواب شماره به اشتراک گذاشته شده 🔖</i>\n\n🔸افزودن با پیام ان|اف\n<i>تغییر وضعیت ارسال پیام در جواب شماره به اشتراک گذاشته شده ℹ️</i>\n\n🔸تنظیم پیام افزودن مخاطب متن\n<i>تنظیم متن داده شده به عنوان جواب شماره به اشتراک گذاشته شده 📨</i>\n\nلیست مخاطبین|خصوصی|گروه|سوپرگروه|پاسخ های خودکار|لینک|مدیر\n<i>دریافت لیستی از مورد خواسته شده در قالب پرونده متنی یا پیام 💎</i>\n\n🔸مسدودیت شناسه\n<i>مسدود‌کردن(بلاک) کاربر با شناسه داده شده از گفت و گوی خصوصی ☫</i>\n\n🔸رفع مسدودیت شناسه\n<i>رفع مسدودیت کاربر با شناسه داده شده 💢</i>\n\n🔸وضعیت مشاهده ان|اف ☯\n<i>تغییر وضعیت مشاهده پیام‌ها توسط تبلیغ‌گر (فعال و غیر‌فعال‌کردن تیک دوم)</i>\n\n🔸امار\n<i>دریافت آمار و وضعیت تبلیغ‌گر 📊</i>\n\n🔸وضعیت\n<i>دریافت وضعیت اجرایی تبلیغ‌گر⚙️</i>\n\n🔸بارگیری\n<i>بارگیری آمار تبلیغ‌گر🚀</i>\n<code>☻مورد استفاده حداکثر یک بار در روز👽</code>\n\n🔸ارسال به همه|خصوصی|گروه|سوپرگروه\n<i>ارسال پیام جواب داده شده به مورد خواسته شده 📩</i>\n<code>(😕عدم استفاده از همه و خصوصی😇)</code>\n\n🔸ارسال به سوپرگروه متن\n<i>ارسال متن داده شده به همه سوپرگروه ها ✉️</i>\n<code>(😈توصیه ما استفاده و ادغام دستورات بگو و ارسال به سوپرگروه😵)</code>\n\n🔸تنظیم جواب "متن" جواب\n<i>تنظیم جوابی به عنوان پاسخ خودکار به پیام وارد شده مطابق با متن باشد 📃</i>\n\n🔸حذف جواب متن\n<i>حذف جواب مربوط به متن ✖️</i>\n\n🔸پاسخگوی خودکار ان|اف\n<i>تغییر وضعیت پاسخگویی خودکار استی به متن های تنظیم شده 🚨</i>\n\n🔸حذف لینک عضویت|تایید|ذخیره شده\n<i>حذف لیست لینک‌های مورد نظر </i>✘\n\n🔸حذف کلی لینک عضویت|تایید|ذخیره شده\n<i>حذف کلی لیست لینک‌های مورد نظر </i>💢\n📌<code>پذیرفتن مجدد لینک در صورت حذف کلی</code>📌\n\n🔸اد ال شناسه\n<i>افزودن کابر با شناسه وارد شده به همه گروه و سوپرگروه ها ع✜✛</i>\n\n🔸خارج شو شناسه\n<i>عملیات ترک کردن با استفاده از شناسه گروه 🔚</i>\n\n🔸کمک\n<i>دریافت همین پیام 🔁</i>\n〰〰〰ا〰〰〰\nسٲزڹڋھ : @Astae_bot\nکانال : @tabchi2611\n<code>گپ پشتمیبانی ما در کانال.</code>'
					return send(msg.chat_id_,msg.id_, txt)
				elseif tostring(msg.chat_id_):match("^-") then
					if text:match("^(خارج شو)$") then
						rem(msg.chat_id_)
						return tdcli_function ({
							ID = "ChangeChatMemberStatus",
							chat_id_ = msg.chat_id_,
							user_id_ = bot_id,
							status_ = {ID = "ChatMemberStatusLeft"},
						}, dl_cb, nil)
					elseif text:match("^(اد ال مخاطبین)$") then
						tdcli_function({
							ID = "SearchContacts",
							query_ = nil,
							limit_ = 999999999
						},function(i, naji)
							local users, count = redis:smembers("botBOT-IDusers"), naji.total_count_
							for n=0, tonumber(count) - 1 do
								tdcli_function ({
									ID = "AddChatMember",
									chat_id_ = i.chat_id,
									user_id_ = naji.users_[n].id_,
									forward_limit_ = 50
								},  dl_cb, nil)
							end
							for n=1, #users do
								tdcli_function ({
									ID = "AddChatMember",
									chat_id_ = i.chat_id,
									user_id_ = users[n],
									forward_limit_ = 50
								},  dl_cb, nil)
							end
						end, {chat_id=msg.chat_id_})
						return send(msg.chat_id_, msg.id_, "<i>در ځٵڶ ٳڈ ڜڏڹ سيڬ کڹ ۈ بصبږ ...</i>")
					end
				end
			end
			if redis:sismember("botBOT-IDanswerslist", text) then
				if redis:get("botBOT-IDautoanswer") then
					if msg.sender_user_id_ ~= bot_id then
						local answer = redis:hget("botBOT-IDanswers", text)
						send(msg.chat_id_, 0, answer)
					end
				end
			end
		elseif (msg.content_.ID == "MessageContact" and redis:get("botBOT-IDsavecontacts")) then
			local id = msg.content_.contact_.user_id_
			if not redis:sismember("botBOT-IDaddedcontacts",id) then
				redis:sadd("botBOT-IDaddedcontacts",id)
				local first = msg.content_.contact_.first_name_ or "-"
				local last = msg.content_.contact_.last_name_ or "-"
				local phone = msg.content_.contact_.phone_number_
				local id = msg.content_.contact_.user_id_
				tdcli_function ({
					ID = "ImportContacts",
					contacts_ = {[0] = {
							phone_number_ = tostring(phone),
							first_name_ = tostring(first),
							last_name_ = tostring(last),
							user_id_ = id
						},
					},
				}, dl_cb, nil)
				if redis:get("botBOT-IDaddcontact") and msg.sender_user_id_ ~= bot_id then
					local fname = redis:get("botBOT-IDfname")
					local lnasme = redis:get("botBOT-IDlname") or ""
					local num = redis:get("botBOT-IDnum")
					tdcli_function ({
						ID = "SendMessage",
						chat_id_ = msg.chat_id_,
						reply_to_message_id_ = msg.id_,
						disable_notification_ = 1,
						from_background_ = 1,
						reply_markup_ = nil,
						input_message_content_ = {
							ID = "InputMessageContact",
							contact_ = {
								ID = "Contact",
								phone_number_ = num,
								first_name_ = fname,
								last_name_ = lname,
								user_id_ = bot_id
							},
						},
					}, dl_cb, nil)
				end
			end
			if redis:get("botBOT-IDaddmsg") then
				local answer = redis:get("botBOT-IDaddmsgtext") or "🔸ٲډڊێ پىٶې ڀێام بده"
				send(msg.chat_id_, msg.id_, answer)
			end
		elseif msg.content_.ID == "MessageChatDeleteMember" and msg.content_.id_ == bot_id then
			return rem(msg.chat_id_)
		elseif (msg.content_.caption_ and redis:get("botBOT-IDlink"))then
			find_link(msg.content_.caption_)
		end
		if redis:get("botBOT-IDmarkread") then
			tdcli_function ({
				ID = "ViewMessages",
				chat_id_ = msg.chat_id_,
				message_ids_ = {[0] = msg.id_} 
			}, dl_cb, nil)
		end
	end
end
