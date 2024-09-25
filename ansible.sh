sudo apt update
sudo apt install ansible -y
ansible --version
apt install sshpass
apt install python3-pip
pip install docker-py
ansible-galaxy collection install community.docker
ansible-playbook -i ../inventory.ini ping.yml --ask-pass --ask-become-pass
ansible-playbook -i ../inventory.ini docker.yml --ask-pass --ask-become-pass
ansible-playbook -i ../inventory.ini jenkins.yml --ask-pass --ask-become-pass
ansible-playbook -i ../inventory.ini kubernetes.yml --ask-pass --ask-become-pass
ansible-playbook -i ../inventory.ini terraform.yml --ask-pass --ask-become-pass





