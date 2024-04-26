#!/bin/bash

detect_os() {
    case "$(uname -s)" in
    Linux*) kernel_name="Linux" ;;
    Darwin*) kernel_name="macOS" ;;
    CYGWIN*) kernel_name="Cygwin" ;;
    MINGW*) kernel_name="MinGW" ;;
    *) kernel_name="unknown" ;;
    esac

    if [[ "$kernel_name" == "Linux" ]]; then
        if [[ -e /etc/debian_version ]]; then
            OS="Ubuntu/Debian"
        elif [[ -e /etc/fedora-release ]]; then
            OS="Fedora"
        elif [[ -e /etc/centos-release ]]; then
            OS="CentOS"
        else
            OS="Linux (other)"
        fi
    elif [[ "$kernel_name" == "macOS" ]]; then
        OS="macOS"
    elif [[ "$kernel_name" == "Cygwin" || "$kernel_name" == "MinGW" ]]; then
        OS="Windows"
    else
        OS="unknown"
    fi

    echo "Detected OS: $OS"
}

install_chocolatey() {
    if ! command -v choco &>/dev/null; then
        echo "Installing Chocolatey..."
        powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
    else
        echo "Chocolatey is already installed."
    fi
}

install_homebrew() {
    if ! command -v brew &>/dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Homebrew is already installed."
    fi
}

install_winget() {
    if ! command -v winget &>/dev/null; then
        echo "Installing Winget..."
        release_url=$(powershell -command "(Invoke-WebRequest -Uri 'https://github.com/microsoft/winget-cli/releases/latest').Links | Where-Object { $_.href -like '*Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.appxbundle*' } | Select-Object -ExpandProperty href")

        powershell -Command "Invoke-WebRequest -Uri '$release_url' -OutFile 'Microsoft.DesktopAppInstaller.appxbundle'"
        powershell -Command "Add-AppxPackage -Path 'Microsoft.DesktopAppInstaller.appxbundle'"

        rm -f Microsoft.DesktopAppInstaller.appxbundle
    else
        echo "Winget is already installed."
    fi
}

install_add_tool() {
    echo "Installing Required tools for $1"
    case $1 in
    "Ubuntu" | "Debian" | "WSL")
        sudo apt update
        ;;
    "CentOS" | "RHEL" | "Fedora")
        sudo dnf update
        ;;
    "macOS")
        read -r -p "This will install Homebrew, you do want to continue? (y/n): " homebrew_choice
        if [[ $homebrew_choice == "y" ]]; then
            install_homebrew
        fi
        ;;
    "Windows (Chocolatey)")
        read -r -p "This will install Chocolatey, you do want to continue? (y/n): " chocolatey_choice
        if [[ $chocolatey_choice == "y" ]]; then
            install_chocolatey
        fi
        ;;
    "Windows (Winget)")
        read -r -p "This will install Winget, you do want to continue? (y/n): " winget_choice
        if [[ $winget_choice == "y" ]]; then
            install_winget
        fi
        ;;
    esac
}

install_git() {
    read -r -p "Do you want to install Git? (y/n) " install_git
    if [[ $install_git == "y" ]]; then
        if ! command -v git &>/dev/null; then
            echo "Installing Git..."
            case $1 in
            "Ubuntu" | "Debian" | "WSL")
                sudo apt update
                sudo apt install -y git
                ;;
            "CentOS" | "RHEL" | "Fedora")
                sudo dnf update
                sudo dnf install -y git
                ;;
            "macOS")
                brew install git
                ;;
            "Windows (Chocolatey)")
                choco install git -y
                ;;
            "Windows (Winget)")
                winget install -e --id Git.Git
                ;;
            esac
        else
            echo "Git is already installed."
        fi
    fi
}

install_optional_tools() {
    read -r -p "Do you want to install Node.js? (y/n) " install_node
    if [[ $install_node == "y" ]]; then
        if ! command -v node &>/dev/null; then
            echo "Installing Node.js..."
            case $1 in
            "Ubuntu" | "Debian" | "WSL")
                sudo apt install -y nodejs npm
                ;;
            "CentOS" | "RHEL" | "Fedora")
                sudo dnf install -y nodejs npm
                ;;
            "macOS")
                brew install node
                ;;
            "Windows (Chocolatey)")
                choco install nodejs -y
                ;;
            "Windows (Winget)")
                winget install -e --id OpenJS.NodeJS
                ;;
            esac
        else
            echo "Node.js is already installed."
        fi
    fi

    read -r -p "Do you want to install Visual Studio Code? (y/n) " install_vscode
    if [[ $install_vscode == "y" ]]; then
        if ! command -v code &>/dev/null; then
            echo "Installing Visual Studio Code..."
            case $1 in
            "Ubuntu" | "Debian" | "WSL")
                sudo apt install -y code
                ;;
            "CentOS" | "RHEL" | "Fedora")
                sudo dnf install -y code
                ;;
            "macOS")
                brew install --cask visual-studio-code
                ;;
            "Windows (Chocolatey)")
                choco install vscode -y
                ;;
            "Windows (Winget)")
                winget install -e --id Microsoft.VisualStudioCode
                ;;
            esac
        else
            echo "Visual Studio Code is already installed."
        fi
    fi
}

generate_ssh_key() {
    read -r -p "Enter your email for the SSH key: " email
    ssh_key_path="$HOME/.ssh/id_rsa"

    if [[ -f "$ssh_key_path" ]]; then
        echo "An SSH key already exists at $ssh_key_path."
        read -r -p "Do you want to overwrite it? (y/n): " overwrite
        if [[ $overwrite != "y" ]]; then
            echo "Keeping existing SSH key."
            return
        fi
    fi

    echo "Generating new SSH key..."
    ssh-keygen -t rsa -b 4096 -C "$email" -f "$ssh_key_path" -N ""

    case "$(uname -s)" in
    Linux*) pbcopy_command="xclip -selection clipboard" ;;
    Darwin*) pbcopy_command="pbcopy" ;;
    CYGWIN* | MINGW*) pbcopy_command="clip" ;;
    *) pbcopy_command="" ;;
    esac

    if [[ -n "$pbcopy_command" ]]; then
        cat "${ssh_key_path}.pub" | $pbcopy_command
        echo "SSH public key has been copied to clipboard."
    else
        echo "Clipboard support is not available on this system."
        echo "SSH public key:"
        cat "${ssh_key_path}.pub"
    fi
}

echo "Detecting your operating system..."
detect_os
echo "If the detected OS is incorrect, please select your OS manually from the list below:"
echo "1. Ubuntu/Debian"
echo "2. CentOS/RHEL/Fedora"
echo "3. macOS"
echo "4. Windows Subsystem for Linux (WSL)"
echo "5. Native Windows (using Chocolatey)"
echo "6. Native Windows (using Winget)"
read -r -p "Enter your choice (1/2/3/4/5/6) or press Enter to accept the detected OS: " os_choice

if [[ -z "$os_choice" ]]; then
    case $OS in
    "Ubuntu/Debian")
        os_choice=1
        ;;
    "Fedora" | "CentOS")
        os_choice=2
        ;;
    "macOS")
        os_choice=3
        ;;
    "Windows (using Git Bash)")
        read -r -p "Are you using WSL or native Windows? (w/n): " wn_choice
        if [[ $wn_choice == "w" ]]; then
            os_choice=4
        else
            read -r -p "Do you prefer to use Chocolatey or Winget? (c/w): " cw_choice
            if [[ $cw_choice == "c" ]]; then
                os_choice=5
            else
                os_choice=6
            fi
        fi
        ;;
    *)
        echo "Unable to determine OS, please select manually."
        read -r -p "Enter your choice (1/2/3/4/5/6): " os_choice
        ;;
    esac
fi

case $os_choice in
1)
    os="Ubuntu"
    ;;
2)
    os="CentOS"
    ;;
3)
    os="macOS"
    ;;
4)
    os="WSL"
    ;;
5)
    os="Windows (Chocolatey)"
    ;;
6)
    os="Windows (Winget)"
    ;;
*)
    echo "Invalid choice."
    exit 1
    ;;
esac

echo "You have selected: $os"
install_add_tool "$os"
install_git "$os"
install_optional_tools "$os"

read -r -p "Do you want to generate an SSH key? (y/n): " generate_key
if [[ $generate_key == "y" ]]; then
    generate_ssh_key
fi

echo "Environment setup is complete. Press any key to continue."
read -r -p ""
