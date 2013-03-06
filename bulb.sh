#!/bin/bash

BULB="http://127.0.0.1:8000"

bold=`tput bold`
normal=`tput sgr0`

PYTHON_LIST=$(cat <<PYTHON
for elem in raw:
  print '#'*20
  for label in elem:
    print '|',label,':',elem[label]
PYTHON
)

PYTHON_LIST_COMPACT=$(cat <<PYTHON
for elem in raw:
  str = ''
  for label in elem:
    str += "[%s]=%s " % (label,elem[label])
  print '|',str
PYTHON
)

if [ $# -lt 3 -a "$1" = "list" ]; then
  raw=$(curl -s -H "Accept: application/json" "$BULB/idea/")
  if [ $# -eq 2 -a "$2" = "compact" ]
  then
    echo -e "raw=$raw\n$PYTHON_LIST_COMPACT" | python
  else
    echo -e "raw=$raw\n$PYTHON_LIST" | python
  fi

elif [ $# -lt 3 -a "$1" = "create" ]; then
  if [ $# -eq 2 ]; then
    raw=$(curl -s -X "POST" -H "Accept: application/json" -d "$2" -H "Content-Type: application/json" "$BULB/idea/")
  else
    read -p "Title: " title
    raw=$(curl -s -X "POST" -H "Accept: application/json" -d "{\"title\":\"$title\"}" -H "Content-Type: application/json" "$BULB/idea/")
  fi
  python -c "raw=$raw;print $raw;print 'Stored:',raw['id']"

elif [ $# -eq 2 -a "$1" = "get" ]; then
  raw=$(curl -s -H "Accept: application/json" "$BULB/idea/$2/")
  echo -e "raw=$raw\n$PYTHON_LIST" | python

elif [ $# -eq 3 -a "$1" = "connect" ]; then
  raw=$(curl -s -X "POST" -H "Accept: application/json" -d "{\"neighbour\":\"$3\"}" -H "Content-Type: application/json" "$BULB/idea/$2/neighbours/")

elif [ $# -lt 4 -a "$1" = "neighbours" ]; then
  raw=$(curl -s -H "Accept: application/json" "$BULB/idea/$2/neighbours/")
  if [ $# -eq 3 -a "$3" = "compact" ]
  then
    echo -e "raw=$raw\n$PYTHON_LIST_COMPACT" | python
  else
    echo -e "raw=$raw\n$PYTHON_LIST" | python
  fi

elif [ $# -eq 2 -a "$1" = "delete" ]; then
  read -p "Are you sure you want to delete $2? (y/n)" answer
  while [ "$answer" != "y" -a "$answer" != "n" ]; do
    echo -e "${bold}You need to answer 'y' or 'n'.$normal"
    read -p "Are you sure you want to delete $2? (y/n) " answer
  done
  if [ "$answer" == "y" ]; then
    raw=$(curl -s -X "DELETE" -H "Accept: application/json" "$BULB/idea/$2/")
  else
    echo -e "Delete ${bold}canceled${normal}!"
  fi

else
  echo "Usage:"
  echo -e "  $0 ${bold}list${normal} [compact]"
  echo -e "  $0 ${bold}create${normal} [raw_json]"
  echo -e "  $0 ${bold}get${normal} ideaId"
  echo -e "  $0 ${bold}connect${normal} ideaId1 ideaId2"
  echo -e "  $0 ${bold}neighbours${normal} [compact]"
  echo -e "  $0 ${bold}delete${normal} ideaId"
fi
