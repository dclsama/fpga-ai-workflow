# =============================================================================
# run_sim.tcl - Batch simulation script for Vivado XSim
# Run all simulation steps and quit when done.
# =============================================================================

# Log all signals for waveform dumping (WDB)
log_wave -recursive *

# Run simulation until $finish or $stop
run all

quit
