#!/bin/bash
set -e

if [ ! -f /etc/installer_completed ]; then

echo "**************************************************************"
echo "*                                                            *"
echo "*                 Cylo Base Installer 1.0                    *"
echo "*                     Installing Apps:                       *"
echo "*                                                            *"
echo "**************************************************************"
echo "Default base image applications"
if [ "${INSTALL_NGINXPHP}" = true ]; then echo "Nginx & PHP-FPM 7"; fi
if [ "${INSTALL_MYSQL}" = true ]; then echo "MySQL Server"; fi
echo " "
echo "**************************************************************"
echo " "

    # Create Directories
    echo "Creating default directories"
    mkdir -p /home/appbox/config

    if [ "${INSTALL_NGINXPHP}" = true ]; then
        # Install NGINX & PHP-FPM 7
        echo "Installing NGINX & PHP-FPM 7"
        /bin/sh /scripts/nginx_php7.sh
    else
        echo "NGINX & PHP not required, removing installer"
        rm -fr /scripts/nginx_php7.sh
    fi

    if [ "${INSTALL_MYSQL}" = true ]; then
        # Install MySQL
        echo "Installing MySQL"
        /bin/sh /scripts/mysql.sh
    else
        echo "MySQL not required, removing installer"
        rm -f /scripts/mysql.sh
    fi

    # Set Permissions
    echo "Setting Permissions on homedir"
    chown -R appbox:appbox /home/appbox

    # Clean Up
    echo "Cleaning up"
    rm -fr /sources

    apt autoremove -y
    apt-get clean
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

echo "                                   .''.       "
echo "       .''.      .        *''*    :_\/_:     . "
echo "      :_\/_:   _\(/_  .:.*_\/_*   : /\ :  .'.:.'."
echo "  .''.: /\ :   ./)\   ':'* /\ * :  '..'.  -=:o:=-"
echo " :_\/_:'.:::.    ' *''*    * '.\'/.' _\(/_'.':'.'"
echo " : /\ : :::::     *_\/_*     -= o =-  /)\    '  *"
echo "  '..'  ':::'     * /\ *     .'/.\'.   '"
echo "      *            *..*         :"

    echo "Finishing Install"
    # Finish Install
    if [ "${APEX_CALLBACK}" = true ]; then
        until [[ $(curl -i -H "Accept: application/json" -H "Content-Type:application/json" -X POST "https://api.cylo.io/v1/apps/installed/${INSTANCE_ID}" | grep '200') ]]
            do
            sleep 5
        done
    fi
    touch /etc/installer_completed

fi