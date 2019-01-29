$ORIGIN example.com.
$TTL 86400
 
example.com.    3600    IN      SOA     ns.example.com. username.example.com. 1 86400 7200 2419200 300
example.com.            IN      NS      ns
ns                      IN      A       192.0.2.1
