sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

mkdir ~/.config/nvim
cp init.vim ~/.config/nvim/init.vim

rm -r ~/.config/nvim/snippets
cp -r snippets ~/.config/nvim/snippets

#curl -sL install-node.vercel.app/lts | sudo bash

# todo: change
#curl -LO https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb
#sudo dpkg -i ripgrep_13.0.0_amd64.deb
#rm ripgrep_13.0.0_amd64.deb

brew install ripgrep || sudo apt install ripgrep
#nvim +PlugInstall +CocInstall coc-go +CocInstall coc-db +CocInstall coc-html +CocInstall coc-tsserver +CocInstall coc-json +CocInstall coc-phpls

nvim +PlugInstall

sudo apt install npm
sudo npm install -g prettier
sudo npm install -g @fsouza/prettierd

sudo apt install shfmt

sudo apt install clangd-19 # для C
