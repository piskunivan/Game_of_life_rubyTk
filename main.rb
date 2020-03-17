require 'tk'

$window_size = 650   #height = 650, width = 600

mesBox_title = 'Matrix resolution'.freeze

available_sizes = [10,12,20,24,30,40,50,100,150,200]
time_sleep_betw_loops = [0.6,1,1.5,2,3,5]

root = TkRoot.new{
    title "Game of life"
    minsize(600, 650)
    maxsize(1, 1)
  }
  myFont = TkFont.new("family" => 'Helvetica', "size" => 13)
  resize_btn_font = TkFont.new("family" => 'Helvetica', "size" => 17)

  lbl_size = TkLabel.new(root) do
     textvariable
     borderwidth 3
     relief      "groove"
     font myFont
     place(height: 30, width: 50, x: $window_size  - 135, y: 8)
  end

  lbl_time_sleep = TkLabel.new(root) do
     textvariable
     borderwidth 3
     relief      "groove"
     font myFont
     place(height: 30, width: 50, x: $window_size  - 285, y: 8)
  end

  lbl_info_sleep = TkLabel.new(root) do
     font myFont
     place(height: 30, width: 50, x: $window_size  - 340, y: 8)
  end
  lbl_info_sleep.text = "Delay"

  var_size = TkVariable.new
  lbl_size.textvariable = var_size
  var_size.value = 20

  var_time_sleep = TkVariable.new
  lbl_time_sleep.textvariable = var_time_sleep
  var_time_sleep.value = 1.5

  increase_delay_btn = TkButton.new(root) do
       activebackground "blue"
       borderwidth 0
       text '+'
       cursor "hand2"
       font resize_btn_font
       place(height: 14, width: 14, x: $window_size  - 230, y: 7)
       command(
         ->(){
           if var_time_sleep.value.to_f != time_sleep_betw_loops[-1]
             var_time_sleep.value = time_sleep_betw_loops[time_sleep_betw_loops.index(var_time_sleep.value.to_f)+1]
           end
         }
       )
  end

  reduce_delay_btn = TkButton.new(root) do
       activebackground "blue"
       borderwidth 0
       text '-'
       cursor "hand2"
       font resize_btn_font
       place(height: 14, width: 14, x: $window_size  - 230, y: 25)
       command(
         ->(){
           if  var_time_sleep.value.to_f != time_sleep_betw_loops[0]
             var_time_sleep.value = time_sleep_betw_loops[time_sleep_betw_loops.index(var_time_sleep.value.to_f)-1]
           end
         }
       )
  end

  canvas = TkCanvas.new(root) do
     place(height: $window_size - 50 , width: $window_size-50, x: 0, y: 50)
  end

  start_pause_btn = TkButton.new(root) do
         background  "green3"
         text 'Start'
         state 'disabled'
         activebackground "green"
         cursor "hand2"
         font myFont
         place(height: 30, width: 70, x: 5, y: 8)
       end
  $start_pause_btn_pressed = false

  stop_btn = TkButton.new(root) do
           background  "gray19"
           text 'Reset'
           foreground  "white"
           cursor "hand2"
           font myFont
           place(height: 30, width: 70, x: 95, y: 8)
         end

          # DRAW NEW MATRIX
  draw_new_matrix = lambda do |previos_m,its_after_increase|
    canvas.delete('all')
    current_size = var_size.value.to_i
    cell_size = ($window_size-50)/current_size

    $cells_matrix = (0..current_size-1).map do |i|
                    (0..current_size-1).map do |j|
                      t = TkcRectangle.new(canvas, i*cell_size, j*cell_size, (i+1)*cell_size, (j+1)*cell_size , fill: "gray74",outline: 'white', width: 1)
                      t.bind("Button-1"){|e|
                        t.fill != 'gray16' ? t.fill('gray16') : t.fill('gray74')
                        start_pause_btn.state('normal')
                       }
                    end
                  end

    if previos_m != []
      if its_after_increase
        prev_new_mat_sizes_diff = (current_size - available_sizes[available_sizes.index(current_size)-1]) / 2

        previos_m.each do |live_loc_arr|
          $cells_matrix[live_loc_arr[0]+prev_new_mat_sizes_diff][live_loc_arr[1]+prev_new_mat_sizes_diff].fill = 'gray16'
        end
      else
        prev_new_mat_sizes_diff = (current_size - available_sizes[available_sizes.index(current_size)+1]) / 2
        previos_m.each do |live_loc_arr|
          if (live_loc_arr[0]+prev_new_mat_sizes_diff).between?(0,current_size-1) && (live_loc_arr[1]+prev_new_mat_sizes_diff).between?(0,current_size-1)
              $cells_matrix[live_loc_arr[0]+prev_new_mat_sizes_diff][live_loc_arr[1]+prev_new_mat_sizes_diff].fill = 'gray16'
          end
        end
      end
  end

  end

  save_state_of_map_after_resize = lambda do |its_after_increase|
    if start_pause_btn.state == 'normal'
      live_map = []
      $cells_matrix.each_with_index do |row,id_col|
        row.each_with_index do |cell, id_row|
          live_map << [id_col,id_row] if cell.fill == 'gray16'
        end
      end
      draw_new_matrix.call(live_map,its_after_increase)
    else
       draw_new_matrix.call([],nil)
    end

  end

  inc_matrix = Proc.new do
    if var_size.value.to_i == available_sizes[-1]
      Tk.messageBox(
        type: "ok",
        icon: 'warning',
        title: mesBox_title,
        message: 'Maximum size reached')
    else
      var_size.value = available_sizes[available_sizes.index(var_size.value.to_i)+1]
      save_state_of_map_after_resize.call(true)
    end
  end

  prevent_to_big_manual_resize = lambda do
    if var_size.value.to_i < 40
      inc_matrix.call
    else
      Tk.messageBox(
        type: 'ok',
        icon: 'info',
        title: mesBox_title,
        message: 'Maximum manual size reached'
      )
    end
  end

  reduce_matrix = Proc.new do
    if var_size.value.to_i == available_sizes[0]
      Tk.messageBox(
        type: "ok",
        icon: 'warning',
        title: mesBox_title,
        message: 'Minimum size reached')
    else
      var_size.value = available_sizes[available_sizes.index(var_size.value.to_i)-1]
      save_state_of_map_after_resize.call(false)
    end
  end

  increase_btn = TkButton.new(root) do
       activebackground "blue"
       borderwidth 0
       text '+'
       cursor "hand2"
       font resize_btn_font
       place(height: 16, width: 16, x: $window_size-77, y: 14)
     end
  increase_btn.command prevent_to_big_manual_resize

  reduce_btn = TkButton.new(root) do
      activebackground "blue"
      borderwidth 0
      text '-'
      cursor "hand2"
      font resize_btn_font
      place(height: 16, width: 16, x: $window_size-160, y: 14)
  end
  reduce_btn.command reduce_matrix

  elements_conf_normal_state = lambda do
    start_pause_btn.configure('text', 'Start')
    start_pause_btn.configure('background','green3')
    canvas.configure('state','normal')
    increase_btn.configure('state', 'normal')
    reduce_btn.configure('state', 'normal')
  end

  stop_btn.command (
          ->() do
                    canvas.delete("all")
                    $t.exit
                    elements_conf_normal_state.call
                    draw_new_matrix.call([],nil)
                    start_pause_btn.configure('state', 'disabled')
                    stop_btn.configure('disabled')
                    $start_pause_btn_pressed = false
              end
         )

  def is_need_to_resize?
      # if 3-neighbors-cell in bottom, top row; right, left column
    $math_matrix[0].each{|e| return true if e==3}
    $math_matrix[-1].each{|e| return true if e==3}
    for i in (0...$math_matrix.size)
      if $math_matrix[i][0] == 3 || $math_matrix[i][-1] == 3
           return true
      end
    end
    return false
  end

 start_pause_btn.command (
          ->() do
                  $start_pause_btn_pressed = !$start_pause_btn_pressed
                  if $start_pause_btn_pressed
                    start_pause_btn.configure('text', 'Pause')
                    start_pause_btn.configure('background','firebrick3')
                    canvas.configure('state','disabled')
                    increase_btn.configure('state', 'disabled')
                    reduce_btn.configure('state', 'disabled')
                    $t = Thread.new{
                      loop do
                          sleep(var_time_sleep.value.to_f/3)
                          $math_matrix = Array.new(var_size.value.to_i+2){Array.new(var_size.value.to_i+2){0}}
                              #neighbors count for each cell set
                          $cells_matrix.each_with_index do |col,idx|
                            col.each_with_index do |cell, idy|
                              if cell.fill == 'gray16'
                                $math_matrix[idy][idx] += 1
                                $math_matrix[idy+1][idx] += 1
                                $math_matrix[idy+2][idx] += 1
                                $math_matrix[idy+2][idx+1] += 1
                                $math_matrix[idy+2][idx+2] += 1
                                $math_matrix[idy+1][idx+2] += 1
                                $math_matrix[idy][idx+2] += 1
                                $math_matrix[idy][idx+1] += 1
                              end
                            end
                          end
                          if is_need_to_resize?
                            inc_matrix.call
                            next
                          end
                          $math_matrix[1..-2].each_with_index do |row,idy|
                            row[1..-2].each_with_index do |cell,idx|
                              if $cells_matrix[idx][idy].fill == 'gray74'
                                $cells_matrix[idx][idy].fill = 'gray16' if cell == 3
                              else
                                $cells_matrix[idx][idy].fill = 'gray74' if cell<2 || cell>3
                              end
                            end
                          end
                    end}
                  else
                      $t.exit
                      elements_conf_normal_state.call
                  end
              end
         )
    draw_new_matrix.call([],nil)
  Tk.mainloop()
