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

local mat4 = require(current_folder .. "cpml.mat4")
local vec3 = require(current_folder .. "cpml.vec3")
local quat = require(current_folder .. "cpml.quat")
local simplex = require(current_folder .. "cpml.simplex")
local intersect = require(current_folder .. "cpml.intersect")
local constants = require(current_folder .. "cpml.constants")

cpml.mat4 = mat4
cpml.vec3 = vec3
cpml.quat = quat
cpml.simplex = simplex
cpml.intersect = intersect
cpml.constants = constants

return cpml
