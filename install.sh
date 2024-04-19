
cp init.vim ~/.config/nvim/init.vim

curl -sL install-node.vercel.app/lts | sudo bash

# todo: change
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb
sudo dpkg -i ripgrep_13.0.0_amd64.deb
rm ripgrep_13.0.0_amd64.deb

#:CocInstall coc-go
#:CocInstall coc-db
