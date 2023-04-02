" TODO:
" - add a search function  

"
"  g:coloroll_force_colorscheme
"  g: coloroll_force_airlinetheme
"           override what's in the file
"
"
" let g:coloroll_keymap_allcolors = "\<leader>0"
" let g:coloroll_keymap_favcolors = "\<leader>9"
" let g:coloroll_keymap_allthemes = "\<leader>8"
" let g:coloroll_keymap_favthemes = "\<leader>7"
"
"

if exists('g:ColorollLoaded')  "|| &cp
  finish
endif
let g:ColorollLoaded = 1

" manage the config file; if the file doesn't exist, a directory 'config' in
" the vim user runtime directory is created
" the config file saves all parameters that can be changed during runtime
if !exists('g:coloroll_config_file')
    let seed_path = fnamemodify( $MYVIMRC, ":h:p" )
    let config_path = seed_path . "/config/"
    if !isdirectory(config_path)
        call mkdir(config_path, "p", 0700)
    endif
    let g:coloroll_config_file = config_path . "coloroll.json"
endif

try
    let payload = coloroll#load_json(g:coloroll_config_file)
    " echo "XX"
    " " load config file
catch /.*/
    call coloroll#ColorollError("an error occurrred when loading the config file |". g:coloroll_config_file ."|")
endtry

" GENERIC OPTIONS
"
if !exists('g:coloroll_favorites')
    " let g:coloroll_favorites = {"color":["ayu", 'desert_n3p', 'gruvbox'], "theme":[]}
    let g:coloroll_favorites = {"color":[], "theme":[]}
endif

if !exists('g:coloroll_special_settings')
    " this dictionary contains any optional list of special settings that need
    " to be applied after a given colorscheme or theme is loaded
    let g:coloroll_special_settings= {"color":{}, "theme":{}}
endif

" APPEARANCE 
"
if !exists('g:coloroll_favorite_mark')
    let g:coloroll_favorite_mark = " > "
    let g:coloroll_favorite_mark = "  ★   "
    " let g:coloroll_favorite_mark = " ⌬ "
    " let g:coloroll_favorite_mark = " 🙣   "   
endif

if !exists('g:coloroll_borderchars')
    " characters to use to show the borders of the window, which are the
    " borderchars list that is passed to the popup_menu call.
    " and characters need to be defined using the same order required by it:
    " top/right/bottom/left border; optionally it is possible to specify character 
    " to use for the topleft/topright/botright/botleft corner.
    let g:coloroll_borderchars = ['─', '│', '─', '│', '╭', '╮', '╯', '╰']
endif


if !exists("g:coloroll_last_colorscheme")
    let g:coloroll_last_colorscheme = execute( "colorscheme" )[1:]
endif

" AIRLINE THEMES OPTIONS
"
" find if Airline is installed
call coloroll#check_airline()
if !exists('g:coloroll_airline')
    let g:coloroll_airline =  g:coloroll_airline_found
elseif g:coloroll_airline == 1 && g:coloroll_airline_found == 0
    call coloroll#ColorollError("[WARNING] AirLine theme enabled but Arline does not appear to be installed. ")
    let g:coloroll_airline = 0
endif


if !exists("g:coloroll_last_airlinetheme")
    let g:coloroll_last_airlinetheme = execute("AirlineTheme")[1:]
endif

augroup ColorollChanges
    " track changes made through the colorscheme command
    autocmd! Colorscheme * :call coloroll#update_colorscheme() 
augroup END 

" TODO do the same with Airline Themes?

"
if exists('g:coloroll_force_colorscheme')
    " GO LIVE...
    call coloroll#ColorApplier(g:coloroll_force_colorscheme, v:true)
else
    " apply current settings
    call coloroll#ColorApplier(g:coloroll_last_colorscheme, v:true)
endif

if exists('g:coloroll_force_airlinetheme')
    call coloroll#ThemeApplier(g:coloroll_force_airlinetheme, v:true)
else
    " apply current settings
    call coloroll#ThemeApplier(g:coloroll_last_airlinetheme, v:true)
endif



" DEFINE THE COMMANDS PROVIDED BY THIS PLUGIN
command! -nargs=0 ColorollAllColors call coloroll#SelectorMenu('color')
command! -nargs=0 ColorollFavoriteColors call coloroll#SelectorMenu('color', g:coloroll_favorites['color'])
command! -nargs=0 ColorollAllThemes call coloroll#SelectorMenu('theme')
command! -nargs=0 ColorollFavoriteThemes call coloroll#SelectorMenu('color', g:coloroll_favorites['themes'])

if exists('g:coloroll_keymap_allcolors')
    execute("nnoremap ". g:coloroll_keymap_allcolors . " :ColorollAllColors<CR>")
endif

if exists('g:coloroll_keymap_favcolors')
    execute("nnoremap ". g:coloroll_keymap_favcolors . " :ColorollFavoriteColors<CR>")
endif

if exists('g:coloroll_keymap_allthemes')
    execute("nnoremap ". g:coloroll_keymap_allthemes . " :ColorollAllThemes<CR>")
endif

if exists('g:coloroll_keymap_favthemes')
    execute("nnoremap ". g:coloroll_keymap_favthemes . " :ColorollFavoriteThemes<CR>")
endif
