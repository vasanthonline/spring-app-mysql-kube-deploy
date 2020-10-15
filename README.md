# spring-app-mysql-kubernetes
Deployment orchestration for spring app &amp; mysql via Kubernetes to EKS

## Setup EKS Cluster

To create a new cluster based on the inputs provided. To create a Node group within the cluster based on the machine type and node group size.

`sh ./eck-cluster-setup.sh`

## Setup Application

Given a kubernetes cluster, create a new application and database. Create a persistent volume and associate with the application. Connect the application to the database via a db_url, db_username and db_password secret.

`sh ./build.sh`

`sh ./deploy.sh`


## Teardown Application

Teardown the provisioned application, database and it's associated secrets.

`sh ./teardown.sh`

## Definition of TODO parameters

### Cluster Parameters

| Parameter     | Data type     | Definition  |
| ------------- |:-------------:| -----:|
| <TODO_CLUSTER_NAME> | string | The name of the Kuberenetes cluster |
| <TODO_CLUSTER_NODE_GROUP> | string | The name of the node group inside the Kubernetes cluster |
| <TODO_CLUSTER_NODE_GROUP_TYPE> | string | The type of the instance / machine to be created in the node group. Eg: `t2.micro`, `m4.large`, `p3.2xlarge` etc. |
| <TODO_CLUSTER_NODES_COUNT> | number | The number of instances in the node group. |
| <TODO_CLUSTER_NODES_MIN> | number | The minimum number of instance in the node group. Used for auto-scaling when load decreases. |
| <TODO_CLUSTER_NODES_MAX> | number | The maximum number of instance in the node group. Used for auto-scaling when load decreases. |
| <TODO_CLUSTER_REGION> | string | The region in which the cluster is to be created. Eg: `us-east-2`, `us-west-1` etc |
| <TODO_CLUSTER_SSH_KEY> | string | The local path to the public SSH key created via https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#prepare-key-pair |

### Application Parameters

| Parameter     | Data type     | Definition  |
| ------------- |:-------------:| -----:|
| <TODO_APP_ENV> | string | The environment of the application. Could be `dev`, `staging`, `production` etc.|
| <TODO_APP_NAME> | string | The name of the application. |
| <TODO_APP_PROFILE> | string | The [Maven profile](http://maven.apache.org/guides/introduction/introduction-to-profiles.html) of the application. Optional. |
| <TODO_APP_VERSION> | string | The version of the application. Preferably a [semver](https://semver.org/) based version string. |
| <TODO_ORGANIZATION_NAME> | string | The name of the organization owning the application. |

### Database Parameters

| Parameter     | Data type     | Definition  |
| ------------- |:-------------:| -----:|
| <TODO_DB_INSTANCE> | string | The name of the DB instance. |
| <TODO_DB_ROOT_PASSWORD> | string | The root user password to be set of the DB instance. |
| <TODO_DB_USERNAME> | string | The non-root user to be created for access to the database. |
| <TODO_DB_PASSWORD> | string | The password of the non-root user to be created for access to the database. |
| <TODO_USE_SSL> | boolean | Flag to indicate whether the application should use SSL to connect to database. |


### Docker Parameters

| Parameter     | Data type     | Definition  |
| ------------- |:-------------:| -----:|
| <TODO_DOCKER_HUB_EMAIL> | string | The email associated with the [Docker hub](https://hub.docker.com/) account. |
| <TODO_DOCKER_HUB_PASSWORD> | string | The username associated with the [Docker hub](https://hub.docker.com/) account. |
| <TODO_DOCKER_HUB_USERNAME> | string | The password associated with the [Docker hub](https://hub.docker.com/) account. |
