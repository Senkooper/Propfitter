
print(steamworks.DownloadUGC,'dsadsadsa')
require('workshop')
include('propfitter/shared.lua')



local plrsDat = {}
local workshopItems = {}
local pendingItems = {}

util.AddNetworkString('propfitter_workshopGet')
util.AddNetworkString('propfitter_workshopErr')

hook.Add( "InitPostEntity", "Ready", function()

	clearAllFiles('cache/workshop')

    
end )


local MAX_SIZE = 60000000
local LIMIT_SIZE_TOTAL = MAX_SIZE * 10


hook.Add("PlayerInitialSpawn","propfitter_sendItems",function(plr)
	local steamId = plr:SteamID64()
	local plrDat = plrsDat[steamId]
	if not plrDat then
		plrDat = {totalItemsSize = 0}
		plrsDat[steamId] = plrDat
	end

	for id,item in pairs(workshopItems) do
		getWorkshopItem(id,plrDat,nil)
	end
end)


net.Receive('propfitter_workshopGet',function(len,plr)
	
	local steamId = plr:SteamID64()
	local plrDat = plrsDat[steamId]
	if not plrDat then
		plrDat = {totalItemsSize = 0}
		plrsDat[steamId] = plrDat
	end
	
	getWorkshopItem(net.ReadUInt64(),plrDat,plr)

end)




function getAddonFail(id,errCode,plr)

	pendingItems[id] = nil
	if not plr then
		print('[propfitter ERROR!]:\n '+errMsgs[errCode])
		return
	end
	net.Start('propfitter_workshopErr')
	net.WriteInt(errCode,8)
	net.Send(plr)
end



local function sendAddon(id,addon)
	
	net.Start('propfitter_workshopGet')
	net.WriteUInt64(id)
	net.WriteString(addon.info.title)
	net.WriteInt(addon.info.time_updated,32)
	net.WriteString(addon.info.preview_url)
	net.Broadcast()
	pendingItems[id] = nil
	workshopItems[id] = item
end

function getWorkshopItem(id,plrDat,plr)
	print('getting item '..id)
	if pendingItems[id] then
		return
	end
	
	local item = workshopItems[id]
	if item then
		if item.numUpdates > 3 then
			return
		end
		workshopItems[id] = nil
	else
		item = {info=nil,numUpdates=0,maxSize=0}
	end
	pendingItems[id] = item
	

	//todo: baked cookies gets unlimited uploads STEAM_0:1:891700880
	http.Post( "https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/", { ['itemcount'] = '1', ['publishedfileids[0]'] = id },

	-- onSuccess function
		function( body, length, headers, code )
		//	print( "Done!", body )
			local response = util.JSONToTable(body).response

			if response == nil then
				getAddonFail(id,NO_RESPONSE,plr)
				return
			end

			local info = response.publishedfiledetails[1]

			if info.result ~= 1 then
				getAddonFail(id,INVALID_RESPONSE,plr)
				return
			end


			local gmaPath = 'cache/workshop/'..id..tostring(info.time_updated)..'.gma'

			if file.Exists(gmaPath,'DATA') then
				game.MountGMA('data/'..gmaPath)
				item.info = info

				sendAddon(id,item)

				return
			end

			if info.consumer_app_id ~= 4000 then
				getAddonFail(id,NOT_GMOD_ADDON,plr)
				return 
			end

			
			if item.numUpdates == 0 then
				item.maxSize = tonumber(info.file_size)
				
				if item.maxSize > LIMIT_SIZE_TOTAL-plrDat.totalItemsSize then
					getAddonFail(id,TO_BIG,plr)
					return 
				end
				
			else
				if tonumber(info.file_size) > item.maxSize then
					getAddonFail(id,TO_BIG,plr)
					return
				end
			end
			

			
			
			print('HUH WHAT TF')
			steamworks.DownloadUGC(id,function(path,fl,status)
			
				if not path then
					getAddonFail(id,DOWNLOAD_FAIL,plr)
					return
				end
				local flDat = fl:Read()
				print(path,'DA PATH')
				if string.GetExtensionFromFilename(path) ~= 'gma' then
					print('HUH dsadsad\n\n')
					if item.numUpdates == 0 then
						flDat = util.Decompress(flDat,LIMIT_SIZE_TOTAL-plrDat.totalItemsSize)
						if not flDat then
							getAddonFail(id,UNCOMPRESSED_TO_BIG,plr)
							return
						end
					else
						flDat = util.Decompress(flDat,item.maxSize)
						if not flDat then
							
							getAddonFail(id,UNCOMPRESSED_TO_BIG,plr)
							return
						end
					end
					
					
				end
				

				
				local err = mountGMA(id,flDat,gmaPath,false)
				if err then
					print('DOWNLOADUGC RESULT WTF SHITASS LANG 3123123',status,err,string.len(flDat),string.GetExtensionFromFilename(path))
					getAddonFail(id,err,plr)

					return
				end
					plrDat.totalItemsSize = plrDat.totalItemsSize + string.len(flDat)
					
					item.maxSize = math.max(20000000,1.3*item.maxSize)
					item.info = info
					
					sendAddon(id,item)
					
					item.numUpdates = item.numUpdates + 1
					


	

				
			end)

			//print('daResult',response.publishedfiledetails[1].file_size)

		end,

		-- onFailure function
		function( message )
			
			print(message)
			getAddonFail(id,GET_ITEM_INFO_FAILED,plr)
		end

	)

end
print('\n[propfitter] server loaded\n')