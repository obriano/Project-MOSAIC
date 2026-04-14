module timestamp (
    input clk,rst, // clock and reset
    output reg [63:0] time_counter // counting register
);
//counter with asynchronous reset
  always @(posedge clk or posedge rst) begin
    if (rst)
    time_counter <= 64'd0;
    else
    time_counter <= time_counter + 64'd1;
  end  
endmodule
