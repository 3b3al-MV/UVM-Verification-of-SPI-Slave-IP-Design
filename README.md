# UVM Verification of SPI Slave IP Design

Welcome to the UVM Verification of SPI Slave IP Design repository. This project provides a comprehensive Universal Verification Methodology (UVM) environment for verifying the functionality of a Serial Peripheral Interface (SPI) Slave IP design.

## Table of Contents

- [Introduction](#introduction)
- [Repository Structure](#repository-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
- [Running the Simulation](#running-the-simulation)
- [Testbench Architecture](#testbench-architecture)
- [Contributing](#contributing)
- [License](#license)

## Introduction

This project aims to verify the functionality of an SPI Slave IP using UVM. The SPI (Serial Peripheral Interface) is a synchronous serial communication protocol used for short-distance communication, primarily in embedded systems.

## Repository Structure

- `docs/`: Documentation files
- `rtl/`: RTL design files
- `tb/`: Testbench files
  - `env/`: UVM environment components
  - `tests/`: Test cases
  - `sequences/`: UVM sequences
  - `tb_top.sv`: Top-level testbench
- `sim/`: Simulation scripts and files
- `Makefile`: Makefile for running simulations
- `README.md`: Project documentation

## Getting Started

### Prerequisites

To run this project, you need to have the following tools installed:

- **Simulator**: Any UVM-compatible simulator (e.g., Synopsys VCS, Cadence Xcelium, Mentor Graphics ModelSim/Questa)
- **Make**: To run the provided Makefile
- **Git**: To clone the repository

### Setup

Clone the repository to your local machine using the following command:

```bash
git clone https://github.com/3b3al-MV/UVM-Verification-of-SPI-Slave-IP-Design.git
cd UVM-Verification-of-SPI-Slave-IP-Design
```
## Testbench Architecture

The UVM testbench architecture for the SPI Slave IP verification includes the following components:

- **Driver**: Sends SPI transactions to the DUT.
- **Monitor**: Observes and captures SPI transactions from the DUT.
- **Sequencer**: Generates sequences of SPI transactions.
- **Agent**: Contains the driver, monitor, and sequencer.
- **Environment**: Contains one or more agents and scoreboard.
- **Scoreboard**: Compares expected results with the actual outputs from the DUT.
- **Tests**: Top-level test cases that configure the environment and initiate sequences.

## Contributing

We welcome contributions to improve this project. If you want to contribute, please follow these steps:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Commit your changes (`git commit -am 'Add new feature'`).
4. Push to the branch (`git push origin feature-branch`).
5. Create a new Pull Request.

Please ensure your code adheres to the existing coding standards and includes appropriate tests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
