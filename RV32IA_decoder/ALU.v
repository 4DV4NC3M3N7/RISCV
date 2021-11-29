module ALU
(
    input   [31:0]      in_a,in_b,                          //data fed to ALU
    input   [3:0]       opt,                                //operation
    output  [31:0]      out,                                //output of ALU
    output              overflow_flag,pos_flag,neg_flag     //flags
);
wire        lo_left,lo_right,art_right,art_left,rot_right,rot_left,add_sub;





endmodule

module barrel_shifter
  (
    input   [31:0]      input_bit,
    input   [4:0]       shift_bit,
    input               lo_left,lo_right,art_right,art_left,rot_right,rot_left,
    output  [31:0]      output_bit
  );
  wire rot=rot_right|rot_left;
  wire left=lo_left|art_left|rot_left;
  reg [31:0] state_0,state_1,state_2,state_3,state_4,in,out;



  integer i;
  always @(*) begin

	for(i=0;i<32;i=i+1) begin
	in[i]=left?input_bit[31-i]:input_bit[i];
	end

	for(i=0;i<31;i=i+1) begin //state 0
	state_0[i]=shift_bit[0]?in[i+1]:in[i];
	end
	for(i=0;i<1;i=i+1) begin
	state_0[31-i]=shift_bit[0]?((in[0-i]&rot)|(art_right&input_bit[31])):in[31-i];
	end

	for(i=0;i < 30;i=i+1)begin //state 1
	state_1[i]=shift_bit[1]?state_0[i+2]:state_0[i];
	end
	for(i=0;i<2;i=i+1) begin
	state_1[31-i]=shift_bit[1]?((state_0[1-i]&rot)|(art_right&input_bit[31])):state_0[31-i];
	end

	for(i=0;i<28;i=i+1) begin //state 2
	state_2[i]=shift_bit[2]?state_1[i+4]:state_1[i];
	end
	for(i=0;i<4;i=i+1) begin
	state_2[31-i]=shift_bit[2]?((state_1[3-i]&rot)|(art_right&input_bit[31])):state_1[31-i];
	end

	for(i=0;i<24;i=i+1) begin //state 3
	state_3[i]=shift_bit[3]?state_2[i+8]:state_2[i];
	end
	for(i=0;i<8;i=i+1) begin
	state_3[31-i]=shift_bit[3]?((state_2[7-i]&rot)|(art_right&input_bit[31])):state_2[31-i];
	end

	for(i=0;i<16;i=i+1) begin //state 4
	state_4[i]=shift_bit[4]?state_3[i+16]:state_3[i];
	end
	for(i=0;i<16;i=i+1) begin
	state_4[31-i]=shift_bit[4]?((state_3[15-i]&rot)|(art_right&input_bit[31])):state_3[31-i];
	end

	for(i=0;i<32;i=i+1) begin
	out[i]=left?state_5[31-i]:state_5[i];
	end
  end

 assign output_bit=out;
endmodule

module select_adder
(
    input               add_sub,//add_sub= 0 => add , add_sub= 1 => sub
    input   [31:0]      a,b,
    output  [31:0]      s,
    output  reg         cout,overflow_flag,zero_flag,pos_flag,neg_flag
);
wire    [31:0]      b_temp;
wire    [31:0]      s_1,s_2;
wire    [7:0]       cout_stage_1, cout_stage_2;
wire    [7:0]       cout_temp;

assign b_temp=b^add_sub;


adder_4bits b0( .a(a[3:0]), .b(b_temp[3:0]), .cin(add_sub),
                .output_adder_4bits(s[3:0]), .cout(cout_temp[0]));

adder_4bits b1( .a(a[7:4]), .b(b_temp[7:4]), .cin(1'b0),
                .output_adder_4bits(s_1[7:4]), .cout(cout_stage_1[0]));

adder_4bits b2( .a(a[7:4]), .b(b_temp[7:4]), .cin(1'b1),
                .output_adder_4bits(s_2[7:4]), .cout(cout_stage_2[0]));

adder_4bits b3( .a(a[11:8]), .b(b_temp[11:8]), .cin(1'b0),
                .output_adder_4bits(s_1[11:8]), .cout(cout_stage_1[1]));

adder_4bits b4( .a(a[11:8]), .b(b_temp[11:8]), .cin(1'b1),
                .output_adder_4bits(s_2[11:8]), .cout(cout_stage_2[1]));

adder_4bits b5( .a(a[15:12]), .b(b_temp[15:12]), .cin(1'b0),
                .output_adder_4bits(s_1[15:12]), .cout(cout_stage_1[2]));

adder_4bits b6( .a(a[15:12]), .b(b_temp[15:12]), .cin(1'b1),
                .output_adder_4bits(s_2[15:12]), .cout(cout_stage_2[2]));

adder_4bits b7( .a(a[19:16]), .b(b_temp[19:16]), .cin(1'b0),
                .output_adder_4bits(s_1[19:16]), .cout(cout_stage_1[3]));

adder_4bits b8( .a(a[19:16]), .b(b_temp[19:16]), .cin(1'b1),
                .output_adder_4bits(s_2[19:16]), .cout(cout_stage_2[3]));

adder_4bits b9( .a(a[23:20]), .b(b_temp[23:20]), .cin(1'b0),
                .output_adder_4bits(s_1[23:20]), .cout(cout_stage_1[4]));

adder_4bits b10( .a(a[23:20]), .b(b_temp[23:20]), .cin(1'b1),
                 .output_adder_4bits(s_2[23:20]), .cout(cout_stage_2[4]));

adder_4bits b11( .a(a[27:24]), .b(b_temp[27:24]), .cin(1'b0),
                 .output_adder_4bits(s_1[27:24]), .cout(cout_stage_1[5]));

adder_4bits b12( .a(a[27:24]), .b(b_temp[27:24]), .cin(1'b1),
                 .output_adder_4bits(s_2[27:24]), .cout(cout_stage_2[5]));

adder_4bits b13( .a(a[31:28]), .b(b_temp[31:28]), .cin(1'b0),
                 .output_adder_4bits(s_1[31:28]), .cout(cout_stage_1[6]));

adder_4bits b14( .a(a[31:28]), .b(b_temp[31:28]), .cin(1'b1),
                 .output_adder_4bits(s_2[31:28]), .cout(cout_stage_2[6]));

assign s[7:4]=cout_temp[0]?(s_1[7:4]:s_2[7:4]);
assign cout_temp[1]=cout_temp[0]?(cout_stage_1[0]:cout_stage_2[0]);

assign s[11:8]=cout_temp[1]?(s_1[11:8]:s_2[11:8]);
assign cout_temp[2]=cout_temp[1]?(cout_stage_1[1]:cout_stage_2[1]);

assign s[15:12]=cout_temp[2]?(s_1[15:12]:s_2[15:12]);
assign cout_temp[3]=cout_temp[2]?(cout_stage_1[2]:cout_stage_2[2]);

assign s[19:16]=cout_temp[3]?(s_1[19:16]:s_2[19:16]);
assign cout_temp[4]=cout_temp[3]?(cout_stage_1[3]:cout_stage_2[3]);

assign s[23:20]=cout_temp[4]?(s_1[23:20]:s_2[23:20]);
assign cout_temp[5]=cout_temp[4]?(cout_stage_1[4]:cout_stage_2[4]);

assign s[27:24]=cout_temp[5]?(s_1[27:24]:s_2[27:24]);
assign cout_temp[6]=cout_temp[5]?(cout_stage_1[5]:cout_stage_2[5]);

assign s[31:28]=cout_temp[6]?(s_1[31:28]:s_2[31:28]);
assign cout_temp[7]=cout_temp[6]?(cout_stage_1[6]:cout_stage_2[6]);

assign cout=cout_temp[7];

always @ (posedge clk) begin
if(reset) begin
     zero_flag<=1'b0;
     neg_flag <=1'b0;
     pos_flag <=1'b0;
     overflow_flag <=1'b0;
end
else begin
	 zero_flag<=!s;
	 neg_flag<=s[31]&(!zero_flag);
	 pos_flag<=(!s[31])&(!zero_flag);
	 overflow_flag<=(s[31]^(!(a[31]^b_temp[31])));
end
end

endmodule


module adder_4bits
(
    input   [3:0]      a,b,
    input              cin,
    output  [3:0]      output_adder_4bits
    output             cout
);
wire    [3:0]      cout_temp;

full_adder a0( .a(a[0]), .b(b[0]), .cin(cin),
               .s(output_adder_4bits[0]), .cout(cout_temp[0]));

full_adder a1( .a(a[1]), .b(b[1]), .cin(cout_temp[0]),
               .s(output_adder_4bits[1]), .cout(cout_temp[1]));

full_adder a2( .a(a[2]), .b(b[2]), .cin(cout_temp[1]),
               .s(output_adder_4bits[2]), .cout(cout_temp[2]));

full_adder a3( .a(a[3]), .b(b[3]), .cin(cout_temp[2]),
               .s(output_adder_4bits[3]), .cout(cout_temp[3]));
assign cout=cout_temp[3];

endmodule

module full_adder
(
    input               a,b,cin,
    output              s,cout
);

s=cin^(a^b);
cout=cin&(a^b)|(a&b);

endmodule
