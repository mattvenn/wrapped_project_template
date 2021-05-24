module dump();
    initial begin
        $dumpfile ("wrapper.vcd");
        $dumpvars (0, wrapped_memLCDdriver);
        #1;
    end
endmodule
