# Hack your Domain-Specific Language - Alexis Facques

Domain-Specific Languages (DSL) - Master Cloud Computing & Services Project - Université de Rennes 1

Domain-Specific Language (DSL) development for modelling variability, using **JAVA**, **Eclipse XTEXT and XTEND**.
This includes :
- Creating an abstract syntax and grammar for our DSL;
- Developing model transformations towards other file formats (JSON, Natural Language, CNF);
- Solving (Deadlock feature detection, satisfiability...) random Feature Models using our DSL and implemented solvers such as [Sat4J](http://www.sat4j.org/).

Practical uses of our DSL will be shown through the development of a feature model configurator, using **NodeJS**.

## External links

- [Course's repository](https://github.com/FAMILIAR-project/HackOurLanguages-SIF)
- [Detailed project milestones](https://docs.google.com/document/d/1t2qIumAGT4mXSBazm8pMCxPXZv87qo3jEHRHCIiTsVE/edit)

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

- Clone this repo, build the docker image:

```
    git clone https://github.com/alexisfacques/DSL-Feature-Modelling.git
    cd DSL-Feature-Modelling/web
    docker build --tag featuremodelling .
```

- Run the image as such:

`docker run -v -p 8080:8080 featuremodelling`

- Web feature model configurator is available on `http//localhost:8080`.

## Project milestones - Table of contents

[Project report is available here](PROJECT_REPORT.pdf)

### Milestone 1 - Basic Feature Model and XTEXT

Worth checking:
- [XText Grammar](com.alexisfacques.xtext.featurediagram/src/com/alexisfacques/xtext/FeatureDiagram.xtext)
- [Example of use](web/data/test.diagram)

### Milestone 2 - Transformation of Feature Models

Worth checking:
- [DIMACS transformation strategy (interoperability with SAT4J solvers) solvers](com.alexisfacques.xtext.featurediagram/src/com/alexisfacques/xtext/FeatureDiagramToCNF.xtend)
- [JSON transformation strategy](com.alexisfacques.xtext.featurediagram/src/com/alexisfacques/xtext/FeatureDiagramToJSON.xtend)
- [Minizinc format transformation strategy (interoperability with CSP solvers)](com.alexisfacques.xtext.featurediagram/src/com/alexisfacques/xtext/FeatureDiagramToMZN.xtend)
- [SAT4J Solver implementation](com.alexisfacques.sat4j/src/com/alexisfacques/sat4j/Sat4JSolver.java)
- [Random feature model generator](com.alexisfacques.xtext.featurediagram/src/com/alexisfacques/xtext/FeatureDiagramGeneration.xtend)
- [Executable .jars files](web/bin)

### Milestone 3 - For Feature Model to Wizards and configurator

Worth checking:
- [Angular application sources](web/angular-src/src/app)
- [NodeJS web server](web/src/app.ts)

## License

This project is licensed under the MIT License.
