#!/bin/sh

SKINFNAME="Capri"
SKINDIRNAME="capri"
SOURCEPATH="https://raw.githubusercontent.com/cmsnegar/Capri/master/"
DATADIR="/usr/local/directadmin/data/skin_data"
PLUGINPATH="/usr/local/directadmin/data/skin_data/$SKINDIRNAME"
THISPATH=$PWD
LICENSE=CS_a1234567890b

# install the skin
doInstall()
{
  echo ""
  echo -e "\e[1;37mThis script will install and setup $SKINFNAME Skin for DirectAdmin Control panel."
  
  
  echo -e "\e[40;37m\e[0m"
  echo ""
  if [ "$SKNAME" = "" ]; then
    echo -n "Please choose a skin name or press enter to use default [$SKINFNAME]: "
    read SKNAME
  fi
  
  if [ "$SKNAME" = "" ]; then
    SKNAME="$SKINFNAME"
  fi
  
  SKINPATH="/usr/local/directadmin/data/skins/$SKNAME"
  
  echo -e "Skin name will be:\e[1;37m $SKNAME \e[40;37m\e[0m"
  echo ""

  	echo -n "Please choose a color set (1: blue, 2: grey) [1]: "
    read SKCOLOR
  
	echo -n "Would you like to install the login page skin? (y/n) [y]: "
  read SKLOGIN
  
  echo ""
  echo "Capri skin also have a email-only version for users who have a email services."
  echo -n "Would you like to install a second email-only skin (will be called $SKNAME-mail)? (y/n) [n]: "
  read SKMAILONLY
  echo ""
  
  if [ -n $ARG1 ]; then
    LICENSE="$ARG1"
  fi
  
  echo $1
  
  if [ ! -d "$DATADIR" ]; then
    mkdir $DATADIR
  fi
  chmod 777 $DATADIR
  chown diradmin:diradmin $DATADIR
 
  if [ ! -d "$PLUGINPATH" ]; then
    mkdir $PLUGINPATH
  fi
  chmod 777 $PLUGINPATH
  chown diradmin:diradmin $PLUGINPATH
  
  if [ "$OVERWRITE" = "" ]; then
    if [ -d "$SKINPATH" ]; then
      echo -n "Directory $SKINPATH already exists. Do you want to delete it? (y/n) [y]: "
      read ACT1
      echo
      if [ "$ACT1" = "n" ]; then
        echo "Instalation aborted by user.";
        exit 0;
      else
        rm -fr $SKINPATH/*
        rmdir $SKINPATH
      fi
    fi
  fi
  
  if [ ! -d "$SKINPATH" ]; then
    mkdir $SKINPATH
  fi
  chmod 755 $SKINPATH
  chown diradmin:diradmin $SKINPATH
  
  cd $SKINPATH
  echo -n "Downloading skin files...            "

  if [ "$SKCOLOR" = "2" ]; then
      wget -q -O $SKINPATH/$SKINDIRNAME.tar.gz $SOURCEPATH/capri_grey.tar.gz
  else
      wget -q -O $SKINPATH/$SKINDIRNAME.tar.gz $SOURCEPATH/capri.tar.gz
  fi

  # aca chequeo si el archivo se descargo
  if [ ! -f "$SKINPATH/$SKINDIRNAME.tar.gz" ]; then
    echo -e "\e[1;31m Failed \e[40;37m\e[0m"; echo""
    echo -e "*** An error occur while downloading files. Please try again or contact support."
    echo ""
    cd $THISPATH
    exit 0;
  fi
  
  # aca chequeo si pesa menos de 150k
  if [ `du -k $SKINPATH/$SKINDIRNAME.tar.gz |awk '{print $1}'` -lt 200 ]; then
    # Si pesa menos lo abro a ver que contiene
    if [ `du -b $SKINPATH/$SKINDIRNAME.tar.gz |awk '{print $1}'` -lt 10 ]; then
    FILEDATA=`cat $SKINPATH/$SKINDIRNAME.tar.gz`
    fi
    # Si contiene la palabra "license" es por que es una licencia incorrecta
    if [ "$FILEDATA" = "license" ]; then
      rm -f $SKINPATH/$SKINDIRNAME.tar.gz
      echo -e "\e[1;31m Failed \e[40;37m\e[0m"; echo""
      echo -e "*** The license key entered is not active or it is invalid."
      echo ""
      cd $THISPATH
      exit 0;
    fi
    # Si se descargo otra cosa, borro y termino
    rm -f $SKINPATH/$SKINDIRNAME.tar.gz
    echo -e "\e[1;31m Failed \e[40;37m\e[0m"; echo""
    echo -e "*** An error occur while downloading files. Cannot reach source download URL. Please try again or contact support."
    echo ""
    cd $THISPATH
    exit 0;
  fi
  
  echo -e "\e[1;32m Done \e[40;37m\e[0m "
  
  echo -n "Decompressing skin files...          "
  tar xfz $SKINPATH/$SKINDIRNAME.tar.gz
  
  if [ ! -f "$SKINPATH/files_admin.conf" ]; then
    echo -e "\e[1;31m Failed \e[40;37m\e[0m"; echo""
    echo -e "*** An error occur while decompressing files. Please try again or contact support."
    echo ""
    rm -fr $SKINPATH/*
    rm -fr $PLUGINPATH/*
    rmdir $SKINPATH
    rmdir $PLUGINPATH
    cd $THISPATH
    exit 0;
  fi
  
  echo -e "\e[1;32m Done \e[40;37m\e[0m "
  
  
  # instalo mail only skin
  if [ "$SKMAILONLY" = "y" ]; then
  
    if [ ! -d "$SKINPATH-mail" ]; then
      mkdir $SKINPATH-mail
    fi
    chmod 755 $SKINPATH-mail
    chown diradmin:diradmin $SKINPATH-mail
    cd $SKINPATH-mail
    
    echo -n "Installing email-only skin...        "
    wget -q -O $SKINPATH-mail/$SKINDIRNAME-mail.tar.gz $SOURCEPATH/capri_mail.tar.gz
    
    if [ ! -f "$SKINPATH-mail/$SKINDIRNAME-mail.tar.gz" ]; then
      echo -e "\e[1;31m Failed \e[40;37m\e[0m"; echo""
      echo -e "*** An error occur while downloading files. Please try again or contact support."
      echo ""
      cd $THISPATH
    else
      if [ `du -k $SKINPATH-mail/$SKINDIRNAME-mail.tar.gz |awk '{print $1}'` -lt 50 ]; then
        rm -f $SKINPATH-mail/$SKINDIRNAME-mail.tar.gz
        rm -f $SKINPATH-mail/*
        rmdir $SKINPATH-mail
        echo -e "\e[1;31m Failed \e[40;37m\e[0m";
        echo -e "*** An error occur while downloading email-only skin files. Mail-only skin not installed."
        cd $THISPATH
      else
        tar xfz $SKINPATH-mail/$SKINDIRNAME-mail.tar.gz
        echo -n "1" > $PLUGINPATH/emailonly
        echo -e "\e[1;32m Done \e[40;37m\e[0m "
        cd $THISPATH
      fi
    fi
  fi
  
    
  # instalo login page
  if [ "$SKLOGIN" != "n" ]; then
    echo -n "Installing login page skin...        "
    if [ "$SKCOLOR" = "2" ]; then
      wget -q -O /usr/local/directadmin/data/templates/capri_login.tar.gz $SOURCEPATH/capri_login_grey.tar.gz
    else
      wget -q -O /usr/local/directadmin/data/templates/capri_login.tar.gz $SOURCEPATH/capri_login.tar.gz
    fi
    
    if [ -f "/usr/local/directadmin/data/templates/capri_login.tar.gz" ]; then
      if [ `du -b /usr/local/directadmin/data/templates/capri_login.tar.gz |awk '{print $1}'` -lt 3000 ]; then
        rm -f /usr/local/directadmin/data/templates/capri_login.tar.gz
        echo -e "\e[1;31m Failed \e[40;37m\e[0m";
        echo -e "*** An error occur while downloading login page files. Login page not installed."
      else
        cd /usr/local/directadmin/data/templates/
        tar xfz capri_login.tar.gz
        chmod 755 /usr/local/directadmin/data/templates/login_images
        chown diradmin:diradmin /usr/local/directadmin/data/templates/login_images
        chown diradmin:diradmin /usr/local/directadmin/data/templates/login_images/*
        chown diradmin:diradmin /usr/local/directadmin/data/templates/login.html
        rm -f capri_login.tar.gz
        echo -n "1" > $PLUGINPATH/loginpage
        echo -e "\e[1;32m Done \e[40;37m\e[0m "
      fi
    else
        rm -f /usr/local/directadmin/data/templates/capri_login.tar.gz
        echo -e "\e[1;31m Failed \e[40;37m\e[0m";
        echo -e "*** An error occur while downloading login page files. Login page not installed."
    fi

  fi

  echo -n "Setting permissions...               "
  chown -R diradmin:diradmin $SKINPATH/*
  find $SKINPATH/ -type f -exec chmod 755 {} \;
  chmod 777 $SKINPATH/inc
  chown diradmin:diradmin $SKINPATH
  
  mv $SKINPATH/skin_data/cron.sh $PLUGINPATH/cron.sh
  rm -f $SKINPATH/skin_data/*
  rmdir $SKINPATH/skin_data
  chmod 666 $PLUGINPATH/*
  chmod 755 $PLUGINPATH/cron.sh
  chmod 777 $PLUGINPATH
  
  if [ -f "$SKINPATH-mail/header.html" ]; then
    find $SKINPATH-mail/ -type f -exec chmod 755 {} \;
    chown -R diradmin:diradmin $SKINPATH-mail/*
    chown diradmin:diradmin $SKINPATH-mail
  fi
  
  echo -n "$LICENSE" > $PLUGINPATH/license
  echo -n "$SKNAME" > $PLUGINPATH/name
	echo -n "$SKCOLOR" > $PLUGINPATH/color
  chmod 777 $PLUGINPATH/license
  
  # seteo cron
  perl -ni -e 'unless (m/Added by $SKINFNAME/) { print }' /etc/crontab 2>&1
  perl -ni -e 'unless (m/Added by $SKINFNAME/) { print }' /etc/crontab 2>&1
  echo "* * * * * root $PLUGINPATH/cron.sh > /dev/null 2>&1 # Added by $SKINFNAME" >> /etc/crontab
  
  echo -e "\e[1;32m Done \e[40;37m\e[0m "
  
  # finalizo la instalacion
  echo "";echo ""
  echo -e "\e[1;37mCongratulations! $SKINFNAME has been installed. Log in you control panel and switch to $SKNAME skin.\e[40;37m\e[0m"
  echo ""
  
  exit 0;
}

####################################################################################################################################################

doUpdate()
{
  echo ""
  echo -e "Updating $SKINFNAME."

  SKINPATH="/usr/local/directadmin/data/skins/$OLDSKINNAME"
	
	if [ -f "$PLUGINPATH/color" ]; then
	  SKCOLOR=`cat $PLUGINPATH/color`
	fi
	
	if [ ! -f "$PLUGINPATH/color" ]; then
		echo -n "Please choose a color set (1: blue, 2: grey) [1]: "
    read SKCOLOR
	fi
  
  if [ -f "$PLUGINPATH/license" ]; then
    LICENSE=`cat $PLUGINPATH/license`
  else
    if [ -f "$SKINPATH/inc/license" ]; then
      LICENSE=`cat $PLUGINPATH/license`
    fi
  fi
  
  if [ "$LICENSE" = "" ]; then
    echo ""
    echo -n "We can't find you license key. Please insert your license key: "
    read LICENSE
    echo ""
  fi
    
  if [ ! -d "$DATADIR" ]; then
    mkdir $DATADIR
  fi
  chmod 777 $DATADIR
  chown diradmin:diradmin $DATADIR
 
  if [ ! -d "$PLUGINPATH" ]; then
    mkdir $PLUGINPATH
  fi
  chmod 777 $PLUGINPATH
  chown -R diradmin:diradmin $PLUGINPATH
  
  if [ ! -d "$SKINPATH" ]; then
    mkdir $SKINPATH
  fi
  chmod 755 $SKINPATH
  chown -R diradmin:diradmin $SKINPATH
  
  cd $SKINPATH
  echo -n "Downloading skin files...            "

  if [ "$SKCOLOR" = "2" ]; then
      wget -q -O $SKINPATH/$SKINDIRNAME.tar.gz $SOURCEPATH/capri_grey.tar.gz
  else
      wget -q -O $SKINPATH/$SKINDIRNAME.tar.gz $SOURCEPATH/capri.tar.gz
  fi

  # aca chequeo si el archivo se descargo
  if [ ! -f "$SKINPATH/$SKINDIRNAME.tar.gz" ]; then
    echo -e "\e[1;31m Failed \e[40;37m\e[0m"; echo""
    echo -e "*** An error occur while downloading files. Please try again or contact support."
    echo ""
    cd $THISPATH
    exit 0;
  fi
  
  # aca chequeo si pesa menos de 150k
  if [ `du -k $SKINPATH/$SKINDIRNAME.tar.gz |awk '{print $1}'` -lt 200 ]; then
    # Si pesa menos lo abro a ver que contiene
    if [ `du -b $SKINPATH/$SKINDIRNAME.tar.gz |awk '{print $1}'` -lt 10 ]; then
      FILEDATA=`cat $SKINPATH/$SKINDIRNAME.tar.gz`
    fi
    # Si contiene la palabra "license" es por que es una licencia incorrecta
    if [ "$FILEDATA" = "license" ]; then
      rm -f $SKINPATH/$SKINDIRNAME.tar.gz
      echo -e "\e[1;31m Failed \e[40;37m\e[0m"; echo""
      echo -e "*** The license key entered is not active or it is invalid."
      echo ""
      cd $THISPATH
      exit 0;
    fi
    # Si se descargo otra cosa, borro y termino
    rm -f $SKINPATH/$SKINDIRNAME.tar.gz
    echo -e "\e[1;31m Failed \e[40;37m\e[0m"; echo""
    echo -e "*** An error occur while downloading files. Cannot reach source download URL. Please try again or contact support."
    echo ""
    cd $THISPATH
    exit 0;
  fi
  
  echo -e "\e[1;32m Done \e[40;37m\e[0m "
  
  echo -n "Decompressing skin files...          "
  tar xfz $SKINPATH/$SKINDIRNAME.tar.gz
  
  if [ ! -f "$SKINPATH/files_admin.conf" ]; then
    echo -e "\e[1;31m Failed \e[40;37m\e[0m"; echo""
    echo -e "*** An error occur while decompressing files. Please try again or contact support."
    echo ""
    cd $THISPATH
    exit 0;
  fi
  
  echo -e "\e[1;32m Done \e[40;37m\e[0m "
  
  if [ -f "$PLUGINPATH/loginpage" ]; then
    echo -n "Installing login page skin...        "
    if [ "$SKCOLOR" = "2" ]; then
      wget -q -O /usr/local/directadmin/data/templates/capri_login.tar.gz $SOURCEPATH/capri_login_grey.tar.gz
    else
      wget -q -O /usr/local/directadmin/data/templates/capri_login.tar.gz $SOURCEPATH/capri_login.tar.gz
    fi
    cd /usr/local/directadmin/data/templates/
    tar xfz capri_login.tar.gz
    chmod 755 /usr/local/directadmin/data/templates/login_images
    chown diradmin:diradmin /usr/local/directadmin/data/templates/login_images
    chown diradmin:diradmin /usr/local/directadmin/data/templates/login_images/*
    chown diradmin:diradmin /usr/local/directadmin/data/templates/login.html
    rm -f capri_login.tar.gz
    echo -n "1" > $PLUGINPATH/loginpage
    
    echo -e "\e[1;32m Done \e[40;37m\e[0m "
    
  fi
  
  echo -n "Setting permissions...               "
  
  mv $SKINPATH/skin_data/cron.sh $PLUGINPATH/cron.sh
  rm -f $SKINPATH/skin_data/*
  rmdir $SKINPATH/skin_data
  chmod 666 $PLUGINPATH/*
  chmod 755 $PLUGINPATH/cron.sh
  chmod 777 $PLUGINPATH
  
  chown diradmin:diradmin $SKINPATH/*
  find $SKINPATH/ -type f -exec chmod 755 {} \;
  chmod 777 $SKINPATH/inc
  
  if [ ! -f "$PLUGINPATH/name" ]; then
    echo -n "$OLDSKINNAME" > $PLUGINPATH/name
  fi
  
  echo -n "$LICENSE" > $PLUGINPATH/license
	echo -n "$SKCOLOR" > $PLUGINPATH/color
  chmod 666 $PLUGINPATH/license
  
  # seteo cron
  perl -ni -e 'unless (m/Added by $SKINFNAME/) { print }' /etc/crontab 2>&1
  perl -ni -e 'unless (m/Added by $SKINFNAME/) { print }' /etc/crontab 2>&1
  echo "* * * * * root $PLUGINPATH/cron.sh > /dev/null 2>&1 # Added by $SKINFNAME" >> /etc/crontab
  
  echo -e "\e[1;32m Done \e[40;37m\e[0m "
  
  if [ -f "$PLUGINPATH/imagelogo" ]; then
    mv $SKINPATH/images/logo.gif $SKINPATH/images/logo.gif.bak
    cp $PLUGINPATH/imagelogo $SKINPATH/images/logo.gif
    chown diradmin:diradmin $SKINPATH/images/logo.gif
  fi
  
  # custom logo
  if [ -d "$PLUGINPATH/logos" ]; then
    cd $PLUGINPATH/logos
    
    for file in *; do
    {
      if [ -f "$PLUGINPATH/logos/$file" ] && [ ! -f "$SKINPATH/images/custom/$file.gif" ]; then
        cp $PLUGINPATH/logos/$file $SKINPATH/images/custom/$file.gif
      fi
    }
    done;
    
    chmod 666 $SKINPATH/images/custom/*
    chown diradmin:diradmin $SKINPATH/images/custom/*
    chmod 666 $PLUGINPATH/logos/*
    
    if [ -f "/usr/local/directadmin/data/admin/reseller.list" ]; then
      RESELLERS=`cat /usr/local/directadmin/data/admin/reseller.list`
      echo -n "" > $SKINPATH/files_custom.conf
      for LINE in $RESELLERS; do
      {
        echo "IMG_RESLOGO_$LINE=images/custom/$LINE.gif" >> $SKINPATH/files_custom.conf
      }
      done;
    fi
  fi
  
  # finalizo la instalacion
  echo "";echo ""
  echo -e "\e[1;37mCongratulations! $SKINFNAME has been updated.\e[40;37m\e[0m"
  echo ""
  
  exit 0;
}
####################################################################################################################################################

echo ""
echo ""
echo "________________________________________________________________________________________"
echo ""
echo ""

  if [ "$1" = "--license" ] && [ "$2" != "" ]; then
    ARG1=$2
  fi


if [ -f "/usr/local/directadmin/data/skin_data/$SKINDIRNAME/name" ]; then

  if [ -f "/usr/local/directadmin/data/skin_data/$SKINDIRNAME/name" ]; then
    OLDSKINNAME=`cat /usr/local/directadmin/data/skin_data/$SKINDIRNAME/name`
  fi
  
  if [ "$OLDSKINNAME" != "" ]; then
  
      echo -n "$SKINFNAME skin, named $OLDSKINNAME was found in the server. Do you want to update this skin? (y/n) [y]: "
      read UPDATE
      echo
      if [ "$UPDATE" != "n" ]; then
        doUpdate
      else
        echo -n "Do you want to make a fresh install? (y/n) [y]: "
        read FRESHINSTALL
        echo
        
        if [ "$FRESHINSTALL" != "n" ]; then
          doInstall
        else
          echo "Nothing to do. Good bye!"
        fi
      fi
    
  else
  
      echo "$SKINFNAME skin was found in the server, but we can't determine the name."
      echo -n "Please enter the skin name o press RETURN to a fresh install: ";
      read OLDSKINNAME
      echo
      
      if [ "$OLDSKINNAME" = "" ]; then
        doInstall
      else
        if [ -d "/usr/local/directadmin/data/skins/$OLDSKINNAME" ]; then
          doUpdate
        else
          echo -n "We cannot found $OLDSKINNAME location. Do you want to make a fresh install? (y/n) [y]: "
          read FRESHINSTALL
          echo
          
          if [ "$FRESHINSTALL" != "n" ]; then
            doInstall
          else
            echo "Nothing to do. Good bye!"
          fi
        fi
      fi
    
  fi
  
else

  cd /usr/local/directadmin/data/skins
  for dir in *; do
  {
    if [ -f "/usr/local/directadmin/data/skins/$dir/inc/data" ]; then
      OLDSKINNAME="$dir"
    fi
  }
  done;
  
  if [ -z "$OLDSKINNAME" ]; then
    doInstall
  else
    echo -n "Is $OLDSKINNAME the name of your actual installation of $SKINFNAME skin? (y/n) [y]: "
    read ISM
  fi
  
  if [ "$ISM" = "n" ]; then
    doInstall
  else
    SKNAME="$OLDSKINNAME"
    OVERWRITE="1"
    OLDLICENSE=`cat /usr/local/directadmin/data/skins/$OLDSKINNAME/inc/license`
    if [ "$OLDLICENSE" != "" ]; then
      echo -n "Is $OLDLICENSE the license key of you Marina skin= (y/n) [y]: "
      read ISL
      
      if [ "$ISM" = "n" ]; then
        doInstall
      else
        LICENSE="$OLDLICENSE"
        doInstall
      fi
    fi
  fi
  
fi

exit 0;