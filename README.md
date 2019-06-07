# An introduction to Drools
Drools is a business rules management system (BRMS) that allows separation of business logic from applications.  It allows application developers to focus more on interfaces, performance, persistence, deployment and less so on managing and updating business rules.  By centralising the business rules within an organisation, it also offers business experts greater access to, and control over rules.

## Introduction
In this introductory course, the various components of Drools including the Business Central UI, KIE Execution Server, rule authoring and rule execution are explored.

## Business Central and KIE execution servers
### Starting servers
In this example, rules will be created in Business Central and deployed to multiple KIE execution servers. Docker Compose will be used to spin up the containers.  The two required files are located in the [business-central-and-kie-servers](business-central-and-kie-servers] directory in this project.  To start the containers from a local directory containing the [docker-compose.yaml](business-central-and-kie-servers/docker-compose.yaml) file, run:

```shell
docker-compose up
```

This will create an isolated Docker network wherein the Docker hosts may refer to each other by hostname. The Business Central UI instance (```drools-workbench```) will act as the controller for the three KIE execution servers (```kie-server-1```, ```kie-server-2``` and ```kie-server-3```).  The KIE execution servers are designed to fail starting up if they cannot connect to the controller.  Consequently, a delay is needed to prevent the KIE execution servers from starting up.  Because Docker's ```depends-on``` cannot know when Business Central is ready to receive connections, [wait-for-workbench.sh](business-central-and-kie-servers/wait-for-workbench.sh) will continuously poll a Business Central REST endpoint to check for readiness.  Once ready, the KIE servers will resume the startup process.  The KIE execution servers use websockets to communicate with the Business Central controller.

Once the startup pocess is complete (this may take a few minutes), log in to the Business Central UI at http://127.0.0.1:3930/business-central/ with the credentials ```admin``` and ```admin```.  Note that ```/business-central``` is required because the base URL is a Wildfly application server than can host multiple applications (```business-central``` being the only one in this case).  Once logged into the workbench, verify the three execution servers have registered themselves with the Business Central controller by visiting ```Deploy``` > ```Execution Servers``` in the UI and ensuring three server configurations exist with a remote server defined for each.

To verify the execution servers are up, retrieve basic information on each of the KIE execution servers by making GET requests with Basic Auth (base64 encoded) to:
```shell
curl -u admin:admin -H 'Accept:application/json' http://127.0.0.1:3931/kie-server/services/rest/server
curl -u admin:admin -H 'Accept:application/json' http://127.0.0.1:3932/kie-server/services/rest/server
curl -u admin:admin -H 'Accept:application/json' http://127.0.0.1:3933/kie-server/services/rest/server
```
To browse the API documentation of the KIE execution servers, visit http://127.0.0.1:3931/kie-server/docs.  This will provide Swagger UI formatted endpoint definitions with examples.  To browse the API documentation of Business Central, visit http://127.0.0.1:3930/business-central/docs, also in Swagger format.

### Importing projects
To import a project, visit the ```Designs``` > ```Projects``` page and choose Import Project.  In the ```Repository URL``` enter https://github.com/danial-k/drools-sample.git.  Note that imported projects should have ```kjar``` (Knowledge JAR) packaging as part of a valid ```pom.xml``` file and a ```kmodule.xml``` META-INF file defined.  Furthermore, the Business Central import utility will only use the ```master``` branch.  Once the project is displayed in the ```Import Projects```, select the project and choolse ```Ok```.  This will initiate the asset indexing process and initialise the project in Business Central's internal git repository.

Note that the task of importing a project into Business Central may also be accomplished by making a ```POST``` request to http://127.0.0.1:3931/business-central/rest/spaces/MySpace/git/clone with the following payload (assuming the space has already been created): 
```json
{
  "name": "Example Project",
  "description": "Example Project imported from GitHub",
  "gitURL": "https://github.com/danial-k/drools-sample.git"
}
```

### Build and deploy to Execution Servers
Once a project has been built using Business Central's internal Maven build tooling, the JARs will be available at ```/business-central/maven2/```
