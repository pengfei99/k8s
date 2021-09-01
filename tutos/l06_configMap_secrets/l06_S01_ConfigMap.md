# k8s config map 
A **ConfigMap** is an API object used to store non-confidential data in key-value pairs. Pods can consume ConfigMaps

- as environment variables
- as command-line arguments
- as configuration files in a volume.

**A ConfigMap allows you to decouple environment-specific configuration from your container images**, so that your 
applications are easily portable.

There are four different ways that you can use a ConfigMap to configure a container inside a Pod:

- Inside a container command and args
- Environment variables for a container
- Add a file in read-only volume, for the application to read
- Write code to run inside the Pod that uses the Kubernetes API to read a ConfigMap

## Create a configMap

A ConfigMap has data and binaryData fields. These fields accept key-value pairs as their values. Both the data 
field and the binaryData are optional. The data field is designed to contain UTF-8 byte sequences while the 
binaryData field is designed to contain binary data.

### Create configMaps from repository 
Suppose that we have two files that contains the configuration that we want to add as configMap 

The game.properties file looks like:
```text 
enemies=aliens
lives=3
enemies.cheat=true
enemies.cheat.level=noGoodRotten
secret.code.passphrase=UUDDLRLRBABAS
secret.code.allowed=true
secret.code.lives=30
```

The ui.properties file looks like:
```text
color.good=purple
color.bad=yellow
allow.textmode=true
how.nice.to.look=fairlyNice
```

You can use the following procedure to create the **configMap based on the repository** that contains the two files.

```shell
# Create a folder named game-config in /tmp
mkdir -p /tmp/game-config

# then put the two following files game.properties and ui.properties in it.

# then run this command to create the configMap from all files under directory game-config/
# note we specify a directory in from-file, it will take all files under this directory
kubectl create configmap game-config --from-file=/tmp/game-config/

# if you want to use only one file
kubectl create configmap game-properties-config- --from-file=/tmp/game-config/game.properties

# if you want to use multiple files
kubectl create configmap game-config-2 --from-file=/tmp/game-config/game.properties --from-file=/tmp/game-config/ui.properties

```


After the creation, you can check the details of the created config map

```shell
kubectl describe configmaps game-config

# To get the configmap in a yaml file
kubectl get configmaps game-config -o yaml
```

### Create configmap from env file

In above section, we can create a configMap from any file. There is no restriction. K8s also provides an option with
more control. The option **–from-env-file** creates a ConfigMap from an env-file.

An env-file contain a list of environment variables. It must respect the following rules:

- Each line in an env file has to be in VAR=VAL format.
- Lines beginning with # (i.e. comments) are ignored.
- Blank lines are ignored.
- There is no special handling of quotation marks (i.e. the quotation marks will be part of the ConfigMap value).

For example, the following file env-config.properties is an env-file

```text
enemies=aliens
lives=3
allowed="true"
```

To create a configmap, the command is similar, just use --from-env-file to replace --from-file. Below is an example.

```shell
# the creation is similar to raw files
$ kubectl create configmap game-config-env-file --from-env-file=game-config/env-file.properties
```

### Change the default key name of the config map

By default the configMap uses the file name as the main key for all the key-value pair of a file. See the game-config example. But you can specify a key to replace the default file name key.
