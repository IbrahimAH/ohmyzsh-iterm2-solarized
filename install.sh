#!/bin/bash

CODEDIR=~/zsh-addons
do_brew_installs=true
do_brew_installs_extra=true

steps=12

echo -e "\033[93m!! Warning !!"
echo "This script must be run off corporate network (without VPN)."
echo "Installing ZSH/Iterm2 may exit the script."
echo "If so, re-run ./install.sh"
echo -n "<enter> to continue"
read i

if [ -z `which brew` ]; then
	echo "1/$steps Installing Brew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ "$do_brew_installs" = true ]; then
	echo "2/$steps Installing Iterm2 & ZSH..."
	brew install --cask iterm2
	brew install zsh
fi

echo "3/$steps Setting ZSH as default shell..."
chsh -s $(which zsh)

echo "4/$steps Installing Oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

if [ "$do_brew_installs_extra" = true ]; then
	echo "5/$steps Installing Ohmyzsh plugins..."
	brew install hub
	brew tap homebrew/command-not-found
fi

mkdir -p ${CODEDIR}
cd ${CODEDIR}

# optional zsh plugin for auto suggestions based on bash history
echo "6/$steps Installing plugin zsh-autosuggestions..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# optional, highlights valid and invalid commands like fish shell
echo "7/$steps Installing plugin zsh-syntax-highlighting..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
echo "source ${(q-)PWD}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc

# copy my custom .zshrc config with some plugins and theme settings ready to go
echo "8/$steps Copying in my .zshrc file to ~/..."
git clone https://github.com/IbrahimAH/ohmyzsh-iterm2-solarized.git
cp ohmyzsh-iterm2-solarized/.zshrc ~/.zshrc

# powerline fonts are required for proper formatting in the theme we're using
echo "9/$steps Installing powerline fonts..."
cd ${CODEDIR}
git clone https://github.com/powerline/fonts.git
cd fonts
./install.sh

echo "10/$steps Importing Dark theme to Iterm2..."
cd ${CODEDIR}
mkdir schemes
cd schemes
curl https://raw.githubusercontent.com/altercation/solarized/master/iterm2-colors-solarized/Solarized%20Dark.itermcolors > SolarizedDark.itermcolors
# retrieve script that installs themes into iterm. worth reviewing this codebase before blindly installing...
# the current (07/21) version of this script seems reasonable and is available in this repo
cd ${CODEDIR}
mkdir tools
cd tools
curl https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/tools/import-scheme.sh > import-scheme.sh
chmod +x import-scheme.sh
./import-scheme.sh 'SolarizedDark.itermcolors'

echo -e "\033[93m11/$steps Launch iTerm2 then change the following preferences"
echo -e "\033[93miTerm2->Preferences->Profiles->Colors->Color Presets...->SolarizedDark"
echo -e "\033[93mThen in Profiles->Colors. Change ANSI Bright-Black to a brighter colour."
echo -e "\033[93mThen in Profiles->Text->Font. Choose whichever Powerline font you like."
echo ""

echo "12/$steps Apply font settings to VS Code..."
while true; do
    read -p "Do you have VS Code installed?" yn
    case $yn in
        [Yy]* )
		echo "Navigate to VS Code->Preferences->Settings and search 'terminal.integrated.fontFamily'."
		echo "In the FontFamily setting, input your chosen Powerline font. i.e. Source Code Pro for Powerline"
		echo "You may also wish to change the font size 'terminal.integrated.fontSize'."; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo -e "Restart iTerm2 and you're good to go!"
