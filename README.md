# Spatial_Classifier-DL
Deep learning based spatial stationary and nonstationary classifier.

**Pre-requisites**

Please ensure that you have R installed on your system, along with the following libraries:
```
geoR
MASS
fields
```
Additionally, please verify if Python 3+ is installed. If not please download and install python from [here]([https://www.jstatsoft.org/article/view/v098i04](https://www.python.org/downloads/)) 

**Install python virtual env to run the code**

Check if `pip` is installed

`$ pip --version`

If `pip` is not installed, follow steps below:

```
$ cd ~
$ curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
$ python3 get-pip.py
```

Install virtual environment first & then activate:

```
$ git clone git@github.com:pratik187/Spatial_NormalizingFlows.git
$ cd Spatial_NormalizingFlows
$ python3 -m pip install --user virtualenv #Install virtualenv if not installed in your system
$ python3 -m virtualenv env #Create virtualenv for your project
$ source env/bin/activate #Activate virtualenv for linux/MacOS
```

Install all dependencies for your project from `requirements.txt` file:

```
$ pip install -r requirements.txt
```

**Reproducing results**


