detect_os() {
    case "$(uname -s)" in
        Linux*)     kernel_name="Linux";;
        Darwin*)    kernel_name="macOS";;
        CYGWIN*)    kernel_name="Cygwin";;
        MINGW*)     kernel_name="MinGW";;
        *)          kernel_name="unknown";;
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
    if ! command -v choco &> /dev/null; then
        echo "Installing Chocolatey..."
        powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
    else
        echo "Chocolatey is already installed."
    fi
}

install_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Homebrew is already installed."
    fi
}

install_git() {
    if ! command -v git &> /dev/null; then
        echo "Installing Git..."
        case $1 in
            "Ubuntu"|"Debian"|"WSL")
                sudo apt update
                sudo apt install -y git
                ;;
            "CentOS"|"RHEL"|"Fedora")
                sudo dnf update
                sudo dnf install -y git
                ;;
            "macOS")
                install_homebrew
                brew install git
                ;;
            "Windows (Chocolatey)")
                install_chocolatey
                choco install git -y
                ;;
            "Windows (Winget)")
                winget install -e --id Git.Git
                ;;
        esac
    else
        echo "Git is already installed."
    fi
}

install_optional_tools() {
    read -p "Do you want to install Node.js? (y/n) " install_node
    if [[ $install_node == "y" ]]; then
        if ! command -v node &> /dev/null; then
            echo "Installing Node.js..."
            case $1 in
                "Ubuntu"|"Debian"|"WSL")
                    sudo apt install -y nodejs npm
                    ;;
                "CentOS"|"RHEL"|"Fedora")
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

    read -p "Do you want to install Visual Studio Code? (y/n) " install_vscode
    if [[ $install_vscode == "y" ]]; then
        if ! command -v code &> /dev/null; then
            echo "Installing Visual Studio Code..."
            case $1 in
                "Ubuntu"|"Debian"|"WSL")
                    sudo apt install -y code
                    ;;
                "CentOS"|"RHEL"|"Fedora")
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

echo "Detecting your operating system..."
detect_os
echo "If the detected OS is incorrect, please select your OS manually from the list below:"
echo "1. Ubuntu/Debian"
echo "2. CentOS/RHEL/Fedora"
echo "3. macOS"
echo "4. Windows Subsystem for Linux (WSL)"
echo "5. Native Windows (using Chocolatey)"
echo "6. Native Windows (using Winget)"
read -p "Enter your choice (1/2/3/4/5/6) or press Enter to accept the detected OS: " os_choice

if [[ -z "$os_choice" ]]; then
    case $OS in
        "Ubuntu/Debian")
            os_choice=1
            ;;
        "Fedora"|"CentOS")
            os_choice=2
            ;;
        "macOS")
            os_choice=3
            ;;
        "Windows (using Git Bash)")
            read -p "Are you using WSL or native Windows? (w/n): " wn_choice
            if [[ $wn_choice == "w" ]]; then
                os_choice=4
            else
                read -p "Do you prefer to use Chocolatey or Winget? (c/w): " cw_choice
                if [[ $cw_choice == "c" ]]; then
                    os_choice=5
                else
                    os_choice=6
                fi
            fi
            ;;
        *)
            echo "Unable to determine OS, please select manually."
            read -p "Enter your choice (1/2/3/4/5/6): " os_choice
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
install_git $os
install_optional_tools $os

echo "Environment setup is complete. Press any key to continue."
read -p ""