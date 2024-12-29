#!/usr/bin/bash

#functions
checkwichinstalltype() {
    echo "Which installation type would you like to choose for installing the software?(github/fresh/withdata)"

    read installationtype

    if [ "$installationtype" = "fresh" ] || [ "$installationtype" = "github" ]; then
        echo "enter app link in githup:"
        read applinkingit

        echo "enter co link in githup:"
        read colinkingit

        echo "enter api link in githup:"
        read apilinkingit

        echo "enter backup link:"
        read fullbackup

    elif [ "$installationtype" = "withdata" ]; then
        echo "enter backup link:"
        read fullbackup
    elif [ "$installationtype" = "widthgoogledrive" ]; then
        echo "enter link of backup:"
        read googledrivelink
    else
        echo "Invalid option."
    fi
}
editdonenv() {
    COENVFILE="/home/foreveri/public_html/forever-co/.env"
    >"$COENVFILE"
    echo "BASE_URL=https://laraapi.$domain/api/" >>"$COENVFILE"
    echo "WEB_BASE_URL=https://$domain" >>"$COENVFILE"
    echo "API_BASE_URL=https://laraapi.$domain" >>"$COENVFILE"

    SHOPNOW="/home/foreveri/public_html/forever-shopnow/.env"
    >"$SHOPNOW"
    echo "BASE_URL=https://laraapi.$domain/api/" >>"$SHOPNOW"
    echo "WEB_BASE_URL=https://$domain" >>"$SHOPNOW"
    echo "API_BASE_URL=https://laraapi.$domain" >>"$SHOPNOW"
    echo "NO_INDEX=false" >>"$SHOPNOW"

}

installapps() {
    cd /home/foreveri/public_html/forever-shopnow/
    npm i
    yes no | npm run build
    yes no | npm run deploy

    cd /home/foreveri/public_html/forever-co/
    npm i
    yes no | npm run build
    yes no | npm run deploy
}
newfreshinstall(){
    cd /root

    wget --no-check-certificate "$fullbackup" -O foreveri.tar.gz

    tar -xvzf foreveri.tar.gz

    fullbackupinstall
}
freshinstallation() {
    cd /root
    git clone $applinkingit
    git clone $colinkingit
    git clone $apilinkingit

    mv /root/forever-shopnow/ /home/foreveri/public_html/forever-shopnow/

    #add panel folder and deploy

    mv /root/forever-co/ /home/foreveri/public_html/forever-co/

    editdonenv

    installapps

    #add api folder
    rm -rf /root/forever-laraapi/public/storage
    rm -rf /home/foreveri/public_html/laraapi/
    mv /root/forever-laraapi/ /home/foreveri/public_html/laraapi/
    cd /home/foreveri/public_html/laraapi/public/
    ln -s ../storage/app/public storage
    cd /home/foreveri/public_html/laraapi
    chmod -R 777 ./*
    php artisan config:cache
    php artisan cache:clear

}
composerandupdate() {
    cd ~
    curl -sS https://getcomposer.org/installer -o composer-setup.php
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer

    cd /home/foreveri/public_html/laraapi
    yes yes | composer update

    php artisan config:cache
    php artisan cache:clear
}
fullbackupinstall() {
    # remove node modules folder

    rm -rf /root/foreveri/homedir/public_html/forever-shopnow/node_modules/
    rm -rf /root/foreveri/homedir/public_html/forever-co/node_modules/

    #remove exiting app folder

    rm -rf /home/foreveri/public_html/forever-shopnow/*
    rm -rf /home/foreveri/public_html/forever-co/*
    rm -rf /home/foreveri/public_html/laraapi/*

    #add store folder and deploy

    mv /root/foreveri/homedir/public_html/forever-shopnow/ /home/foreveri/public_html/

    #add panel folder and deploy

    mv /root/foreveri/homedir/public_html/forever-co/ /home/foreveri/public_html/

    editdonenv

    installapps

    #add api folder
    rm -rf foreveri/homedir/public_html/laraapi/public/storage
    mv /root/foreveri/homedir/public_html/laraapi/ /home/foreveri/public_html/
    cd /home/foreveri/public_html/laraapi/public/
    ln -s ../storage/app/public storage
    cd /home/foreveri/public_html/laraapi
    chmod -R 777 ./*
    php artisan config:cache
    php artisan cache:clear
}

getwhmlink() {
    echo "enter whm token:"
    read whmtoken

    # Capture the return value of the function
    result=$(check_token_format "$whmtoken")

    # Check if the return value is 1 and echo "success"
    if [ "$result" -eq 0 ]; then
        echo "Token not correct."
        exit 1
    fi
}

installreq() {
    # Check if curl is already installed
    if command -v curl &>/dev/null; then
        echo "curl is already installed."
    else
        # Install curl
        echo "Installing curl..."
        sudo apt-get update
        sudo apt-get install -y curl
    fi

    if command -v unzip &>/dev/null; then
        echo "unzip is already installed."
    else
        # Install unzip
        echo "Installing unzip..."
        sudo apt-get update
        sudo apt-get install -y unzip
    fi

    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

    nvm install 14

    npm install -g pm2

    if ! command -v git &>/dev/null; then
        echo "Git is not installed. Installing Git..."
        sudo apt-get install -y git
    else
        echo "Git is already installed."
    fi
}

domaininstallation() {
    serverip=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

    # Define WHM credentials and API URL
    whm_username="root"
    createacct_url="https://$serverip:2087/json-api/createacct"
    api_version="1"
    username="foreveri"
    echo "enter currect domain:"
    read domain
    ###domain="foreveriranians.com"

    # Construct the command
    createact="wget --header=\"Authorization: whm $whm_username:$whmtoken\" \
    --spider --no-check-certificate \"$createacct_url?api.version=$api_version&username=$username&domain=$domain\""

    # Execute the command
    eval "$createact"
}

subdomainforonlineshop() {
    ######### create shop subdomain

    echo "enter domain for online shop"

    read onlineshopdomain

    # Construct the command
    shopsubdomain="wget --header=\"Authorization: whm $whm_username:$whmtoken\" \
    --spider --no-check-certificate \"$subdomain_url?api.version=$api_version&domain=$onlineshopdomain&document_root=public_html/shopnow\""

    # Execute the command
    eval "$shopsubdomain"
}
cosubdomaininstallation() {
    subdomain_url="https://$serverip:2087/json-api/create_subdomain"

    echo "enter domain for organization panel: "

    read organizationdomain

    # Construct the command
    cosubdomain="wget --header=\"Authorization: whm $whm_username:$whmtoken\" \
    --spider --no-check-certificate \"$subdomain_url?api.version=$api_version&domain=$organizationdomain&document_root=public_html/co\""

    # Execute the command
    eval "$cosubdomain"
}
apisubdomaininstallation() {
    # Construct the command
    laraapisubdomain="wget --header=\"Authorization: whm $whm_username:$whmtoken\" \
    --spider --no-check-certificate \"$subdomain_url?api.version=$api_version&domain=laraapi.$domain&document_root=public_html/laraapi/public\""

    # Execute the command
    eval "$laraapisubdomain"

    ########## download and unzip backup folder

}
check_token_format() {
    local token=$1
    local pattern='^[A-Za-z0-9]{10,}$' # Regular expression pattern for WHM token format

    if [[ $token =~ $pattern ]]; then
        echo "1"
    else
        echo "0"
    fi
}
getgooglebackupdate() {
    cd /root

    wget --no-check-certificate "$googledrivelink" -O foreveri.tar.gz

    tar -xvzf foreveri.tar.gz

    fullbackupinstall
}

makeapachedir() {
    if [ ! -e "/etc/apache2/conf.d/userdata" ]; then
        mkdir /etc/apache2/conf.d/userdata
    fi
    if [ ! -e "/etc/apache2/conf.d/userdata/ssl" ]; then
        mkdir /etc/apache2/conf.d/userdata/ssl
    fi
    if [ ! -e "/etc/apache2/conf.d/userdata/ssl/2_4" ]; then
        mkdir /etc/apache2/conf.d/userdata/ssl/2_4
    fi
    if [ ! -e "/etc/apache2/conf.d/userdata/ssl/2_4/foreveri" ]; then
        mkdir /etc/apache2/conf.d/userdata/ssl/2_4/foreveri
    fi
}
domainapacheconfig() {
    if [ ! -e "/etc/apache2/conf.d/userdata/ssl/2_4/foreveri/$domain" ]; then
        mkdir /etc/apache2/conf.d/userdata/ssl/2_4/foreveri/$domain
    fi

    shopconf="/etc/apache2/conf.d/userdata/ssl/2_4/foreveri/$domain/$domain.conf"
    shopproxy="ProxyPass / http://localhost:3200/"
    shopproxyrev="ProxyPassReverse / http://localhost:3200/"

    if [ ! -e "$shopconf" ]; then
        touch "$shopconf"
        echo "$shopproxy" >>""$shopconf""
        echo "$shopproxyrev" >>""$shopconf""
    fi

}
codomainapacheconfig() {
    if [ ! -e "/etc/apache2/conf.d/userdata/ssl/2_4/foreveri/co.$domain" ]; then
        mkdir /etc/apache2/conf.d/userdata/ssl/2_4/foreveri/co.$domain
    fi

    coconf="/etc/apache2/conf.d/userdata/ssl/2_4/foreveri/co.$domain/co.$domain.conf"
    coproxy="ProxyPass / http://localhost:3400/"
    coproxyrev="ProxyPassReverse / http://localhost:3400/"

    if [ ! -e "$coconf" ]; then
        touch "$coconf"
        echo "$coproxy" >>""$coconf""
        echo "$coproxyrev" >>""$coconf""
    fi
}

mysqluseranddb() {
    mysql -e "
        CREATE DATABASE IF NOT EXISTS foreveri_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
        CREATE USER IF NOT EXISTS 'foreveri_db'@'localhost' IDENTIFIED BY '@Forever2022';
        GRANT ALL PRIVILEGES ON foreveri_db.* TO 'foreveri_db'@'localhost';
        FLUSH PRIVILEGES;
        ALTER USER 'foreveri_db'@'localhost' IDENTIFIED BY '@Forever2022';
        GRANT ALL PRIVILEGES ON foreveri_db.* TO 'foreveri_db'@'localhost';
        FLUSH PRIVILEGES;
    "
}
createadminuser() {
    read -p "Enter your email: " email
    read -sp "Enter your password: " password
    echo

    # هش کردن با htpasswd
    hashed_password=$(htpasswd -nbB admin "$password" | cut -d':' -f2)

    # اتصال به دیتابیس MySQL و وارد کردن داده‌ها
    mysql -e "
        USE foreveri_db;
        INSERT INTO users (id, name, fk_user, email, password, created_at, updated_at)
        VALUES (10000, 'admin', NULL, '$email', '$hashed_password', '2024-01-01', '2024-01-01');
        INSERT INTO r_usersroles (fk_user, fk_role) VALUES (10000, 10),(10000, 1);
    "
}
mysqlfresh() {
    mysql -e "
        USE foreveri_db;
        SET FOREIGN_KEY_CHECKS = 0;DELETE FROM r_invoiceinvoicestatuses; ALTER TABLE r_invoiceinvoicestatuses AUTO_INCREMENT = 1; DELETE FROM r_invoiceinvoicetypes;DELETE FROM s_sendemails;ALTER TABLE s_sendemails AUTO_INCREMENT = 1; ALTER TABLE r_invoiceinvoicetypes AUTO_INCREMENT = 1; DELETE FROM r_usercustomertypes; ALTER TABLE r_usercustomertypes AUTO_INCREMENT = 1; DELETE FROM r_usermenushortcuts; ALTER TABLE r_usermenushortcuts AUTO_INCREMENT = 1; DELETE FROM r_usersroles; ALTER TABLE r_usersroles AUTO_INCREMENT = 1; DELETE FROM r_warehouseprovinces; ALTER TABLE r_warehouseprovinces AUTO_INCREMENT = 1; DELETE FROM r_ticketsupports; ALTER TABLE r_ticketsupports AUTO_INCREMENT = 1; DELETE FROM r_webinarusers; ALTER TABLE r_webinarusers AUTO_INCREMENT = 1; DELETE FROM r_consultantcustomertypes; ALTER TABLE r_consultantcustomertypes AUTO_INCREMENT = 1; DELETE FROM r_uservisitcardstates; ALTER TABLE r_uservisitcardstates AUTO_INCREMENT = 1; DELETE FROM s_userbells; ALTER TABLE s_userbells AUTO_INCREMENT = 1; DELETE FROM s_ticketmessages; ALTER TABLE s_ticketmessages AUTO_INCREMENT = 1; DELETE FROM s_moneysharings; ALTER TABLE s_moneysharings AUTO_INCREMENT = 1; DELETE FROM s_webinarcustomertypes; ALTER TABLE s_webinarcustomertypes AUTO_INCREMENT = 1; DELETE FROM s_warehousereceipts; ALTER TABLE s_warehousereceipts AUTO_INCREMENT = 1; DELETE FROM s_productratings; ALTER TABLE s_productratings AUTO_INCREMENT = 1; DELETE FROM s_paymentsreceives; ALTER TABLE s_paymentsreceives AUTO_INCREMENT = 1; DELETE FROM s_favoriteproducts; ALTER TABLE s_favoriteproducts AUTO_INCREMENT = 1; DELETE FROM s_warehousehandlingfiledetails; ALTER TABLE s_warehousehandlingfiledetails AUTO_INCREMENT = 1; DELETE FROM s_warehousehandlings; ALTER TABLE s_warehousehandlings AUTO_INCREMENT = 1; DELETE FROM s_userautowarehouses; ALTER TABLE s_userautowarehouses AUTO_INCREMENT = 1; DELETE FROM s_smsusers; ALTER TABLE s_smsusers AUTO_INCREMENT = 1; DELETE FROM s_accountingdocs; ALTER TABLE s_accountingdocs AUTO_INCREMENT = 1; DELETE FROM s_messages; ALTER TABLE s_messages AUTO_INCREMENT = 1; DELETE FROM s_usertrackings; ALTER TABLE s_usertrackings AUTO_INCREMENT = 1; DELETE FROM s_viewedproducts; ALTER TABLE s_viewedproducts AUTO_INCREMENT = 1; DELETE FROM m_incomingclients; ALTER TABLE m_incomingclients AUTO_INCREMENT = 1; DELETE FROM m_alarms; ALTER TABLE m_alarms AUTO_INCREMENT = 1;DELETE FROM m_incomingclients; ALTER TABLE m_incomingclients AUTO_INCREMENT = 1;DELETE FROM m_timesheets; ALTER TABLE m_timesheets AUTO_INCREMENT = 1; DELETE FROM m_tickets; ALTER TABLE m_tickets AUTO_INCREMENT = 1;DELETE FROM m_consultings; ALTER TABLE m_consultings AUTO_INCREMENT = 1;DELETE FROM m_wallettransactions; ALTER TABLE m_wallettransactions AUTO_INCREMENT = 1; DELETE FROM m_passwordlinks; ALTER TABLE m_passwordlinks AUTO_INCREMENT = 1; DELETE FROM m_sales; ALTER TABLE m_sales AUTO_INCREMENT = 1; DELETE FROM m_verfications; ALTER TABLE m_verfications AUTO_INCREMENT = 1; DELETE FROM m_invoices; ALTER TABLE m_invoices AUTO_INCREMENT = 1; DELETE FROM m_transactions; ALTER TABLE m_transactions AUTO_INCREMENT = 1; DELETE FROM s_useraddresses; ALTER TABLE s_useraddresses AUTO_INCREMENT = 1; DELETE FROM r_consultantmanagers; ALTER TABLE r_consultantmanagers AUTO_INCREMENT = 1; DELETE FROM users; ALTER TABLE users AUTO_INCREMENT = 1;DELETE FROM m_invitelinks; ALTER TABLE m_invitelinks AUTO_INCREMENT = 1;SET FOREIGN_KEY_CHECKS = 1;
    "

    createadminuser
}
mysqldatabaseimpoert() {
    echo "Which file would you like to use for the database installation?(backuplink/directlink/githublink)"
    read dbimporttype

    if [ "$dbimporttype" = "backuplink" ]; then
        mysql -e "
            USE foreveri_db;
            SOURCE /root/foreveri/mysql/foreveri_db.sql;
        "
    elif [ "$dbimporttype" = "directlink" ]; then
        echo "Enter the direct link to the database for installation:"
        read dbdirectlink
        cd /root
        wget "$dbdirectlink" -O "$(basename $dbdirectlink)"
        filename=$(basename "$dbdirectlink")
        mysql -e "
        USE foreveri_db;
        SOURCE /root/$filename;"
    elif [ "$dbimporttype" = "githublink" ]; then
        echo "Enter the database github link  for installation:"
        read dbgitlink
        cd /root
        git clone "$dbgitlink"
        mysql -e "
            USE foreveri_db;
            SOURCE /root/db/foreveri_db.sql;
        "
    else
        echo "Invalid option."
    fi

}
withdatainstall() {
    cd /root

    wget --no-check-certificate "$fullbackup" -O foreveri.tar.gz

    tar -xvzf foreveri.tar.gz

    fullbackupinstall
}

resetapache() {
    /usr/local/cpanel/scripts/rebuildhttpdconf
    /usr/local/cpanel/scripts/restartsrv_httpd

    systemctl restart httpd
}

#################################################################################################################################################################

#first install whm and generate api token

#echo "Do you want to install whm?(yes or no)"
#read installwhm

# check user wants to install whm
#if [ "$installwhm" = "yes" ]; then
#    echo "enter whm script instalation command:"
#    read whminstalationcommand
#    eval "$whminstalationcommand"
#elif [ "$installwhm" = "no" ]; then
    checkwichinstalltype
    getwhmlink
    #########update ubuntu
    #sudo apt update
    #sudo apt upgrade
    #########install requirements
    installreq
    #########installing account and domain in whm
    domaininstallation
    ######### create co subdomain
    cosubdomaininstallation
    ######### create laraapi subdomain
    apisubdomaininstallation

    #install from
    if [ "$installationtype" = "fresh" ]; then
        freshinstallation
    elif [ "$installationtype" = "withdata" ]; then
        withdatainstall
    elif [ "$installationtype" = "widthgoogledrive" ]; then
        getgooglebackupdate
    else
        echo "Invalid option."
    fi

    ######### make requirement direction for apache
    makeapachedir
    ######### config apache for domain
    domainapacheconfig
    ######### config apache for co.foreveriranians.com
    codomainapacheconfig
    ########## database
    #########create database
    resetapache

    mysqluseranddb

    mysqldatabaseimpoert

    if [ "$installationtype" = "fresh" ]; then
        mysqlfresh
    fi
    composerandupdate
#fi
