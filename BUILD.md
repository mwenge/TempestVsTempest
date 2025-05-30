## How to build (Linux)
The build system and structure is based on 'The Book of CP-System' by Fabien Sanglard, of which this repository is a fork.


- Setup env
```
cp src/fonts ~/.fonts
fc-cache -f -v
sudo apt-get update
sudo apt install -y golang-go
sudo add-apt-repository universe
sudo add-apt-repository ppa:inkscape.dev/stable
sudo apt-get update
sudo apt install inkscape
sudo apt install ghostscript # For trimming the final PDF.
sudo apt install -y texlive-full
```

- Setup dependencies
```
go mod init "image/draw"
go get golang.org/x/image/draw
```
- Build
```
./make.sh release
```

## How to build (Windows)

- Install WSL1/WSL2
- Follow Linux steps.

## How to build (MacOS X)
- Install fonts (in `src/fonts` folder)
- Get MacTeX.
- Install golang (https://golang.org/doc/install)
- Install Inkscape > v1.0
- Symlink inkscape binary to `/usr/local/bin` or add it to your PATH
- Get build system dependencies 
```
go mod init "image/draw"
go get golang.org/x/image/draw
```
- Build
```
./make.sh release
```



### Debug mode

Building is slow when using 300dpi assets. To develop, the build system generates low dpi assets. 
Debug is the default mode.

```
./make.sh debug
```

### Force asset regeneration
```
./make.sh debug|release -f
```

### Poor typesetting

If upon compilation the typesetting is "off" with blank pages, it may be that the wrong version of TexLive is used to compile. Run the following command and make sure you have at least version 2020.

```
$ tex --version
TeX 3.141592653 (TeX Live 2022)
```

This book is verified to compile properly with TexLive 2020, 2021, and 2022. In case you have an older version, use the following steps to install the lastest.

[Uninstall TexLive](https://puttym.github.io/update-texlive)

[Download TexLive NetInstall](https://www.tug.org/texlive/acquire-netinstall.html)

[Install TexLive](https://www.tug.org/texlive/quickinstall.html)
