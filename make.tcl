#*****************************************************************************************
# Vivado (TM) v2022.2 (64-bit)
# make.tcl: Tcl script for re-creating project 'tdc_gth_new'
#*****************************************************************************************

# Automatyczne wykrycie ścieżki (żeby działało niezależnie skąd odpalisz)
set origin_dir [file dirname [info script]]
set _xil_proj_name_ "tdc_gth_new"

# Tworzenie projektu w folderze /build
puts "Creating project in: $origin_dir/build"
create_project ${_xil_proj_name_} "$origin_dir/build" -part xcku040-ffva1156-1-c -force

set proj_dir [get_property directory [current_project]]
set obj [current_project]

# Ustawienia projektu (Kluczowe: Core Container z projektu ADC)
set_property -name "board_part" -value "" -objects $obj
set_property -name "corecontainer.enable" -value "1" -objects $obj
set_property -name "enable_core_container" -value "1" -objects $obj
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
set_property -name "enable_vhdl_2008" -value "1" -objects $obj
set_property -name "target_language" -value "VHDL" -objects $obj
set_property -name "simulator_language" -value "Mixed" -objects $obj

if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# 1. IMPORT plików (skopiowanie do folderu build)
puts "Importing source files..."
set files [list \
 [file normalize "${origin_dir}/hdl/spi_mux.vhd" ]\
 [file normalize "${origin_dir}/hdl/gth_wrapper.vhd" ]\
 [file normalize "${origin_dir}/hdl/gth_splitter_clk.vhd" ]\
 [file normalize "${origin_dir}/hdl/channel_diff_stat.vhd" ]\
 [file normalize "${origin_dir}/hdl/gth_rst_controller.vhd" ]\
 [file normalize "${origin_dir}/hdl/channel_hist.vhd" ]\
 [file normalize "${origin_dir}/bd/design_1.bd" ]\
 [file normalize "${origin_dir}/hdl/gth_splitter.vhd" ]\
 [file normalize "${origin_dir}/hdl/density_code.vhd" ]\
 [file normalize "${origin_dir}/hdl/cdc_fifo_min.vhd" ]\
 [file normalize "${origin_dir}/ip/gtwizard_ultrascale_0.xci" ]\
]
set imported_files [import_files -fileset sources_1 $files]

# 2. Generowanie wrappera (teraz zadziała, bo plik BD jest zaimortowany)
puts "Generating Block Design Wrapper..."
set wrapper_path [make_wrapper -fileset sources_1 -files [ get_files -norecurse design_1.bd] -top]
add_files -norecurse -fileset sources_1 $wrapper_path

# 3. Ustawienie typu plików VHDL
foreach file_path $files {
    if {[string match "*.vhd" $file_path]} {
        set file_obj [get_files -of_objects [get_filesets sources_1] [list "*[file tail $file_path]"]]
        set_property -name "file_type" -value "VHDL" -objects $file_obj
    }
}
set_property -name "top" -value "design_1_wrapper" -objects [get_filesets sources_1]


# 4. Import Constraints (XDC)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}
puts "Adding Constraints..."
set xdc_file "[file normalize "$origin_dir/xdc/kintex_main.xdc"]"
if {[file exists $xdc_file]} {
    import_files -fileset constrs_1 [list $xdc_file]
} else {
    puts "WARNING: Could not find XDC file: $xdc_file"
}


# 5. Import Simulation
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}
puts "Adding Simulation files..."
set sim_file "[file normalize "${origin_dir}/sim/tb_channel_diff_stat.vhd"]"
if {[file exists $sim_file]} {
    import_files -fileset sim_1 [list $sim_file]
    set file_obj [get_files -of_objects [get_filesets sim_1] [list "*[file tail $sim_file]"]]
    set_property -name "file_type" -value "VHDL" -objects $file_obj
    set_property -name "top" -value "tb_channel_diff_stat" -objects [get_filesets sim_1]
    set_property -name "top_lib" -value "xil_defaultlib" -objects [get_filesets sim_1]
} else {
    puts "WARNING: Could not find simulation file: $sim_file. Make sure it is in the /sim directory!"
}

update_compile_order -fileset sources_1

puts "--------------------------------------------------------"
puts " Project Created Successfully in /build directory!"
puts "--------------------------------------------------------"