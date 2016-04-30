		
`timescale 1ns / 1ps
module GCD(CLK,BTNC,BTNL,BTNR,BTNU,SW,LED,C,AN);
input  CLK, BTNC, BTNL, BTNR, BTNU;
input [15:0] SW;
output reg [15:0] LED;
output [6:0] C;
output [7:0] AN;
reg in_disp,o_disp;
wire clkslow;
reg [2:0] nstate;
reg [15:0] n1,n2,out;
//reg clkorig;

always @ (posedge CLK) begin
    if(BTNC==1) begin
        LED<=0;
        in_disp<=0; 
        nstate<=0; 
        o_disp<=0;
        n1<=0; n2<=0; out<=0;      
    end
    else begin
        case(nstate)
            3'd0: begin
                    LED<=SW;
                    in_disp<=1;
                    nstate<=3'd1;
                    o_disp<=0;
                  end
            3'd1: begin
                    LED<=SW;    
                    if(BTNL==1) begin  n1<=SW; in_disp<=1; o_disp<=0; nstate<=3'd2; end
                    else nstate<=3'd1;
                  end
            3'd2: begin
                    LED<=SW;
                    if(BTNR==1) begin  n2<=SW; in_disp<=1; o_disp<=0; nstate<=3'd3; end
                    else nstate<=3'd2;
                  end
            3'd3: begin
                    LED<=0;
                    if(BTNU==1) begin  out<=n1+n2; o_disp<=1; in_disp<=0;  nstate<=3'd4; end
                    else nstate<=3'd3;
                  end
            default: nstate<=3'd0;
        endcase
    end
end
//---------------------module clock_div(clk_in,rst,clk_out);
    clock_div cd1(.clk_in(CLK),.rst(in_disp),.clk_out(clkslow));
//---------------------module seg_disp(clk,in1,in2,disp,odisp,c,an);
    seg_disp s1(.clk(clkslow),.in1(LED),.in2(out),.disp(in_disp),.odisp(o_disp),.c(C),.an(AN));
    
endmodule

module seg_disp(clk,in1,in2,disp,odisp,c,an);
input clk,disp,odisp;
input [15:0] in1,in2;
output reg [6:0] c;
output reg [7:0] an;
reg [2:0] state1,state2;
wire [6:0] c1,c2,c3,c4,c5,c6,c7,c8;
always @ (posedge clk) begin
    if(disp==0) begin
        c<=7'b1000000;
        an<=8'b11101111;
        state1<=3'd0;
        state2<=3'd0;
    end
    if(disp==1) begin
        case(state1)
            3'd0:   begin   an<=8'b11111110;    c<=c1;  state1<=3'd1;    end
            3'd1:   begin   an<=8'b11111101;    c<=c2;  state1<=3'd2;    end
            3'd2:   begin   an<=8'b11111011;    c<=c3;  state1<=3'd3;    end
            3'd3:   begin   an<=8'b11110111;    c<=c4;  state1<=3'd4;    end
            3'd4:   begin   an<=8'b10111111;    c<=7'b0011000;  state1<=3'd5;    end
            3'd5:   begin   an<=8'b01111111;    c<=7'b1001111;  state1<=3'd6;    end
            3'd6:   begin   an<=8'b11011111;    c<=7'b0111111;  state1<=3'd0;    end
            default:    state1<=2'd0;
        endcase
    end
    if(odisp==1) begin
        case(state2)
            3'd0:   begin   an<=8'b11111110;    c<=c5;  state2<=3'd1;    end
            3'd1:   begin   an<=8'b11111101;    c<=c6;  state2<=3'd2;    end
            3'd2:   begin   an<=8'b11111011;    c<=c7;  state2<=3'd3;    end
            3'd3:   begin   an<=8'b11110111;    c<=c8;  state2<=3'd4;    end
            3'd4:   begin   an<=8'b10111111;    c<=7'b0011000;  state2<=3'd5;    end
            3'd5:   begin   an<=8'b01111111;    c<=7'b1000000;  state2<=3'd6;    end
            3'd6:   begin   an<=8'b11011111;    c<=7'b0111111;  state2<=3'd0;    end            
            default:    state2<=2'd0;
        endcase
    end
    else an<=8'b11101111;
end
    //--------convert (clk,in,digit)
    convert ca(.clk(clk),.in(in1[3:0]),.digit(c1));
    convert cb(.clk(clk),.in(in1[7:4]),.digit(c2));
    convert cc(.clk(clk),.in(in1[11:8]),.digit(c3));
    convert cd(.clk(clk),.in(in1[15:12]),.digit(c4));
    convert ce(.clk(clk),.in(in2[3:0]),.digit(c5));
    convert cf(.clk(clk),.in(in2[7:4]),.digit(c6));
    convert cg(.clk(clk),.in(in2[11:8]),.digit(c7));
    convert ch(.clk(clk),.in(in2[15:12]),.digit(c8));
endmodule



module clock_div(clk_in,rst,clk_out);
input clk_in, rst;
output wire clk_out;
reg [14:0] count;
always @ (posedge clk_in) begin
    if(rst==0) begin
        count=0;
    end
    else begin
        count=count+1;
    end
end
assign clk_out=count[14];
endmodule

module convert (clk,in,digit);
input clk;
input [3:0] in;
output reg [6:0] digit;
always @ (posedge clk) begin
    case(in)
        4'd0    : digit = 7'b1000000;
        4'd1    : digit = 7'b1111001;
        4'd2    : digit = 7'b0100100;
        4'd3    : digit = 7'b0110000;
        4'd4    : digit = 7'b0011001;
        4'd5    : digit = 7'b0010010;
        4'd6    : digit = 7'b0000010;
        4'd7    : digit = 7'b1111000;
        4'd8    : digit = 7'b0000000;
        4'd9    : digit = 7'b0010000;
        4'd10   : digit = 7'b0001000;
        4'd11   : digit = 7'b0000011;
        4'd12   : digit = 7'b1000110;
        4'd13   : digit = 7'b0100001;
        4'd14   : digit = 7'b0000110;
        4'd15   : digit = 7'b0001110;
        default : digit = 7'b1111111;
    endcase
end
endmodule
