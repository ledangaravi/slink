
import json
import boto3

def AWSlist_to_list(list_raw):
    # Function removes single dict entries containing data type and builds normal list
    # All data values in database are stored as strings "S"
    # example: [{"S":"hello"},{"S":"there"},{"S":"!"}] becomes ["hello", "there", "!"]
    list_out = list()
    for i in range(len(list_raw)):
        list_out.append(str(list_raw[i]["S"]))
    return list_out
    

def lambda_handler(event, context):
    # Main function triggered by AWS DynamoDB on change of the DEVICE table
    print('Database triggered')
    # Initialise the AWS IoT Core MQTT client
    client = boto3.client('iot-data', region_name='eu-west-2')

    # Loop process all modified records
    for record in event['Records']:
        
        # Only process if new data is available
        if (record['eventName'] == "INSERT" or record['eventName'] == "MODIFY"):
            print("New data")
            recordData = record['dynamodb']["NewImage"] # the added/modified data is stored in record/dynamodb/NewImage
            
            try: # Parse the required fields
                deviceID = str(recordData["device_ID"]["S"])
                u_name = str(recordData["u_name"]["S"])
                WOD_name = str(recordData["WOD_name"]["S"])
                
                exList_raw = list(recordData["exList"]["L"])
                exList = AWSlist_to_list(exList_raw)
                
                repList_raw = list(recordData["repList"]["L"])
                repList = AWSlist_to_list(repList_raw)
                wList_raw = list(recordData["wList"]["L"])
                wList = AWSlist_to_list(wList_raw)
                
                # Pack data
                payloaddata = {
                    "device_ID" : deviceID,
                    "u_name" : u_name,
                    "WOD_name" : WOD_name,
                    "exList" : exList,
                    "repList" : repList,
                    "wList" : wList
                }
                print(payloaddata)
                
                # Format into JSON and pack into bytes
                payload = bytes(json.dumps(payloaddata), 'utf-8')
                
                # Send data through MQTT
                print("Sending data to device " + deviceID)
                client.publish(topic='SLINK/devices/{0}'.format(deviceID), qos=1,payload=payload)
                
            except:
                print("Malformed exercise data DB entry or failed to send message")
                continue
                
 
    return 'Successfully processed {} records.'.format(len(event['Records']))
