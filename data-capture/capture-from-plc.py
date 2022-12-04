import csv
import os
import sys
import time
from pymodbus.client.sync import ModbusTcpClient

def main(logfile):

    print("Writing to log: " + logfile)
    sys.stdout.flush()

    logfile = "/home/scadabr/data-capture/log/" + logfile

    plc = ModbusTcpClient("192.168.95.2")
    prevLine = []

    while True:
        with open(logfile, "a+", encoding="utf8") as fp:

            w = csv.writer(fp)

            try:
                input_resp = plc.read_input_registers(0, 13)
                holding_resp = plc.read_holding_registers(0, 4)

                if input_resp.isError() or holding_resp.isError(): continue

                input_plcData = input_resp.registers
                holding_plcData = holding_resp.registers
                data = []

                if len(prevLine) > 0:
                    # f1 readings
                    data.append(holding_plcData[0])                 # control given from plc    
                    data.append(input_plcData[0])
                    data.append(input_plcData[1])
                    data.append(input_plcData[1] - prevLine[2])     # change in f1 flow

                    #f2 readings
                    data.append(holding_plcData[1])                 # control given from plc    
                    data.append(input_plcData[2])
                    data.append(input_plcData[3])
                    data.append(input_plcData[3] - prevLine[6])     # change in f2 flow

                    # purge readings
                    data.append(holding_plcData[2])                 # control given from plc    
                    data.append(input_plcData[4])
                    data.append(input_plcData[5])
                    data.append(input_plcData[5] - prevLine[10])    # change in purge flow

                    # product readings
                    data.append(holding_plcData[3])                 # control given from plc    
                    data.append(input_plcData[6])
                    data.append(input_plcData[7])
                    data.append(input_plcData[7] - prevLine[14])    # change in product flow

                    # pressure
                    data.append(input_plcData[8])
                    data.append(input_plcData[8] - prevLine[16])    # change in pressure

                    # liquid level
                    data.append(input_plcData[9])
                    data.append(input_plcData[9] - prevLine[18])    # change in liquid level

                    # composition
                    data.append(input_plcData[10])
                    data.append(input_plcData[10] - prevLine[20])   # change in a in purge
                    data.append(input_plcData[11])
                    data.append(input_plcData[11] - prevLine[22])   # change in b in purge
                    data.append(input_plcData[12])
                    data.append(input_plcData[12] - prevLine[24])   # change in c in purge
                # first input
                else:
                    # f1 readings
                    data.append(holding_plcData[0])                 # control given from plc    
                    data.append(input_plcData[0])
                    data.append(input_plcData[1])
                    data.append(0)

                    #f2 readings
                    data.append(holding_plcData[1])                 # control given from plc    
                    data.append(input_plcData[2])
                    data.append(input_plcData[3])
                    data.append(0)

                    # purge readings
                    data.append(holding_plcData[2])                 # control given from plc    
                    data.append(input_plcData[4])
                    data.append(input_plcData[5])
                    data.append(0)

                    # product readings
                    data.append(holding_plcData[3])                 # control given from plc    
                    data.append(input_plcData[6])
                    data.append(input_plcData[7])
                    data.append(0)

                    # pressure
                    data.append(input_plcData[8])
                    data.append(0)

                    # liquid level
                    data.append(input_plcData[9])
                    data.append(0)

                    # composition
                    data.append(input_plcData[10])
                    data.append(0)
                    data.append(input_plcData[11])
                    data.append(0)
                    data.append(input_plcData[12])
                    data.append(0)

                prevLine = data
                w.writerow(data)
                time.sleep(0.1)

            except KeyboardInterrupt as k:
                plc.close()
                fp.close()
                break

            except Exception as e:
                continue

if __name__ == "__main__":
    if (len(sys.argv) != 2):
        print("Usage: python3 capture-from-plc.py <logfile>")
        sys.exit(1)
    main(sys.argv[1])
