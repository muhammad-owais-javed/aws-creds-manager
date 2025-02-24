#!/bin/bash

GREEN="\e[32m"
RED="\e[31m"
BLUE="\e[34m"
YELLOW="\e[33m"
RESET="\e[0m"

echo -e "${BLUE}AWS Access Key Validation${RESET}"
echo -e "${YELLOW}---------------------------------${RESET}"

read -p "Enter AWS Access Key: " AWS_ACCESS_KEY_ID
read -s -p "Enter AWS Secret Access Key: " AWS_SECRET_ACCESS_KEY
echo -e "\n${YELLOW}Validating credentials...${RESET}"

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY

if aws sts get-caller-identity --query "Arn" --output text >/dev/null 2>&1; then
    echo -e "${GREEN}✔ AWS credentials are valid.${RESET}"
else
    echo -e "${RED}✖ Invalid AWS credentials. Please check your keys.${RESET}"
fi

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
