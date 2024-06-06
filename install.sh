curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
cp init.vim ~/.config/nvim/init.vim

#curl -sL install-node.vercel.app/lts | sudo bash

# todo: change
#curl -LO https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb
#sudo dpkg -i ripgrep_13.0.0_amd64.deb
#rm ripgrep_13.0.0_amd64.deb

brew install ripgrep
nvim +PlugInstall +CocInstall coc-go +CocInstall coc-db +CocInstall coc-html +CocInstall coc-tsserver +CocInstall coc-json +CocInstall coc-phpls

npm install -g prettier
npm install -g @fsouza/prettierd

sudo apt install -g shfmt
