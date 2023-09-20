apt install -qq -y sshpass >/dev/null 2>&1
sshpass -p "999" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no masternode.lan.com:/joincluster.sh /joincluster.sh 
bash /joincluster.sh 
