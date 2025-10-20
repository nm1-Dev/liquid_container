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
  'server/custom/framework/*.lua',
  'server/custom/*.lua',
  'server/server.lua'
}

lua54 'yes'