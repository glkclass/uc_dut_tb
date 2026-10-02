# Scripts to create / update / run Vivado project

### Setup:

- Create `<repo>/scripts/user.env` file to customize variables located in `<repo>/scripts/config.env` file if needed. Something like this:
```
XILINX_TOOLS_PATH=path_2_xilinx_tools
ARTEFACT_FOLDER=path_2_artefact_folder
N_JOBS=8
...
```

### Usage:

- Task 1: Create Vivado project for flash type=x4 from scratch using tcl scripts generated before. The project will be created in `<repo>/syn` folder.
```
	cd <repo>/scripts
	export FLASH_SPI_INTERFACE=x4
	make create_project
```

- Task 1.1: Create Vivado project for flash type=x1 from scratch using tcl scripts generated before. The project will be created in `<repo>/syn` folder.
```
	cd <repo>/scripts
	export FLASH_SPI_INTERFACE=x1
	make create_project
```

- Task 2: Build existing Vivado project for any flash type.
```
	cd <repo>/scripts
	make build_release_soc
```

- Task 3: Save Vivado project changes to tcl scripts which can be used later to create project from scratch.
```
	cd <repo>/scripts
	make update_project
```

- Task 4: Program flash of N Processing boards via N jtag connections in parallel.

	- Setup config.environment in `<repo>/scripts/user.env`
```
XILINX_TOOLS_PATH=path_2_xilinx_tools
PROGRAM_BIN_STREAM=path_2_program_bin_file
```

	- Program N targets.
```
	cd <repo>/scripts
	make program_n_flash
```
