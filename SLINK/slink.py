#! /usr/bin/env python3

# Main software of the SLINK device
# Uses sensor.py library
# Uses paho-mqtt, modified SunFounder Emo 3rd party libraries
# 
# 2019 Tomasz Bialas
#


import sys
import sensor
import emo
import logging
import paho.mqtt.client as mqtt
import json
import time
import datetime


# Device configuration
device_id = 1 # unique device ID
rep_hysteresis = 15 # hysteresis to prevent false triggers
samplerate = 32
calibration_constant = 0.0625 # calibration constant to get weight in grams; load cell output is linear
mqtt_clientID = "SLINK{0}".format(device_id)
aws_iot_endpoint = "a225r00pw7qoxz-ats.iot.eu-west-2.amazonaws.com"
mqtt_port = 8883
mqtt_RX_topic = "SLINK/devices/SLINK{0}".format(device_id)
mqtt_TX_topic = "SLINK/ExerciseData"
log_format ='%(asctime)s [%(levelname)s] %(message)s'
loglevel = logging.INFO # set to logging.DEBUG for debug messages

# SSL certificates paths
ca_file = "/usr/share/ca-certificates/amazon/AmazonRootCA1.pem"
cert = "/home/pi/certificates/amazon_eu-west-2/4e9dca8ad1-certificate.pem.crt"
private = "/home/pi/certificates/amazon_eu-west-2/4e9dca8ad1-private.pem.key"

# Global varuables to be modified from callbacks
workout_received = False
RXmsg = ""
connected = False


def on_subscribe(client, userdata, mid, granted_qos):
    # callback on subscribe event
    logger.debug("Subscribed with status " + str(mid) + str(granted_qos))


def on_connect(client, userdata, flags, rc):
    # callback on connection
    global connected
    connected = True
    logger.info("Connected with result code "+str(rc))

def on_message(client, userdata, message):
    # when a message is received, store as global variable
    global workout_received
    global RXmsg

    RXmsg = message.payload.decode('utf-8')
    workout_received = True
    logger.debug("Received workout configuration")
    logger.debug(RXmsg)

def on_disconnect(client, userdata, rc):
    # if disconnected, reconnect to server
    logger.info("Lost connection. Reconnecting...")
    client.reconnect()
    logger.debug("Reconnected")

def main():
    global RXmsg
    global workout_received
    global logger
    global connected

    # setup the logging object
    logger = logging.getLogger()
    logger.setLevel(loglevel)
    loghandler = logging.StreamHandler(sys.stdout)
    logformat = logging.Formatter(log_format)
    loghandler.setFormatter(logformat)
    logger.addHandler(loghandler)
    logger.info("Slink starting")
    logger.info("Device ID is {0}".format(mqtt_clientID))

    # setup display
    display = emo.Emo()
    display.show_string("SLINK")

    # setup load cell
    loadcell = sensor.LoadSensor()
    loadcell.config_amp_gain(7) # set maximum gain
    loadcell.config_set_input_MUX(0) # set input pins
    loadcell.config_set_data_rate(samplerate) # set the ADC sampling rate
    loadcell.config_set_mode(0) # set continuous sampling mode

    # set load cell zero
    display.show_string("CALIB")
    logger.info("Calibrating load cell zero...")
    loadcell.calibrate()
    logger.info("Calibrated.")

    # display idle message
    display.show_string("SLINK")
    
    # setup the MQTT client
    mqttc = mqtt.Client(client_id=mqtt_clientID)
    logger.info("Connecting to {0} ...".format(aws_iot_endpoint))
    mqttc.tls_set(ca_certs = ca_file, certfile = cert, keyfile=private)
    mqttc.on_message = on_message
    mqttc.on_disconnect = on_disconnect
    mqttc.on_connect = on_connect
    mqttc.on_subscribe = on_subscribe

    mqttc.connect(aws_iot_endpoint, port = mqtt_port)
    mqttc.loop_start()

    while (connected == False):
        logger.debug("Waiting for connection")
        time.sleep(0.5)

    # main loop
    while (True):
        # display idle message
        display.show_string("SLINK")
        global workout_received
        workout_valid = False
        RXmsg = "" 
        # listen for new workout configuration
        mqttc.subscribe(mqtt_RX_topic)
        logger.debug("Subscribed to {0}".format(mqtt_RX_topic))

        logger.info("Waiting for configuration...")
        while (workout_received == False or workout_valid == False): # wait for MQTT message
            logger.debug("Waiting for configuration...")

            if (workout_received == True):
                # decode message. if parsing fails, message is invalid, wait for next message
                try:
                    payloadRX = json.loads(RXmsg)
                    logger.debug(payloadRX)
                    WOD_name = str(payloadRX["WOD_name"])
                    u_name = str(payloadRX["u_name"])
                    exList = list(payloadRX["exList"])
                    repList = list(payloadRX["repList"])
                    wList = list(payloadRX["wList"])
                    workout_valid = True
                    logger.debug("Received valid config")
                except:
                    logger.debug("Received invalid config")
                    workout_valid = False
                    workout_received = False
            time.sleep(1)
        
        mqttc.unsubscribe(mqtt_RX_topic)

        # Start of workout sequence
        # Workout structure: workout/exercises/repetitions
        logger.info("Start workout")
        workoutstart = time.time()
        logger.info("Selected workout: {0}".format(WOD_name))
        display.scroll_text("SELECTED WORKOUT: {0}".format(WOD_name))
        display.show_string("GO!")
        time.sleep(1)
        
        # loop executed for each exercise in workout sequence
        for exercise in range(len(exList)):
            exercisename = exList[exercise]
            exerciseweight = wList[exercise]
            exercise_start = time.time()
            exercise_power = []
            exercise_speed = []
            
            logger.debug("Exercise name: {0}".format(exercisename))
            display.scroll_text(exercisename)

            # loop for each repetition in exercise
            for rep in range(int(repList[exercise])):
                rep_maxval = 0 # peak value
                rep_duration = time.time() # start of workout
                rep_triggerHI = False # rising edge of repetition detected
                rep_triggerLO = False # falling edge of repetition detected
                rep_total = int(repList[exercise]) # total amount of repetitions
                rep_threshold = int(wList[exercise])*calibration_constant*1000/3 # threshold (in g) to trigger at; depends on selected weight (in kg) and the calibration value
                                                                            #/3 added to make pulling easier for demo purposes, and prevent breaking the prototype

                while (rep_triggerHI == False or rep_triggerLO == False):
                    sample = loadcell.get_sample()
                    if (sample <= 0):
                        sample = 0
                    logger.debug("sample {0}".format(sample))
                    logger.debug(sample/rep_threshold)

                    # display force graph, amount of reps done out of total
                    display.show_progressbar_with_text(abs(sample/rep_threshold), "{0}/{1}    ".format(str(rep), str(rep_total)))
                    
                    # detect successful rep
                    if (rep_triggerHI == True and rep_triggerLO == False):
                        if (sample >= rep_maxval):
                            rep_maxval = sample
                    
                    if (rep_triggerHI == False and sample >= (rep_threshold + rep_hysteresis)):
                        logger.debug("NEW REP: rising edge")
                        rep_triggerHI = True

                    if (rep_triggerHI == True and sample <= (rep_threshold - rep_hysteresis)):
                        logger.debug("NEW REP: falling edge")
                        rep_triggerLO = True

                    time.sleep(1/samplerate /2) # sampling at Nyquist rate
                                
                rep_duration = time.time() - rep_duration # length of repetition
                logger.debug("rep duration {0}".format(rep_duration))
                rep_speed = 60/rep_duration # reps per minute
                exercise_power.append(str(rep_maxval/calibration_constant))
                exercise_speed.append(str(rep_speed))
            
            exercise_end = time.time()
            display.show_progressbar_with_text(0, "{0}/{1}    ".format(str(rep+1), str(rep_total)))
            time.sleep(0.1)
            display.scroll_text("WELL DONE!")
            logger.debug(exercise_power)
            logger.debug(exercise_speed)

            # pack exercise data
            payloadTX = {
                    "u_name": u_name,
                    "WOD_name": WOD_name,
                    "time_plus_num": "{0};{1}".format(workoutstart, exercise),
                    "timestamp_first": str(exercise_start),
                    "timestamp_last": str(exercise_end),
                    "forceList": exercise_power,
                    "speedList": exercise_speed,
                    "weight": exerciseweight,
                    "reps": str(rep_total),
                    "ex_name": exercisename
                    }
            jsonpayloadTX = json.dumps(payloadTX)
            logger.info("Uploading workout data")
            logger.debug(jsonpayloadTX)

            # upload exercise data
            mqttc.publish(mqtt_TX_topic, payload=bytes(jsonpayloadTX, 'utf-8'), qos=1)
            time.sleep(1)
        display.scroll_text("WORKOUT COMPLETE!")
if __name__ == "__main__":
    main()
