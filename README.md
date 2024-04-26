# Development Environment Setup Script

## Overview

This script automates the process of setting up a development environment across various operating systems. It detects your operating system and offers to install essential development tools, including Git, Node.js, and Visual Studio Code. The script is designed to simplify the initial configuration of development environments, making it easy to get started with minimal setup time.

## Key Features

- **Automatic OS Detection**: Automatically detects the operating system to streamline the setup process.
- **Conditional Installation**: Checks if essential tools like Git, Node.js, and Visual Studio Code are already installed and skips installation if they are present.
- **Customizable Tool Installation**: Offers optional installation of Node.js and Visual Studio Code after installing Git.
- **Support for Multiple Operating Systems**: Includes support for Ubuntu/Debian, CentOS/RHEL/Fedora, macOS, Windows Subsystem for Linux (WSL), and native Windows with Chocolatey or Winget.

## Prerequisites

Before running the script, make sure you have:

- Administrative or sudo privileges on your system.
- A stable internet connection to download necessary files.

## Installation

To use this script, follow these steps:

1. Clone the repository:

   ```
   git clone git@github.com:manuelc2209/template-react.git
   ```

2. Use the script
   ```
   ./setup.sh
   ```

The script will automatically detect your operating system and prompt you to confirm or select a different OS if the detection is incorrect. Follow the on-screen instructions to complete the setup of your development tools.

# Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are greatly appreciated.

# Fork the Project

- Create your Feature Branch (git checkout -b feature/FeatureName)
- Commit your Changes (git commit -m 'Add some Feature')
- Push to the Branch (git push origin feature/FeatureName)
- Open a Pull Request

# License

This project is licensed under the MIT License - see the LICENSE file for details.
