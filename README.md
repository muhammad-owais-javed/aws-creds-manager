# AWS Credentials Management Tools

A collection of scripts for managing AWS credentials on development machines.

## Contents

- `aws_setup.sh` - Configures AWS credentials and environment variables
- `aws_keys_validator.sh` - Validates AWS access keys
- `aws_secrets_cleaner.sh` - Removes AWS credentials and environment variables

## Setup

### Prerequisites

- AWS CLI installed
- Bash shell
- AWS IAM credentials with appropriate permissions

### Usage

#### Setting up AWS credentials

```bash
./aws_setup.sh
```

This script:
- Creates a secure AWS credentials directory
- Configures AWS credentials and region
- Sets up environment variables for the current session
- Optionally updates shell configuration files for persistence

#### Validating AWS keys

```bash
./aws_keys_validator.sh
```

This script:
- Prompts for AWS access and secret keys
- Validates the credentials against AWS
- Displays the validation result

#### Cleaning up AWS credentials

```bash
./aws_secrets_cleaner.sh
```

This script:
- Removes AWS credentials and configuration files
- Cleans environment variable references from shell configuration files
- Unsets AWS environment variables from the current session

## Security Features

- Credentials directory permissions set to 700 (user read/write/execute only)
- Credential files permissions set to 600 (user read/write only)
- Secret keys are not displayed when typed
- Credentials validated before storing
- Complete cleanup option to remove all traces of credentials


## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/newFeature`)
3. Commit your changes (`git commit -m 'Add some New Feature'`)
4. Push to the branch (`git push origin feature/newFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Muhammad Owais Javed

## Acknowledgments

- Special thanks to contributors and testers
