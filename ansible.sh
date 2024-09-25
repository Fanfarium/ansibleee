sudo apt update
sudo apt install ansible -y
ansible --version
apt install sshpass
apt install python3-pip
pip install docker-py
ansible-galaxy collection install community.docker
ansible-playbook -i inventory.ini playbook/ping.yml --ask-pass --ask-become-pass
ansible-playbook -i inventory.ini playbook/docker.yml --ask-pass --ask-become-pass
ansible-playbook -i inventory.ini playbook/jenkins.yml --ask-pass --ask-become-pass
ansible-playbook -i inventory.ini playbook/kubernetes.yml --ask-pass --ask-become-pass
ansible-playbook -i inventory.ini playbook/terraform.yml --ask-pass --ask-become-pass





