fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'fivem-pro-template'
author '1MS Studio'
description 'Minimal secure resource template — demonstrates fivem-pro Iron Rules'
version '1.0.0'

shared_scripts {
    'config.lua',
    'locales/en.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/style.css',
    'html/app.js',
}

dependencies {
    'oxmysql',
}
