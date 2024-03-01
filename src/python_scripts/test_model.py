#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Friday March  01 19:33:04 2024

@author: Pratik
"""

import numpy as np
import os
import sys
import matplotlib.pylab as plt
import math
from pathlib import Path # Python >= 3.5, for folder creation
import random # Random seed
from tqdm import tqdm # Progress bar in for loop
import subprocess
# Tensorflow
import tensorflow as tf

# from tensorflow.keras.layers import Dense, Flatten, Conv2D
# from tensorflow.keras import Model
from keras.layers import Dense, Flatten, Conv2D
# from tensorflow.keras import Model
from keras.models import Sequential,Model,load_model
from keras.utils import to_categorical
from keras.callbacks import EarlyStopping, ModelCheckpoint
from scipy.interpolate import NearestNDInterpolator

def main():
    # Folder places and filenames
    # Stationary
    
    print("##########################################################################################################")
    print("")
    print("Testing model accuracy on Stationary and non-Stationary datasets.")
    print("These datasets have been generated from spherical covariance functions.")
    print("")
    print("##########################################################################################################")
    directory_in_str_locs_stationary = "stationary_test/"
    directory_in_str_z_stationary = "stationary_test/"
    locs_string_stationary = "LOC_" # LOC_3600_sample_1.txt, LOC_3600_sample_2.txt, ...
    z_string_stationary = "Z_" # Z_3600_sample_1.txt, Z_3600_sample_2.txt, ...



    # Initialization 
    directory_in_str_locs = directory_in_str_locs_stationary
    directory_in_str_z = directory_in_str_z_stationary
    locs_string = locs_string_stationary
    z_string = z_string_stationary

    directory_locs = os.fsencode(directory_in_str_locs)
    data_folder1_locs = os.listdir(directory_locs)

    location_file_list = []
    Z_file_list = []
    for path, subdirs, files in os.walk(directory_locs):
        for name in files:
            name_string = name.decode("utf-8")
            if name_string.startswith(locs_string): 
                location_file_path = os.path.join(path, name)
                location_file_path = location_file_path.decode("utf-8")
                z_file_path = location_file_path.replace(locs_string, z_string, 1)
                location_file_list.append(location_file_path)
                Z_file_list.append(z_file_path)

    # loc_files is the file name for plotting. 
    loc_files = []
    for i in range(len(location_file_list)): 
        replace_res = location_file_list[i].replace(directory_in_str_locs, "")
        replace_res = replace_res.replace("\\", "_")
        loc_files.append(replace_res)

    # Grid row and column
    GRID_ROWS = 10
    GRID_COLS = 10
    manual_range_locs = False;
    manual_range_z = False;

    # Initialization continued
    ndata = len(location_file_list)
    #ndata = 100 # Test
    stationary_x_test = np.zeros((ndata,GRID_COLS,GRID_ROWS))

    stationary_y_test = np.zeros(ndata) # Zero = the model is stationary. One = nonstationary. 

    # Initialization continued
#     param_val_is_stat = 1;
#     npzfilename = npzfilename_stationary;

#     # Initialization continued
#     npzfilename = npzfilename_nonstationary;

    # Initialization continued
#     param_is_stat = np.ones(ndata)
    #param_samplenum.fill(param_val_samplenum)
#     param_is_stat.fill(param_val_is_stat)

    param_list = []
    print("[*][*][*] Preprocessing Stationary test data [*][*][*]")
    # Main program for data preprocessing
    for i_folder in tqdm(range(ndata)):
        # Append the parameter to samples. 
#         param_dict = {
#             "sample": i_folder,
#             "is_stat": param_val_is_stat
#         }
#         param_list.append(param_dict)
        #==========
        # Data extraction
        #===========
        # Get location and observation files for each subsample
        loc_text = location_file_list[i_folder]
        z_text = Z_file_list[i_folder]
        # Load the location and z files
        location_file = open(loc_text)
        Z_value_file = open(z_text)
    #     print(location_file)
        locations = np.loadtxt(location_file, delimiter=',')
        Z_values = np.loadtxt(Z_value_file, delimiter=',')

        ### random selection of subsample of locations
        idx = np.random.randint(len(locations), size=2500)
        locations = locations[idx,:]
        Z_values = Z_values[idx]


        #==========
        # End of data extraction
        #==========
        # Compute the output grid
        output_arr = np.zeros((GRID_ROWS,GRID_COLS))
        grid_sum_arr = np.zeros((GRID_ROWS,GRID_COLS))
        grid_div_arr = np.zeros((GRID_ROWS,GRID_COLS))
        if manual_range_locs == False:
            # Start and end locations (Auto)
    #         print(locations[:,0],locations[:,1])
            startx = min(locations[:, 0])
            starty = min(locations[:, 1])
            endx = max(locations[:, 0])
            endy = max(locations[:, 1])
    #     print(locations)
        locations[:,0] = (locations[:, 0] - startx)/(endx - startx)
        locations[:,1] = (locations[:, 1] - starty)/(endy - starty)
    #     print(locations)

        X = np.linspace(0, 1,GRID_COLS)
        Y = np.linspace(0, 1,GRID_ROWS)
        X, Y = np.meshgrid(X, Y)  # 2D grid for interpolation
        interp = NearestNDInterpolator(locations, Z_values)
        Z = interp(X, Y)

        if manual_range_z == False:
            # Normalize (Auto)
            m = np.min(Z)
            M = np.max(Z)
        if m == M:
            output_arr = np.ones((GRID_ROWS,GRID_COLS)) * 0.5 # All 0.5
        else: 
            # Range from 0 to 1. 
            Z = (Z - m) / (M - m)
        # Save results
        stationary_x_test[i_folder] = Z
        
    stationary_x_test = stationary_x_test.reshape(100,10,10,1)
    
    # Folder places and filenames
    # non-Stationary
    directory_in_str_locs_stationary = "nonstationary_test/"
    directory_in_str_z_stationary = "nonstationary_test/"
    locs_string_stationary = "LOC_" # LOC_3600_sample_1.txt, LOC_3600_sample_2.txt, ...
    z_string_stationary = "Z_" # Z_3600_sample_1.txt, Z_3600_sample_2.txt, ...



    # Initialization 
    directory_in_str_locs = directory_in_str_locs_stationary
    directory_in_str_z = directory_in_str_z_stationary
    locs_string = locs_string_stationary
    z_string = z_string_stationary

    directory_locs = os.fsencode(directory_in_str_locs)
    data_folder1_locs = os.listdir(directory_locs)

    location_file_list = []
    Z_file_list = []
    for path, subdirs, files in os.walk(directory_locs):
        for name in files:
            name_string = name.decode("utf-8")
            if name_string.startswith(locs_string): 
                location_file_path = os.path.join(path, name)
                location_file_path = location_file_path.decode("utf-8")
                z_file_path = location_file_path.replace(locs_string, z_string, 1)
                location_file_list.append(location_file_path)
                Z_file_list.append(z_file_path)

    # loc_files is the file name for plotting. 
    loc_files = []
    for i in range(len(location_file_list)): 
        replace_res = location_file_list[i].replace(directory_in_str_locs, "")
        replace_res = replace_res.replace("\\", "_")
        loc_files.append(replace_res)

    # Grid row and column
    GRID_ROWS = 10
    GRID_COLS = 10

    # Initialization continued
    ndata = len(location_file_list)
    #ndata = 100 # Test
    nonstationary_x_test = np.zeros((ndata,GRID_COLS,GRID_ROWS))

    nonstationary_y_test = np.ones(ndata) # Zero = the model is stationary. One = nonstationary. 

#     # Initialization continued
#     param_val_is_stat = 1;
#     npzfilename = npzfilename_stationary;

#     # Initialization continued
#     npzfilename = npzfilename_nonstationary;

#     # Initialization continued
#     param_is_stat = np.ones(ndata)
#     #param_samplenum.fill(param_val_samplenum)
#     param_is_stat.fill(param_val_is_stat)

#     param_list = []
    print("[*][*][*] Preprocessing non-Stationary test data [*][*][*]")
    # Main program for data preprocessing
    for i_folder in tqdm(range(ndata)):
        # Append the parameter to samples. 
#         param_dict = {
#             "sample": i_folder,
#             "is_stat": param_val_is_stat
#         }
#         param_list.append(param_dict)
        #==========
        # Data extraction
        #===========
        # Get location and observation files for each subsample
        loc_text = location_file_list[i_folder]
        z_text = Z_file_list[i_folder]
        # Load the location and z files
        location_file = open(loc_text)
        Z_value_file = open(z_text)
    #     print(location_file)
        locations = np.loadtxt(location_file, delimiter=',')
        Z_values = np.loadtxt(Z_value_file, delimiter=',')

        ### random selection of subsample of locations
        idx = np.random.randint(len(locations), size=2500)
        locations = locations[idx,:]
        Z_values = Z_values[idx]


        #==========
        # End of data extraction
        #==========
        # Compute the output grid
        output_arr = np.zeros((GRID_ROWS,GRID_COLS))
        grid_sum_arr = np.zeros((GRID_ROWS,GRID_COLS))
        grid_div_arr = np.zeros((GRID_ROWS,GRID_COLS))
        if manual_range_locs == False:
            # Start and end locations (Auto)
    #         print(locations[:,0],locations[:,1])
            startx = min(locations[:, 0])
            starty = min(locations[:, 1])
            endx = max(locations[:, 0])
            endy = max(locations[:, 1])
    #     print(locations)
        locations[:,0] = (locations[:, 0] - startx)/(endx - startx)
        locations[:,1] = (locations[:, 1] - starty)/(endy - starty)
    #     print(locations)

        X = np.linspace(0, 1,GRID_COLS)
        Y = np.linspace(0, 1,GRID_ROWS)
        X, Y = np.meshgrid(X, Y)  # 2D grid for interpolation
        interp = NearestNDInterpolator(locations, Z_values)
        Z = interp(X, Y)
    
        if manual_range_z == False:
            # Normalize (Auto)
            m = np.min(Z)
            M = np.max(Z)
        if m == M:
            output_arr = np.ones((GRID_ROWS,GRID_COLS)) * 0.5 # All 0.5
        else: 
            # Range from 0 to 1. 
            Z = (Z - m) / (M - m)
        # Save results
        nonstationary_x_test[i_folder] = Z
        
    nonstationary_x_test = nonstationary_x_test.reshape(100,10,10,1)
    
    # load model 
    
    model = load_model("Model_Example/classifier.h5")
    prediction = model.predict(stationary_x_test)
    count = 0

    for i in range(100):
        if prediction[i,0] >= 0.5:
            count += 1
    print("")
    print("##################################################################")
    print("")
    print("--------- Accuracy on Stationary data with spherical covariance ---------")
    print('{}%'.format(count))
    print("")
    print("##################################################################")
    
    prediction = model.predict(nonstationary_x_test)
    count = 0

    for i in range(100):
        if prediction[i,1] >= 0.5:
            count += 1
    print("")
    print("##################################################################")
    print("")
    print("--------- Accuracy on non-Stationary data with spherical covariance ---------")
    print('{}%'.format(count))
    print("")
    print("##################################################################")
    
    
    
    
if __name__ == '__main__':
    main()    
    