FROM geoscienceaustralia/sandbox

ENV CUDA_REPO_PKG=cuda-repo-ubuntu1804_10.2.89-1_amd64.deb

USER root

# RUN apt search gnupg | grep gnupg

# RUN apt-get install gnupg2

RUN apt-get update && apt-get install -y gnupg2

RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
RUN wget -O /tmp/${CUDA_REPO_PKG} https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/${CUDA_REPO_PKG}
RUN dpkg -i /tmp/${CUDA_REPO_PKG}

# RUN rm -f /tmp/${CUDA_REPO_PKG}
RUN apt-get update
RUN apt-get install -y cuda-drivers-460

USER $nb_user

# # JupyterLab-lsp is a language server protocol provider (completition etc.)
# # RUN conda install -c conda-forge jupyterlab-lsp
# # RUN conda install -c conda-forge python-language-server

# # https://jupyterlab-lsp.readthedocs.io/en/latest/Installation.html
# RUN conda install --quiet --yes --freeze-installed -c conda-forge \
#     'python-language-server' \
#     'jupyterlab=3.0.0' \
#     'r-languageserver' \
#     'texlab' \
#     'chktex' \
#     'jupyter-lsp=1.1.4' \
#   && jupyter labextension install --no-build \
#     '@krassowski/jupyterlab-lsp@3.5.0' \
#   && jupyter lab build --dev-build=False --minimize=True \
#   && conda clean --all -f -y \
#   && rm -rf \
#     $CONDA_DIR/share/jupyter/lab/staging \
#     /home/$NB_USER/.cache/yarn \
#   && fix-permissions $CONDA_DIR \
#   && fix-permissions /home/$NB_USER

# # Use JupyterLab (instead of Notebook)
# ENV JUPYTER_ENABLE_LAB=yes
