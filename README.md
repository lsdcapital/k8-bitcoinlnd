
# Note

This repo is archived in favour of the charts in the lsdcapital/helm-charts folder

## k8-bitcoinlnd

I started this repo as I wanted to run bitcoin-core, lnd, lndhub all on Kubernetes on GKE. Many of the docker containers I found on Dockerhub had some issue with moving the Kubernetes or didn't have the source Dockerfile available. I created these to hopefully be something that is useful and other can contribute to.

## GKE Cluster
For our testing and implentation we used GKE rapid channel - 1.17.9-gke.1703  
Instances are e2-medium with Container-Optimised OS (cos) with 3 nodes  
Persistant Volumes are provided from a GKE storage class with standard persistant disks

## Bitcoin-core
[Bitcoin Core](https://github.com/bitcoin/bitcoin)  
Version: 0.20.1

I really struggled on GKE with standard storage and the e2-medium to sync the initial bitcoin blockchain. I ended up rsyncing it from another full node which was much faster.
- Stop bitcoind on the source
- In the container where the /data volume is mounted
  - You may need to install rsync and openssh-clients depending on your container
  - cd /data
  - rsync -rv --inplace --progress --partial -z -c --delete-after --ignore-times -e 'ssh -p 22' user@host:/path/to/bitcoind/blocks .
  - rsync -rv --inplace --progress --partial -z -c --delete-after --ignore-times -e 'ssh -p 22' user@host:/path/to/bitcoind/chainstate .
  - rsync -rv --inplace --progress --partial -z -c --delete-after --ignore-times -e 'ssh -p 22' user@host:/path/to/bitcoind/indexes .
- Edit the bitcoind k8 yaml and define
  - namespaces
  - rpcauth (See in the utils folder for a helper program)

## LND
[LND](https://github.com/lightningnetwork/lnd)  
Version: v0.11.0-beta

Edit the lnd k8 yaml and define
- alias in the configmap
- bitcoind.rpcuser & bitcoind.rpcpass in the configmap

### Create wallet
- Access your container
- kubectl exec -it <podname> -- /bin/bash
- lncli create (Be sure to record your seed keys. If you lose those you will lose your funds!)

As pods restart we need a way to unlock the wallet. You can
- Do this manually everytime
- Create /data/.walletpass with the plaintext password (echo <password> > /data/.walletpass)

### LND Watchtower
I created a seperate deployment yaml for a watchtower server  
TODO: This needs more testing. Help appreciated  

## LND SCB Backup
You must backup your channel file. Please see [lnd-scb-backup](https://github.com/lsdopen/lnd-scb-backup) which is a helper container that will back this up. Currently to file or Google Bucket.

## LNDHUB
[LNDHUB](https://github.com/BlueWallet/LndHub)

LndHub requires the following files to function
- /lndhub/config.js (provided via configmap)
- /lndhub/tls.cert (provied via a secret config map)
- /lndhub/admin.macaroon (provided via a secret config map)
- Update the bitcoin rpc username:password int he config.js configmap

You need to encode the two secrets with the files from your lnd node. To do this
- cat /data/tls.cert |base64 -w0

### Redis
LndHub needs a redis database. This database must use persistant storage - else people will lose their lndhub wallets.

I built two redis containers for this (deployment yaml is in the repo). I also investigated using Google Memstore - which will certainly work and if you are going to do this for commercially I would look at that option. The costing didn't make sense to me as Google Memstore smallest size is 1GB which you pay regardless of usage.

If you are using Redis - I created a redis cronjob to backup the Redis RDB remotely and store it to a Google Bucket.  [redis-dump-backup](https://github.com/lsdopen/redis-dump-backup)

