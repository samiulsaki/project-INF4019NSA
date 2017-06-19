#!/bin/bash
clear

VarCurrConn=$(echo "show info;show stat" | socat unix-connect:/var/run/haproxy/admin.sock stdio | grep 'CurrConns' | awk '{print $2}')
MaxCurrConn=$(echo "show info;show stat" | socat unix-connect:/var/run/haproxy/admin.sock stdio | grep 'Maxconn' | awk '{print $2}')
VarConnRate=$(echo "show info;show stat" | socat unix-connect:/var/run/haproxy/admin.sock stdio | grep '^ConnRate:' | awk '{print $2}')
MaxConnRate=$(echo "show info;show stat" | socat unix-connect:/var/run/haproxy/admin.sock stdio | grep '^ConnRateLimit:' | awk '{print $2}')
DockerPs=$(docker service ps my-web | grep "my-web.*" | grep "Running" | wc -l)

echo "Variable Current Connection :" $VarCurrConn
echo "Maximum Current Connection Limit :" $MaxCurrConn
echo "Variable Connetion Rate : "$VarConnRate
echo "Maximum Connection Rate Limit :" $MaxConnRate

printf "`date +'%s%N'`,$VarCurrConn,$MaxCurrConn,$VarConnRate,$MaxConnRate,$DockerPs\n" >> data.csv

MaxConnDefault=2000
MaxConnRateDefault=2000
ServScaleRatio=100
MinDockerServ=10
MinConnDiff=500
MaxConnDiff=1000
MinConnRateDiff=1000
MaxConnRateDiff=2000
Digit=1000

#while [  "$MaxCurrConn" -gt "$MaxConnDefault" ]; do
if [ "$((MaxCurrConn - VarCurrConn))" -le  "$MinConnDiff" ] ; then
	printf "MaxCurrConn is less than VarrCurrConn\n"
	ConnLimit="$((MaxCurrConn + Digit))"
	echo "Connection Limits are now :" $ConnLimit
	SetGlobal=$(socat /var/run/haproxy/admin.sock - <<< "set maxconn global $ConnLimit")
        SetFrontend=$(socat /var/run/haproxy/admin.sock - <<< "set maxconn frontend mysite $ConnLimit")
	printf "Session Limits are set for Global and Frontend to %d (increased)\n\n"  $ConnLimit
	ConnLimit=0
fi

if [ "$((MaxCurrConn - VarCurrConn))" -ge  "$MaxConnDiff" ] ; then
	printf "MaxCurrConn is greater than VarrCurrConn\n"
	ConnLimit="$((MaxCurrConn - Digit))"
	echo "Connection Limits are now :" $ConnLimit
	SetGlobal=$(socat /var/run/haproxy/admin.sock - <<< "set maxconn global $ConnLimit")
       	SetFrontend=$(socat /var/run/haproxy/admin.sock - <<< "set maxconn frontend mysite $ConnLimit")
	printf "Session Limits are set for Global and Frontend to %d (decreased)\n\n"  $ConnLimit
	ConnLimit=0
fi

if  [ "$MaxConnRate" -ge "$MaxConnRateDefault" ] && [ "$((MaxConnRate - VarConnRate))" -lt  "$MinConnRateDiff" ] ; then
	ConnRateLimit="$((MaxConnRate + Digit))"
	SetRateConn=$(socat /var/run/haproxy/admin.sock - <<< "set rate-limit connections global  $ConnRateLimit")
	SetRateSess=$(socat /var/run/haproxy/admin.sock - <<< "set rate-limit sessions global  $ConnRateLimit")
	printf "Connections and Sessions Rate Limits are set for Global to %d (increased)\n\n"  $ConnRateLimit
	Scale=$(expr $ConnRateLimit / $ServScaleRatio)
	echo "Scale :"$Scale
	docker service scale my-web=$Scale
	ConnRateLimit=0
fi

if  [ "$MaxConnRate" -ge "$MaxConnRateDefault" ] && [ "$((MaxConnRate - VarConnRate))" -gt  "$MaxConnRateDiff" ] ; then
	ConnRateLimit="$((MaxConnRate - Digit))"
	SetRateConn=$(socat /var/run/haproxy/admin.sock - <<< "set rate-limit connections global  $ConnRateLimit")
	SetRateSess=$(socat /var/run/haproxy/admin.sock - <<< "set rate-limit sessions global  $ConnRateLimit")
	printf "Connections and Sessions Rate Limits are set for Global to %d (decreased)\n\n"  $ConnRateLimit
	Scale=$(expr $ConnRateLimit / $ServScaleRatio)
	echo "Scale :" $Scale
	docker service scale my-web=$Scale
	ConnRateLimit=0
fi

#done

#while [  "$MaxCurrConn" -le "$MaxConnDefault" ]; do
if [ "$MaxCurrConn" -lt "$MaxConnDefault" ]; then
	printf "Maximum Current Connection is Lower\n"
	printf "Changing to default values........."
	SetGlobal=$(socat /var/run/haproxy/admin.sock - <<< "set maxconn global $MaxConnDefault")
	SetFrontend=$(socat /var/run/haproxy/admin.sock - <<< "set maxconn frontend mysite $MaxConnDefault")
	SetRateConn=$(socat /var/run/haproxy/admin.sock - <<< "set rate-limit connections global  $MaxConnRateDefault")
	SetRateSess=$(socat /var/run/haproxy/admin.sock - <<< "set rate-limit sessions global  $MaxConnRateDefault")
	SetDockerService=$(docker service scale my-web=$MinDockerServ)
	sleep 2s
fi
#	break
#done
