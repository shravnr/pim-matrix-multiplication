# Set search paths
set search_path [list ../hdl ../hvl ../sim ./ ../pkg ]
set target_library [list /software/Synopsys-2024_x86_64/primelib/W-2024.09/ncx/demo/test2cell.lib]
set link_library "* /software/Synopsys-2024_x86_64/primelib/W-2024.09/ncx/demo/test2cell.lib"

set verilog_use_systemverilog true


# Read your design RTL files
read_verilog {../hdl/memory.sv ../pkg/types.sv}

# Set top-level module
set_top memory

# Set clock constraints (adjust period if needed)
create_clock -period 2.0 [get_ports clk]

# Elaborate and synthesize
elaborate
compile_ultra

# Write out the synthesized netlist and SDF
write -format verilog -hierarchy -output memory_netlist.v
write_sdf memory.sdf

