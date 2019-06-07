# An introduction to Drools
Drools is a business rules management system (BRMS) that allows separation of business logic from applications.  It allows application developers to focus more on interfaces, performance, persistence, deployment and less so on managing and updating business rules.  By centralising the business rules within an organisation, it also offers business experts greater access to, and control of rules.

## Introduction
In this introductory course, the various components of Drools including the Business Central UI, KIE Execution Server, rule authoring and rule execution are explored.

## Business Central and KIE execution servers
In this example, rules will be created in Business Central and deployed to multiple KIE execution servers. Docker Compose will be used to spin up the containers:
```shell
docker-compose up
```
