# vim-coloroll

A lazy Vim TUI for color [and Airline theme] selection

![image](https://user-images.githubusercontent.com/16327850/229337715-34ae7ec3-cc5f-4fcf-9a12-2e660ce043eb.png)

The plugin is essentially a glorified `popup_menu` with a lot of sugar on top
to make it more user friendly.  Each new command will open a `popup_menu`
showing a list of choices (colorschemes or Airline themes) and allows to
preview them by just selecting them moving the cursor. Once the selection is
made (`<Cr>`), the choice is applied and permanently saved for next sessions.

<!-- "  g:coloroll_force_colorscheme -->
<!-- "  g: coloroll_force_airlinetheme -->
<!-- "           override what's in the file -->
<!-- " -->
<!-- " -->

## Installation


Use your favorite plugin manager or copy/clone it in your ``.vim/autoload`` directory.
With Vim-plug:

    Plug 'ntropia2/vim-coloroll'

The plugin will install two new normal mode commands to preview and select colorschems
available in the current Vim installation:

    ColorollAllColors       " show menu with all colorschemes
    ColorollFavoriteColors  " show menu with favorite colorschemes only

Optionally, if the Airline plugin is installed, the following commands will be also available

    ColorollAllThemes       " show menu with all Airline themes available
    ColorollFavoriteThemes  " show menu with favorite Airline themes only

If Airline is not installed, an error message is printed when calling theme commands.

## Usage & Configuration

### Command keybindings

Keybindings for each command in normal mode can be specified as following:

    let g:coloroll_keymap_allcolors = "\<leader>0"
    let g:coloroll_keymap_favcolors = "\<leader>9"
    let g:coloroll_keymap_allthemes = "\<leader>8"
    let g:coloroll_keymap_favthemes = "\<leader>7"

### Menu key bindings

When a command is executd and the menu is visible, there are the following key
bindings available:

| key | description |
|---|---|
| \<Up\> / k | select line above |
| \<Down\> / j | select line below |
| \<PgUp\>  | select line +5 above |
| \<PgDown\>  | select line +5 below |
| \<CR\>  | accept current line and close the menu |
| \<Esc\> | close menu and restore previously active value |
| b | toggle favorite bookmark (see `g:coloroll_favorite_mark`) |
| \<Home\>  | select the first line in the menu |
| \<End\>  | select the last line in the menu |
| d | switch between dark and light color modes (note: this value is not saved) |
| h | show help menu (note: incomplete, not working)|


### Appearence

By default, the mark used for showing favorite choices (bookmarks) is `" > "`,
but it can be customized by specifying any number of characters and Unicode
symbols:

    let g:coloroll_favorite_mark = " > "
    let g:coloroll_favorite_mark = " --> "
    let g:coloroll_favorite_mark = "  ★   "
    let g:coloroll_favorite_mark = " 🙣   "  

The way Unicode characters are rendered depends mainly on your terminal and how
it prints multi-character symbols. The plugin will try to keep the spacing
consistent and ordered, but your mileage might vary considerably.


The appearence of the popup menu can be customized by passing a list  of  border
characters, which are the borderchars list that  is  passed  to  the  popup_menu
call, and characters need to be defined using the same  order  required  by  it:
top/right/bottom/left border; optionally it is possible to specify character  to
use for the topleft/topright/botright/botleft corner.

    let g:coloroll_borderchars = ['─', '│', '─', '│', '╭', '╮', '╯', '╰']


### Config file

In order to persist across sessions, the plugin saves the settings in the file
`[VIMRC_PATH]/config/coloroll.json`. If the directory does not exist, it will
be created automatically. The file path can be changed as following:
  
    let g:coloroll_config_file = "/path/to/custom/coloroll.json"


<!-- ## Special post commands -->

<!-- Optinionally, special commands can be executed after a specific colorscheme or Airline theme: -->

<!--     let g:coloroll_special_settings= {"color":{'ayu' : ["let ayucolor=\"dark\""]}, "theme":{}} -->

<!-- This part doesn't work yet! -->
