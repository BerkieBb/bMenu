fx_version 'cerulean'
game 'gta5'

author 'BerkieB'
description 'A standalone menu containing lots of useful options for FiveM'
version 'don\'t use in live environment'
repository 'https://github.com/BerkieBb/berkie_menu'

lua54 'yes'
use_experimental_fxv2_oal 'yes'

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    'client/**/*.lua',
}

server_scripts {
    'server/**/*.lua'
}

files {
    'config/weapons.lua'
}

dependencies {
    '/server:5904',
    '/onesync',
    'ox_lib'
}