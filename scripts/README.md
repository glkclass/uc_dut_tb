# Scripts to create / update / run Vivado project

### Setup:

- Create `<repo>/scripts/user_env` file to contain customized env variables if needed. For details see `env` file containing default values of env variables. Something like this:
```
XILINX_TOOLS_PATH=path_2_xilinx_tools
PROGRAM_BIN_STREAM=path_2_program_bin_file
ART_BIN_FOLDER=path_2_artefact_folder
N_JOBS=8
FLASH_SPI_INTERFACE=SPIx1
...
```

### Usage:

- Task 1: Create Vivado project from scratch using tcl scripts generated before. The project will be created in `<repo>/syn` folder.
```
	cd <repo>/scripts
	make create_project
```

- Task 2: Save Vivado project changes to tcl scripts which can be used later to create project from scratch.
```
	cd <repo>/scripts
	make update_project
```

- Task 3: Program flash of N Processing boards via N jtag connections in parallel.

1. Setup environment in user_env
```
XILINX_TOOLS_PATH=path_2_xilinx_tools
PROGRAM_BIN_STREAM=path_2_program_bin_file
```

2. Program N targets.
```
	cd <repo>/scripts
	make program_n_flash
```
