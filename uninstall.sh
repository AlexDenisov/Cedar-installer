function check_exit_code {
  if [ $? -ne 0 ]
  then
    echo " Failed!"
  else
    echo " Done."
  fi
}

function check_exit_code_quiet {
  if [ $? -ne 0 ]
  then
    echo " Failed!"
  else
    printf "."
  fi
}

printf "Cleaning Cedar."
rm -rf ~/cedar-framework
check_exit_code_quiet
sudo rm -rf /opt/cedar
check_exit_code
