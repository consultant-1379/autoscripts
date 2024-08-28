#!/usr/bin/bash

__checkSubtitute ()

{
  if [[ $? -ne 0 ]];then
    echo "Subtitute failed."
    echo "Exiting."
    echo
    exit

  fi
}

__checkCopy ()

{
  if [[ $? -ne 0 ]];then
    echo "Copy failed."
    echo "Exiting."
    echo
    exit

  fi
}

__checkAdd ()

{
  if [[ $? -ne 0 ]];then
    echo "Addition failed."
    echo "Exiting."
    echo
    exit

  fi
}

__checkSolarisPackages ()

{
  sol_pkgs=(SUNWmfrun SUNWarc SUNWbtool SUNWhea SUNWlibms \
            SUNWmfrun SUNWxorg-client-programs \
            SUNWxorg-clientlibs SUNWxwfsw SUNWxwplt \
            )

  for pkgs in ${sol_pkgs[@]}
  do
    pkginfo -l $pkgs >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
      echo "$pkgs not found."
      echo "Exiting."
      echo
      exit;
    fi

  done
}


__checkFontCitrix ()

{
  if [[ -f $CTXXTW ]];then
    perl -pi -e 's/CMAP=\$OPENWINHOME\/lib\/rgb/CMAP=\/usr\/share\/X11\/rgb/g' $CTXXTW >/dev/null 2>&1; __checkSubtitute
    perl -pi -e 's/usr\/openwin\/lib\/X11\/fonts\/Type1\/,\\/usr\/share\/fonts\/X11\/Type1\/,\\/g' $CTXXTW >/dev/null 2>&1; __checkSubtitute
    perl -pi -e 's/usr\/openwin\/lib\/X11\/fonts\/75dpi\/,\\/usr\/share\/fonts\/X11\/75dpi\/,\\/g' $CTXXTW >/dev/null 2>&1; __checkSubtitute
    perl -pi -e 's/usr\/openwin\/lib\/X11\/fonts\/100dpi\/,\\/usr\/share\/fonts\/X11\/100dpi\/,\\/g' $CTXXTW >/dev/null 2>&1; __checkSubtitute

    perl -ni -e 'if(!/usr\/openwin\/lib\/X11\/fonts\/Speedo\/,\\/){print;}' $CTXXTW >/dev/null 2>&1;
    if [[ $? -ne 0 ]];then
      echo "Issue while editing $CTXXTW . Please check"
      echo "Exiting"
      echo
      exit
    fi

    perl -pi -e 's/usr\/openwin\/lib\/X11\/fonts\/F3bitmaps/usr\/X11\/lib\/X11\/fonts\/F3bitmaps/g' $CTXXTW >/dev/null 2>&1; __checkSubtitute
    perl -pi -e 's/usr\/openwin\/lib\/X11\/fonts\/TrueType/usr\/share\/fonts\/TrueType/g' $CTXXTW >/dev/null 2>&1; __checkSubtitute

  else
    echo "$CTXXTW - No such file or directory."
    echo "Exiting."
    echo
    exit;

  fi

}


__checkCtxSession ()

{
  if [[ -f $CTXSESSION ]];then
    perl -pi -e 's/JDS_WM/GDM_WM/g' $CTXSESSION >/dev/null 2>&1; __checkSubtitute
    perl -pi -e 's/JDS_MESSAGE/GDM_MESSAGE/g' $CTXSESSION >/dev/null 2>&1; __checkSubtitute
    perl -pi -e 's/JDS_MESSAGE/GDM_MESSAGE/g' $CTXSESSION >/dev/null 2>&1; __checkSubtitute
    perl -pi -e 's/DESKTOP_WM\:\=\"\$GDM_WM\"/DESKTOP_WM\:\=\"\$XDM_WM\"/g' $CTXSESSION >/dev/null 2>&1; __checkSubtitute
    perl -pi -e 's/usr\/dt\/config\/Xsession2.jds/usr\/bin\/gnome-session/g' $CTXSESSION >/dev/null 2>&1; __checkSubtitute
    perl -pi -e 's/usr\/dt\/bin\/Xsession/usr\/bin\/gnome-session/g' $CTXSESSION >/dev/null 2>&1; __checkSubtitute

    if [[ `grep 'XDM_WM:="/etc/gdm/Xsession"' $CTXSESSION | wc -l` -eq 0 ]];then
      sed '/GDM_MESSAGE\:="/a\
: ${XDM_WM:="/etc/gdm/Xsession"}' $CTXSESSION > $TMP/ctxsession; __checkAdd

      mv $TMP/ctxsession $CTXSESSION 2>/dev/null;
      if [[ $? -ne 0 ]];then
        echo "Issue while applying workaround. Not able to edit $CTXSESSION"
        echo
        exit
      fi
    fi

  else
    echo "$CTXSESSION - No such file or directory."
    echo "Exiting."
    echo
    exit;

  fi

}


__checkERICPortd ()

{
  if [[ ! -f $ERICPORTDXML ]];then
    cp $SECPF_ERICPORTDXML $ERICPORTDXML; __checkCopy
    cp $SECPF_ERICPORTDXML $ERIC_CONFIG; __checkCopy
    $SVCCFG import $ERIC_CONFIG/ericportd.xml
    if [[ $? -ne 0 ]];then
      echo "Import failed."
      echo "Exiting."
      echo
    fi
  fi

}


__checkSymJavaLink ()

{
  #Check if java libraries are linked properly
  LINKED_DIR=`ls -l $CTXSMF|grep javalibs|awk '{print $11}'`

  if [[ -z $LINKED_DIR ]];then
    echo "Java library files are not linked"
  fi

  if [[ $LINKED_DIR != *$JDK_VERSION* ]];then
    echo "Linking java library files..."
    ln -s $JAVA_LIB_PATH $CTXSMF/javalibs 2>/dev/null
    if [[ $? -ne 0 ]];then
      echo "Java libraries didn't link properly."
      echo "Exiting"
      exit
    fi
  fi

  # Checking java libraries again to confirm
  if [[ `ls -l $CTXSMF | grep "$JDK_VERISON" | wc -l` -eq 0 ]];then
    echo "Issue with Java libraries. Please check"
    echo "Exiting."
    echo
    exit
  fi

}

__checkNFSMapID ()

{
  NFSMAPID=`grep -i "NFSMAPID_DOMAIN" $NFS|awk -F"=" '{print $2}'`
  if [[ -z $NFSMAPID ]];then
    echo "NFS Map ID is not set in $NFS"
    echo "Setting NFS Map ID..."
    echo
    sharectl set -p nfsmapid_domain=vts.com nfs

    #Lets Check Again
    NFSMAPID=`grep -i "NFSMAPID_DOMAIN" $NFS|awk -F"=" '{print $2}'`
    if [[ -z $NFSMAPID ]];then
      echo "Unable to set NFS Map ID in $NFS. Please check."
      echo "Exiting."
      echo
      exit
    fi
  fi
}


##############
#### MAIN ####
##############

CTXSMF="/opt/CTXSmf/"
CTXXTW="/opt/CTXSmf/slib/ctxXtw.sh"
CTXSESSION="/opt/CTXSmf/lib/ctxsession.sh"
ERICPORTDXML="/var/svc/manifest/ericsson/cominf/ericportd.xml"
SECPF_ERICPORTDXML="/opt/ericsson/secpf/portd/etc/ericportd.xml"
ERIC_CONFIG="/ericsson/config/"
SVCCFG="/usr/sbin/svccfg"
TMP="/tmp"
JDK_VERISON="1.6.0"
NFS="/etc/default/nfs"
JAVA_LIB_PATH="/usr/jdk/instances/java1.6.0/jre/lib/i386"
JAVA_LIB_PATH1="/usr/jdk/instances/jdk1.7.0/jre/lib/i386"


#__checkSolarisPackages
__checkFontCitrix
__checkCtxSession
__checkERICPortd
__checkSymJavaLink
__checkNFSMapID


##############
#### END  ####
##############


