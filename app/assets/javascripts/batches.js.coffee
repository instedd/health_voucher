batchInfo = {}

@onBatchIndex = ->
  refreshBatches()

@refreshBatches = ->
  batches = $('.batches').find('[data-generating=true]')
  if batches.length > 0

    now = new Date().getTime()
    batches.each (idx, batch) ->
      row = $(batch)
      id = row.data('id')
      available = parseInt(row.find('.available').first().text())

      if batchInfo[id]
        bi = batchInfo[id]
        last_sample = bi.samples[bi.samples.length - 1]

        if available - last_sample.available == 0
          # generation stalled, reset samples
          bi.samples = [ time: now, available: available ]
        else
          if bi.samples.length >= 2
            first_sample = bi.samples[0]
            elapsed = now - first_sample.time
            generated = available - first_sample.available
            rate = generated / elapsed * 1000
            eta = (bi.total - available) / rate

            if eta > 120
              eta = Math.round(eta / 60)
              message = "#{eta} minutes"
            else
              message = "#{Math.round(eta)} seconds"
            row.find('.generating').text("(generating cards, ETA #{message})")

          # add sample
          bi.samples.push time: now, available: available
          if bi.samples.length > 4
            bi.samples.shift()

      else
        qty = parseInt(row.find('.quantity').first().text())
        batchInfo[id] = {
          total: qty,
          samples: [ time: now, available: available ]
        }

    # schedule refresh
    setTimeout((->
      ids = batches.map (idx, batch) -> $(batch).data('id')
      $.getScript "/batches/refresh?ids=#{ids.toArray().join(',')}"
    ), 5000)

