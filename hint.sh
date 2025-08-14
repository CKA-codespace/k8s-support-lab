#!/bin/bash

choose_tier() {
    local tier="$1"
    
    if [ -n "$tier" ]; then
        case "$tier" in
            "rookie")
                export LAB_TIER=rookie
                echo "export LAB_TIER=rookie" >> ~/.bashrc
                echo "LAB_TIER set to: rookie"
                echo "You'll receive detailed step-by-step guidance."
                ;;
            "pro")
                export LAB_TIER=pro
                echo "export LAB_TIER=pro" >> ~/.bashrc
                echo "LAB_TIER set to: pro"
                echo "You'll receive concise instructions and terse hints."
                ;;
            *)
                echo "Invalid tier: $tier"
                echo "Usage: ./hint.sh choose-tier [rookie|pro]"
                exit 1
                ;;
        esac
    else
        echo "Choose your experience level:"
        echo "1) Rookie - Step-by-step guidance with progressive hints"
        echo "2) Pro - Concise instructions with terse hints"
        echo
        read -p "Enter your choice (1 or 2): " choice
        
        case $choice in
            1)
                export LAB_TIER=rookie
                echo "export LAB_TIER=rookie" >> ~/.bashrc
                echo "LAB_TIER set to: rookie"
                echo "You'll receive detailed step-by-step guidance."
                ;;
            2)
                export LAB_TIER=pro
                echo "export LAB_TIER=pro" >> ~/.bashrc
                echo "LAB_TIER set to: pro"
                echo "You'll receive concise instructions and terse hints."
                ;;
            *)
                echo "Invalid choice. Please run './hint.sh choose-tier' again."
                exit 1
                ;;
        esac
    fi
}

if [ "$1" = "choose-tier" ]; then
    choose_tier "$2"
else
    echo "Usage: ./hint.sh choose-tier [rookie|pro]"
    echo "This script helps you set your experience level for the labs."
fi