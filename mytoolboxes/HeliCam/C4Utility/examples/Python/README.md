# Python Examples for gen4 Devices

Please carry out the following steps to be able to run the Python examples for Heliotis gen4 devices.

## Required Software

You need to install Heliotis driver software (and optionally our algorithm library) as well as a Python programming environment as described below. 

### Heliotis Software

Please download the latest Heliotis software suitable for your operating system directly from our [website](https://www.heliotis.com/en/support/login_en/) and install it. See the [heliotis programmer's guide](https://www.heliotis.com/download/heliinspect-h8-programmers-guide-draft-2021-08-05/) for more information.

#### C4Utility

The driver software in the C4 Utility package is strictly required.

#### AlgoLibrary (Optional) 

We recommend you install the *Heliotis Algorithm Library* with efficient implementations of basic processing algorithms as well. (The free version is sufficient.)


### Python

To run the example code, a suitable Python installation is needed. The code was tested using Python 3.11.5.
Please visit [the official website](https://www.python.org/downloads/) to download the current release or use a python version manager.

Each example comes with its own _requirements.txt_ and/or _Pipfile_ file where the required Python packages are listed. 
The Python package [harvesters](https://github.com/genicam/harvesters) is used to establish the camera connection using the GenICam interface.


#### Virtual Environment for Python Package Installation
It is strongly recommended you create a virtual environment for doing so. You may use one of the following options for managing virtual environments (from the command line):
- [`pipenv`](https://pypi.org/project/pipenv/)

    Navigate to the environment folder of the example (`./env`) and run the following command to install the packages as specified by the `Pipfile` located there.
    ``` bash
    pipenv install
    ```

    Then, launch the virtual environment.
    ``` bashpython -m venv .venv

    pipenv shell
    ```
    
- [`anaconda`](https://www.anaconda.com/)

    Create a virtual environment (in this example called ``myenv``) with the required packages available through ``conda``.
    ``` bash
    conda create -n myenv python=3.11.5 pip
    ```

    Activate the newly created virtual environment.
    ``` bash
    conda activate myenv
    ```

    Finally, install the required Python package using ``pip``. Navigate to the `./env` directory of the example and run the following command:
    ``` bash
    pip install -r requirements.txt
    ```


- [`venv`](https://docs.python.org/3/library/venv.html) and [`pip`](https://pypi.org/project/pip/)

    Create a virtual environment with `venv` in a custom directory.
    ``` bash
    python -m venv /<desired>/<path>/<to>/<the>/<environment>
    ```

    Then, use the following command to activate the virtual environment:

    **Linux:**
    ``` bash
    source /<path>/<to>/<env>/bin/activate
    ```

    **Windows:**
    ``` 
    .\<path>\<to>\<env>\Scripts\activate
    ```

    Finally, install the required Python package using ``pip``. Navigate to the `./env` directory of the example and run the following command:
    ``` bash
    pip install -r requirements.txt
    ```

## Running the Examples

The Python examples are either script-based `*.py` or jupyter notebook `*.ipynb` based. 

### Python Script
Run the script `*.py` in the python environment you installed.

### Jupyter Notebook
Navigate to the code directory of interest or one of its parents. Then start `jupyter-lab` in the python environment you installed by using the following command:

```
jupyter-lab
```

This will open a browser window with **Jupyter Lab** which allows you to find and open the `*.ipynb` file. You may find the documentation of Jupyter Lab [here](https://jupyterlab.readthedocs.io/en/stable/index.html).
