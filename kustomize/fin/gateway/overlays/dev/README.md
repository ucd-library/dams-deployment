Notes for fix of ingress not binding to port 80:

```
[remove gateway ingress]
sudo microk8s disable ingress
sudo reboot
sudo microk8s enable ingress
[add gateway ingress]
```