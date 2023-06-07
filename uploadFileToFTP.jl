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
