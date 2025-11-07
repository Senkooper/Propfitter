require('senkoocore/gma')
AddCSLuaFile()



UPDATE_LIMIT_REACHED = 0
NO_RESPONSE = 1
INVALID_RESPONSE = 2
NOT_GMOD_ADDON = 3
TO_BIG = 4
DOWNLOAD_FAIL = 5
UNCOMPRESSED_TO_BIG = 6
META_PARSE_FAIL = 8
NO_VALID_FILES = 9
FAILED_CREATE_FILE = 10
MOUNT_FAIL = 11
GET_ITEM_INFO_FAILED = 12


errMsgs = {}

errMsgs[UPDATE_LIMIT_REACHED] = 'This addon has been updated too many times'
errMsgs[NO_RESPONSE] = 'Could not get addon info'
errMsgs[INVALID_RESPONSE] = 'Invalid addon info'
errMsgs[NOT_GMOD_ADDON] = "Not a Garry's Mod addon"
errMsgs[TO_BIG] = 'addon too big'
errMsgs[DOWNLOAD_FAIL] = 'Failed to download addon'
errMsgs[UNCOMPRESSED_TO_BIG] = 'The uncompressed addon file is too big'
errMsgs[META_PARSE_FAIL] = 'Failed to get addon file meta'
errMsgs[NO_VALID_FILES] = 'No valid files found because it contained only lua, and/or duplicate names'
errMsgs[FAILED_CREATE_FILE] = 'Failed to create the addon file'
errMsgs[MOUNT_FAIL] = 'Failed to mount addon'
errMsgs[GET_ITEM_INFO_FAILED] = 'addon info request failed'





function clearAllFiles(dir)
	local fls = file.Find(dir..'/*','DATA')

  	for i,f in ipairs(fls) do
		print('DELETING CACHED WORKSHOP ITEMS')
		file.Delete(dir..'/'..f)
  	end
end

function writeFile(path,contents)
	local dir = string.GetPathFromFilename(path)

	if not file.Exists(dir,'DATA') then
		file.CreateDir(dir)
	end

	file.Write(path,contents)
end

function mountGMA(id,gmaDat,gmaPath,noOverwrites)
	

	

	local meta = GMA.parse(gmaDat)

	if not meta then
		//pendingItems[id] = nil
		return META_PARSE_FAIL
	end

	
	GMA.filterFiles(meta,function(fl)
		return fl.ext:lower() == 'lua'
	end)
	
	if noOverwrites then
		GMA.filterFiles(meta,function(fl)
			//print(file.Exists(fl.filename,'GAME'),fl.filename)
			return file.Exists(fl.filename,'GAME')
		end)
	end
	if #meta.files == 0 then
		return NO_VALID_FILES
	end
	

	local gmaFl = file.Open(gmaPath,'wb','DATA')

	if not gmaFl then
		return FAILED_CREATE_FILE
	end

	GMA.build(meta,gmaFl)

	gmaFl:Close()

	
	local success, mountedFls = game.MountGMA('data/'..gmaPath)

	if success then
		//PrintTable(mountedFls)
	//	PrintTable(meta.files)
		return nil,mountedFls
	end
	file.Delete(gmaPath)
	return MOUNT_FAIL
end
