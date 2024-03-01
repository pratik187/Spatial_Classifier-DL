#!/bin/bash

python3 src/python_scripts/preprocess_training_data.py
python3 src/python_scripts/model_building.py
python3 src/python_scripts/test_model.py
