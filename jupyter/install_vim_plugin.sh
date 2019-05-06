#!/usr/bin/env bash

pip install jupyter_contrib_nbextensions
jupyter contrib nbextension install --user
jupyter nbextension enable vim_binding/vim_binding
