#!/bin/bash
while true
do
read -r -p "Plot size? [100G/200G/300G/400G/500G] " response
case "$response" in
    [100G][100][100g])
plot={path=/root/subspace_adv,size=100GiB}
        echo -e "100G"
        ;;
    [200G][200][200g]) 
plot={path=/root/subspace_adv,size=100GiB path=/root/subspace_adv,size=100GiB}
        echo -e "200G"
        ;;
    [300G][300][300g]) 
plot={path=/root/subspace_adv,size=100GiB path=/root/subspace_adv,size=100GiB path=/root/subspace_adv,size=100GiB}  
        echo -e "300G"
        ;;
    [400G][400][400g]) 
plot={path=/root/subspace_adv,size=100GiB path=/root/subspace_adv,size=100GiB path=/root/subspace_adv,size=100GiB path=/root/subspace_adv,size=100GiB}    
        echo -e "400G"
        ;;
    [500G][500][500g]) 
plot={path=/root/subspace_adv,size=100GiB path=/root/subspace_adv,size=100GiB path=/root/subspace_adv,size=100GiB path=/root/subspace_adv,size=100GiB path=/root/subspace_adv,size=100GiB}    
        echo -e "500G"
        ;;
esac
done