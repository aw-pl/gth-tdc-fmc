# --- GET ABSOLUTE PATHS ---
set script_dir    [file dirname [info script]]
set workspace_dir [file normalize "$script_dir/workspace"]
set xsa_file      [file normalize "$script_dir/design_1_wrapper.xsa"]
set src_dir       [file normalize "$script_dir/src"]

# --- CONFIGURATION ---
set plat_name     "afcku"
set app_name      "tdc_app"
set processor_name "microblaze_0" 

# --- CLEANUP ---
if {[file exists $workspace_dir]} {
    puts "Deleting old workspace..."
    file delete -force $workspace_dir
}

# 1. Set Workspace
setws $workspace_dir

# 2. Create Platform
platform create -name $plat_name -hw $xsa_file -proc $processor_name -os standalone

# 3. Configure BSP
# Checking your tree, you have axi_uart16550_0 and axi_uart16550_1. 
# Set this to the one you actually use for logs:
set domain "standalone_domain"
bsp setlib -name xiltimer
bsp config stdin  axi_uart16550_1
bsp config stdout axi_uart16550_1
platform generate

# 4. Create App
app create -name $app_name -platform $plat_name -domain $domain -sysproj ${app_name}_system -template "Empty Application"

# 5. Import Sources
importsources -name $app_name -path $src_dir

# 6. Set Linker Script
app config -name $app_name linker-script $src_dir/lscript.ld

# 7. Add CPU flags (Important for TDC/GTH performance)
app config -name $app_name -add compiler-misc {-mno-xl-soft-mul -mxl-barrel-shift -mxl-pattern-compare}

# 8. Build
app build -name $app_name

puts "--------------------------------------------------------"
puts " Build Complete! STDOUT set to: axi_uart16550_1"
puts "--------------------------------------------------------"
exit