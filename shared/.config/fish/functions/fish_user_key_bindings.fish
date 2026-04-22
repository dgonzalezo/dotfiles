function fish_user_key_bindings
  fish_vi_key_bindings
  # peco
  bind -M insert \cr peco_select_history # Bind for peco select history to Ctrl+R
  bind -M insert \cf peco_change_directory # Bind for peco change directory to Ctrl+F

  # vim-like
 # bind -M insert \cl forward-char

  # prevent iterm2 from closing when typing Ctrl-D (EOF)
 # bind -M insert \cd delete-char
end
