#!/bin/bash

```bash
# Set your Docker Hub credentials
USERNAME="vignan"
PASSWORD="your_password_here"  # Replace with your Docker Hub password

# Authenticate and get JWT token
TOKEN=$(curl -s -H "Content-Type: application/json" \
    -X POST -d "{\"username\": \"$USERNAME\", \"password\": \"$PASSWORD\"}" \
    https://hub.docker.com/v2/users/login/ | jq -r .token)

# Get list of repositories
REPOS=$(curl -s -H "Authorization: JWT $TOKEN" \
    https://hub.docker.com/v2/repositories/$USERNAME/?page_size=100 | jq -r '.results[].name')

# Loop through and delete each repository
for repo in $REPOS; do
  echo "Deleting repository: $repo"
  curl -s -X DELETE -H "Authorization: JWT $TOKEN" \
    https://hub.docker.com/v2/repositories/$USERNAME/$repo/
done

echo "All repositories deleted."
```
# Docker Hub Repository Cleanup Script

This script automates the process of deleting all repositories under a specified Docker Hub account.

## Prerequisites

1. **Docker Hub Account**: Ensure you have a Docker Hub account with repositories you want to delete.
2. **`jq` Command-Line Tool**: This script uses `jq` to parse JSON responses. Install it using your package manager:
    - For Debian/Ubuntu: `sudo apt-get install jq`
    - For macOS: `brew install jq`

## Script Overview

The script performs the following steps:
1. Authenticates with Docker Hub using your username and password.
2. Retrieves a list of all repositories under your account.
3. Iterates through the list and deletes each repository.

## Usage

1. **Set Your Credentials**:
    - Replace `vignan` with your Docker Hub username.
    - Replace `your_password_here` with your Docker Hub password.

2. **Run the Script**:
    - Save the script to a file, e.g., `delete_repos.sh`.
    - Make the script executable: `chmod +x delete_repos.sh`.
    - Run the script: `./delete_repos.sh`.

3. **Output**:
    - The script will display the name of each repository as it is deleted.
    - Once all repositories are deleted, it will print: `All repositories deleted.`

## Notes

- **Caution**: This script will permanently delete all repositories under your account. Ensure you have backups or are certain about the deletion.
- **Security**: Avoid hardcoding sensitive credentials in the script. Consider using environment variables or a secure secrets manager.

## Example

```bash
USERNAME="your_username"
PASSWORD="your_password"

# Run the script
./delete_repos.sh
```

## Disclaimer

Use this script at your own risk. The author is not responsible for any unintended data loss or issues caused by this script.