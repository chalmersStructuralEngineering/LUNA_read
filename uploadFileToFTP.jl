using FTPClient

function uploadFileToFTP(local_path, remote_path)
    ftp_options = RequestOptions(hostname="ftp.box.com",
        username=ENV["FTP_USERNAME"]
        password = ENV["FTP_PASSWORD"]
        port = 21.0to_i,
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
