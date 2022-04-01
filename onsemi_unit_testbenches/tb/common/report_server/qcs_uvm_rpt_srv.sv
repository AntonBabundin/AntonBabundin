//------------------------------------------------------------------------------
//
//  *** *** ***
// *   *   *   *
// *   *    *     Quantenna
// *   *     *    Connectivity
// *   *      *   Solutions
// * * *   *   *
//  *** *** ***
//     *
//------------------------------------------------------------------------------

class qcs_uvm_rpt_srv extends uvm_default_report_server;
  local string filename_cache[string];
  local string hier_cache[string];

  int unsigned file_name_width = 30;
  int unsigned hier_width = 30;

  // Flags to add/remove element from the log line
  bit show_verbosity = 0;
  bit show_terminator = 0;
  bit show_severity = 1;
  bit show_file_name = 1;
  bit show_time = 1;
  bit show_heir = 1;
  bit show_id = 1;

  // Mostly, extension of the base uvm_default_report_server::compose_report_message
  virtual function string compose_report_message(uvm_report_message report_message,
    string report_object_name = ""
  );
    string sev_string;
    uvm_severity l_severity;
    uvm_verbosity l_verbosity;
    string filename_line_string;
    string time_str;
    string line_str;
    string id_str;
    string context_str;
    string verbosity_str;
    string terminator_str;
    string msg_body_str;
    uvm_report_message_element_container el_container;
    string prefix;
    uvm_report_handler l_report_handler;

    // Custom
    // Hierarchical path
    string hier_str;

    if (show_severity) begin
      l_severity = report_message.get_severity();
      sev_string = $sformatf("%-10s", l_severity.name());
    end

    // Format filename & line-number
    if (show_file_name && report_message.get_filename() != "") begin
      line_str.itoa(report_message.get_line());
      filename_line_string = {"[",
        format_file_name(report_message.get_filename(), line_str), "]"};
    end

    // Make definable in terms of units.
    if (show_time)
      $swrite(time_str, "{%-12t}", $time());

    // Format hier
    if (show_heir) begin
      if (report_object_name == "") begin
        l_report_handler = report_message.get_report_handler();
        report_object_name = l_report_handler.get_full_name();
      end

      if (report_message.get_context() != "") begin
        context_str = {"@@", report_message.get_context()};
      end

      hier_str = {report_object_name, context_str};
      hier_str = format_hier(hier_str);
    end

    if (show_verbosity) begin
      if ($cast(l_verbosity, report_message.get_verbosity()))
        verbosity_str = l_verbosity.name();
      else
        verbosity_str.itoa(report_message.get_verbosity());

      verbosity_str = $sformatf("(%-10s)", verbosity_str);
    end

    if (show_id)
      id_str = {"[", report_message.get_id(), "]"};

    if (show_terminator)
      terminator_str = {" -", sev_string};

    el_container = report_message.get_element_container();

    if (el_container.size() == 0)
      msg_body_str = report_message.get_message();
    else begin
      prefix = uvm_default_printer.knobs.prefix;
      uvm_default_printer.knobs.prefix = " +";
      msg_body_str = {report_message.get_message(), "\n", el_container.sprint()};
      uvm_default_printer.knobs.prefix = prefix;
    end

    compose_report_message = {sev_string, verbosity_str, filename_line_string, time_str,
      hier_str, id_str, ": ", msg_body_str, terminator_str};
  endfunction : compose_report_message

  // Cut the full file name + (line number)
  function string format_file_name(string filename, string line);
    int last_slash;
    int flen;

    if(filename.len() > 0) begin
      last_slash = filename.len() - 1;
      if(file_name_width > 0) begin
        if(filename_cache.exists(filename))
          format_file_name = filename_cache[filename];
        else begin
          while(filename[last_slash] != "/" && last_slash != 0)
            last_slash--;
          if(filename[last_slash] == "/")
            format_file_name = filename.substr(last_slash + 1, filename.len() - 1);
          else
            format_file_name = filename;

          format_file_name = $sformatf("%s(%s)", format_file_name, line);
          flen = format_file_name.len();

          if(flen < file_name_width)
            format_file_name = {format_file_name, {(file_name_width-flen){" "}}};

          filename_cache[filename] = format_file_name;
        end
      end else
        format_file_name = "";
    end
  endfunction : format_file_name

  // Cut the full hierarchical path
  function string format_hier(string str);
    int hier_len = str.len();
    if(hier_width > 0) begin
      if(hier_cache.exists(str))
        format_hier = hier_cache[str];
      else begin
        if(hier_len > 13 && str.substr(0,12) == "uvm_test_top.") begin
          str = str.substr(13, hier_len - 1);
          hier_len -= 13;
        end

        if(hier_len < hier_width)
          format_hier = {str, {(hier_width - hier_len){" "}}};
        else
          format_hier = str;

        format_hier = {"[", format_hier, "]"};
        hier_cache[str] = format_hier;
      end
    end
    else
      format_hier = "";
  endfunction : format_hier
endclass : qcs_uvm_rpt_srv