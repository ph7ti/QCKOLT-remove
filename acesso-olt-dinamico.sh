#!/usr/bin/expect
set timeout 20
set hostName [lindex $argv 0]
set userName [lindex $argv 1]
set password [lindex $argv 2]
spawn telnet $hostName
expect "User name:"
send "$userName\r"
expect "password:"
send "$password\r";
expect "*>"
send "enable\r";
expect "*#"
send "config\r";
expect "*(config)#"
send "undo idle-timeout\r";
expect "*(config)#*"
send "quit\r"
expect "*#*"
send "quit\r"
sleep 1
sleep 1
expect "*n]:*"
sleep 1
send -- "y \r"
sleep 1
