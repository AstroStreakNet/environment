#!/usr/bin/env bash

LOGFILE=$(date "+%Y-%m-%d-%H%M%S.log")
touch "logs/$LOGFILE"

# Function to check if tmux session exists
tmux_session_exists() {
    tmux has-session -t "$1" 2>/dev/null
}

# Function to run processes in tmux panes
run_in_tmux() {
    local session_name="$1"
    local logfile="$2"

    # Check if the tmux session exists
    if ! tmux_session_exists "$session_name"; then
        # If session doesn't exist, create a new one
        tmux new-session -d -s "$session_name"
    fi

    # Run the bot in a nix-shell in a tmux pane
    tmux send-keys -t "$session_name" "nix-shell ./astrobot/shell.nix --run 'python3 ./astrobot/main.py \"$logfile\"'" Enter

    # Split the window vertically and run webback in another pane
    tmux split-window -v -t "$session_name"
    tmux send-keys -t "$session_name" "tmux renamew services" Enter
    tmux send-keys -t "$session_name" "./backend/webback 2>&1 | tee -a \"$logfile\"" Enter
}

# Main
if [ -n "$TMUX" ]; then
    # If already in a tmux session, run processes directly
    run_in_tmux "$TMUX_PANE" "logs/$LOGFILE"
else
    # If not in tmux, create a new tmux session and run processes
    run_in_tmux "astronet" "logs/$LOGFILE"
    tmux attach-session -t astronet
fi

