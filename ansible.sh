sudo apt update
sudo apt install ansible -y
ansible --version
ansible-galaxy collection install community.docker
ansible-playbook -i inventory.ini /home/ubuntu/ansibleee/playbook/docker_and_jenkins.yml
ansible-playbook -i inventory.ini /home/ubuntu/ansibleee/playbook/kubernetes.yml
ansible-playbook -i inventory.ini /home/ubuntu/ansibleee/playbook/terraform.yml
ansible-playbook -i inventory.ini /home/ubuntu/ansibleee/playbook/apache.yml


