#!/bin/bash

# List of servers
servers=("192.168.100.4")

# File path on the servers
file_path="/tmp/text.txt"

# Password for User
password="1234Vitosha"

# User to be used
user="admin"

# Full Function of script
function esb_script { 
    server=$1
    echo "Starting change on server: $server"
    echo "."
# Backup part of the script
    read -p "Do you wish to proceed with creating backup for the file (y/n): " bkp
    echo "."
    echo "."
    if [[ $bkp == y ]]; then
        sshpass -p $password ssh -o StrictHostKeyChecking=no "$user@$server" "cp \"$file_path\" \"/tmp/file_$(date +"%m%d%y").bkp\""
        if [ $? -eq 0 ]; then
            echo "Backup was successfully created on $server."
        else
            echo "Failed to make backup on $server."
        fi
    else
        exit
    fi  
# Importing part of the script
        echo "."
        echo "."
        read -p "Do you wish to proceed with importing (y/n): " import
        if [[ $import == y ]]; then
                # Source server details
                source_user="admin"
                source_host="192.168.100.3"
                source_file="/tmp/source.txt"

                # Destination server details
                destination_user="admin"
                destination_host="192.168.100.4"
                destination_file="/tmp/text.txt"

                # Password variable
                password="1234Vitosha"

                # Read the content from the source file on the source server
                source_content=$(sshpass -p "$password" ssh "${source_user}@${source_host}" "cat ${source_file}")

                # Append the content to the destination file on the destination server
                sshpass -p "$password" ssh "${destination_user}@${destination_host}" "echo '${source_content}' >> ${destination_file}"
                if [ $? -eq 0 ]; then
                        echo "."
                        echo "."
                        echo "Text was successfully imported on $server."
                    else
                        echo "."
                        echo "."
                        echo "Failed to import text on $server."
                    fi
        else
            echo "."
            echo "."
            echo "Finished without importing the text on $server."
        fi
# Here are entered the variables needed for the execution of the commands
echo ""
echo "Proceeding with executing the commands, enter values below."
echo ""
read -p "Please, enter node name: " node
    echo""
    read -p "Please, enter what will be the name of the new resource name: " esbname
        echo ""
        read -p "Please, enter the name of the user: " user
            echo ""
            read -p "Please, enter the password for the user: "$'\n' -s dbpass
echo ""
echo ""
# Running the commands
    read -p "Do you want to proceed with 'mqsisetdbparms' command (y/n): " command
        if [[ $command == y ]]; then
            sshpass -p $password ssh -o StrictHostKeyChecking=no "$user@$server" "mqsisetdbparms $node -n $esbname -u "$user"-p '$dbpass'"

                echo "Do you want to proceed with 'mqsicvp' command (y/n) ?"
                read command
                    if [[ $command == y ]]; then
                        sshpass -p $password ssh -o StrictHostKeyChecking=no "$user@$server" "mqsicvp $node -p $esbname"
                    else
                        exit
                    fi
        else
            exit
        fi
# Stopping the service
    read -p "Do you want to proceed with stoping the service on server $server (y/n): " stop

    if [[ $stop == y ]]; then
        sshpass -p $password ssh -o StrictHostKeyChecking=no "$user@$server" "mqsistop $node"
    else
        exit
    fi
# Starting the service 
    read -p "Do you want to proceed with start the service on server $server (y/n): " start

    if [[ $start == y ]]; then
        sshpass -p $password ssh -o StrictHostKeyChecking=no "$user@$server" "mqsistart $node"
    else
        exit
    fi
}
# This is the loop for the function
for server in "${servers[@]}"; do
    esb_script "$server"
done