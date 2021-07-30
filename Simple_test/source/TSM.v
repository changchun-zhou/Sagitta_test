state wait_for_4th_rising_edge_of_signal:
    if ((wr_val == 1'bR) && (cfg_info == 2) && ($counter0 == 3)) then
        reset_counter $counter0;
        trigger;
    elseif ((wr_val == 1'bR) && (cfg_info == 2)) then
        increment_counter $counter0;
        goto wait_for_4th_rising_edge_of_signal;
    else 
        goto wait_for_4th_rising_edge_of_signal;
        
    endif