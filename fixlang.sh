#!/bin/bash

TMOD_LANGUAGE=${TMOD_LANGUAGE:-"en-US"}

if [ "$TMOD_LANGUAGE" == "en-US" ]; then
  export CMD_SAY="say"
  export CMD_SAVE="save"
  export CMD_EXIT="exit"
  export MSG_SAVE="The World has been saved."
fi

if [ "$TMOD_LANGUAGE" == "de-DE" ]; then
  export CMD_SAY="Sage"
  export CMD_SAVE="speichern"
  export CMD_EXIT="verlassen"
  export MSG_SAVE="Die Welt wurde gerettet."
fi

if [ "$TMOD_LANGUAGE" == "it-IT" ]; then
  export CMD_SAY="di'"
  export CMD_SAVE="salva"
  export CMD_EXIT="esci"
  export MSG_SAVE="Il mondo è stato salvato."
fi

if [ "$TMOD_LANGUAGE" == "fr-FR" ]; then
  export CMD_SAY="dire"
  export CMD_SAVE="sauvegarder"
  export CMD_EXIT="quitter"
  export MSG_SAVE="Le monde a été sauvé."
fi

if [ "$TMOD_LANGUAGE" == "es-ES" ]; then
  export CMD_SAY="say"
  export CMD_SAVE="save"
  export CMD_EXIT="exit"
  export MSG_SAVE="El mundo ha sido salvado."
fi

if [ "$TMOD_LANGUAGE" == "ru-RU" ]; then
  export CMD_SAY="сказать"
  export CMD_SAVE="сохранить"
  export CMD_EXIT="выход"
  export MSG_SAVE="Мир спасён."
fi

if [ "$TMOD_LANGUAGE" == "zh-Hans" ]; then
  export CMD_SAY="说"
  export CMD_SAVE="保存"
  export CMD_EXIT="退出"
  export MSG_SAVE="世界已保存。"
fi

if [ "$TMOD_LANGUAGE" == "pt-BR" ]; then
  export CMD_SAY="say"
  export CMD_SAVE="save"
  export CMD_EXIT="exit"
  export MSG_SAVE="O mundo foi salvo."
fi

if [ "$TMOD_LANGUAGE" == "pl-PL" ]; then
  export CMD_SAY="say"
  export CMD_SAVE="save"
  export CMD_EXIT="exit"
  export MSG_SAVE="Świat został uratowany."
fi
