// =========================================================================
// Filename: dsi_tasks.v
// Copyright(c) 2017 Lattice Semiconductor Corporation. All rights reserved.
// =========================================================================

////////////////////////////////////////////////////////
/// • Intermotion Technology
/// • B2P Changes
/// • Date MAY 2, 2019
/// • Arman Arshakyan
/// • Directives are changed to parameters.
/// • "expected_data.log" filen ame is used insted of "input_data.log" file.
/// • Changed/updated some signals/parameters names.
/// • "task gen_byte" is moved to byte_driver.v;
//////////////////////////////////////////////////////////////////////////////////

task gen_dsi_rgb888_pixel_data;
begin
    gen_byte();

    if(RX_CH ==1 || RX_CH ==2 || RX_CH ==4)begin
        pix_data_0_buf = {b[0],b[1],b[2]};
    end 
    //if( ((RX_CH ==2 || RX_CH ==4) && GEAR == 8) || ((RX_CH ==1 || RX_CH ==2) && GEAR == 16) )begin
    if((RX_CH ==2  && GEAR == 8) || ((RX_CH ==1 || RX_CH ==2) && GEAR == 16) || RX_CH == 4)begin
        pix_data_1_buf = {b[3],b[4],b[5]};
    end
    if(RX_CH ==4 || (RX_CH==2 && GEAR==16))begin
        pix_data_2_buf = {b[6],b[7],b[8]};
        pix_data_3_buf = {b[9],b[10],b[11]};

        if(RX_CH ==4 && GEAR==16) begin
            pix_data_4_buf = {b[12],b[13],b[14]};
            pix_data_5_buf = {b[15],b[16],b[17]};
            pix_data_6_buf = {b[18],b[19],b[20]};
            pix_data_7_buf = {b[21],b[22],b[23]};
        end
    end

    if(RX_CH ==1 || RX_CH ==2 || RX_CH ==4)begin
        write_to_file("expected_data.log", pix_data_0_buf);
    end
    //if( ((RX_CH ==2 || RX_CH ==4) && GEAR == 8) || ((RX_CH ==1 || RX_CH ==2) && GEAR == 16) )begin
    if((RX_CH ==2  && GEAR == 8) || ((RX_CH ==1 || RX_CH ==2) && GEAR == 16) || RX_CH == 4)begin
        write_to_file("expected_data.log", pix_data_1_buf);
    end
    if(RX_CH ==4 || (RX_CH==2 && GEAR==16))begin
        write_to_file("expected_data.log", pix_data_2_buf);
        write_to_file("expected_data.log", pix_data_3_buf);
        if(RX_CH ==4 && GEAR==16) begin
            write_to_file("expected_data.log", pix_data_4_buf);
            write_to_file("expected_data.log", pix_data_5_buf);
            write_to_file("expected_data.log", pix_data_6_buf);
            write_to_file("expected_data.log", pix_data_7_buf);
        end
    end

    drive_dsi_byte_data;
end
endtask

task gen_dsi_rgb666_lp_pixel_data;
begin
     gen_byte();

    if(RX_CH ==1 || RX_CH ==2 || RX_CH ==4)begin
        pix_data_0_buf = {b[0][7:2],b[1][7:2],b[2][7:2]};
    end 
     //if( ((RX_CH ==2 || RX_CH ==4) && GEAR == 8) || ((RX_CH ==1 || RX_CH ==2) && GEAR == 16) )begin
    if((RX_CH ==2  && GEAR == 8) || ((RX_CH ==1 || RX_CH ==2) && GEAR == 16) || RX_CH == 4)begin
        pix_data_1_buf = {b[3][7:2],b[4][7:2],b[5][7:2]};
    end
    if(RX_CH ==4 || (RX_CH==2 && GEAR==16))begin
        pix_data_2_buf = {b[6][7:2],b[7][7:2],b[8][7:2]};
        pix_data_3_buf = {b[9][7:2],b[10][7:2],b[11][7:2]};
        if(RX_CH ==4 && GEAR==16) begin
            pix_data_4_buf = {b[12][7:2],b[13][7:2],b[14][7:2]};
            pix_data_5_buf = {b[15][7:2],b[16][7:2],b[17][7:2]};
            pix_data_6_buf = {b[18][7:2],b[19][7:2],b[20][7:2]};
            pix_data_7_buf = {b[21][7:2],b[22][7:2],b[23][7:2]};
        end
    end

    if(RX_CH ==1 || RX_CH ==2 || RX_CH ==4)begin
        write_to_file("expected_data.log", pix_data_0_buf);
    end
    //if( ((RX_CH ==2 || RX_CH ==4) && GEAR == 8) || ((RX_CH ==1 || RX_CH ==2) && GEAR == 16) )begin
    if( (RX_CH ==2  && GEAR == 8) || ((RX_CH ==1 || RX_CH ==2) && GEAR == 16) || RX_CH == 4)begin
        write_to_file("expected_data.log", pix_data_1_buf);
    end
    if(RX_CH ==4 || (RX_CH==2 && GEAR==16))begin
        write_to_file("expected_data.log", pix_data_2_buf);
        write_to_file("expected_data.log", pix_data_3_buf);
        if(RX_CH ==4 && GEAR==16) begin
            write_to_file("expected_data.log", pix_data_4_buf);
            write_to_file("expected_data.log", pix_data_5_buf);
            write_to_file("expected_data.log", pix_data_6_buf);
            write_to_file("expected_data.log", pix_data_7_buf);
        end
    end

    drive_dsi_byte_data;
end
endtask

task gen_dsi_rgb666_pixel_data ; 
begin
    gen_byte();

    if(RX_CH ==1 || RX_CH ==2 || RX_CH ==4)begin
        pix_data_0_buf = {b[0][5:0],b[1][3:0],b[0][7:6],b[2][1:0],b[1][7:4]};
        pix_data_1_buf = {b[2][7:2],b[3][5:0],b[4][3:0],b[3][7:6]};
        pix_data_2_buf = {b[5][1:0],b[4][7:4],b[5][7:2],b[6][5:0]};
        pix_data_3_buf = {b[7][3:0],b[6][7:6],b[8][1:0],b[7][7:4],b[8][7:2]};
     end
    //if( ((RX_CH ==2 || RX_CH ==4) && GEAR == 8) || ((RX_CH ==1 || RX_CH ==2) && GEAR == 16) )begin
    if( (RX_CH ==2  && GEAR == 8) || ((RX_CH ==1 || RX_CH ==2) && GEAR == 16) || RX_CH == 4)begin
        pix_data_4_buf = {b[9][5:0],b[10][3:0],b[9][7:6],b[11][1:0],b[10][7:4]};
        pix_data_5_buf = {b[11][7:2],b[12][5:0],b[13][3:0],b[12][7:6]};
        pix_data_6_buf = {b[14][1:0],b[13][7:4],b[14][7:2],b[15][5:0]};
        pix_data_7_buf = {b[16][3:0],b[15][7:6],b[17][1:0],b[16][7:4],b[17][7:2]};
    end
    if(RX_CH ==4 || (RX_CH==2 && GEAR==16))begin
        pix_data_8_buf  = {b[18][5:0],b[19][3:0],b[18][7:6],b[20][1:0],b[19][7:4]};
        pix_data_9_buf  = {b[20][7:2],b[21][5:0],b[22][3:0],b[21][7:6]};
        pix_data_10_buf = {b[23][1:0],b[22][7:4],b[23][7:2],b[24][5:0]};
        pix_data_11_buf = {b[25][3:0],b[24][7:6],b[26][1:0],b[25][7:4],b[26][7:2]};

        pix_data_12_buf = {b[27][5:0],b[28][3:0],b[27][7:6],b[29][1:0],b[28][7:4]};
        pix_data_13_buf = {b[29][7:2],b[30][5:0],b[31][3:0],b[30][7:6]};
        pix_data_14_buf = {b[32][1:0],b[31][7:4],b[32][7:2],b[33][5:0]};
        pix_data_15_buf = {b[34][3:0],b[33][7:6],b[35][1:0],b[34][7:4],b[35][7:2]};

        if(RX_CH==4 && GEAR==16) begin
            pix_data_16_buf = {b[36][5:0],b[37][3:0],b[36][7:6],b[38][1:0],b[37][7:4]};
            pix_data_17_buf = {b[38][7:2],b[39][5:0],b[40][3:0],b[39][7:6]};
            pix_data_18_buf = {b[41][1:0],b[40][7:4],b[41][7:2],b[42][5:0]};
            pix_data_19_buf = {b[43][3:0],b[42][7:6],b[44][1:0],b[43][7:4],b[44][7:2]};

            pix_data_20_buf = {b[45][5:0],b[46][3:0],b[45][7:6],b[47][1:0],b[46][7:4]};
            pix_data_21_buf = {b[47][7:2],b[48][5:0],b[49][3:0],b[48][7:6]};
            pix_data_22_buf = {b[50][1:0],b[49][7:4],b[50][7:2],b[51][5:0]};
            pix_data_23_buf = {b[52][3:0],b[51][7:6],b[53][1:0],b[52][7:4],b[53][7:2]};

            pix_data_24_buf = {b[54][5:0],b[55][3:0],b[54][7:6],b[56][1:0],b[55][7:4]};
            pix_data_25_buf = {b[56][7:2],b[57][5:0],b[58][3:0],b[57][7:6]};
            pix_data_26_buf = {b[59][1:0],b[58][7:4],b[59][7:2],b[60][5:0]};
            pix_data_27_buf = {b[61][3:0],b[60][7:6],b[62][1:0],b[61][7:4],b[62][7:2]};

            pix_data_28_buf = {b[63][5:0],b[64][3:0],b[63][7:6],b[65][1:0],b[64][7:4]};
            pix_data_29_buf = {b[65][7:2],b[66][5:0],b[67][3:0],b[66][7:6]};
            pix_data_30_buf = {b[68][1:0],b[67][7:4],b[68][7:2],b[69][5:0]};
            pix_data_31_buf = {b[70][3:0],b[69][7:6],b[71][1:0],b[70][7:4],b[71][7:2]};
        end
    end
    if(RX_CH ==1 || RX_CH ==2 || RX_CH ==4)begin
        write_to_file("expected_data.log", pix_data_0_buf);
        write_to_file("expected_data.log", pix_data_1_buf);
        write_to_file("expected_data.log", pix_data_2_buf);
        write_to_file("expected_data.log", pix_data_3_buf);
    end 
    //if( ((RX_CH ==2 || RX_CH ==4) && GEAR == 8) || ((RX_CH ==1 || RX_CH ==2) && GEAR == 16) )begin
    if((RX_CH ==2  && GEAR == 8) || ((RX_CH ==1 || RX_CH ==2) && GEAR == 16) || RX_CH == 4)begin
        write_to_file("expected_data.log", pix_data_4_buf);
        write_to_file("expected_data.log", pix_data_5_buf);
        write_to_file("expected_data.log", pix_data_6_buf);
        write_to_file("expected_data.log", pix_data_7_buf);
    end
    if(RX_CH ==4 || (RX_CH==2 && GEAR==16))begin
        write_to_file("expected_data.log", pix_data_8_buf);
        write_to_file("expected_data.log", pix_data_9_buf);
        write_to_file("expected_data.log", pix_data_10_buf);
        write_to_file("expected_data.log", pix_data_11_buf);
        write_to_file("expected_data.log", pix_data_12_buf);
        write_to_file("expected_data.log", pix_data_13_buf);
        write_to_file("expected_data.log", pix_data_14_buf);
        write_to_file("expected_data.log", pix_data_15_buf);
        if(RX_CH==4 && GEAR==16) begin
            write_to_file("expected_data.log", pix_data_16_buf);
            write_to_file("expected_data.log", pix_data_17_buf);
            write_to_file("expected_data.log", pix_data_18_buf);
            write_to_file("expected_data.log", pix_data_19_buf);
            write_to_file("expected_data.log", pix_data_20_buf);
            write_to_file("expected_data.log", pix_data_21_buf);
            write_to_file("expected_data.log", pix_data_22_buf);
            write_to_file("expected_data.log", pix_data_23_buf);
            write_to_file("expected_data.log", pix_data_24_buf);
            write_to_file("expected_data.log", pix_data_25_buf);
            write_to_file("expected_data.log", pix_data_26_buf);
            write_to_file("expected_data.log", pix_data_27_buf);
            write_to_file("expected_data.log", pix_data_28_buf);
            write_to_file("expected_data.log", pix_data_29_buf);
            write_to_file("expected_data.log", pix_data_30_buf);
            write_to_file("expected_data.log", pix_data_31_buf);
        end
    end

    drive_dsi_byte_data;
end
endtask

task drive_dsi_byte_data;
begin
    if(RX_CH ==1 && GEAR == 8)begin
        for(i=0;i<num_bytes;i=i+1)begin
            byte_data <= b[i];
            @(posedge clk);
        end
    end
    if((RX_CH ==2 && GEAR == 8) || (RX_CH ==1 && GEAR == 16)) begin
        for(i=0;i<num_bytes*2;i=i+2)begin
            byte_data <= {b[i+1],b[i]};
            @(posedge clk);
        end
     end
    if((RX_CH ==4 && GEAR==8) || (RX_CH ==2 && GEAR==16)) begin
        for(i=0;i<num_bytes*4;i=i+4)begin
            byte_data <= {b[i+3],b[i+2],b[i+1],b[i]};
            @(posedge clk);
        end
    end
    if(RX_CH ==4 && GEAR==16) begin
        for(i=0;i<num_bytes*8;i=i+8)begin
            byte_data <= {b[i+7],b[i+6],b[i+5],b[i+4],b[i+3],b[i+2],b[i+1],b[i]};
            @(posedge clk);
        end
    end
end
endtask
