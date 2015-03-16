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
	_VERSION = "0.0.9",
	_DESCRIPTION = "Cirno's Perfect Math Library: Just about everything you need for 3D games. Hopefully."
}

local files = {
	"color",
	"constants",
	"intersect",
	"mat4",
	"mesh",
	"quat",
	"simplex",
	"utils",
	"vec2",
	"vec3",
}

for _, v in ipairs(files) do
	cpml[v] = require(current_folder .. "modules." .. v)
end

return cpml
