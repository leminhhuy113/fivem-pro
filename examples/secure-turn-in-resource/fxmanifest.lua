fx_version 'cerulean'
game 'gta5'

name 'secure-turn-in'
author '1MS Studio'
description 'Framework-selectable server-authoritative turn-in example'
version '1.0.0'

shared_script 'config.lua'

client_script 'client/main.lua'

server_scripts {
    'server/adapter.lua',
    'server/main.lua',
}
