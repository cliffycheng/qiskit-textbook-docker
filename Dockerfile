FROM python:3

# Run as user
RUN useradd -ms /bin/bash cliffycheng
USER cliffycheng
WORKDIR /home/cliffycheng

# Set local path
ENV PATH="/home/cliffycheng/.local/bin:${PATH}"

# Jupyter Notebook
RUN pip install notebook

# Qiskit textbook
RUN pip install git+https://github.com/qiskit-community/qiskit-textbook.git#subdirectory=qiskit-textbook-src

# Other dependencies for textbook
RUN pip install scipy numexpr
# This is something MatplotlibDrawer needs
RUN pip install pylatexenc

# Some setup so that container will actually exit when kill signal
# Taken from Jupyter base-notebook
#RUN pip install tini
#ENTRYPOINT ["tini", "-g", "--"]

# Some configs to make qiskit-textbook match what's on the site 
# per https://qiskit.org/textbook/ch-prerequisites/setting-the-environment.html

# Create .qiskit folder if it does not exist
RUN mkdir -p .qiskit
# Copy settings.conf
COPY configs/settings.conf .qiskit/

# Create .ipython/profile_default/ folder if it does not exist
RUN mkdir -p .ipython/profile_default/
# Copy ipython_kernel_config.python
COPY configs/ipython_kernel_config.py .ipython/profile_default/

# Make default folder for notebooks and copy over any local notebooks over
RUN mkdir -p notebooks
COPY notebooks/*.ipynb notebooks/

# Run Jupyter
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
EXPOSE 8888
CMD [ "jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0" ]
