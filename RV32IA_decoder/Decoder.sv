
//----------------------------- load upper immediate opcode
`define LUI_opcode 	7'b0110111  
//-----------------------------	add upper immediate to pc opcode
`define AUIPC_opcode 7'b0010111  
//-----------------------------	jump and link opcode
`define JAL_opcode 	7'b1101111  
//----------------------------- 	jump and link register opcode
`define JALR_opcode 	7'b1100111
//-----------------------------  branching opcodes
`define BR_opcode 	7'b1100011    
//===================
`define BEQ		3'b000
`define BNE		3'b001
`define BLT		3'b100
`define BGE		3'b101
`define BLTU	3'b110
`define BGEU	3'b111
//===================
//-----------------------------	load opcodes
`define L_opcode 		7'b0000011  
//===================
`define LB 		3'b000
`define LH 		3'b001
`define LW 		3'b010
`define LBU		3'b100
`define LHU		3'b101
//===================
//-----------------------------	Store opcodes
`define S_opcode		7'b0100011  
//===================
`define SB 		3'b000
`define SH 		3'b001
`define SW 		3'b010
//===================
//-----------------------------	register immediate opcodes
`define Reg_imm_opcode	7'b0010011
//===================
`define ADDI	3'b000
`define SLTI	3'b010
`define SLTIU 	3'b011
`define XORI	3'b100
`define ORI		3'b110
`define ANDI	3'b111
//===================
//----------------------------- Shift by a constant 
`define Shift_imm_opcode	7'b0010011
//===================
`define SLLI	3'b001
`define SRLI	3'b101
`define SRAI 	3'b101	 //funct3
//======================	
`define SRAI_	7'0100000 //funct7 use for SRAI and SRA arithmetic shift right
//======================
//-----------------------------
`define Reg_Reg_opcode 	7'b0110011
//===================
`define ADD 	3'b000
`define SUB 	3'b000
`define SLL 	3'b001
`define SLT 	3'b010
`define SLTU 	3'b011
`define XOR 	3'b100
`define SRL 	3'b101
`define SRA 	3'b101
`define OR 		3'b110
`define AND 	3'b111
//===================
//-----------------------------
`define FENCE_opcode 7'b0001111
//-----------------------------
`define ECALL_opcode	 7'b1110011
`define EBREAK_opcode 7'b1110011
/*
//==============================================================
______________7 control signals of standard RV32I_______________
		RegDst	=	1'b1;//Register destination.
		Branch	=	1'b0;
		MemRead	=	1'b0;
		MemtoReg	=	1'b0;
		alu_op	=	4'h0;//operation to be perform by the ALU
		MemWrite	=	1'b0;
		ALUSrc	=	1'b1;//is for choosing between immediate/register source 2.
		RegWrite	=	1'b1;
//==============================================================
*/
//==============================================================
module Decoder(a,c);
input [31:0]a;
output [3:0]c;
			//always@(a)
			 //c <= 4'hf;
			 decode(.instr(a),.alu_op(c));

endmodule 
//==============================================================
module decode(instr,alu_op,RegDst,Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite);
input [31:0] instr;
logic 	[31:0]imm;
logic 	[6:0]funct7;
logic 	[2:0]funct3;
logic 	[6:0]opcode;
output logic 	RegDst,Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite;
output logic 	[3:0]alu_op; 

assign opcode = instr[6:0];
assign funct3 = instr[14:12];
assign funct7 = instr[31:25];
//assign RT = instr[20:16];
//assign RS = instr[25:21];
//assign RD = instr[15:11];
always @ (instr,opcode,RegDst,Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite,funct3)
	begin
				case(opcode)
						`LUI_opcode: //Load Upper Immediate
						begin
								RegDst	=	1'b1;
								Branch	=	1'b0;
								MemRead	=	1'b1;
								MemtoReg	=	1'b1;
								alu_op	=	4'h0;
								MemWrite	=	1'b1;
								ALUSrc	=	1'b0;
								RegWrite	=	1'b0;
						end
						`AUIPC_opcode: // Add Upper Immediate to pc
						begin
								RegDst	=	1'b0;
								Branch	=	1'b0;
								MemRead	=	1'b0;
								MemtoReg	=	1'b0;
								MemWrite	=	1'b0;
								ALUSrc	=	1'b1;
								RegWrite	=	1'b0;
						end
						`JAL_opcode: //Jump And Link
						begin
								RegDst	=	1'b0;
								Branch	=	1'b1;
								MemRead	=	1'b0;
								MemtoReg	=	1'b0;
								alu_op	=	4'h0;
								MemWrite	=	1'b0;
								ALUSrc	=	1'b0;
								RegWrite	=	1'b0;
						end
						`JALR_opcode: //Jump And Link Register 
						begin
								RegDst	=	1'b0;
								Branch	=	1'b0;
								MemRead	=	1'b0;
								MemtoReg	=	1'b1;
								alu_op	=	4'h0;
								MemWrite	=	1'b0;
								ALUSrc	=	1'b0;
								RegWrite	=	1'b1;
						end
						`BR_opcode: //branching
						begin
							case(funct3)
							`BEQ:// BEQ funct3-
								begin
								RegDst	=	1'b0;
								Branch	=	1'b1;
								MemRead	=	1'b1;
								MemtoReg	=	1'b0;
								alu_op	=	4'h1;
								MemWrite	=	1'b0;
								ALUSrc	=	1'b1;
								RegWrite	=	1'b0;
								end
							`BNE:// BNE funct3-
								begin
								RegDst	=	1'b0;
								Branch	=	1'b1;
								MemRead	=	1'b1;
								MemtoReg	=	1'b0;
								alu_op	=	4'h1;
								MemWrite	=	1'b0;
								ALUSrc	=	1'b1;
								RegWrite	=	1'b0;
								end
							`BLT:// BLT funct3-
								begin
								RegDst	=	1'b0;
								Branch	=	1'b1;
								MemRead	=	1'b1;
								MemtoReg	=	1'b0;
								alu_op	=	4'h1;
								MemWrite	=	1'b0;
								ALUSrc	=	1'b1;
								RegWrite	=	1'b0;
								end
							`BGE:// BGE funct3-
								begin
								RegDst	=	1'b0;
								Branch	=	1'b1;
								MemRead	=	1'b1;
								MemtoReg	=	1'b0;
								alu_op	=	4'h1;
								MemWrite	=	1'b0;
								ALUSrc	=	1'b1;
								RegWrite	=	1'b0;
								end
							`BLTU:// BLTU funct3-
								begin
								RegDst	=	1'b0;
								Branch	=	1'b1;
								MemRead	=	1'b1;
								MemtoReg	=	1'b0;
								alu_op	=	4'h1;
								MemWrite	=	1'b0;
								ALUSrc	=	1'b1;
								RegWrite	=	1'b0;
								end
							`BGEU:// BGEU funct3-
								begin
								RegDst	=	1'b0;
								Branch	=	1'b1;
								MemRead	=	1'b1;
								MemtoReg	=	1'b0;
								alu_op	=	4'h1;
								MemWrite	=	1'b0;
								ALUSrc	=	1'b1;
								RegWrite	=	1'b0;
								end
							endcase
						end
						`L_opcode: //Load 
						begin
							case(funct3)
							`LB:	//signed byte = 8 bits 
								begin
								RegDst	=	1'b1;
								Branch	=	1'b0;
								MemRead	=	1'b0;
								MemtoReg	=	1'b0;
								alu_op	=	4'h1;
								MemWrite	=	1'b1;
								ALUSrc	=	1'b1;
								RegWrite	=	1'b0;
								end
							`LH:	//signed half word = 16 bits
								begin
								RegDst	=	1'b1;
								Branch	=	1'b0;
								MemRead	=	1'b0;
								MemtoReg	=	1'b0;
								alu_op	=	4'h1;
								MemWrite	=	1'b1;
								ALUSrc	=	1'b1;
								RegWrite	=	1'b0;
								end
							`LW:	//signed word = 32 bits
								begin
								RegDst	=	1'b1;
								Branch	=	1'b0;
								MemRead	=	1'b0;
								MemtoReg	=	1'b0;
								alu_op	=	4'h1;
								MemWrite	=	1'b1;
								ALUSrc	=	1'b1;
								RegWrite	=	1'b0;
								end
							`LBU:	//unsigned byte = 8 bits
								begin
								RegDst	=	1'b1;
								Branch	=	1'b0;
								MemRead	=	1'b0;
								MemtoReg	=	1'b0;
								alu_op	=	4'h1;
								MemWrite	=	1'b1;
								ALUSrc	=	1'b1;
								RegWrite	=	1'b0;
								end
							`LHU:	//unsigned half word = 16 bits
								begin
								RegDst	=	1'b1;
								Branch	=	1'b0;
								MemRead	=	1'b0;
								MemtoReg	=	1'b0;
								alu_op	=	4'h1;
								MemWrite	=	1'b1;
								ALUSrc	=	1'b1;
								RegWrite	=	1'b0;
								end
							endcase
						end
						`S_opcode: //Store 
						begin
							case(funct3)
							`SB:	
								begin
								RegDst	=	1'b0;
								Branch	=	1'b0;
								MemRead	=	1'b0;
								MemtoReg	=	1'b0;
								alu_op	=	4'h1;
								MemWrite	=	1'b0;
								ALUSrc	=	1'b0;
								RegWrite	=	1'b0;
								end
							`SH:	
								begin
								RegDst	=	1'b0;
								Branch	=	1'b0;
								MemRead	=	1'b0;
								MemtoReg	=	1'b0;
								alu_op	=	4'h1;
								MemWrite	=	1'b0;
								ALUSrc	=	1'b0;
								RegWrite	=	1'b0;
								end
							`SW:	
								begin
								RegDst	=	1'b0;
								Branch	=	1'b0;
								MemRead	=	1'b0;
								MemtoReg	=	1'b0;
								alu_op	=	4'h1;
								MemWrite	=	1'b0;
								ALUSrc	=	1'b0;
								RegWrite	=	1'b0;
								end
							endcase
						end
						`Reg_imm_opcode:// immediate to register operations(done)
						begin
							case(funct3)
							`ADDI:	
								begin
								RegDst	=	1'b1;//Register destination.
								Branch	=	1'b0;
								MemRead	=	1'b0;
								MemtoReg	=	1'b0;
								alu_op	=	4'h0;
								MemWrite	=	1'b0;
								ALUSrc	=	1'b1;//is for choosing between immediate/register source 2.
								RegWrite	=	1'b1;
								end
							`SLTI:	
								begin
								RegDst	=	1'b1;
								Branch	=	1'b0;
								MemRead	=	1'b0;
								MemtoReg	=	1'b0;
								alu_op	=	4'h1;
								MemWrite	=	1'b0;
								ALUSrc	=	1'b1;
								RegWrite	=	1'b1;
								end
							`SLTIU:	
								begin
								RegDst	=	1'b1;
								Branch	=	1'b0;
								MemRead	=	1'b0;
								MemtoReg	=	1'b0;
								alu_op	=	4'h1;
								MemWrite	=	1'b0;
								ALUSrc	=	1'b1;
								RegWrite	=	1'b1;
								end
							`XORI:	
								begin
								RegDst	=	1'b1;
								Branch	=	1'b0;
								MemRead	=	1'b0;
								MemtoReg	=	1'b0;
								alu_op	=	4'h1;
								MemWrite	=	1'b0;
								ALUSrc	=	1'b1;
								RegWrite	=	1'b1;
								end
							`ORI:	
								begin
								RegDst	=	1'b1;
								Branch	=	1'b0;
								MemRead	=	1'b0;
								MemtoReg	=	1'b0;
								alu_op	=	4'h1;
								MemWrite	=	1'b0;
								ALUSrc	=	1'b1;
								RegWrite	=	1'b1;
								end
							`ANDI:	
								begin
								RegDst	=	1'b1;
								Branch	=	1'b0;
								MemRead	=	1'b0;
								MemtoReg	=	1'b0;
								alu_op	=	4'h1;
								MemWrite	=	1'b0;
								ALUSrc	=	1'b1;
								RegWrite	=	1'b1;
								end
							endcase
						end
						`Shift_imm_opcode:// shifting immediate
						begin
							case(funct3)
							`SLLI:
								begin
										RegDst	=	1'b1;
										Branch	=	1'b0;
										MemRead	=	1'b0;
										MemtoReg	=	1'b0;
										alu_op	=	4'h1;
										MemWrite	=	1'b0;
										ALUSrc	=	1'b0;
										RegWrite	=	1'b0;
								end
							`SRLI:
								begin
										RegDst	=	1'b1;
										Branch	=	1'b0;
										MemRead	=	1'b0;
										MemtoReg	=	1'b0;
										alu_op	=	4'h1;
										MemWrite	=	1'b0;
										ALUSrc	=	1'b0;
										RegWrite	=	1'b0;
								end
							`SRAI:
								begin
								if(funct7==7'b0100000)// SRAI_=7'b0100000 funct7
									begin
										RegDst	=	1'b1;
										Branch	=	1'b0;
										MemRead	=	1'b1;
										MemtoReg	=	1'b0;
										alu_op	=	4'h1;
										MemWrite	=	1'b1;
										ALUSrc	=	1'b0;
										RegWrite	=	1'b1;
									end
								else
									begin
										RegDst	=	1'b1;
										Branch	=	1'b0;
										MemRead	=	1'b0;
										MemtoReg	=	1'b0;
										alu_op	=	4'h1;
										MemWrite	=	1'b0;
										ALUSrc	=	1'b0;
										RegWrite	=	1'b0;
									end
								end
							endcase
						end
						`Reg_Reg_opcode:// register to register operations(done)
						begin
								case(funct3)
									`ADD:
									begin
										RegDst	=	1'b1;// regdst=0 is putting result into rt
										Branch	=	1'b0;
										MemRead	=	1'b0;
										MemtoReg	=	1'b0;
										alu_op	=	4'h1;
										MemWrite	=	1'b0;
										ALUSrc	=	1'b0;
										RegWrite	=	1'b1;
									end
									`SUB:
									begin
									if(funct7==7'b0100000)// SRAI_=7'b0100000 funct7
										begin
										RegDst	=	1'b1;
										Branch	=	1'b0;
										MemRead	=	1'b1;
										MemtoReg	=	1'b0;
										alu_op	=	4'h1;
										MemWrite	=	1'b1;
										ALUSrc	=	1'b0;
										RegWrite	=	1'b1;
										end
									else
										begin
										RegDst	=	1'b0;
										Branch	=	1'b0;
										MemRead	=	1'b0;
										MemtoReg	=	1'b0;
										alu_op	=	4'hx;
										MemWrite	=	1'b0;
										ALUSrc	=	1'b0;
										RegWrite	=	1'b0;
										end
									end
									`SLL:
									begin
										RegDst	=	1'b1;
										Branch	=	1'b0;
										MemRead	=	1'b0;
										MemtoReg	=	1'b0;
										alu_op	=	4'h1;
										MemWrite	=	1'b0;
										ALUSrc	=	1'b0;
										RegWrite	=	1'b1;
									end
									`SLT:
									begin
										RegDst	=	1'b1;
										Branch	=	1'b0;
										MemRead	=	1'b0;
										MemtoReg	=	1'b0;
										alu_op	=	4'h1;
										MemWrite	=	1'b0;
										ALUSrc	=	1'b0;
										RegWrite	=	1'b1;
									end
									`SLTU:
									begin
										RegDst	=	1'b1;
										Branch	=	1'b0;
										MemRead	=	1'b0;
										MemtoReg	=	1'b0;
										alu_op	=	4'h1;
										MemWrite	=	1'b0;
										ALUSrc	=	1'b0;
										RegWrite	=	1'b1;
									end	
									`XOR:
									begin
										RegDst	=	1'b1;
										Branch	=	1'b0;
										MemRead	=	1'b0;
										MemtoReg	=	1'b0;
										alu_op	=	4'h1;
										MemWrite	=	1'b0;
										ALUSrc	=	1'b0;
										RegWrite	=	1'b1;
									end
									`SRL:
									begin
										RegDst	=	1'b1;
										Branch	=	1'b0;
										MemRead	=	1'b0;
										MemtoReg	=	1'b0;
										alu_op	=	4'h1;
										MemWrite	=	1'b0;
										ALUSrc	=	1'b0;
										RegWrite	=	1'b1;
									end								
									`SRA:
									begin
									if(funct7==7'b0100000)// SRAI_=7'b0100000 funct7
										begin
										RegDst	=	1'b1;
										Branch	=	1'b0;
										MemRead	=	1'b1;
										MemtoReg	=	1'b0;
										alu_op	=	4'h1;
										MemWrite	=	1'b1;
										ALUSrc	=	1'b0;
										RegWrite	=	1'b1;
										end
									else
										begin
										RegDst	=	1'b0;
										Branch	=	1'b0;
										MemRead	=	1'b0;
										MemtoReg	=	1'b0;
										alu_op	=	4'hx;
										MemWrite	=	1'b0;
										ALUSrc	=	1'b0;
										RegWrite	=	1'b0;
										end
									end
									`OR:
									begin
										RegDst	=	1'b1;
										Branch	=	1'b0;
										MemRead	=	1'b0;
										MemtoReg	=	1'b0;
										alu_op	=	4'h1;
										MemWrite	=	1'b0;
										ALUSrc	=	1'b0;
										RegWrite	=	1'b1;
									end
									`AND:
									begin
										RegDst	=	1'b1;
										Branch	=	1'b0;
										MemRead	=	1'b0;
										MemtoReg	=	1'b0;
										alu_op	=	4'h1;
										MemWrite	=	1'b0;
										ALUSrc	=	1'b0;
										RegWrite	=	1'b1;
									end									
								endcase
						end
						`FENCE_opcode:
						begin
							if(funct3==3'b000)
								begin
								RegDst	=	1'b1;
								Branch	=	1'b0;
								MemRead	=	1'b1;
								MemtoReg	=	1'b1;
								alu_op	=	4'h1;
								MemWrite	=	1'b1;
								ALUSrc	=	1'b0;
								RegWrite	=	1'b1;
								end
							else
								begin
								RegDst	=	1'b0;
								Branch	=	1'b0;
								MemRead	=	1'b0;
								MemtoReg	=	1'b0;
								alu_op	=	4'hx;
								MemWrite	=	1'b0;
								ALUSrc	=	1'b0;
								RegWrite	=	1'b0;
								end
						end
						`ECALL_opcode:
						begin
							if(funct3==3'b000)
								begin
									if(instr[31:20]==0)
								begin
								RegDst	=	1'b0;
								Branch	=	1'b0;
								MemRead	=	1'b1;
								MemtoReg	=	1'b1;
								alu_op	=	4'h1;
								MemWrite	=	1'b1;
								ALUSrc	=	1'b0;
								RegWrite	=	1'b1;
								end
								end
							else
								begin
								RegDst	=	1'b0;
								Branch	=	1'b0;
								MemRead	=	1'b0;
								MemtoReg	=	1'b0;
								alu_op	=	4'h1;
								MemWrite	=	1'b0;
								ALUSrc	=	1'b0;
								RegWrite	=	1'b0;
								end
						end
						`EBREAK_opcode:
						begin
							if(funct3==3'b000)
								begin
									if(instr[31:20]==1)
								begin
								RegDst	=	1'b0;
								Branch	=	1'b0;
								MemRead	=	1'b1;
								MemtoReg	=	1'b1;
								alu_op	=	4'h1;
								MemWrite	=	1'b1;
								ALUSrc	=	1'b0;
								RegWrite	=	1'b1;
								end
								end
							else
								begin
								RegDst	=	1'b0;
								Branch	=	1'b0;
								MemRead	=	1'b0;
								MemtoReg	=	1'b0;
								alu_op	=	4'h1;
								MemWrite	=	1'b0;
								ALUSrc	=	1'b0;
								RegWrite	=	1'b0;
								end
						end
						default: 
						begin
								RegDst	=	1'b0;
								Branch	=	1'b0;
								MemRead	=	1'b0;
								MemtoReg	=	1'b0;
								alu_op	=	4'h0;
								MemWrite	=	1'b0;
								ALUSrc	=	1'b0;
								RegWrite	=	1'b0;
						end
				endcase
	end
						
		
		
endmodule 
