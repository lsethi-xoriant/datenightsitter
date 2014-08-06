
#update system
sudo yum -y update


# *********************************
#      Setting up Ruby / RVM
# *********************************

#download Ruby dependencies
sudo yum -y install readline-devel git make zlib-devel sqlite-devel.x86_64 gcc g++ svn
sudo yum -y install -y gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl openssl-devel make bzip2 autoconf automake libtool bison iconv-devel
sudo yum -y install curl-devel httpd-devel apr-devel apr-util-devel ruby-devel




# install rvm and latest ruby;   This will take awhile... grab a cup of coffee... most likely it will need to compile the ruby binary
\curl -L https://get.rvm.io | sudo bash -s stable

#add users to groups as specified
sudo usermod -a -G rvm ec2-user

#logged out and logged back in


#  Exit shell(s) and reload
source /etc/profile.d/rvm.sh

#logged out and logged back in



#  install ruby for RVM
rvm install 2.1.2
#rvm reinstall 1.9.3 --verify-downloads 1    #had to reinstall b/c rubygems-2.1.7 released today and did not have a checksum
rvm use --default 2.1.2


# to update rvm, needed to go into sudo mode
sudo -s
rvm get stable
exit


# *********************************
#      setting up MySQL and postgresql
# *********************************
#install db engines, however no need to have it running as we are using AWS RDS
sudo yum -y install mysql mysql-server mysql-devel postgresql-devel





# *********************************
#      Build a swap file
# *********************************
sudo dd if=/dev/zero of=/swapfile1 bs=1M count=1024
sudo mkswap /swapfile1
sudo chown root:root /swapfile1
sudo chmod 0600 /swapfile1
sudo swapon /swapfile1
sudo echo "/swapfile1    swap    swap    defaults    0   0" >> /etc/fstab


# *********************************
#      setting up Apache
# *********************************


#install apache webserver
sudo yum -y install httpd  
sudo chkconfig httpd on
sudo service httpd start
sudo echo "<html><header></header><body><h1>test page</h1></body></html>" > /var/www/index.html



# *********************************
#      Setting up Passenger
# *********************************



#install passenger
sudo -s
    gem install passenger
    passenger-install-apache2-module
exit

#add LoadModule and virtual host config into httpd.conf and import

#   LoadModule passenger_module /usr/local/rvm/gems/ruby-2.1.2/gems/passenger-4.0.48/buildout/apache2/mod_passenger.so
#   
#  <IfModule mod_passenger.c>
#     PassengerRoot /usr/local/rvm/gems/ruby-2.1.2/gems/passenger-4.0.48
#     PassengerDefaultRuby /usr/local/rvm/gems/ruby-2.1.2/wrappers/ruby
#   </IfModule>

# *********************************
#      Configure Apache for app
# *********************************
sudo chmod 777 /etc/httpd/conf/httpd.conf
#EXIT AWS SHELL
cd ~/sites/datenightsitter/z_db/etc/httpd/conf
scp ~/sites/datenightsitter/z_db/etc/httpd/conf/httpd.conf web01.datenightsitter.net:/etc/httpd/conf/httpd.conf

#re-enter shell


# *********************************
#      Build App Repos
# *********************************

#make repositories
sudo mkdir /www
sudo chown -R ec2-user:ec2-user /www
sudo chmod -R g+rwx /www

mkdir /www/sites
mkdir /www/sites/datenightsitter


# *********************************
#     confirm SSH
# *********************************

# test ssh forwardagent and get RSA fingerprint
ssh -T git@github.com



# *********************************
#     restart Apache
# *********************************
sudo service httpd restart
