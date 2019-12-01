# TODO:
# - [x] Keyboard shortcuts => using "zle -N function" and "bindkey code function"
# - [x] Insert selected line in current line => zle -U
# - [x] Get content of current line as history filter => $BUFFER
# - [x] Disable error message on "which" => was silly bug
# - [x] Gather history
# - [ ] Show in popup


_mistory_check_dialog() {
  which dialog &> /dev/null
  if [ $? -ne 0 ]
  then
    echo "Error: 'dialog' utility not found in PATH"
    return 1
  else
    return 0
  fi
}

_mistory_dialog() {
  local defitem=$1
  shift
  #TODO use "tput cols" and "tput lines" to maximize dialog size
  dialog --keep-tite --title "History" --default-item $defitem --menu "" 20 70 15 $@
}

_mistory_main() {
  local history_array
  _mistory_check_dialog || return
  # Multiline to array: https://unix.stackexchange.com/a/29748
  history_array=("${(@f)$(history | grep "$BUFFER")}")
  zle kill-whole-line
  _mistory_dialog $history_array
  #echo $hist
  #zle -U "You were typing <$wastyping>, right?"
  #zle accept-line
}


zle -N _mistory_main
bindkey "^[[5~" _mistory_main


#----- Testing stuff -----

_mistory_split_history_line() {
  match=""
  echo "Testing <$1>"
  [[ $1 =~ '^[ ]*([0-9]+)[ ]+(.+)$' ]]
  echo "Num: <$match[1]>"
  echo "Text: <$match[2]>"
}

mistory_array_manipulation() {
  # Define array
  a=(pim pam pum haha)
  # Add element to array
  a+=(bum)
  # Loop array
  for e in $a; do echo $e; done
  # Index from start
  echo $a[1]
  # Index from end
  echo $a[-1]
}

mistory_test() {
  local history_array dialog_items
  history_array=("${(@f)$(history | grep dialog)}")
  #echo $history_array
  dialog_items=()
  for history_line in $history_array
  do
    [[ $history_line =~ '^[ ]*([0-9]+)[ ]+(.+)$' ]] && \
      dialog_items+=($match[1]) && dialog_items+=($match[2])
  done
  _mistory_dialog $dialog_items[-2] $dialog_items
  #for item in $dialog_items; do echo $item; done
  #echo $dialog_items
  # local line result
  # line="  560  git commit -m \"Initial version\""
  # _mistory_split_history_line $line
}


