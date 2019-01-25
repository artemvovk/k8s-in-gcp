#!/bin/bash -
set -o nounset                              # Treat unset variables as an error


# Handling input
COMMAND="apply"
PS3='Which action to perform: '
options=("Update Bastion IP" "Run Playbook" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Update Bastion IP")
            COMMAND="update"
            break
            ;;
        "Run Playbook")
            COMMAND="play"
            break
            ;;
        "Quit")
            exit 0
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

PROXY_IP=$(ansible-inventory -i inventory.gcp.yml --graph | awk 'c&&!--c;/\@tag_bastion/{c=1}' | cut -d'-' -f3)
echo $PROXY_IP
sed -i "s/artem@\(.*\)/artem@$PROXY_IP\"'/" group_vars/tag_master.yml
sed -i "s/artem@\(.*\)/artem@$PROXY_IP\"'/" group_vars/tag_worker.yml

if [[ "$COMMAND" == "play" ]]; then
    ansible-playbook -vvvv -i inventory.gcp.yml playbook.yml
fi

#gcloud compute scp --zone us-east1-b --recurse ./ k8s-bastion:~/ansible
#gcloud compute scp --zone us-east1-b --recurse ~/.config/gcloud/k8s-builder-tf-cli.json k8s-bastion:~/.config/gcloud/k8s-builder-tf-cli.json
#gcloud compute scp --zone us-east1-b --recurse ~/.ssh/id_rsa k8s-bastion:~/.ssh/
