<h1>Kubernetes assignments</h1>

<h3>Task 1:</h3>

Create a simple "fortune" container, on every http connection it should return some random phrase.

Create a simple pod/deployment that will run that container.

<h3>Task 2:</h3>

Use a Deployment instead of just a pod.

Create a service pointing to that deployment.

Create an ingress to make your service accessible on the internet.

Connect to ext. kube-cluster with kubectl and deploy everything there, check dns + http/s ingress + cert-manager settings.

<h3>Task 3:</h3>

Create persistent volume, check how it works.

Create new statefulset/deployment with stateful app (db, site with data, etc), use pv/pvc.

Do best practices.

<h3>Task 4:</h3>

Create Helm Chart, move everything from task 3 to it.

Add new values and modifications to statefulset/deployment.


