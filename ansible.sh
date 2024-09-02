sudo apt update
sudo apt install ansible -y
ansible --version
apt install sshpass
ansible-galaxy collection install community.docker
ansible-playbook -i inventory.ini /home/ubuntu/ansibleee/playbook/ping.yml --ask-pass --ask-become-pass
ansible-playbook -i inventory.ini /home/ubuntu/ansibleee/playbook/docker_and_jenkins.yml
ansible-playbook -i inventory.ini /home/ubuntu/ansibleee/playbook/kubernetes.yml
ansible-playbook -i inventory.ini /home/ubuntu/ansibleee/playbook/terraform.yml
ansible-playbook -i inventory.ini /home/ubuntu/ansibleee/playbook/apache.yml


