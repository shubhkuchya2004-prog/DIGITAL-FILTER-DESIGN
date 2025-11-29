# DIGITAL-FILTER-DESIGN

*COMPANY* : CODTECH IT SOLUTIONS

*NAME* : SHUBH KUCHYA

*INTERN ID* : CT04DR1218

*DOMAIN* : VLSI

*DURATION* : 4 WEEKS

*MENTOR* : NEELA SANTOSH

#The process of designing and simulating a Digital FIR (Finite Impulse Response) filter involves several systematic steps that ensure the filter meets the required frequency response specifications and functions correctly in hardware or software environments. FIR filters are widely used in digital signal processing due to their inherent stability and linear phase characteristics.If designing directly in Verilog, the coefficients are pre-computed using MATLAB/Python and then inserted into the HDL code.
A direct-form FIR architecture is typically implemented, which includes:

A shift register to store past input samples

A set of multipliers (input samples × coefficients)

An adder tree or accumulator to sum the products

Output scaling and optional rounding/saturation logic

For hardware-efficient implementation, the floating-point coefficients are quantized to:

16-bit or 12-bit fixed-point

Signed representation

Q-format such as Q1.15

Input samples are also represented in fixed-point. Care is taken to prevent:

Overflow

Word-length growth

Loss of precision
