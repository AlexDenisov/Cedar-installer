
CEDAR_LOG=/tmp/cedar-installer.log
FINAL_FRAMEWORK_PATH=$HOME/cedar-framework
CEDAR_INSTALLER_DIR=$PWD
CEDAR_INSTALL_DIR=/opt/cedar

function exit_fail {
  echo "See '"$CEDAR_LOG"' for more details."
  $CEDAR_INSTALLER_DIR/uninstall.sh
  exit 1
}

function exit_success {
  echo "Cedar builded successfully."
  echo "You can see '"$CEDAR_LOG"' for more details."
  echo "To remove Cedar run " $CEDAR_INSTALL_DIR"/uninstall.sh."
  exit 0
}

function check_exit_code {
  if [ $? -ne 0 ]
  then
    echo " Failed!"
    exit_fail
  else
    echo " Done."
  fi
}

function check_exit_code_quiet {
  if [ $? -ne 0 ]
  then
    echo " Failed!"
    exit_fail
  else
    printf "."
  fi
}

function link_cedar {
  SRC_FRAMEWORK=$PWD/$1
  DST_FRAMEWORK=$FINAL_FRAMEWORK_PATH/$2
  printf "\t"$2"" #"$DST_FRAMEWORK"."
  ln -s $SRC_FRAMEWORK $DST_FRAMEWORK > $CEDAR_LOG 2>&1
  check_exit_code
}

printf "Create installation dir."
sudo mkdir -p $CEDAR_INSTALL_DIR > $CEDAR_LOG 2>&1
check_exit_code_quiet
sudo chown `whoami` $CEDAR_INSTALL_DIR > $CEDAR_LOG 2>&1
check_exit_code_quiet
cd $CEDAR_INSTALL_DIR > $CEDAR_LOG 2>&1
check_exit_code

printf "Clone OCHamcrest project from Github."
git clone git://github.com/pivotal/OCHamcrest.git > $CEDAR_LOG 2>&1
check_exit_code

printf "Clone Cedar project from Github."
git clone git://github.com/pivotal/cedar.git > $CEDAR_LOG 2>&1
check_exit_code

printf "Initialize Cedar submodules."
cd cedar > $CEDAR_LOG 2>&1
check_exit_code_quiet
git submodule update --init > $CEDAR_LOG 2>&1
check_exit_code_quiet
cd .. > $CEDAR_LOG 2>&1
check_exit_code

printf "Build all targets from OCHamcrest project."
xcodebuild -project OCHamcrest/Source/OCHamcrest.xcodeproj -alltargets > $CEDAR_LOG 2>&1
check_exit_code

printf "Build all targets from OCMock project."
xcodebuild -project cedar/Externals/OCMock/Source/OCMock.xcodeproj -alltargets > $CEDAR_LOG 2>&1
check_exit_code

printf "Build Cedar-StaticLib from Cedar project."
xcodebuild -project cedar/Cedar.xcodeproj -target Cedar-StaticLib > $CEDAR_LOG 2>&1
check_exit_code

printf "Build Cedar-iOS.framework from Cedar project."
xcodebuild -project cedar/Cedar.xcodeproj -target Cedar-iOS > $CEDAR_LOG 2>&1
check_exit_code

printf "Creating "$FINAL_FRAMEWORK_PATH" directory."
mkdir $FINAL_FRAMEWORK_PATH > $CEDAR_LOG 2>&1
check_exit_code

echo "Create symbolic links to" $FINAL_FRAMEWORK_PATH":"
link_cedar "/OCHamcrest/Source/build/Release/OCHamcrest.framework" "OCHamcrest.framework"
link_cedar "/OCHamcrest/Source/build/Release-iphoneuniversal/OCHamcrest-iPhone.framework" "OCHamcrest-iPhone.framework"
link_cedar "/cedar/Externals/OCMock/Source/build/Release/OCMock.framework" "OCMock.framework"
link_cedar "/cedar/Externals/OCMock/Source/build/Release-iphoneuniversal/OCMock-iPhone.framework" "OCMock-iPhone.framework"
link_cedar "/cedar/build/Release/Cedar.framework" "Cedar.framework"
link_cedar "/cedar/build/Release-iphoneuniversal/Cedar-iOS.framework" "Cedar-iOS.framework"

printf "Copy supported files."
cp $CEDAR_INSTALLER_DIR/uninstall.sh $CEDAR_INSTALL_DIR > $CEDAR_LOG 2>&1
check_exit_code

exit_success
