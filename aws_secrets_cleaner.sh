#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=== AWS Credentials Cleanup ===${NC}"
echo -e "${YELLOW}This script will remove AWS credentials and environment variables set by the setup script.${NC}"

read -p "Are you sure you want to remove all AWS credential settings? (y/n): " choice
if [[ ! "$choice" =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Cleanup canceled.${NC}"
    exit 0
fi

if [[ -d "$HOME/.aws" ]]; then
    echo -e "${YELLOW}Removing AWS credentials and configuration...${NC}"
    
    rm -f "$HOME/.aws/credentials" "$HOME/.aws/config" "$HOME/.aws/aws_env.sh"
    
    if [[ ! "$(ls -A $HOME/.aws)" ]]; then
        rm -rf "$HOME/.aws"
    else
        echo -e "${YELLOW}Note: $HOME/.aws directory not removed as it contains other files.${NC}"
    fi
    
    echo -e "${GREEN}AWS credentials and configuration files removed.${NC}"
else
    echo -e "${GREEN}No AWS credentials directory found.${NC}"
fi

for rc_file in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.bash_profile" "$HOME/.profile"; do
    if [[ -f "$rc_file" ]]; then
        echo -e "${YELLOW}Checking $rc_file for AWS environment settings...${NC}"
        
        temp_file=$(mktemp)
        
        grep -v "AWS Environment Variables" "$rc_file" | grep -v "source.*aws_env.sh" > "$temp_file"
        
        cp "$temp_file" "$rc_file"
        rm "$temp_file"
        
        echo -e "${GREEN}Removed AWS environment settings from $rc_file${NC}"
    fi
done

echo -e "${YELLOW}Unsetting AWS environment variables from current session...${NC}"
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_REGION

echo -e "${GREEN}AWS cleanup complete. All credential settings have been removed.${NC}"
echo -e "${YELLOW}Note: You may need to start a new shell session for all changes to take effect.${NC}"