# LLXPRT - AI Provider CLI Manager

## Project Description

LLXPRT is a Command Line Interface (CLI) tool designed to streamline the management of multiple AI providers, such as Google Gemini and Anthropic Claude. This project provides a secure environment for interacting with these services, ensuring sensitive information is protected and file access is restricted.

## Key Features

*   **Secure Environment Variables:** Protects sensitive API keys and other credentials stored in `.env` files from unauthorized access by Large Language Models (LLMs).
*   **Restricted File Access:** Ensures that LLMs and other components only have access to the designated project directory, preventing broader system exposure.
*   **Dockerized Setup:** Provides a consistent and isolated development and execution environment using Docker and Docker Compose.
*   **Multi-Provider Support:** Manages multiple AI providers through a unified interface.
*   **Sandboxed Execution:** Runs AI agents in a controlled environment with limited system access.

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

*   **Docker** (version 20.10 or later)
*   **Docker Compose** (version 2.0 or later)
*   **Git** (for cloning the repository)
*   **Bash shell** (for running setup scripts)

### Installation and Setup

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd llxprt
    ```

2.  **Set up environment variables:**
    Create a `.env` file in the project root (use `.env.sample` as a template if available):
    ```bash
    cp .env.sample .env  # If sample exists
    # Edit .env with your API keys and configuration
    ```

3.  **Make scripts executable:**
    ```bash
    chmod +x start-llxprt.sh set_private_files.sh llxprt-terminal-script.sh
    ```

4.  **Run the setup script:**
    ```bash
    ./llxprt-terminal-script.sh /path/to/your/project
    ```
    Or directly:
    ```bash
    ./start-llxprt.sh /path/to/your/project ai_user ai_group
    ```

5.  **Start the container:**
    The script will automatically build and start the Docker container. Wait for the container to be ready.

## Usage

Once the container is running, you can interact with LLXPRT:

### Basic Commands

*   **Start an interactive session:**
    ```bash
    docker exec -it ai-agents-container bash
    ```

*   **Run LLXPRT commands:**
    Inside the container, use the `llxprt` command:
    ```bash
    llxprt --help
    ```

*   **List available AI providers:**
    ```bash
    llxprt providers list
    ```

*   **Configure a provider:**
    ```bash
    llxprt providers configure <provider-name>
    ```

### Managing AI Sessions

*   **Start a new AI agent session:**
    ```bash
    llxprt session start --provider <provider-name>
    ```

*   **List active sessions:**
    ```bash
    llxprt session list
    ```

*   **Stop a session:**
    ```bash
    llxprt session stop <session-id>
    ```

### File Management

*   **View project files:**
    ```bash
    llxprt files list
    ```

*   **Read a file:**
    ```bash
    llxprt files read <file-path>
    ```

## Project Structure

```
/app/project/
├── .dockerignore          # Docker ignore patterns
├── .env                   # Environment variables (protected)
├── .gitignore            # Git ignore patterns
├── docker-compose.yml    # Docker Compose configuration
├── Dockerfile            # Docker build instructions
├── llxprt-terminal-script.sh  # Main terminal script
├── readme.md             # This documentation
├── set_private_files.sh  # Script to protect sensitive files
├── start-llxprt.sh       # Startup script
└── .llxprt-config/       # LLXPRT configuration directory
    ├── oauth/            # OAuth credentials
    ├── profiles/         # User profiles
    ├── prompts/          # AI prompt templates
    ├── provider_accounts.json  # Provider configurations
    ├── settings.json     # Application settings
    ├── tmp/              # Temporary files
    └── todos/            # Task management
```

## Security Features

### File Protection
- `.env` files are automatically protected using Linux ACLs
- Only authorized users/groups can access sensitive files
- AI agents run with restricted file system permissions

### Container Security
- Read-only filesystem by default
- Non-root user execution
- Network isolation with host mode only when needed
- Volume mounts with proper SELinux/AppArmor labels

## Troubleshooting

### Common Issues

1. **Permission denied errors:**
   - Ensure your user is in the `docker` group
   - Check that `.env` files have correct permissions

2. **Container fails to start:**
   - Check Docker daemon is running: `sudo systemctl status docker`
   - Verify Docker Compose version: `docker compose version`

3. **LLXPRT command not found:**
   - Ensure container is running: `docker ps`
   - Check if installation completed successfully

### Logs and Debugging

*   **View container logs:**
    ```bash
    docker logs ai-agents-container
    ```

*   **Check container status:**
    ```bash
    docker ps -a | grep ai-agents-container
    ```

*   **Restart the container:**
    ```bash
    docker compose restart
    ```

## Development

### Building from Source

1. **Build the Docker image:**
   ```bash
   docker build -t llxprt:latest .
   ```

2. **Run tests:**
   ```bash
   docker run --rm llxprt:latest npm test
   ```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues, questions, or feature requests:
- Open an issue on GitHub
- Check the documentation
- Review existing issues for similar problems

---

**Note:** Always keep your `.env` files secure and never commit them to version control. Use `.env.sample` files for template configurations.