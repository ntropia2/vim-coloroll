" SOURCE: https://www.linode.com/docs/guides/writing-a-vim-plugin/

" TODO
" - addnsuoort for soecial cimmands for colors
" - add variable for defining keybijdings
" - change "current" information (a sign next to line?)
" - documentation


""""""""""""""""""""""""""""""""""""""""""""""""""
" functions start here
"

" this variable is used to toggle the monitoring of colorscheme changes
" during previews is disabled to prevent making the changes permanent
let g:coloroll__event_monitoring = 1

func! coloroll#update_colorscheme()
    if g:coloroll__event_monitoring == 1
        let g:coloroll_last_colorscheme = execute("colorscheme")[1:] |
        call coloroll#save_json(g:coloroll_config_file)
    endif
endfunc

func! coloroll#save_json(fname=v:none)
    " save coloroll 'session' settings in a JSON file
    if a:fname == v:none
        let filename = g:coloroll_config_file
    else
        let filename = a:fname
    endif
    let payload = {"g:coloroll_favorites": g:coloroll_favorites, 
        \ "g:coloroll_last_colorscheme": g:coloroll_last_colorscheme,
        \ "g:coloroll_last_airlinetheme": g:coloroll_last_airlinetheme}
    try
        call writefile(split(json_encode(payload)), filename)
    catch /.*/
        call coloroll#ColorollError("Error when saving file |".filename."|")
    endtry
endfunc

func! coloroll#load_json(fname=v:none)
    " load 'session' settings from a JSON file
    if a:fname == v:none
        let filename = g:coloroll_config_file
    else
        let filename = a:fname
    endif
    try
        let payload = json_decode(join(readfile(filename)))
        let g:coloroll_favorites = payload['g:coloroll_favorites']
        let g:coloroll_last_colorscheme = payload['g:coloroll_last_colorscheme']
        let g:coloroll_last_airlinetheme = payload['g:coloroll_last_airlinetheme']
    catch /.*/
        call coloroll#ColorollError("Error when reading file |".filename."|")
    endtry
endfunc

func! coloroll#check_airline()
    "check if airline is installed and enabled
    if exists(":AirlineToggle") != 2
        let g:coloroll_airline_found = 0
        return v:false
    else
        let g:coloroll_airline_found = 1
        return v:true
    endif
endfunc

func! coloroll#get_airline_themes(match='')
    " function to return all airline themes installed (copied from
    " airline#util.vim)
    try 
        let files = split(globpath(&rtp, 'autoload/airline/themes/'.a:match.'*.vim', 1), "\n")
        return sort(map(files, 'fnamemodify(v:val, ":t:r")'))
    catch /.*/
        return []
    endtry
endfunction

func! coloroll#ColorCallback(id, key)
    " this function creates a specialized callback function for color 
    " (sort of pseudo-lambda in Python)
    let g:coloroll__last_used = execute( "colorscheme" )[1:]
    " TODO make last_used a global variable
    call coloroll#GenericCallback(a:id, a:key,"color") ", last_used)
    return v:true
endfunc

func! coloroll#ThemeCallback(id, key)
    " this function creates a specialized callback function for themes 
    " (sort of pseudo-lambda in Python)
    let g:coloroll__last_used = execute("AirlineTheme")[1:]
    call coloroll#GenericCallback(a:id, a:key, "theme") " , last_used)
    return v:true
endfunc

func! coloroll#ColorApplier(colorscheme, save=v:false )
    " helper function to create a wrapped colorscheme function
    if a:save
        let g:coloroll__event_monitoring = 1
        " this shoukd be suffic8rnt to trigger aurodave
    endif
    execute("colorscheme " . a:colorscheme)
endfunc

func! coloroll#ThemeApplier(theme, save=v:false)
    " helper function to create a wrapped airline theme function
    " this function strips the suffix for the preferred/bookmarked themes
    call airline#switch_theme( a:theme, 1)
    if a:save
        let g:coloroll_last_airlinetheme = a:theme
        call coloroll#save_json(g:coloroll_config_file)
    endif
endfunc

func! coloroll#get_current_choice(text_line)
    " return the string of the current choice by removing the suffix, if present
    " return the boolean value of the favorite property
    "
    " these two lenghts are required to capture possible multi-byte or double
    " width characters used as favorite markers
    let suffix_size = strwidth(g:coloroll_favorite_mark)
    let suffix_idx = strlen(g:coloroll_favorite_mark)
    let filler = repeat(" ", suffix_size)
    if a:text_line[0:suffix_idx-1] == g:coloroll_favorite_mark
        let l:clean_string = a:text_line[suffix_idx:]
        let l:is_favorite = v:true
        let l:suffix_string = a:text_line
        let l:no_suffix_string = repeat(" ", suffix_size) . l:clean_string
    elseif a:text_line[0:suffix_idx-1] == filler || a:text_line[0:suffix_size-1] == filler
        let l:clean_string = a:text_line[suffix_size:]
        let is_favorite = v:false
        let l:suffix_string = g:coloroll_favorite_mark . l:clean_string
        let l:no_suffix_string = a:text_line
    else
        echom "Problem! |" . a:text_line ."| suffix:|". a:text_line[0:suffix_size-1] ."|" . a:text_line[0:suffix_idx-1] ."|"
    endif
    return [ l:clean_string, l:is_favorite, l:suffix_string, l:no_suffix_string ]
endfunc


func! coloroll#GenericCallback(id, key, mode='color') ", last_used=v:none)
    " disable listening to colorscheme changes
    let g:coloroll__event_monitoring = 0
    if a:mode == "color"
        let l:apply_func = "coloroll#ColorApplier"
        " let l:last_value = g:coloroll_last_colorscheme
    elseif a:mode == "theme"
        let l:apply_func = "coloroll#ThemeApplier"
        " let l:last_value = g:coloroll_last_airlinetheme
    endif
    if a:key == "\<esc>"
        execute("call " . l:apply_func . "(\"". g:coloroll__last_used .   "\", v:false)")
        call popup_close(a:id, -1)
        " restore listening to colorscheme changes events
        let g:coloroll__event_monitoring = 1
        " restore original updatetime before the call
        execute("set updatetime=".g:coloroll__updatetime_value)
    elseif a:key == "\<cr>" || a:key == "\^M"
        let line_content = g:choice_buff_list[getcurpos(a:id)[1] - 1]
        let [ curr_choice, is_favorite, suffix_string, no_suffix_string ] = coloroll#get_current_choice(line_content)
        execute("call " . l:apply_func . "(\"". curr_choice .   "\", v:true)")
        call popup_close(a:id, -1)
        " restore original updatetime before the call
        execute("set updatetime=".g:coloroll__updatetime_value)
    elseif (a:key == 'j') || (a:key == "\<down>")
        call win_execute(a:id, "normal! j")
        let line_content = g:choice_buff_list[getcurpos(a:id)[1] - 1]
        let [ curr_choice, is_favorite, suffix_string, no_suffix_string] = coloroll#get_current_choice(line_content)
        execute("call " . l:apply_func . "(\"". curr_choice  .  "\", v:false)")
    elseif a:key == 'k'  || a:key == "\<up>"
        call win_execute(a:id, "normal! k")
        let line_content = g:choice_buff_list[getcurpos(a:id)[1] - 1]
        let [ curr_choice, is_favorite, suffix_string, no_suffix_string ] = coloroll#get_current_choice(line_content)
        execute("call " . l:apply_func . "(\"". curr_choice  .  "\", v:false)")
    elseif a:key == "\<PageDown>"
        call win_execute(a:id, "normal! 5j")
        let line_content = g:choice_buff_list[getcurpos(a:id)[1] - 1]
        let [ curr_choice, is_favorite, suffix_string, no_suffix_string ] = coloroll#get_current_choice(line_content)
        execute("call " . l:apply_func . "(\"". curr_choice  .  "\", v:false)")
    elseif a:key == "\<PageUp>"
        call win_execute(a:id, "normal! 5k")
        let line_content = g:choice_buff_list[getcurpos(a:id)[1] - 1]
        let [ curr_choice, is_favorite, suffix_string, no_suffix_string ] = coloroll#get_current_choice(line_content)
        execute("call " . l:apply_func . "(\"". curr_choice  .  "\", v:false)")
    elseif a:key == "\<kHome>" || a:key == "\<Home>"
        call win_execute(a:id, "normal! gg")
        let line_content = g:choice_buff_list[getcurpos(a:id)[1] - 1]
        let [ curr_choice, is_favorite, suffix_string, no_suffix_string ] = coloroll#get_current_choice(line_content)
        execute("call " . l:apply_func . "(\"". curr_choice  .  "\", v:false)")
    elseif a:key == "\<kEnd>" || a:key == "\<End>"
        call win_execute(a:id, "normal! G")
        let line_content = g:choice_buff_list[getcurpos(a:id)[1] - 1]
        let [ curr_choice, is_favorite, suffix_string, no_suffix_string ] = coloroll#get_current_choice(line_content)
        execute("call " . l:apply_func . "(\"". curr_choice  .  "\", v:false)")
    elseif a:key == "b"
        let l:choice_idx = getcurpos(a:id)[1] - 1
        let line_content = g:choice_buff_list[getcurpos(a:id)[1] - 1]
        let [ curr_choice, is_favorite, suffix_string, no_suffix_string ] = coloroll#get_current_choice(line_content)
        if !is_favorite
            let new_line = suffix_string
            " add the newly bookmarked item to the favorites list
            call add(g:coloroll_favorites[a:mode], curr_choice)
        else
            let new_line = no_suffix_string
            " remove the item from the bookmarks
            let l:del_idx = index(g:coloroll_favorites[a:mode], curr_choice)
            call remove(g:coloroll_favorites[a:mode], l:del_idx)
        endif
        " save fo file
        call coloroll#save_json(g:coloroll_config_file) 
        " update the content of the buffer
        let g:choice_buff_list[l:choice_idx] = new_line
        " update the popup with the updated buffer
        call popup_settext(a:id, g:choice_buff_list)
    elseif a:key == "d"
        " toggle dark/light
        " execute("set updatetime=".g:coloroll__updatetime_value)
        " set updatetime=1
        let &bg=(&bg=='light'?'dark':'light')
        " let g:coloroll__updatetime_value = &updatetime
        " set updatetime=1000

    " elseif a:key == "B"
    "     " execute("call " . l:apply_func . "(\"". g:coloroll__last_used .   "\", v:false)")
    "     call popup_close(a:id, -1)
    "     if a:mode == 
    "     call coloroll#SelectorMenu(a:mode, choice_list)
    "     " restore listening to colorscheme changes events
    "     " let g:coloroll__event_monitoring = 1
    "     " restore original updatetime before the call
    "     " execute("set updatetime=".g:coloroll__updatetime_value)

    "     let line_content = g:choice_buff_list[getcurpos(a:id)[1] - 1]
    "     " get current line
    "     " check if bookmark suffix is present or not (set a variable)
    "     " update suffix (toggle "*")
    "     " update bookmark list (add/remove)
    "     execute("call " . l:apply_func . "(". line_content  .  ", v:false)")
    elseif a:key == "h"
        call coloroll#HelpMenu() 
    elseif a:key == "\<CursorHold>"
        return v:true
    endif
endfunc


func! coloroll#SelectorMenu(mode='color', choice_list=v:null )
    " mode:   color[scheme], [airline]theme
    " choice_list    list of options to choose from
    if a:mode == 'color' 
        let l:callback_func = "coloroll#ColorCallback"
        let l:last_item = execute("colorscheme")[1:]
        let l:title_text = " Select color scheme [current:". l:last_item . "] "
        if a:choice_list isnot v:null
            let l:pool = a:choice_list
        else
            let l:pool = getcompletion('', 'color')
        endif
    elseif a:mode == 'theme'  
        if g:coloroll_airline_found == 0
            coloroll#ColorollError("[WARNING] AirLine theme requested but Arline does not appear to be installed. ")
            return v:false
        endif
        let l:last_item = execute("AirlineTheme")[1:] 
        let l:callback_func = "coloroll#ThemeCallback"
        let l:title_text = " Select theme (current: ". l:last_item . ") "
        if a:choice_list isnot v:null
            let l:pool = a:choice_list
        else
            let l:pool = coloroll#get_airline_themes()
        endif
    endif
    " modify the prefered list items to show the bookmark suffix
    let g:choice_buff_list = []
    let l:last_item_idx = -1
    " echom "strwidth:" .       strwidth(g:coloroll_favorite_mark)
    " echom "strlen:" .       strlen(g:coloroll_favorite_mark)
    " echom "len:" .       len(g:coloroll_favorite_mark)
    " echom "strdisplaywidth:"  .       strdisplaywidth(g:coloroll_favorite_mark)
    " echom "strchars::" .       strchars(g:coloroll_favorite_mark)
    for item in l:pool
        if item == l:last_item
            let l:last_item_idx = index(l:pool, l:last_item)
        endif
        if index(g:coloroll_favorites[a:mode], item) != -1
            let tag = g:coloroll_favorite_mark
        else
            let tag =  repeat(" ", strwidth(g:coloroll_favorite_mark))
        endif
        call add(g:choice_buff_list, tag . item)
    endfor 
    " temporarily reduce updatetime value to prevent cursor flickering
    let g:coloroll__updatetime_value = &updatetime
    set updatetime=1000
    " create the selection menu and store the window id
    let s:selection_winid =  popup_create(g:choice_buff_list, #{
        \   title: l:title_text,
        \   pos: 'center',
        \   cursorline: 1,
        \   highlight: 'Question',
        \   borderchars : g:coloroll_borderchars,
        \   close: 'click',
        \   border: [1, 1, 1, 1],
        \   maxheight: &lines - &cmdheight -10,
        \   minheight: 5,
        \   drag: v:true,
        \   moved: [0, 0, 0],
        \   mousemoved: [0, 0, 0],
        \   filter: l:callback_func,
        \})
        " \   zindex: 10,
    " check where to move the cursor
    if l:last_item_idx != -1
        " the current item is in the list, move the cursor to itx index
        let l:last_item_idx += 1
        call win_execute(s:selection_winid, 'normal! '. l:last_item_idx .'gg')
    else
        " the current item is not in the list, call the first item of the list
        execute("call " . l:callback_func . "(\"". l:pool[0].  "\", v:false)")
    endif
endfunc

func! coloroll#HelpMenu()
    " open a new popup with the key bindings
    " TODO this function should disable andvre-enabke events on the menu
    " selector
    let l:content = ["Up/Down\t move cursor up and down", "<CR>\t accept color"] 
    call popup_create(l:content, #{close : 'click', zindex: 20})    
endfunc

function! coloroll#ColorollError(message)
    echohl Error
    echom "Coloroll: " . a:message
    echohl None
endfunction


