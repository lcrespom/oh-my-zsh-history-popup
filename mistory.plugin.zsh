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
  #TODO use "tput cols" and "tput lines" to maximize dialog size
  dialog --keep-tite --title "History" --menu "" 20 70 15 $@
}

_mistory_split_history_line() {
  match=""
  echo "Testing <$1>"
  [[ $1 =~ '^[ ]*([0-9]+)[ ]+(.+)$' ]]
  echo "Num: <$match[1]>"
  echo "Text: <$match[2]>"
  return "asdf"
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


mistory_test() {
  # local history_array
  # history_array=("${(@f)$(df | grep disk)}")
  # _mistory_dialog $history_array
  local line result
  line="  560  git commit -m \"Initial version\""
  result=(_mistory_split_history_line $line)
  echo "-$result-"
  # [[ $line =~ '^[ ]*([0-9]+)[ ]+(.+)$' ]]
  # echo "<$match[1]>"
  # echo "<$match[2]>"
  # match=""
}



zle -N _mistory_main
bindkey "^[[5~" _mistory_main