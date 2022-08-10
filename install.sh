#!/bin/bash

CODEDIR=~/zsh-addons
do_brew_installs=true

echo -e "\033[93m!! Warning !!"
echo "This script must be run off corporate network (without VPN)."
echo -n "<enter> to continue"
read i

if [ -z `which brew` ]; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ "$do_brew_installs" = true ]; then
	brew install --cask iterm2
	brew install zsh
	brew install zsh-syntax-highlighting
fi

# make zsh your default shell
chsh -s $(which zsh)

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

mkdir -p ${CODEDIR}

# optional zsh plugin for auto suggestions based on bash history
cd ${CODEDIR}
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# optional, highlights valid and invalid commands like fish shell
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
echo "source ${(q-)PWD}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc

# copy my custom .zshrc config with some plugins and theme settings ready to go
git clone https://github.com/IbrahimAH/ohmyzsh-iterm2-solarized.git
cp ohmyzsh-iterm2-solarized/.zshrc ~/.zshrc

# powerline fonts are required for proper formatting in the theme we're using
cd ${CODEDIR}
git clone https://github.com/powerline/fonts.git
cd fonts
./install.sh
# get solarized dark theme
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

echo -e "\033[93mLaunch iTerm2 then change the following preferences"
echo -e "\033[93miTerm2->Preferences->Profiles->Colors->Color Presets...->SolarizedDark"
echo -e "\033[93mThen in Profiles->Colors. Change ANSI Bright-Black to a brighter colour."
echo -e "\033[93mThen in Profiles->Text->Font. Choose whichever Powerline font you like."
echo ""

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
