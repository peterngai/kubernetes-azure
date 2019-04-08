# kubernetes-azure
This is an example project of setting up a hybrid kubernetes cluster on Azure.  We'll be utilizing acs-engine to help provision the VMs and nodes and kubernetes to orchestrate a hybrid environment of linux and windows containers.

## Required environments and software
To utilize this project, you'll need a valid Azure environment -- one where you have proper permissions to create Service Principals.  If you would need to, you can sign up for a free trial account here: 
* https://azure.microsoft.com/en-us/free/

Also, you'll need to download a copy of the acs-engine binary and install it locally.  This executable would need to be accessible from your path.  Download the binary here:
* https://github.com/Azure/acs-engine/releases/latest

## Instructions
This tutorial is divided into 2 parts:
1. Setting up the Kubernetes cluster
2. Logging onto the jumpbox and installing a pod and service

### Setting up the Kubernetes cluster
A kubernetes cluster on Azure is a mixture of 3 vms, jumpboxes, pools, network interfaces, etc.., -- the good news is that this project includes a script that can be automatically run to create this.  Below is a pictoral representation of the cluster:

![alt text](https://github.com/peterngai/kubernetes-azure/blob/master/images/acs-engine-win-containers.png)

1.  Navigate to the model directory
2.  Edit the env.sh file by specifying values for RESOURCE_GROUP, LOCATION, DNS, ADMIN_USER, ADMIN_PASSWORD, SSH_PUBLIC_KEY -- for an example of the values, please refer to the file env-my-example.sh.
3.  Run the file ./deploy-k8s-hybrid-simple.sh -- this will provision out your Kubernetes cluster, along with the jumpbox, and should take about 16 minutes to complete.
4.  Now, once deployment is completed, you should be able to navigate the resources in the Azure dashboard.  Take note of the jumpbox external ip address (for example, this is listed as 192.168.1.100 below)

![alt text](https://github.com/peterngai/kubernetes-azure/blob/master/images/jumpbox-ip.png)

### Logging onto the jumpbox and installing a pod and service
This next step involves deploying a pod and a service to the Kubernetes cluster.  In order to perform these operations, one must be ssh-ed onto the jumpbox.  Gathering the external IP address from the previous step will help with this.

NOTE -- keep in mind that specifying your SSH_PUBLIC_KEY in the previous step, while editing the env.sh file, is crucial.  Only from the system which possesses this public key will be allowed access.  Again, check the sample env.sh file, env-my-example.sh, for a sample.  Not sure how to establish your public key?  Search online for the term "ssh key how to gather your public key" to help figure out how -- its a separate topic and can get lengthy, depending on your environment.

Ok, let's continue...

1.  Log onto the jumpbox by typing in the command: ssh <ADMIN_USER>@<JUMPBOX EXTERNAL IP>    (from my example, this would be ssh azureadmin@192.168.1.100)
2.  Change ownership of the established account:  sudo chown <ADMIN_USER>:<ADMIN_USER> -R ../<ADMIN_USER>    (from my example, this would be sudo chown azureadmin:azureadmin -R ../azureadmin)
3.  Log off of the jumpbox and return back to your system, by typing: exit
4.  Copy the files located in the "apps" directory to the jumpbox, by typing the following scp apps/iis-* <ADMIN_USER>@<JUMPBOX EXTERNAL IP>:~   (from my example, this would be scp apps/iis-* azureadmin@192.168.1.100:~)
5.  Log back onto the jumpbox by typing the command: ssh <ADMIN_USER>@<JUMPBOX EXTERNAL IP>    (from my example, this would be ssh azureadmin@192.168.1.100)
6.  Create the pod by typing the following:  kubectl create -f iis-pod.yaml    This operation will take a few minutes to complete as its pulling a large docker image from dockerhub (~2GB)
7.  Create the service by typing the following:  kubectl create -f iis-service.yaml    This operation will take a few minutes to complete as its attempting to allocate an external IP address and bind to the pod.  Keep in mind that its not necessary for the pod to be completed as these two operations are independent.
8.  Type the following command to see if the kubectl operations have completed.  Once they are completed, the pod should be listed as "Running" and an External-IP address should be found under the svc/win-webserver service.

![alt text](https://github.com/peterngai/kubernetes-azure/blob/master/images/kubectl-op.png)

9.  Let's confirm the pod and service are running correctly by navigating to http://\<EXTERNAL-IP\>.  You should see the generic IIS page.

You've just established a Kubernetes cluster and deployed a pod and service!

Cheers!
