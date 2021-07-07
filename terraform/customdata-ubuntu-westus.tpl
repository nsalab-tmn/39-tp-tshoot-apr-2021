#!/bin/bash
while ! ping -c 1 -W 1 1.1.1.1; do
    echo "Waiting for 1.1.1.1 - network interface might be down..."
    sleep 5
done
useradd -m -p \$6\$72GB/f/OszFnou9D\$AWGi/S0F9bYU22nbMk01rkR.wU7OM2zERLgysvRNHEidKpEdc4x7w25jYuazGcFFk7Lobp8VkFyAcPAyQnIw8/ -s /bin/bash superadmin
echo "superadmin   ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/39-superadmin
echo "install docker from snap"
snap install docker || { echo "Failure snap install docker"; exit 1; } 
echo "finished docker from snap"
apt-get update -y 
apt-get install nginx unzip -y || { echo "Failure apt-get install nginx unzip -y"; exit 1; } 


# get api and run container
mkdir -p /root/src
curl ${ts39-api-url}  > /root/src/ts39-api.zip
unzip /root/src/ts39-api.zip -d /root/src/ts39-api || { echo "Failure unzip /root/src/ts39-api.zip -d /root/src/ts39-api"; exit 1; } 
cd /root/src/ts39-api || { echo "Failure cd /root/src/ts39-api"; exit 1; } 
docker build . -t ts39-api
docker run -d -p 8080:8080 --restart=always ts39-api
# run influxh container
docker run -d -p 8086:8086 --restart=always influxdb || { echo "Failure docker run influxdb"; exit 1; } 

# configure and reload nginx
cat <<EOF >/etc/nginx/sites-enabled/default
server {
    listen 443 default_server ssl;
    listen [::]:443 default_server ssl;
    ssl_certificate /etc/nginx/fullchain.pem;
    ssl_certificate_key /etc/nginx/privkey.pem;
    index index.html index.htm index.nginx-debian.html;
    server_name api.${prefix}.az.skillscloud.company;
    location / {
        proxy_pass         http://127.0.0.1:8080/;
        proxy_redirect     off;

        proxy_set_header   Host             \$host;
        proxy_set_header   X-Real-IP        \$remote_addr;
    }
}
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    ssl_certificate /etc/nginx/fullchain.pem;
    ssl_certificate_key /etc/nginx/privkey.pem;
    index index.html index.htm index.nginx-debian.html;
    server_name tm.${prefix}.az.skillscloud.company;
    location / {
        proxy_pass         http://127.0.0.1:8086/;
        proxy_redirect     off;

        proxy_set_header   Host             \$host;
        proxy_set_header   X-Real-IP        \$remote_addr;
    }
}
EOF
cat <<EOF > /etc/nginx/fullchain.pem
-----BEGIN CERTIFICATE-----
MIIKaTCCCVGgAwIBAgISA0lr8RId0Xw1/zae2+KEIfK9MA0GCSqGSIb3DQEBCwUA
MDIxCzAJBgNVBAYTAlVTMRYwFAYDVQQKEw1MZXQncyBFbmNyeXB0MQswCQYDVQQD
EwJSMzAeFw0yMTA0MDcxMDMxNDBaFw0yMTA3MDYxMDMxNDBaMCMxITAfBgNVBAMM
GCouYXouc2tpbGxzY2xvdWQuY29tcGFueTCCASIwDQYJKoZIhvcNAQEBBQADggEP
ADCCAQoCggEBAKL0C6jn7gbghe+E+gC25aELZoLRknQcHZ8lT1n897NlXy44SmE3
H7DTvPEPzz/QuqjrmWjdRM8TNqM5ux8dfzKg7vBgfByX3zUhmJYnB6ZDrIkxQKYJ
z0Ct98KQPBLkvTEnyWj+VFQ2wXSXa8uyNCRTvVu1FJng8n1aflm+6mnVBybxXkNL
mUtHBHSA5mjnbUqFHIrjB7kT01OkHsunfDMIOMcXo0rEww9UVx/bndNoU4D+eHBf
c8fn5hUBjzWgG2Ap4zx7GxCFSxMbH4SbLnu8Gj29gCds4PiydVHM5hmb1dORZGgw
jwYTsu0a6xwcaYpz7L/DRxfrh3kluquDw40CAwEAAaOCB4YwggeCMA4GA1UdDwEB
/wQEAwIFoDAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwDAYDVR0TAQH/
BAIwADAdBgNVHQ4EFgQUjRz0Td6mU7zVztwKx+RQA1ai4pQwHwYDVR0jBBgwFoAU
FC6zF7dYVsuuUAlA5h+vnYsUwsYwVQYIKwYBBQUHAQEESTBHMCEGCCsGAQUFBzAB
hhVodHRwOi8vcjMuby5sZW5jci5vcmcwIgYIKwYBBQUHMAKGFmh0dHA6Ly9yMy5p
LmxlbmNyLm9yZy8wggVVBgNVHREEggVMMIIFSIIYKi5hei5za2lsbHNjbG91ZC5j
b21wYW55giAqLmNvbXAtMDEuYXouc2tpbGxzY2xvdWQuY29tcGFueYIgKi5jb21w
LTAyLmF6LnNraWxsc2Nsb3VkLmNvbXBhbnmCICouY29tcC0wMy5hei5za2lsbHNj
bG91ZC5jb21wYW55giAqLmNvbXAtMDQuYXouc2tpbGxzY2xvdWQuY29tcGFueYIg
Ki5jb21wLTA1LmF6LnNraWxsc2Nsb3VkLmNvbXBhbnmCICouY29tcC0wNi5hei5z
a2lsbHNjbG91ZC5jb21wYW55giAqLmNvbXAtMDcuYXouc2tpbGxzY2xvdWQuY29t
cGFueYIgKi5jb21wLTA4LmF6LnNraWxsc2Nsb3VkLmNvbXBhbnmCICouY29tcC0w
OS5hei5za2lsbHNjbG91ZC5jb21wYW55giAqLmNvbXAtMTAuYXouc2tpbGxzY2xv
dWQuY29tcGFueYIgKi5jb21wLTExLmF6LnNraWxsc2Nsb3VkLmNvbXBhbnmCICou
Y29tcC0xMi5hei5za2lsbHNjbG91ZC5jb21wYW55giAqLmNvbXAtMTMuYXouc2tp
bGxzY2xvdWQuY29tcGFueYIgKi5jb21wLTE0LmF6LnNraWxsc2Nsb3VkLmNvbXBh
bnmCICouY29tcC0xNS5hei5za2lsbHNjbG91ZC5jb21wYW55giAqLmNvbXAtMTYu
YXouc2tpbGxzY2xvdWQuY29tcGFueYIgKi5jb21wLTE3LmF6LnNraWxsc2Nsb3Vk
LmNvbXBhbnmCICouY29tcC0xOC5hei5za2lsbHNjbG91ZC5jb21wYW55giAqLmNv
bXAtMTkuYXouc2tpbGxzY2xvdWQuY29tcGFueYIgKi5jb21wLTIwLmF6LnNraWxs
c2Nsb3VkLmNvbXBhbnmCICouY29tcC0yMS5hei5za2lsbHNjbG91ZC5jb21wYW55
giAqLmNvbXAtMjIuYXouc2tpbGxzY2xvdWQuY29tcGFueYIgKi5jb21wLTIzLmF6
LnNraWxsc2Nsb3VkLmNvbXBhbnmCICouY29tcC0yNC5hei5za2lsbHNjbG91ZC5j
b21wYW55giAqLmNvbXAtMjUuYXouc2tpbGxzY2xvdWQuY29tcGFueYIgKi5jb21w
LTI2LmF6LnNraWxsc2Nsb3VkLmNvbXBhbnmCICouY29tcC0yNy5hei5za2lsbHNj
bG91ZC5jb21wYW55giAqLmNvbXAtMjguYXouc2tpbGxzY2xvdWQuY29tcGFueYIg
Ki5jb21wLTI5LmF6LnNraWxsc2Nsb3VkLmNvbXBhbnmCICouY29tcC0zMC5hei5z
a2lsbHNjbG91ZC5jb21wYW55giAqLmNvbXAtMzEuYXouc2tpbGxzY2xvdWQuY29t
cGFueYIgKi5jb21wLTMyLmF6LnNraWxsc2Nsb3VkLmNvbXBhbnmCICouY29tcC0z
My5hei5za2lsbHNjbG91ZC5jb21wYW55giAqLmNvbXAtMzQuYXouc2tpbGxzY2xv
dWQuY29tcGFueYIgKi5jb21wLTM1LmF6LnNraWxsc2Nsb3VkLmNvbXBhbnmCICou
Y29tcC0zNi5hei5za2lsbHNjbG91ZC5jb21wYW55giAqLmNvbXAtMzcuYXouc2tp
bGxzY2xvdWQuY29tcGFueYIgKi5jb21wLTM4LmF6LnNraWxsc2Nsb3VkLmNvbXBh
bnmCICouY29tcC0zOS5hei5za2lsbHNjbG91ZC5jb21wYW55MEwGA1UdIARFMEMw
CAYGZ4EMAQIBMDcGCysGAQQBgt8TAQEBMCgwJgYIKwYBBQUHAgEWGmh0dHA6Ly9j
cHMubGV0c2VuY3J5cHQub3JnMIIBAwYKKwYBBAHWeQIEAgSB9ASB8QDvAHUAlCC8
Ho7VjWyIcx+CiyIsDdHaTV5sT5Q9YdtOL1hNosIAAAF4rBowLQAABAMARjBEAiBs
CzDfvF4sU4Bd5nFOnKfGO6iBIbWuNQ+1I3rXyzrZqAIgCoRkW5iGhf71qS72BMUh
3Si+UFSZ2ymhnjxdbBR1vPMAdgB9PvL4j/+IVWgkwsDKnlKJeSvFDngJfy5ql2iZ
fiLw1wAAAXisGjCTAAAEAwBHMEUCIQDjkC7wF1716afiR7z5yzIsp6eJStLNDTdX
OSxLQ4UjCgIgSYQk+UsEI62wD4aobKxOGz2cUi6tDfHQtqT8ulnoD0UwDQYJKoZI
hvcNAQELBQADggEBAHH+ZJ33WnmmbROAX6iYULf49eO0zsfNuRGrEF0ELCAMz+Pe
BHOTBdEQGyLktYHLnunw1o0bUEYPA+3KNAhFxJtjzZufOMIySTWRtN+s33BwvzcL
7E03wGnM17ZtdbjGEHRb4wJTw2peAEL5w5872UyTpAGe/28HRcmmSUcw3ExOXkHr
DUevf/hADahOpsWvv0bJkTIK825LLxTMeW0JLKSL3dXxSsTUVxvSEnDf3gDAtlT7
aJgwvEr+cIHqTLrn/pR0f6a24syb1I4yZWQmKnkPLzbYi4FpOB32cQ7+HZiFM0Bi
cEky45nVpHbeFxxPEeIVy9r1kHD71ojJYKAn0ig=
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIEZTCCA02gAwIBAgIQQAF1BIMUpMghjISpDBbN3zANBgkqhkiG9w0BAQsFADA/
MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT
DkRTVCBSb290IENBIFgzMB4XDTIwMTAwNzE5MjE0MFoXDTIxMDkyOTE5MjE0MFow
MjELMAkGA1UEBhMCVVMxFjAUBgNVBAoTDUxldCdzIEVuY3J5cHQxCzAJBgNVBAMT
AlIzMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuwIVKMz2oJTTDxLs
jVWSw/iC8ZmmekKIp10mqrUrucVMsa+Oa/l1yKPXD0eUFFU1V4yeqKI5GfWCPEKp
Tm71O8Mu243AsFzzWTjn7c9p8FoLG77AlCQlh/o3cbMT5xys4Zvv2+Q7RVJFlqnB
U840yFLuta7tj95gcOKlVKu2bQ6XpUA0ayvTvGbrZjR8+muLj1cpmfgwF126cm/7
gcWt0oZYPRfH5wm78Sv3htzB2nFd1EbjzK0lwYi8YGd1ZrPxGPeiXOZT/zqItkel
/xMY6pgJdz+dU/nPAeX1pnAXFK9jpP+Zs5Od3FOnBv5IhR2haa4ldbsTzFID9e1R
oYvbFQIDAQABo4IBaDCCAWQwEgYDVR0TAQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8E
BAMCAYYwSwYIKwYBBQUHAQEEPzA9MDsGCCsGAQUFBzAChi9odHRwOi8vYXBwcy5p
ZGVudHJ1c3QuY29tL3Jvb3RzL2RzdHJvb3RjYXgzLnA3YzAfBgNVHSMEGDAWgBTE
p7Gkeyxx+tvhS5B1/8QVYIWJEDBUBgNVHSAETTBLMAgGBmeBDAECATA/BgsrBgEE
AYLfEwEBATAwMC4GCCsGAQUFBwIBFiJodHRwOi8vY3BzLnJvb3QteDEubGV0c2Vu
Y3J5cHQub3JnMDwGA1UdHwQ1MDMwMaAvoC2GK2h0dHA6Ly9jcmwuaWRlbnRydXN0
LmNvbS9EU1RST09UQ0FYM0NSTC5jcmwwHQYDVR0OBBYEFBQusxe3WFbLrlAJQOYf
r52LFMLGMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjANBgkqhkiG9w0B
AQsFAAOCAQEA2UzgyfWEiDcx27sT4rP8i2tiEmxYt0l+PAK3qB8oYevO4C5z70kH
ejWEHx2taPDY/laBL21/WKZuNTYQHHPD5b1tXgHXbnL7KqC401dk5VvCadTQsvd8
S8MXjohyc9z9/G2948kLjmE6Flh9dDYrVYA9x2O+hEPGOaEOa1eePynBgPayvUfL
qjBstzLhWVQLGAkXXmNs+5ZnPBxzDJOLxhF2JIbeQAcH5H0tZrUlo5ZYyOqA7s9p
O5b85o3AM/OJ+CktFBQtfvBhcJVd9wvlwPsk+uyOy2HI7mNxKKgsBTt375teA2Tw
UdHkhVNcsAKX1H7GNNLOEADksd86wuoXvg==
-----END CERTIFICATE-----
EOF
    cat <<EOF > /etc/nginx/privkey.pem
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCi9Auo5+4G4IXv
hPoAtuWhC2aC0ZJ0HB2fJU9Z/PezZV8uOEphNx+w07zxD88/0Lqo65lo3UTPEzaj
ObsfHX8yoO7wYHwcl981IZiWJwemQ6yJMUCmCc9ArffCkDwS5L0xJ8lo/lRUNsF0
l2vLsjQkU71btRSZ4PJ9Wn5Zvupp1Qcm8V5DS5lLRwR0gOZo521KhRyK4we5E9NT
pB7Lp3wzCDjHF6NKxMMPVFcf253TaFOA/nhwX3PH5+YVAY81oBtgKeM8exsQhUsT
Gx+Emy57vBo9vYAnbOD4snVRzOYZm9XTkWRoMI8GE7LtGuscHGmKc+y/w0cX64d5
Jbqrg8ONAgMBAAECggEAWFfKgnXK27uZoTMMfpqpf1e46a9IoN4lSQRnMrgsafvJ
UDuAR5gk/C6uvln91/EHYVDpSKq9BS67bl58DfBl50LMh1EnuDC1+A4QtUbPpNoH
jhE/pUSoMb6fFcIwb2XHFAEn9l37xfQxiU4WSMaB8jfb7v4K/ymvDTqkSW9xkpHn
zozV2XjT39NmhJV/tiRB9jLHCtQTUxzOE5AUnw5X9oOABhY7jroqUGhCC+ny3GS1
BMJzpPBf3zAb3IgV2aaYX4z5YjDcDzMZKd9CVXg1o14IlMRmBFdJnfwfyk518pH7
6aC585d3WW0ROnP74hV3Cd1NBtc02tuf7aFfg2Nt2QKBgQDSyq5bMqKfeqCQKVLu
aZiIi2ljqiy72/yqPJkqzWC9G3/tAJPvYi1hL+6ZTwlxqHwMSabazaocuuU2tDCN
6y+MYyxTrmUGM3UPoOmSonthHfypZLLg9dACcCVwTIZhkk90E5IiP4h434DUiA8B
uEh94Ec6jO1u3RLm+FpK1u2buwKBgQDF5tdvjvZDZ25Wfj/vsxPeM3ASTADpfW7/
Wt8HbLXbfRJX5cTIUjTzuuuyZsZziioEMowje74cMArOEVCbIz2EUtLBWUyjJqYV
OQn+Dpc2fii5JzmbvpDDzrPMrEopY9XAllxo9q+Hp5Ytq2dQbGvMMoXgGDQMHwB+
qJYyXWCVVwKBgQCGTZThjlWG/v6mW233cVg6R3kSgy6VUwic/pcoakqksozDWIbp
EsiPD5caHv2JaSwAOD0TU857F6lLPWtiQOK+s8FeX9MGLGr9Viz7vIKX0h9VXk+K
fZPWudVgw6ErMall78JAB/LP8LeIsle9ZMjrSqaXa4ssA7czajE9Vct2WQKBgGCn
hcCuiggRlAoaTw+63pE/fhTxmeBvqq58q0DtD0TLqRHU3m8X91SyjjrrhzEW4b57
EYajAQ6zSBOs0Tlz1K+z48sa2hs03RiwavjyF1g99ZW4WqJ+SCXZ5maoHvBoGhWd
WjTJhqEycF6NwD+/NEbexhPUvlbNLWiu3exrPqixAoGBANDeiDFeUTEx+hfsxoZ8
C+tbLTdl+Bx2hTBCWA/7k6c3DXVCgsssWv7KG0UrbPwKo56WrzPa3JhADxnovVix
xWGEoN64H/O5KnzMm1PhsPPwjPPXmpBwMHEzfFIqvpyjXa84mMZ2XWW1BZqT5leB
gtlEr/FcpeaNzQ+0WughRHv+
-----END PRIVATE KEY-----
EOF
nginx -s reload || { echo "Failure nginx reload"; exit 1; }
echo "successfully initialized" > /tmp/init-result