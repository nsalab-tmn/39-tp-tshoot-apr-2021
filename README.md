![](tickets/topology.png)

## Ticket 1: Port forwarding issue
Customer message: Hi there! I have to test something on ubuntu machine in West US. One of our tech folks told me that I can SSH to it using non-standart port 4422, but either I do something wrong or maybe there are any additional security on it. Could you please confirm that it should work?

### Problem description:
Wrong NAT entry on *tshoot-cisco-westus* router. Port 4422 forwarded to 22 using udp protocol instead of tcp

### Audit commands:
```
show ip nat translations
```

### Correct solution:
Replace wrong NAT entry with a correct one
```
(config)# no ip nat inside source static udp 10.2.10.6 22 interface GigabitEthernet1 4422
(config)# ip nat inside source static tcp 10.2.10.6 22 interface GigabitEthernet1 4422
```

### Marking:
1. Check SSH port translation from localhost (+1 point. Don't continue, if this check is failed): 
```
$ sshpass -p $DEFAULT_PASSWORD ssh -p 4422 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $DEFAULT_USER@westus.comp-xx.az.skillscloud.company 'hostname'"
>>> ssh command should return hostname pattern comp-xx-ubuntu-westus
```

2. Check SSH port translation rule (+1 point):
```
# show ip nat translation src-port 22
>>> should return 'tcp  10.2.1.4:4422         10.2.10.6:22'
```
3. Check wrong NAT entry has been removed (+1 point):
```
# show ip nat translation src-port 22
>>> should not return 'udp  10.2.1.4:4422         10.2.10.6:22'
```

## Ticket 2: SLA issue
Customer message: Hi there! We do monitor round-trip time to Google DNS from South Central US border router, but recently our monitoring don't receive any measurment values but looks like there are no troubles with traffic flow. Could you please investigate why we don't receive these metrics? Thanks!

### Problem description:
Track is configured on *tshoot-cisco-southcentralus* router using *ip sla 100*, but ip sla 100 is not running.

### Audit commands:
```
show track
show ip sla summary
show ip sla statistics
```

### Correct solution:
Start IP SLA process
```
(config)# ip sla schedule 100 life forever start-time now
```

### Marking:
1. Check track return value (+1 point. Don't continue, if this check is failed): 
```
# show track 100
>>> assert ouput "Latest operation return code: OK"
```

2. Check SLA params have not been modified (+1 point):
```
# sh ip sla summary 
>>> assert ouput "icmp-echo   8.8.8.8"
```
3.  Check SLA time-to-live (+1 point):
```
# show ip sla statistics 100 
>>> assert ouput "Operation time to live: Forever"
```

## Ticket 3: Routing issue
Customer message: Hello! We have some issue with routing redundancy of our internal networks when any of the tunnels between any site goes down. What the point of having full-mesh VPN than? Could you please fix this issue?

### Problem description:
EIGRP routing is configured accross full-mesh IPSec VPNs between all routers. Each EIGRP instance has a router filter configured as a distribute list. ACLs which are configured for distribute lists have no network entry to redistribute routes between two other routers in case of failover. E.g. if VPN between East and West is down, South router has no ACE to permit East routes to West router and vice versa. The same problem is present on each router.

### Audit commands:
```
show ip protocols
show access-lists
```

### Correct solution:
Add one ACE per ACL on each router to permit routes distribution between each pair of routers in case of indirect VPN failure

1) On tshoot-cisco-eastus
```
(config)# ip access-list standard ACL_DL_TO_SOUTH
(config-acl)# 7 permit 10.2.10.0 0.0.0.255
(config)# ip access-list standard ACL_DL_TO_WEST
(config-acl)# 7 permit 10.3.10.0 0.0.0.255
```

2) On tshoot-cisco-westus
```
(config)# ip access-list standard ACL_DL_TO_EAST
(config-acl)# 7 permit 10.3.10.0 0.0.0.255
(config)# ip access-list standard ACL_DL_TO_SOUTH
(config-acl)# 7 permit 10.1.10.0 0.0.0.255
```

3) On tshoot-cisco-southcentralus
```
(config)# ip access-list standard ACL_DL_TO_EAST
(config-acl)#  7 permit 10.2.10.0 0.0.0.255
(config)# ip access-list standard ACL_DL_TO_WEST
(config-acl)#  7 permit 10.1.10.0 0.0.0.255
```

### Marking:
### Testcase 1: East to West Failover
0. Shutdown tunnel12 (East <-> West) on tshoot-cisco-eastus
```
(config)# interface tunnel 12
(config-if)# shutdown
```

1. Test connectivity East <-> West from tshoot-cisco-eastus (+1 point. Don't continue, if this check is failed): 
```
# ping 10.2.10.4 source Gi2 repeat 10
>>> assert at least 3 successful pings
```

2. Check routes filters on tshoot-cisco-southcentralus were not modified (+1 point):
```
# show ip protocols
>>> assert ouput "Tunnel13 filtered by ACL_DL_TO_EAST" and "Tunnel23 filtered by ACL_DL_TO_WEST"
```
3.  Check ACLs directed to East on tshoot-cisco-southcentralus have no "permit any any" statements  (+1 point):
```
# show access-lists ACL_DL_TO_EAST
>>> assert ouput "deny   any"
>>> assert "permit any" is not in the output
```

4.  Check ACLs directed to West on tshoot-cisco-southcentralus have no "permit any any" statements  (+1 point):
```
# show access-lists ACL_DL_TO_WEST
>>> assert ouput "deny   any"
>>> assert "permit any" is not in the output
```

5. Clean up: Bing back tunnel12 (East <-> West) on tshoot-cisco-eastus
```
(config)# interface tunnel 12
(config-if)# no shutdown
```

### Testcase 2: West to South Failover
0. Shutdown tunnel23 (West <-> South) on tshoot-cisco-westus
```
(config)# interface tunnel 23
(config-if)# shutdown
```

1. Test connectivity West <-> South from tshoot-cisco-westus (+1 point. Don't continue, if this check is failed): 
```
# ping 10.3.10.4 source Gi2 repeat 10
>>> assert at least 3 successful pings
```

2. Check routes filters on tshoot-cisco-eastus were not modified (+1 point):
```
# show ip protocols
>>> assert ouput "Tunnel12 filtered by ACL_DL_TO_WEST" and "Tunnel13 filtered by ACL_DL_TO_SOUTH"
```
3.  Check ACLs directed to West on tshoot-cisco-eastus have no "permit any any" statements  (+1 point):
```
# show access-lists ACL_DL_TO_WEST
>>> assert ouput "deny   any"
>>> assert "permit any" is not in the output
```

4.  Check ACLs directed to South on tshoot-cisco-eastus have no "permit any any" statements  (+1 point):
```
# show access-lists ACL_DL_TO_SOUTH
>>> assert ouput "deny   any"
>>> assert "permit any" is not in the output
```

5. Clean up: Bing back tunnel23 (West <-> South) on tshoot-cisco-westus
```
(config)# interface tunnel 23
(config-if)# no shutdown
```

### Testcase 3: South to East Failover
0. Shutdown tunnel13 (South <-> East) on tshoot-cisco-southcentralus
```
(config)# interface tunnel 13
(config-if)# shutdown
```

1. Test connectivity South <-> East from tshoot-cisco-southcentralus (+1 point. Don't continue, if this check is failed): 
```
# ping 10.1.10.4 source Gi2 repeat 10
>>> assert at least 3 successful pings
```

2. Check routes filters on tshoot-cisco-westus were not modified (+1 point):
```
# show ip protocols
>>> assert ouput "Tunnel12 filtered by ACL_DL_TO_EAST" and "Tunnel23 filtered by ACL_DL_TO_SOUTH"
```
3.  Check ACLs directed to East on tshoot-cisco-westus have no "permit any any" statements  (+1 point):
```
# show access-lists ACL_DL_TO_EAST
>>> assert ouput "deny   any"
>>> assert "permit any" is not in the output
```

4.  Check ACLs directed to South on tshoot-cisco-westus have no "permit any any" statements  (+1 point):
```
# show access-lists ACL_DL_TO_SOUTH
>>> assert ouput "deny   any"
>>> assert "permit any" is not in the output
```

5. Clean up: Bing back tunnel13 (South <-> East) on tshoot-cisco-southcentralus
```
(config)# interface tunnel 13
(config-if)# no shutdown
```

## Ticket 4: Filesystem security
Customer message: User azadmin can execute `cat /etc/shadow` on ubuntu-eastus machine. I believe this is not normal. I'm affraid that user can access some other secret files. Could you please check?

### Problem description:
Someone added suid bit to the `cat` utility and immutable attribute. So every user can execute `cat` with owner rights. You should remove the immutable flag first and then remove the suid bit.

### Audit commands:
```
cat /etc/shadow
sudo cat /etc/shadow
ls -la /usr/bin/cat
lsattr /usr/bin/cat
```

### Correct solution:
Remove immutable and setgid flags from /usr/bin/cat
```
sudo chattr -i /usr/bin/cat
sudo chmod -s /usr/bin/cat
```

### Marking:
1. File shadow must be unreadable (+1 point. Don't continue, if this check is failed): 
```
$ cat /etc/shadow
>>> assert output "Permission denied" 
```

2. File shadow must be readable by su (+1 point):
```
$ sudo cat /etc/shadow
>>> assert that <FILE CONTENT> is shown
```
3. cat executable must have right mod, owner and attr (+1 point):
```
$ ls -la /usr/bin/cat
>>> assert that *s* flag is not present
$ lsattr /usr/bin/cat
>>> assert that *i* flag (immutable) is not present
```

## Ticket 5: Web service failure
Customer message: Web page http://comp-XX.az.skillscloud.company doesn't work from my browser. It must redirect to https as I remember.

### Problem description:
Nginx web-server's config was corrupted. HTTP server returns the wrong HTTP code (304 instead of 301). HTTPS server has no `ssl` option for the listener. Moreover, ssl certificate is outdated, so you should copy the wildcard certificate from the `ubuntu-westus` web-server.

### Audit commands:
```
curl  http://comp-xx.az.skillscloud.company
curl  https://comp-xx.az.skillscloud.company
nginx -T
echo | openssl s_client -showcerts -connect comp-xx.az.skillscloud.company:443 2>/dev/null | openssl x509 -inform pem -noout -text
```

### Correct Solution
1. Change return code for HTTP server
```
$ sudo sed -i 's/304/301/' /etc/nginx/sites-enabled/default 
```
2. Add ssl option to the HTTPS server listener
```
$ sudo sed -i 's/443 default_server;/443 default_server ssl;/' /etc/nginx/sites-enabled/default 
```
3. Copy wildcard ssl certificate from the `ubuntu-westus` web-server and reload nginx config. 
```
$ scp azadmin@10.2.10.6:/etc/nginx/fullchain.pem /etc/nginx/fullchain.pem 
$ scp azadmin@10.2.10.6:/etc/nginx/privkey.pem /etc/nginx/privkey.pem 
$ sudo nginx -s reload
```

### Marking:
1. Check http redirect with correct code (+1 point):
```
$ curl  http://comp-xx.az.skillscloud.company -v 2> >(grep Location) | grep Location
< Location: https://comp-xx.az.skillscloud.company/
```
2. Web service check
  - Web page works fine without ssl (+1 point):
```
$ curl -k https://comp-xx.az.skillscloud.company 2> /dev/null | grep portfolioModal3
... portfolioModal3 ...
```
 - Check that ssl is turned on (+1 point):
```
$ curl  https://comp-xx.az.skillscloud.company 2> /dev/null | head -n1
>>> should not show any problems or errors
```

## Ticket 6: Docker application
Customer message: Web application https://westus.comp-XX.az.skillscloud.company is not working for some reason. Source code is located in /root/src/ts39-api. Could you please check `/root/src/ts39-api/Dockerfile` and make this application running?

### Problem description:
A developer hasn't done with dockerfile. So you need to add commands for exposing TCP port and installing the dependencies. Don't forget to build and run the application.

### Audit commands:
```
$ docker ps
$ docker logs <container-id>
$ nginx -T
$ ss -ltnp
$ docker run -it -p 8080:8080 ts39-api bash
```

### Correct solution:
You should fix the dockerfile, rebuild it and run. 
```
$ cd /root/src/ts39-api
add "RUN python -m pip install -r requirements.txt" above ENRTYPOINT in Dockerfile
add "RUN chmod +x /app/app.py" above ENRTYPOINT in Dockerfile
add "EXPOSE 8080" above ENRTYPOINT in Dockerfile
$ docker build -t ts39-api .
$ docker run -d -p 8080:8080 --restart=always ts39-api
```

### Marking:
1. Check if application is working (+1 point):
```
curl https://westus.comp-XX.az.skillscloud.company
```
2. Check that application port is exposed (+1 point):
```
sudo cat /root/src/ts39-api/Dockerfile | grep EXPOSE  
```

## Ticket 7: Azure hosted DNS zone issue
Customer message: Hello there! John Doe from our Ops team told me that InfluxDB is deployed on https://tm.comp-xx.az.skillscloud.company and ready for testing. However when I trying to access it from my browser there is an error. Could you please ensure that it's still running?

### Problem description:
`tm` A record is configured inside Azure DNS hosted zone `comp-xx.az.skillscloud.company` and has wrong entry — private IP address of *ubuntu-westus* VM instead of public routable IP address of *tshoot-cisco-westus* router.

### Audit commands:
```
nslookup tm.comp-xx.az.skillscloud.company
dig ns comp-xx.az.skillscloud.company
```

### Correct solution:
Fix A record inside `comp-xx.az.skillscloud.company` Azure hosted DNS zone
```
az network dns record-set a update \
  --name tm --resource-group rg-comp-xx \ 
  --zone-name comp-xx.az.skillscloud.company
```

### Marking:
1. Check that `tm.comp-xx.az.skillscloud.company` can be resolved to a puiblic IP address  (+1 point):
```
nslookup tm.$PREFIX.az.skillscloud.company $(dig ns $PREFIX.az.skillscloud.company +short | head -n1)
>>> assert output doesn't contain "server can't find" or "Address: 10.2.10.6"
```
2. Check that website is available (+1 point):
```
curl https://tm.$PREFIX.az.skillscloud.company 2> /dev/null | grep InfluxDB
>>> assert output "InfluxDB"
```

## Ticket 8: Azure route table issue
Customer message: Greetings! I'm trying to access my GitHub repository from Ubuntu machine in South Central US, but looks like there is no internet connction at all. Could you please check and fix internet connection?

### Problem description:
Routing table in South Central US has no default route configured. 

### Audit commands:
```
ubuntu-southcentralus$ ping <cisco router ip address in private subnet>
ubuntu-southcentralus$ ping 8.8.8.8 
tshoot-cisco-southcentralus# ping 8.8.8.8
tshoot-cisco-southcentralus# ping 8.8.8.8 source Gi2
```

### Correct solution:
Add default route to South Central US routing table to a virtual cisco router
```
az network route-table route create \
  -g rg-comp-xx --route-table-name comp-xx-rt-southcentralus \
  -n default --next-hop-type VirtualAppliance \
  --address-prefix 0.0.0.0/0 --next-hop-ip-address 10.3.10.4
```

### Marking:
1. Check that `rt-southcentralus` has default route configured (+1 point):
```
az network route-table route list -g rg-comp-xx --route-table-name comp-xx-rt-southcentralus
>>> assert output "addressPrefix": "0.0.0.0/0" 
>>> assert output "nextHopIpAddress": "10.3.10.4"
>>> assert output "nextHopType": "VirtualAppliance"
```
2. Make sure ubuntu-southcentralus has access to internet (+1 point):
```
ping -c2 google.com ; \
ping -c5 google.com 2>&1 | awk -F'/' 'END{ print (/^rtt/? "OK "$5" ms":"FAIL") }'
>>> assert output "OK"
```

## Ticket 9: Azure Bastion access issue
Customer message: Good afternoon! recently I requested acceess to Ubuntu machine in South Central US region to test a couple of things out. Somebody from Dev team has created a `devuser` (with default password) on this machine and told me that I can access it using Bastion connection on Azure portal. However I can't connect using Bastion for some reason. Could you please help me with this issue?

### Problem description:
Bastion connection is using SSH under the hood so it heavily depends on SSH configuration on the virtual machine itself. SSH on ubuntu-southcentralus is configured using user-whitelist and `devuser` is not allowed to connect over SSH to this machine.

### Audit commands:
```
sudo su devuser
ssh devuser@localhost
```

### Correct solution:
Add `devuser` to the whitelist in `/etc/ssh/sshd_config.d/10-allow.conf` and restart sshd daemon
```
sudo echo "$(cat /etc/ssh/sshd_config.d/10-allow.conf) devuser" > /etc/ssh/sshd_config.d/10-allow.conf
sudo systemctl restart sshd
```

### Marking:
1. Check Ubuntu South available over SSH from itself under superadmin (+1 point):
```
ssh devuser@localhost \
-o StrictHostKeyChecking=no -o PasswordAuthentication=no \
-o UserKnownHostsFile=/dev/null whoami
>>> assert that "Permission denied" is not in the output
```
2. Check SSH whitelist (+1 point):
```
cat /etc/ssh/sshd_config.d/10-allow.conf
>>> assert output "devuser"
```
