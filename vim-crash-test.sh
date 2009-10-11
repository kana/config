mkdir vim-crash-test
cd ./vim-crash-test

# Build Vim which I use.
git clone git://github.com/kana/vim.git
cd ./vim
git checkout -f svn-trunk-200910112259
./configure \
  --prefix=/usr/local/apps/vim \
  --with-features=huge \
  --disable-darwin \
  --disable-netbeans \
  --enable-multibyte \
  --disable-gui \
  --enable-acl \
  --disable-nls \
  --without-x \
  CC=gcc \
  'CFLAGS=-g -O0'
make
cd ..

# Run test.
git clone git://github.com/kana/config.git
cd ./config
git checkout vim-ku-0.3-sigbus2-200910112259
make -B test/vim-ku/core-internal-candidate.ok

# __END__
