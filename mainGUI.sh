#!/bin/bash

#exit case
exit=1
while [ $exit == 1 ]
do

  # clear the screen
  tput clear

  # Move cursor to screen location X,Y (top left is 0,0)
  tput cup 3 15

  # Set a foreground colour using ANSI escape
  tput setaf 3
  echo "Faber's Test Environment"
  tput sgr0

  tput cup 5 17
  # Set reverse video mode
  tput rev
  echo "M A I N - M E N U"
  tput sgr0

  tput cup 7 15
  echo "1. Download New Inspection Data"

  tput cup 8 15
  echo "2. Process New Data"

  tput cup 9 15
  echo "3. Inspection Viewer Application"

  tput cup 10 15
  echo "4. Exit Program"

  # Set bold mode
  tput bold
  tput cup 12 15
  read -p "Enter your choice [1-4] " choice

  if [ "$choice" = "1" ]; then
      echo "Searching for External Drive"

  elif [ "$choice" = "2" ] ; then
      echo "Starting Pre Processing"

  elif [ "$choice" = "3" ] ; then

      echo "Starting Docker Containers"
      echo "docker-compose up -d --build"
      docker-compose up -d

      # Check for server
      while ! curl http://localhost
      do
        sleep 2
      done

      # Connect to local web application
      python -m webbrowser http://localhost

      # Option to Shutdown Containers
      appShutdown=1

      while [ $appShutdown = 1 ]
      do
        tput clear
        tput bold
        tput cup 12 15
        read -p "Shut Down Inspection Viewer [y/n] " answer </dev/tty

        # Leaving this Menu after stopping containers
        if [ "$answer" = "y" ]; then
          echo "Shutting Down Application"
          docker-compose stop
          appShutdown=0
        fi

      done

  elif [ "$choice" = "4" ] ; then
    # Exit Script
    tput clear
    exit 1

  else
      echo "Error 404"
  fi

done
tput clear
tput sgr0
tput rc
