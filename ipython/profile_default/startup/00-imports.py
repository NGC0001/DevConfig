import os, sys
import time, datetime
import math
import argparse

import numpy as np
import pandas as pd

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '0'
os.environ['TF_CPP_MIN_VLOG_LEVEL'] = '3'
os.environ['TF_DUMP_GRAPH_PREFIX'] = '/tmp/tf_dump_graph'
import tensorflow as tf
tf.debugging.set_log_device_placement(True)
