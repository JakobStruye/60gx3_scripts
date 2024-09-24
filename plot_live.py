#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Feb 16 10:47:19 2024

@author: nabeel
"""

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jul  3 22:36:52 2023

@author: nabeel
"""

#import paramiko
import time
from csi_parser import Parse_csi
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import os
import matplotlib
import subprocess

def tail(f, n):
    proc = subprocess.Popen(['tail', '-n', str(n), f], stdout=subprocess.PIPE)
    output, _ = proc.communicate()
    return output.decode('utf-8').splitlines()
#matplotlib.use('Qt5Agg')
##%matplotlib qt

# Update the next three lines with your server's information
host = "192.168.7.1"
username = "root"
password = "admin"
remote_file = "out13"
local_file = "out13"
window = 100
#client = paramiko.client.SSHClient()
#client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
#client.connect(host, username=username, password=password)
start_time = time.time()

# Initialize variablesx`1x`
df_amps = pd.DataFrame()
df_phs = pd.DataFrame()
df_times = pd.DataFrame()
num_lines_read = 0
#open(local_file, 'w').close()
plt.figure()
plt.title('Amplitude vs. Time', fontsize=16)
plt.xlabel('Time (s)', fontsize=12)
plt.ylabel('Amplitude', fontsize=12)
while True:
    # Open the local file in append mode
    with open(local_file, "r") as f:
        # Read the remote file and write to the local file
        #stdin, stdout, stderr = client.exec_command(f"tail +{num_lines_read+1} {remote_file}")
        #lines = stdout.readlines()
        #f.write(''.join(lines))
        #f.flush()  # Ensure that the data is written to the file immediately

        
        #num_lines_read += len(lines)

        # Exit the loop if there are no more lines to read
        
        lines = tail(local_file,window)
        # Parse the CSI data from the current lines
        mag, phase, time_csi, bad_idxs = Parse_csi(lines)
        if bad_idxs:
            mag = mag[:window - len(bad_idxs)]
        # Create new dataframes to store the current iteration's data
        df_amps_iter = pd.DataFrame(mag)
        df_phs_iter = pd.DataFrame(phase)
        df_times_iter = pd.DataFrame(time_csi)
                        
                                     
                                           # Replace the old dataframes with the new ones
        df_amps = df_amps_iter
        df_phs = df_phs_iter
        df_times = df_times_iter
        # df_amps = pd.concat([df_amps, df_amps_iter], axis=0)
        # df_phs = pd.concat([df_phs, df_phs_iter], axis=0)
        # df_times = pd.concat([df_times, df_times_iter], axis=0)


        # Plot the data in real-time
        plt.show(block=False)
        plt.clf()
        average_amps = df_amps.iloc[:, :].mean(axis=1)
        plt.plot(average_amps, color='blue', linestyle='solid')  
        for bad_idx in bad_idxs:
            plt.axvline(bad_idx)
        plt.draw()
        plt.pause(0.01)
        #if not lines:
        #    break

    time.sleep(0.1)

#client.close()
exit()
# Concatenate the dataframes

# Initialize the counter to 1
counter = 1

# Define the base filename
base_filename = '/home/nabeel/Desktop/client7/first_'    
# Generate the filename
filename = f"{base_filename}{counter}.csv"

# Check if the file already exists
while os.path.isfile(filename):
    # If the file exists, increment the counter and generate a new filename
    counter += 1
    filename = f"{base_filename}{counter}.csv"

# Save the dataframe to the new filename
df_csi = pd.concat([df_amps, df_phs, df_times], axis=1)
df_csi.to_csv(filename, index=False)
df_csi = pd.concat([df_amps, df_phs, df_times], axis=1)

# Define the base filename

# Generate the filename
filename_plot = f"{base_filename}{counter}.png"

# Save the plot to the new filename
plt.savefig(filename_plot)

# Show the plot
plt.show()
plt.close()


