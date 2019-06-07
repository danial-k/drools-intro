# An introduction to Drools
Drools is a business rules management system (BRMS) that allows separation of business logic from applications.  It allows application developers to focus more on interfaces, performance, persistence, deployment and less so on managing and updating business rules.  By centralising the business rules within an organisation, it also offers business experts greater access to, and control of rules.

## Introduction
In this introductory course, the various components of Drools including the Business Central UI, KIE Execution Server, rule authoring and rule execution are explored.

## Business Central and KIE execution servers
In this example, rules will be created in Business Central and deployed to multiple KIE execution servers. Docker Compose will be used to spin up the containers.  Two required files are located in the (business-central-and-kie-servers)[business-central-and-kie-servers] directory in this project.  To start the containers from a local directory containing the [docker-compose.yaml](business-central-and-kie-servers/docker-compose.yaml) file, run:

```shell
docker-compose up
```
This will create a private Docker network wherein the Docker hosts may refer to each other by hostname. The Business Central UI instance (```drools-workbench```) will act as the controller for the three KIE execution servers (```kie-server-1```, ```kie-server-2``` and ```kie-server-3```).  The KIE execution servers are designed to fail starting up if they cannot connect to the controller.  Consequently, a delay is needed to prevent the KIE execution servers from starting up.  Because Docker's ```depends-on``` cannot know when Business Central is ready to receive connections, [wait-for-workbench.sh](business-central-and-kie-servers/wait-for-workbench.sh) will continuously poll a Business Central REST endpoint to check for readiness.  Once ready, the KIE servers will resume the startup process.
