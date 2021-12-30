# DOKS_challenge
[![DigitalOcean Referral Badge](https://web-platforms.sfo2.cdn.digitaloceanspaces.com/WWW/Badge%201.svg)](https://www.digitalocean.com/?refcode=d7e559710d53&utm_campaign=Referral_Invite&utm_medium=Referral_Program&utm_source=badge)

Hi, My name is Magnus, also known as nigma1337, and this is my explaination of the Digitalocean kubernetes challenge, upgrade inside a vcluster.

### Step 0.5
First off, we need to create a cluster.
Personally, I made a terraform configuration to create a cluster on digitalocean, just as a small added challenge, just add your API key (which can be gotten via the DO website, under the API menu) to [terraform.tfvars]terraform.tfvars and do `terraform apply`. You can also just create the cluster via the digitalocean website. I'm gonna go with DOKS version `1.19.15-do.0`, and as i'm planning to upgrade it to version `1.21.5-do.0`, because I need to make sure my workflow is compatible with Kubernetes version `1.21.5`

Also made sure to grab the kubeconfig file, via `doctl kubernetes cluster kubeconfig show -t <API-KEY-HERE> terraform-do-cluster >> ~/.kube/config`, which will also set our current context to the new cluster

I didn't use `doctl kubernetes cluster kubeconfig save`, as that didn't work for me, throwing an error about the cluster not being found

### Step 1 
Now, let's get to the real part. Install the vcluster CLI via 
```
curl -s -L "https://github.com/loft-sh/vcluster/releases/latest" | sed -nE 's!.*"([^"]*vcluster-linux-amd64)".*!https://github.com\1!p' | xargs -n 1 curl -L -o vcluster && chmod +x vcluster;
sudo mv vcluster /usr/local/bin;
```
(commands taken from https://www.vcluster.com/docs/getting-started/setup)

### Step 2
Time to create the vcluster.

The command we'll run looks like this:
`vcluster create <name> -n <namespace> --k3s-image <k3s image name>`

So after filling out the blanks, we'll end up with this, as we want k3s version 1.21.5:
`vcluster create testcluster -n virtual-cluster --k3s-image rancher/k3s:v1.21.5-k3s2`

Then, run
`kubectl get pods -n virtual-cluster` 
to check the status of our virtual cluster, it should look something like this
```
NAME                                                   READY   STATUS    RESTARTS   AGE
coredns-7448499f4d-d5vs6-x-kube-system-x-testcluster   1/1     Running   0          67s
testcluster-0                                          2/2     Running   0          99s
```

### Step 3
Let's connect to the cluster!

The output of our create commands tells us to use 
`vcluster connect testcluster --namespace virtual-cluster`
to access the cluster.

This writes a kubeconfig.yaml file to your current directory, which allows kubectl access to the cluster, and forwards local port 8443 to port 8443 on the cluster.

### Cleanup
To cleanup, remove the cluster via `terraform destroy` or via the digitalocean website. Keep in mind, you also have to manually delete the volume vcluster created.