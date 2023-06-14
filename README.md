# LUNA_read
Files to connet to LUNA, read, save and upload to the FTP written in Julia

The code reads the 8 Luna channels and stores the data in specific intervals of time (int). In order to reduce possible anomalies in the readings a set of continuous readings are performed and thereafter averaged for every iteration.
The number of readings is controlled by the ts var, which indicated the total number of readings, for all channels, that means this values is divided by the number of ACTIVE channels. 

Once the data is stored locally, it can be uploaded to an FTP server. Due to an issue with the Julia library, the Python library is used instead. 
The issue with teh Julia Library is identifyed it does not accept '@' symbols in the user name so it needs to be replaced by %40 instead. Once this is done teh library manages to upload the files to the FTP correctly. 
