//==================================================================================================================================================				
//==================================================================================================================================================
//==================================================================================================================================================

// data Memroy unit (RAM)
module Data_Memory(address,din,WE,CS,OE,dout);
input [20:0]address;
input [15:0]din;
input WE,CS,OE; // Write Enable, Chip Select, Output Enable
output reg [15:0]dout;
			//generate
				SRAM_cell(.reset(1'b0),.din(din[0]),.WE(WE),.dout(dout[0]));
			//endgenerate
endmodule 
//==================================================================================================================================================				
//==================================================================================================================================================
//==================================================================================================================================================
module SRAM_cell(reset,din,WE,dout);
input din;
input WE,reset; // Write Enable, Chip Select, Output Enable
output reg dout;
	always @(din or WE or reset)
			begin
			if (!reset)
				dout<=0;
				else
					if (WE)
						dout<=din;
			end
endmodule 