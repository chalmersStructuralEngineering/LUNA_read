using FTPClient

function uploadFileToFTP(local_path, remote_path, user, pwrd, host)
    ftp_options = RequestOptions(hostname=host,
        username=user,
        password=pwrd,
        port=21,
        ssl=false)

    ftp = FTP(ftp_options)  # Create a new FTP object

    resp = upload(ftp, local_path, remote_path)  # Upload the file

    if resp.code != 226
        println("Failed to upload the file.")
    else
        println("File uploaded successfully.")
    end

    close(ftp)  # Always ensure to close the FTP connection once done
end

function uploadFileToFTP2(filepath, remote_path, user, pwrd, host)

    ftp_options = RequestOptions(hostname=host,
        username=user,
        password=pwrd,
        port=21,
        ssl=false)

    ftp = FTP(ftp_options)  # Create a new FTP object

    try
        # Open the file in binary mode and upload
        open(filepath, "r") do file
            upload(ftp, file, remote_path)  # Upload IO content as file "Assignment3-copy.txt" on FTP server
        end
        println("File uploaded successfully.")
    catch e
        println("Failed to upload the file.")
        println(e)
    finally
        # Remember to close the FTP connection
        close(ftp)
    end
end
