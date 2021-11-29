//
// RISC-V RV32I CPU, By Li Yamin, yamin@ieee.org, Fri Jun 28 09:19:13 JST 2019
//
module rv32 (clk,clrn,pc,inst,m_addr,d_f_mem,d_t_mem,write,
                                 io_rdn,io_wrn,rvram,wvram,read);
    input         clk, clrn;                                 // clock and reset
    input  [31:0] inst;                                      // instruction
    input  [31:0] d_f_mem;                                   // load data
    output [31:0] pc;                                        // program counter
    output [31:0] m_addr;                                    // mem or i/o addr
    output [31:0] d_t_mem;                                   // store data
    output  [3:0] write;                                     // memory byte write enables
    output        read;                                      // memory read
    output  [3:0] wvram;                                     // vram byte write enables
    output        rvram;                                     // vram read
    output   reg  io_wrn;                                    // i/o write
    output   reg  io_rdn;                                    // i/o read

    // control signals
    reg           wreg;                                      // write regfile
    reg     [3:0] wmem;                                      // write memory byte enables
    reg           rmem;                                      // write/read memory
    reg    [31:0] alu_out;                                   // alu output
    reg    [31:0] mem_out;                                   // mem output
    reg    [31:0] m_addr;                                    // mem address
    reg    [31:0] next_pc;                                   // next pc
    reg    [31:0] d_t_mem;
    wire   [31:0] pc_plus_4 = pc + 4;                        // pc + 4

    // instruction format
    wire    [6:0] opcode = inst[6:0];   //
    wire    [2:0] func3  = inst[14:12]; //
    wire    [6:0] func7  = inst[31:25]; //
    wire    [4:0] rd     = inst[11:7];  //
    wire    [4:0] rs     = inst[19:15]; // = rs1
    wire    [4:0] rt     = inst[24:20]; // = rs2
    wire    [4:0] shamt  = inst[24:20]; // == rs2;
    wire          sign   = inst[31];
    wire   [11:0] imm    = inst[31:20];

    // branch offset            31:13          12      11       10:5         4:1     0
    wire   [31:0] broffset  = {{19{sign}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};   // beq, bne,  blt,  bge,   bltu, bgeu
    wire   [31:0] simm      = {{20{sign}},inst[31:20]};                                    // lw,  addi, slti, sltiu, xori, ori,  andi, jalr
    wire   [31:0] stimm     = {{20{sign}},inst[31:25],inst[11:7]};                         // sw
    wire   [31:0] uimm      = {inst[31:12],12'h0};                                         // lui, auipc
    wire   [31:0] jaloffset = {{11{sign}},inst[31],inst[19:12],inst[20],inst[30:21],1'b0}; // jal
    // jal target               31:21          20       19:12       11       10:1      0

    // instruction decode
    wire i_auipc = (opcode == 7'b0010111);
    wire i_lui   = (opcode == 7'b0110111);
    wire i_jal   = (opcode == 7'b1101111);
    wire i_jalr  = (opcode == 7'b1100111) & (func3 == 3'b000);
    wire i_beq   = (opcode == 7'b1100011) & (func3 == 3'b000);
    wire i_bne   = (opcode == 7'b1100011) & (func3 == 3'b001);
    wire i_blt   = (opcode == 7'b1100011) & (func3 == 3'b100);
    wire i_bge   = (opcode == 7'b1100011) & (func3 == 3'b101);
    wire i_bltu  = (opcode == 7'b1100011) & (func3 == 3'b110);
    wire i_bgeu  = (opcode == 7'b1100011) & (func3 == 3'b111);
    wire i_lb    = (opcode == 7'b0000011) & (func3 == 3'b000);
    wire i_lh    = (opcode == 7'b0000011) & (func3 == 3'b001);
    wire i_lw    = (opcode == 7'b0000011) & (func3 == 3'b010);
    wire i_lbu   = (opcode == 7'b0000011) & (func3 == 3'b100);
    wire i_lhu   = (opcode == 7'b0000011) & (func3 == 3'b101);
    wire i_sb    = (opcode == 7'b0100011) & (func3 == 3'b000);
    wire i_sh    = (opcode == 7'b0100011) & (func3 == 3'b001);
    wire i_sw    = (opcode == 7'b0100011) & (func3 == 3'b010);
    wire i_addi  = (opcode == 7'b0010011) & (func3 == 3'b000);
    wire i_slti  = (opcode == 7'b0010011) & (func3 == 3'b010);
    wire i_sltiu = (opcode == 7'b0010011) & (func3 == 3'b011);
    wire i_xori  = (opcode == 7'b0010011) & (func3 == 3'b100);
    wire i_ori   = (opcode == 7'b0010011) & (func3 == 3'b110);
    wire i_andi  = (opcode == 7'b0010011) & (func3 == 3'b111);
    wire i_csrrw = (opcode == 7'b1110011) & (func3 == 3'b001); // not an rv32i instruction
    wire i_slli  = (opcode == 7'b0010011) & (func3 == 3'b001) & (func7 == 7'b0000000);
    wire i_srli  = (opcode == 7'b0010011) & (func3 == 3'b101) & (func7 == 7'b0000000);
    wire i_srai  = (opcode == 7'b0010011) & (func3 == 3'b101) & (func7 == 7'b0100000);
    wire i_add   = (opcode == 7'b0110011) & (func3 == 3'b000) & (func7 == 7'b0000000);
    wire i_sub   = (opcode == 7'b0110011) & (func3 == 3'b000) & (func7 == 7'b0100000);
    wire i_sll   = (opcode == 7'b0110011) & (func3 == 3'b001) & (func7 == 7'b0000000);
    wire i_slt   = (opcode == 7'b0110011) & (func3 == 3'b010) & (func7 == 7'b0000000);
    wire i_sltu  = (opcode == 7'b0110011) & (func3 == 3'b011) & (func7 == 7'b0000000);
    wire i_xor   = (opcode == 7'b0110011) & (func3 == 3'b100) & (func7 == 7'b0000000);
    wire i_srl   = (opcode == 7'b0110011) & (func3 == 3'b101) & (func7 == 7'b0000000);
    wire i_sra   = (opcode == 7'b0110011) & (func3 == 3'b101) & (func7 == 7'b0100000);
    wire i_or    = (opcode == 7'b0110011) & (func3 == 3'b110) & (func7 == 7'b0000000);
    wire i_and   = (opcode == 7'b0110011) & (func3 == 3'b111) & (func7 == 7'b0000000);

    // pc
    reg    [31:0]  pc;
    always @ (posedge clk or negedge clrn) begin
        if (!clrn) pc <= 0;
        else       pc <= next_pc;
    end

    // data written to register file
    wire        i_load = i_lw | i_lb | i_lbu | i_lh | i_lhu | i_csrrw;
    wire [31:0] data_2_rf = i_load ? mem_out : alu_out;

    // register file
    reg    [31:0] regfile [1:31];                          // x1 - x31, should be [1:31]
    wire   [31:0] a = (rs==0) ? 0 : regfile[rs];           // read port
    wire   [31:0] b = (rt==0) ? 0 : regfile[rt];           // read port
    always @ (posedge clk) begin
        if (wreg && (rd != 0)) begin
            regfile[rd] <= data_2_rf;                      // write port
        end
    end

    // vram space
    wire  vr_space =                                       // vram space:
          alu_out[31] & // 1
          alu_out[30] & // 1                               // c0000000-dfffffff
         ~alu_out[29];  // 0

    // output signals
    assign write   =    wmem & {4{~vr_space}};             // data memory write
    assign read    =    rmem &    ~vr_space;               // data memory read
    assign wvram   =    wmem & {4{vr_space}};              // video ram write
    assign rvram   =    rmem & vr_space;                   // video ram read

    // control signals, will be combinational circuit
    always @(*) begin                                      // 38 instructions
        alu_out = 0;                                       // alu output
        mem_out = 0;                                       // mem output
        m_addr  = 0;                                       // memory address
        wreg    = 0;                                       // write regfile
        wmem    = 4'b0000;                                 // write memory (sw)
        rmem    = 0;                                       // read  memory (lw)
        io_rdn  = 1;
        io_wrn  = 1;
        d_t_mem = b;
        next_pc = pc_plus_4;
        case (1'b1)
            i_add: begin                                   // add
                alu_out = a + b;
                wreg    = 1; end
            i_sub: begin                                   // sub
                alu_out = a - b;
                wreg    = 1; end
            i_and: begin                                   // and
                alu_out = a & b;
                wreg    = 1; end
            i_or: begin                                    // or
                alu_out = a | b;
                wreg    = 1; end
            i_xor: begin                                   // xor
                alu_out = a ^ b;
                wreg    = 1; end
            i_sll: begin                                   // sll
                alu_out = a << b[4:0];
                wreg    = 1; end
            i_srl: begin                                   // srl
                alu_out = a >> b[4:0];
                wreg    = 1; end
            i_sra: begin                                   // sra
                alu_out = $signed(a) >>> b[4:0];
                wreg    = 1; end
            i_slli: begin                                  // slli
                alu_out = a << shamt;
                wreg    = 1; end
            i_srli: begin                                  // srli
                alu_out = a >> shamt;
                wreg    = 1; end
            i_srai: begin                                  // srai
                alu_out = $signed(a) >>> shamt;
                wreg    = 1; end
            i_slt: begin                                   // slt
                if ($signed(a) < $signed(b)) 
                  alu_out = 1; end
            i_sltu: begin                                  // sltu
                if ({1'b0,a} < {1'b0,b}) 
                  alu_out = 1; end
            i_addi: begin                                  // addi
                alu_out = a + simm;
                wreg    = 1; end
            i_andi: begin                                  // andi
                alu_out = a & simm;
                wreg    = 1; end
            i_ori: begin                                   // ori
                alu_out = a | simm;
                wreg    = 1; end
            i_xori: begin                                  // xori
                alu_out = a ^ simm;
                wreg    = 1; end
            i_slti: begin                                  // slti
                if ($signed(a) < $signed(simm)) 
                  alu_out = 1; end
            i_sltiu: begin                                 // sltiu
                if ({1'b0,a} < {1'b0,simm}) 
                  alu_out = 1; end
            i_lw: begin                                    // lw
                alu_out = a + simm;
                m_addr  = {alu_out[31:2],2'b00};           // alu_out[1:0] != 0, exception
                rmem    = 1;
                mem_out = d_f_mem;
                wreg    = 1; end
            i_lbu: begin                                   // lbu
                alu_out = a + simm;
                m_addr  = alu_out;
                rmem    = 1;
                case(m_addr[1:0])
                  2'b00: mem_out = {24'h0,d_f_mem[ 7: 0]};
                  2'b01: mem_out = {24'h0,d_f_mem[15: 8]};
                  2'b10: mem_out = {24'h0,d_f_mem[23:16]};
                  2'b11: mem_out = {24'h0,d_f_mem[31:24]};
                endcase
                wreg    = 1; end
            i_lb: begin                                    // lb
                alu_out = a + simm;
                m_addr  = alu_out;
                rmem    = 1;
                case(m_addr[1:0])
                  2'b00: mem_out = {{24{d_f_mem[ 7]}},d_f_mem[ 7: 0]};
                  2'b01: mem_out = {{24{d_f_mem[15]}},d_f_mem[15: 8]};
                  2'b10: mem_out = {{24{d_f_mem[23]}},d_f_mem[23:16]};
                  2'b11: mem_out = {{24{d_f_mem[31]}},d_f_mem[31:24]};
                endcase
                wreg    = 1; end
            i_lhu: begin                                   // lhu
                alu_out = a + simm;
                m_addr  = {alu_out[31:1],1'b0};            // alu_out[0] != 0, exception
                rmem    = 1;
                       case(m_addr[1])
                  1'b0: mem_out = {16'h0,d_f_mem[15: 0]};
                  1'b1: mem_out = {16'h0,d_f_mem[31:16]};
                endcase
                wreg    = 1; end
            i_lh: begin                                    // lh
                alu_out = a + simm;
                m_addr  = {alu_out[31:1],1'b0};            // alu_out[0] != 0, exception
                rmem    = 1;
                case(m_addr[1])
                  1'b0: mem_out = {{16{d_f_mem[15]}},d_f_mem[15: 0]};
                  1'b1: mem_out = {{16{d_f_mem[31]}},d_f_mem[31:16]};
                endcase
                wreg    = 1; end
            i_sb: begin                                    // sb
                alu_out = a + stimm;
                m_addr  = alu_out;
                wmem    = 4'b0001 << alu_out[1:0]; end
            i_sh: begin                                    // sh
                alu_out = a + stimm;
                m_addr  = {alu_out[31:1],1'b0};            // alu_out[0] != 0, exception
                wmem    = 4'b0011 << {alu_out[1],1'b0}; end
            i_sw: begin                                    // sw
                alu_out = a + stimm;
                m_addr  = {alu_out[31:2],2'b00};           // alu_out[1:0] != 0, exception
                wmem    = 4'b1111; end
            i_beq: begin                                   // beq
                if (a == b) 
                  next_pc = pc + broffset; end
            i_bne: begin                                   // bne
                if (a != b) 
                  next_pc = pc + broffset; end
            i_blt: begin                                   // blt
                if ($signed(a) < $signed(b)) 
                  next_pc = pc + broffset; end
            i_bge: begin                                   // bge
                if ($signed(a) >= $signed(b)) 
                  next_pc = pc + broffset; end
            i_bltu: begin                                  // bltu
                if ({1'b0,a} < {1'b0,b}) 
                  next_pc = pc + broffset; end
            i_bgeu: begin                                  // bgeu
                if ({1'b0,a} >= {1'b0,b}) 
                  next_pc = pc + broffset; end
            i_auipc: begin                                 // auipc
                alu_out = pc + uimm;
                wreg    = 1; end
            i_lui: begin                                   // lui
                alu_out = uimm;
                wreg    = 1; end
            i_jal: begin                                   // jal
                alu_out = pc_plus_4;
                wreg    = 1;
                next_pc = pc + jaloffset; end
            i_jalr: begin                                  // jalr
                alu_out = pc_plus_4;
                wreg    = 1;
                next_pc = (a + simm) & 32'hfffffffe; end
            i_csrrw: begin                                 // csrrw
                m_addr  = {20'h0,imm};
                if (rd != 0) begin
                    io_rdn  = 0; // csr read
                    mem_out = d_f_mem;
                    wreg    = 1;
                end
                if (rs != 0) begin
                    io_wrn  = 0; // csr write
                    d_t_mem = a;
                end
            end
            default: ;
        endcase
    end
endmodule