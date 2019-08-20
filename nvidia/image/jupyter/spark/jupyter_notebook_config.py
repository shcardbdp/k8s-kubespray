# Copyright 2015 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
import os
from IPython.lib import passwd

c = c  # pylint:disable=undefined-variable
c.NotebookApp.ip = '*'
c.NotebookApp.port = int(os.getenv('PORT', 8888))
c.NotebookApp.open_browser = False
os.environ['LD_LIBRARY_PATH']='/usr/local/cuda/extras/CUPTI/lib64:/usr/local/cuda/lib64:/usr/lib/x86_64-linux-gnu:/usr/lib/oracle/12.2/client64/lib:/home/jovyan/notebooks/src/shcPython'
c.Spawner.env_keep.append('LD_LIBRARY_PATH')  # setting to connect oracle using up

# cull action 
c.MappingKernelManager.cull_busy = False
c.MappingKernelManager.cull_connected = False
c.MappingKernelManager.cull_idle_timeout = 300
#c.NotebookApp.shutdown_no_activity_timeout = 300
c.MappingKernelManager.cull_interval = 300

# jupyter setting [hide quit button]
c.NotebookApp.quit_button = False

# Test for downloading on jupyter by el
c.NotebookApp.allow_remote_access = True

# sets a password if PASSWORD is set in the environment
if 'PASSWORD' in os.environ:
  password = os.environ['PASSWORD']
  if password:
    c.NotebookApp.password = passwd(password)
  else:
    c.NotebookApp.password = ''
    c.NotebookApp.token = ''
  del os.environ['PASSWORD']
