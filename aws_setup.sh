#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' 

validate_input() {
    local input=$1
    local field_name=$2
    if [[ -z "$input" ]]; then
        echo -e "${RED}Error: $field_name cannot be empty.${NC}"
        return 1
    fi
    return 0
}

setup_directory() {
    local aws_dir="$HOME/.aws"
    if [[ ! -d "$aws_dir" ]]; then
        echo -e "${YELLOW}Creating AWS credentials directory...${NC}"
        mkdir -p "$aws_dir"
    fi
    chmod 700 "$aws_dir"
    echo -e "${GREEN}AWS credentials directory is set up securely.${NC}"
}

validate_aws_credentials() {
    echo -e "${YELLOW}Validating AWS credentials...${NC}"

    # Make sure that AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        echo -e "${RED}Error: AWS CLI is not installed. Please install it and try again.${NC}"
        return 1
    fi

    # Temporary environment variables for validation
    export AWS_ACCESS_KEY_ID="$1"
    export AWS_SECRET_ACCESS_KEY="$2"
    export AWS_REGION="$3"

    # Validating AWS credentials
    if aws sts get-caller-identity &> /dev/null; then
        echo -e "${GREEN}AWS credentials are valid.${NC}"
        return 0
    else
        echo -e "${RED}Error: Invalid AWS credentials. Please check and try again.${NC}"
        return 1
    fi
}

store_aws_config() {
    local access_key="$1"
    local secret_key="$2"
    local region="$3"
    local credentials_file="$HOME/.aws/credentials"
    local config_file="$HOME/.aws/config"

    cat > "$credentials_file" << EOF
[default]
aws_access_key_id = $access_key
aws_secret_access_key = $secret_key
EOF

    cat > "$config_file" << EOF
[default]
region = $region
output = json
EOF

    chmod 600 "$credentials_file" "$config_file"
    echo -e "${GREEN}AWS credentials and configuration have been stored securely.${NC}"

    local env_file="$HOME/.aws/aws_env.sh"
    cat > "$env_file" << EOF
export AWS_ACCESS_KEY_ID=$access_key
export AWS_SECRET_ACCESS_KEY=$secret_key
export AWS_REGION=$region
EOF
    chmod 600 "$env_file"
}

update_shell_rc() {
    local env_file="$HOME/.aws/aws_env.sh"
    local source_cmd="[ -f $env_file ] && source $env_file"
    local updated=false

    #Detect user's shell
    local shell_name=$(basename "$SHELL")
    
    # Updating rc file based on shell
    case "$shell_name" in
        bash)
            local bash_rc="$HOME/.bashrc"
            if [[ -f "$bash_rc" ]] && ! grep -q "source $env_file" "$bash_rc"; then
                echo "" >> "$bash_rc"
                echo "# AWS Environment Variables" >> "$bash_rc"
                echo "$source_cmd" >> "$bash_rc"
                updated=true
            fi
            ;;
        zsh)
            local zsh_rc="$HOME/.zshrc"
            if [[ -f "$zsh_rc" ]] && ! grep -q "source $env_file" "$zsh_rc"; then
                echo "" >> "$zsh_rc"
                echo "# AWS Environment Variables" >> "$zsh_rc"
                echo "$source_cmd" >> "$zsh_rc"
                updated=true
            fi
            ;;
    esac
    
    if [[ "$updated" == true ]]; then
        echo -e "${GREEN}Environment variables will be automatically loaded in new shell sessions.${NC}"
    else
        echo -e "${YELLOW}To load AWS environment variables in every new shell, add this line to your shell's rc file:${NC}"
        echo -e "  ${NC}$source_cmd${NC}"
    fi
}

# Main
echo -e "${GREEN}=== AWS Credentials Setup ===${NC}"
echo -e "${YELLOW}This script will configure AWS credentials for use with tools like Terraform and Ansible.${NC}"

setup_directory

# Checking if credentials are set in environment variables
if [[ -n "$AWS_ACCESS_KEY_ID" && -n "$AWS_SECRET_ACCESS_KEY" ]]; then
    echo -e "${YELLOW}AWS credentials detected in environment variables.${NC}"
    read -p "Do you want to use these existing AWS environment variables? (y/n): " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        AWS_REGION=${AWS_REGION:-$(aws configure get region 2>/dev/null)}
        if [[ -z "$AWS_REGION" ]]; then
            while true; do
                read -p "Enter AWS region (e.g., us-east-1): " AWS_REGION
                validate_input "$AWS_REGION" "AWS Region" && break
            done
        fi
        
        if validate_aws_credentials "$AWS_ACCESS_KEY_ID" "$AWS_SECRET_ACCESS_KEY" "$AWS_REGION"; then
            store_aws_config "$AWS_ACCESS_KEY_ID" "$AWS_SECRET_ACCESS_KEY" "$AWS_REGION"
            update_shell_rc
        else
            echo -e "${RED}Failed to validate credentials from environment variables.${NC}"
        fi
        exit 0
    fi
fi



while true; do
    read -p "Enter AWS IAM Access Key ID: " AWS_ACCESS_KEY_ID
    validate_input "$AWS_ACCESS_KEY_ID" "AWS Access Key ID" && break
done

while true; do
    read -s -p "Enter AWS IAM Secret Access Key: " AWS_SECRET_ACCESS_KEY
    echo  
    validate_input "$AWS_SECRET_ACCESS_KEY" "AWS Secret Access Key" && break
done

while true; do
    read -p "Enter AWS region (e.g., us-east-1): " AWS_REGION
    validate_input "$AWS_REGION" "AWS Region" && break
done

if validate_aws_credentials "$AWS_ACCESS_KEY_ID" "$AWS_SECRET_ACCESS_KEY" "$AWS_REGION"; then
    store_aws_config "$AWS_ACCESS_KEY_ID" "$AWS_SECRET_ACCESS_KEY" "$AWS_REGION"
    
    # Setting environment variables forcurrent session
    export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
    export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
    export AWS_REGION="$AWS_REGION"

    # Updating shell for persistence
    update_shell_rc
    
    echo -e "${GREEN}Setup complete. Your AWS tools are ready to use.${NC}"
    echo -e "${YELLOW}Environment variables have been set for this session.${NC}"
    echo -e "${YELLOW}For new sessions, source the environment file: ${NC}source $HOME/.aws/aws_env.sh"
else
    echo -e "${RED}Not saving invalid credentials. Please try again.${NC}"
    exit 1
fi