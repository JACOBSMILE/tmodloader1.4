#!/bin/sh

# This file will send input from the docker exec to the console.
tmux send-keys "$1" Enter