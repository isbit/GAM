echo "Installing Net-Framework-Core..."
export mypath=$(pwd)
until powershell Install-WindowsFeature Net-Framework-Core; do echo "trying again..."; done
cd ~
#export exefile=Win64OpenSSL_Light-${BUILD_OPENSSL_VERSION//./_}.exe
#if [ ! -e $exefile ]; then
#  echo "Downloading $exefile..."
#  wget --quiet https://slproweb.com/download/$exefile
#fi
#echo "Installing $exefile..."
#powershell ".\\${exefile} /silent /sp- /suppressmsgboxes /DIR=C:\\ssl"
#cinst -y python3
PYVER=$(~/python/python.exe -V)
PYRESULT=$?
if [[ "$PYRESULT" != "0" ]] || [[ "$PYVER" != *"$BUILD_PYTHON_VERSION"* ]]; then
  rm -rf python
  mkdir python
  echo "Downloading Python $BUILD_PYTHON_VERSION..."
  wget --quiet https://www.python.org/ftp/python/$BUILD_PYTHON_VERSION/python-$BUILD_PYTHON_VERSION-embed-amd64.zip
  7z e python-$BUILD_PYTHON_VERSION-embed-amd64.zip -opython
  rm -rf python/*._pth # screws up pip library location
fi
until cinst -y wixtoolset; do echo "trying again..."; done
#until cp -v /c/ssl/libcrypto-1_1-x64.dll /c/Python37/DLLs/libcrypto-1_1.dll; do echo "trying again..."; done
#until cp -v /c/ssl/libssl-1_1-x64.dll /c/Python37/DLLs/libssl-1_1.dll; do echo "trying again..."; done
export PATH=$PATH:/c/Users/travis/python/scripts
cd $mypath
export python=/c/Users/travis/python/python.exe
export pip=/c/Users/travis/python/scripts/pip.exe

curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
$python get-pip.py

$pip install --upgrade pip
$pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 $pip install -U
$pip install --upgrade -r src/requirements.txt
#$pip install --upgrade pyinstaller
# Install PyInstaller from source and build bootloader
# to try and avoid getting flagged as malware since
# lots of malware uses PyInstaller default bootloader
# https://stackoverflow.com/questions/53584395/how-to-recompile-the-bootloader-of-pyinstaller
echo "Downloading PyInstaller..."
#wget --quiet https://github.com/pyinstaller/pyinstaller/releases/download/v$PYINSTALLER_VERSION/PyInstaller-$PYINSTALLER_VERSION.tar.gz
wget --quiet https://github.com/pyinstaller/pyinstaller/archive/develop.tar.gz
#tar xf PyInstaller-$PYINSTALLER_VERSION.tar.gz
tar xf develop.tar.gz
#cd PyInstaller-$PYINSTALLER_VERSION/bootloader
cd pyinstaller-develop/bootloader
echo "bootloader before:"
md5sum ../PyInstaller/bootloader/Windows-64bit/*
$python ./waf all --target-arch=64bit
echo "bootloader after:"
md5sum ../PyInstaller/bootloader/Windows-64bit/*
echo "PATH: $PATH"
cd ..
$python setup.py install
echo "cd to $mypath..."
#until cp -v /c/ssl/*.dll /c/Python37/DLLs; do echo "trying again..."; done
cd $mypath
