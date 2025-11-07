






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




 local defFrameStyle = senkoocoreGUI.style.getDefFrame()



       local errSpace 


    local errPopup
    local errHtml

    print(LocalPlayer(),'asdsadsadsadsadsadsa')
local blurAnimStart

local mainFrame
local mainHtml
local addonsDisplay
local modelsDisplay
local searchBar
local contentUrl

local gettingaddon = false
local searchMode = false



function createModelPanel()
    local modelIcon = vgui.Create('DModelPanel',modelsDisplay)

    modelIcon:SetSize(140,140)
    modelIcon:SetModel(LocalPlayer():GetModel())
end

function hideWorkshop()
    searchMode = false
    searchBar:Call([[input.style.display = 'none',
            bttn.style.display = 'none'
            refresh.style.display = 'none'
            workshopBttn.textContent = 'Workshop']])

    modelsDisplay:Show()
    addonsDisplay:Show()   
    mainHtml:Hide()
end


function menuCreate()

     mainFrame = senkoocoreGUI.frame(defFrameStyle.paint)


    
    mainFrame:SetDeleteOnClose(false );

    mainFrame:SetSize(1000,500)
    mainFrame:Center()
    mainFrame:SetScreenLock(true)
  //  mainFrame:SetDraggable(false)


    

    mainHtml = vgui.Create('DHTML',mainFrame)

    mainHtml:Hide()

    

    



    mainFrame:Hide()

      



   
 
    addonsDisplay = vgui.Create('DHTML',mainFrame)


    searchBar = vgui.Create('DHTML',mainFrame)
     modelsDisplay = vgui.Create('DHTML',mainFrame)
  
    
    modelsDisplay:SetHTML([[
        <body style="margin 0; background-color: rgb(100,100,100)">

        </body>
    ]])

    addonsDisplay:AddFunction('propfitter','addonHover',function()
        addonsDisplay:SetToolTip('sadsadsad fdasfdsf ')
    
        print('dasds')
        
    end)

    addonsDisplay:SetHTML([[

    
        <head>
            <style>
                *{
                    box-sizing: border-box;
                }
                body{
                    font-family: Arial, Helvetica, sans-serif;
                }
                body > img{
                    width: calc(100% / 2 - 8px / 2);
                     cursor: pointer;
                }

                
                
              
                body{
                    display: flex;
                    flex-wrap: wrap;
                    gap: 4px;
                    align-content: flex-start;
                }
               
            </style>
        </head>
        <body style="margin: 4px; background-color: rgb(100,100,100); overflow-x: hidden;">
            <img onmouseenter="propfitter.addonHover()" src="https://images.steamusercontent.com/ugc/760472985785287638/5319B2E8CC39B626EA199DC2CCACDA4481E1E96D/">
        </body
    ]])

     modelsDisplay:Dock(FILL)
    modelsDisplay:DockMargin(0,0,8,0)
    addonsDisplay:Dock(RIGHT)
    addonsDisplay:SetWide(400)



        searchBar:Dock(BOTTOM)
    searchBar:SetTall(80)


   



    //searchBar:Hide();


    

    mainHtml:OpenURL('https://steamcommunity.com/app/4000/workshop')
    
    searchBar:AddFunction('propfitter','workshop',function()
        mainHtml:OpenURL('https://steamcommunity.com/app/4000/workshop')

        

        
    end)

    searchBar:AddFunction('propfitter','back',function()

        if searchMode then
            hideWorkshop()
           return
        end
        searchMode = true
        
        addonsDisplay:Hide()
        modelsDisplay:Hide()

        mainHtml:Show()

        searchBar:Call([[input.style.display = 'unset'
        bttn.style.display = 'unset'
        refresh.style.display = 'unset'
        workshopBttn.textContent = 'Back']])
    end)



    searchBar:AddFunction('propfitter','getWorkshopAddon',function(url)
       
        if not gettingaddon then
            hideWorkshop()
             gettingaddon = true
        end
        if url == '' then
            print(contentUrl,'addon id')
            net.Start('propfitter_workshopGet')
            net.WriteUInt64(contentUrl)
            net.SendToServer()
            return
        end

       
        if string.sub(url,9,50) == 'steamcommunity.com/sharedfiles/filedetails' then
            net.Start('propfitter_workshopGet')
            net.WriteUInt64(string.match(url,'[0-9]+',56))
            net.SendToServer()
            return
        end

         if string.sub(url,1,42) == 'steamcommunity.com/sharedfiles/filedetails' then
            net.Start('propfitter_workshopGet')
            net.WriteUInt64(string.match(url,'[0-9]+',48))
            net.SendToServer()
            return
        end

        print(url,'gma link')
    end)

   
    searchBar:Call([[
        var bttn = document.getElementById("bttn")
        var input = document.getElementById('input')
        var refresh = document.getElementById('refresh')
        var workshopBttn = document.getElementById('workshopBttn')


        console.log('FUDJSAKDJSAURKSA URMOTHER')
        

        var showFileDetails = false
     
        function onInput(){
            
            if (input.value == '' && !showFileDetails){
                bttn.style.visibility = 'hidden'
                return
            }

            bttn.style.visibility = 'visible'
        }

        function openFileDetails(){
            input.value = ''
            showFileDetails = true
            bttn.style.visibility = 'visible'
        }

        function defaultLayout(){
            input.value = ''
            showFileDetails = false
            bttn.style.visibility = 'hidden'
        }

        function openWorkshop(){
            showFileDetails = false
            propfitter.workshop()
            defaultLayout()
           
        }

        function submitClick(){
            bttn.style.visibility = 'hidden'
            propfitter.getWorkshopAddon(input.value)
         
            
        }
    
    ]])



 

     function mainHtml:OnBeginLoadingDocument(url)
        //print(url)
        
       
        print('loading',url)
       
        if string.sub(url,9,26) == 'steamcommunity.com' then

             //print(string.sub(url,9,26))
            //print(string.sub(url,28,50) )
            if string.sub(url,28,50) == 'sharedfiles/filedetails' then

                contentUrl = string.match(url,'[0-9]+',56)
                searchBar:Call('openFileDetails()')
             
                return
            end

            //print('huhWTFPLSGO BACK TO ORGIN\n\n\n\n\n',url)
        

            searchBar:Call('defaultLayout()')
        end
        
    end


    searchBar:SetHTML([[

        <style>
            *{
                box-sizing: border-box;
            }
            input:focus{
                outline: unset;
            }
            button:focus{
                outline: unset;
            }
            
            button{
                margin-top: 3px;
                transition: all 0.07s;
                border-radius: 8px;
                border: 2px solid rgb(175,175,175);
                margin-bottom: 6px;
                background-color:white;
            }

            button:hover{
                box-shadow: rgba(0,0,0,0.3) 0 6px 6px;
                transform: translateY(-3px);
            }


            button:active{
                box-shadow: none; 
                transform: translateY(0);
            }
        </style>
        <body style='margin-top: 0; margin-bottom: 0; height: 100%; padding-top: 8px;'>
            
            <div style=' width: 100%'>
                <button id='workshopBttn' onclick='propfitter.back()' style='height: 26px; width: 74px; margin-bottom: 6px; background-color: white;'>Workshop</button>
                <button id='refresh' onclick='openWorkshop()' style='height: 26px; width: 74px; margin-bottom: 6px; background-color: white; display: none'>Refresh</button>
            </div>

            <div style=' width: 100%'>
                <input id='input' oninput='onInput()' type='text' style='height: 26px; width: 46%; background-color: white; border: 2px solid rgb(175,175,175); border-radius: 8px; font-size: 16px; padding: 0px 5px; margin-bottom: 6px; display: none' placeholder='link to addon file'>
                <button id='bttn' onclick='submitClick()' style='height: 26px; margin-bottom: 6px; visibility: hidden; display: none; background-color: white;'>Submit</button>
            </div>
            
            
            
            
        </body>

    ]])
    


   
    

    mainHtml:Dock(FILL)

    



    


    //notification.AddLegacy(' addon upload reached\n Please wait till next server restart\n to re-upload addons.',NOTIFY_ERROR,15)

    
   
    //mainHtml:OpenURL('https://steamcommunity.com/app/4000/workshop/')

    errSpace = vgui.Create('Panel')
    errSpace:Hide()
    errSpace:Dock(FILL)
    

    errSpace:MakePopup()

    
     errPopup = senkoocoreGUI.frame(function(self,w,h)
        Derma_DrawBackgroundBlur(self,blurAnimStart)
        defFrameStyle.paint(self,w,h)
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
    writeFile('propfitter/addons.json',util.TableToJSON(addons))
end)


hook.Add('InitPostEntity','propfitter_init',function()
   // file.Read('propfitter/addons.dat','DATA')


   local contents = file.Read('propfitter/addons.dat')
   if not contents then
        writeFile('propfitter/addons.json','')
    else
        local addons = util.JSONToTable(contents)
        if addons then
            local mostRecentVersion
            for key,addon in pairs(addons) do
                mostRecentVersion = addon.versions[1]
                local version
                for i = 2, #addon.versions do
                    version = addon.versions[i]
                    file.Delete('cache/workshop/'..addon.id..version)
                end
            end
        else
            clearAllFiles('cache/workshop')
            writeFile('propfitter/addons.json','')
        end
    end


end)
net.Receive('propfitter_workshopErr',function()
    //local code = net.ReadInt(8)

    blurAnimStart = SysTime()
    mainFrame:MoveToBack()
    errSpace:Show()
    errPopup:Show()

    errHtml:Call('errMsgDisplay.textContent = "'..errMsgs[net.ReadInt(8)]..'"')

end)




local function loadModels(mountedFls,id,name)

    local addon = addons[id]
    if addon then
        return
    end

    
    addon = {mdls={},id=id,name=name}

    for i,v in ipairs(mountedFls) do
        if string.GetExtensionFromFilename(string.lower(v)) == 'mdl' then
            table.insert(addon.mdls,v)
        end
    end


    print('addon ',name)
    PrintTable(addon.mdls)

    addons[id] = addon
    
end


net.Receive('propfitter_workshopGet',function()

    print('\n[propfitter] downloading addon')


    local id = net.ReadUInt64()
    local name = net.ReadString()
    local version = net.ReadInt(32)
    local previewImgUrl = net.ReadString()


    print(id..'\n')


    local gmaPath = 'cache/workshop/'..id..tostring(version)..'.gma'

    if file.Exists(gmaPath,'DATA') then
        if mountedFls then
            loadModels(mountedFls,id,name)
        end
       
        return;
    end

    steamworks.DownloadUGC(id,function(path,fl)
        local err,mountedFls = mountGMA(id,fl:Read(),gmaPath,false)
        if mountedFls then
            loadModels(mountedFls,id,name)
        end
       
        
    end)

		
end)


local function parseAddonID(str)
    if string.sub(str,9,50) == 'steamcommunity.com/sharedfiles/filedetails' then
        return string.match(str,'?id=([0-9]+)',50)
    end

    if string.sub(str,1,42) == 'steamcommunity.com/sharedfiles/filedetails' then
        return string.match(str,'?id=([0-9]+)',42)
    end
end

concommand.Add('propfitter',function(plr,cmd,args)
    print(cmd)
    PrintTable(args)

    net.Start('propfitter_workshopGet')
    net.WriteUInt64(parseAddonID(args[1]))
    net.SendToServer()
end,function(cmd,args)
    return {cmd..' "[URL to workshop addon, GMA download or addon ID]"'}
end)

concommand.Add('propfitter_test',window)

print('[propfitter] client loaded\n')