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
import math
from matplotlib.animation import FuncAnimation

def tail(f, n):
    proc = subprocess.Popen(['tail', '-n', str(n), f], stdout=subprocess.PIPE)
    output, _ = proc.communicate()
    return output.decode('utf-8').splitlines()
#matplotlib.use('Qt5Agg')
##%matplotlib qt

clients = ["3", "7"]
local_files = ["out" + client for client in clients]
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
n = len(clients)
cols = math.ceil(math.sqrt(n))
rows = math.ceil(n / cols)

fig, axs = plt.subplots(rows, cols, figsize=(12, 6))

# Flatten the axs array if there are multiple rows/cols
axs = axs.flatten()

lines = [axs[i].plot(0,0, color='blue', linestyle='solid')[0] for i in range(n)]
#for ax in axs:
#    print("axset")
#    ax.set_xlim(-1,101)
#    ax.set_ylim(-5,121)
#plt.figure()
#for ax in axs:
#    ax.title.set_text('Amplitude vs. Time', fontsize=16)
#    #ax.xlabel('Time (s)', fontsize=12)
#    #ax.ylabel('Amplitude', fontsize=12)
def update(frame):
    # Open the local file in append mode
    for file_idx, local_file in enumerate(local_files):
      with open(local_file, "r") as f:
        # Read the remote file and write to the local file
        #stdin, stdout, stderr = client.exec_command(f"tail +{num_lines_read+1} {remote_file}")
        #lines = stdout.readlines()
        #f.write(''.join(lines))
        #f.flush()  # Ensure that the data is written to the file immediately

        
        #num_lines_read += len(lines)

        # Exit the loop if there are no more lines to read
        
        flines = tail(local_file,window)

        # Parse the CSI data from the current lines
        mag, phase, time_csi, bad_idxs = Parse_csi(flines)
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
        #plt.show(block=False)
        average_amps = df_amps.iloc[:, :30].mean(axis=1)
        #average_amps = df_amps.iloc[:,0]
        ax = axs[file_idx]
        ax.cla()
        ax.set_title("Client " + clients[file_idx])
        ax.set_ylabel("Mean amplitude")
        ax.plot(average_amps, color='blue', linestyle='solid') 
        ax.set_xlim(0,100)
        ax.set_ylim(-1,101)
        #lines[file_idx].set_xdata(range(len(average_amps)))
        #lines[file_idx].set_ydata(average_amps)#, color='blue', linestyle='solid')
        for bad_idx in bad_idxs:
            ax.axvline(bad_idx, color='red')

    return lines

ani = FuncAnimation(fig, update, interval=1000, blit=False)
#plt.tight_layout()
plt.show()
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


