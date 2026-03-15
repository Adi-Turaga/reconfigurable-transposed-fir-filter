`timescale 1ns / 1ps

module round_sat(
    input signed [39:0] acc,
    output reg signed [31:0] y_out
    );
    
    parameter signed SAT_MAX = 32'h7FFFFFFF;
    parameter signed SAT_MIN = 32'h80000000;
    
    reg signed [39:0] y_tmp;
    
    always @ (*) begin
        y_tmp = (acc >= 0) ? ((acc + (40'sd1 <<< 14)) >>> 15)
                             : ((acc - (40'sd1 <<< 14)) >>> 15);
        
        if(y_tmp > SAT_MAX) y_out = SAT_MAX;
        else if(y_tmp < SAT_MIN) y_out = SAT_MIN;
        else y_out = y_tmp[31:0];
    end
    
endmodule
