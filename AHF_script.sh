GNU nano 2.7.4                                      File: AHF_script.sh                                      

#!/bin/bash
# This script should completely set up AutoHeadFixer on a blank Raspberry pi.
#$ sudo chmod 777 AFH_script.sh
#$ ./AFH_script.sh

read -p "Select 0 for dependancy install or any key for a full installation" userinput  #DEFAULT:false for developing - setting purge =true deletes the cr$

if [ $userinput -eq 0 ];
        then
                echo "TRUE"
        else
                echo "no purge"
fi

mkdir AutoHeadFixSetup
cd AutoHeadFixSetup


#updates pi, bypassing y/n prompts, clears out unused packages
sudo apt-get update && sudo apt-get upgrade -y && apt-get autoremove && apt-get autoclean



echo "downloading AHF repository lever_config branch"
git clone --single-branch --branch lever_config https://github.com/jamieboyd/AutoHeadFix
#cd AutoHeadFix

echo "cloning pulsedThread and building makefile"
git clone https://github.com/jamieboyd/pulsedThread.git
cd pulsedThread
sudo make
sudo make install
python3 setup_ptGreeter.py install
python3 setup_pyPTpyFuncs.py install

#mv * ..
cd ..
#rmdir pulsedThread


echo "Cloning GPIO_Thread"
git clone https://github.com/jamieboyd/GPIO_Thread.git
cd GPIO_Thread
python3 HX711_setup.py install # is this neccesary??

python3 SimpleGPIO_setup.py install
python3 StepperMotor_setup.py install 
python3 leverThread_setup.py install 
python3 PWM_thread_setup.py install

#mv * ..
cd ..
#rmdir GPIO_Thread

echo "cloning rfid reader"
git clone https://github.com/jamieboyd/RFIDTagReader.git
cd RFIDTagReader
python3 RFIDTagReader_setup.py install
#mv * ..
cd ..
#rmdir RFIDTagReader

echo "cloning adafruit python mpr121"
git clone https://github.com/adafruit/Adafruit_Python_MPR121.git
cd Adafruit_Python_MPR121
sudo python3 setup.py install
#mv * ..
cd .. 
#rmdir Adafruit_Python_MPR121

echo "Cloning pca9685"
git clone https://github.com/adafruit/Adafruit_Python_PCA9685.git
cd Adafruit_Python_PCA9685
sudo python3 setup.py install
cd ..


echo "cloning adafruit GPIO"
git clone https://github.com/adafruit/Adafruit_Python_GPIO.git 
cd Adafruit_Python_GPIO
#mv * ..
sudo python3 setup.py install
cd ..

#rm Adafruit_Python_GPIO


echo "cloning touch detector"
git clone https://github.com/Judge24601/TouchDetector.git
cd TouchDetector
python3 TouchDetector_setup.py install
#mv * ..
cd ..
#rm TouchDetector


echo "installing pypy and remaining modules (mysql-server, php-mysql, pymysql)"
sudo apt-get install pypy mysql-server php-mysql -y
python3 -m pip install PyMySQL -y
#pip3 install adafruit-circuitpython-mpr121

if [ $userinput -eq 0 ];
         then
                echo "Purge requested"
                cd ..
                sudo rm -rf AutoHeadFixSetup
        else 
                echo "no purge"
                cd AutoHeadFix/
                _path=$PWD
                cd ~
                sudo touch .bash_aliases
                sudo echo "alias ahf='cd $_path'" | sudo tee .bash_aliases
fi

echo "setting up database"

sudo apt install mariadb-server -y


sudo mysql_secure_installation  #-Y option for more sequre install 

sudo apt-get install libatlas-base-dev -y 
sudo apt-get install python3-scipy -y
sudo pip3 install imreg_dft
sudo pip3 install matplotlib
sudo pip3 install pynput
sudo pip3 install h5py -y
sudo pip3 install h5py -y #Not a typo. Sometimes needs to be run twice
sudo apt-get install libhdf5-dev -y

#to pass commands from command line: sudo mysql -u root -p password -e "Multiple sql commands seperated by ;"
#example: sudo mysql -u root -p password -e "SHOW DATABASES;SHOW DATABASES" // will login to mysql and execute show databases two times
#sudo mysql -u root -p password -e "CREATE DATABASE databasename;CREATE USER 'exampleuser'@'localhost' IDENTIFIED BY 'password';"
#gather inputs for database creation


read -p "please enter the root password you just created: " rootp
read -p "Please enter the name of the new user you would like to create:  " user
read -p "Please enter the password you would like to associate with above user " password
read -p "Please enter a name for database you would like to create and grant $user access too? " database
# read -p "Please enter an address for localHost" localhost 

cat << END
***************************************************************
a mysql user and database will now be set up with the following:
username: $user
password: $password
database: $database
***************************************************************
END

sudo mysql -u root -p$rootp -e "CREATE DATABASE $database;CREATE USER '$user'@'localhost' IDENTIFIED BY '$password';GRANT ALL PRIVILEGES ON raw_data.* TO '$user'@'localhost';FLUSH PRIVILEGES"
#CREATE DATABASE exampledb;
#CREATE USER 'exampleuser'@'localhost' IDENTIFIED BY 'pimylifeup';
#GRANT ALL PRIVILEGES ON exampledb.* TO 'exampleuser'@'localhost';
sudo apt install phpmyadmin -y  #select apache 2 by pressing space and then enter, select yes at the next prompt then set password
echo "Install complete"

