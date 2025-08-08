#!/bin/bash

TMOD_LANGUAGE=${TMOD_LANGUAGE:-"en-US"}

if [ "$TMOD_LANGUAGE" == "en-US" ]; then
  export CMD_SAY="say"
  export CMD_SAVE="save"
  export CMD_EXIT="exit"
  export MSG_SAVE="The World has been saved."
fi

if [ "$TMOD_LANGUAGE" == "zh-Hans" ]; then
  export CMD_SAY="说"
  export CMD_SAVE="保存"
  export CMD_EXIT="退出"
  export MSG_SAVE="世界已保存。"
fi
