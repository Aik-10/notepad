fx_version 'bodacious'
game 'gta5'

server_script "server/main.lua"

client_script "client/main.lua"

ui_page {
    'nui/ui.html',
}

files {
    'nui/ui.html',
    'nui/css/main.css',
    'nui/js/app.js',
}
