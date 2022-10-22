# #!/usr/bin/env bash
HISTORY=$HOME/.local/bin/historyQueryCht
languages=`echo "lua go golang cpp c typescript nodejs js ruby rails python psql sql python3 bash html javascript" | tr ' ' '\n'`  
core_utils=`echo "xargs find mv sed awk tr tar" | tr ' ' '\n'`

selected=`printf "$languages\n$core_utils" | fzf`
if [ -z $selected ]; then
  read -p "Enter: " selected
fi

if echo $languages | grep -qs $selected; then
    while [ : ];
    do
      query=$(rlwrap -H $HISTORY bash -c 'read -p "Query: " REPLY && echo $REPLY')
      query=`echo $query | tr ' ' '+'`
      tmux neww bash -c "echo \"curl cht.sh/$selected/$query/\" & curl cht.sh/$selected/$query & while [ : ]; do sleep 1; done"
    done
elif echo $core_utils | grep -qs $selected;
then
    while [ : ];
    do
      query=$(rlwrap -H $HISTORY bash -c 'read -p "Query: " REPLY && echo $REPLY')
      query=`echo $query | tr ' ' '+'`
      echo "curl -s cht.sh/$selected~$query | less"
      tmux neww bash -c "curl -s cht.sh/$selected~$query | less"
    done
else
    while [ : ];
    do
      query=$(rlwrap -H $HISTORY bash -c 'read -p "Query: " REPLY && echo $REPLY')
      if [ -z $query ]; then
        tmux neww bash -c "curl -s cht.sh/$selected | less"
      else
        query=`echo $query | tr ' ' '+'`
        tmux neww bash -c "curl -s cht.sh/$selected+$query | less"
      fi
    done
fi
