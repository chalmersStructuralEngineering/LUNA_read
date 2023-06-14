using PyCall

# Import Python's built-in ftplib
ftplib = pyimport("ftplib")

function uploadFileToFTP2(filepath, remote_path, username, password, hostname)

    ftp = ftplib.FTP(hostname, username, password)

    try
        # Open the file in binary mode and upload
        open(filepath, "r") do file
            ftp.storbinary("STOR " * remote_path, file)
        end
        println("File uploaded successfully.")
    catch e
        println("Failed to upload the file.")
        println(e)
    finally
        # Remember to close the FTP connection
        ftp.quit()
    end
end


