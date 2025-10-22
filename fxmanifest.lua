fx_version 'cerulean'
game 'gta5'

author 'Nmsh'
description 'FiveM Script for Liquid Container'
version '1.0.0'

shared_script {
  'shared/config.lua'
}

client_scripts {
  'client/functions.lua',
  'client/client.lua'
}

server_scripts {
  'server/functions.lua',
  'server/server.lua'
}

ui_page 'web/index.html'

files {
  'web/index.html',
  'web/style.css',
  'web/script.js',
  'web/merryweather.png'
}