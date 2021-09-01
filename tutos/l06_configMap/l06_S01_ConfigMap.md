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

There are ways to create configMap:
- from a repository: All files in the repository will be added to the configMap
- from files: We specify file by file that we want to add to the configMap
- from env-file: We set certain rules to the file format.
- from inline literal values:
- from a generator:
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

By default, the configMap uses the file name as the main key for all the key-value pair of a file. See the 
key name of the above game-config example. But you can specify a key to replace the default file name key.

```shell
# The general form is 
kubectl create configmap game-config-3 --from-file=<my-key-name>=<path-to-file>

# the game.properties values will have main key pengfei-game, and ui.properties will have pengfei-ui
kubectl create configmap game-config-3 --from-file=pengfei-game=game-config/game.properties --from-file=pengfei-ui=game-config/ui.properties

```


### Create a configMap from literal value
We can also use in line literal to create config map

```shell
kubectl create configmap pengfei-config --from-literal=pengfei.age=37 --from-literal=pengfei.sex=m
```

### Create a configMap from generator

We can use a generator (kustomization.yaml file) to create the ConfigMap object. Note the name of the generator file 
is **mandatory. It must be kustomization.yaml**.

The following file is an example. Note that **the name you give to the configMap will be autocompleted with a random 
number**. For example, it will be something like “game-config-4-bt44gb9824”

In the following configGenerator file, we can use files to specify from-files configMap, literals, etc.
```yaml
configMapGenerator:
- name: game-config-4
  files:
  # from files
  - ./game-config/game.properties
  - ./game-config/ui.properties
  # from files with custom keys
  - custom-key-name=./game.properties
  # from literals
  literals:
  - special.how=very
  - special.type=charm
```

To launch the generator, you need to run the following command. The command only takes **the name of the directory 
which contains kustomization.yaml**

```shell
kubectl apply -k <directory-name> 
```

## Delete a configMap

You have two ways to delete a configMap:
- via configMap name:
- via configmap yaml file:

```shell
# Via configMap name
# kubectl delete configmap  <configmap-name>  -n  <namespace-name> 
$ kubectl delete configmap    my-cofigmap     -n   namespacename 

# via yaml file
# kubectl delete -f <file-directory> -n <namespace-name>
$ kubectl delete -f  configmap.yaml  -n  namespacename
```

## Use the configMap inside a pod

There are mainly two ways to include a configmap inside a pod:
- via variable env:
- via volume: We can mount configMap as a volume

### Include a configmap by using env var. 

There is two ways to create env var based on configMap:
- option valueFrom: It creates an env var at a time from configMap
- option envFrom: It takes all key-value pair of a configMap and generate one env var for each key-value paire.

#### Create an env var by using valueFrom
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-test-pod
spec:
  containers:
    - name: test-container
      image: busybox
      command: [ "/bin/sh", "-c", "env" ]
      env:
        # Define the environment variable in the container
        - name: FOOBAR_AGE
          valueFrom:
            configMapKeyRef:
              # The ConfigMap name containing the value you want to assign to FOOBAR_AGE
              name: pengfei-config
              # Specify the key in the configMap which you want to show the value
              key: pengfei.age
        - name: FOOBAR_SEX
          valueFrom:
            configMapKeyRef:
              name: pengfei-config
              key: pengfei.sex  
  restartPolicy: Never
```

You can create a pod by using following command
```shell
kubectl apply -f <pod-describ.yaml>

# then you can check the log of the container
kubectl logs configmap-test-pod | grep FOOBAR
FOOBAR_SEX=m
FOOBAR_AGE=37 
```
Note that for each env var, it can read from a different config map.

As the env var are created during the initialization of the pod, you can call env var in the pod's command.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-envvar-pod
spec:
  containers:
    - name: test-container
      image: busybox
      # call the env var
      command: [ "/bin/echo", "$(FOOBAR_AGE), $(FOOBAR_SEX)" ]
      env:
        # Define the environment variable in the container
        - name: FOOBAR_AGE
          valueFrom:
            configMapKeyRef:
              # The ConfigMap name containing the value you want to assign to FOOBAR_AGE
              name: pengfei-config
              # Specify the key in the configMap wwhich you want to show the value
              key: pengfei.age
        - name: FOOBAR_SEX
          valueFrom:
            configMapKeyRef:
              name: pengfei-config
              key: pengfei.sex
        
  restartPolicy: Never
```

#### Create env vars by using envFrom
Use envFrom to convert all the ConfigMap's data as container environment variables

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-envfrom-pod
spec:
  containers:
    - name: test-container
      image: busybox
      command: [ "/bin/sh", "-c", "env" ]
      # In envFrom, we just put the name of the configMap, it will get all the key value pair and put it as evn var in the container
      envFrom:
      - configMapRef:
        # name of the config map
          name: game-config
  restartPolicy: Never
```
When you check the env var of the container, it takes the raw data of the configMap. For example, for the 
ui.properties key, it set the env var as followed. Not very useful.

```text
ui.properties=color.good=purple
color.bad=yellow
allow.textmode=true
how.nice.to.look=fairlyNice
```

### Include configMap in a pod by using volume

Add the ConfigMap name under the volumes section of the Pod specification. This adds the ConfigMap data to the 
directory specified as volumeMounts.mountPath

In the following example, we create a volume by calling a configMap, then we mount the volume to a container.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-vol-pod
spec:
  containers:
    - name: test-container
      image: k8s.gcr.io/busybox
      # let the container sleep for 600 sec to keep it running. So we can do kubectl exec on the container
      command: [ "/bin/sh","-c","sleep 600" ]
      # mount an existing volume on the container 
      volumeMounts:
      - name: pengfei-volume
        mountPath: /etc/config
  # create a volume by using the config map
  volumes:
    # name of the volume
    - name: pengfei-volume
      configMap:
        # name of the config map
        name: game-config
        items:
          # key name
        - key: game.properties
          # path of the file which will contain the value of the key
          path: game.properties
        - key: ui.properties
          path: ui.properties
  restartPolicy: Never

```
