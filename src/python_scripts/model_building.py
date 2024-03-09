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
from keras.models import Sequential,Model
from keras.utils import to_categorical
from keras.callbacks import EarlyStopping, ModelCheckpoint
from scipy.interpolate import NearestNDInterpolator


def Classifier(x_train,x_test,y_train,y_test,model_saving_location):
    #create model

    model = Sequential()
    #add model layers
    # model.add(Conv2D(64, kernel_size=3, activation="relu", input_shape=(100, 100, 1)))
    model.add(Conv2D(32, kernel_size=3, activation="relu"))
    model.add(Conv2D(64, kernel_size=5, activation="relu"))
    model.add(Flatten())
    model.add(Dense(128, activation='relu'))
    model.add(Dense(2, activation='softmax'))
    
    #compile model using accuracy to measure model performance
    model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])
    #train the model
    callbacks = [EarlyStopping(monitor='accuracy', patience=20),
                 ModelCheckpoint(filepath= model_saving_location+'/classifier.h5', monitor='accuracy', save_best_only=True)]
    model.fit(x_train, y_train,callbacks=callbacks, 
              validation_data=(x_test, y_test), epochs=15, batch_size = 256, verbose = 2)
    
    return model


def main():
    # Filename for preprocessing data (.npz format)
    save_data_string = "Processed_Data/"
    # Saving names for the npz
    npzfilename_stationary = "Dat_stationary_0413Pratik.npz";
    npzfilename_nonstationary = "Dat_nonstationary_0413Pratik.npz";
    stationary_npz_filename = save_data_string + npzfilename_stationary
    nonstationary_npz_filename = save_data_string + npzfilename_nonstationary
    # Places for location saving
    model_saving_location = 'Model_Example'
    Path(model_saving_location).mkdir(parents=True, exist_ok=True)
    # Split rate for stationary data
    split_size_stationary = 0.9
    # Split rate for nonstationary data
    split_size_nonstationary = 0.9
    
    # Stationary data - load npz file
    npzfile = np.load(stationary_npz_filename, allow_pickle=True)
    stationary_x_all = npzfile['x'] # Preprocessed data
    stationary_y_all = npzfile['y'] # Stationary or nonstationary
    stationary_params = npzfile['params']
    
    # Nonstationary data - load npz file
    npzfile = np.load(nonstationary_npz_filename, allow_pickle=True)
    tx = npzfile['x']
    nonstationary_x_all = npzfile['x'] # Preprocessed data
    nonstationary_y_all = npzfile['y'] # Stationary or nonstationary
    nonstationary_params = npzfile['params']
    
    # Split for stationary data
    total_size_stationary = int(len(stationary_x_all))
    training_size_stationary = int(total_size_stationary * split_size_stationary)
    test_size_stationary = total_size_stationary - training_size_stationary

    # Split for nonstationary data
    total_size_nonstationary = int(len(nonstationary_x_all))
    training_size_nonstationary = int(total_size_nonstationary * split_size_nonstationary)
    test_size_nonstationary = total_size_nonstationary - training_size_nonstationary
    
    # Shuffler for stationary and nonstationary
    random.seed(220)
    shuffler_stationary = random.sample(range(total_size_stationary), total_size_stationary)
    shuffler_nonstationary = random.sample(range(total_size_nonstationary), total_size_nonstationary)
    
    # Grid row and column
    GRID_ROWS = 10
    GRID_COLS = 10
    # Shuffle data
    stationary_x_shuffled = stationary_x_all[shuffler_stationary, 0:GRID_ROWS, 0:GRID_COLS]
    stationary_y_shuffled = stationary_y_all[shuffler_stationary]
    stationary_params_shuffled = stationary_params[shuffler_stationary, ]
    nonstationary_x_shuffled = nonstationary_x_all[shuffler_nonstationary, 0:GRID_ROWS, 0:GRID_COLS]
    nonstationary_y_shuffled = nonstationary_y_all[shuffler_nonstationary]
    nonstationary_params_shuffled = nonstationary_params[shuffler_nonstationary, ]
    
    # Training data
    stationary_x_train = stationary_x_shuffled[0:training_size_stationary, 0:GRID_ROWS, 0:GRID_COLS]
    stationary_y_train = stationary_y_shuffled[0:training_size_stationary]
    stationary_params_train = stationary_params_shuffled[0:training_size_stationary, ]
    nonstationary_x_train = nonstationary_x_shuffled[0:training_size_nonstationary, 0:GRID_ROWS, 0:GRID_COLS]
    nonstationary_y_train = nonstationary_y_shuffled[0:training_size_nonstationary]
    nonstationary_params_train = nonstationary_params_shuffled[0:training_size_nonstationary, ]
    # Test data
    stationary_x_test = stationary_x_shuffled[training_size_stationary:, 0:GRID_ROWS, 0:GRID_COLS]
    stationary_y_test = stationary_y_shuffled[training_size_stationary:]
    stationary_params_test = stationary_params_shuffled[training_size_stationary:, ]
    nonstationary_x_test = nonstationary_x_shuffled[training_size_nonstationary:, 0:GRID_ROWS, 0:GRID_COLS]
    nonstationary_y_test = nonstationary_y_shuffled[training_size_nonstationary:]
    nonstationary_params_test = nonstationary_params_shuffled[training_size_nonstationary:, ]
    # Combine
    x_train = np.concatenate((stationary_x_train,nonstationary_x_train))
    y_train = np.concatenate((stationary_y_train,nonstationary_y_train))
    params_train = np.concatenate((stationary_params_train,nonstationary_params_train))
    x_test = np.concatenate((stationary_x_test,nonstationary_x_test))
    y_test = np.concatenate((stationary_y_test,nonstationary_y_test))
    params_test = np.concatenate((stationary_params_test,nonstationary_params_test))
    
    x_train = x_train.reshape(x_train.shape[0], GRID_ROWS, GRID_COLS, 1)
    x_test = x_test.reshape(x_test.shape[0], GRID_ROWS, GRID_COLS, 1)
    
    y_train = to_categorical(y_train)
    y_test = to_categorical(y_test)
    tf.random.set_seed(15) 
    print("[*][*][*] Training Started [*][*][*]")
    classifier = Classifier(x_train,x_test,y_train,y_test,model_saving_location)
    print("[*][*][*] Training Finished [*][*][*]")
    

    
if __name__ == '__main__':
    main()    
    
    
    
    
    
    
    
    
    
    
    
