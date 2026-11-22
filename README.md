# Individual Project

FPGA-based accelerator exploration for Gaussian Process (GP) computations.

## Current milestone: K-matrix calculation prototype

The first prototype calculates the RBF kernel matrix between input samples and inducing points.

- Input matrix: X, 16 x 4
- Inducing-point matrix: Z, 5 x 4
- Output kernel matrix: K_XZ, 16 x 5 (80 values)
- Initial arithmetic: IEEE-754 single-precision floating point
- Initial kernel parameters: lengthscales = [1, 1, 1, 1], signal variance = 1

For the initial prototype:

K(i,m) = exp(-0.5 * sum_j((X(i,j) - Z(m,j))^2))

## Repository structure

- K_Matrix_Accelerator/rtl: RTL modules
- K_Matrix_Accelerator/testbench: simulation testbenches
- K_Matrix_Accelerator/simulation: simulation support files
- K_Matrix_Accelerator/hls: HLS implementation and experiments
- K_Matrix_Accelerator/documentation: design notes and reports

The first hardware submodule is a parameterized register-based matrix buffer for storing X and Z. The register implementation is intended for transparent initial simulation and may later be replaced by inferred BRAM.

## Development workflow

Each module is developed and simulated independently before integration. HLS estimates and RTL simulation results will be recorded separately from physical FPGA measurements.
