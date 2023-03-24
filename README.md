# vault-kubernetes
Playbooks to configure and setup Hashicorp vault for use in Kubernetes

# Kubernetes PKI Requirements

Thankfully, Kubernetes provides some pretty good documentation on how to setup certificates. 
Unfortunately, It's not exactly clear what's expected. 

|           Default CN          |         Parent CA         | O (in Subject) |      kind      |                 hosts (SAN)                 |
|:-----------------------------:|:-------------------------:|:--------------:|:--------------:|:-------------------------------------------:|
| kube-etcd                     | etcd-ca                   |                | server, client | <hostname>, <Host_IP>, localhost, 127.0.0.1 |
| kube-etcd-peer                | etcd-ca                   |                | server, client | <hostname>, <Host_IP>, localhost, 127.0.0.1 |
| kube-etcd-healthcheck-client  | etcd-ca                   |                | client         |                                             |
| kube-apiserver-etcd-client    | etcd-ca                   | system:masters | client         |                                             |
| kube-apiserver                | kubernetes-ca             |                | server         | <hostname>, <Host_IP>, <advertise_IP>, [1]  |
| kube-apiserver-kubelet-client | kubernetes-ca             | system:masters | client         |                                             |
| front-proxy-client            | kubernetes-front-proxy-ca |                | client         |                                             |
