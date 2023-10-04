using FTPClient

function uploadFileToFTP(files, user, pwrd, host, rcpt)

    ftp_options = RequestOptions(hostname=host,
        username=user,
        password=pwrd,
        port=21,
        ssl=false)

    ftp = FTP(ftp_options)  # Create a new FTP object

    try
        for (key, value) in files
            println("Uploading file ", key, " to FTP server")
            # Open the file in binary mode and upload
            open(value[1], "r") do file
                upload(ftp, file, value[2])  # Upload IO content as file on FTP server
            end
            println("File uploaded successfully.")
        end
    catch e
        println("Failed to upload the file.")
        println(e)
        # sendEmail(ENV["SMTP_USERNAME_gm"], ENV["SMTP_PASSWORD_gm"], ENV["SMTP_HOSTNAME_gm"], rcpt, "Failed to upload file to FTP server!")
    finally
        # Remember to close the FTP connection
        close(ftp)
    end

end
