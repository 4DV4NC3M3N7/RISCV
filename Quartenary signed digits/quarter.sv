
//==================================================================================================================================================				
//==================================================================================================================================================
//==================================================================================================================================================

module Register_32bits_cell(Q,D,clear,clk,enable);
		input [31:0]D;
		input clear,enable,clk;
		reg [31:0] q;
		output [31:0] Q;
		genvar i;
		generate 
		for(i=0;i<32;i++)
		begin: d_ff_block
		always @ ( posedge clk or negedge clear )
			begin
				if(!clear)
					q[i] <= 1'b0;
				else 
					q[i] <= D[i];
			end
			
		bufif1 TB(Q[i],q[i],enable);
		end
		endgenerate 
		
endmodule
//==================================================================================================================================================				
//==================================================================================================================================================
//==================================================================================================================================================
		//decoder 5bits
		module decoder_5bits(sel,out_put);
		input [4:0]sel;
		output [31:0]out_put;
		
					assign out_put[0]=~sel[4]&~sel[3]&~sel[2]&~sel[1]&~sel[0];
					assign out_put[1]=~sel[4]&~sel[3]&~sel[2]&~sel[1]&sel[0];
					assign out_put[2]=~sel[4]&~sel[3]&~sel[2]&sel[1]&~sel[0];
					assign out_put[3]=~sel[4]&~sel[3]&~sel[2]&sel[1]&sel[0];
					assign out_put[4]=~sel[4]&~sel[3]&sel[2]&~sel[1]&~sel[0];
					assign out_put[5]=~sel[4]&~sel[3]&sel[2]&~sel[1]&sel[0];
					assign out_put[6]=~sel[4]&~sel[3]&sel[2]&sel[1]&~sel[0];
					assign out_put[7]=~sel[4]&~sel[3]&sel[2]&sel[1]&sel[0];
					assign out_put[8]=~sel[4]&sel[3]&~sel[2]&~sel[1]&~sel[0];
					assign out_put[9]=~sel[4]&sel[3]&~sel[2]&~sel[1]&sel[0];
					assign out_put[10]=~sel[4]&sel[3]&~sel[2]&sel[1]&~sel[0];
					assign out_put[11]=~sel[4]&sel[3]&~sel[2]&sel[1]&sel[0];
					assign out_put[12]=~sel[4]&sel[3]&sel[2]&~sel[1]&~sel[0];
					assign out_put[13]=~sel[4]&sel[3]&sel[2]&~sel[1]&sel[0];
					assign out_put[14]=~sel[4]&sel[3]&sel[2]&sel[1]&~sel[0];
					assign out_put[15]=~sel[4]&sel[3]&sel[2]&sel[1]&sel[0];
					assign out_put[16]=sel[4]&~sel[3]&~sel[2]&~sel[1]&~sel[0];
					assign out_put[17]=sel[4]&~sel[3]&~sel[2]&~sel[1]&sel[0];
					assign out_put[18]=sel[4]&~sel[3]&~sel[2]&sel[1]&~sel[0];
					assign out_put[19]=sel[4]&~sel[3]&~sel[2]&sel[1]&sel[0];
					assign out_put[20]=sel[4]&~sel[3]&sel[2]&~sel[1]&~sel[0];
					assign out_put[21]=sel[4]&~sel[3]&sel[2]&~sel[1]&sel[0];
					assign out_put[22]=sel[4]&~sel[3]&sel[2]&sel[1]&~sel[0];
					assign out_put[23]=sel[4]&~sel[3]&sel[2]&sel[1]&sel[0];
					assign out_put[24]=sel[4]&sel[3]&~sel[2]&~sel[1]&~sel[0];
					assign out_put[25]=sel[4]&sel[3]&~sel[2]&~sel[1]&sel[0];
					assign out_put[26]=sel[4]&sel[3]&~sel[2]&sel[1]&~sel[0];
					assign out_put[27]=sel[4]&sel[3]&~sel[2]&sel[1]&sel[0];
					assign out_put[28]=sel[4]&sel[3]&sel[2]&~sel[1]&~sel[0];
					assign out_put[29]=sel[4]&sel[3]&sel[2]&~sel[1]&sel[0];
					assign out_put[30]=sel[4]&sel[3]&sel[2]&sel[1]&~sel[0];
					assign out_put[31]=sel[4]&sel[3]&sel[2]&sel[1]&sel[0];
					
		endmodule
//==================================================================================================================================================				
//==================================================================================================================================================
//==================================================================================================================================================
		//mux 32 bits in width and 32 line to 1 line
		module MUX_32x32bits(in_put,sel,final_out);
		input [4:0]sel;
		input [31:0] in_put;
		wire [31:0]out_put;
		output final_out;
		
					assign out_put[0]=in_put[0]&~sel[4]&~sel[3]&~sel[2]&~sel[1]&~sel[0];
					assign out_put[1]=in_put[1]&~sel[4]&~sel[3]&~sel[2]&~sel[1]&sel[0];
					assign out_put[2]=in_put[2]&~sel[4]&~sel[3]&~sel[2]&sel[1]&~sel[0];
					assign out_put[3]=in_put[3]&~sel[4]&~sel[3]&~sel[2]&sel[1]&sel[0];
					assign out_put[4]=in_put[4]&~sel[4]&~sel[3]&sel[2]&~sel[1]&~sel[0];
					assign out_put[5]=in_put[5]&~sel[4]&~sel[3]&sel[2]&~sel[1]&sel[0];
					assign out_put[6]=in_put[6]&~sel[4]&~sel[3]&sel[2]&sel[1]&~sel[0];
					assign out_put[7]=in_put[7]&~sel[4]&~sel[3]&sel[2]&sel[1]&sel[0];
					assign out_put[8]=in_put[8]&~sel[4]&sel[3]&~sel[2]&~sel[1]&~sel[0];
					assign out_put[9]=in_put[9]&~sel[4]&sel[3]&~sel[2]&~sel[1]&sel[0];
					assign out_put[10]=in_put[10]&~sel[4]&sel[3]&~sel[2]&sel[1]&~sel[0];
					assign out_put[11]=in_put[11]&~sel[4]&sel[3]&~sel[2]&sel[1]&sel[0];
					assign out_put[12]=in_put[12]&~sel[4]&sel[3]&sel[2]&~sel[1]&~sel[0];
					assign out_put[13]=in_put[13]&~sel[4]&sel[3]&sel[2]&~sel[1]&sel[0];
					assign out_put[14]=in_put[14]&~sel[4]&sel[3]&sel[2]&sel[1]&~sel[0];
					assign out_put[15]=in_put[15]&sel[4]&sel[3]&sel[2]&sel[1]&sel[0];
					assign out_put[16]=in_put[16]&sel[4]&~sel[3]&~sel[2]&~sel[1]&~sel[0];
					assign out_put[17]=in_put[17]&sel[4]&~sel[3]&~sel[2]&~sel[1]&sel[0];
					assign out_put[18]=in_put[18]&sel[4]&~sel[3]&~sel[2]&sel[1]&~sel[0];
					assign out_put[19]=in_put[19]&sel[4]&~sel[3]&~sel[2]&sel[1]&sel[0];
					assign out_put[20]=in_put[20]&sel[4]&~sel[3]&sel[2]&~sel[1]&~sel[0];
					assign out_put[21]=in_put[21]&sel[4]&~sel[3]&sel[2]&~sel[1]&sel[0];
					assign out_put[22]=in_put[22]&sel[4]&~sel[3]&sel[2]&sel[1]&~sel[0];
					assign out_put[23]=in_put[23]&sel[4]&~sel[3]&sel[2]&sel[1]&sel[0];
					assign out_put[24]=in_put[24]&sel[4]&sel[3]&~sel[2]&~sel[1]&~sel[0];
					assign out_put[25]=in_put[25]&sel[4]&sel[3]&~sel[2]&~sel[1]&sel[0];
					assign out_put[26]=in_put[26]&sel[4]&sel[3]&~sel[2]&sel[1]&~sel[0];
					assign out_put[27]=in_put[27]&sel[4]&sel[3]&~sel[2]&sel[1]&sel[0];
					assign out_put[28]=in_put[28]&sel[4]&sel[3]&sel[2]&~sel[1]&~sel[0];
					assign out_put[29]=in_put[29]&sel[4]&sel[3]&sel[2]&~sel[1]&sel[0];
					assign out_put[30]=in_put[30]&sel[4]&sel[3]&sel[2]&sel[1]&~sel[0];
					assign out_put[31]=in_put[31]&sel[4]&sel[3]&sel[2]&sel[1]&sel[0];
					
			assign final_out = 	 out_put[0]|out_put[1]|out_put[2]|out_put[3]|out_put[4]|out_put[5]|out_put[6]|out_put[7]
										|out_put[8]|out_put[9]|out_put[10]|out_put[11]|out_put[12]|out_put[13]|out_put[14]|out_put[15]
										|out_put[16]|out_put[17]|out_put[18]|out_put[19]|out_put[20]|out_put[21]|out_put[22]|out_put[23]
										|out_put[24]|out_put[25]|out_put[26]|out_put[27]|out_put[28]|out_put[29]|out_put[30]|out_put[31];	
		endmodule
//==================================================================================================================================================				
//==================================================================================================================================================
//==================================================================================================================================================

module quarter(RR1,RR2,WR,WD,RD1,RD2,write);   //Register_file
//--------------------------------------------------------------------------------------------------------------------------------------------------					
	input  [4:0] WR,RR1,RR2; //write register, read register 1, read register 2
	input  [31:0]WD; //write data
	input write;
	wire  [31:0]RC,WC ; //register choosing,write clock 
	output [31:0] RD1,RD2; //read data 1 ,read data 2
	wire [31:0][31:0] d,to_mux;
//--------------------------------------------------------------------------------------------------------------------------------------------------					
		//decoder stage
//--------------------------------------------------------------------------------------------------------------------------------------------------					
			decoder_5bits decoder_v1(.sel(WR),.out_put(RC[31:0]));
//--------------------------------------------------------------------------------------------------------------------------------------------------								
			genvar i,j;
			generate
			for(i=0;i<32;i++)
				begin: register_32bits_wide_cluster
						Register_32bits_cell cell_(.Q(d[i][31:0]),.D(WD[31:0]),.clear(1'b1),.clk(WC[i]),.enable(1'b1));
						assign WC[i] = RC[i] & write;	
				end
					
					//assign to_mux[i][j]={d[j][0],} 
					
			
							for(i=0;i<32;i++)
								begin: width 
								assign to_mux[i][31:0]={d[31][i],d[30][i],d[29][i],d[28][i],d[27][i],d[26][i],d[25][i],d[24][i],
																d[23][i],d[22][i],d[21][i],d[20][i],d[19][i],d[18][i],d[17][i],d[16][i],
																d[15][i],d[14][i],d[13][i],d[12][i],d[11][i],d[10][i],d[9][i],d[8][i],
																d[7][i],d[6][i],d[5][i],d[4][i],d[3][i],d[2][i],d[1][i],d[0][i]};
																
										MUX_32x32bits mux1(.in_put(to_mux[i][31:0]),.sel(RR1),.final_out(RD1[i]));
										MUX_32x32bits mux2(.in_put(to_mux[i][31:0]),.sel(RR2),.final_out(RD2[i]));						
								end	
						
		
				
			endgenerate
			
//--------------------------------------------------------------------------------------------------------------------------------------------------					
endmodule 