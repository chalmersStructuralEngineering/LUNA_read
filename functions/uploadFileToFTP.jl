using FTPClient

function uploadFileToFTP(filepath, remote_path, user, pwrd, host, rcpt)

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
        sendEmail(ENV["SMTP_USERNAME_gm"], ENV["SMTP_PASSWORD_gm"], ENV["SMTP_HOSTNAME_gm"], rcpt, "Failed to upload file to FTP server!")
    finally
        # Remember to close the FTP connection
        close(ftp)
    end

end
