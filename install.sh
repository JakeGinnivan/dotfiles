# Install some stuff before others!
important_casks=(
    dropbox
    spotify
    visual-studio-code
    slack
    iterm2
)

brews=(
    awscli
    git
    grep
    httpie
    "imagemagick --with-webp"
    node@12
    postgres
    python3
    ruby
    thefuck
    graphviz
    jq
    pulumi
    zsh
    zsh-completions
    zsh-syntax-highlighting
    zsh-autosuggestions
    defaultbrowser
    "lastpass-cli --with-pinentry --with-doc"
    mas
    rbenv
)

casks=(
    alfred
    docker
    kitematic
    expressvpn
    firefox
    google-chrome
    kap-beta
    microsoft-office
    skype
    steam
    visual-studio-code
    java
    # KDiff3 (no longer in cask)
    https://raw.githubusercontent.com/Homebrew/homebrew-cask/6a96e5ea44803e52a43c0c89242390f75d1581ab/Casks/kdiff3.rb
    google-photos-backup-and-sync
    gimp
    imageoptim
)

pips=(
    pip
)

gems=(
  bundler
  travis
)

npms=(
)

app_store=(
    # Amphetamine
    937984704
)

alfred_workflows=(
    "https://raw.github.com/willfarrell/alfred-encode-decode-workflow/master/encode-decode.alfredworkflow"
    "https://raw.githubusercontent.com/cs1707/tldr-alfred/master/tldr.alfredworkflow"
    "https://raw.github.com/gharlan/alfred-github-workflow/releases/download/latest/github.alfredworkflow"
    "https://raw.github.com/packal/repository/raw/master/com.stuartryan.alfred.lastpass/lastpass-cli-alfred-workflow.alfredworkflow"
)

git_configs=(
  "branch.autoSetupRebase always"
  "color.ui auto"
  "core.autocrlf input"
  "credential.helper osxkeychain"
  "merge.ff false"
  "pull.rebase true"
  "push.default simple"
  "rebase.autostash true"
  "rerere.autoUpdate true"
  "remote.origin.prune true"
  "rerere.enabled true"
)

vscode=(
    eamodio.gitlens
    vscode-icons-team.vscode-icons
    esbenp.prettier-vscode
    ms-azuretools.vscode-docker
    ms-azuretools.vscode-docker
    coenraads.bracket-pair-colorizer
    redhat.vscode-yaml
    editorconfig.editorconfig
    dotjoshjohnson.xml
    vscodevim.vim
    wayou.vscode-todo-highlight
    wallabyjs.quokka-vscode
    rbbit.typescript-hero
    wix.vscode-import-cost
    azemoh.one-monokai
    codezombiech.gitignore
    jasonnutter.search-node-modules
    mauve.terraform
    sdras.night-owl
    flowtype.flow-for-vscode
    jebbs.plantuml
    foxundermoon.shell-format
    dbaeumer.vscode-eslint
)

fonts=(
    font-fira-code
    font-source-code-pro
    font-dejavu-sans
    font-dejavu-sans-mono-for-powerline
)


######################################## End of app list ########################################
set +e
set -x

function install {
    cmd=$1
    shift
    for pkg in "$@";
    do
        exec="$cmd $pkg"
        if ${exec} ; then
            echo "Installed $pkg"
        else
            echo "Failed to execute: $exec"
        fi
    done
}

function brew_install_or_upgrade {
    if brew ls --versions "$1" >/dev/null; then
        if (brew outdated | grep "$1" > /dev/null); then 
            echo "Upgrading already installed package $1 ..."
            brew upgrade "$1"
        else 
            echo "Latest $1 is already installed"
        fi
    else
        brew install "$1"
    fi
}

function add_alfred_workflow {
    base=$(basename -- "$1")
    target="$HOME/Downloads/$base"
    echo $target
    curl -s -L --output $target "$1"
}

sudo -v # Ask for the administrator password upfront
# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

if test ! "$(command -v brew)"; then
    echo "Install Homebrew"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    echo "Update Homebrew"
    brew update
    brew upgrade
    brew doctor
fi

echo "Creating an SSH key for you..."
ssh-keygen -t rsa
echo "Installing xcode-stuff"
xcode-select --install

echo "Install important software ..."
brew tap homebrew/cask-versions
install 'brew cask install' "${important_casks[@]}"

echo "Install packages"
install 'brew_install_or_upgrade' "${brews[@]}"
brew link --overwrite ruby

#Install Zsh & Oh My Zsh
echo "Installing Oh My ZSH..."
curl -L http://install.ohmyz.sh | sh

echo "Setting ZSH as shell..."
sudo chsh -s /bin/zsh

echo "Set git defaults"
for config in "${git_configs[@]}"
do
    git config --global ${config}
done

echo "Install software"
install 'brew cask install' "${casks[@]}"

echo "Install secondary packages"
install 'pip3 install --upgrade' "${pips[@]}"
install 'gem install' "${gems[@]}"
install 'npm install --global' "${npms[@]}"
install 'code --install-extension' "${vscode[@]}"
install 'mas install' "${app_store[@]}"
brew tap homebrew/cask-fonts
install 'brew cask install' "${fonts[@]}"

sudo cpan install Capture::Tiny

# install 'add_alfred_workflow' "${alfred_workflows[@]}"

defaultbrowser firefox

echo "Update packages"
pip3 install --upgrade pip setuptools wheel
m update install all

echo "Install software from App Store"
mas list

cat ~/.ssh/id_rsa.pub | pbcopy
echo "Please add this public key to Github\n"
echo "Public key copied to clipboard\n"
echo "https://github.com/account/ssh \n"

echo "Alfred workflows are in ~/Downloads, run them"

echo "Done!"
