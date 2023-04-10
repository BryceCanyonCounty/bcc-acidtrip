fx_version "adamant"
games {"rdr3"}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

lua54 'yes'
author 'Jake2k4'


server_scripts {
    'server.lua',
}

shared_scripts {
    'config.lua',
}


client_scripts {
    '/client/client.lua',
    '/client/functions.lua',
}

dependencies {
    'vorp_core',
    'vorp_inventory',
    'bcc-versioner',
    'weathersync'
}

version '1.0.0'