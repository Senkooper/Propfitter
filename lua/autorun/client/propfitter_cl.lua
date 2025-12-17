

include('propfitter/shared.lua')
require('senkoocore/gui')
print('[propfitter] shared loaded\n')





local function ent_size(path)
    
    local ent = ClientsideModel(path, RENDERGROUP_OPAQUE) 
    if not IsValid(ent) then
        return nil, "fail 404"
    end

    local min, max = ent:GetModelBounds() 
    ent:Remove() 
    local size = max - min
    size.x = size.x + 100
    size.y = size.y + 100
    size.z = size.z + 200
 

    return size 
end



file.CreateDir('cache/workshop')
local addons = {}
local errSpace 


local errPopup
local errHtml







function menuCreate()
    errSpace = vgui.Create('Panel')
    errSpace:Hide()
    errSpace:Dock(FILL)
    

    errSpace:MakePopup()

    
     errPopup = senkoocoreGUI.frame(function(self,w,h)
        Derma_DrawBackgroundBlur(self,blurAnimStart)

        
        //defFrameStyle.paint(self,w,h)
    end)
    errPopup:Hide()
    errPopup:SetSize(330,170)
    errPopup:Center()
    errPopup:SetDraggable(true)

    //warn:DoModal()
    errPopup:SetTitle('ERROR!')

    errPopup.btnClose:Hide()

    errHtml = vgui.Create('DHTML',errPopup)

    errHtml:Dock(FILL)


    function errSpace:OnMousePressed()
        print('hi')
        errPopup:MakePopup()
    end

    errHtml:AddFunction('gmod','close',function()
        errPopup:Hide()
        errSpace:Hide()

    end)

   

       

    errHtml:SetHTML([[
        <style>
            *{
                box-sizing: border-box;
            }
        </style>

        <body style=' margin:0; padding:2px; background-color:white; height: 100%; display: flex; flex-direction: column'>




            <section style='display: flex; justify-content: center'>
                <svg  width="45" height="45" viewBox="0 0 20 20">
                    <path fill="#de3031" d="M13.728 1H6.272L1 6.272v7.456L6.272 19h7.456L19 13.728V6.272zM11 15H9v-2h2zm0-4H9V5h2z"/>
                </svg>
            </section>
           
            <h1 id='errMsgDisplay' style='font-size: 18px; margin-top: 2px; text-align: center; height: 100%'>
                
            </h1>


            <section style='display:flex; justify-content: center'>

                <button style='user-select: none' onclick='gmod.close()'>Ok</button>

            </section>
            

           
             

        </body>
       
    ]])

    errHtml:Call([[
        var errMsgDisplay = document.getElementById('errMsgDisplay')
    ]])




end

if IsValid(LocalPlayer()) then
    menuCreate()
end
hook.Add('InitPostEntity','propfitter_menuCreate',menuCreate)

 

  


    
  

local function window()


    local testFame = vgui.Create('DFrame')
    testFame:Center()
    testFame:SetSize(1000,500)
    testFame:SetDraggable(true)

  
    local testDhtml = vgui.Create('DHTML',testFame)
    testDhtml:Dock(FILL)

    testDhtml:SetHTML([[
      

             


            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Document</title>
            </head>
            <body>
                <svg  width="45" height="45" viewBox="0 0 20 20">
                    <path fill="#de3031" d="M13.728 1H6.272L1 6.272v7.456L6.272 19h7.456L19 13.728V6.272zM11 15H9v-2h2zm0-4H9V5h2z"/>
                </svg>
            <div style="background-color: purple">HELLLO</div>
            </body>
            </html>
            
            

           
             

      
       
    ]])
    //blurAnimStart = SysTime()0
    
      //mainFrame:Show()


    

end




gameevent.Listen( "client_disconnect" )
hook.Add('client_disconnect','propfitter_save',function()

    local contents = file.Read('propfitter/addons.json','DATA')

    if not contents then
         writeFile('propfitter/addons.json','')
    else
        local prevAddons = util.JSONToTable(contents)

        if prevAddons then
            for key, addon in pairs(prevAddons) do
                if not addons[key] then
                    addons[key] = addon
                end
            end
        end
        
        writeFile('propfitter/addons.json',util.TableToJSON(addons))
    end
    
end)


hook.Add('InitPostEntity','propfitter_init',function()
   // file.Read('propfitter/addons.dat','DATA')


   local contents = file.Read('propfitter/addons.json')
   if not contents then
        writeFile('propfitter/addons.json','')
    else
        addons = util.JSONToTable(contents)

     
        if not addons or not pcall(function()
                for key,addon in pairs(addons) do
                    local version
                    for i = 1, #addon.versions-1 do
                        version = addon.versions[i]
                        file.Delete(string.format(addonFilePathFormat,key,version))
                    end
                    addon.versions = {addon.versions[#addon.versions]}
                end
        end) then
                addons = {}
                clearAllFiles('cache/workshop')
                writeFile('propfitter/addons.json','')

        end
    end


end)
net.Receive('propfitter_workshopErr',function()
    //local code = net.ReadInt(8)

    blurAnimStart = SysTime()
    errSpace:Show()
    errPopup:Show()

    errHtml:Call('errMsgDisplay.textContent = "'..errMsgs[net.ReadInt(8)]..'"')

end)




local function loadModels(mountedFls,id,name,version,exists)



    local addon = addons[id]
    
    if not addon then
        addon = {mdls={},name=name,versions={version}}

        for i,v in ipairs(mountedFls) do
            if string.GetExtensionFromFilename(string.lower(v)) == 'mdl' then
                table.insert(addon.mdls,v)
            end
        end
       addons[id] = addon
    else
        if not exists then
            table.insert(addon.versions,version)
        end
        
    end

    print('addon ',name)
    PrintTable(addon.mdls)
    print('\naddons: ')
    PrintTable(addons)
    
end




net.Receive('propfitter_workshopGet',function()

    print('\n[propfitter] downloading addon')


    local id = net.ReadUInt64()
    local name = net.ReadString()
    local version = net.ReadInt(32)
    local previewImgUrl = net.ReadString()
    local loadLua = net.ReadBool()


    local gmaPath = string.format(addonFilePathFormat,id,version)
   
    if file.Exists(gmaPath,'DATA') then
        local success,mountedFls = game.MountGMA('data/'..gmaPath)
        
        if mountedFls then
           
            loadModels(mountedFls,'addon_'..id,name,version,true)
        end
      
       
    else
        
        steamworks.DownloadUGC(id,function(path,fl)
           
            local err,mountedFls = mountGMA(id,fl:Read(),gmaPath,false,loadLua)
            if mountedFls then
                loadModels(mountedFls,'addon_'..id,name,version)
            end
        
            
        end)
    end


    

		
end)


local function parseAddonID(str)

    if not str then
        return nil
    end

    str = string.Trim(str)

    if string.sub(str,9,50) == 'steamcommunity.com/sharedfiles/filedetails' then
        return string.match(str,'?id=([0-9]+)',50)
    end

    if string.sub(str,1,42) == 'steamcommunity.com/sharedfiles/filedetails' then
        return string.match(str,'?id=([0-9]+)',42)
    end
    
    return string.match(str,'[0-9]+')
end


local argMsg = 'URL to workshop addon or addon ID'
local cmdHelper = string.format('propfitter "[%s]"',argMsg)
concommand.Add('propfitter',function(plr,cmd,args)
    if #args == 0 then
        print(string.format('Missing argument. %s',cmdHelper))
        return
    end
    local addonID = parseAddonID(args[1])

    if not addonID then
        print(string.format('Invalid argument. %s',cmdHelper))
        return
    end
    net.Start('propfitter_workshopGet')
    net.WriteUInt64(addonID)
    net.SendToServer()
end,function(cmd,args)
    return {cmdHelper}
end)

concommand.Add('propfitter_test',window)

print('[propfitter] client loaded\n')