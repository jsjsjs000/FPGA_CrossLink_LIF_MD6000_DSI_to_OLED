
task I2C_WAIT;
    begin
        #THSD;
    end
endtask // I2C_WAIT

task I2C_TXSTART;
    begin

        I2C_WAIT;
        scl_tb <= 1'b1;
        I2C_WAIT;
        sda_tb <= 1'b1;
        I2C_WAIT;
        sda_tb <= 1'b0;
        I2C_WAIT;
        scl_tb <= 1'b0;
        I2C_WAIT;
        sda_tb <= 1'b1;
        I2C_WAIT;
    end
endtask // I2C_TXSTART

task I2C_TXSTOP;
    begin
        I2C_WAIT;
        sda_tb <= 1'b0;
        I2C_WAIT;
        scl_tb <= 1'b1;
        I2C_WAIT;
        sda_tb <= 1'b1;
        I2C_WAIT;
    end
endtask // I2C_TXSTOP

task I2C_TXACK;
    begin
        I2C_WAIT;
        sda_tb <= 1'b0;
        I2C_WAIT;
        scl_tb <= 1'b1;
        I2C_WAIT;
        scl_tb <= 1'b0;
        I2C_WAIT;
        sda_tb <= 1'bZ;
        I2C_WAIT;
    end
endtask // I2C_TXACK

task I2C_TXNACK;
    begin
        I2C_WAIT;
        sda_tb <= 1'b1;
        I2C_WAIT;
        scl_tb <= 1'b1;
        I2C_WAIT;
        scl_tb <= 1'b0;
        I2C_WAIT;
        sda_tb <= 1'bZ;
        I2C_WAIT;
    end
endtask // I2C_TXNACK

task I2C_RXACK;
    begin
        I2C_WAIT;
        sda_tb <= 1'b0;
        I2C_WAIT;
        while (sda != 1'b0)
            begin
                I2C_WAIT;
            end // while (sda_tb != 1'b0)
        I2C_WAIT;
        scl_tb <= 1'b1;
        I2C_WAIT;
        I2C_WAIT;
        scl_tb <= 1'b0;
        sda_tb <= 1'bZ;
        I2C_WAIT;
    end
endtask // I2C_RXACK


task I2C_TXBYTE;
    input [7:0] txbyte;
    begin
        // bit 7
        I2C_WAIT;
        sda_tb <= txbyte[7];
        I2C_WAIT;
        scl_tb <= 1'b1;
        I2C_WAIT;
        I2C_WAIT;
        scl_tb <= 1'b0;
        // bit 6
        I2C_WAIT;
        sda_tb <= txbyte[6];
        I2C_WAIT;
        scl_tb <= 1'b1;
        I2C_WAIT;
        I2C_WAIT;
        scl_tb <= 1'b0;
        // bit 5
        I2C_WAIT;
        sda_tb <= txbyte[5];
        I2C_WAIT;
        scl_tb <= 1'b1;
        I2C_WAIT;
        I2C_WAIT;
        scl_tb <= 1'b0;
        // bit 4
        I2C_WAIT;
        sda_tb <= txbyte[4];
        I2C_WAIT;
        scl_tb <= 1'b1;
        I2C_WAIT;
        I2C_WAIT;
        scl_tb <= 1'b0;
        // bit 3
        I2C_WAIT;
        sda_tb <= txbyte[3];
        I2C_WAIT;
        scl_tb <= 1'b1;
        I2C_WAIT;
        I2C_WAIT;
        scl_tb <= 1'b0;
        // bit 2
        I2C_WAIT;
        sda_tb <= txbyte[2];
        I2C_WAIT;
        scl_tb <= 1'b1;
        I2C_WAIT;
        I2C_WAIT;
        scl_tb <= 1'b0;
        // bit 1
        I2C_WAIT;
        sda_tb <= txbyte[1];
        I2C_WAIT;
        scl_tb <= 1'b1;
        I2C_WAIT;
        I2C_WAIT;
        scl_tb <= 1'b0;
        // bit 0
        I2C_WAIT;
        sda_tb <= txbyte[0];
        I2C_WAIT;
        I2C_WAIT;
        scl_tb <= 1'b1;
        I2C_WAIT;
        I2C_WAIT;
        scl_tb <= 1'b0;
        // done
        I2C_WAIT;
        sda_tb <= 1'bZ;
        I2C_WAIT;
        I2C_WAIT;
    end
endtask // I2C_TXBYTE

task I2C_RXBYTE;
    output [7:0] RxData_i;
    begin
        RxData_i <= 8'b11111111;
        // bit 7
        I2C_WAIT;
        scl_tb <= 1'b1;
	sda_tb <= 1'bZ;
        if (sda == 1'b0) RxData_i[7] <= 1'b0;
        I2C_WAIT;
        I2C_WAIT;
        scl_tb <= 1'b0;
        I2C_WAIT;
        // bit 6
        I2C_WAIT;
        scl_tb <= 1'b1;
        if (sda == 1'b0) RxData_i[6] <= 1'b0;
        I2C_WAIT;
        I2C_WAIT;
        scl_tb <= 1'b0;
        I2C_WAIT;
        // bit 5
        I2C_WAIT;
        scl_tb <= 1'b1;
        if (sda == 1'b0) RxData_i[5] <= 1'b0;
        I2C_WAIT;
        I2C_WAIT;
        scl_tb <= 1'b0;
        I2C_WAIT;
        // bit 4
        I2C_WAIT;
        scl_tb <= 1'b1;
        if (sda == 1'b0) RxData_i[4] <= 1'b0;
        I2C_WAIT;
        I2C_WAIT;
        scl_tb <= 1'b0;
        I2C_WAIT;
        // bit 3
        I2C_WAIT;
        scl_tb <= 1'b1;
        if (sda == 1'b0) RxData_i[3] <= 1'b0;
        I2C_WAIT;
        I2C_WAIT;
        scl_tb <= 1'b0;
        I2C_WAIT;
        // bit 2
        I2C_WAIT;
        scl_tb <= 1'b1;
        if (sda == 1'b0) RxData_i[2] <= 1'b0;
        I2C_WAIT;
        I2C_WAIT;
        scl_tb <= 1'b0;
        I2C_WAIT;
        // bit 1
        I2C_WAIT;
        scl_tb <= 1'b1;
        if (sda == 1'b0) RxData_i[1] <= 1'b0;
        I2C_WAIT;
        I2C_WAIT;
        scl_tb <= 1'b0;
        I2C_WAIT;
        // bit 0
        I2C_WAIT;
        scl_tb <= 1'b1;
        if (sda == 1'b0) RxData_i[0] <= 1'b0;
        I2C_WAIT;
        I2C_WAIT;
        scl_tb <= 1'b0;
        I2C_WAIT;
        // done
        I2C_WAIT;
        sda_tb <= 1'bZ;
        I2C_WAIT;
    end
endtask // I2C_RXBYTE

task I2C_REG_WR;
    input [7:0] regaddr;
    input [15:0] regdata;
    begin
        I2C_TXSTART;
        I2C_TXBYTE({SLAVE_ADDR[6:0],1'b0});
        I2C_RXACK;
        I2C_TXBYTE(regaddr);
        I2C_RXACK;
        I2C_TXBYTE(regdata[7:0]);
        I2C_RXACK;
        I2C_TXBYTE(regdata[15:8]);
        I2C_RXACK;
        I2C_TXSTOP;
    end
endtask // I2C_WRITE


task I2C_REG_RD;
    input [7:0] regaddr;
    output [15:0] rd_data;
    begin
        I2C_TXSTART;
        I2C_TXBYTE({SLAVE_ADDR[6:0],1'b0});
        I2C_RXACK;
        I2C_TXBYTE(regaddr);
        I2C_RXACK;
        I2C_TXSTOP;

        I2C_TXSTART;
        I2C_TXBYTE({SLAVE_ADDR[6:0],1'b1});
        I2C_RXACK;
        I2C_RXBYTE(rd_data[7:0]);
        I2C_TXACK;
        I2C_RXBYTE(rd_data[15:8]);
        I2C_TXNACK;
        I2C_TXSTOP;
    end
endtask // I2C_READ

///// added by MT ///////////////////////////////
task I2C_REG_WR_MULTI;
	input [3:0] num_byte;
    input [7:0] regaddr;
    input [127:0] regdata;
	integer bc;
    begin
        I2C_TXSTART;
        I2C_TXBYTE({SLAVE_ADDR[6:0],1'b0});
        I2C_RXACK;
        I2C_TXBYTE(regaddr);
        I2C_RXACK;
		for (bc=0; bc<num_byte; bc=bc+1) begin
			case (bc)
				0 : I2C_TXBYTE(regdata[7:0]); 
				1 : I2C_TXBYTE(regdata[15:8]); 
				2 : I2C_TXBYTE(regdata[23:16]); 
				3 : I2C_TXBYTE(regdata[31:24]); 
				4 : I2C_TXBYTE(regdata[39:32]); 
				5 : I2C_TXBYTE(regdata[47:40]); 
				6 : I2C_TXBYTE(regdata[55:48]); 
				7 : I2C_TXBYTE(regdata[63:56]); 
				8 : I2C_TXBYTE(regdata[71:64]); 
				9 : I2C_TXBYTE(regdata[79:72]); 
				10 : I2C_TXBYTE(regdata[87:80]); 
				11 : I2C_TXBYTE(regdata[95:88]); 
				12 : I2C_TXBYTE(regdata[103:96]); 
				13 : I2C_TXBYTE(regdata[111:104]); 
				14 : I2C_TXBYTE(regdata[119:112]); 
				15 : I2C_TXBYTE(regdata[127:120]); 
//        	I2C_TXBYTE(regdata[bc*8+7:bc*8]);
        	endcase
        	I2C_RXACK;
		end
        I2C_TXSTOP;
    end
endtask // I2C_WRITE

task I2C_REG_RD_MULTI;
	input [3:0] num_byte;
    input [7:0] regaddr;
    output [127:0] rd_data;
	integer bc;
    begin
        I2C_TXSTART;
        I2C_TXBYTE({SLAVE_ADDR[6:0],1'b0});
        I2C_RXACK;
        I2C_TXBYTE(regaddr);
        I2C_RXACK;
//        I2C_TXSTOP;

        I2C_TXSTART;
        I2C_TXBYTE({SLAVE_ADDR[6:0],1'b1});
        I2C_RXACK;
		for (bc=0; bc<num_byte; bc=bc+1) begin
			case (bc)
				0 : I2C_RXBYTE(rd_data[7:0]); 
				1 : I2C_RXBYTE(rd_data[15:8]); 
				2 : I2C_RXBYTE(rd_data[23:16]); 
				3 : I2C_RXBYTE(rd_data[31:24]); 
				4 : I2C_RXBYTE(rd_data[39:32]); 
				5 : I2C_RXBYTE(rd_data[47:40]); 
				6 : I2C_RXBYTE(rd_data[55:48]); 
				7 : I2C_RXBYTE(rd_data[63:56]); 
				8 : I2C_RXBYTE(rd_data[71:64]); 
				9 : I2C_RXBYTE(rd_data[79:72]); 
				10 : I2C_RXBYTE(rd_data[87:80]); 
				11 : I2C_RXBYTE(rd_data[95:88]); 
				12 : I2C_RXBYTE(rd_data[103:96]); 
				13 : I2C_RXBYTE(rd_data[111:104]); 
				14 : I2C_RXBYTE(rd_data[119:112]); 
				15 : I2C_RXBYTE(rd_data[127:120]); 
        	endcase
//        	I2C_RXBYTE(rd_data[bc*8+7:bc*8]);
			if (bc == num_byte-1) begin
        		I2C_TXNACK;
			end
			else begin
        		I2C_TXACK;
			end
		end
        I2C_TXSTOP;
    end
endtask // I2C_READ

