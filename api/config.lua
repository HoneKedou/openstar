
local cjson_safe = require "cjson.safe"

local optl = require("optl")

local get_argsByName = optl.get_argsByName

local _action = get_argsByName("action")
local _mod = get_argsByName("mod")
local _debug = get_argsByName("debug")

local config_dict = ngx.shared.config_dict
local host_dict = ngx.shared.host_dict

local _tb,config = config_dict:get_keys(0),{}
for i,v in ipairs(_tb) do
	config[v] = config_dict:get(v)
end

local config_base = cjson_safe.decode(config_dict:get("base")) or {}

local function  hostMod()
	local _tb_host,tb_host_mod,tb_host_name = host_dict:get_keys(0),{},{}
	for i,v in ipairs(_tb_host) do
		local from , to = string.find(v, "_HostMod")
		if from == nil then
			local tmp_tb = {}
			tmp_tb[1],tmp_tb[2] = v,host_dict:get(v)
			table.insert(tb_host_name, tmp_tb)
			tb_host_mod[v] = host_dict:get(v.."_HostMod")
		end
	end
	--optl.sayHtml_ext({_tb_host=_tb_host,tb_host_mod=tb_host_mod,tb_host_name=tb_host_name})
	local j_tb_host_name = optl.tableTojson(tb_host_name)

	if _debug == "no" then
		optl.writefile(config_base.jsonPath.."host_json/host_Mod.json",j_tb_host_name,"w+")
		for i,v in ipairs(tb_host_name) do
			optl.writefile(config_base.jsonPath.."host_json/"..v[1]..".json",tb_host_mod[v[1]],"w+")
		end
	else
		optl.writefile(config_base.jsonPath.."host_json/host_Mod_bak.json",j_tb_host_name,"w+")
		for i,v in ipairs(tb_host_name) do
			optl.writefile(config_base.jsonPath.."host_json/"..v[1].."_bak.json",tb_host_mod[v[1]],"w+")
		end
	end
end

if _action == "save" then

	if _mod == "all_mod" then
		for k,v in pairs(config) do
			if k == "base" then
				if _debug == "no" then
					optl.writefile(config_base.baseDir..k..".json",v,"w+")
				else
					optl.writefile(config_base.baseDir..k.."_bak.json",v,"w+")
				end
			elseif k == "denyMsg" then
				if _debug == "no" then
					optl.writefile(config_base.jsonPath..k..".json",v,"w+")
				else
					optl.writefile(config_base.jsonPath..k.."_bak.json",v,"w+")
				end
			else
				if _debug == "no" then
					optl.writefile(config_base.jsonPath..k..".json",v,"w+")
				else
					optl.writefile(config_base.jsonPath..k.."_bak.json",v,"w+")
				end
			end
		end
		hostMod()
		ngx.say("it is ok")
	else
		local msg = config[_mod]
		if not msg and _mod ~= "host_Mod" then return ngx.say("mod is Non-existent") end 
		if _mod == "base" then
			if _debug == "no" then
				optl.writefile(config_base.baseDir.._mod..".json",msg,"w+")
			else
				optl.writefile(config_base.baseDir.._mod.."_bak.json",msg,"w+")
			end
		elseif _mod == "host_Mod" then
			hostMod()
			ngx.say("it is ok")
		else
			if _debug == "no" then
				optl.writefile(config_base.jsonPath.._mod..".json",msg,"w+")
			else
				optl.writefile(config_base.jsonPath.._mod.."_bak.json",msg,"w+")
			end
		end
		optl.sayHtml_ext({mod=msg})
	end

elseif _action =="load" then

	loadConfig()
	ngx.say("it is ok")
else
    optl.sayHtml_ext({code="error",msg="action is Non-existent"})
end


