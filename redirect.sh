#!/bin/bash

if [ ! -e "/dev/pts/0" ]; then
    echo "tty not enabled"
    exit 1
fi

if [ -e "/tmp/input" ]; then
    rm /tmp/input
fi

mkfifo /tmp/input

send_keys_to_tmux() {
    while IFS= read -r line; do
        tmux send-keys "$line" Enter
    done
}

send_keys_to_tmux < /tmp/input &

# Attempt to redirect input from the TTY to pipe
cat < /dev/pts/0 > /tmp/input