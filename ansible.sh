sudo apt update
sudo apt install ansible -y
ansible --version
apt install sshpass
apt install python3-pip
pip install docker-py
ansible-galaxy collection install community.docker
ansible-playbook -i inventory.ini /home/ubuntu/ansibleee/playbook/ping.yml --ask-pass --ask-become-pass
ansible-playbook -i inventory.ini /home/ubuntu/ansibleee/playbook/docker_and_jenkins.yml
ansible-playbook -i ../inventory.ini kubernetes.yml --ask-pass --ask-become-pass
kubectl rollout restart daemonset kube-proxy -n kube-system
kubectl get pods -n kube-system

ansible-playbook -i inventory.ini /home/ubuntu/ansibleee/playbook/terraform.yml
ansible-playbook -i inventory.ini /home/ubuntu/ansibleee/playbook/apache.yml


