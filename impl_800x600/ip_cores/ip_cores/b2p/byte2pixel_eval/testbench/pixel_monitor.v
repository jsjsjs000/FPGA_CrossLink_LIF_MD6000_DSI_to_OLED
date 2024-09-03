// =========================================================================
// Filename: pixel_monitor.v
// Copyright(c) 2017 Lattice Semiconductor Corporation. All rights reserved.
// =========================================================================
////////////////////////////////////////////////////////
/// • Intermotion Technology
/// • B2P Changes
/// • Date MAY 2, 2019
/// • Arman Arshakyan
/// • Directives are changed to parameters.
/// • "received_sync_data.log" and "received_data.log" separate files are used insted of one "output_data.log" file.
/// • Changed/updated some signal names.
//////////////////////////////////////////////////////////////////////////////////

module pixel_monitor #(
    parameter RX_TYPE      = "DSI",
    parameter PD_BUS_WIDTH = 24,
    parameter PIXEL_COUNT  = 1,
    parameter TX_CH        = 1
    )
   (input enable_write_log,
    input clk,
    input reset,
    input de_o,
    input hsync,
    input vsync,
    input [(PD_BUS_WIDTH*TX_CH)-1:0] pixel_data,
    input line_valid,
    input frame_valid
   );

reg [PD_BUS_WIDTH-1:0] data,data1,data2,data3;
integer received_pixel_counter = 0;

    initial begin
        if (RX_TYPE == "DSI")
            detect_pixel_data_in_dsi;
        else
            detect_pixel_data_in_csi2;
    end    

    // post map sim fix
    reg sync_file_write_en;
    initial begin
      sync_file_write_en = 0;
      #10
      sync_file_write_en = 1;
    end

    always @(posedge vsync) begin
      if (sync_file_write_en == 1)
        write_vsync_hsync("received_sync_data.log", 1);
    end

    always @(posedge hsync) begin
      if (sync_file_write_en == 1) begin
        #1;
        write_vsync_hsync("received_sync_data.log", 0);
      end
    end

    task detect_pixel_data_in_dsi;
    begin
        forever begin
            @(posedge clk);
            if(de_o ==1 && PIXEL_COUNT==1) begin
                data = pixel_data[PD_BUS_WIDTH-1:0];
                write_to_file("received_data.log", data);
            end
            else if(de_o ==1 && PIXEL_COUNT==2) begin
                if(TX_CH==2) begin
                    data = pixel_data[PD_BUS_WIDTH-1:0] ; 
                    data1 = pixel_data[(2*PD_BUS_WIDTH)-1:PD_BUS_WIDTH];
                    write_to_file("received_data.log", data);
                    write_to_file("received_data.log", data1);
                end
                else if(TX_CH==1) begin
                    data = pixel_data[(PD_BUS_WIDTH/2)-1:0] ; 
                    data1 = pixel_data[PD_BUS_WIDTH-1:(PD_BUS_WIDTH/2)];
                    write_to_file("received_data.log", data);
                    write_to_file("received_data.log", data1);
                end
            end
            else if(de_o ==1 && PIXEL_COUNT==4) begin
                data = pixel_data[(PD_BUS_WIDTH/2)-1:0] ; 
                data1 = pixel_data[PD_BUS_WIDTH-1:(PD_BUS_WIDTH/2)] ; 
                data2 = pixel_data[(PD_BUS_WIDTH+(PD_BUS_WIDTH/2))-1:PD_BUS_WIDTH];
                data3 = pixel_data[(2*PD_BUS_WIDTH)-1:(PD_BUS_WIDTH+(PD_BUS_WIDTH/2))];
                write_to_file("received_data.log", data);
                write_to_file("received_data.log", data1);
                write_to_file("received_data.log", data2);
                write_to_file("received_data.log", data3);
            end
        end
    end
    endtask

   task detect_pixel_data_in_csi2;
   begin
     
      forever begin
         @(posedge clk);
         

            if(line_valid ==1 && frame_valid==1 && PIXEL_COUNT==1) begin
                data = pixel_data[PD_BUS_WIDTH-1:0] ; 
                write_to_file("received_data.log", data);
            end

            else if(line_valid ==1 && frame_valid==1 && PIXEL_COUNT==2) begin
              if(TX_CH==2) begin
                data = pixel_data[PD_BUS_WIDTH-1:0] ; 
                data1 = pixel_data[(2*PD_BUS_WIDTH)-1:PD_BUS_WIDTH] ; 
                write_to_file("received_data.log", data);
                write_to_file("received_data.log", data1);
              end
              else if(TX_CH==1) begin
                data = pixel_data[(PD_BUS_WIDTH/2)-1:0] ; 
                data1 = pixel_data[PD_BUS_WIDTH-1:(PD_BUS_WIDTH/2)] ; 
                write_to_file("received_data.log", data);
                write_to_file("received_data.log", data1);
              end
            end
            else if(line_valid ==1 && frame_valid==1 && PIXEL_COUNT==4) begin
                data = pixel_data[(PD_BUS_WIDTH/2)-1:0] ; 
                data1 = pixel_data[PD_BUS_WIDTH-1:(PD_BUS_WIDTH/2)] ; 
                data2 = pixel_data[(PD_BUS_WIDTH+(PD_BUS_WIDTH/2))-1:PD_BUS_WIDTH] ; 
                data3 = pixel_data[(2*PD_BUS_WIDTH)-1:(PD_BUS_WIDTH+(PD_BUS_WIDTH/2))] ; 
                write_to_file("received_data.log", data);
                write_to_file("received_data.log", data1);
                write_to_file("received_data.log", data2);
                write_to_file("received_data.log", data3);
            end
      end
    end
    endtask

    task write_to_file (input [1024*4-1:0]str_in, input [PD_BUS_WIDTH-1:0]data);
    //task write_to_file (input [1024*4-1:0]str_in, input [(PD_BUS_WIDTH*TX_CH)-1:0]data);
        integer filedesc;
    begin
        if(enable_write_log == 1) begin
         filedesc = $fopen(str_in,"a");
         $fwrite(filedesc, "%h\n", data);
         $fclose(filedesc);
         received_pixel_counter = received_pixel_counter + 1;
        end
    end
    endtask


    task write_vsync_hsync ( input [1024*4-1:0]str_in,input vsync);
         integer filedesc;
    begin
        if(enable_write_log == 1) begin
            filedesc = $fopen(str_in,"a");
            if(vsync == 1) begin
               $fwrite(filedesc, "VSYNC\n");
            end
            else begin
               $fwrite(filedesc, "HSYNC\n");
            end
            $fclose(filedesc);
        end
    end
    endtask

endmodule
