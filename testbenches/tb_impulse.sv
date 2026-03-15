`timescale 1ns / 1ps

module tb_impulse();

    parameter NUM_TAPS = 128;       // number of coefficients
    
    reg clk = 0, en, rst;
    reg signed [15:0] input_signal;
    reg signed [15:0] data[299:0];
    wire signed [31:0] output_signal;
    reg [1:0] flt_type;
    
    fir_filter #(.TAPS(NUM_TAPS)) UUT_IMPULSE (
        .clk(clk), .en(en), .rst(rst), .flt_type(flt_type),
        .x(input_signal), .y(output_signal)
    );
    
    integer k;      // counter for loop
    integer FILE1;  // file for filtered data
    
    reg [8*32-1:0] output_filename;
    
    always #10 clk = ~clk;
    
    integer s, cs;
    initial begin
        k = 0;
        
        $readmemh("impulse.txt", data);
        $sformat(output_filename, "output_impulse_BS.txt"); // format output data filename
        FILE1 = $fopen(output_filename, "w"); // open output file

        if (FILE1 == 0) begin
            $display("ERROR: cannot open output file for writing.");
            $finish;
        end
        
        clk = 0;
        #20;
        rst = 1'b1;
        en = 1'b0;
        #40;
        
        rst = 1'b0;
        en = 1'b1;
        flt_type <= 2'b11; // setting the filter mode
        input_signal <= data[k];
        #10;
        
        for(k = 1; k < 299; k = k + 1) begin
            input_signal <= data[k];
            @(posedge clk);
            $fdisplay(FILE1, "%h", output_signal);
            
        end 
        
        $fclose(FILE1);
        $finish;
        
    end
endmodule
