--[[
                  .'@@@@@@@@@@@@@@#:                  
              ,@@@@#;            .'@@@@+              
           ,@@@'                      .@@@#           
         +@@+            ....            .@@@         
       ;@@;         '@@@@@@@@@@@@.          @@@       
      @@#         @@@@@@@@++@@@@@@@;         `@@;     
    .@@`         @@@@@#        #@@@@@          @@@    
   `@@          @@@@@` Cirno's  `@@@@#          +@@   
   @@          `@@@@@  Perfect   @@@@@           @@+  
  @@+          ;@@@@+   Math     +@@@@+           @@  
  @@           `@@@@@  Library   @@@@@@           #@' 
 `@@            @@@@@@          @@@@@@@           `@@ 
 :@@             #@@@@@@.    .@@@@@@@@@            @@ 
 .@@               #@@@@@@@@@@@@;;@@@@@            @@ 
  @@                  .;+@@#'.   ;@@@@@           :@@ 
  @@`                            +@@@@+           @@. 
  ,@@                            @@@@@           .@@  
   @@#          ;;;;;.          `@@@@@           @@   
    @@+         .@@@@@          @@@@@           @@`   
     #@@         '@@@@@#`    ;@@@@@@          ;@@     
      .@@'         @@@@@@@@@@@@@@@           @@#      
        +@@'          '@@@@@@@;            @@@        
          '@@@`                         '@@@          
             #@@@;                  .@@@@:            
                :@@@@@@@++;;;+#@@@@@@+`               
                      .;'+++++;.                      
--]]
local current_folder = (...):gsub('%.init$', '') .. "."

local cpml = {
	_LICENSE = "CPML is distributed under the terms of the MIT license. See LICENSE.md.",
	_URL = "https://github.com/shakesoda/cpml",
	_VERSION = "0.0.1",
	_DESCRIPTION = "Cirno's Perfect Math Library: Just about everything you need for 3D games. Hopefully."
}

local files = {
	"constants",
	"mat4",
	"vec3",
	"quat",
	"simplex",
	"intersect"
}

for _, v in ipairs(files) do
	cpml[v] = require(current_folder .. "cpml." .. v)
end

return cpml
