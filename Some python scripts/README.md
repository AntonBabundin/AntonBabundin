Here is my some python scripts:
1. pcap_read.py - read pcap file from wireshark and make raw ethernet packets in txt file
2. json_reader.py - read some parameters for json file
3. ver_clone_wd.py - Command for verification flow. Clone default stuff of a work directory. It lets other colleague investigate issues or whatever they want with prepared for simulation database or with already. This script is working with data in *.yaml 
4. ver_run_cgm.py - Command for verification flow. Command for clone and compile C-"golden" model. Command has 3 modes:
    1. shared: deploy precompiled C-model from the .zip archive
    2. original: compile model for target commit or branch name from the SYS team repo
5. gcc.yaml - Yaml file with compile flags for ver_run_cgm.py
