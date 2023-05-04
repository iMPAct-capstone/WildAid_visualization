# WildAid Visualization

The purpose of this repository is to visually display MPS tracker data. The final product will include an R Shiny application with interactive displays of MPS tracker data. 

Visualizations will include previously collected data from 2019-2022, reformatted in the WildAid_data_reformatting repository. They will also incorporate future data entered in the R shiny application created in the WildAid_data_entry repository. 

This README.txt file was generated on 2023-05-03 by the iMPAct Team 

**GENERAL INFORMATION**

1. Title of the Project: Improving Monitoring & Evaluation of Marine Enforcement in Coastal Marine Protected Areas and Fisheries 

2. Author Information 
Names: Kiran Favre, Elise Gonzales, Jared Petry, Adelaide Robinson
Institution: University of California, Santa Barbara

A. Client Contact Information
Name: Silvia Bor
Organization: WildAid Marine

3. Date of data collection
The data is continually input annually for sites across the globe.  The purpose of this tool is to make the data entry and visualization process much easier than in the past.  The data has been collected since 2019.

4. Geographic location of data collection: global


**SHARING/ACCESS INFORMATION**

1. Licenses/restrictions placed on the data: 
This data set is the property of WildAid Marine and is not intended for public reuse. Data sharing will occur only with the permission of this organization.

2. Links to other publicly accessible locations of the data: 
This data is not currently available for public use. Permission can be requested from the client organization at marine@wildaid.org.


**DATA & FILE OVERVIEW**

1. File List:

MPS Tracker Data:
Description: The data set contains ongoing WildAid Marine Protection System Tracker data. This tracking system was designed to measure various metrics of enforcement performance of marine protected areas or fisheries with whom WildAid partners.
Format: Google Sheet
Variables include: 
category: overall category evaluated
sub_category: specific category evaluated
indicator_type: type of indicator monitored by sub category
score: 1-5 score based on scoring metric described in metadata
country: the country the site is in or managed by
site: The marine protected area or fishery evaluated
comments: justification for score and further details of observations
entered_by: site evaluator(s) who entered the observation
visualization_include: yes or no variable to identify rows of data that should not be included in the visualization
Missing data codes: NA

Site List:
To keep track of information for each site and to be used in creating a map of the sites in the visualization application.
Format: Google Sheet
Variables Include:
country
site
latitude: WGS 84
longitude: WGS 84
partners: organizations associated with the specific project
size: the geographic area of the site
PMS: on-site project managers 
status: (aka implementation status) Refers to WildAid Marine’s blueprint for Marine Protection Plan. https://marine.wildaid.org/about-us/our-model/
active_site: A description of whether or not the site is active 
Year Started Working: the year that indicates the outset of the project at this site

2. Are there multiple versions of the dataset? 
The previous version of the data set was stored in multiple Excel files. There is currently only one version of the reformatted data set. The source code that originally manipulated the excel sheets into machine readable format is available in the WildAid_data_reformatting repository within this Github organization.

**METHODOLOGICAL INFORMATION**

1. Description of methods used for collection/generation of data:

MPS tracker data is collected on an annual basis at the site level. A site can include an entire EEZ, a single marine protected area or fishery, or a network of smaller protected marine areas. In 2023, the system through which MPS tracker data was collected and synthesized was redone as part of the MEDS capstone project. 

Data collected for 2022 and prior: Excel files containing the latest version of the MPS tracker were sent to on-site program managers annually. Once they received the tracker, on-site program managers scored each sub-category based on provided metrics using their knowledge of the site and through discussions with on-site partner organization staff. Regional managers and additional staff worked cooperatively to fill out the tracker as needed. When complete, trackers were emailed back to the Marine Program Manager for review. Adjustments to scores were made through discussions with Marine Program Managers to ensure the scores were accurate and followed the provided metrics. The content monitored in the tracker was updated on an annual basis. Because of these updates, sub-categories monitored, scoring criteria, the names of sub-categories, and the category label of each sub-category varied from year to year. There were also variations in the version of the tracker filled out across sites within the same year. Metrics (how to score, scoring criteria), categories, and sub-categories used for each year of data collection are available in the template versions of the tracker in the metadata folder. An additional tab containing supplemental information for each sub-category is available for 2021 and 2022. This folder includes one template for the tracker for a year; however, there were minor differences between versions of the tracker used at sites for a given year.
    
Data collected for 2023 onward: On-site program managers are notified annually that they should begin filling out the MPS tracker for their sites. Managers log on to the data-entry R shiny application using username and password. On-site project managers score each of the categories based on the provided metrics using their knowledge of the site and through discussions with on-site partner organization staff. Metrics provided and sub-categories monitored are consistent with those in the 2022 version of the tracker. Multiple project managers can work in conjunction to fill out the tracker, and drafts can be saved over time. When the entire tracker is entered, the Marine Program Manager will review and work with the on-site managers to ensure data accuracy.

Scoring: All sub-categories are scored with an integer between 1 and 5. Scores are based on provided scoring guidelines.


2. Methods for processing the data: 
The data was processed into a machine readable format by following tidy data principles.  The source code that originally manipulated the excel sheets into machine readable format is available in the WildAid_data_reformatting repository within this Github organization.

3. Instrument- or software-specific information needed to interpret the data:
The data used was processed using R and packages tidyxl, readxl, and googlehseets4.  The data entry and visualization applications we have created make it so that anyone with the link to these web apps can effectively analyze and interpret our data with no training in programming or external tools.

4. Quality-assurance procedures performed on the data:
In the past, the WildAid Marine Program Manager would manually validate the data.  Now, the WildAid data entry application will ensure that the correct data types are entered and populate the google spreadsheet.  With the pipeline through the google sheets interface, if there are any problems with the data, anyone with a working knowledge of google sheets can manually change the data without coding or database training.

5. People involved with sample collection, processing, analysis and/or submission:
The WildAid Marine Program Manager, local project managers and team, and local partners were responsible for collecting and entering the data. The capstone team was responsible for processing the data into a machine readable format for the applications.  The data entry and visualization web applications were created using RShiny by the capstone team.
