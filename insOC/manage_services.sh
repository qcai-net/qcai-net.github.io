#!/bin/bash

# OpenClaw Service Manager
# Usage: ./manage_services.sh [start|stop|restart|status]

ACTION=$1
GATEWAY_PLIST="$HOME/Library/LaunchAgents/com.openclaw.gateway.plist"
LLM_PLIST="$HOME/Library/LaunchAgents/com.openclaw.llmserver.plist"

case $ACTION in
    start)
        echo "Starting OpenClaw services..."
        launchctl load -w "$LLM_PLIST" 2>/dev/null
        launchctl load -w "$GATEWAY_PLIST" 2>/dev/null
        ;;
    stop)
        echo "Stopping OpenClaw services..."
        launchctl unload -w "$GATEWAY_PLIST" 2>/dev/null
        launchctl unload -w "$LLM_PLIST" 2>/dev/null
        # Force kill any remaining processes just in case
        pkill -f "openclaw gateway"
        pkill -f "omlx serve"
        ;;
    restart)
        $0 stop
        sleep 2
        $0 start
        ;;
    status)
        echo "Checking service status..."
        launchctl list | grep openclaw
        echo "Port 18789 (Gateway): $(lsof -i :18789 | grep LISTEN || echo 'Not Listening')"
        echo "Port 1234 (LLM): $(lsof -i :1234 | grep LISTEN || echo 'Not Listening')"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac
