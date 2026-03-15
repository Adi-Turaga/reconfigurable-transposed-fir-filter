`timescale 1ns / 1ps

module tb_noise();

    parameter NUM_TAPS = 128;       // number of coefficients
    //parameter FILE_NUMBER = 368;    // file numbers (368, 624, 728)
    
    int file_list[3] = {368, 624, 728};
    
    logic clk = 0, en, rst;
    logic signed [15:0] input_signal;
    logic signed [15:0] data[300];
    logic signed [31:0] output_signal;
    logic signed [39:0] acc;
    logic [1:0] flt_type;
    
    fir_filter #(.TAPS(NUM_TAPS)) UUT (
        .clk(clk), .en(en), .rst(rst), .flt_type(flt_type),
        .x(input_signal), .y(output_signal)
    );
    
    integer k;      // counter for loop
    integer FILE1;  // file for filtered data
    
    always #10 clk = ~clk;
    
    task automatic run_filter_test(int file_id, logic [1:0] filter);
        string input_filename, output_filename, filter_t;
        int fid;
        
        case (filter)
            2'b00: filter_t = "LP";
            2'b01: filter_t = "HP";
            2'b10: filter_t = "BP";
            2'b11: filter_t = "BS";
            default: filter_t = "XX";
        endcase      
        
        input_filename  = $sformatf("wave_randn_%0d.txt", file_id);
        output_filename = $sformatf("output_randn_%0d_%s.txt", file_id, filter_t);
        
        $display("----- STARTING TEST: FILE %0d, FILTER: %s -----", file_id, filter_t);
        $readmemh(input_filename, data);
        
        fid = $fopen(output_filename, "w");
        if (!fid) begin
            $display("FATAL: Could not open %s", output_filename);
            disable run_filter_test; 
        end
        
        @(posedge clk);
        rst = 1; en = 0; flt_type = filter;
        repeat(5) @(posedge clk);
        rst = 0; en = 1;
        
        for(int i = 0; i < 300; i++) begin
            //@(negedge clk);
            input_signal = data[i];
            @(posedge clk);
            //#1;
            $fdisplay(fid, "%h", output_signal);
        end
        
        $fclose(fid);
        $display("----- Finished Test: %s generated -----", output_filename);
             
    endtask
    
    initial begin
        foreach(file_list[i]) begin
            run_filter_test(file_list[i], 2'b00);
            run_filter_test(file_list[i], 2'b01);
            run_filter_test(file_list[i], 2'b10);
            run_filter_test(file_list[i], 2'b11);
        end    
        $display("All tests completed successfully.");
        $finish;
    end

endmodule
