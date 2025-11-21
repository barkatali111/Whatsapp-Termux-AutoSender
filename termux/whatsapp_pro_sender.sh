#!/bin/bash

MY_NUMBER="+923052199342"
PACKAGE_NAME="com.whatsapp"
SERVICE_NAME=".MessageService"
LOG_FILE="$HOME/whatsapp_sent.log"

send_message() {
    local RECEIVER="$1"
    local MSG="$2"

    am startservice -n "$PACKAGE_NAME/$SERVICE_NAME" \
        -e RECEIVER "$RECEIVER" \
        -e MESSAGE "$MSG"

    if [ $? -eq 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') | SENT to $RECEIVER | $MSG" >> "$LOG_FILE"
        echo "✅ Message sent to $RECEIVER"
    else
        echo "❌ Failed to send to $RECEIVER"
    fi
}

send_csv_messages() {
    local FILE="$1"
    if [ ! -f "$FILE" ]; then
        echo "❌ CSV file not found!"
        return
    fi
    echo "Reading messages from $FILE..."
    while IFS=',' read -r RECEIVER MSG; do
        if [ -n "$RECEIVER" ] && [ -n "$MSG" ]; then
            send_message "$RECEIVER" "$MSG"
            sleep $((RANDOM % 3 + 1))
        fi
    done < "$FILE"
    echo "✅ CSV complete!"
}

send_json_messages() {
    local FILE="$1"
    if [ ! -f "$FILE" ]; then
        echo "❌ JSON file not found!"
        return
    fi
    for row in $(jq -c '.[]' "$FILE"); do
        RECEIVER=$(echo "$row" | jq -r '.number')
        MSG=$(echo "$row" | jq -r '.message')
        send_message "$RECEIVER" "$MSG"
        sleep $((RANDOM % 3 + 1))
    done
    echo "✅ JSON complete!"
}

while true; do
    echo "======================================="
    echo " Whatsapp Pro Auto Message Sender"
    echo "======================================="
    echo "Your Number: $MY_NUMBER"
    echo
    echo "1) Send single message"
    echo "2) Send from CSV"
    echo "3) Send from JSON"
    echo "4) View log"
    echo "5) Exit"
    echo
    read -p "Choose an option: " choice

    case "$choice" in
        1)
            read -p "Receiver number: " RECEIVER
            read -p "Message: " MSG
            send_message "$RECEIVER" "$MSG"
            read -p "Press Enter..."
            ;;
        2)
            read -p "CSV file path: " FILE
            send_csv_messages "$FILE"
            read -p "Press Enter..."
            ;;
        3)
            read -p "JSON file path: " FILE
            send_json_messages "$FILE"
            read -p "Press Enter..."
            ;;
        4)
            cat "$LOG_FILE"
            read -p "Press Enter..."
            ;;
        5)
            exit 0
            ;;
        *)
            echo "Invalid option!"
            ;;
    esac
    echo
done
