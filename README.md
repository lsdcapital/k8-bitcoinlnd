# bitcoin-core

GKE Cluster
For our testing and implentation we used GKE rapid channel - 1.17.9-gke.1703
Instances are e2-medium with Container-Optimised OS (cos) with 3 nodes
Persistant Volumes are coming from a GKE storage class with standard persistant disks

Bitcoind
I really struggled on GKE with standard storage and the e2-medium to sync the bitcoin blockchain. I  ended up rsyncing it from another full node which was much faster.

In a container where you can mount the /data volume - ensure bitcoind is down and
# You may need to install rsync and openssh-clients depending on your container
cd /data
rsync -rv --inplace --progress --partial -z -c --delete-after --append -e 'ssh -p 2222' user@host:/path/to/bitcoind/blocks .
rsync -rv --inplace --progress --partial -z -c --delete-after --append -e 'ssh -p 2222' user@host:/path/to/bitcoind/chainstate .
rsync -rv --inplace --progress --partial -z -c --delete-after --append -e 'ssh -p 2222' user@host:/path/to/bitcoind/indexes .

Edit the bitcoind k8 yaml and define 
- namespaces
- rpcauth. See in the utils folder for a helper program


# LND

Edit the lnd k8 yaml and define
- alias in the configmap
- bitcoind.rpcuser & bitcoind.rpcpass in the configmap

# Create wallet
Access your container
kubectl exec -it <podname> -- /bin/bash
lncli create
# Be sure to record your seed keys. If you lose those you will lose your funds
# As pods restart we need a way to unlock the wallet. There is some post work that will as long as /data/.walletpass exists with the plaintext password
# TODO: This might not be a great idea to keep it in plaintext
echo <password> > /data/.walletpass

Need to ensure /data/data/chain/bitcoin/mainnet/channel.backup is backed up everytime a new channel is open / closed.
TODO: Investigate https://api.lightning.community/#subscribechannelbackups to have a container listen, get updates and save it to bucket / s3 / pv

# LNDHUB

LndHub requires the following files to function
/lndhub/config.js (provided via configmap)
/lndhub/tls.cert (provied via a secret config map)
/lndhub/admin.macaroon (provided via a secret config map)

You need to encode the two secrets with the files from your lnd node.
cat /data/tls.cert |base64.  Concatenate the files and provide it in a secret

Update the bitcoin rpc username:password int he config.js configmap

LndHub needs a redis database. This database must use persistant storage - else people will lose their wallets!
TODO: Investigate using Google memstore instead of redis containers
