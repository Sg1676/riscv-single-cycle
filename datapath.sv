module datapath(
    input  logic        clk,
    input  logic        reset,
    input  logic [1:0]  ResultSrc,
    input  logic        PCSrc,
    input  logic        ALUSrc,
    input  logic        RegWrite,
    input  logic [1:0]  ImmSrc,
    input  logic [2:0]  ALUControl,
    output logic        Zero,
    output logic [31:0] PC,
    input  logic [31:0] Instr,
    output logic [31:0] ALUResult,
    output logic [31:0] WriteData,
    input  logic [31:0] ReadData
);
    logic [31:0] PCNext, PCPlus4, PCTarget;
    logic [31:0] ImmExt, SrcA, SrcB, Result;

    // next PC
    flopr #(32) pcreg (.d(PCNext), .clk, .reset, .q(PC));
    adder       pcadd4(.a(PC), .b(32'd4), .y(PCPlus4));
    adder       pcaddbranch(.a(PC), .b({ImmExt[30:0], 1'b0}), .y(PCTarget)); // PC + (ImmExt << 1)
    mux2  #(32) pcmux (.d0(PCPlus4), .d1(PCTarget), .s(PCSrc), .y(PCNext));

    // register file
    regfile rf(.clk, .we3(RegWrite), .a1(Instr[19:15]), .a2(Instr[24:20]),
               .a3(Instr[11:7]), .wd3(Result), .rd1(SrcA), .rd2(WriteData));
    extend  ext(.instr(Instr[31:7]), .immsrc(ImmSrc), .immext(ImmExt));

    // ALU
    mux2 #(32) srcbmux(.d0(WriteData), .d1(ImmExt), .s(ALUSrc), .y(SrcB));
    alu        alu(.a(SrcA), .b(SrcB), .alucontrol(ALUControl), .result(ALUResult));
    assign Zero = (ALUResult == 32'b0);

    // write-back
    mux3 #(32) resultmux(.d0(ALUResult), .d1(ReadData), .d2(PCPlus4), .s(ResultSrc), .y(Result));
endmodule
