defmodule Tapper.Plug.HeaderPropagation do

  require Logger

  @b3_trace_id_header "x-b3-traceid"
  @b3_span_id_header "x-b3-spanid"
  @b3_parent_span_id_header "x-b3-parentspanid"
  @b3_sampled_header "x-b3-sampled"
  @b3_flags_header "x-b3-flags"

  @type sampled :: boolean() | :absent

  @spec decode([{String.t, String.t}]) :: {:join, Tapper.Id.TraceId.t, Tapper.Id.SpanId.t, Tapper.Id.SpanId.t, sampled(), boolean()} | :start
  def decode(headers) do
    with {@b3_trace_id_header, trace_id} <- List.keyfind(headers, @b3_trace_id_header, 0),
      {@b3_span_id_header, span_id} <- List.keyfind(headers, @b3_span_id_header, 0),
      {@b3_parent_span_id_header, parent_span_id} <- List.keyfind(headers, @b3_parent_span_id_header, 0, {@b3_parent_span_id_header, :root}),
      {:ok, trace_id} <- Tapper.TraceId.parse(trace_id),
      {:ok, span_id} <- Tapper.SpanId.parse(span_id),
      {:ok, parent_span_id} <- if(parent_span_id == :root, do: {:ok, :root}, else: Tapper.SpanId.parse(parent_span_id))
    do
      sample = case List.keyfind(headers, @b3_sampled_header, 0) do
        {_, sampled} -> sampled == "1"
        nil -> :absent
      end

      flags = case List.keyfind(headers, @b3_flags_header, 0) do
        {_, flags} -> flags
        nil -> ""
      end

      debug = flags == "1"

      {:join, trace_id, span_id, parent_span_id, sample, debug}
    else
      nil ->
        Logger.debug("No B3 headers (or incomplete ones)")
        :start
      :error ->
        Logger.info("Bad B3 headers #{inspect headers}")
        :start
    end

  end

end
