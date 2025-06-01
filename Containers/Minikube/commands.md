# List profiles (clusters)
`minikube profile list`

# Change active profile
`minikube profile [name]`
> if name is not specified, it will display current profile (cluster) name, otherwise it will change to specified profile.

# Start

`minikube start -p [name]`
> if the cluster has been started before, you do not need to specify all options as part of first run.

# Stop

`minikube stop -p [name]`
> if `-p` is not specified, active profile name is used.

# Delete

`minikube delete -p [name]`
> if `-p` is not specified, active profile name is used.

# Status of all running clusters

`minikube status -p [name]`
> if `-p` is not specified, active profile name is used.