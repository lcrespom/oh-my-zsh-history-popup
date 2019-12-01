# TODO:
# - [x] Keyboard shortcuts => using "zle -N function" and "bindkey code function"
# - [x] Insert selected line in current line => zle -U
# - [x] Get content of current line as history filter => $BUFFER
# - [x] Disable error message on "which" => was silly bug
# - [x] Gather history
# - [x] Show in popup

# Regex for matching and splitting a history line in line number and history text.
_MISTORY_LINE_PATTERN='^[ ]*([0-9]+)\*?[ ]+(.+)$'


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
  # Check if `dialog` command is available, exit otherwise
  _mistory_check_dialog || return

  local history_array dialog_items
  # Get history lines matching text in prompt into an array
  # Multiline to array: https://unix.stackexchange.com/a/29748
  history_array=("${(@f)$(history | grep "$BUFFER")}")
  #TODO if error / array is empty, make error noise and exit

  # Build array of history line pairs (number, text)
  dialog_items=()
  for history_line in $history_array
  do
    [[ $history_line =~ $_MISTORY_LINE_PATTERN ]] && \
      dialog_items+=($match[1]) && dialog_items+=($match[2])
  done

  # Show dialog :-)
  local tmpfile=$(mktemp)
  _mistory_dialog $dialog_items[-2] $dialog_items 2> $tmpfile
  local dialog_return=$?
  local sel_number=$(cat $tmpfile)
  rm $tmpfile
  #TODO trap "rm -f $tempfile" 0 0 1 2 3 15

  # Display selection
  zle kill-whole-line
  zle accept-line
  #TODO if user did not press < OK >, exit but re-display buffer
  [[ $dialog_return -ne 0 ]] && return
  # Get history line from selected menu item number
  local sel_line=$(history $sel_number $sel_number)
  # Get only the text from the history line
  [[ $sel_line =~ $_MISTORY_LINE_PATTERN ]] && \
    zle -U $match[2]
}


zle -N _mistory_main
bindkey "^[[5~" _mistory_main
