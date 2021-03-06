
//==================================================================================================================================================				
//==================================================================================================================================================
//==================================================================================================================================================

// This adder has P,G,cout are outputs
	module full_adder_1_bit(a,b,sum_dif,p,g,cin,add_sub);
//--------------------------------------------------------------------------------------------------------------------------------------------------		
				input a,b,cin,add_sub;
				output sum_dif,p,g;
				wire B;
//--------------------------------------------------------------------------------------------------------------------------------------------------		
				assign B = b ^ add_sub ;
				assign g = a & B ;
				assign p = a ^ B ;
				assign sum_dif =  a ^ B ^ cin ;
//--------------------------------------------------------------------------------------------------------------------------------------------------		
	endmodule
//==================================================================================================================================================				
//==================================================================================================================================================
//==================================================================================================================================================

	//mux 2 to 1	
	module mux_2(input b,a,s,output y);
//--------------------------------------------------------------------------------------------------------------------------------------------------		
			assign y = s?b:a;     // when s = 0 choosing 'a' and when s = 1 choose 'b' , a is 0 b is 1 
			
	endmodule	
//==================================================================================================================================================				
//==================================================================================================================================================
//==================================================================================================================================================
	
	//    32bits 1bits shifter left and right
	module logic_shifter(in,scale,right_output,left_output,SAR_select);//Shifter_single_layer_32bits       logic_shifter
//--------------------------------------------------------------------------------------------------------------------------------------------------		
			input [31:0]  in;
			input [6:0]	scale;
			wire  [31:25][31:0] stage_left;
			wire  [31:25][31:0] stage_right;
			wire  [31:25][31:0] stage_right_arithmetic;
			output[31:0] right_output,left_output;
		 	input SAR_select; //shift arithmetic selection input 1 for arithmetic right shift, 0 for logic right shift.
			
			genvar i,j;
			
			generate
			
			for (i=0;i<32;i++)
					begin: SL_0_LAYER
					assign stage_left[31][31-i] = in[31-i];// this is line for connecting to the first array of mux
					assign stage_right[31][31-i] = in[31-i];// this is line for connecting to the first array of mux
			end
					for (i=0;i < 32;i++)            // this is for the first bit shift
								begin: SL_LAYERS_OF_Ns
									if (i>=1)
										mux_2 SLL(stage_left[31][i-1],stage_left[31][i],scale[0],stage_left[30][i]); //left shift
									else
										mux_2 SLL(1'b0,stage_left[31][i],scale[0],stage_left[30][i]);//left shift
									if (i<=30)
										mux_2 SLR(stage_right[31][i+1],stage_right[31][i],scale[0],stage_right[30][i]); //right shift
									else
										mux_2 SLR(SAR_select,stage_right[31][i],scale[0],stage_right[30][i]);//left shift
									end
					for (j=2;j<17;j*=2)      // this is for the 31-bits shift
								begin: SLL_N_LAYERS_
								for (i=0;i < 32;i++)
									begin: SL_LAYERS_OF_Ns_
									if (j<=i)
										mux_2 SLL(stage_left[31-$clog2(j)][i-j],stage_left[31-$clog2(j)][i],scale[$clog2(j)],stage_left[30-$clog2(j)][i]); //left shift_old
									else
										mux_2 SLL(1'b0,stage_left[31-$clog2(j)][i],scale[$clog2(j)],stage_left[30-$clog2(j)][i]);//left shift
									if (j<=31-i)
										mux_2 SLR(stage_right[31-$clog2(j)][i+j],stage_right[31-$clog2(j)][i],scale[$clog2(j)],stage_right[30-$clog2(j)][i]); //left shift_old
									else
										mux_2 SLR(SAR_select,stage_right[31-$clog2(j)][i],scale[$clog2(j)],stage_right[30-$clog2(j)][i]);//left shift
									end
								end
								for(i=0;i<32;i++)
								begin: connecting
									assign stage_left[25][i] = stage_left[26][i] & ~scale[6];
									assign stage_right[25][i] = stage_right[26][i] & ~scale[6];
								end
								assign left_output[31:0] = stage_left[25][31:0] ;
								assign right_output[31:0] = stage_right[25][31:0] ;
			endgenerate
			
//--------------------------------------------------------------------------------------------------------------------------------------------------							
					 
	endmodule
//==================================================================================================================================================				
//==================================================================================================================================================
//==================================================================================================================================================

	//comparator cell unit	
	module CMP_cell(a,b,Less,More,Even); //look ahead compare cell unit
		input [3:0] a,b;
		//output x,y;
		output Less,More,Even;
		wire[3:0]cmp;
//--------------------------------------------------------------------------------------------------------------------------------------------------		
			assign cmp[3] = (a[3]^b[3]);
			assign cmp[2] = (~(a[3]^b[3])&(a[2]^b[2]));
			assign cmp[1] = ~(a[3]^b[3])&~(a[2]^b[2])&(a[1]^b[1]);
			assign cmp[0] = ~(a[3]^b[3])&~(a[2]^b[2])&~(a[1]^b[1])&(a[0]^b[0]);
//--------------------------------------------------------------------------------------------------------------------------------------------------					

						assign Less = (~a[3]&b[3]&cmp[3])|(~a[2]&b[2]&cmp[2])|(~a[1]&b[1]&cmp[1])|(~a[0]&b[0]&cmp[0]);
						assign More = (a[3]&~b[3]&cmp[3])|(a[2]&~b[2]&cmp[2])|(a[1]&~b[1]&cmp[1])|(a[0]&~b[0]&cmp[0]);
						//assign Even = ~(Less&More);
			
	endmodule	
	// comparator module
	module Compare_module(a,b,Less,More,Even);
	input[31:0]a,b;
	wire [9:0] L,M;
	wire [1:0] cmp;
	output Less,More,Even;
				genvar i,j;
				generate
			   
				for (i=0;i<32;i+=4)begin: n_blocks
						CMP_cell cell_(a[i+3:i],b[i+3:i],L[(i/4)],M[(i/4)]);
				end
				for (j=0;j<5;j+=4)begin: n_subs
						CMP_cell cell_(L[j+3:j],M[j+3:j],L[(j/4)+8],M[(j/4)+8]);
				end
				assign cmp[1] = L[9]^M[9];
				assign cmp[0] = ~(L[9]^M[9])&(L[8]^M[8]);
				assign Less = (~L[9]&M[9]&cmp[1])|(~L[8]&M[8]&cmp[0]);
				assign More = (L[9]&~M[9]&cmp[1])|(L[8]&~M[8]&cmp[0]);
				assign Even = (~Less)&(~More);
				endgenerate
	endmodule
//==================================================================================================================================================				
//==================================================================================================================================================
//==================================================================================================================================================
	
	
	module mux_ALU_select_16_functions(sel,OUTput,addition,subtraction,and_logic,or_logic,xor_logic,shiftL_logic,shiftR_logic,shiftR_arithmetic,unset_logic,not_logic);
//--------------------------------------------------------------------------------------------------------------------------------------------------				
		input  addition,subtraction,and_logic,or_logic,xor_logic,shiftL_logic,shiftR_logic,shiftR_arithmetic,not_logic;
		input [8:1] unset_logic;
		input [3:0] sel;
		wire [15:0]outlet;
		output OUTput;
//--------------------------------------------------------------------------------------------------------------------------------------------------		
	//#	SEL=0 arithmetic addition
				assign outlet[0] 	= addition & (~sel[3]) & (~sel[2]) & (~sel[1]) & (~sel[0]);                 
	
	//#	SEL=1 arithmetic subtraction
				assign outlet[1] 	= subtraction & (~sel[3]) & (~sel[2]) & (~sel[1]) & (sel[0]);
	
	//#	SEL=2 AND logic operation
				assign outlet[2] 	= and_logic & (~sel[3]) & (~sel[2]) & (sel[1]) & (~sel[0]);
	
	//#	SEL=3 OR logic operation
				assign outlet[3] 	= or_logic & (~sel[3]) & (~sel[2]) & (sel[1]) & (sel[0]);
	
	//#	SEL=4 XOR logic operation
				assign outlet[4] 	= xor_logic & (~sel[3]) & (sel[2]) & (~sel[1]) & (~sel[0]);
	
	//#	SEL=5 NOT logic operation
				assign outlet[5] 	= not_logic & (~sel[3]) & (sel[2]) & (~sel[1]) & (sel[0]);
	
	//#	SEL=6 SHIFT LEFT logic operation
				assign outlet[6] 	= shiftL_logic & (~sel[3]) & (sel[2]) & (sel[1]) & (~sel[0]);
	
	//#	SEL=7 SHIFT RIGHT logic operation
				assign outlet[7] 	= shiftR_logic & (~sel[3]) & (sel[2]) & (sel[1]) & (sel[0]);
	
	//#	SEL=8 SHIFT RIGHT arithmetic operation
				assign outlet[8] 	= shiftR_arithmetic & (sel[3]) & (~sel[2]) & (~sel[1]) & (~sel[0]);
				assign outlet[9] 	= unset_logic[2] & (sel[3]) & (~sel[2]) & (~sel[1]) & (sel[0]);
				assign outlet[10] = unset_logic[3] & (sel[3]) & (~sel[2]) & (sel[1]) & (~sel[0]);
				assign outlet[11] = unset_logic[4] & (sel[3]) & (~sel[2]) & (sel[1]) & (sel[0]);
				assign outlet[12] = unset_logic[5] & (sel[3]) & (sel[2]) & (~sel[1]) & (~sel[0]);
				assign outlet[13] = unset_logic[6] & (sel[3]) & (sel[2]) & (~sel[1]) & (sel[0]);
				assign outlet[14] = unset_logic[7] & (sel[3]) & (sel[2]) & (sel[1]) & (~sel[0]);
				assign outlet[15] = unset_logic[8] & (sel[3]) & (sel[2]) & (sel[1]) & (sel[0]);
				assign OUTput = outlet[0]|outlet[1]|outlet[2]|outlet[3]|outlet[4]|outlet[5]|outlet[6]|outlet[7]|outlet[8]|outlet[9]|outlet[10]|outlet[11]|outlet[12]|outlet[13]|outlet[14]|outlet[15];
//--------------------------------------------------------------------------------------------------------------------------------------------------			
	endmodule
//==================================================================================================================================================				
//==================================================================================================================================================
//==================================================================================================================================================	

module carry_block_4bits(cin,p,g,carry_in,cout,P);		//carry_block_4bits
//--------------------------------------------------------------------------------------------------------------------------------------------------		
				output		[3:0] cin ;
				input 		 carry_in ;
				input  [3:0] p , g ;
				output 		 cout, P ;
//--------------------------------------------------------------------------------------------------------------------------------------------------		
				assign cin[0] = carry_in ;   						//the Cin entry
				
				assign cin[1] = ( cin[0] & p[0] ) | g[0] ; 	// going in next FA 1bits block
				
				assign cin[2] = ( cin[1] & p[1] ) | g[1] ;  	// going in next FA 1bits block
				
				assign cin[3] = ( cin[2] & p[2] ) | g[2] ;  	// going in next FA 1bits block
				
				assign cout   = ( cin[3] & p[3] ) | g[3] ;  	// cout is also 'G'
				
				assign P      = p[0] & p[1] & p[2] & p[3] ; 	//   'P'
//--------------------------------------------------------------------------------------------------------------------------------------------------						
				
				
	endmodule
//==================================================================================================================================================
//==================================================================================================================================================
//==================================================================================================================================================

		module FA_4bits(a,b,sum_dif,carry_in,cout,P,add_sub);
//--------------------------------------------------------------------------------------------------------------------------------------------------		
				input  [3:0] a , b ;
				wire   [3:0] cin , p , g ;
				input        carry_in , add_sub;
				output [3:0] sum_dif ;
				output       cout , P ;
//--------------------------------------------------------------------------------------------------------------------------------------------------		
			//discrete block of 1 bit full adder
							full_adder_1_bit FA_0 (a[0],b[0],sum_dif[0],p[0],g[0],cin[0],add_sub);
							full_adder_1_bit FA_1 (a[1],b[1],sum_dif[1],p[1],g[1],cin[1],add_sub);
							full_adder_1_bit FA_2 (a[2],b[2],sum_dif[2],p[2],g[2],cin[2],add_sub);
							full_adder_1_bit FA_3 (a[3],b[3],sum_dif[3],p[3],g[3],cin[3],add_sub);

			//carry block 4bits
			carry_block_4bits CLA_4bits_0(cin[3:0],p[3:0],g[3:0],carry_in,cout,P);
//--------------------------------------------------------------------------------------------------------------------------------------------------				
		endmodule
//==================================================================================================================================================				
//==================================================================================================================================================
//==================================================================================================================================================	
	
		module FA_32bits(a,b,sum_dif,carry_in,C,V,add_sub);	//FA_32bits
//--------------------------------------------------------------------------------------------------------------------------------------------------		
				input  [31:0] a , b ;  
				wire   [7:0] cin , p ,g ;		// for smaller 4bits modules
				wire   [1:0] Cin;			// for final 32bits joint
				input  	carry_in , add_sub;
				output [31:0] sum_dif ;
				wire [1:0]  P, G;
				output C,V;// C = Carry out; V = oVerflow.
//--------------------------------------------------------------------------------------------------------------------------------------------------		
	// assembly of multiple 4-bits segments to one single 32-bits
//--------------------------------------------------------------------------------------------------------------------------------------------------		
				FA_4bits block0(a[3:0],b[3:0],sum_dif[3:0],cin[0],g[0],p[0],add_sub);
				FA_4bits block1(a[7:4],b[7:4],sum_dif[7:4],cin[1],g[1],p[1],add_sub);
				FA_4bits block2(a[11:8],b[11:8],sum_dif[11:8],cin[2],g[2],p[2],add_sub);
				FA_4bits block3(a[15:12],b[15:12],sum_dif[15:12],cin[3],g[3],p[3],add_sub);
				
				carry_block_4bits CLA_4bits_1(cin[3:0],p[3:0],g[3:0],Cin[0],G[0],P[0]);// cout = g[3]; 'Cin[0]' entry for carry in 
//--------------------------------------------------------------------------------------------------------------------------------------------------		
				FA_4bits block4(a[19:16],b[19:16],sum_dif[19:16],cin[4],g[4],p[4],add_sub);
				FA_4bits block5(a[23:20],b[23:20],sum_dif[23:20],cin[5],g[5],p[5],add_sub);
				FA_4bits block6(a[27:24],b[27:24],sum_dif[27:24],cin[6],g[6],p[6],add_sub);
				FA_4bits block7(a[31:28],b[31:28],sum_dif[31:28],cin[7],g[7],p[7],add_sub);
				
				carry_block_4bits CLA_4bits_2(cin[7:4],p[7:4],g[7:4],Cin[1],G[1],P[1]);// cout = g[3];
				
				// 2 bits carry block top of the add/sub module.
				assign  Cin[0]  = carry_in ;
				assign  Cin[1]  = ( Cin[0] & P[0] ) | G[0] ; 
				assign  C 	 	 = ( Cin[1] & P[1] ) | G[1] ;
				//assign  P_ 		 = P[1] & P[0] ;
				assign V = C^g[6]; // overflow detection in signed integer when addition of two positive numbers gives a negative result 
			//	assign V = (~C)&g[6]; // overflow detection in signed integer when addition of two positive numbers gives a negative result or in reverse
//--------------------------------------------------------------------------------------------------------------------------------------------------					
		endmodule
//==================================================================================================================================================				
//==================================================================================================================================================
//==================================================================================================================================================
	
	module ALU(a,b,result,sel,V,C,Less,More,Even);// ALU unit main module
	
	input [31:0] 	a,b ;
	input [3:0] 	sel;
	wire 			add_sub,SAR_select;
	wire[31:0]	arithmetic, AND, OR, XOR, NOT, SLR, SLL, SAR;
	output [31:0] result;
	output V,C,Less,More,Even;
//--------------------------------------------------------------------------------------------------------------------------------------------------		
	//COMPARATOR OPERATION MODULE(instances)
//--------------------------------------------------------------------------------------------------------------------------------------------------
	Compare_module CMP_module_v1(a[31:0],b[31:0],Less,More,Even);
//--------------------------------------------------------------------------------------------------------------------------------------------------		
	//LOGICAL SHIFT LEFT AND RIGHT OPERATION MODULE(instances)
//--------------------------------------------------------------------------------------------------------------------------------------------------
	logic_shifter shift_module_v1(.in(a[31:0]),
											.scale(b[31:0]),
											.right_output(SLR[31:0]),
											.left_output(SLL[31:0]),
											.SAR_select(SAR_select)
											);
	assign SAR_select = (sel[3]) & (~sel[2]) & (~sel[1]) & (~sel[0]) & ~((~sel[3]) & (sel[2]) & (sel[1]) & (sel[0]));
	assign SAR[31:0] = SLL[31:0];
//--------------------------------------------------------------------------------------------------------------------------------------------------	
	//logic operations module
//--------------------------------------------------------------------------------------------------------------------------------------------------	
	assign  AND[31:0] = a[31:0] & b[31:0];
	assign  OR[31:0] = a[31:0] | b[31:0];
	assign  XOR[31:0] = a[31:0] ^ b[31:0];
	assign  NOT[31:0] = ~a[31:0]; 
//--------------------------------------------------------------------------------------------------------------------------------------------------
	//mode 0 and 1 arithmetic module (intances)
//--------------------------------------------------------------------------------------------------------------------------------------------------
	assign add_sub = (~sel[3]) & (~sel[2]) & (~sel[1]) & (sel[0]);
	
	FA_32bits 	FA_0 (a[31:0],
							b[31:0],
							arithmetic[31:0],
							add_sub,// this is for carry_in or add 1 into the sum-2's complement
							C,		//carry out
							V,		// overflow
							add_sub// this is for negating or flip the number 'b'-1's complement
						  );
	//assign 
//--------------------------------------------------------------------------------------------------------------------------------------------------
	// 32bits expanding using 1bits 16 to 1 Mux for 16 mode 32bits input/outputs
//--------------------------------------------------------------------------------------------------------------------------------------------------
	genvar i;
		generate
			for(i=0;i < 32 ; i++)
			begin: MUX_16_to_1_selecting_block
			mux_ALU_select_16_functions Mux_ALU_module 
			(
			.sel(sel[3:0]),
			.OUTput(result[i]),
			.addition(arithmetic[i]),
			.subtraction(arithmetic[i]),
			.and_logic(AND[i]),
			.or_logic(OR[i]),
			.xor_logic(XOR[i]),
			.not_logic(NOT[i]),
			.shiftL_logic(SLL[i]),
			.shiftR_logic(SLR[i]),
			.shiftR_arithmetic(SLR[i])
			);
		
		end
		endgenerate
//--------------------------------------------------------------------------------------------------------------------------------------------------	
	
//--------------------------------------------------------------------------------------------------------------------------------------------------	

		

//--------------------------------------------------------------------------------------------------------------------------------------------------		
	
	
	
	endmodule 