# server
sudo adduser kratos
sudo usermod -aG sudo kratos
sudo mkdir -p /home/kratos/.ssh
sudo chown -R kratos:kratos /home/birame/.ssh

# machine
sudo ssh-keygen -t rsa -b 4096 -C "kratos@diouf-host" -f /home/diouf/.ssh/id_rsa
ssh-copy-id -i /home/diouf/.ssh/id_rsa.pub -p2222 birame@11.11.90.149
ssh birame@11.11.90.149 -p2222 