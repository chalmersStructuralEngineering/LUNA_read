# LUNA_read
Files to connet to LUNA, read, save and upload to the FTP written in Julia

The code reads teh 8 Luna channels and stores the data on specific intervals of time (int). In order to reduce possible anomalies in the readings a set of continuous readings are performed and thereafter average for each reading.
The number of readings is controlled by the ts var, which indicated teh total number of readings, all channels, that means this values is divided by the number of ACTIVE channels. 

Once the data is stored locally, it can be uploaded to an FTP server. Due to an issue with the Julia library, the Python library is used instead. 
