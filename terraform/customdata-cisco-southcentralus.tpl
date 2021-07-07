service timestamps debug datetime msec
service timestamps log datetime msec
service password-encryption
service call-home
platform qfp utilization monitor load 80
platform punt-keepalive disable-kernel-core
platform console serial
!
hostname tshoot-cisco-southcentralus
!
!
vrf definition GS
 rd 100:100
 !
 address-family ipv4
 exit-address-family
!
logging persistent size 1000000 filesize 8192 immediate
no logging console
enable secret 9 $9$a1A7.VPe7AwSdk$hwptuTi/FYmGJAqK6zYrpl.lzkx5XOvbs29gZGMwFQg
!
aaa new-model
!
!
aaa authentication login default local
aaa authorization exec default local none 
!
!
aaa session-id common
!
!
!
ip domain name skillscloud.company
!
crypto isakmp policy 100
 encryption aes
 hash md5
 authentication pre-share
 group 5
crypto isakmp key cisco123 address 0.0.0.0        
crypto ipsec transform-set TSET esp-aes 256 esp-md5-hmac 
 mode transport
crypto ipsec profile IPSEC
 set transform-set TSET
!
!
login on-success log
!
!
!
!
username azadmin privilege 15 view admin secret 9 $9$uU/G3vgUsHH4r.$TCtC6aT6JZ7esuttYXEZuw84rk2zsHjq2WDZ2SFM/1I
username superadmin privilege 15 secret 9 $9$HFtYcPcveT3.Ok$mMQPxAp1II/WbV.PJchCKloxcXImb2u6pfpdbQKXszY
!
banner motd c  ___ ___       __                               __                                                            
 |   Y   .-----|  .----.-----.--------.-----.   |  |_.-----.                                                   
 |.  |   |  -__|  |  __|  _  |        |  -__|   |   _|  _  |                                                   
 |. / \  |_____|__|____|_____|__|__|__|_____|   |____|_____|                                                   
 |:      |                                                                                                     
 |::.|:. |                                                                                                     
 `--- ---'                                                                                                     
  _______ __    __ __ __       _______ __                __     _______                                        
 |   _   |  |--|__|  |  .-----|   _   |  .-----.--.--.--|  |   |   _   .-----.--------.-----.---.-.-----.--.--.
 |   1___|    <|  |  |  |__ --|.  1___|  |  _  |  |  |  _  |   |.  1___|  _  |        |  _  |  _  |     |  |  |
 |____   |__|__|__|__|__|_____|.  |___|__|_____|_____|_____|   |.  |___|_____|__|__|__|   __|___._|__|__|___  |
 |:  1   |                    |:  1   |                        |:  1   |              |__|              |_____|
 |::.. . |                    |::.. . |                        |::.. . |                                       
 `-------'                    `-------'    __     __           `-------'                                       
 .-----.-----.--.--.--.-----.----.-----.--|  |   |  |--.--.--.                                                 
 |  _  |  _  |  |  |  |  -__|   _|  -__|  _  |   |  _  |  |  |                                                 
 |   __|_____|________|_____|__| |_____|_____|   |_____|___  |                                                 
 |__|                                                  |_____|                                                 
  ______  _______ _______ ___     _______ _______                                                              
 |   _  \|   _   |   _   |   |   |   _   |   _   \                                                             
 |.  |   |   1___|.  1   |.  |   |.  1   |.  1   /                                                             
 |.  |   |____   |.  _   |.  |___|.  _   |.  _   \                                                             
 |:  |   |:  1   |:  |   |:  1   |:  |   |:  1    \                                                            
 |::.|   |::.. . |::.|:. |::.. . |::.|:. |::.. .  /                                                            
 `--- ---`-------`--- ---`-------`--- ---`-------'                                                             c
!
track 100 ip sla 100 reachability
!
! 
!
!
!
interface Tunnel13
 ip address 10.1.3.3 255.255.255.0
 tunnel source GigabitEthernet1
 tunnel destination ${eastip}
 tunnel protection ipsec profile IPSEC
!
interface Tunnel23
 ip address 10.2.3.3 255.255.255.0
 tunnel source GigabitEthernet1
 tunnel destination ${westip}
 tunnel protection ipsec profile IPSEC
!
interface VirtualPortGroup0
 vrf forwarding GS
 ip address 192.168.35.101 255.255.255.0
 ip nat inside
 no mop enabled
 no mop sysid
!
interface GigabitEthernet1
 ip address dhcp
 ip nat outside
!
interface GigabitEthernet2
 ip address dhcp
 ip nat inside
!
!
!
router eigrp 100
 network 10.1.3.0 0.0.0.255
 network 10.2.3.0 0.0.0.255
 network 10.3.10.0 0.0.0.255
 distribute-list ACL_DL_TO_EAST out Tunnel13
 distribute-list ACL_DL_TO_WEST out Tunnel23
!
iox
ip forward-protocol nd
no ip http server
no ip http secure-server
!
ip nat inside source list ACL_FOR_NAT interface GigabitEthernet1 overload
ip nat inside source list GS_NAT_ACL interface GigabitEthernet1 vrf GS overload
ip route 0.0.0.0 0.0.0.0 10.3.1.1
ip route vrf GS 0.0.0.0 0.0.0.0 GigabitEthernet1 10.3.1.1 global
ip ssh version 2
ip ssh server algorithm publickey ecdsa-sha2-nistp256 ecdsa-sha2-nistp384 ecdsa-sha2-nistp521 ssh-rsa x509v3-ecdsa-sha2-nistp256 x509v3-ecdsa-sha2-nistp384 x509v3-ecdsa-sha2-nistp521
ip scp server enable
!
ip access-list standard ACL_DL_TO_EAST
 5 permit 10.1.3.0 0.0.0.255
 7 permit 10.2.10.0 0.0.0.255
 10 permit 10.3.10.0 0.0.0.255
 20 deny   any
ip access-list standard ACL_DL_TO_WEST
 5 permit 10.2.3.0 0.0.0.255
 7 permit 10.1.10.0 0.0.0.255
 10 permit 10.3.10.0 0.0.0.255
 20 deny   any
ip access-list standard ACL_FOR_NAT
 10 permit 10.3.10.0 0.0.0.255
ip access-list standard GS_NAT_ACL
 10 permit 192.168.35.0 0.0.0.255
!
!
ip sla 100
 icmp-echo 8.8.8.8 source-interface GigabitEthernet1
  threshold 1000
  timeout 2000
  frequency 5
ip sla schedule 100 life forever start-time now
!
!
!
!
!
!
!
control-plane
!
!
!
!
!
parser view admin inclusive
 secret 9 $9$bQL1/3ivTsbcuE$3ia.lc5FnKSnnnp6C.VrL6MjzMkGicRwyl2Dsybmb3g
 commands configure exclude all line
 commands configure exclude all parser
 commands configure exclude all username
 commands exec exclude copy
 commands exec exclude more
 commands exec exclude show startup-config
 commands exec exclude show running-config
 commands exec exclude show configuration
 commands exec include show
!
!
!
line con 0
 exec-timeout 0 0
 stopbits 1
line vty 0 4
 transport input ssh
line vty 5 20
 transport input ssh
!
call-home
 ! If contact email address in call-home is configured as sch-smart-licensing@cisco.com
 ! the email address configured in Cisco Smart License Portal will be used as contact email address to send SCH notifications.
 contact-email-addr sch-smart-licensing@cisco.com
 profile "CiscoTAC-1"
  active
  destination transport-method http
!
!
!
!
!
app-hosting appid guestshell
 app-vnic gateway1 virtualportgroup 0 guest-interface 0
  guest-ipaddress 192.168.35.102 netmask 255.255.255.0
 app-default-gateway 192.168.35.101 guest-interface 0
 name-server0 8.8.8.8
 
!!!!!!!!!!!!!!!!!!!!!!! 
!TICKET 2: SLA ISSUE
!
!Message: Hi there! We do monitor round-trip time to Google DNS from South US 
!border router, but recently our monitoring don't receive any measurment values
!but looks like there are no troubles with traffic flow. Could you please 
!investigate why we don't receive these metrics? Thanks!
!
!Malicious config:
no ip sla schedule 100 life forever start-time now


!!!!!!!!!!!!!!!!!!!!!!! 
!TICKET 3: ROUTING ISSUE
!
!Message: Hello! We have some issue with our routing redundancy of our internal 
!networks when any of the tunnels between any site goes down. 
!What the point of having full-mesh VPN than? Could you please fix this issue?
!
!Malicious config:
ip access-list standard ACL_DL_TO_WEST
 no 7
ip access-list standard ACL_DL_TO_EAST
 no 7
!!!!!!!!!!!!!!!!!!!!!!!
 
end
