fx_version 'cerulean'

use_experimental_fxv2_oal 'yes'
lua54 'yes'

game 'gta5'

author 'https://github.com/NotSomething0'

description 'Open source FiveM Anti-cheat'

version 'v1.5.0'

dependencies {
    '/onesync',
    '/server:5511',
    '/native:0x54C06897'
}

server_scripts {
    'server/util/sv_*.lua',
    'server/classes/sv_*.lua',
    'server/modules/sv_*.lua',
    'server/sv_*.lua',
}