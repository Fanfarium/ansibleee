#!/bin/bash
clean_ports() {
    PORT=6443
    echo "Перевірка наявності зайнятих портів $PORT..."

    # Виведення процесів, які використовують порт
    sudo lsof -i :$PORT

    # Остановка служб Kubernetes
    echo "Зупинка служб Kubernetes..."
    sudo systemctl stop kubelet
    sudo systemctl stop kube-apiserver
    sudo systemctl stop kube-scheduler
    sudo systemctl stop kube-controller-manager
    sudo systemctl stop kube-proxy

    # Очистка залишкових процесів
    echo "Очистка залишкових процесів..."
    PIDS=$(sudo lsof -t -i :$PORT)
    if [ -n "$PIDS" ]; then
        echo "Зупинка процесів з PIDs: $PIDS"
        sudo kill -9 $PIDS
    else
        echo "Процеси на порту $PORT не знайдено."
    fi

    # Перевірка чи порт звільнений
    echo "Перевірка наявності зайнятих портів після очищення..."
    sudo lsof -i :$PORT

    # Якщо порт все ще зайнятий, перезавантаження системи
    if sudo lsof -i :$PORT > /dev/null; then
        echo "Порт $PORT все ще зайнятий. Перезавантаження системи..."
        sudo reboot
    else
        echo "Порт $PORT звільнений."
    fi
}

# Запуск функції очищення портів
clean_ports

# Запуск сценарію Kubernetes
echo "Запуск сценарію Kubernetes..."
# Вимкнення swap
sudo swapoff -a

# Дозволити необхідні модулі ядра
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Застосування параметрів sysctl
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# Перевірка наявності зайнятих портів
echo "Перевірка наявності зайнятих портів 6443..."
if sudo lsof -i :6443 > /dev/null; then
    echo "Порт 6443 зайнятий. Зупиніть процес або звільніть порт перед продовженням."
    exit 1
fi

# Перевірка стану Kubernetes
echo "Перевірка стану Kubernetes..."
if [ -d /etc/kubernetes ]; then
    echo "Старі конфігурації Kubernetes знайдено. Очищення..."
    sudo kubeadm reset -f
    sudo rm -rf /etc/kubernetes
    sudo rm -rf /var/lib/etcd
    sudo rm -rf ~/.kube
fi

# Створення директорії для keyrings, якщо не існує
sudo mkdir -p /etc/apt/keyrings
sudo chmod 755 /etc/apt/keyrings

# Оновлення індексу пакетів та встановлення залежностей
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Додавання APT репозиторію Kubernetes
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Встановлення компонентів Kubernetes та containerd
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl containerd
sudo apt-mark hold kubelet kubeadm kubectl

# Налаштування containerd
echo "Налаштування containerd..."
# Коментування та очищення параметру disabled_plugins у файлі config.toml
CONFIG_FILE="/etc/containerd/config.toml"
if sudo grep -q '^disabled_plugins = \["cri"\]' "$CONFIG_FILE"; then
    sudo sed -i '/^disabled_plugins = \["cri"\]/c\# Disable the CRI plugin if not needed\ndisabled_plugins = []' "$CONFIG_FILE"
    echo "Оновлено конфігурацію containerd."
else
    echo "Конфігурація containerd вже оновлена або параметр не знайдено."
fi

# Перезапуск containerd для застосування змін
sudo systemctl restart containerd

# Ініціалізація Kubernetes кластера
echo "Ініціалізація Kubernetes кластера..."
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Налаштування kubectl для поточного користувача
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Друк повідомлення про завершення
echo "Інсталяція та конфігурація Kubernetes завершена."

# Розгортання мережевого плагіна
echo "Розгортання мережевого плагіна Flannel..."
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Перевірка статусу
echo "Перевірка статусу кластеру..."
kubectl get nodes
kubectl get pods --all-namespaces
