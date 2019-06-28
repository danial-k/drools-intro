# An introduction to Drools
Drools is a business rules management system (BRMS) that allows separation of business logic from applications.  It allows application developers to focus more on interfaces, performance, persistence, deployment and less so on managing and updating business rules.  By centralising the business rules within an organisation, it also offers business experts greater access to, and control over rules.

## Introduction
In this introductory course, the various components of Drools including the Business Central UI, KIE Execution Server, rule authoring and rule execution are explored.

## Business Central and KIE execution servers
### Starting servers
In this example, rules will be created in Business Central and deployed to multiple KIE execution servers. Docker Compose will be used to spin up the containers.  The two required files are located in the [business-central-and-kie-servers](business-central-and-kie-servers) directory in this project.  To start the containers from a local directory containing the [docker-compose.yaml](business-central-and-kie-servers/docker-compose.yaml) file, run:

```shell
cd business-central-and-kie-servers
docker-compose up
```
If using Windows and a shell syntax error is received, ensure line endings in ```wait-for-workbench.sh``` are ```LF``` and not ```CRLF```.

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
#### Manually via Business Central UI
To import a project, visit the ```Designs``` > ```Projects``` page and choose Import Project.  In the ```Repository URL``` enter https://github.com/danial-k/drools-sample.git.  Note that imported projects should have ```kjar``` (Knowledge JAR) packaging as part of a valid ```pom.xml``` file and a ```kmodule.xml``` META-INF file defined.  Furthermore, the Business Central import utility will only use the ```master``` branch.  Once the project is displayed in the ```Import Projects```, select the project and choolse ```Ok```.  This will initiate the asset indexing process and initialise the project in Business Central's internal git repository.  Note that on login, the default spaces ```MySpace``` is created.

#### Automated via API calls
Ensure that at least one space exists in which projects may be created.  Without logging in, a default space will not be created.  To retrieve the current spaces in managed by Business Central:
```bash
curl -u admin:admin -H 'Accept:application/json' http://127.0.0.1:3930/business-central/rest/spaces
```
If the response is empty, create a new space with:
```bash
curl --request POST \
  -u admin:admin \
  --url http://127.0.0.1:3930/business-central/rest/spaces \
  --header 'Content-Type: application/json' \
  --data '{"name": "ExampleSpace", "description": "Example space for projects.", "owner": "admin", "defaultGroupId": "ExampleSpace"}'
```

To trigger an import request into the newly created space, execute the following:
```shell
curl --request POST \
  -u admin:admin \
  --url 'http://127.0.0.1:3930/business-central/rest/spaces/ExampleSpace/git/clone' \
  --header 'Content-Type: application/json' \
  --data '{"name": "ExampleProject", "description": "Example Project", "gitURL": "https://github.com/danial-k/drools-sample.git"}'
```
The project should then be visible in the Business Central UI.  For further information on the Business Central UI, consult the [Business Central Integration chapter](https://docs.jboss.org/drools/release/7.23.0.Final/drools-docs/html_single/index.html#knowledge-store-rest-api-con_decision-tables) of the Drools documentation.

### Build and deploy to Execution Servers
Once a project has been built using Business Central's internal Maven build tooling, the JARs will be available at ```/business-central/maven2/```
