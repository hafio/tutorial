Refer to Help Page: [kind](https://kind.sigs.k8s.io/)

Install GO - [All releases - The Go Programming Language](https://go.dev/dl/)

> GO should be installed in `C:\Program Files\Go\bin` or depending on where you selected/unzipped to.
> 
> Will need to restart (close &amp; open) your terminal for the new path to be updated

execute `go install sigs.k8s.io/kind@latest`

use and customize the below [kind-config.yaml](https://localhost:26654/attachments/2)

```yaml
# kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: local-k8-kind

nodes:
  - role: control-plane
  - role: worker
#    image: XXXX
  - role: worker
  - role: worker
  - role: worker
  - role: worker
  - role: worker
  - role: worker
  - role: worker
  - role: worker
  - role: worker
  
networking:
  ipFamily: ipv6
  apiServerAddress: 127.0.0.1
  apiServerPort: 6443
```

execute `kind create cluster --config kind-config.yaml`

output should be:

```
Creating cluster "kind" ...
 ✓ Ensuring node image (kindest/node:v1.31.2) 🖼
 ✓ Preparing nodes 📦 📦 📦 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
 ✓ Joining worker nodes 🚜
Set kubectl context to "kind-kind"
You can now use your cluster with:

kubectl cluster-info --context kind-kind

Not sure what to do next? 😅  Check out https://kind.sigs.k8s.io/docs/user/quick-start/
```