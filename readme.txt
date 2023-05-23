wget -q -O subspace.sh https://raw.githubusercontent.com/mgpwnz/subspace/main/subspace_adv.sh && chmod +x subspace.sh && sudo /bin/bash subspace.sh


delete
systemctl stop subspace-farmer.service subspace-node.service
systemctl disable subspace-farmer.service subspace-node.service
rm -rf sub /etc/systemd/system/subspace*
systemctl daemon-reload