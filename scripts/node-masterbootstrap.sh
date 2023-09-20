echo "kubeadm init"
kubeadm init --apiserver-advertise-address 172.16.17.100  

echo "Install calico"
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.18/manifests/calico.yaml 

echo "create new token"
kubeadm token create --print-join-command > /joincluster.sh 

echo "copying admin.config to vagrant host"
cp /etc/kubernetes/admin.conf /vagrant 
