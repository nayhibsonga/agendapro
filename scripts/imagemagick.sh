#!/bin/bash
OLDFOLDER="ImageMagick-6.9.3-7"
FOLDER="ImageMagick-6.9.3-7"
FILE="ImageMagick.tar.gz"
LOG="imagemagick-instalation.log"

date >> $LOG

echo ">> Desinstalando versiones viejas (aprox < 1 min)"
echo ">> Desinstalando versiones viejas (aprox < 1 min)" >> $LOG
sudo apt-get remove imagemagick
if [[ -d $OLDFOLDER ]]; then
  cd $OLDFOLDER/
  sudo make uninstall &>> ../$LOG
  cd ..
  rm -rf $OLDFOLDER/ &>> $LOG
fi

echo ">> Bajando ImageMagick (aprox < 1 min)"
echo ">> Bajando ImageMagick (aprox < 1 min)" >> $LOG
wget "http://www.imagemagick.org/download/ImageMagick.tar.gz"
if [[ ! -e $FILE ]]; then
  echo ">> Error descargando"
  echo ">> Error descargando" >> $LOG
  exit 1
fi

echo ">> Descomprimiento ImageMagick (aprox < 1 min)"
echo ">> Descomprimiento ImageMagick (aprox < 1 min)" >> $LOG
tar xvzf $FILE &>> $LOG
if [[ ! -d $FOLDER ]]; then
  echo ">> Error descomprimiendo"
  echo ">> Error descomprimiendo" >> $LOG
  exit 1
fi

if [[ -d $FOLDER ]]; then
  echo ">> Configurando ImageMagick (aprox < 1 min)"
  echo ">> Configurando ImageMagick (aprox < 1 min)" >> $LOG
  cd $FOLDER/
  ./configure &>> ../$LOG
  echo ">> Compilando ImageMagick (aprox 5 min)"
  echo ">> Compilando ImageMagick (aprox 5 min)" >> ../$LOG
  make &>> ../$LOG

  echo ">> Instalando ImageMagick (aprox < 1 min)"
  echo ">> Instalando ImageMagick (aprox < 1 min)" >> ../$LOG
  sudo make install &>> ../$LOG
  sudo ldconfig /usr/local/lib

  echo ">> Limpiando (aprox < 1 min)"
  echo ">> Limpiando (aprox < 1 min)" >> ../$LOG
  make clean &>> ../$LOG
  sudo make clean &>> ../$LOG
  cd ..
  rm -f $FILE &>> $LOG

  echo ">> Testeando"
  echo ">> Testeando" >> $LOG
  convert -version
fi

exit 0
