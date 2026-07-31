`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.03.2026 20:03:21
// Design Name: 
// Module Name: img_2d_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module img_2d_tb( );
   reg clk,clkb,rst;
reg [7:0]in;

wire [31:0]out;
wire wen1,wen2,wen3;
wire [7:0]addr;
wire  [7:0] b1_out, b2_out, b3_out;
wire [3:0]state;
wire [7:0] shifting_count;
wire valid_in,done_store,write;

integer file_in,file_out;
integer status;    
    
    img_2d DUT(clk,clkb,rst,in,out, wen1,wen2,wen3,addr,b1_out, b2_out, b3_out,state,shifting_count, valid_in,done_store,write);
    always #5 clk=~clk;
    initial begin
        clk=0;
        clkb = 0;
        #2.5;
        forever #2.5 clkb = ~clkb;
    end
    
   
    
    initial begin
        
        rst=1;
        file_in=$fopen("C:\\Users\\likhi\\cameraman.txt","r");
        file_out = $fopen("C:\\Users\\likhi\\out_blur.txt","w");

        if(file_in == 0) begin
            $display("File not opened");
            $finish;
        end
       #20;
       rst=0;
       
    end
    initial begin
    #6001000;
    $fflush(file_out);
    $fclose(file_out);
    $finish;
end
     
   always @(posedge clk) begin

    if(rst) begin
        in <= 0;
        
    end
    
    else begin
        
        if(!$feof(file_in) && valid_in) begin
            status = $fscanf(file_in,"%d", in);
        end
        
       
        else begin
            in<=0;
        end      
                
    end   

    end 
    always @(posedge clk) begin
        if(write) begin
            $fwrite(file_out,"%d \n", out);
            $display("%d",out);
        end
    end     
    
    
endmodule

