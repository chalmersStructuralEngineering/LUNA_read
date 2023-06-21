include("sendEmail.jl")

sendEmail(ENV["SMTP_USERNAME_gm"], ENV["SMTP_PASSWORD_gm"], ENV["SMTP_HOSTNAME_gm"], ["<fignasi@chalmers.se>"], "PRC reding ok!")