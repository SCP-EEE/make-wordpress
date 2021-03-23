all: server_start

server_start: wordpress 
	export PASSWORD=$(shell pwgen -1)
	sudo ln -sf /etc/sv/mysqld /var/service/
	mysql_secure_installation
	mysql -u root -p -e "create database wordpresss; grant all privileges on wordpresss.* to $(value USER)@localhost identified by '$(value PASSWORD)'; FLUSH PRIVILEGES;"
	@echo you're pwssword is $(value PASSWORD)
	sudo chown -R nginx.nginx /usr/share/nginx/html/*
	sudo chmod -R 755 /usr/share/nginx/html/wp-admin /usr/share/nginx/html/wp-content /usr/share/nginx/html/wp-includes
	sudo chmod 644 /usr/share/nginx/html/*.php
	sudo ln -sf /etc/sv/nginx /var/service/
	sudo ln -sf /etc/sv/php-fpm /var/service/

wordpress: configure
	wget https://ja.wordpress.org/latest-ja.zip
	unzip *.zip
	sudo mv wordpress/* /usr/share/nginx/html/

configure: depend_install
	sudo sed -i "s/user = http/user = nginx/" /etc/php/php-fpm.d/www.conf
	sudo sed -i "s/group = http/group = nginx/" /etc/php/php-fpm.d/www.conf
	sudo sed -i "s/listen = 127.0.0.1:9000/listen = \/tmp\/www.sock/" /etc/php/php-fpm.d/www.conf
	sudo sed -i "s/;listen.owner = http/listen.owner = nginx/" /etc/php/php-fpm.d/www.conf
	sudo sed -i "s/;listen.group = http/listen.group = nginx/" /etc/php/php-fpm.d/www.conf
	sudo sed -i "s/;extension=curl/extension=curl/" /etc/php/php.ini
	sudo sed -i "s/;extension=mysqli/extension=mysqli/" /etc/php/php.ini
	sudo sed -i "s/;extension=openssl/extension=openssl/" /etc/php/php.ini
	sudo patch /etc/nginx/nginx.conf nginx.conf.diff

depend_install: clean
	sudo xbps-install -y -f nginx php-fpm mysql dma pwgen php php-mysql

clean:
	sudo ln -sf /etc/sv/mysqld /var/service/
	sudo rm -f /etc/nginx/nginx.conf
	sudo rm -f /etc/php/php-fpm.d/www.conf
	sudo rm -f /etc/php/php.ini
	sudo rm -rf /usr/share/nginx/html/*
	sudo rm -f /var/service/nginx
	sudo rm -f /var/service/php-fpm
	rm -f *.zip
	rm -rf wordpress
	mysql -u root -p -e "drop database wordpresss;" -f
	sudo rm -f /var/service/mysqld

uninstall:
	sudo xbps-remove -R php-fpm php-mysql nginx dma pwgen php
