using SMTPClient

function sendEmail(user, pwrd, host, rcpt, content)
    opt = SendOptions(
        isSSL=true,
        username=user,
        passwd=pwrd)

    body = IOBuffer(
        "Date: Fri, 18 Oct 2013 21:44:29 +0100\r\n" *
        "From: Ignasi <fignasi@chalmers.se>\r\n" *
        "To: fignasi@chalmers.se\r\n" *
        "Subject: PRC Test\r\n" *
        "\r\n" * content *
        "\r\n")

    from = "<natxofp@gmail.com>"

    send(host, rcpt, from, body, opt)

end