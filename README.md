# GFSK Modulation and BER Simulation in MATLAB

## Overview
This MATLAB script simulates a **Gaussian Frequency Shift Keying (GFSK)** communication system, where random bits are modulated, transmitted through an **Additive White Gaussian Noise (AWGN)** channel, and demodulated. It evaluates the system's performance by calculating the **Bit Error Rate (BER)** across different **Signal-to-Noise Ratio (SNR)** levels.

## Features
- **GFSK Modulation**: Modulates data using Gaussian Frequency Shift Keying.
- **AWGN Channel**: Simulates transmission over a noisy channel using Additive White Gaussian Noise.
- **Forward Error Correction (FEC)**: Supports FEC encoding and decoding for enhanced reliability (Modes 2 and 8).
- **BER Calculation**: Computes the Bit Error Rate to measure system performance.
- **SNR Sweeps**: Simulates the effect of various SNR levels on BER.

## File Structure
```
├── main.m                # Main simulation script
├── gfsk_modulation.m     # Function for GFSK modulation
├── gfsk_demod.m          # Function for GFSK demodulation
├── fec_enc.m             # FEC encoding function
├── fec_decode.m          # FEC decoding function
├── detector_synch.m      # Function for signal synchronization
├── pattern_mapping.m     # Function for pattern mapping (Mode 8)
```

## Requirements
- **MATLAB R2020a or higher**
- **Signal Processing Toolbox** (optional, but recommended)

## Simulation Parameters
- **Number of Bits**: 400 random bits per transmission.
- **Modulation Index (h)**: 0.5
- **Bandwidth-Time Product (B)**: 0.5
- **Sampling Rate**: 2 (upsampling factor)
- **SNR Range**: -4 dB to 10 dB (step of 2 dB)
- **Modes**:
  - **Mode 1**: No FEC.
  - **Mode 2**: FEC applied to the payload.
  - **Mode 8**: FEC + Pattern Mapping.

## How It Works
1. **Payload Generation**: A random sequence of bits is generated.
2. **FEC Encoding (Optional)**: If Mode 2 or Mode 8, FEC is applied.
3. **Modulation**: The bits are modulated using GFSK.
4. **Transmission**: The modulated signal is sent through an AWGN channel.
5. **Noise Addition**: Noise is added based on SNR level.
6. **Receiver Synchronization**: The receiver synchronizes with the signal.
7. **Demodulation**: The received signal is demodulated to retrieve the bits.
8. **FEC Decoding (Optional)**: If FEC was applied, the bits are decoded.
9. **BER Calculation**: BER is computed by comparing transmitted and received bits.

## Usage
To run the simulation, execute the main script:
```matlab
clear; close all;
main
```
This will:
- Modulate, transmit, and demodulate data across multiple SNR values.
- Plot the **BER vs. SNR** curve on a semilogarithmic scale.

## Outputs
- **BER Plot**: Displays the Bit Error Rate against SNR values to visualize system performance under different noise conditions.

## Function Descriptions
| Function | Description |
|----------|-------------|
| `gfsk_modulation()` | Performs GFSK modulation on input bits. |
| `gfsk_demod()` | Recovers original bits from the modulated signal. |
| `fec_enc()` | Encodes bits using FEC for error correction. |
| `fec_decode()` | Decodes FEC-encoded bits. |
| `detector_synch()` | Synchronizes the receiver with the signal. |
| `pattern_mapping()` | Maps bits to a predefined pattern in Mode 8. |

## Example
The following SNR values are simulated: **-4 dB to 10 dB**. The output graph shows how **BER decreases as SNR increases**, indicating improved system performance at higher SNR levels.

```matlab
semilogy(snrDb, BER);  % Plot BER vs SNR on a semilog scale
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
grid on;
title('GFSK BER vs. SNR');
```

---

### 📌 *Contributions and Issues*
Feel free to **fork, contribute, or report issues** for improvements!

🚀 Happy Coding!
