fx_version "cerulean"
game "gta5"

author "Stevie"
description "Dupfinder"
--repository ""
version "v0.0.1"

lua54 "yes"


server_scripts {
  "@oxmysql/lib/MySQL.lua",
  "server/server.lua"
}
