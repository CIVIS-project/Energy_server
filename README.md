# CIVIS Energy ICT server code

CIVIS’s EU cofunded project focuses on the ICT-enabled social dimension to harness the potential of innovation of individuals and collectives with respect to energy prosumption. 
CIVIS WP4 work package ha developed an Energy ICT platform, enabling the possibilities to:
- collect energy data from enabled dwellings (data from sensors and data from energy DSO);
- store energy data into system DBs after proper format manipulations;
- process energy data with specific software modules in order to identify useful information for the upper layers of the overall architecture  (such as the You Power App)


## Getting Started

These instructions will provide information useful for development and testing purposes. 

### Prerequisities

This code requires Windows OS and has been developed with:  
* Visual Studio 2013 (RESTful APIs)
and deployed on Microsoft Windows Server 2012 R2 with: 
* Microsoft SQL server 2012 (database)

### Installing
The code is structured in the following folder:
- Database
	* Executing those scripts you will get a database like the one deployed for handling data from Trentino pilot 
	It also contain TSQL programmability objects. You have to take care to schedule stored procedure execution for periodic data aggregation and analyis.
- RESTful APIs 
	* Shall be deployed on IIS. Provide the interfaces for: 
		- receiving data from sensors and storing them in to the database after proper format manipulations
		- providing services required by upper layers, such as aggregated data, suggestions for energy savings
- Reasoning 
	* This folder contains ontology models and Jena rules as used by Hi Reply reasoner.


## Authors
Francesco Cuscito, Paola Dal Zovo, Liudmila Dobriakova

## License

This project is licensed under the GPLv3.0 License - see the [LICENSE.txt](https://github.com/CIVIS-project/Energy_server/blob/master/License.txt)  file for details

#
