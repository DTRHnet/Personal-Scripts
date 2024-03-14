#!/usr/bin/env bash

_KEYFILE_=
_TTL_=14000
_LASTFUNC_=

declare -A srv=(['MEDIA']='user@host' ['WEB']='user@host' ['VPS']='user@host')

function chkDuplicates() { echo "$(screen -ls | grep -i $1)" | wc -l; }

function init() {

  local x=0; local y=0; local z=0 
  _LASTFUNC_="${FUNCNAME}"

  echo -e "$1\n"
  echo -en "\tChecking for existing agent.. "
  if [ ! $(echo "$SSH_AGENT_PID") ]; then eval "$(ssh-agent -s)" >/dev/null 
    echo -e "Agent started with PID $SSH_AGENT_PID" && echo -e "Adding $_KEYFILE_ to agent..\n" 
    ssh-add -t ${_TTL_} ${_KEYFILE_}         
  else
    echo -e "Agent is running under pid $SSH_AGENT_PID"
  fi        

  # TODO: Loop this properly with the array for efficiency, this works though
  x=$(chkDuplicates MEDIA) 
  y=$(chkDuplicates WEB) 
  z=$(chkDuplicates VPS) 

  echo -e "\n$(date +%d-%m-%y) - INITIALIZE SSH SCREENS -----------------------\n"
  screen -dmS MEDIA$x ssh ${srv[MEDIA]}
  screen -dmS WEB$y ssh ${srv[WEB]}
  screen -dmS VPS$z ssh ${srv[VPS]}; sleep 1
  screen -ls 
}

main() {
  init "$(echo $(date +%d-%m-%y) - CONFIGURING SSH AGENT -----------------------)"
}  

main  
