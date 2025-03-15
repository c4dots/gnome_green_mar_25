#!/bin/bash
UPDATE_BACKGROUND=true
UPDATE_ZSH=true
INSTALL_PACKAGES=true
INSTALL_THEMES=true
INSTALL_ICONS=true
INSTALL_SEARCH_LIGHT=true
INSTALL_DING=true
INSTALL_TOP_BAR=true
INSTALL_DASH_TO_PANEL=true

for ARG in "$@"; do
  case $ARG in
    --no-zsh)
      UPDATE_ZSH=false
      ;;
    --no-themes)
      INSTALL_THEMES=false
      ;;
    --no-packages)
      INSTALL_PACKAGES=false
      ;;
    --no-icons)
      INSTALL_ICONS=false
      ;;
    --no-background)
      UPDATE_BACKGROUND=false
      ;;
    --no-search-light)
      INSTALL_SEARCH_LIGHT=false
      ;;
    --no-dash)
      INSTALL_DASH_TO_PANEL=false
      ;;
    --no-ding)
      INSTALL_DING=false
      ;;
    --help)
      echo ">> HELP"
      echo " | '--no-zsh': Disables the installation or update of ZShell."
      echo " | '--no-themes': Skips the installation of custom themes."
      echo " | '--no-icons': Skips the installation of custom icon packs."
      echo " | '--no-packages': Prevents the installation of additional software packages."
      echo " | '--no-background': Prevents changing the background/wallpaper."
      echo " | '--no-search-light': Disables the installation of the Search Light Extension."
      echo " | '--no-dash': Prevents from installing the dash (/taskbar)."
      echo " | '--no-ding': Disables the installation of the Desktop Icons NG (DING) Extension."
      echo " | '--help': Displays the usage of different options."
      echo ""
      echo ">> Usage: $0 [--no-zsh] [--no-themes] [--no-icons] [--no-background] [--no-search-light] [--no-dash] [--no-ding] [--no-packages] [--help]"
      exit 0
      ;;
  esac
done

########################################### THEMES ###########################################

# Theme
if [ "$INSTALL_THEMES" == "true" ]; then
    if [ ! -d "$HOME/.themes/Marble-green-dark" ]; then
        echo ">> Installing Marble Theme..."
        git clone https://github.com/imarkoff/Marble-shell-theme.git
        cd Marble-shell-theme
        python install.py --green
        cd ..
    else
        echo ">> Marble Theme is already installed, skipping."
    fi

    if [ ! -d "$HOME/.themes/Graphite-teal-Dark-nord-Dark" ]; then
        echo ">> Installing Graphite Theme..."
        git clone https://github.com/vinceliuice/Graphite-gtk-theme
        cd Graphite-gtk-theme
        sh install.sh --name "Graphite-teal-Dark-nord" --tweaks rimless -c dark
        cd ..
    else
        echo ">> Graphite Theme is already installed, skipping."
    fi

    dconf write /org/gnome/desktop/interface/gtk-theme "'Graphite-teal-Dark-nord-Dark'"
    dconf write /org/gnome/shell/extensions/user-theme/name "'Marble-green-dark'"
fi

# Icons
if [ "$INSTALL_ICONS" == "true" ]; then
    if [ ! -d "$HOME/.icons/Futura" ]; then
        echo ">> Installing Futura Icon Theme..."
        git clone https://github.com/coderhisham/Futura-Icon-Pack &> /dev/null
        cp -R Futura-Icon-Pack ~/.icons/Futura
    else
        echo ">> Futura Icon Theme is already installed, skipping."
    fi
    dconf write /org/gnome/desktop/interface/icon-theme "'Futura'"
fi

########################################### THEMES ###########################################

########################################### PACKAGES ###########################################

PACKAGES=( "nautilus" "git" "python3" "ttf-ubuntu-font-family" "gnome-shell-extensions" "gnome-text-editor" "gnome-tweaks" "zsh" "powerline" "powerline-fonts" "neofetch" "diodon" )

install_package() {
    local package="$1"

    if command -v "$package" &>/dev/null || 
       (command -v dpkg &>/dev/null && dpkg -l | grep -q "^ii  $package ") || 
       (command -v rpm &>/dev/null && rpm -q "$package" &>/dev/null) || 
       (command -v pacman &>/dev/null && pacman -Q "$package" &>/dev/null); then
        echo " | $package is already installed."
        return 0
    fi

    echo " | Installing $package..."

    if command -v apt &>/dev/null; then
        sudo apt install -y "$package" &> /dev/null
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y "$package" &> /dev/null
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm "$package" &> /dev/null
    elif command -v yay &>/dev/null; then
        yay -S --noconfirm "$package" &> /dev/null
    else
        echo "No supported package manager found. Please install '$package' manually."
        return 2
    fi
}

if [ "$INSTALL_PACKAGES" == "true" ]; then
    echo ">> Installing packages"
    for PACKAGE in "${PACKAGES[@]}"; do
        install_package "$PACKAGE"
    done
fi

########################################### PACKAGES ###########################################

########################################### EXTENSIONS ###########################################

mkdir extensions &> /dev/null
cd extensions

function install_ding() {
    echo ">> Installing Desktop Icons NG..."
    git clone https://gitlab.com/rastersoft/desktop-icons-ng ~/.local/share/gnome-shell/extensions/ding@rastersoft.com &> /dev/null

    dconf load / < ../conf/ding
}

function install_top_bar() {
    echo ">> Installing Top Bar..."

    # Open bar
    echo " | Installing Openbar..."
    git clone https://github.com/neuromorph/openbar &> /dev/null
    cp -R openbar/openbar@neuromorph/ ~/.local/share/gnome-shell/extensions/

    # Top bar organizer
    echo " | Installing Top Bar Organizer..."
    git clone https://gitlab.gnome.org/june/top-bar-organizer &> /dev/null
    cp -R top-bar-organizer/src ~/.local/share/gnome-shell/extensions/top-bar-organizer@julian.gse.jsts.xyz

    dconf load / < ../conf/topbar
}

function install_search_light() {
    echo ">> Installing Search Light..."
    git clone https://github.com/icedman/search-light ~/.local/share/gnome-shell/extensions/search-light@icedman.github.com &> /dev/null
    dconf load / < ../conf/searchlight
}

function install_dash_to_panel() {
    echo ">> Installing Dash to Panel..."
    git clone https://github.com/home-sweet-gnome/dash-to-panel &> /dev/null
    make -C dash-to-panel &> /dev/null
    dconf load / < ../conf/dashtopanel
}

if [ "$INSTALL_DING" == "true" ]; then
    install_ding
fi

if [ "$INSTALL_TOP_BAR" == "true" ]; then
    install_top_bar
fi

if [ "$INSTALL_DASH_TO_PANEL" == "true" ]; then
    install_dash_to_panel
fi

if [ "$INSTALL_SEARCH_LIGHT" == "true" ]; then
    install_search_light
fi

cd ..

# Reload gnome shell
echo ">> Reloading gnome shell..."
if [ "$XDG_SESSION_TYPE" != "wayland" ]; then
    killall -HUP gnome-shell &> /dev/null
fi

# Enable extensions
echo ">> Disabling extensions that might cause conflicts..."
gnome-extensions disable openbar@neuromorph &> /dev/null
gnome-extensions disable top-bar-organizer@julian.gse.jsts.xyz &> /dev/null

echo ">> Enabling extensions..."
if [ "$INSTALL_DING" == "true" ]; then
    gnome-extensions enable ding@rastersoft.com &> /dev/null
fi

if [ "$INSTALL_DASH_TO_PANEL" == "true" ]; then
    gnome-extensions enable dash-to-panel@jderose9.github.com &> /dev/null
fi

if [ "$INSTALL_SEARCH_LIGHT" == "true" ]; then
    gnome-extensions enable search-light@icedman.github.com &> /dev/null
fi

if [ "$XDG_SESSION_TYPE" != "wayland" ]; then
    killall -HUP gnome-shell &> /dev/null
fi
########################################### EXTENSIONS ###########################################

########################################### ZSHELL ###########################################

if [ "$UPDATE_ZSH" == "true" ]; then
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo ">> Oh my ZShell is already installed."
    else
        echo ">> Installing Oh my ZShell..."
        yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/binding "'<Super>t'"
        dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/command "'gnome-terminal -- zsh'"
        dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/name "'terminal'"
    fi

    echo ">> Updating ZSH Theme..."
    sed -i 's/ZSH_THEME=".*"/ZSH_THEME="agnoster"/' ~/.zshrc
    source ~/.zshrc &> /dev/null
fi

########################################### ZSHELL ###########################################

########################################### CONFIGS ###########################################

echo ">> Loading configs..."
dconf load / < conf/gedit
dconf load / < conf/nautilus
dconf load / < conf/desktop
dconf load / < conf/diodon

if [ "$UPDATE_BACKGROUND" == "true" ]; then
    echo ">> Loading background..."
    cp conf/background.png ~/.config/background
    gsettings set org.gnome.desktop.background picture-uri ~/.config/background
fi

########################################### CONFIGS ###########################################

echo ">> Done."
