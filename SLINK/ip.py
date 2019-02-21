#! /usr/bin/env python3

# Script to periodically update Amazon AWS Shadow for the device
# 2019 Tomasz Bialas



import sys
import paho.mqtt.client as mqtt
import json
import time
import socket

deviceID = 1
mqtt_clientID = "SLINK-{0:02d}".format(deviceID) 

aws_iot_endpoint = "a225r00pw7qoxz-ats.iot.eu-west-2.amazonaws.com"

ca = "/usr/share/ca-certificates/amazon/AmazonRootCA1.pem" 
cert = "/home/pi/certificates/amazon_eu-west-2/4e9dca8ad1-certificate.pem.crt"
private = "/home/pi/certificates/amazon_eu-west-2/4e9dca8ad1-private.pem.key"

def get_ip_address():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(("8.8.8.8", 80))
    return s.getsockname()[0]

client = mqtt.Client(client_id=mqtt_clientID)
client.tls_set(ca_certs=ca, certfile=cert, keyfile=private)
client.connect(aws_iot_endpoint, port=8883)

client.loop_start()

payload = {
    "state" : {
        "desired" : {
            "deviceID": deviceID,
            "ip": get_ip_address()
        }
    }
}



jsonpayload = json.dumps(payload)

while (True):

    client.publish("$aws/things/SLINK_01/shadow/update", payload=bytes(jsonpayload, 'utf-8'), qos=0)
    print("Shadow updated")
    #print("Sending failed. Retrying...")
    time.sleep(300)
