// B/J immediates are emitted WITHOUT the implicit LSB 0 (i.e. imm >> 1);
// the datapath forms the target as PC + (ImmExt << 1), per spec.
module extend(
    input  logic [31:7] instr,
    input  logic [1:0]  immsrc,
    output logic [31:0] immext
);
    always_comb
        case (immsrc)
            2'b00: immext = {{20{instr[31]}}, instr[31:20]};                               // I
            2'b01: immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};                  // S
            2'b10: immext = {{20{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8]};   // B: imm[12:1]
            2'b11: immext = {{12{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21]}; // J: imm[20:1]
            default: immext = 32'b0;
        endcase
endmodule
