fx_version 'cerulean'
game 'gta5'

author 'Nmsh'
description 'Containers '
version '1.0.0'

shared_script {
  '@ox_lib/init.lua',
  'shared/config.lua'
}

client_scripts {
  'client/custom/framework/*.lua',
  'client/custom/*.lua',
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

lua54 'yes'